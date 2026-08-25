#include "PathfindingSystem.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "ShapeData.h"
#include "Geist/Logging.h"
#include "rlgl.h"
#include <algorithm>
#include <array>
#include <cmath>
#include <cstring>
#include <fstream>
#include <sstream>
#include <cstdint>
#include <unordered_set>
#include <deque>   // added for stable node storage
#include <shared_mutex>

// ============================================================================
// Hostile-unit blocking helpers
// ============================================================================

static bool IsPartyMemberUnit(const U7Object* unit)
{
	return unit
		&& unit->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC
		&& g_Player
		&& g_Player->NPCIDInParty(unit->m_NPCID);
}

static bool IsPathfindingAgentUnit(const U7Object* unit)
{
	return unit
		&& (unit->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC
			|| unit->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_MONSTER)
		&& unit->m_hp > 0.0f
		&& !unit->m_isContained;
}

bool PathfindingSystem::AreUnitsHostile(const U7Object* agent, const U7Object* other)
{
	if (!IsPathfindingAgentUnit(agent) || !IsPathfindingAgentUnit(other))
		return false;

	if (agent->m_ID == other->m_ID)
		return false;

	bool agentParty = IsPartyMemberUnit(agent);
	bool otherParty = IsPartyMemberUnit(other);

	// Friendly party members can share space (Avatar + Iolo, etc.)
	if (agentParty && otherParty)
		return false;

	// Party vs hostile team, and vice versa
	if (agentParty && other->m_Team == 1)
		return true;
	if (otherParty && agent->m_Team == 1)
		return true;

	return false;
}

static bool UnitOccupiesTileAtHeight(const U7Object* unit, int worldX, int worldZ, float agentBaseY)
{
	if (!unit)
		return false;

	const BoundingBox& bbox = unit->m_boundingBox;
	int minTileX = (int)floor(bbox.min.x);
	int maxTileX = (int)floor(bbox.max.x);
	int minTileZ = (int)floor(bbox.min.z);
	int maxTileZ = (int)floor(bbox.max.z);

	if (worldX < minTileX || worldX > maxTileX || worldZ < minTileZ || worldZ > maxTileZ)
		return false;

	if (fabs(unit->m_Pos.y - agentBaseY) > (MAX_CLIMBABLE_HEIGHT + 0.5f))
		return false;

	return true;
}

static bool IsTileBlockedByHostileUnit(int worldX, int worldZ, float agentBaseY, const U7Object* agent)
{
	if (!agent)
		return false;

	int chunkX = worldX / 16;
	int chunkZ = worldZ / 16;

	extern std::shared_mutex g_chunkMapMutex;
	std::shared_lock lock(g_chunkMapMutex);

	for (int dz = -1; dz <= 1; ++dz)
	{
		for (int dx = -1; dx <= 1; ++dx)
		{
			int cx = chunkX + dx;
			int cz = chunkZ + dz;
			if (cx < 0 || cx >= 192 || cz < 0 || cz >= 192)
				continue;

			for (U7Object* obj : g_chunkObjectMap[cx][cz])
			{
				if (!IsPathfindingAgentUnit(obj))
					continue;

				if (!PathfindingSystem::AreUnitsHostile(agent, obj))
					continue;

				if (UnitOccupiesTileAtHeight(obj, worldX, worldZ, agentBaseY))
					return true;
			}
		}
	}

	return false;
}

// ============================================================================
// PathfindingGrid Implementation
// ============================================================================

PathfindingGrid::PathfindingGrid()
{
	// Tile-based pathfinding - no grid pre-computation needed
	AddConsoleString("Pathfinding system initialized (tile-based)");
}

PathfindingGrid::~PathfindingGrid()
{
}

bool PathfindingGrid::IsPositionWalkable(int worldX, int worldZ, float agentBaseY, const U7Object* agent) const
{
	// Tile-level check using agent-specific base Y
	return CheckTileWalkable(worldX, worldZ, agentBaseY, agent);
}

std::vector<PathfindingGrid::OverlappingObject> PathfindingGrid::GetOverlappingObjects(int worldX, int worldZ) const
{
	std::vector<OverlappingObject> result;

	int chunkX = worldX / 16;
	int chunkZ = worldZ / 16;

	// Check this chunk and neighbors
	for (int dz = -1; dz <= 1; dz++)
	{
		for (int dx = -1; dx <= 1; dx++)
		{
			int cx = chunkX + dx;
			int cz = chunkZ + dz;

			if (cx < 0 || cx >= 192 || cz < 0 || cz >= 192)
				continue;

			for (U7Object* obj : g_chunkObjectMap[cx][cz])
			{
				if (!obj || !obj->m_objectData || !obj->m_shapeData)
					continue;
				if (const_cast<U7Object*>(obj)->GetIsDead())
					continue;
				if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC ||
				    obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_MONSTER)
					continue;
				if (obj->m_isContained)
					continue;
				if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_EGG)
					continue;

				// Logical TFA footprint (SE-origin): same convention as doors/roofs.
				// Draw AABBs over-cover tiles for iso art and block 1-tile corridors.
				const int w = std::max(1, static_cast<int>(obj->m_objectData->m_width));
				const int d = std::max(1, static_cast<int>(obj->m_objectData->m_depth));
				const int maxTileX = static_cast<int>(std::floor(obj->m_Pos.x));
				const int maxTileZ = static_cast<int>(std::floor(obj->m_Pos.z));
				const int minTileX = maxTileX - w + 1;
				const int minTileZ = maxTileZ - d + 1;

				if (worldX < minTileX || worldX > maxTileX || worldZ < minTileZ || worldZ > maxTileZ)
					continue;

				OverlappingObject ovObj;
				ovObj.obj = obj;
				ovObj.tileX = minTileX;
				ovObj.tileZ = minTileZ;
				ovObj.width = w;
				ovObj.depth = d;
				result.push_back(ovObj);
			}
		}
	}

	return result;
}

// Helper: Check if a shape ID is a walkable surface (floors, bridges, stairs)
bool PathfindingSystem::IsWalkableSurface(int shapeID)
{
	// Bridge/floor pieces: 367-370
	if (shapeID >= 367 && shapeID <= 370)
		return true;

	// Additional floor shapes//floor-roof 
	if (shapeID == 1014)
		return true;

	// Stairs: 426-430
	if (shapeID >= 426 && shapeID <= 430)
		return true;

	if (shapeID == 150)//gangplank
		return true;

	if (shapeID >= 186 && shapeID <= 193)//carpet, rug, floor, fortress
		return true;

	if (shapeID == 257)//fortress gateway top
		return true;

	if (shapeID >= 290 && shapeID <= 293) // seats / floors
		return true;

	if (shapeID >= 310 && shapeID <= 313) // wooden floor
		return true;

	if (shapeID >= 314 && shapeID <= 317) // floor
		return true;

	if (shapeID >= 341 && shapeID <= 344) // floor
		return true;

	if (shapeID == 368)//floor
		return true;

	if (shapeID >= 385 && shapeID <= 387)//stairs
		return true;

	if (shapeID >= 607 && shapeID <= 610)//path
		return true;

	if (shapeID >= 973 && shapeID <= 974)//stairs
		return true;

	if (shapeID == 415)//garbage
		return true;

	if (shapeID == 260)//fortress
		return true;

	if (shapeID == 263)//fortress
		return true;

	if (shapeID == 352)//fortress
		return true;

	if (shapeID == 483)//rug
		return true;

	if (shapeID == 700)//deck
		return true;

	if (shapeID == 750)//carpet
		return true;

	if (shapeID == 758)//carpet
		return true;

	if (shapeID == 870)//drawbridge
		return true;

	if (shapeID == 873)//chair
		return true;

	if (shapeID == 897)//seat
		return true;

	if (shapeID == 804)//crate
		return true;

	if (shapeID == 962)
		return true;

	return false;
}

bool PathfindingSystem::IsPassThroughObject(int shapeID)
{
	// Curtains (and similar soft props): walk through; do not block or act as floors.
	// Previously excluded entirely from GetOverlappingObjects.
	return shapeID == 657 || shapeID == 678;
}

bool PathfindingSystem::IsNonBlockingWalkSurface(int shapeID)
{
	// Crates are standable tops with solid sides — they still block volume.
	if (shapeID == 804)
		return false;
	// Pass-through handled separately.
	if (IsPassThroughObject(shapeID))
		return false;
	return IsWalkableSurface(shapeID);
}

float PathfindingSystem::GetObjectSurfaceY(const U7Object* obj)
{
	if (!obj || !obj->m_objectData)
		return obj ? obj->m_Pos.y : 0.0f;

	// Exult: standing lift = object_lift + 3d_height
	// (Chunk_cache::is_blocked → get_highest_blocked(lift) + 1).
	// Roofs/flats are *drawn* as a plane at m_Pos.y, but gameplay lift still
	// includes TFA height (roofs are height 1 → stand one above placement).
	// Returning placement Y alone left the Avatar one lift low vs Exult, so
	// same-lift eggs on roofs (e.g. Trinsic blacksmith at lift 6) never fired.
	return obj->m_Pos.y + obj->m_objectData->m_height;
}

bool PathfindingSystem::IsStandableObjectTop(const U7Object* obj)
{
	if (!obj || !obj->m_objectData || !obj->m_shapeData)
		return false;
	// GetIsDead is non-const on Unit; safe read for path queries.
	if (const_cast<U7Object*>(obj)->GetIsDead() || obj->m_isContained)
		return false;
	if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_EGG ||
	    obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC ||
	    obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_MONSTER)
		return false;
	// Doors are not floors (hinge/block handled separately).
	if (obj->m_objectData->m_isDoor)
		return false;

	const int shapeID = obj->m_shapeData->GetShape();

	// Curtains etc. are not floors.
	if (IsPassThroughObject(shapeID))
		return false;

	// Roofs are always standable (chimney climb / roof walk) at any lift.
	if (IsRoofShape(shapeID))
		return true;

	// Absurd heights only:
	if (obj->m_Pos.y > 32.0f)
		return false;

	// Explicit floors / stairs / crates / chairs / …
	if (IsWalkableSurface(shapeID))
		return true;

	// Decorative flats (signs, paintings, wall hangings) are never floors, even
	// when raised and TFA-height 1 — otherwise hanging signs become walk planes.
	{
		const ShapeDrawType dt = obj->m_shapeData->GetDrawType();
		if (dt == ShapeDrawType::OBJECT_DRAW_FLAT ||
		    dt == ShapeDrawType::OBJECT_DRAW_ANIMFLAT)
			return false;
	}

	// Climbable solid tops: crates/chests/boxes — one step tall only.
	// Tall blockers (signposts, pillars, walls with height 2+) remain volume
	// blockers; they must NOT invent intermediate "rungs" to walk up.
	const float h = obj->m_objectData->m_height;
	if (h <= 0.001f)
		return false;
	if (h > MAX_CLIMBABLE_HEIGHT + 0.05f)
		return false;
	if (!obj->m_objectData->m_isNotWalkable)
		return false;

	return true;
}

// AABB vs AABB intersection helper (axis-aligned)
// static bool AABBIntersectsAABB(const Vector3& minA, const Vector3& maxA, const Vector3& minB, const Vector3& maxB)
// {
// 	if (maxA.x < minB.x || minA.x > maxB.x) return false;
// 	if (maxA.y < minB.y || minA.y > maxB.y) return false;
// 	if (maxA.z < minB.z || minA.z > maxB.z) return false;
// 	return true;
// }

