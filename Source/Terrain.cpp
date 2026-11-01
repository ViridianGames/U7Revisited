// Ultima VII's map consists of 12x12 "superchunks", each of which is 16x16 "chunks".
// A chunk consists of 16x16 cells. The world is 192x192 chunks (3072x3072 tiles).
//
// Terrain draws a camera-centered TILEWIDTH x TILEHEIGHT patch by blitting
// 8x8 shape tiles into a render texture. That RT is expensive to rebuild, so
// Update() is dirty-flagged: camera tile, day/night, dungeon view, palette
// step, and (at night or in dungeons) nearby light sources.
//
// Exult: dungeon interiors always use the night palette (gameclk get_time_palette
// with dungeon=true). Without a torch / light spell the view is night-dark;
// light sources only illuminate local discs around them.

#include "U7Globals.h"
#include "U7Object.h"
#include "U7Player.h"
#include "Terrain.h"
#include "Logging.h"
#include "raymath.h"

#include <algorithm>
#include <cmath>
#include <cstring>
#include <vector>

using namespace std;

namespace
{
	// Same RGB as MainState night ambient (darklevel 64 / red_green 32).
	constexpr Color kDungeonAmbient = { 32, 32, 64, 255 };

	bool NeedsDynamicLighting()
	{
		return !g_isDay || g_dungeonViewActive;
	}

	Color AmbientLightingColor()
	{
		// Exult: dungeon → night palette regardless of clock hour.
		if (g_dungeonViewActive)
			return kDungeonAmbient;
		return g_dayNightColor;
	}

	// Exult Actor::add_light_source: lit items in left/right hand only.
	bool UnitHoldsLightSource(U7Object* unit)
	{
		if (!unit || !unit->m_NPCData)
			return false;
		static const EquipmentSlot kHands[] = {
			EquipmentSlot::SLOT_LEFT_HAND,
			EquipmentSlot::SLOT_RIGHT_HAND,
		};
		for (EquipmentSlot slot : kHands)
		{
			const int itemId = unit->m_NPCData->GetEquippedItem(slot);
			if (itemId < 0)
				continue;
			U7Object* item = GetObjectFromID(itemId);
			if (item && item->m_objectData && item->m_objectData->m_isLightSource)
				return true;
		}
		return false;
	}

	// Case-insensitive substring check (ASCII).
	bool NameContainsI(const std::string& name, const char* needle)
	{
		if (!needle || !*needle || name.empty())
			return false;
		const size_t nlen = std::strlen(needle);
		if (name.size() < nlen)
			return false;
		for (size_t i = 0; i + nlen <= name.size(); ++i)
		{
			bool match = true;
			for (size_t j = 0; j < nlen; ++j)
			{
				const char a = name[i + j];
				const char b = needle[j];
				const char al = (a >= 'A' && a <= 'Z') ? static_cast<char>(a - 'A' + 'a') : a;
				const char bl = (b >= 'A' && b <= 'Z') ? static_cast<char>(b - 'A' + 'a') : b;
				if (al != bl)
				{
					match = false;
					break;
				}
			}
			if (match)
				return true;
		}
		return false;
	}

	// House/dungeon vertical occluders. Many building walls are OW_CLIMBABLE in
	// object_walkability.csv (standable tops) — still block light by name.
	bool NameSuggestsLightOccluder(const std::string& name)
	{
		if (NameContainsI(name, "wall")) // wall, broken wall, metal wall, …
			return true;
		if (NameContainsI(name, "portcullis"))
			return true;
		if (NameContainsI(name, "fence"))
			return true;
		if (NameContainsI(name, "cavern"))
			return true;
		if (NameContainsI(name, "fortress"))
			return true;
		if (NameContainsI(name, "iron bars"))
			return true;
		return false;
	}

	// Tall walls / closed doors block dynamic light. Windows (TFA translucent,
	// e.g. shape 438) and short furniture do not.
	bool ObjectBlocksDynamicLight(const U7Object* obj)
	{
		if (!obj || !obj->m_objectData || !obj->m_shapeData)
			return false;
		if (obj->m_isContained)
			return false;
		if (const_cast<U7Object*>(obj)->GetIsDead())
			return false;
		if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC ||
			obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_MONSTER ||
			obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_EGG)
		{
			return false;
		}

