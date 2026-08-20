// Ultima VII's map consists of 12x12 "superchunks", each of which is 16x16 "chunks".
// A chunk consists of 16x16 cells. The world is 192x192 chunks (3072x3072 tiles).
//
// Terrain draws a camera-centered TILEWIDTH x TILEHEIGHT patch by blitting
// 8x8 shape tiles into a render texture. That RT is expensive to rebuild, so
// Update() is dirty-flagged: camera tile, day/night, dungeon view, palette
// step, and (at night) nearby light sources.

#include "U7Globals.h"
#include "U7Object.h"
#include "Terrain.h"
#include "Logging.h"
#include "raymath.h"

#include <algorithm>
#include <cstring>

using namespace std;

bool Terrain::ColorsEqual(Color a, Color b)
{
	return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
}

Terrain::Terrain()
{
	m_height = 3072;
	m_width = 3072;

	// Temporary 1x1 until UpdateTerrainTexture loads the real atlas.
	Image blank = GenImageColor(8, 8, Color{ 0, 0, 0, 0 });
	m_terrainTiles = LoadTextureFromImage(blank);
	UnloadImage(blank);

	m_currentTerrain = LoadRenderTexture(TILEWIDTH * 8, TILEHEIGHT * 8);
	m_cellModel = LoadModelFromMesh(GenMeshPlane(TILEWIDTH, TILEHEIGHT, 1, 1));
	SetMaterialTexture(&m_cellModel.materials[0], MATERIAL_MAP_DIFFUSE, m_currentTerrain.texture);

	// Default lighting to white so object draw before first Update is safe.
	for (int i = 0; i < TILEWIDTH; ++i)
	{
		for (int j = 0; j < TILEHEIGHT; ++j)
		{
			m_cellLighting[i][j] = WHITE;
		}
	}
}

Terrain::~Terrain()
{
	UnloadModel(m_cellModel);
	UnloadRenderTexture(m_currentTerrain);
	if (m_terrainColorImage.data != nullptr)
	{
		UnloadImage(m_terrainColorImage);
		m_terrainColorImage = { 0 };
	}
	if (m_terrainIndexImage.data != nullptr)
	{
		UnloadImage(m_terrainIndexImage);
		m_terrainIndexImage = { 0 };
	}
	if (m_terrainTiles.id > 0)
	{
		UnloadTexture(m_terrainTiles);
		m_terrainTiles = { 0 };
	}
}

void Terrain::Init()
{
	SetupChunkData();
	MarkDirty();
}

void Terrain::MarkDirty()
{
	m_forceDirty = true;
}

void Terrain::UpdateTerrainTexture(Image img)
{
	if (m_terrainColorImage.data != nullptr)
	{
		UnloadImage(m_terrainColorImage);
	}
	// Keep a CPU copy so palette cycling can rewrite water pixels.
	m_terrainColorImage = ImageCopy(img);

	if (m_terrainTiles.id > 0)
	{
		UnloadTexture(m_terrainTiles);
	}
	m_terrainTiles = LoadTextureFromImage(m_terrainColorImage);
	SetTextureFilter(m_terrainTiles, TEXTURE_FILTER_POINT);
	MarkDirty();
}

void Terrain::SetTerrainIndexImage(Image indexImage)
{
	if (m_terrainIndexImage.data != nullptr)
	{
		UnloadImage(m_terrainIndexImage);
	}
	m_terrainIndexImage = indexImage;
	m_terrainHasPaletteAnim = (m_terrainIndexImage.data != nullptr);
	m_lastTerrainPaletteStep = -1;
	MarkDirty();
}

void Terrain::ApplyPaletteToTerrainAtlas()
{
	if (!m_terrainHasPaletteAnim || m_terrainColorImage.data == nullptr || m_terrainIndexImage.data == nullptr)
	{
		return;
	}

	const int step = static_cast<int>(GetTime() * 8.0) % 8;
	if (step == m_lastTerrainPaletteStep)
	{
		return;
	}
	m_lastTerrainPaletteStep = step;

	// Only rewrite tiles that capture glisten/cycle indices.
	for (int shape = 0; shape < 150; ++shape)
	{
		for (int frame = 0; frame < 32; ++frame)
		{
			ShapeData& shapeData = g_shapeTable[shape][frame];
			if (shapeData.m_palettePixels.empty())
			{
				continue;
			}

			const int baseX = shape * 8;
			const int baseY = frame * 8;
			for (const auto& pixel : shapeData.m_palettePixels)
			{
				const int pX = std::get<0>(pixel);
				const int pY = std::get<1>(pixel);
				const int pRef = std::get<2>(pixel);
				if (pRef < 0 || pRef > 255)
				{
					continue;
				}

				const int atlasX = baseX + pX;
				const int atlasY = baseY + pY;
				if (atlasX < 0 || atlasY < 0 || atlasX >= m_terrainColorImage.width || atlasY >= m_terrainColorImage.height)
				{
					continue;
				}

				Color idxSample = GetImageColor(m_terrainIndexImage, atlasX, atlasY);
				if (idxSample.a < 128)
				{
					continue;
				}
				const int idx = idxSample.r;
				ImageDrawPixel(&m_terrainColorImage, atlasX, atlasY, g_runtimePalette[idx]);
			}
		}
	}

	UpdateTexture(m_terrainTiles, m_terrainColorImage.data);
	// Atlas contents changed → ground RT must re-blit tiles.
	MarkDirty();
}