bool PathfindingSystem::ValidateMove(U7Object* agent, const Vector3& desiredPos, float& outDestH)
{
	if (!agent) return false;

	if (!g_pathfindingSystem || !g_pathfindingSystem->m_pathfindingGrid)
	{
		outDestH = desiredPos.y;
		return true;
	}

	PathfindingGrid* grid = g_pathfindingSystem->m_pathfindingGrid.get();

	int destX = (int)floor(desiredPos.x);
	int destZ = (int)floor(desiredPos.z);

	// Bounds check
	if (destX < 0 || destX >= 3072 || destZ < 0 || destZ >= 3072)
		return false;

	// Source height (feet)
	float srcH = agent->m_Pos.y;

	// Prefer explicit desired Y (path waypoints carry the target surface).
	auto heights = grid->GetWalkableSurfaceHeights(destX, destZ);
	if (heights.empty())
		heights.push_back(0.0f);

	const float stepLim = MAX_CLIMBABLE_HEIGHT + 0.05f;
	float destH = srcH;
	{
		// Surfaces reachable in one step from current feet.
		std::vector<float> inStep;
		inStep.reserve(heights.size());
		for (float h : heights)
		{
			if (fabsf(h - srcH) <= stepLim)
				inStep.push_back(h);
		}
		if (inStep.empty())
			return false;

		const float prefer = desiredPos.y;
		// Keyboard/mouse steer usually keeps desired.y == current feet (horizontal intent).
		// Prefer the highest reachable surface so we step *onto* crates/stairs.
		// Pathfinding sets an explicit target Y (differs from feet) — match that instead.
		const bool horizontalIntent = fabsf(prefer - srcH) < 0.25f;

		if (horizontalIntent)
		{
			destH = inStep[0];
			for (float h : inStep)
			{
				if (h > destH)
					destH = h;
			}
		}
		else
		{
			float best = inStep[0];
			float bestD = fabsf(best - prefer);
			for (float h : inStep)
			{
				const float d = fabsf(h - prefer);
				if (d < bestD)
				{
					bestD = d;
					best = h;
				}
			}
			destH = best;
		}
	}

	// Tile must be standable approaching from srcH (any in-step surface).
	if (!grid->IsPositionWalkable(destX, destZ, srcH, agent))
		return false;

	// Collision detection using chunk object map
	// Slightly smaller than half-tile so entering a crate tile (esp. multi-tile
	// footprints) is not rejected by glancing the solid side before the step-up.
	const float kPlayerRadius = 0.28f;
	const float kPlayerHeight = 1.6f;      // current playerHeight
	const float kSmallObstacleHeight = 0.25f;
	// For climbs, test the body at the *destination* surface only — spanning the
	// full vertical climb made crate AABBs always intersect mid-step.
	const float bodyY = destH;
	Vector3 playerMin = { desiredPos.x - kPlayerRadius, bodyY, desiredPos.z - kPlayerRadius };
	Vector3 playerMax = { desiredPos.x + kPlayerRadius, bodyY + kPlayerHeight, desiredPos.z + kPlayerRadius };

	int chunkX = destX / 16;
	int chunkZ = destZ / 16;
	const float climbEpsilon = 0.05f;

	// Protect chunk map with shared lock if available
	extern std::shared_mutex g_chunkMapMutex;
	std::shared_lock lock(g_chunkMapMutex);

	for (int dz = -1; dz <= 1; ++dz)
	{
		for (int dx = -1; dx <= 1; ++dx)
		{
			int cx = chunkX + dx;
			int cz = chunkZ + dz;
			if (cx < 0 || cx >= 192 || cz < 0 || cz >= 192) continue;

			for (U7Object* obj : g_chunkObjectMap[cx][cz])
			{
				if (!obj) continue;

				// Allow walking through eggs/triggers: they should be interactive but non-blocking.
				if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_EGG) continue;

				if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC
					|| obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_MONSTER)
				{
					if (!PathfindingSystem::AreUnitsHostile(agent, obj))
						continue;
					// Hostile unit — fall through to collision checks below
				}

				if (!obj->m_shapeData) continue;
				if (obj->m_isContained) continue; // skip items in containers

				// XZ from draw bbox; vertical from TFA. Iso art bboxes often tower
				// through upper floors/roofs and would block roof-walk over walls.
				Vector3 minObj = obj->m_boundingBox.min;
				Vector3 maxObj = obj->m_boundingBox.max;

				const float eps = 0.02f;
				minObj.x -= eps; minObj.z -= eps;
				maxObj.x += eps; maxObj.z += eps;

				float logicalBottom = minObj.y;
				float logicalTop = maxObj.y;
				if (obj->m_objectData)
				{
					logicalBottom = obj->m_Pos.y;
					logicalTop = GetObjectSurfaceY(obj);
				}
				minObj.y = logicalBottom - eps;
				maxObj.y = logicalTop + eps;

				// Already above this solid (roof over walls, upper floor, etc.)
				if (bodyY >= logicalTop - climbEpsilon)
					continue;

				// Quick reject if AABBs don't overlap
				if (!CheckCollisionBoxes({playerMin, playerMax}, {minObj, maxObj}))
					continue;

				// Now we have overlap — decide whether it should block movement
				float objBottom = minObj.y;
				float objTop = maxObj.y;
				int shapeID = obj->m_shapeData->GetShape();
				float walkableTop = logicalTop;

				// 1) ignore very small ground clutter early
				float objHeight = objTop - objBottom;
				if (objHeight > 0.0f && objHeight < kSmallObstacleHeight)
				{
					if (!(obj->m_objectData && obj->m_objectData->m_isDoor))
					{
						continue;
					}

					float footprintX = maxObj.x - minObj.x;
					float footprintZ = maxObj.z - minObj.z;
					if (objHeight < kSmallObstacleHeight && footprintX < 1.0f && footprintZ < 1.0f) continue;
				}

				// 2) door hinge special-case
				if (obj->m_objectData && obj->m_objectData->m_isDoor)
				{
					if (destX == (int)floor(obj->m_Pos.x) && destZ == (int)floor(obj->m_Pos.z))
					{
						return false;
					}
					continue;
				}

				// Curtains / soft props: always passable.
				if (IsPassThroughObject(shapeID))
					continue;

				// Floors, stairs, rugs, bridges: never block the body (only provide surfaces).
				// Crates are walkable surfaces but still have solid sides — handled below.
				if (IsNonBlockingWalkSurface(shapeID))
					continue;

				// 3) ignore ceilings / upper floors above the body at dest height
				if (objBottom >= (bodyY + kPlayerHeight))
				{
					continue;
				}

				// Standable tops (crates, fences, stacked stairs): free when feet
				// are on this object (top or intermediate 1-tile step) at src or dest.
				if (IsStandableObjectTop(obj) && obj->m_objectData)
				{
					walkableTop = GetObjectSurfaceY(obj);
					const float baseY = obj->m_Pos.y;
					const auto onObject = [&](float feetY) {
						return feetY >= baseY - climbEpsilon && feetY <= walkableTop + climbEpsilon;
					};
					if (onObject(destH) || onObject(srcH))
						continue;
					// Climbing through this volume toward destH above it
					if (walkableTop > srcH - climbEpsilon && walkableTop < destH + climbEpsilon &&
					    (destH - srcH) <= MAX_CLIMBABLE_HEIGHT + climbEpsilon)
						continue;
				}

				// 4) swept XZ collision at destination body height (not mid-climb lerp)
				Vector3 srcPos = agent->m_Pos;
				Vector3 moveDelta = Vector3Subtract(desiredPos, srcPos);
				float distXZ = sqrtf(moveDelta.x * moveDelta.x + moveDelta.z * moveDelta.z);
				if (distXZ > 0.0001f)
				{
					const float sampleStep = 0.25f;
					int steps = (int)ceil(distXZ / sampleStep);
					bool hit = false;
					for (int s = 1; s <= steps; ++s)
					{
						float t = (float)s / (float)steps;
						Vector3 samplePos = Vector3Add(srcPos, Vector3Scale(moveDelta, t));
						Vector3 sampleMin = { samplePos.x - kPlayerRadius, bodyY, samplePos.z - kPlayerRadius };
						Vector3 sampleMax = { samplePos.x + kPlayerRadius, bodyY + kPlayerHeight, samplePos.z + kPlayerRadius };
						if (CheckCollisionBoxes({sampleMin, sampleMax}, {minObj, maxObj}))
						{
							hit = true;
							break;
						}
					}
					if (hit) return false;
				}

				if (!(objTop < playerMin.y || objBottom > playerMax.y))
				{
					return false;
				}
			}
		}
	}

	outDestH = destH;
	return true;
}

float PathfindingGrid::GetTileHeight(int worldX, int worldZ) const
{
	auto heights = GetWalkableSurfaceHeights(worldX, worldZ);
	if (heights.empty())
		return 0.0f;
	// Lowest non-negative surface (ground floor preference for generic queries)
	return heights.front();
}

// Can the agent stand on surface H at this tile (body not intersecting solid blockers)?
static bool CanStandOnSurface(const PathfindingGrid* grid, int worldX, int worldZ, float standH,
	const U7Object* agent, const std::vector<PathfindingGrid::OverlappingObject>& overlapping)
{
	const float agentHeight = 1.6f;
	const float bodyMin = standH + 0.05f;
	const float bodyMax = standH + agentHeight;

	// Terrain: blocks ground-level standing if notwalkable and no raised surface.
	if (standH <= 0.05f)
	{
		if (worldZ >= 0 && worldZ < (int)g_World.size() &&
		    worldX >= 0 && worldX < (int)g_World[worldZ].size())
		{
			const unsigned short shapeframe = g_World[worldZ][worldX];
			const int shapeID = shapeframe & 0x3ff;
			if (shapeID < 1024 && g_objectDataTable[shapeID].m_isNotWalkable &&
			    !g_objectDataTable[shapeID].m_isDoor)
			{
				// Raised standable objects clear terrain (crate on blocked tile is fine at H>0).
				// At ground, terrain notwalkable means blocked unless a door footprint.
				bool doorClears = false;
				for (const auto& ov : overlapping)
				{
					if (ov.obj && ov.obj->m_objectData && ov.obj->m_objectData->m_isDoor)
					{
						const int hingeX = (int)floor(ov.obj->m_Pos.x);
						const int hingeZ = (int)floor(ov.obj->m_Pos.z);
						if (!(worldX == hingeX && worldZ == hingeZ))
							doorClears = true;
					}
				}
				if (!doorClears)
					return false;
			}
		}
	}

	for (const auto& ov : overlapping)
	{
		U7Object* obj = ov.obj;
		if (!obj || !obj->m_objectData)
			continue;

		if (obj->m_objectData->m_isDoor)
		{
			const int hingeX = (int)floor(obj->m_Pos.x);
			const int hingeZ = (int)floor(obj->m_Pos.z);
			if (worldX == hingeX && worldZ == hingeZ)
				return false; // hinge tile
			continue; // openable door footprint is walkable
		}

		const int shapeID = obj->m_shapeData ? obj->m_shapeData->GetShape() : -1;

		// Curtains etc. never obstruct standing/pathing.
		if (shapeID >= 0 && PathfindingSystem::IsPassThroughObject(shapeID))
			continue;

		// Floors/stairs/rugs never block the body — they only contribute surface heights.
		// Without this, a height-1+ stair volume makes the whole tile unwalkable at ground.
		if (shapeID >= 0 && PathfindingSystem::IsNonBlockingWalkSurface(shapeID))
			continue;

		const float surfaceY = PathfindingSystem::GetObjectSurfaceY(obj);
		const float baseY = obj->m_Pos.y;

		// Feet on or above this object's logical top (roof over walls, upper floors).
		if (standH >= surfaceY - 0.05f)
			continue;

		// Standing exactly on a standable top (crate, floor mesh, …).
		if (PathfindingSystem::IsStandableObjectTop(obj)
			&& fabsf(standH - surfaceY) <= 0.05f)
		{
			continue;
		}

		// Non-solid / no collision volume
		if (!obj->m_objectData->m_isNotWalkable && !PathfindingSystem::IsWalkableSurface(shapeID))
			continue;

		// Solid volume [baseY, surfaceY] intersects agent body → blocked
		if (surfaceY > bodyMin && baseY < bodyMax)
		{
			return false;
		}
	}

	if (IsTileBlockedByHostileUnit(worldX, worldZ, standH, agent))
		return false;

	return true;
}

bool PathfindingGrid::CheckTileWalkable(int worldX, int worldZ, float agentBaseY, const U7Object* agent) const
{
	if (g_World.empty() || g_World.size() == 0)
		return false;
	if (worldZ < 0 || worldZ >= (int)g_World.size())
		return false;
	if (g_World[worldZ].empty() || worldX < 0 || worldX >= (int)g_World[worldZ].size())
		return false;

	// Single chunk scan — heights derived from the same overlapping list.
	const auto overlapping = GetOverlappingObjects(worldX, worldZ);
	const auto heights = GetWalkableSurfaceHeightsFromObjects(overlapping);

	// Approachable from agentBaseY if any standable surface is within one step
	// and the body fits there. Multi-layer: a high floor no longer poisons ground.
	const float step = MAX_CLIMBABLE_HEIGHT + 0.05f;
	for (float h : heights)
	{
		if (fabsf(h - agentBaseY) > step)
			continue;
		if (CanStandOnSurface(this, worldX, worldZ, h, agent, overlapping))
			return true;
	}
	return false;
}