		// Glass / stained-glass panes let light through (including "glass wall").
		if (obj->m_objectData->m_isTranslucent)
			return false;

		const int shapeID = obj->m_shapeData->GetShape();
		if (shapeID >= 0 && PathfindingSystem::IsPassThroughObject(shapeID))
			return false;
		if (shapeID >= 0 && (PathfindingSystem::IsRoofShape(shapeID)
			|| PathfindingSystem::IsMountainTopShape(shapeID)))
		{
			return false;
		}

		// Fully sunk / open barriers (portcullis in the floor, etc.).
		if (PathfindingSystem::GetObjectSurfaceY(obj) <= 0.05f)
			return false;

		const std::string& name = obj->m_objectData->m_name;
		const bool namedOccluder = NameSuggestsLightOccluder(name);

		// Floors/stairs/rugs — skip unless the shape is a misclassified wall
		// (e.g. shape 344 "wall" sits in IsWalkableSurface's 341-344 range).
		if (shapeID >= 0 && PathfindingSystem::IsNonBlockingWalkSurface(shapeID)
			&& !namedOccluder)
		{
			return false;
		}

		// Closed doors block light even though pathfinding treats them as OW_DOOR.
		if (obj->m_objectData->m_isDoor)
			return obj->m_objectData->m_height >= 2.0f;

		ObjectWalkability walk = OW_WALKABLE;
		if (g_pathfindingSystem)
			walk = g_pathfindingSystem->GetObjectWalkability(shapeID, obj);

		if (walk == OW_WALKABLE || walk == OW_DOOR)
			return false;

		// Climbable CSV walls (common for house exteriors/interiors): occlude by name.
		// Other climbables (tables, desks, carts) stay non-occluding.
		if (walk == OW_CLIMBABLE)
			return namedOccluder && obj->m_objectData->m_height >= 2.0f;

		// OW_BLOCKING from CSV (even when TFA not-walkable is clear — walls 151/152)
		// or TFA not-walkable tall solids.
		if (walk != OW_BLOCKING && !obj->m_objectData->m_isNotWalkable)
			return false;

		if (obj->m_objectData->m_height < 2.0f)
			return false;

		return true;
	}

	// Bresenham LOS against a packed occlusion grid. Endpoints are not required
	// to be clear (torch against a wall still lights its own tile and neighbors).
	bool HasLightLOS(int x0, int z0, int x1, int z1,
		const std::vector<uint8_t>& blocks, int occMinX, int occMinZ, int occW, int occH)
	{
		if (x0 == x1 && z0 == z1)
			return true;

		const int dx = std::abs(x1 - x0);
		const int dz = std::abs(z1 - z0);
		const int sx = x0 < x1 ? 1 : -1;
		const int sz = z0 < z1 ? 1 : -1;
		int err = dx - dz;
		int x = x0;
		int z = z0;

		while (true)
		{
			if (!(x == x0 && z == z0) && !(x == x1 && z == z1))
			{
				const int lx = x - occMinX;
				const int lz = z - occMinZ;
				if (lx >= 0 && lz >= 0 && lx < occW && lz < occH
					&& blocks[static_cast<size_t>(lz * occW + lx)] != 0)
				{
					return false;
				}
			}
			if (x == x1 && z == z1)
				break;
			const int e2 = 2 * err;
			if (e2 > -dz) { err -= dz; x += sx; }
			if (e2 < dx) { err += dx; z += sz; }
		}
		return true;
	}
}

bool Terrain::ColorsEqual(Color a, Color b)
{
	return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
}

Color Terrain::GetAmbientLightingColor() const
{
	return AmbientLightingColor();
}

Color Terrain::GetLightingAtWorld(int worldX, int worldZ) const
{
	const int camX = static_cast<int>(g_camera.target.x);
	const int camZ = static_cast<int>(g_camera.target.z);
	const int cellx = (TILEWIDTH / 2) + worldX - camX;
	const int celly = (TILEHEIGHT / 2) + worldZ - camZ;
	if (cellx < 0 || cellx >= TILEWIDTH || celly < 0 || celly >= TILEHEIGHT)
		return AmbientLightingColor();
	return m_cellLighting[cellx][celly];
}