void Terrain::Draw()
{
	DrawModel(m_cellModel, { float(int(g_camera.target.x)), 0, float(int(g_camera.target.z)) }, 1, WHITE);
}

void Terrain::Shutdown()
{
}

uint64_t Terrain::ComputeLightHash() const
{
	// XOR-only so order of g_sortedVisibleObjects (distance sort thrash) does not
	// flip the hash every frame while the same lights are present.
	uint64_t h = 0;
	for (U7Object* object : g_sortedVisibleObjects)
	{
		if (!object || !object->m_objectData || !object->m_objectData->m_isLightSource)
		{
			continue;
		}
		// Pack id + tile coords into one word then XOR.
		const uint64_t id = static_cast<uint64_t>(static_cast<uint32_t>(object->m_ID));
		const uint64_t tx = static_cast<uint64_t>(static_cast<uint32_t>(static_cast<int>(object->m_Pos.x)));
		const uint64_t tz = static_cast<uint64_t>(static_cast<uint32_t>(static_cast<int>(object->m_Pos.z)));
		h ^= (id * 0x9E3779B97F4A7C15ull) ^ (tx << 20) ^ (tz << 1);
	}
	return h;
}

void Terrain::Update()
{
	const int centerX = static_cast<int>(g_camera.target.x);
	const int centerZ = static_cast<int>(g_camera.target.z);

	uint64_t lightHash = m_cachedLightHash;
	if (!g_isDay)
	{
		lightHash = ComputeLightHash();
	}
	else
	{
		lightHash = 0;
	}

	const char* reason = nullptr;
	if (m_forceDirty)
		reason = "force";
	else if (centerX != m_cachedCenterTileX || centerZ != m_cachedCenterTileZ)
		reason = "camera_tile";
	else if (!ColorsEqual(g_dayNightColor, m_cachedDayNightColor) || g_isDay != m_cachedIsDay)
		reason = "day_night";
	else if (g_dungeonViewActive != m_cachedDungeonView)
		reason = "dungeon";
	else if (m_lastTerrainPaletteStep != m_cachedPaletteStep)
		reason = "palette";
	else if (lightHash != m_cachedLightHash)
		reason = "lights";

	if (reason == nullptr)
	{
		++m_skipsThisSecond;
		return;
	}

	const double t0 = GetTime();
	CalculateLighting();
	UpdateTerrainTiles();
	const double ms = (GetTime() - t0) * 1000.0;

	++m_rebuildsThisSecond;
	m_rebuildMsThisSecond += ms;
	m_lastDirtyReason = reason;

	m_forceDirty = false;
	m_cachedCenterTileX = centerX;
	m_cachedCenterTileZ = centerZ;
	m_cachedDayNightColor = g_dayNightColor;
	m_cachedIsDay = g_isDay;
	m_cachedDungeonView = g_dungeonViewActive;
	m_cachedPaletteStep = m_lastTerrainPaletteStep;
	m_cachedLightHash = lightHash;
}