void PathfindingGrid::DrawDebugOverlayTileLevel(float lowerY, float upperY)
{
	// Draw tile-level walkability using batched meshes (2 draw calls total!)
	extern Camera g_camera;
	extern Camera3D g_camera;

	// Only draw tiles within 40 tiles of camera
	int centerX = (int)g_camera.target.x;
	int centerZ = (int)g_camera.target.z;
	int range = 40;

	// Check if camera has moved - if not, use cached tiles
	bool cameraMovedOrNeverCached = (centerX != m_lastCameraCenterX || centerZ != m_lastCameraCenterZ);

	if (cameraMovedOrNeverCached)
	{
		// Regenerate tile cache
		m_cachedGreenTiles.clear();
		m_cachedRedTiles.clear();
		m_cachedGreenTiles.reserve(6400);  // Pre-allocate for 80x80 area
		m_cachedRedTiles.reserve(6400);

		extern AStar* g_aStar;
		for (int worldZ = centerZ - range; worldZ < centerZ + range; worldZ++)
		{
			for (int worldX = centerX - range; worldX < centerX + range; worldX++)
			{
				// Bounds check
				if (worldX < 0 || worldX >= 3072 || worldZ < 0 || worldZ >= 3072)
					continue;

				// Always query all walkable surface heights for debug visualization.
				auto heights = GetWalkableSurfaceHeights(worldX, worldZ);

				// If no surfaces found, treat as ground only (and potentially blocked)
				if (heights.empty())
					heights.push_back(0.0f);

				// If the tile only has ground (0.0) and tile is not considered walkable,
				// mark as blocked (red). Otherwise draw every surface level returned.
				bool onlyGround = (heights.size() == 1 && fabs(heights[0]) < 0.0001f);
				bool tileIsWalkable = true;
				if (onlyGround)
				{
					// Use the existing conservative tile check for determining blocked ground tiles.
					tileIsWalkable = CheckTileWalkable(worldX, worldZ, 0.0f);
				}

				if (!tileIsWalkable)
				{
					// Blocked tiles always at ground level
					m_cachedRedTiles.push_back({ (float)worldX, 0.1f, (float)worldZ });
					continue;
				}

				// For walkable tiles: draw every surface height returned by GetWalkableSurfaceHeights,
				// including high/upper floors so debug shows all walkable levels.
				for (float h : heights)
				{
					float displayHeight = h + 0.05f;

					TileWithCost t;
					t.pos = { (float)worldX, displayHeight, (float)worldZ };

					// If this layer represents a climbable surface, set climb cost.
					if (h > 0.1f)
						t.cost = CLIMB_MOVEMENT_COST;
					else
						t.cost = g_pathfindingSystem->m_aStar ? g_pathfindingSystem->m_aStar->GetMovementCost(worldX, worldZ, this) : 1.0f;

					// Debug markers: visited / on final path at this exact surface height.
					bool visited = false;
					bool onPath = false;
					if (g_pathfindingSystem && g_pathfindingSystem->m_aStar)
					{
						visited = g_pathfindingSystem->m_aStar->IsNodeVisited(worldX, worldZ, h);
						onPath = g_pathfindingSystem->m_aStar->IsNodeOnFinalPath(worldX, worldZ, h);
					}
					t.visited = visited;
					t.onPath = onPath;

					m_cachedGreenTiles.push_back(t);
				}
			}
		}

		// Update cached camera position
		m_lastCameraCenterX = centerX;
		m_lastCameraCenterZ = centerZ;
	}

	// Draw all green tiles with color-coded costs (using cached data)
	rlBegin(RL_TRIANGLES);
	
	float floorThreshold = 0.5f; // Allow for float imprecision

	for (const auto& tile : m_cachedGreenTiles)
	{
		if (tile.pos.y < lowerY || tile.pos.y >= upperY)
			continue;
		Color costColor;
		if (tile.onPath)
		{
			costColor = Color{ 255, 255, 0, 200 }; // Yellow = final path
		}
		else if (tile.visited)
		{
			costColor = Color{ 0, 150, 255, 160 }; // Blue-ish = visited by A*
		}
		else
		{
			// previous cost-based coloring
			if (tile.cost < 0.75f)
				costColor = Color{ 0, 255, 255, 128 };  // Cyan
			else if (tile.cost < 1.25f)
				costColor = Color{ 0, 255, 0, 128 };    // Green
			else if (tile.cost < 1.75f)
				costColor = Color{ 255, 255, 0, 128 };  // Yellow
			else if (tile.cost < 2.5f)
				costColor = Color{ 255, 165, 0, 128 };  // Orange
			else
				costColor = Color{ 255, 100, 100, 128 }; // Light red
		}

		rlColor4ub(costColor.r, costColor.g, costColor.b, costColor.a);


		// Two triangles forming a 1x1 quad
		Vector3 v1 = { tile.pos.x, tile.pos.y, tile.pos.z };
		Vector3 v2 = { tile.pos.x + 1.0f, tile.pos.y, tile.pos.z };
		Vector3 v3 = { tile.pos.x + 1.0f, tile.pos.y, tile.pos.z + 1.0f };
		Vector3 v4 = { tile.pos.x, tile.pos.y, tile.pos.z + 1.0f };

		// Triangle 1
		rlVertex3f(v1.x, v1.y, v1.z);
		rlVertex3f(v2.x, v2.y, v2.z);
		rlVertex3f(v3.x, v3.y, v3.z);

		// Triangle 2
		rlVertex3f(v1.x, v1.y, v1.z);
		rlVertex3f(v3.x, v3.y, v3.z);
		rlVertex3f(v4.x, v4.y, v4.z);
	}
	rlEnd();
	
	// Draw all red tiles in one call (using cached data)
	rlBegin(RL_TRIANGLES);
	rlColor4ub(255, 0, 0, 128);  // Red, semi-transparent
	for (const auto& pos : m_cachedRedTiles)
	{
		if (pos.y < lowerY || pos.y >= upperY)
			continue;
		// Two triangles forming a 1x1 quad
		Vector3 v1 = { pos.x, pos.y,pos.z };
		Vector3 v2 = { pos.x + 1.0f, pos.y, pos.z };
		Vector3 v3 = { pos.x + 1.0f, pos.y, pos.z + 1.0f };
		Vector3 v4 = { pos.x, pos.y, pos.z + 1.0f };

		// Triangle 1
		rlVertex3f(v1.x, v1.y, v1.z);
		rlVertex3f(v2.x, v2.y, v2.z);
		rlVertex3f(v3.x, v3.y, v3.z);

		// Triangle 2
		rlVertex3f(v1.x, v1.y, v1.z);
		rlVertex3f(v3.x, v3.y, v3.z);
		rlVertex3f(v4.x, v4.y, v4.z);
	}
	rlEnd();

}

void PathfindingGrid::DebugPrintTileInfo(int worldX, int worldZ)
{
	// AddConsoleString("=== Debug Tile (" + std::to_string(worldX) + ", " + std::to_string(worldZ) + ") ===");

	// Check terrain
	unsigned short shapeframe = g_World[worldZ][worldX];
	int shapeID = shapeframe & 0x3ff;
	int frameID = (shapeframe >> 10) & 0x3f;

	// AddConsoleString("Terrain: shape=" + std::to_string(shapeID) +
	//                  " frame=" + std::to_string(frameID) +
	//                  " name=" + g_objectDataTable[shapeID].m_name);

	if (shapeID < 1024 && g_objectDataTable[shapeID].m_isNotWalkable)
	{
		if (g_objectDataTable[shapeID].m_isDoor)
		{
			AddConsoleString("  -> Terrain is DOOR, frame=" + std::to_string(frameID) +
				(frameID > 0 ? " (OPEN)" : " (CLOSED)"));
			NPCDebugPrint("Tile (" + std::to_string(worldX) + "," + std::to_string(worldZ) + "): Terrain is DOOR, frame=" + std::to_string(frameID) +
				(frameID > 0 ? " (OPEN)" : " (CLOSED)"));
		}
		else
		{
			AddConsoleString("  -> Terrain is NOT WALKABLE");
			NPCDebugPrint("Tile (" + std::to_string(worldX) + "," + std::to_string(worldZ) + "): Terrain is NOT WALKABLE");
		}
	}
	else
	{
		AddConsoleString("  -> Terrain is walkable");
		NPCDebugPrint("Tile (" + std::to_string(worldX) + "," + std::to_string(worldZ) + "): Terrain is walkable");
	}

	// Check overlapping objects using shared helper
	auto overlappingObjects = GetOverlappingObjects(worldX, worldZ);
	bool foundBlockingObject = false;

	for (const auto& ovObj : overlappingObjects)
	{
		U7Object* obj = ovObj.obj;

		std::string skipReason = "";
		if (obj->m_Pos.y > 2.0f && !obj->m_objectData->m_isDoor)
			skipReason = " [SKIPPED: above ground y=" + std::to_string(obj->m_Pos.y) + "]";

		std::string msg = std::string("Object ") + (skipReason.empty() ? "BLOCKS" : "found") + ": " + obj->m_objectData->m_name +
			" at (" + std::to_string(ovObj.tileX) + "," + std::to_string(ovObj.tileZ) + ")" +
			" size=" + std::to_string(ovObj.width) + "x" + std::to_string(ovObj.depth) +
			(obj->m_objectData->m_isDoor ? std::string(" [DOOR frame=") + std::to_string(obj->m_Frame) + "]" : "") +
			skipReason;
		//AddConsoleString(msg);
		NPCDebugPrint("Tile (" + std::to_string(worldX) + "," + std::to_string(worldZ) + "): " + msg);
		if (skipReason.empty())
			foundBlockingObject = true;
	}

	if (!foundBlockingObject)
	{
		//AddConsoleString("No blocking objects found");
		NPCDebugPrint("Tile (" + std::to_string(worldX) + "," + std::to_string(worldZ) + "): No blocking objects found");
	}

	// Final verdict
	bool walkable = CheckTileWalkable(worldX, worldZ, 0.0f);
	//AddConsoleString("RESULT: " + std::string(walkable ? "WALKABLE" : "BLOCKED"));
	NPCDebugPrint("Tile (" + std::to_string(worldX) + "," + std::to_string(worldZ) + "): RESULT: " + std::string(walkable ? "WALKABLE" : "BLOCKED"));
}

// Build sorted unique surface heights from a pre-fetched object list (no chunk scan).
std::vector<float> PathfindingGrid::GetWalkableSurfaceHeightsFromObjects(
	const std::vector<OverlappingObject>& objects) const
{
	std::vector<float> heights;
	heights.reserve(objects.size() * 2 + 1);

	// Ground always present
	heights.push_back(0.0f);

	// Floors/stairs (allowlist) AND short solid tops (crates, boxes, chests).
	// Tall solids are NOT standable (see IsStandableObjectTop) — no synthetic
	// intermediate rungs up posts/pillars. Stacked height-1 props each contribute
	// their own top instead.
	for (const auto& ov : objects)
	{
		U7Object* obj = ov.obj;
		if (!PathfindingSystem::IsStandableObjectTop(obj))
			continue;

		heights.push_back(PathfindingSystem::GetObjectSurfaceY(obj));
	}

	// sort and deduplicate (small epsilon)
	std::sort(heights.begin(), heights.end());
	const float EPS = 0.001f;
	std::vector<float> uniqueHeights;
	uniqueHeights.reserve(heights.size());
	for (float h : heights)
	{
		if (uniqueHeights.empty() || fabs(uniqueHeights.back() - h) > EPS)
			uniqueHeights.push_back(h);
	}
	return uniqueHeights;
}

// Returns a sorted list of unique surface heights for world tile (x,z).
std::vector<float> PathfindingGrid::GetWalkableSurfaceHeights(int worldX, int worldZ) const
{
	if (worldX < 0 || worldX >= 3072 || worldZ < 0 || worldZ >= 3072)
		return {};

	return GetWalkableSurfaceHeightsFromObjects(GetOverlappingObjects(worldX, worldZ));
}

// ============================================================================
// AStar Implementation
// ============================================================================

AStar::AStar()
{
	LoadTerrainCosts("Data/terrain_walkable.csv");
}

AStar::~AStar()
{
	CleanupNodes();
}