Color Terrain::GetLightingForObject(const U7Object* obj, Vector3 viewPos) const
{
	if (!obj || !obj->m_objectData)
		return AmbientLightingColor();

	const int shapeID = obj->m_shapeData ? obj->m_shapeData->GetShape() : obj->m_ObjectType;
	const std::string& name = obj->m_objectData->m_name;

	// Roofs never pick up local discs.
	if (PathfindingSystem::IsRoofShape(shapeID)
		|| NameContainsI(name, "roof"))
	{
		return AmbientLightingColor();
	}

	const int w = std::max(1, static_cast<int>(obj->m_objectData->m_width));
	const int d = std::max(1, static_cast<int>(obj->m_objectData->m_depth));
	// SE-origin footprint (same as pathfinding stamps).
	const int maxTileX = static_cast<int>(std::floor(obj->m_Pos.x));
	const int maxTileZ = static_cast<int>(std::floor(obj->m_Pos.z));
	const int minTileX = maxTileX - w + 1;
	const int minTileZ = maxTileZ - d + 1;
	const float centerX = (static_cast<float>(minTileX) + static_cast<float>(maxTileX)) * 0.5f;
	const float centerZ = (static_cast<float>(minTileZ) + static_cast<float>(maxTileZ)) * 0.5f;

	const bool verticalBarrier =
		NameSuggestsLightOccluder(name)
		|| NameContainsI(name, "window")
		|| obj->m_objectData->m_isDoor;

	if (verticalBarrier)
	{
		// Facing test:
		// - Long wall + camera clearly off its plane → thin-axis half-space.
		// - 1x1 posts, or camera nearly edge-on (cardinal views along a wall) →
		//   XZ hemisphere toward the camera. Near-cardinal edge-on used to flip
		//   sign(dz)/sign(dx) on noise so a behind-wall light counted as facing.
		const float dx = viewPos.x - centerX;
		const float dz = viewPos.z - centerZ;
		const float viewDist = std::sqrt(dx * dx + dz * dz);
		const bool isPost = (w == 1 && d == 1);

		// sin(angle off the wall plane); below this ≈ edge-on / unstable.
		constexpr float kClearSin = 0.30f; // ~17.5°
		constexpr float kLightRange = 15.0f;
		constexpr float kLightRangeSq = kLightRange * kLightRange;
		constexpr float kPlaneEps = 0.15f;
		constexpr float kHemisphereCos = 0.08f; // light must sit a bit in front

		float nx = 0.0f;
		float nz = 0.0f;
		bool usePlane = false;
		int probeX = (minTileX + maxTileX) / 2;
		int probeZ = (minTileZ + maxTileZ) / 2;

		if (!isPost && w >= d * 3 / 2)
		{
			// Elongated along X → faces ±Z.
			const float clear = (viewDist > 1e-3f) ? (std::fabs(dz) / viewDist) : 0.0f;
			if (clear >= kClearSin)
			{
				usePlane = true;
				nz = (dz >= 0.0f) ? 1.0f : -1.0f;
				probeZ = (nz > 0.0f) ? (maxTileZ + 1) : (minTileZ - 1);
			}
		}
		else if (!isPost && d >= w * 3 / 2)
		{
			// Elongated along Z → faces ±X.
			const float clear = (viewDist > 1e-3f) ? (std::fabs(dx) / viewDist) : 0.0f;
			if (clear >= kClearSin)
			{
				usePlane = true;
				nx = (dx >= 0.0f) ? 1.0f : -1.0f;
				probeX = (nx > 0.0f) ? (maxTileX + 1) : (minTileX - 1);
			}
		}

		if (!usePlane)
		{
			// Hemisphere path: probe along the stronger camera axis.
			if (std::fabs(dx) >= std::fabs(dz))
			{
				probeX = (dx >= 0.0f) ? (maxTileX + 1) : (minTileX - 1);
			}
			else
			{
				probeZ = (dz >= 0.0f) ? (maxTileZ + 1) : (minTileZ - 1);
			}
		}

		auto lightFacesWall = [&](float lx, float lz) -> bool
		{
			const float ldx = lx - centerX;
			const float ldz = lz - centerZ;
			const float lightDistSq = ldx * ldx + ldz * ldz;
			if (lightDistSq > kLightRangeSq)
				return false;

			if (usePlane)
				return (nx * ldx + nz * ldz) > kPlaneEps;

			// Hemisphere toward camera; reject near-orthogonal lights.
			const float lightDist = std::sqrt(lightDistSq);
			if (viewDist < 1e-3f || lightDist < 1e-3f)
				return false;
			const float cosAng = (dx * ldx + dz * ldz) / (viewDist * lightDist);
			return cosAng > kHemisphereCos;
		};

		bool litFromFacingSide = false;
		auto consider = [&](float lx, float lz)
		{
			if (!litFromFacingSide && lightFacesWall(lx, lz))
				litFromFacingSide = true;
		};

		for (U7Object* lightObj : g_sortedVisibleObjects)
		{
			if (!lightObj || !lightObj->m_objectData || !lightObj->m_objectData->m_isLightSource)
				continue;
			consider(lightObj->m_Pos.x, lightObj->m_Pos.z);
			if (litFromFacingSide)
				break;
		}
		if (!litFromFacingSide && g_spellLightRemaining > 0.f && g_Player)
		{
			if (U7Object* avatar = g_Player->GetAvatarObject())
				consider(avatar->m_Pos.x, avatar->m_Pos.z);
		}
		if (!litFromFacingSide && g_Player)
		{
			for (int npcId : g_Player->GetPartyMemberIds())
			{
				auto itNpc = g_NPCData.find(npcId);
				if (itNpc == g_NPCData.end() || !itNpc->second)
					continue;
				U7Object* member = GetObjectFromID(itNpc->second->m_objectID);
				if (!UnitHoldsLightSource(member))
					continue;
				consider(member->m_Pos.x, member->m_Pos.z);
				if (litFromFacingSide)
					break;
			}
		}

		if (!litFromFacingSide)
			return AmbientLightingColor();

		return GetLightingAtWorld(probeX, probeZ);
	}

	return GetLightingAtWorld(maxTileX, maxTileZ);
}