void Terrain::CalculateLighting()
{
	// Fill the whole patch with ambient day/night color.
	for (int i = 0; i < TILEWIDTH; ++i)
	{
		for (int j = 0; j < TILEHEIGHT; ++j)
		{
			m_cellLighting[i][j] = g_dayNightColor;
		}
	}

	if (g_isDay)
	{
		return;
	}

	// Stamp light discs only (was: every light × full 100×100 grid).
	constexpr int softLightRange = 14;
	constexpr int lightRange = 3;
	const int lightRangeSq = lightRange * lightRange;
	const int softLightRangeSq = softLightRange * softLightRange;

	const int camX = static_cast<int>(g_camera.target.x);
	const int camZ = static_cast<int>(g_camera.target.z);
	const int patchMinX = camX - (TILEWIDTH / 2);
	const int patchMinZ = camZ - (TILEHEIGHT / 2);

	const Color hardLight = { 208, 208, 192, 255 };
	const Color softLight = { 144, 144, 128, 255 };

	for (U7Object* object : g_sortedVisibleObjects)
	{
		if (!object || !object->m_objectData || !object->m_objectData->m_isLightSource)
		{
			continue;
		}

		const int lightX = static_cast<int>(object->m_Pos.x);
		const int lightZ = static_cast<int>(object->m_Pos.z);

		const int worldMinX = lightX - softLightRange;
		const int worldMaxX = lightX + softLightRange;
		const int worldMinZ = lightZ - softLightRange;
		const int worldMaxZ = lightZ + softLightRange;

		// Clamp stamp region to the camera patch.
		const int minWX = std::max(worldMinX, patchMinX);
		const int maxWX = std::min(worldMaxX, patchMinX + TILEWIDTH - 1);
		const int minWZ = std::max(worldMinZ, patchMinZ);
		const int maxWZ = std::min(worldMaxZ, patchMinZ + TILEHEIGHT - 1);

		for (int wx = minWX; wx <= maxWX; ++wx)
		{
			for (int wz = minWZ; wz <= maxWZ; ++wz)
			{
				const int dx = wx - lightX;
				const int dz = wz - lightZ;
				const int distSq = dx * dx + dz * dz;

				const int cellx = (TILEWIDTH / 2) + wx - camX;
				const int celly = (TILEHEIGHT / 2) + wz - camZ;
				if (cellx < 0 || cellx >= TILEWIDTH || celly < 0 || celly >= TILEHEIGHT)
				{
					continue;
				}

				if (distSq <= lightRangeSq)
				{
					m_cellLighting[cellx][celly] = hardLight;
				}
				else if (distSq <= softLightRangeSq)
				{
					Color& cell = m_cellLighting[cellx][celly];
					if (cell.r < 128 && cell.g < 128 && cell.b < 128)
					{
						cell = softLight;
					}
				}
			}
		}
	}
}

void Terrain::UpdateTerrainTiles()
{
	unsigned short prevShape = 0;
	unsigned short prevFrame = 0;

	const int camX = static_cast<int>(g_camera.target.x);
	const int camZ = static_cast<int>(g_camera.target.z);

	BeginTextureMode(m_currentTerrain);
	ClearBackground(BLANK);

	for (int i = camX - (TILEWIDTH / 2); i <= camX + (TILEWIDTH / 2 - 1); ++i)
	{
		for (int j = camZ - (TILEHEIGHT / 2); j <= camZ + (TILEHEIGHT / 2 - 1); ++j)
		{
			if (i < 0 || j < 0 || i >= 3072 || j >= 3072)
			{
				continue;
			}

			const int cellx = (TILEWIDTH / 2) + i - camX;
			const int celly = TILEHEIGHT - ((TILEHEIGHT / 2) + j - camZ);

			// Exult dungeon blackness: exterior tiles go black under a mountain.
			if (g_dungeonViewActive && g_pathfindingSystem
				&& !g_pathfindingSystem->IsDungeonTile(i, j))
			{
				DrawRectangle(cellx * 8, (celly - 1) * 8, 8, 8, BLACK);
				continue;
			}

			unsigned short shapenum = g_World[j][i] & 0x3ff;
			unsigned short framenum = (g_World[j][i] >> 10) & 0x1f;
			if (shapenum >= 150 || framenum >= 32)
			{
				// Hole in the terrain — reuse previous tile type.
				shapenum = prevShape;
				framenum = prevFrame;
			}
			else
			{
				prevShape = shapenum;
				prevFrame = framenum;
			}

			// Lighting grid uses world-relative cell coords (not flipped Y).
			const int lightY = (TILEHEIGHT / 2) + j - camZ;
			const Color light = (cellx >= 0 && cellx < TILEWIDTH && lightY >= 0 && lightY < TILEHEIGHT)
				? m_cellLighting[cellx][lightY]
				: g_dayNightColor;

			DrawTexturePro(
				m_terrainTiles,
				{ float(shapenum * 8), float(framenum * 8), 8, 8 },
				{ float(cellx * 8), float(celly * 8), 8, -8 },
				{ 0, 0 },
				0,
				light);
		}
	}
	EndTextureMode();
}

void Terrain::SetupChunkData()
{
	// Chunk building/pathfinding data is filled after the world object list exists:
	// PathfindingSystem::PopulateChunkPathfindingGrid() → BuildChunkBuildingData().
	// Terrain::Init runs before IFIX, so this is intentionally a no-op placeholder.
}