void AStar::LoadTerrainCosts(const std::string& filename)
{
	m_terrainCosts.clear();

	std::ifstream file(filename);
	if (!file.is_open())
	{
		AddConsoleString("WARNING: Could not open terrain costs file: " + filename, YELLOW);
		return;
	}

	std::string line;
	std::getline(file, line);  // Skip header line

	int loadedCount = 0;
	int lineNum = 1;
	while (std::getline(file, line))
	{
		lineNum++;

		// Skip empty lines
		if (line.empty())
			continue;

		// Parse CSV: shape_id,name,suggested_cost
		size_t firstComma = line.find(',');
		if (firstComma == std::string::npos)
			continue;

		size_t secondComma = line.find(',', firstComma + 1);
		if (secondComma == std::string::npos)
			continue;

		try
		{
			// Extract shape ID
			std::string shapeIDStr = line.substr(0, firstComma);
			if (shapeIDStr.empty())
				continue;
			int shapeID = std::stoi(shapeIDStr);

			// Extract name (between first and second comma, remove quotes)
			std::string name = line.substr(firstComma + 1, secondComma - firstComma - 1);
			// Remove quotes if present
			if (name.length() >= 2 && name.front() == '"' && name.back() == '"')
			{
				name = name.substr(1, name.length() - 2);
			}

			// Extract cost (after second comma, trim whitespace)
			std::string costStr = line.substr(secondComma + 1);
			costStr.erase(0, costStr.find_first_not_of(" \t\r\n"));
			costStr.erase(costStr.find_last_not_of(" \t\r\n") + 1);

			// Skip if no cost specified
			if (costStr.empty())
				continue;

			float cost = std::stof(costStr);

			// Reject zero or negative costs (breaks A* heuristic)
			if (cost <= 0.0f)
			{
				AddConsoleString("ERROR: Terrain shape " + std::to_string(shapeID) + " has invalid cost " +
					std::to_string(cost) + " (must be > 0). Skipping.", RED);
				continue;
			}

			m_terrainCosts[shapeID] = cost;
			m_terrainNames[shapeID] = name;
			loadedCount++;
		}
		catch (const std::exception&)
		{
			AddConsoleString("WARNING: Failed to parse terrain cost on line " + std::to_string(lineNum) + ": " + line, YELLOW);
			continue;
		}
	}

	file.close();
	AddConsoleString("Loaded " + std::to_string(loadedCount) + " terrain movement costs from " + filename, GREEN);
}

std::string AStar::GetTerrainName(int shapeID) const
{
	auto it = m_terrainNames.find(shapeID);
	if (it != m_terrainNames.end())
	{
		return it->second;
	}
	return "Unknown";
}

float AStar::GetMovementCost(int worldX, int worldZ, PathfindingGrid* grid)
{
	// Start with base terrain cost
	float baseCost = 1.0f;

	// Look up terrain shape cost
	if (worldX >= 0 && worldX < 3072 && worldZ >= 0 && worldZ < 3072)
	{
		unsigned short shapeframe = g_World[worldZ][worldX];
		int shapeID = shapeframe & 0x3ff;  // Bits 0-9

		// Check if we have a custom cost for this terrain
		auto it = m_terrainCosts.find(shapeID);
		if (it != m_terrainCosts.end())
		{
			baseCost = it->second;
		}
	}

	// Check if this tile has a door - doors add extra cost on top of terrain cost
	int chunkX = worldX / 16;
	int chunkZ = worldZ / 16;

	// Check this chunk and neighbors
	for (int dz = -1; dz <= 1; dz++)
	{
		for (int dx = -1; dx <= 1; dx++)
		{
			int cx = chunkX + dx;
			int cz = chunkZ + dz;

			if (cx < 0 || cx >= 192 || cz < 0 || cz >= 192)
				continue;

			for (U7Object* obj : g_chunkObjectMap[cx][cz])
			{
				if (!obj || !obj->m_objectData || !obj->m_objectData->m_isDoor)
					continue;

				// Get object dimensions
				int objWidth = (int)obj->m_objectData->m_width;
				int objDepth = (int)obj->m_objectData->m_depth;
				if (objWidth <= 0) objWidth = 1;
				if (objDepth <= 0) objDepth = 1;

				int objTileX = (int)floor(obj->m_Pos.x);
				int objTileZ = (int)floor(obj->m_Pos.z);

				// Skip hinge tile (it's non-walkable, handled by CheckTileWalkable)
				if (worldX == objTileX && worldZ == objTileZ)
					continue;

				// Check if this tile overlaps door's footprint (excluding hinge)
				bool overlaps = (worldX >= objTileX - objWidth + 1 && worldX <= objTileX &&
					worldZ >= objTileZ - objDepth + 1 && worldZ <= objTileZ);

				if (overlaps)
				{
					// Door tiles add small extra cost (slight penalty but not prohibitive)
					return baseCost + 0.5f;
				}
			}
		}
	}

	return baseCost;
}

// Quantize y into an integer index (same scheme used by A*)
// Packs yIndex (signed int) in the high bits, z in the middle, x in the low bits.
// yIndex is expected to be a small integer (we quantize world Y into an index).
static inline int QuantizeY(float y)
{
	return (int)roundf(y * 50.0f); // 0.02 precision
}

// Create 64-bit key from x,z,yIndex
static inline int64_t MakeNodeKey(int x, int z, int yIndex)
{
	const int64_t xi = (int64_t)(x & 0xFFFFF);   // 20 bits
	const int64_t zi = (int64_t)(z & 0xFFFFF);
	const int64_t yi = (int64_t)(yIndex & 0xFFFFF);
	return (yi << 40) | (zi << 20) | xi;
}