void Terrain::FillCuboidFaceLighting(const U7Object* obj, Color outFaces[6]) const
{
	const Color ambient = AmbientLightingColor();
	for (int i = 0; i < 6; ++i)
		outFaces[i] = ambient;

	if (!obj || !obj->m_objectData)
		return;

	const int shapeID = obj->m_shapeData ? obj->m_shapeData->GetShape() : obj->m_ObjectType;
	const std::string& name = obj->m_objectData->m_name;
	if (PathfindingSystem::IsRoofShape(shapeID) || NameContainsI(name, "roof"))
		return;

	const bool verticalBarrier =
		NameSuggestsLightOccluder(name)
		|| NameContainsI(name, "window")
		|| obj->m_objectData->m_isDoor;
	if (!verticalBarrier)
	{
		// Non-wall cuboid: same omnidirectional cell lighting on every face.
		const Color lit = GetLightingAtWorld(
			static_cast<int>(std::floor(obj->m_Pos.x)),
			static_cast<int>(std::floor(obj->m_Pos.z)));
		for (int i = 0; i < 6; ++i)
			outFaces[i] = lit;
		return;
	}

	const int w = std::max(1, static_cast<int>(obj->m_objectData->m_width));
	const int d = std::max(1, static_cast<int>(obj->m_objectData->m_depth));
	const int maxTileX = static_cast<int>(std::floor(obj->m_Pos.x));
	const int maxTileZ = static_cast<int>(std::floor(obj->m_Pos.z));
	const int minTileX = maxTileX - w + 1;
	const int minTileZ = maxTileZ - d + 1;
	const float centerX = (static_cast<float>(minTileX) + static_cast<float>(maxTileX)) * 0.5f;
	const float centerZ = (static_cast<float>(minTileZ) + static_cast<float>(maxTileZ)) * 0.5f;

	// Match DrawModelEx Y-rotation (degrees → raylib MatrixRotateY).
	const float yawRad = obj->m_Angle * DEG2RAD;
	const float c = std::cos(yawRad);
	const float s = std::sin(yawRad);

	constexpr float kLightRange = 15.0f;
	constexpr float kLightRangeSq = kLightRange * kLightRange;
	constexpr float kPlaneEps = 0.15f;

	// Local XZ normals: FRONT +Z, RIGHT +X, BACK -Z, LEFT -X.
	// World: (nx,nz) → (nx*c + nz*s, -nx*s + nz*c).
	struct FaceDef
	{
		int side; // CuboidSides index
		float localNx;
		float localNz;
	};
	const FaceDef verticalFaces[4] = {
		{ 1, 0.0f, 1.0f },  // FRONT
		{ 2, 1.0f, 0.0f },  // RIGHT
		{ 4, 0.0f, -1.0f }, // BACK
		{ 5, -1.0f, 0.0f }, // LEFT
	};

	float lightXs[64];
	float lightZs[64];
	int lightCount = 0;
	auto addLight = [&](float lx, float lz)
	{
		if (lightCount >= 64)
			return;
		const float ldx = lx - centerX;
		const float ldz = lz - centerZ;
		if (ldx * ldx + ldz * ldz > kLightRangeSq)
			return;
		lightXs[lightCount] = lx;
		lightZs[lightCount] = lz;
		++lightCount;
	};

	for (U7Object* lightObj : g_sortedVisibleObjects)
	{
		if (!lightObj || !lightObj->m_objectData || !lightObj->m_objectData->m_isLightSource)
			continue;
		addLight(lightObj->m_Pos.x, lightObj->m_Pos.z);
	}
	if (g_spellLightRemaining > 0.f && g_Player)
	{
		if (U7Object* avatar = g_Player->GetAvatarObject())
			addLight(avatar->m_Pos.x, avatar->m_Pos.z);
	}
	if (g_Player)
	{
		for (int npcId : g_Player->GetPartyMemberIds())
		{
			auto itNpc = g_NPCData.find(npcId);
			if (itNpc == g_NPCData.end() || !itNpc->second)
				continue;
			U7Object* member = GetObjectFromID(itNpc->second->m_objectID);
			if (!UnitHoldsLightSource(member))
				continue;
			addLight(member->m_Pos.x, member->m_Pos.z);
		}
	}

	const float halfX = static_cast<float>(w) * 0.5f;
	const float halfZ = static_cast<float>(d) * 0.5f;

	for (const FaceDef& face : verticalFaces)
	{
		const float nwx = face.localNx * c + face.localNz * s;
		const float nwz = -face.localNx * s + face.localNz * c;

		bool lit = false;
		for (int i = 0; i < lightCount; ++i)
		{
			const float side = nwx * (lightXs[i] - centerX) + nwz * (lightZs[i] - centerZ);
			if (side > kPlaneEps)
			{
				lit = true;
				break;
			}
		}
		if (!lit)
		{
			outFaces[face.side] = ambient;
			continue;
		}

		// Probe one tile outside along the face normal.
		const float reach = std::fabs(nwx) * halfX + std::fabs(nwz) * halfZ + 0.85f;
		const int probeX = static_cast<int>(std::floor(centerX + nwx * reach));
		const int probeZ = static_cast<int>(std::floor(centerZ + nwz * reach));
		outFaces[face.side] = GetLightingAtWorld(probeX, probeZ);
	}

	// Top / bottom stay ambient (no torch glow on wall caps).
	outFaces[0] = ambient;
	outFaces[3] = ambient;
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

	// Spell light: active bit + avatar tile so appear/expire/move dirty the RT.
	if (g_spellLightRemaining > 0.f)
	{
		h ^= 0xC0117E55ull;
		U7Object* avatar = g_Player ? g_Player->GetAvatarObject() : nullptr;
		if (avatar)
		{
			const uint64_t tx = static_cast<uint64_t>(static_cast<uint32_t>(static_cast<int>(avatar->m_Pos.x)));
			const uint64_t tz = static_cast<uint64_t>(static_cast<uint32_t>(static_cast<int>(avatar->m_Pos.z)));
			h ^= (tx << 20) ^ (tz << 1);
		}
	}

	// Equipped hand lights on party members (inventory items are not in the
	// visible-object light scan).
	if (g_Player)
	{
		for (int npcId : g_Player->GetPartyMemberIds())
		{
			auto itNpc = g_NPCData.find(npcId);
			if (itNpc == g_NPCData.end() || !itNpc->second)
				continue;
			U7Object* member = GetObjectFromID(itNpc->second->m_objectID);
			if (!UnitHoldsLightSource(member))
				continue;
			h ^= 0x71A7Cull + static_cast<uint64_t>(npcId) * 0x9E3779B97F4A7C15ull;
			const uint64_t tx = static_cast<uint64_t>(static_cast<uint32_t>(static_cast<int>(member->m_Pos.x)));
			const uint64_t tz = static_cast<uint64_t>(static_cast<uint32_t>(static_cast<int>(member->m_Pos.z)));
			h ^= (tx << 20) ^ (tz << 1);
		}
	}
	return h;
}

