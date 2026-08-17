//  Ultima VII's map consistes of 12x12 "superchunks", each of which is 16x16 "chunks".
//
//  A chunk consists of 16x16 cells.
//
//  So the world consists of a 192x192 map of chunks, each of which has 16x16 tiles.
//  
//  Which means that there are 36,864 chunks in the map.  But there are only 3072 unique chunks,
//  which means some are repeated as necessary.
//
//  So the first thing we need to do is create a mesh for each of the 3072 chunks.

#include <fstream>

#include "U7Globals.h"
#include "Terrain.h"

#include <iostream>

#include "Logging.h"
#include "raymath.h"

using namespace std;

Terrain::Terrain()
{ 
   m_height = 3072;
   m_width = 3072;

	m_terrainTiles = LoadTextureFromImage(GenImageColor(2048, 256, Color{ 0, 0, 0, 0 }));
	m_currentTerrain = LoadRenderTexture(TILEWIDTH * 8, TILEHEIGHT * 8);

	m_cellModel = LoadModelFromMesh(GenMeshPlane(TILEWIDTH, TILEHEIGHT, 1, 1));
	SetMaterialTexture(&m_cellModel.materials[0], MATERIAL_MAP_DIFFUSE, m_currentTerrain.texture);
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
}

void Terrain::UpdateTerrainTexture(Image img)
{
	if (m_terrainColorImage.data != nullptr)
	{
		UnloadImage(m_terrainColorImage);
	}
	// Keep a CPU copy so palette cycling can rewrite water pixels
	m_terrainColorImage = ImageCopy(img);

	if (m_terrainTiles.id > 0)
	{
		UnloadTexture(m_terrainTiles);
	}
	m_terrainTiles = LoadTextureFromImage(m_terrainColorImage);
	SetTextureFilter(m_terrainTiles, TEXTURE_FILTER_POINT);
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

	// Only rewrite tiles that capture glisten/cycle indices (224-243)
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

				// Index map is source of truth; color comes from the rotating LUT
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
}

void Terrain::Draw()
{
	DrawModel(m_cellModel, {float(int(g_camera.target.x)), 0, float(int(g_camera.target.z))}, 1, WHITE);
}

void Terrain::Shutdown()
{

}

void Terrain::Update()
{
	UpdateTerrainTiles();
}

void Terrain::CalculateLighting()
{

	//  Calculate lighting grid
	for (int i = 0; i < TILEWIDTH; ++i)
	{
		for (int j = 0; j < TILEHEIGHT; ++j)
		{
			m_cellLighting[i][j] = g_dayNightColor;
		}
	}

	if (g_isDay)
		return;

	int softlightrange = 14;
	int lightrange = 3;
	int lightrangesquared = lightrange * lightrange;
	int softlightrangesquared = softlightrange * softlightrange;
	for (auto object : g_sortedVisibleObjects)
	{
		if (object->m_objectData->m_isLightSource)
		{
			for (int i = g_camera.target.x - (TILEWIDTH / 2); i <= g_camera.target.x + (TILEWIDTH / 2 - 1); i++)
			{
				for (int j = g_camera.target.z - (TILEHEIGHT / 2); j <= g_camera.target.z + (TILEHEIGHT / 2 - 1); j++)
				{
					//  Early outs.  Too far from the center?  Can't be lit, continue.
					if (abs(object->m_Pos.x - i) > softlightrange || abs(object->m_Pos.z - j) > softlightrange)
					{
						continue;
					}

					int cellx = (TILEWIDTH / 2) + i - int(g_camera.target.x);
					int celly = (TILEHEIGHT / 2) + j - int(g_camera.target.z);

					float distance = Vector2DistanceSqr({float(i), float(j)}, {object->m_Pos.x, object->m_Pos.z});

					if (distance <= lightrangesquared)
					{
						m_cellLighting[cellx][celly] = {208, 208, 192, 255};
					}
					else if (distance <= softlightrangesquared)
					{
						Color thiscell = m_cellLighting[cellx][celly];
						if (thiscell.r < 128 && thiscell.g < 128 && thiscell.b < 128)
						{
							m_cellLighting[cellx][celly] = {144, 144, 128, 255};
						}
						// else if (thiscell.r == 128 && thiscell.g == 128 && thiscell.b == 128)
						// {
						//  	m_cellLighting[cellx][celly] = WHITE;
						// }
					}
				}
			}
		}
	}
}

void Terrain::UpdateTerrainTiles()
{
	//  Create terrain tile texture
	unsigned short prevShape = 0;
	unsigned short prevFrame = 0;

	BeginTextureMode(m_currentTerrain);
	for (int i = g_camera.target.x - (TILEWIDTH / 2); i <= g_camera.target.x + (TILEWIDTH / 2 - 1); i++)
	{
		for (int j = g_camera.target.z - (TILEHEIGHT / 2); j <= g_camera.target.z + (TILEHEIGHT / 2 - 1); j++)
		{
			if (i < 0 || j < 0 || i >= 3072 || j >= 3072)
			{
				continue;
			}

			int cellx = (TILEWIDTH / 2) + i - int(g_camera.target.x);
			int celly = TILEHEIGHT - ((TILEHEIGHT / 2) + j - int(g_camera.target.z));

			// Exult dungeon blackness: exterior tiles under the camera go black so
			// only the cave under the mountain shows.
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
				// This is a hole in the terrain, use the previous terrain type
				shapenum = prevShape;
				framenum = prevFrame;
			} else
			{
				prevShape = shapenum;
				prevFrame = framenum;
			}

			DrawTexturePro(m_terrainTiles, { float(shapenum * 8), float(framenum * 8), 8, 8 }, { float(cellx * 8), float(celly * 8), 8, -8 }, { 0, 0 }, 0, m_cellLighting[cellx][TILEHEIGHT - celly]);
		}
	}
	EndTextureMode();
}

void Terrain::SetupChunkData()
{
	// Chunk building/pathfinding data is filled after the world object list exists:
	// PathfindingSystem::PopulateChunkPathfindingGrid() → BuildChunkBuildingData().
	//
	// ChunkInfo (per 16x16 world chunk) tracks:
	//   - walkable[][] / canReach[]   hierarchical pathfinding
	//   - hasRoof / roofGroupID       multi-chunk buildings for roof pop-off
	//   - roofTypeID / roofMaterial   gabled roof type catalog
	//   - interior[][]                under-roof tiles for lighting
	//
	// Terrain::Init runs before IFIX, so this is intentionally a no-op placeholder.
}