// Helper: choose best surface for a tile given preferredY (returns preferred if exact)
// Uses PathfindingGrid::GetWalkableSurfaceHeights to gather candidates.
static float PickClosestSurface(PathfindingGrid* grid, int tx, int tz, float preferredY)
{
	if (!grid)
		return preferredY; // fallback

	auto heights = grid->GetWalkableSurfaceHeights(tx, tz);
	if (heights.empty())
		return 0.0f;

	float best = heights[0];
	float bestDiff = fabsf(best - preferredY);
	for (float h : heights)
	{
		float d = fabsf(h - preferredY);
		if (d < bestDiff)
		{
			bestDiff = d;
			best = h;
		}
	}
	return best;
}
std::vector<Vector3> AStar::FindPath(Vector3 start, Vector3 goal, PathfindingGrid* grid, const U7Object* agent)
{
	if (!grid)
		return {};

	std::unordered_map<int64_t, bool> walkableCache;
	std::unordered_map<int, std::vector<float>> heightsCache;
	std::unordered_map<int, float> moveCostCache; // (x<<16)|z -> terrain+door cost
	walkableCache.reserve(4096);
	heightsCache.reserve(2048);
	moveCostCache.reserve(2048);

	// Budget scales with distance; hard cap keeps long searches bounded.
	const int maxNodesToExplore = 4000;
	std::vector<PathNode> nodePool;
	// Neighbors no longer spam-allocate duplicates for closed/open keys, so a
	// tighter reserve is enough and keeps L1/L2 friendlier.
	nodePool.reserve(std::min(maxNodesToExplore + 64, 2048));

	std::unordered_set<int64_t> localVisitedNodeKeys;
	std::unordered_set<int64_t> localFinalPathKeys;

	int startX = (int)floorf(start.x);
	int startZ = (int)floorf(start.z);
	int goalX = (int)floorf(goal.x);
	int goalZ = (int)floorf(goal.z);

	// Bounds check
	if (startX < 0 || startX >= 3072 || startZ < 0 || startZ >= 3072 ||
		goalX < 0 || goalX >= 3072 || goalZ < 0 || goalZ >= 3072)
	{
		return {};
	}

	// Same tile: trivial path at preferred surface.
	if (startX == goalX && startZ == goalZ)
	{
		float y = PickClosestSurface(grid, startX, startZ, goal.y);
		return { Vector3{ startX + 0.5f, y, startZ + 0.5f } };
	}

	int distance = abs(goalX - startX) + abs(goalZ - startZ);
	// Hierarchical earlier for medium hauls (was 240 — left too much on tile A*).
	const int HIERARCHICAL_THRESHOLD = 48;
	if (distance > HIERARCHICAL_THRESHOLD)
	{
		// Chunk coords (192x192 chunks, chunk = 16 tiles)
		auto toChunk = [](int tile) { return tile / 16; };
		int startCx = toChunk(startX), startCz = toChunk(startZ);
		int goalCx = toChunk(goalX), goalCz = toChunk(goalZ);

		// Simple chunk-A* (uses g_pathfindingSystem->m_chunkInfoMap connectivity)
		const int CHUNKS = 192;
		const int dirOffsets[8][2] = {
			{0,-1}, {1,-1}, {1,0}, {1,1},
			{0,1}, {-1,1}, {-1,0}, {-1,-1}
		};

		auto encode = [](int cx, int cz) { return (cx << 16) | (cz & 0xFFFF); };
		auto decode = [](int key) { return std::pair<int, int>((key >> 16) & 0xFFFF, key & 0xFFFF); };

		// Chunk-A* structures
		std::priority_queue<std::pair<int, int>, std::vector<std::pair<int, int>>, std::greater<std::pair<int, int>>> open;
		std::unordered_map<int, int> chunkG;
		std::unordered_map<int, int> chunkParent;

		int startKey = encode(startCx, startCz);
		int goalKey = encode(goalCx, goalCz);

		open.push({ 0, startKey });
		chunkG[startKey] = 0;
		chunkParent[startKey] = -1;

		auto chunkHeuristic = [&](int cx, int cz) {
			return std::max(std::abs(cx - goalCx), std::abs(cz - goalCz));
			};

		bool chunkFound = false;
		while (!open.empty())
		{
			auto top = open.top(); open.pop();
			int curKey = top.second;
			auto [ccx, ccz] = decode(curKey);
			if (curKey == goalKey) { chunkFound = true; break; }

			// neighbors by 8-dir, consult chunk connectivity
			for (int d = 0; d < 8; ++d)
			{
				int ncx = ccx + dirOffsets[d][0];
				int ncz = ccz + dirOffsets[d][1];
				if (ncx < 0 || ncx >= CHUNKS || ncz < 0 || ncz >= CHUNKS) continue;

				// require connectivity both directions for safety (optional)
				if (!g_pathfindingSystem->m_chunkInfoMap[ccx][ccz].canReach[d]) continue;

				int nKey = encode(ncx, ncz);
				int tentativeG = chunkG[curKey] + 1;
				auto itG = chunkG.find(nKey);
				if (itG == chunkG.end() || tentativeG < itG->second)
				{
					chunkG[nKey] = tentativeG;
					chunkParent[nKey] = curKey;
					int f = tentativeG + chunkHeuristic(ncx, ncz);
					open.push({ f, nKey });
				}
			}
		}

		std::vector<std::pair<int, int>> chunkPath;
		if (chunkFound)
		{
			// Reconstruct chunk path
			int cur = goalKey;
			while (cur != -1)
			{
				auto pr = decode(cur);
				chunkPath.push_back(pr);
				cur = chunkParent[cur];
			}
			std::reverse(chunkPath.begin(), chunkPath.end());
		}

		if (!chunkFound || chunkPath.empty())
		{
			// No chunk path found — fall back to current behavior (attempt local search as before)
			; // continue to normal A* below (we don't early-return)
		}
		else
		{
			// Convert chunk path to intermediate world targets (chunk centers).
			// Carry start height so multi-floor agents don't snap intermediates to ground.
			std::vector<Vector3> intermediates;
			for (const auto& pc : chunkPath)
			{
				int ccx = pc.first, ccz = pc.second;
				float wx = float(ccx * 16 + 8);
				float wz = float(ccz * 16 + 8);
				intermediates.push_back(Vector3{ wx, start.y, wz });
			}

			// Stitch paths: for each intermediate (skipping the first if it's the same chunk as start),
			// call FindPath recursively for the short segment (adjacent chunks -> short distances)
			Vector3 curStart = start;
			std::vector<Vector3> finalPath;
			bool failed = false;

			// If the first intermediate corresponds to the start chunk, skip it
			size_t startIndex = 0;
			if (!intermediates.empty())
			{
				int firstCx = (int)intermediates.front().x / 16;
				int firstCz = (int)intermediates.front().z / 16;
				if (firstCx == startCx && firstCz == startCz)
					startIndex = 1;
			}

			for (size_t i = startIndex; i < intermediates.size(); ++i)
			{
				Vector3 segGoal = intermediates[i];
				auto segPath = FindPath(curStart, segGoal, grid, agent); // recursion — segment distances are small
				if (segPath.empty())
				{
					failed = true;
					break;
				}
				// Append segPath (avoid duplicate of curStart)
				if (!finalPath.empty() && !segPath.empty() && finalPath.back().x == segPath.front().x && finalPath.back().z == segPath.front().z)
				{
					finalPath.insert(finalPath.end(), segPath.begin() + 1, segPath.end());
				}
				else
				{
					finalPath.insert(finalPath.end(), segPath.begin(), segPath.end());
				}
				curStart = finalPath.back();
			}

			if (!failed)
			{
				// Final segment to real goal (may be inside last chunk) — short distance
				auto lastSeg = FindPath(curStart, goal, grid, agent);
				if (lastSeg.empty()) failed = true;
				else
				{
					// Append lastSeg (avoid duplicate)
					if (!finalPath.empty() && finalPath.back().x == lastSeg.front().x && finalPath.back().z == lastSeg.front().z)
						finalPath.insert(finalPath.end(), lastSeg.begin() + 1, lastSeg.end());
					else
						finalPath.insert(finalPath.end(), lastSeg.begin(), lastSeg.end());
				}
			}

			if (!failed)
				return finalPath;

			// else fall through to the regular tile-level A* fallback below
		}
	}

	// Create start node in nodePool
	float startPrefY = start.y;
	float startY = PickClosestSurface(grid, startX, startZ, startPrefY);

	nodePool.emplace_back(startX, startZ, startY);
	int startIndex = (int)nodePool.size() - 1;
	nodePool[startIndex].g = 0;
	nodePool[startIndex].h = Heuristic(startX, startZ, goalX, goalZ);
	nodePool[startIndex].f = nodePool[startIndex].g + nodePool[startIndex].h;
	nodePool[startIndex].parent = -1;

	// min-heap by f: store (f, index)
	std::priority_queue<std::pair<float, int>, std::vector<std::pair<float, int>>, std::greater<std::pair<float, int>>> openSet;
	std::unordered_map<int64_t, int> openSetLookup;  // key -> node index
	std::unordered_map<int64_t, int> closedSet;     // key -> node index

	int startYIdx = QuantizeY(startY);
	int64_t startKey64 = MakeNodeKey(startX, startZ, startYIdx);
	openSet.push({ nodePool[startIndex].f, startIndex });
	openSetLookup[startKey64] = startIndex;

	int goalIndex = -1;
	float bestGoalHeightDiff = 1e9f;
	int nodesExplored = 0;

	// A* main loop
	while (!openSet.empty() && nodesExplored < maxNodesToExplore)
	{
		nodesExplored++;

		// Soft cap: enough for multi-layer local mazes, but scales with range.
		const int dynamicLimit = std::min(maxNodesToExplore, std::max(600, distance * 35 + 250));
		if (nodesExplored > dynamicLimit)
			break;
		auto top = openSet.top();
		openSet.pop();
		int currentIndex = top.second;
		// Defensive: bounds check index
		if (currentIndex < 0 || currentIndex >= (int)nodePool.size())
			continue;

		PathNode current = nodePool[currentIndex];
		int curYIdx = QuantizeY(current.y);
		int64_t currentKey64 = MakeNodeKey(current.x, current.z, curYIdx);

		// Outdated entry check
		auto lookupIt = openSetLookup.find(currentKey64);
		if (lookupIt != openSetLookup.end() && lookupIt->second != currentIndex)
			continue;

		openSetLookup.erase(currentKey64);

		localVisitedNodeKeys.insert(currentKey64);

		float goalPreferredY = PickClosestSurface(grid, goalX, goalZ, goal.y);

		// Goal: same tile, height within one step of preferred (not only exact match).
		// Exact-only rejected near-miss roof landings after crate stairs.
		if (current.x == goalX && current.z == goalZ)
		{
			const float GOAL_STEP = MAX_CLIMBABLE_HEIGHT + 0.05f;
			const float heightDiff = fabsf(current.y - goalPreferredY);
			if (goalPreferredY <= 0.1f || heightDiff <= GOAL_STEP)
			{
				if (heightDiff < bestGoalHeightDiff)
				{
					bestGoalHeightDiff = heightDiff;
					goalIndex = currentIndex;
				}
				// Good enough — stop (exact/near-exact roof or ground goal).
				if (heightDiff <= 0.05f || goalPreferredY <= 0.1f)
					break;
			}
		}

		closedSet[currentKey64] = currentIndex;

		// Get neighbor indices (skips closed keys; reuses open indices)
		std::vector<int> neighborIndices = GetNeighbors(
			currentIndex, grid, goalX, goalZ, walkableCache, heightsCache, nodePool,
			&closedSet, &openSetLookup, agent);

		for (int neighborIndex : neighborIndices)
		{
			// Defensive index check
			if (neighborIndex < 0 || neighborIndex >= (int)nodePool.size())
				continue;

			PathNode& neighbor = nodePool[neighborIndex];

			int neighYIdx = QuantizeY(neighbor.y);
			int64_t neighborKey64 = MakeNodeKey(neighbor.x, neighbor.z, neighYIdx);

			// Closed set already filtered in GetNeighbors, but re-check for safety.
			if (closedSet.find(neighborKey64) != closedSet.end())
				continue;

			float moveCost;
			if (neighbor.y > 0.1f)
			{
				moveCost = CLIMB_MOVEMENT_COST;
			}
			else
			{
				const int costKey = (neighbor.x << 16) | (neighbor.z & 0xFFFF);
				auto cit = moveCostCache.find(costKey);
				if (cit != moveCostCache.end())
					moveCost = cit->second;
				else
				{
					moveCost = GetMovementCost(neighbor.x, neighbor.z, grid);
					moveCostCache.emplace(costKey, moveCost);
				}
			}

			int ddx = neighbor.x - current.x;
			int ddz = neighbor.z - current.z;
			const float DIAGONAL_COST = 1.41421356237f;
			float dirMultiplier = ((ddx != 0) && (ddz != 0)) ? DIAGONAL_COST : 1.0f;

			float tentativeG = current.g + moveCost * dirMultiplier;

			auto openIt = openSetLookup.find(neighborKey64);
			if (openIt == openSetLookup.end())
			{
				neighbor.g = tentativeG;
				neighbor.h = Heuristic(neighbor.x, neighbor.z, goalX, goalZ);
				neighbor.f = neighbor.g + neighbor.h;
				neighbor.parent = currentIndex;
				openSet.push({ neighbor.f, neighborIndex });
				openSetLookup[neighborKey64] = neighborIndex;
			}
			else
			{
				int existingIndex = openIt->second;
				if (existingIndex >= 0 && existingIndex < (int)nodePool.size())
				{
					PathNode& existingNode = nodePool[existingIndex];
					if (tentativeG < existingNode.g)
					{
						// Prefer updating the open entry in place; if a brand-new
						// neighbor index was still allocated, migrate to existing.
						existingNode.g = tentativeG;
						existingNode.h = Heuristic(existingNode.x, existingNode.z, goalX, goalZ);
						existingNode.f = existingNode.g + existingNode.h;
						existingNode.parent = currentIndex;
						openSet.push({ existingNode.f, existingIndex });
						openSetLookup[neighborKey64] = existingIndex;
					}
				}
				else
				{
					neighbor.g = tentativeG;
					neighbor.h = Heuristic(neighbor.x, neighbor.z, goalX, goalZ);
					neighbor.f = neighbor.g + neighbor.h;
					neighbor.parent = currentIndex;
					openSet.push({ neighbor.f, neighborIndex });
					openSetLookup[neighborKey64] = neighborIndex;
				}
			}
		}
	}

	// If we didn't find the exact goal, try fallback to closest point
	if (goalIndex == -1)
	{
		// Find the closest explored node to the goal
		PathNode* furthestNode = nullptr;
		int furthestIndex = -1;
		float minDist = 9999999.0f;
		for (const auto& pair : closedSet)
		{
			int idx = pair.second;
			if (idx < 0 || idx >= (int)nodePool.size()) continue;
			PathNode& node = nodePool[idx];
			float dist = sqrtf((float)((node.x - goalX) * (node.x - goalX) + (node.z - goalZ) * (node.z - goalZ)));
			if (dist < minDist)
			{
				minDist = dist;
				furthestIndex = idx;
				furthestNode = &nodePool[idx];
			}
		}
		if (furthestIndex != -1 && minDist < 150.0f)
		{
			goalIndex = furthestIndex;
		}
		else
		{
			if (nodesExplored >= maxNodesToExplore)
			{
				//AddConsoleString("  FAILED: Search limit reached (" + std::to_string(maxNodesToExplore) + " nodes)", RED);
			}

			//NPCDebugPrint("NPC Start location " + std::to_string(start.x) + "," + std::to_string(start.z) + " failed to find path to (" + std::to_string(goalX) + "," + std::to_string(goalZ) + ")");
			//AddConsoleString("NPC Start location " + std::to_string(start.x) + "," + std::to_string(start.z) + " failed to find path to (" + std::to_string(goalX) + "," + std::to_string(goalZ) + ")", RED);
		}
	}

	std::vector<Vector3> path;
	if (goalIndex != -1)
	{
		int walkIdx = goalIndex;
		while (walkIdx != -1)
		{
			PathNode& walk = nodePool[walkIdx];
			int yidx = QuantizeY(walk.y);
			int64_t k = MakeNodeKey(walk.x, walk.z, yidx);
			localFinalPathKeys.insert(k);
			walkIdx = walk.parent;
		}

		path = ReconstructPath(goalIndex, grid, nodePool);
		path = SmoothPath(path, grid, agent);
	}

	{
		std::lock_guard<std::mutex> lk(m_findMutex);
		m_visitedNodeKeys = std::move(localVisitedNodeKeys);
		m_finalPathKeys = std::move(localFinalPathKeys);
	}

	return path;
}

float AStar::Heuristic(int x1, int z1, int x2, int z2)
{
	const float DIAGONAL_COST = 1.41421356237f;
	int dx = abs(x2 - x1);
	int dz = abs(z2 - z1);

	int mn = std::min(dx, dz);
	int mx = std::max(dx, dz);

	// (mx - mn) orthogonal steps + DIAGONAL_COST * mn diagonal steps
	return (float)((mx - mn) + DIAGONAL_COST * mn);
}

std::vector<int> AStar::GetNeighbors(int nodeIndex, PathfindingGrid* grid, int goalX, int goalZ,
	std::unordered_map<int64_t, bool>& walkableCache,
	std::unordered_map<int, std::vector<float>>& heightsCache,
	std::vector<PathNode>& nodePool,
	const std::unordered_map<int64_t, int>* closedSet,
	const std::unordered_map<int64_t, int>* openSetLookup,
	const U7Object* agent)
{
	std::vector<int> neighbors;
	neighbors.reserve(12);

	if (nodeIndex < 0 || nodeIndex >= (int)nodePool.size())
		return neighbors;

	const PathNode node = nodePool[nodeIndex];
	const float currentHeight = node.y;
	const float step = MAX_CLIMBABLE_HEIGHT + 0.05f;

	// 0-3 orthogonal, 4-7 diagonal (corner-cutting rule)
	const int directions[8][2] = {
		{0, -1}, {0, 1}, {1, 0}, {-1, 0},
		{1, -1}, {1, 1}, {-1, -1}, {-1, 1}
	};

	auto packWalkKey = [](int tx, int tz, int yq) -> int64_t {
		return (static_cast<int64_t>(tx & 0xFFF) << 32) |
		       (static_cast<int64_t>(tz & 0xFFF) << 20) |
		       (static_cast<int64_t>(yq) & 0xFFFFF);
	};

	auto getHeights = [&](int tx, int tz) -> const std::vector<float>& {
		const int tileKey = (tx << 16) | (tz & 0xFFFF);
		auto it = heightsCache.find(tileKey);
		if (it == heightsCache.end())
		{
			auto h = grid->GetWalkableSurfaceHeights(tx, tz);
			if (h.empty())
				h.push_back(0.0f);
			it = heightsCache.emplace(tileKey, std::move(h)).first;
		}
		return it->second;
	};

	auto canApproach = [&](int tx, int tz, float fromH) -> bool {
		const int64_t key = packWalkKey(tx, tz, QuantizeY(fromH));
		auto it = walkableCache.find(key);
		if (it != walkableCache.end())
			return it->second;
		const bool ok = grid->IsPositionWalkable(tx, tz, fromH, agent);
		walkableCache.emplace(key, ok);
		return ok;
	};

	// Emit at most a few surface heights per neighbor to curb multi-layer branching:
	// continue at same height, step up (max), step down (min) within climb range.
	// Reuse closed/open keys so nodePool does not balloon with dead duplicates.
	auto emitHeights = [&](int nx, int nz, const std::vector<float>& neighborHeights) {
		float bestSame = NAN, bestUp = NAN, bestDown = NAN;
		float bestSameD = 1e9f;
		for (float nh : neighborHeights)
		{
			const float d = nh - currentHeight;
			if (fabsf(d) > step)
				continue;
			const float ad = fabsf(d);
			if (ad < bestSameD)
			{
				bestSameD = ad;
				bestSame = nh;
			}
			if (d > 0.05f && (std::isnan(bestUp) || nh > bestUp))
				bestUp = nh;
			if (d < -0.05f && (std::isnan(bestDown) || nh < bestDown))
				bestDown = nh;
		}

		float picks[3];
		int nPick = 0;
		auto addUnique = [&](float h) {
			if (std::isnan(h)) return;
			for (int i = 0; i < nPick; ++i)
				if (fabsf(picks[i] - h) < 0.02f) return;
			picks[nPick++] = h;
		};
		addUnique(bestSame);
		addUnique(bestUp);
		addUnique(bestDown);

		for (int i = 0; i < nPick; ++i)
		{
			const int64_t key = MakeNodeKey(nx, nz, QuantizeY(picks[i]));
			if (closedSet && closedSet->find(key) != closedSet->end())
				continue;
			if (openSetLookup)
			{
				auto oit = openSetLookup->find(key);
				if (oit != openSetLookup->end())
				{
					neighbors.push_back(oit->second);
					continue;
				}
			}
			nodePool.emplace_back(nx, nz, picks[i]);
			const int newIdx = (int)nodePool.size() - 1;
			nodePool[newIdx].parent = -1;
			neighbors.push_back(newIdx);
		}
	};

	for (int i = 0; i < 8; i++)
	{
		const int nx = node.x + directions[i][0];
		const int nz = node.z + directions[i][1];
		if (nx < 0 || nx >= 3072 || nz < 0 || nz >= 3072)
			continue;

		const bool isDiagonal = (i >= 4);
		if (isDiagonal)
		{
			const int ox = node.x + directions[i][0];
			const int oz = node.z;
			const int ox2 = node.x;
			const int oz2 = node.z + directions[i][1];
			if (!canApproach(ox, oz, currentHeight) || !canApproach(ox2, oz2, currentHeight))
				continue;
		}

		const bool isGoal = (nx == goalX && nz == goalZ);
		if (!isGoal && !canApproach(nx, nz, currentHeight))
			continue;

		emitHeights(nx, nz, getHeights(nx, nz));
	}

	return neighbors;
}