void Terrain::Update()
{
	const int centerX = static_cast<int>(g_camera.target.x);
	const int centerZ = static_cast<int>(g_camera.target.z);

	uint64_t lightHash = m_cachedLightHash;
	if (NeedsDynamicLighting())
		lightHash = ComputeLightHash();
	else
		lightHash = 0;

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
	const Color ambient = AmbientLightingColor();

	// Fill the whole patch with ambient (day, night, or dungeon-as-night).
	for (int i = 0; i < TILEWIDTH; ++i)
	{
		for (int j = 0; j < TILEHEIGHT; ++j)
		{
			m_cellLighting[i][j] = ambient;
		}
	}

	// Day outdoors: full bright, no local lights. Night and dungeons: stamp discs.
	if (!NeedsDynamicLighting())
		return;

	// Smooth radial falloff (peak → ambient). Full brightness out to brightCore,
	// then softstep to ambient at softLightRange (larger bright disc, soft rim).
	constexpr int softLightRange = 15;
	constexpr float brightCoreRange = 6.0f;
	const int softLightRangeSq = softLightRange * softLightRange;
	const float falloffSpan = static_cast<float>(softLightRange) - brightCoreRange;
	constexpr Color peakLight = { 208, 208, 192, 255 };

	const int camX = static_cast<int>(g_camera.target.x);
	const int camZ = static_cast<int>(g_camera.target.z);
	const int patchMinX = camX - (TILEWIDTH / 2);
	const int patchMinZ = camZ - (TILEHEIGHT / 2);
	const int patchMaxX = patchMinX + TILEWIDTH - 1;
	const int patchMaxZ = patchMinZ + TILEHEIGHT - 1;

	// Occlusion grid covers the lit patch plus one soft radius so LOS near the
	// edge still sees walls just outside the camera window.
	const int occMinX = patchMinX - softLightRange;
	const int occMaxX = patchMaxX + softLightRange;
	const int occMinZ = patchMinZ - softLightRange;
	const int occMaxZ = patchMaxZ + softLightRange;
	const int occW = occMaxX - occMinX + 1;
	const int occH = occMaxZ - occMinZ + 1;
	std::vector<uint8_t> blocks(static_cast<size_t>(occW * occH), 0);

	auto stampBlockerFootprint = [&](const U7Object* obj)
	{
		const int w = std::max(1, static_cast<int>(obj->m_objectData->m_width));
		const int d = std::max(1, static_cast<int>(obj->m_objectData->m_depth));
		const int maxTileX = static_cast<int>(std::floor(obj->m_Pos.x));
		const int maxTileZ = static_cast<int>(std::floor(obj->m_Pos.z));
		const int minTileX = maxTileX - w + 1;
		const int minTileZ = maxTileZ - d + 1;
		for (int z = minTileZ; z <= maxTileZ; ++z)
		{
			if (z < occMinZ || z > occMaxZ)
				continue;
			for (int x = minTileX; x <= maxTileX; ++x)
			{
				if (x < occMinX || x > occMaxX)
					continue;
				blocks[static_cast<size_t>((z - occMinZ) * occW + (x - occMinX))] = 1;
			}
		}
	};

	const int chunkMinX = std::max(0, occMinX / 16);
	const int chunkMaxX = std::min(191, occMaxX / 16);
	const int chunkMinZ = std::max(0, occMinZ / 16);
	const int chunkMaxZ = std::min(191, occMaxZ / 16);
	for (int cz = chunkMinZ; cz <= chunkMaxZ; ++cz)
	{
		for (int cx = chunkMinX; cx <= chunkMaxX; ++cx)
		{
			for (U7Object* obj : g_chunkObjectMap[cx][cz])
			{
				if (ObjectBlocksDynamicLight(obj))
					stampBlockerFootprint(obj);
			}
		}
	}

	auto stampLight = [&](int lightX, int lightZ)
	{
		const int worldMinX = lightX - softLightRange;
		const int worldMaxX = lightX + softLightRange;
		const int worldMinZ = lightZ - softLightRange;
		const int worldMaxZ = lightZ + softLightRange;

		// Clamp stamp region to the camera patch.
		const int minWX = std::max(worldMinX, patchMinX);
		const int maxWX = std::min(worldMaxX, patchMaxX);
		const int minWZ = std::max(worldMinZ, patchMinZ);
		const int maxWZ = std::min(worldMaxZ, patchMaxZ);

		for (int wx = minWX; wx <= maxWX; ++wx)
		{
			for (int wz = minWZ; wz <= maxWZ; ++wz)
			{
				const int dx = wx - lightX;
				const int dz = wz - lightZ;
				const int distSq = dx * dx + dz * dz;
				if (distSq > softLightRangeSq)
					continue;

				const int cellx = (TILEWIDTH / 2) + wx - camX;
				const int celly = (TILEHEIGHT / 2) + wz - camZ;
				if (cellx < 0 || cellx >= TILEWIDTH || celly < 0 || celly >= TILEHEIGHT)
					continue;

				if (!HasLightLOS(lightX, lightZ, wx, wz, blocks, occMinX, occMinZ, occW, occH))
					continue;

				const float dist = std::sqrt(static_cast<float>(distSq));
				float t;
				if (dist <= brightCoreRange)
				{
					t = 1.0f;
				}
				else
				{
					float u = 1.0f - (dist - brightCoreRange) / falloffSpan;
					if (u <= 0.0f)
						continue;
					// Smoothstep across the outer ring only.
					t = u * u * (3.0f - 2.0f * u);
				}

				Color& cell = m_cellLighting[cellx][celly];
				auto blendChan = [&](unsigned char peakC, unsigned char ambC, unsigned char curC) -> unsigned char
				{
					const float lit = static_cast<float>(ambC)
						+ (static_cast<float>(peakC) - static_cast<float>(ambC)) * t;
					return static_cast<unsigned char>(std::min(255.0f, std::max(static_cast<float>(curC), lit)));
				};
				cell.r = blendChan(peakLight.r, ambient.r, cell.r);
				cell.g = blendChan(peakLight.g, ambient.g, cell.g);
				cell.b = blendChan(peakLight.b, ambient.b, cell.b);
				cell.a = 255;
			}
		}
	};

	for (U7Object* object : g_sortedVisibleObjects)
	{
		if (!object || !object->m_objectData || !object->m_objectData->m_isLightSource)
		{
			continue;
		}
		stampLight(static_cast<int>(object->m_Pos.x), static_cast<int>(object->m_Pos.z));
	}

	if (g_spellLightRemaining > 0.f)
	{
		U7Object* avatar = g_Player ? g_Player->GetAvatarObject() : nullptr;
		if (avatar)
		{
			stampLight(static_cast<int>(avatar->m_Pos.x), static_cast<int>(avatar->m_Pos.z));
		}
	}

	// Torches / lanterns held by the party (not drawn as world light props).
	if (g_Player)
	{
		for (int npcId : g_Player->GetPartyMemberIds())
		{
			auto itNpc = g_NPCData.find(npcId);
			if (itNpc == g_NPCData.end() || !itNpc->second)
				continue;
			U7Object* member = GetObjectFromID(itNpc->second->m_objectID);
			if (!UnitHoldsLightSource(member))
				continue;
			stampLight(static_cast<int>(member->m_Pos.x), static_cast<int>(member->m_Pos.z));
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
				: AmbientLightingColor();

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