std::vector<Vector3> AStar::ReconstructPath(int goalIndex, PathfindingGrid* grid, std::vector<PathNode>& nodePool)
{
	std::vector<Vector3> path;
	int currentIndex = goalIndex;

	while (currentIndex != -1)
	{
		if (currentIndex < 0 || currentIndex >= (int)nodePool.size()) break;
		PathNode& current = nodePool[currentIndex];

		// Tile centers so NPC m_Pos matches draw position (no +0.5 billboard offset).
		Vector3 waypoint;
		waypoint.x = (float)current.x + 0.5f;
		waypoint.y = current.y;
		waypoint.z = (float)current.z + 0.5f;

		path.push_back(waypoint);
		currentIndex = current.parent;
	}

	std::reverse(path.begin(), path.end());
	return path;
}

std::vector<Vector3> AStar::SmoothPath(const std::vector<Vector3>& path, PathfindingGrid* grid, const U7Object* agent)
{
	// Cheap tile-step smooth (no full ValidateMove). Skip huge paths.
	if (!grid || path.size() <= 2 || path.size() > 96)
		return path;

	auto lineClear = [&](const Vector3& a, const Vector3& b) -> bool {
		// Reject large vertical jumps for smoothed segments.
		if (fabsf(b.y - a.y) > MAX_CLIMBABLE_HEIGHT + 0.05f)
			return false;

		int x0 = (int)floorf(a.x);
		int z0 = (int)floorf(a.z);
		int x1 = (int)floorf(b.x);
		int z1 = (int)floorf(b.z);
		const int dx = abs(x1 - x0);
		const int dz = abs(z1 - z0);
		const int sx = x0 < x1 ? 1 : -1;
		const int sz = z0 < z1 ? 1 : -1;
		int err = dx - dz;
		int x = x0, z = z0;
		float y = a.y;
		const int steps = std::max(dx, dz);
		const float yStep = steps > 0 ? (b.y - a.y) / (float)steps : 0.0f;
		int step = 0;

		while (true)
		{
			if (!grid->IsPositionWalkable(x, z, y, agent))
				return false;
			if (x == x1 && z == z1)
				break;
			const int e2 = 2 * err;
			if (e2 > -dz) { err -= dz; x += sx; }
			if (e2 < dx) { err += dx; z += sz; }
			step++;
			y = a.y + yStep * (float)step;
			if (step > 512)
				return false;
		}
		return true;
	};

	std::vector<Vector3> out;
	out.reserve(path.size());
	out.push_back(path.front());

	size_t i = 0;
	while (i < path.size() - 1)
	{
		size_t farthest = i + 1;
		// Greedy: farthest waypoint reachable in a straight tile line.
		for (size_t j = path.size() - 1; j > i + 1; --j)
		{
			if (lineClear(path[i], path[j]))
			{
				farthest = j;
				break;
			}
		}
		out.push_back(path[farthest]);
		i = farthest;
	}
	return out;
}

void AStar::CleanupNodes()
{
	for (PathNode* node : m_allocatedNodes)
	{
		delete node;
	}
	m_allocatedNodes.clear();
}

//----------------------------------------------
// High-level chunk-based initial pathfinding
//---------------------------------------------

//  By building a high-level map of which chunk has a clear path to which
//  neighboring chunk, we can assign pathfinding nodes much more quickly.
//
//  We'll still need A* to reach the final destination within a chunk.

bool LineIntersectsAABB3D(Vector3 p1, Vector3 p2, Vector3 boxMin, Vector3 boxMax)
{
	Vector3 dir = Vector3Subtract(p2, p1);

	float tmin = 0.0f;
	float tmax = 1.0f;

	for (int i = 0; i < 3; ++i)
	{
		float p = (&p1.x)[i];
		float d = (&dir.x)[i];

		if (d != 0.0f)
		{
			float t1 = ((&boxMin.x)[i] - p) / d;
			float t2 = ((&boxMax.x)[i] - p) / d;

			if (t1 > t2) std::swap(t1, t2);

			tmin = std::max(tmin, t1);
			tmax = std::min(tmax, t2);

			if (tmin > tmax) return false;
		}
		else if (p < (&boxMin.x)[i] || p >(&boxMax.x)[i])
		{
			return false;
		}
	}

	return true;
}

// 3D version of LineOfTilesIsWalkable that checks full bounding boxes of objects
bool LineOfTilesIsWalkable3D(Vector3 start, Vector3 end)
{
	// Get chunk coordinates for the two endpoints
	int cx1 = std::clamp(static_cast<int>(start.x) / 16, 0, 191);
	int cz1 = std::clamp(static_cast<int>(start.z) / 16, 0, 191);
	int cx2 = std::clamp(static_cast<int>(end.x) / 16, 0, 191);
	int cz2 = std::clamp(static_cast<int>(end.z) / 16, 0, 191);

	// Collect the chunks the line crosses
	std::vector<std::pair<int, int>> chunksToCheck;
	chunksToCheck.emplace_back(cx1, cz1);
	if (cx1 != cx2 || cz1 != cz2)
	{
		chunksToCheck.emplace_back(cx2, cz2);

		// For diagonal movement add the corner chunk
		if (cx1 != cx2 && cz1 != cz2)
		{
			int midCX = cx1 + (cx2 > cx1 ? 1 : -1);
			int midCZ = cz1 + (cz2 > cz1 ? 1 : -1);
			chunksToCheck.emplace_back(midCX, midCZ);
		}
	}

	// Test against every object in those chunks
	for (const auto& [cx, cz] : chunksToCheck)
	{
		for (U7Object* obj : g_chunkObjectMap[cx][cz])
		{
			if (obj == nullptr) continue;

			// Eggs are triggers - don't let them block 3D connectivity tests
			if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_EGG) continue;

			Vector3 half = Vector3Multiply(obj->m_shapeData->m_Dims, { 0.5f, 0.5f, 0.5f });
			Vector3 min = Vector3Subtract(obj->m_Pos, half);
			Vector3 max = Vector3Add(obj->m_Pos, half);

			if (LineIntersectsAABB3D(start, end, min, max))
			{
				return false;  // blocked by this object
			}
		}
	}

	return true;  // clear path in 3D
}

bool AreAllTilesInDirectionWalkable(Vector2 start, Dir8 direction)
{
	int startx = start.x;
	int starty = start.y;
	int destx = 0;
	int desty = 0;

	switch (direction)
	{
	case DIR_N:
		destx = 0;
		desty = -1;
		break;

	case DIR_NW:
		destx = -1;
		desty = -1;
		break;

	case DIR_NE:
		destx = 1;
		desty = -1;
		break;

	case DIR_E:
		destx = 1;
		desty = 0;
		break;

	case DIR_SE:
		destx = 1;
		desty = 1;
		break;

	case DIR_S:
		destx = 0;
		desty = 1;
		break;

	case DIR_SW:
		destx = -1;
		desty = 1;
		break;

	case DIR_W:
		destx = -1;
		desty = 0;
		break;
	}

	for (int i = 0; i < 16; ++i)
	{
		startx += destx;
		starty += desty;

		//  Stay on the world, please.
		if (startx < 0) startx = 0;
		if (starty < 0) starty = 0;
		if (startx > 3071) startx = 3071;
		if (starty > 3071) starty = 3071;

		unsigned short shapeframe = g_World[startx][starty];
		int shapeID = shapeframe & 0x3ff;  // Extract shape ID (bits 0-9)
		if (g_objectDataTable[shapeID].m_isNotWalkable)
		{
			return false;
		}
	}
	return true;
}

void PathfindingSystem::Init(const std::string& configfile)
{
	m_aStar = std::make_unique<AStar>();
	m_pathfindingGrid = std::make_unique<PathfindingGrid>();

	LoadObjectWalkability("Data/object_walkability.csv");

	// Precompute chunk connectivity for hierarchical pathfinding
	PopulateChunkPathfindingGrid();
}

std::vector<Vector3> PathfindingSystem::FindPath(Vector3 start, Vector3 end, U7Object* agent)
{
	// Instrument A* runtime per call (ms)
	float t0 = GetTime();
	auto path = m_aStar->FindPath(start, end, m_pathfindingGrid.get(), agent);
	float elapsed = GetTime() - t0;
	uint64_t ms = static_cast<uint64_t>(elapsed * 1000.0f);
	m_astarTotalCalls.fetch_add(1);
	m_astarTotalMs.fetch_add(ms);
	// update max
	uint64_t prevMax = m_astarMaxMs.load();
	while (ms > prevMax && !m_astarMaxMs.compare_exchange_weak(prevMax, ms))
	{
		// loop until swapped or prevMax updated
	}

	// Update an exponential moving average (EMA) for per-call latency so UI/telemetry can show trending.
	{
		std::lock_guard<std::mutex> lk(m_instrumentMutex);
		double msd = static_cast<double>(ms);
		if (m_astarEmaMs == 0.0)
			m_astarEmaMs = msd;
		else
			m_astarEmaMs = m_astarEmaAlpha * msd + (1.0 - m_astarEmaAlpha) * m_astarEmaMs;
	}

	// Optional: log unusually slow A* runs for diagnostics
	const uint64_t SLOW_ASTAR_MS = 400; // tunable threshold
	if (ms >= SLOW_ASTAR_MS)
	{
		AddConsoleString(std::string("A* slow: ") + std::to_string(ms) + " ms", YELLOW);
	}

	return path;
}

// Record queue latency (ms) for workloads that are queued before being processed.
// Useful when you later move pathfinding to worker threads: have the producer measure enqueue->dequeue time
// and call this to aggregate queue wait telemetry.
void PathfindingSystem::RecordQueueLatency(uint64_t ms)
{
	m_astarQueueTotalMs.fetch_add(ms);
	m_astarQueueCalls.fetch_add(1);
}

// Implement debug helpers that were declared in the header but missing from the
// previous commit. These must be defined with the exact signatures so the
// linker can resolve calls from other translation units (debug drawing, etc.).

void AStar::ClearDebugMarkers()
{
	m_visitedNodeKeys.clear();
	m_finalPathKeys.clear();
}

bool AStar::IsNodeVisited(int x, int z, float y) const
{
	int yidx = QuantizeY(y);
	int64_t k = MakeNodeKey(x, z, yidx);
	return m_visitedNodeKeys.find(k) != m_visitedNodeKeys.end();
}

bool AStar::IsNodeOnFinalPath(int x, int z, float y) const
{
	int yidx = QuantizeY(y);
	int64_t k = MakeNodeKey(x, z, yidx);
	return m_finalPathKeys.find(k) != m_finalPathKeys.end();
}

void PathfindingSystem::LoadObjectWalkability(const std::string& filename)
{
	std::ifstream file(filename);
	if (!file.is_open())
	{
		return;
	}

	std::string line;
	int lineNumber = 0;

	while (std::getline(file, line))
	{
		lineNumber++;

		// Skip empty lines
		if (line.empty())
			continue;

		// Skip lines starting with space or #
		if (line[0] == ' ' || line[0] == '#')
			continue;

		// Remove any trailing whitespace or comments
		size_t commentPos = line.find('#');
		if (commentPos != std::string::npos)
			line = line.substr(0, commentPos);

		// Trim trailing whitespace
		line.erase(std::find_if(line.rbegin(), line.rend(), [](unsigned char ch) {
			 return !std::isspace(ch);
		}).base(), line.end());

		if (line.empty())
			continue;

		// Parse two integers separated by comma
		std::istringstream ss(line);
		int shapeID, walkableValue;

		if (ss >> shapeID)
		{
			// Skip the comma and any whitespace
			ss.ignore(1, ',');
			if (ss >> walkableValue)
			{
				g_pathfindingSystem->m_objectWalkability[shapeID] = ObjectWalkability(walkableValue);
			}
		}
	}
}

bool PathfindingSystem::IsRoofShape(int shapeId)
{
	switch (shapeId)
	{
	// Clay / red tile roofs
	case 156: case 908: case 966:
	// Thatch (TEXT.FLX has no names for these — still roofs)
	case 161: case 162:
	// Slate roofs
	case 164: case 165: case 166: case 167: case 169: case 962: case 963:
	// Wood roofs
	case 170: case 171: case 172: case 173: case 174: case 175: case 176: case 891: case 956:
	// Greenhouse / broken / wagon (still roofs for group/interior purposes)
	case 223: case 853: case 954: case 979:
		return true;
	default:
		return false;
	}
}

bool PathfindingSystem::IsMountainTopShape(int shapeId)
{
	// Exult data/bg/shape_info.txt section mountain_tops (val=1 normal tops).
	// These mark dungeon ceilings; their footprints are "dungeon tiles".
	switch (shapeId)
	{
	case 180: case 182: case 183: case 324: case 969: case 983:
		return true;
	default:
		return false;
	}
}

RoofMaterial PathfindingSystem::GetRoofMaterial(int shapeId)
{
	switch (shapeId)
	{
	case 170: case 171: case 172: case 173: case 174: case 175: case 176: case 891: case 956:
		return RoofMaterial::Wood;
	case 164: case 165: case 166: case 167: case 169: case 962: case 963:
		return RoofMaterial::Slate;
	case 156: case 908: case 966:
		return RoofMaterial::Tile;
	// Unnamed in TEXT.FLX; in-game thatch (cottage west of Trinsic, etc.)
	case 161: case 162:
		return RoofMaterial::Thatch;
	case 223: case 853: case 954: case 979:
		return RoofMaterial::Other;
	default:
		return RoofMaterial::None;
	}
}

const ChunkInfo* PathfindingSystem::GetChunkInfo(int chunkX, int chunkZ) const
{
	if (chunkX < 0 || chunkX >= 192 || chunkZ < 0 || chunkZ >= 192)
	{
		return nullptr;
	}
	return &m_chunkInfoMap[chunkX][chunkZ];
}

bool PathfindingSystem::IsInteriorTile(int worldX, int worldZ) const
{
	if (worldX < 0 || worldX >= 3072 || worldZ < 0 || worldZ >= 3072)
	{
		return false;
	}
	const ChunkInfo& info = m_chunkInfoMap[worldX / 16][worldZ / 16];
	return info.interior[worldX % 16][worldZ % 16];
}

int PathfindingSystem::GetRoofGroupAt(int worldX, int worldZ) const
{
	if (worldX < 0 || worldX >= 3072 || worldZ < 0 || worldZ >= 3072)
	{
		return -1;
	}
	const ChunkInfo& info = m_chunkInfoMap[worldX / 16][worldZ / 16];
	return info.roofGroupTile[worldX % 16][worldZ % 16];
}

int PathfindingSystem::GetRoofTypeAt(int worldX, int worldZ) const
{
	if (worldX < 0 || worldX >= 3072 || worldZ < 0 || worldZ >= 3072)
	{
		return -1;
	}
	return m_chunkInfoMap[worldX / 16][worldZ / 16].roofTypeID;
}

int PathfindingSystem::GetDungeonCeilingAt(int worldX, int worldZ) const
{
	if (worldX < 0 || worldX >= 3072 || worldZ < 0 || worldZ >= 3072)
	{
		return -1;
	}
	const unsigned char ceil = m_chunkInfoMap[worldX / 16][worldZ / 16].dungeonCeiling[worldX % 16][worldZ % 16];
	return (ceil == 0) ? -1 : static_cast<int>(ceil);
}

bool PathfindingSystem::IsDungeonTile(int worldX, int worldZ) const
{
	return GetDungeonCeilingAt(worldX, worldZ) >= 0;
}

void PathfindingSystem::BuildChunkBuildingData()
{
	const int CHUNKS = 192;
	const int dir4[4][2] = { {0, -1}, {1, 0}, {0, 1}, {-1, 0} };

	// Reset building fields (leave walkable/canReach alone if already filled).
	for (int cx = 0; cx < CHUNKS; ++cx)
	{
		for (int cz = 0; cz < CHUNKS; ++cz)
		{
			ChunkInfo& info = m_chunkInfoMap[cx][cz];
			info.hasRoof = false;
			info.roofGroupID = -1;
			info.roofTypeID = -1;
			info.roofMaterial = RoofMaterial::None;
			info.hasDungeon = false;
			for (int tz = 0; tz < 16; ++tz)
			{
				for (int tx = 0; tx < 16; ++tx)
				{
					info.interior[tx][tz] = false;
					info.roofGroupTile[tx][tz] = -1;
					info.dungeonCeiling[tx][tz] = 0;
				}
			}
		}
	}

	// Pass 1: mark roof coverage tiles + per-tile material (for typing).
	// materialGrid: only written where roof present; 0 = none.
	static thread_local std::array<std::array<uint8_t, 3072>, 3072>* s_matGrid = nullptr;
	static thread_local std::array<std::array<uint8_t, 3072>, 3072>* s_roofMask = nullptr;
	if (!s_matGrid)
	{
		s_matGrid = new std::array<std::array<uint8_t, 3072>, 3072>();
		s_roofMask = new std::array<std::array<uint8_t, 3072>, 3072>();
	}
	// Clear only as we write (full clear is expensive); use a generation stamp instead.
	// Full clear of 3072^2 is ~9MB — acceptable once at load.
	for (int z = 0; z < 3072; ++z)
	{
		std::memset((*s_roofMask)[z].data(), 0, 3072);
		std::memset((*s_matGrid)[z].data(), 0, 3072);
	}

	for (const auto& pair : g_objectList)
	{
		U7Object* obj = pair.second.get();
		if (!obj || obj->GetIsDead() || !obj->m_objectData)
		{
			continue;
		}
		const int shape = obj->m_ObjectType;
		if (!IsRoofShape(shape))
		{
			continue;
		}

		const RoofMaterial mat = GetRoofMaterial(shape);
		const uint8_t matByte = static_cast<uint8_t>(mat);

		// Use logical TFA width/depth, NOT the FLAT draw bounding box.
		// Iso roof sprites are large diamonds: SetPos builds bbox from texture size
		// with origin at bottom-right of the art, so the box extends several tiles
		// west/north of m_Pos and over-pops when hugging exterior walls.
		//
		// U7 object coords are the SE (max X / max Z) corner of the footprint; size
		// extends west/north. Same convention as door cost footprints above.
		// Painting +X/+Z from m_Pos was one tile (or more) past the true south/east
		// edge and caused false pop-off when standing just outside bottom/right.
		const int width = std::max(1, static_cast<int>(obj->m_objectData->m_width));
		const int depth = std::max(1, static_cast<int>(obj->m_objectData->m_depth));
		const int maxTileX = static_cast<int>(std::floor(obj->m_Pos.x));
		const int maxTileZ = static_cast<int>(std::floor(obj->m_Pos.z));
		const int minTileX = maxTileX - width + 1;
		const int minTileZ = maxTileZ - depth + 1;

		for (int wz = minTileZ; wz <= maxTileZ; ++wz)
		{
			for (int wx = minTileX; wx <= maxTileX; ++wx)
			{
				if (wx < 0 || wx >= 3072 || wz < 0 || wz >= 3072)
				{
					continue;
				}
				(*s_roofMask)[wz][wx] = 1;
				// Prefer non-Other materials when overlapping.
				uint8_t& cellMat = (*s_matGrid)[wz][wx];
				if (cellMat == 0 || cellMat == static_cast<uint8_t>(RoofMaterial::Other))
				{
					cellMat = matByte;
				}
				else if (matByte != static_cast<uint8_t>(RoofMaterial::Other) && matByte != 0)
				{
					cellMat = matByte;
				}

				const int cx = wx / 16;
				const int cz = wz / 16;
				ChunkInfo& info = m_chunkInfoMap[cx][cz];
				info.hasRoof = true;
				info.interior[wx % 16][wz % 16] = true;
			}
		}
	}

	// Pass 1b: mountain tops mark dungeon ceilings (Exult Map_chunk::setup_dungeon_levels).
	// Footprint tiles get the mountain's placement Y as ceiling lift; max wins on overlap.
	int dungeonTileCount = 0;
	for (const auto& pair : g_objectList)
	{
		U7Object* obj = pair.second.get();
		if (!obj || obj->GetIsDead() || !obj->m_objectData)
		{
			continue;
		}
		if (!IsMountainTopShape(obj->m_ObjectType))
		{
			continue;
		}

		// Ceiling lift: object placement Y (U7 lift units). Clamp 1..31 so 0 stays "not dungeon".
		int ceiling = static_cast<int>(std::lround(obj->m_Pos.y));
		if (ceiling < 1)
		{
			ceiling = 1;
		}
		if (ceiling > 31)
		{
			ceiling = 31;
		}

		const int width = std::max(1, static_cast<int>(obj->m_objectData->m_width));
		const int depth = std::max(1, static_cast<int>(obj->m_objectData->m_depth));
		const int maxTileX = static_cast<int>(std::floor(obj->m_Pos.x));
		const int maxTileZ = static_cast<int>(std::floor(obj->m_Pos.z));
		const int minTileX = maxTileX - width + 1;
		const int minTileZ = maxTileZ - depth + 1;

		for (int wz = minTileZ; wz <= maxTileZ; ++wz)
		{
			for (int wx = minTileX; wx <= maxTileX; ++wx)
			{
				if (wx < 0 || wx >= 3072 || wz < 0 || wz >= 3072)
				{
					continue;
				}
				const int cx = wx / 16;
				const int cz = wz / 16;
				ChunkInfo& info = m_chunkInfoMap[cx][cz];
				unsigned char& cell = info.dungeonCeiling[wx % 16][wz % 16];
				const unsigned char ceilByte = static_cast<unsigned char>(ceiling);
				if (cell == 0)
				{
					cell = ceilByte;
					info.hasDungeon = true;
					++dungeonTileCount;
				}
				else if (ceilByte > cell)
				{
					cell = ceilByte;
				}
			}
		}
	}
	if (dungeonTileCount > 0)
	{
		Log("BuildChunkBuildingData: " + std::to_string(dungeonTileCount) + " dungeon tiles under mountain tops");
	}

	// Pass 2: flood-fill *tiles* that have roof coverage into building groups.
	// Adjacent chunks only share a group if their roof tiles actually touch.
	// This prevents an entire town from becoming one roofGroupID.
	struct GroupStats
	{
		RoofMaterial material = RoofMaterial::None;
		int minX = 3072, minZ = 3072, maxX = -1, maxZ = -1;
		int tileCount = 0;
	};
	std::vector<GroupStats> groups;
	int nextGroup = 0;

	// visited: reuse roof mask destruction — copy mask bits we need via group stamp in roofGroupTile
	// Use a separate visited grid.
	static thread_local std::array<std::array<uint8_t, 3072>, 3072>* s_visited = nullptr;
	if (!s_visited)
	{
		s_visited = new std::array<std::array<uint8_t, 3072>, 3072>();
	}
	for (int z = 0; z < 3072; ++z)
	{
		std::memset((*s_visited)[z].data(), 0, 3072);
	}

	for (int wz = 0; wz < 3072; ++wz)
	{
		for (int wx = 0; wx < 3072; ++wx)
		{
			if (!(*s_roofMask)[wz][wx] || (*s_visited)[wz][wx])
			{
				continue;
			}

			const int groupId = nextGroup++;
			GroupStats stats;
			std::deque<std::pair<int, int>> q;
			q.push_back({ wx, wz });
			(*s_visited)[wz][wx] = 1;

			while (!q.empty())
			{
				const auto [x, z] = q.front();
				q.pop_front();

				const int cx = x / 16;
				const int cz = z / 16;
				const int tx = x % 16;
				const int tz = z % 16;
				m_chunkInfoMap[cx][cz].roofGroupTile[tx][tz] = groupId;

				stats.tileCount++;
				stats.minX = std::min(stats.minX, x);
				stats.minZ = std::min(stats.minZ, z);
				stats.maxX = std::max(stats.maxX, x);
				stats.maxZ = std::max(stats.maxZ, z);
				const auto mat = static_cast<RoofMaterial>((*s_matGrid)[z][x]);
				if (mat != RoofMaterial::None)
				{
					if (stats.material == RoofMaterial::None || stats.material == RoofMaterial::Other)
					{
						stats.material = mat;
					}
					if (mat != RoofMaterial::Other)
					{
						stats.material = mat;
					}
				}

				for (int d = 0; d < 4; ++d)
				{
					const int nx = x + dir4[d][0];
					const int nz = z + dir4[d][1];
					if (nx < 0 || nx >= 3072 || nz < 0 || nz >= 3072)
					{
						continue;
					}
					if (!(*s_roofMask)[nz][nx] || (*s_visited)[nz][nx])
					{
						continue;
					}
					(*s_visited)[nz][nx] = 1;
					q.push_back({ nx, nz });
				}
			}
			groups.push_back(stats);
		}
	}
	m_roofGroupCount = nextGroup;

	// Pass 3: roll up per-chunk primary group / material / type.
	// Primary group = most common roofGroupTile value in the chunk.
	std::unordered_map<uint64_t, int> typeMap;
	int nextType = 0;
	std::vector<int> groupToType(groups.size(), -1);

	for (size_t gi = 0; gi < groups.size(); ++gi)
	{
		const GroupStats& g = groups[gi];
		if (g.maxX < 0)
		{
			continue;
		}
		int w = g.maxX - g.minX + 1;
		int d = g.maxZ - g.minZ + 1;
		int wq = ((w + 3) / 4) * 4;
		int dq = ((d + 3) / 4) * 4;
		int orient = 0;
		if (wq > dq * 6 / 5)
		{
			orient = 1;
		}
		else if (dq > wq * 6 / 5)
		{
			orient = 2;
		}
		if (orient == 2)
		{
			std::swap(wq, dq);
			orient = 1;
		}

		const uint64_t key =
			(static_cast<uint64_t>(static_cast<int>(g.material)) << 40) |
			(static_cast<uint64_t>(wq & 0xFFF) << 28) |
			(static_cast<uint64_t>(dq & 0xFFF) << 16) |
			(static_cast<uint64_t>(orient & 0xF) << 12);

		auto it = typeMap.find(key);
		if (it == typeMap.end())
		{
			typeMap[key] = nextType;
			groupToType[gi] = nextType;
			++nextType;
		}
		else
		{
			groupToType[gi] = it->second;
		}
	}
	m_roofTypeCount = nextType;

	for (int cx = 0; cx < CHUNKS; ++cx)
	{
		for (int cz = 0; cz < CHUNKS; ++cz)
		{
			ChunkInfo& info = m_chunkInfoMap[cx][cz];
			if (!info.hasRoof)
			{
				continue;
			}

			// Count group frequency within chunk.
			std::unordered_map<int, int> freq;
			int bestGroup = -1;
			int bestCount = 0;
			RoofMaterial bestMat = RoofMaterial::None;
			for (int tz = 0; tz < 16; ++tz)
			{
				for (int tx = 0; tx < 16; ++tx)
				{
					const int g = info.roofGroupTile[tx][tz];
					if (g < 0)
					{
						continue;
					}
					const int c = ++freq[g];
					if (c > bestCount)
					{
						bestCount = c;
						bestGroup = g;
					}
				}
			}
			info.roofGroupID = bestGroup;
			if (bestGroup >= 0 && bestGroup < static_cast<int>(groups.size()))
			{
				info.roofMaterial = groups[bestGroup].material;
				if (bestGroup < static_cast<int>(groupToType.size()))
				{
					info.roofTypeID = groupToType[bestGroup];
				}
			}
			(void)bestMat;
		}
	}

	Log("BuildChunkBuildingData: " + std::to_string(m_roofGroupCount) + " roof groups, " +
		std::to_string(m_roofTypeCount) + " roof types");
}

void PathfindingSystem::UpdateBuildingRoofVisibility(float avatarWorldX, float avatarWorldZ, float avatarWorldY)
{
	// Active building = roof group under the avatar's tile (from chunk roofGroupTile data).
	// Only that group's roof pieces hide — not every roofed chunk nearby.
	// Avatar m_Pos is the standing center (same as draw); floor() is the tile they occupy.
	// Height: only pop roofs that are still ABOVE the avatar (indoors). Standing on
	// or above a roof surface must leave that roof visible.
	const int ax = static_cast<int>(std::floor(avatarWorldX));
	const int az = static_cast<int>(std::floor(avatarWorldZ));
	const int activeGroup = GetRoofGroupAt(ax, az);

	const int acx = ax / 16;
	const int acz = az / 16;
	const int radius = 4; // chunks

	for (int cz = acz - radius; cz <= acz + radius; ++cz)
	{
		for (int cx = acx - radius; cx <= acx + radius; ++cx)
		{
			if (cx < 0 || cx >= 192 || cz < 0 || cz >= 192)
			{
				continue;
			}
			const ChunkInfo& info = m_chunkInfoMap[cx][cz];
			if (!info.hasRoof)
			{
				continue;
			}

			// Does this chunk contain any tiles of the active group?
			bool chunkHasActiveGroup = false;
			if (activeGroup >= 0)
			{
				for (int tz = 0; tz < 16 && !chunkHasActiveGroup; ++tz)
				{
					for (int tx = 0; tx < 16; ++tx)
					{
						if (info.roofGroupTile[tx][tz] == activeGroup)
						{
							chunkHasActiveGroup = true;
							break;
						}
					}
				}
			}

			for (U7Object* obj : g_chunkObjectMap[cx][cz])
			{
				if (!obj || !obj->m_objectData)
				{
					continue;
				}
				if (!IsRoofShape(obj->m_ObjectType))
				{
					continue;
				}
				// Respect permanent DONT_DRAW (e.g. morphroof hide list).
				if (obj->m_drawType == ShapeDrawType::OBJECT_DRAW_DONT_DRAW)
				{
					obj->m_Visible = false;
					continue;
				}

				// Roof pop only HIDES roofs of the building under the avatar.
				// Do not force m_Visible = true: the caller's height-cutoff pass
				// (sandbox PGUP/PGDOWN "view floor") may have already hidden upper
				// storeys and roofs. Un-hiding them here made floor view useless.
				if (activeGroup < 0)
				{
					continue;
				}

				// Hide only if this roof piece's logical TFA footprint (SE-origin)
				// overlaps the active building group — same region used when building
				// roofGroupTile. Do not use the iso draw bbox (oversize diamond).
				bool sameBuilding = false;
				const int width = std::max(1, static_cast<int>(obj->m_objectData->m_width));
				const int depth = std::max(1, static_cast<int>(obj->m_objectData->m_depth));
				const int maxTX = static_cast<int>(std::floor(obj->m_Pos.x));
				const int maxTZ = static_cast<int>(std::floor(obj->m_Pos.z));
				const int minTX = maxTX - width + 1;
				const int minTZ = maxTZ - depth + 1;
				for (int tz = minTZ; tz <= maxTZ && !sameBuilding; ++tz)
				{
					for (int tx = minTX; tx <= maxTX; ++tx)
					{
						if (GetRoofGroupAt(tx, tz) == activeGroup)
						{
							sameBuilding = true;
							break;
						}
					}
				}
				if (sameBuilding)
				{
					// Standing surface includes TFA height (see GetObjectSurfaceY).
					const float roofSurfaceY = GetObjectSurfaceY(obj);
					// Small margin so climbing onto the plane doesn't flicker.
					if (avatarWorldY < roofSurfaceY - 0.15f)
					{
						obj->m_Visible = false;
					}
				}
			}

			(void)chunkHasActiveGroup;
		}
	}

}

void PathfindingSystem::PopulateChunkPathfindingGrid()
{
	const int CHUNKS = 192;
	if (!m_pathfindingGrid)
		return;

	// Direction offsets (N, NE, E, SE, S, SW, W, NW)
	const int dirOffsets[8][2] = {
		{0, -1}, {1, -1}, {1, 0}, {1, 1},
		{0, 1},  {-1, 1}, {-1, 0}, {-1, -1}
	};

	// Precompute per-chunk walkability and connectivity
	for (int cx = 0; cx < CHUNKS; ++cx)
	{
		for (int cz = 0; cz < CHUNKS; ++cz)
		{
			ChunkInfo& info = m_chunkInfoMap[cx][cz];

			// Fill per-tile walkable flags for this chunk (16x16)
			int baseX = cx * 16;
			int baseZ = cz * 16;
			for (int tz = 0; tz < 16; ++tz)
			{
				for (int tx = 0; tx < 16; ++tx)
				{
					int wx = baseX + tx;
					int wz = baseZ + tz;
					// Safety clamp to world bounds
					if (wx < 0 || wx >= 3072 || wz < 0 || wz >= 3072)
					{
						info.walkable[tx][tz] = false;
					}
					else
					{
						info.walkable[tx][tz] = m_pathfindingGrid->IsPositionWalkable(wx, wz, 0.0f);
					}
				}
			}

			// Compute connectivity to neighboring chunks using 3D line-of-sight considering object bounding boxes.
			// Use chunk centers as endpoints for the test.
			Vector3 start = { (float)(baseX + 8), 1.0f, (float)(baseZ + 8) };

			for (int d = 0; d < 8; ++d)
			{
				int ncx = cx + dirOffsets[d][0];
				int ncz = cz + dirOffsets[d][1];

				// Out of range neighbor means not reachable
				if (ncx < 0 || ncx >= CHUNKS || ncz < 0 || ncz >= CHUNKS)
				{
					info.canReach[d] = false;
					continue;
				}

				int nBaseX = ncx * 16;
				int nBaseZ = ncz * 16;
				Vector3 end = { (float)(nBaseX + 8), 1.0f, (float)(nBaseZ + 8) };

				// Fast sanity check: ensure there is at least one walkable tile along the edge between chunks
				// This prevents marking connectivity through completely blocked chunks.
				bool edgeHasWalkable = false;
				// sample a small set of tiles along the bordering edge between the two chunks
				for (int sx = 6; sx <= 10 && !edgeHasWalkable; ++sx)
				{
					for (int sz = 6; sz <= 10 && !edgeHasWalkable; ++sz)
					{
						// Map sample to world coords moving from this chunk towards neighbor
						int sampleX = baseX + sx + dirOffsets[d][0] * 4;
						int sampleZ = baseZ + sz + dirOffsets[d][1] * 4;
						if (sampleX < 0 || sampleX >= 3072 || sampleZ < 0 || sampleZ >= 3072)
							continue;
						if (m_pathfindingGrid->IsPositionWalkable(sampleX, sampleZ, 0.0f))
							edgeHasWalkable = true;
					}
				}

				if (!edgeHasWalkable)
				{
					info.canReach[d] = false;
					continue;
				}

				// Final test: ensure direct 3D corridor between chunk centers isn't blocked by large objects.
				bool reachable = LineOfTilesIsWalkable3D(start, end);
				info.canReach[d] = reachable;
			}
		}
	}

	// Roof groups, types, and interior tiles (needs world objects present).
	BuildChunkBuildingData();
}
