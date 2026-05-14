#include "PathfindingSystem.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "rlgl.h"
#include <algorithm>
#include <cmath>
#include <fstream>
#include <sstream>
#include <cstdint>
#include <unordered_set>
#include <deque>   // added for stable node storage
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

bool PathfindingGrid::IsPositionWalkable(int worldX, int worldZ, float agentBaseY) const
{
	// Tile-level check using agent-specific base Y
	return CheckTileWalkable(worldX, worldZ, agentBaseY);
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
				if (!obj || obj->m_isNPC)
					continue;

				if (obj->m_isContained)
					continue;

				if (obj->m_isEgg)
					continue;

				if (obj->m_shapeData->GetShape() == 257)//fortress gateway top
					continue;

				if (obj->m_shapeData->GetShape() == 292)//seat
					continue;

				if (obj->m_shapeData->GetShape() == 368)//floor
					continue;

				if (obj->m_shapeData->GetShape() == 607)//path
					continue;

				if (obj->m_shapeData->GetShape() == 678)//curtain
					continue;

				if (obj->m_shapeData->GetShape() == 657)//curtain
					continue;

				if (obj->m_shapeData->GetShape() == 873)//chair
					continue;

				if (obj->m_shapeData->GetShape() == 897)//seat
					continue;


				// Use object's world-space bounding box to determine tile overlap.
				const BoundingBox& bbox = obj->m_boundingBox;

				// Convert bbox to tile extents (floor to include partial coverage)
				int minTileX = (int)floor(bbox.min.x);
				int maxTileX = (int)floor(bbox.max.x - 1);
				int minTileZ = (int)floor(bbox.min.z);
				int maxTileZ = (int)floor(bbox.max.z - 1);

				// Skip if this object's bbox doesn't cover requested tile
				if (worldX < minTileX || worldX > maxTileX || worldZ < minTileZ || worldZ > maxTileZ)
					continue;

				OverlappingObject ovObj;
				ovObj.obj = obj;
				ovObj.tileX = minTileX;
				ovObj.tileZ = minTileZ;
				ovObj.width = std::max(1, maxTileX - minTileX + 1);
				ovObj.depth = std::max(1, maxTileZ - minTileZ + 1);
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

	if (shapeID == 657)//curtain
		return true;

	if (shapeID == 678)//curtain
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

	return false;
}

float PathfindingGrid::GetTileHeight(int worldX, int worldZ) const
{
	// Protect against calling before world data exists
	if (g_World.empty() || g_World.size() == 0)
		return 0.0f;
	if (worldZ < 0 || worldZ >= (int)g_World.size())
		return 0.0f;
	if (g_World[worldZ].empty() || worldX < 0 || worldX >= (int)g_World[worldZ].size())
		return 0.0f;

	// Get all objects at this tile
	auto objects = GetOverlappingObjects(worldX, worldZ);

	// Find the LOWEST walkable surface below height threshold
	// This ensures we use ground floor, not upper floors
	float lowestHeight = -1.0f;
	bool foundWalkableSurface = false;

	for (const auto& ovObj : objects)
	{
		U7Object* obj = ovObj.obj;
		if (!obj || !obj->m_objectData || !obj->m_shapeData)
			continue;
		if (obj->m_isEgg)
			continue;
		int shapeID = obj->m_shapeData->GetShape();

		// Skip very high objects (upper floors)
		// This filters out second story floors while keeping tall bridges
		if (obj->m_Pos.y >= MAX_WALKABLE_SURFACE_HEIGHT)
			continue;

		// Check if this is a known walkable surface
		if (PathfindingSystem::IsWalkableSurface(shapeID))
		{
			float surfaceHeight = obj->m_Pos.y + obj->m_objectData->m_height;

			// Keep the lowest walkable surface
			if (!foundWalkableSurface || surfaceHeight < lowestHeight)
			{
				lowestHeight = surfaceHeight;
				foundWalkableSurface = true;
			}
		}
	}

	if (foundWalkableSurface)
		return lowestHeight;

	// No walkable surface objects - ground level
	return 0.0f;
}

bool PathfindingGrid::CheckTileWalkable(int worldX, int worldZ, float agentBaseY) const
{
	// Protect against calling before world data exists
	if (g_World.empty() || g_World.size() == 0)
		return false;

	// Bounds check against actual world arrays
	if (worldZ < 0 || worldZ >= (int)g_World.size())
		return false;
	if (g_World[worldZ].empty() || worldX < 0 || worldX >= (int)g_World[worldZ].size())
		return false;

	// 1. Check terrain tile
	unsigned short shapeframe = g_World[worldZ][worldX];
	int shapeID = shapeframe & 0x3ff;  // Extract shape ID (bits 0-9)
	int frameID = (shapeframe >> 10) & 0x3f;  // Extract frame (bits 10-15)

	bool terrainBlocks = false;
	if (shapeID < 1024 && g_objectDataTable[shapeID].m_isNotWalkable)
	{
		// Special case: doors are walkable (NPCs can open them)
		if (g_objectDataTable[shapeID].m_isDoor)
		{
			// Both closed and open doors are walkable (closed doors just have higher cost)
			; // Continue checking objects
		}
		else
		{
			// Terrain blocks - but check if there's a door object on top before failing
			terrainBlocks = true;
		}
	}

	// 2. Check overlapping objects
	auto overlappingObjects = GetOverlappingObjects(worldX, worldZ);
	bool hasDoor = false;

	for (const auto& ovObj : overlappingObjects)
	{
		U7Object* obj = ovObj.obj;
		if (!obj || !obj->m_objectData)
			continue;

		// Special case for doors: Check if this is the door's hinge tile (base position)
		// The hinge tile is ALWAYS non-walkable
		if (obj->m_objectData->m_isDoor)
		{
			int doorTileX = (int)floor(obj->m_Pos.x);
			int doorTileZ = (int)floor(obj->m_Pos.z);

			// If this is the hinge tile, it's always blocked
			if (worldX == doorTileX && worldZ == doorTileZ)
			{
				return false;  // Hinge tile is never walkable
			}

			// For other tiles covered by the door's bounding box:
			// These are walkable (NPCs can path through and open doors)
			hasDoor = true;
			terrainBlocks = false;
			continue;
		}

		// If we already found a door, ignore other blocking objects
		if (hasDoor)
			continue;

		// Check if this is a walkable surface (floor, bridge, stairs)
		if (obj->m_shapeData && obj->m_objectData)
		{
			int objShapeID = obj->m_shapeData->GetShape();

			// Compare surface top with agent base Y and MAX_CLIMBABLE_HEIGHT:
			// if surface is above what the agent can reach, this tile is not walkable for that agent.
			float surfaceTop = obj->m_Pos.y + obj->m_objectData->m_height;

			// If this shape is a "walkable surface" but the top is too high for this agent, block it.
			if (PathfindingSystem::IsWalkableSurface(objShapeID) && (surfaceTop - agentBaseY) > MAX_CLIMBABLE_HEIGHT)
			{
				// Treat as blocked for this agent
				return false;
			}

			// Existing logic: if it's a known walkable surface at reasonable height, allow tile
			if (PathfindingSystem::IsWalkableSurface(objShapeID))
			{
				// Skip very high walkable surfaces (upper floors)
				if (obj->m_Pos.y >= MAX_WALKABLE_SURFACE_HEIGHT)
					continue;

				terrainBlocks = false;  // Clear any terrain blocking below this walkable surface
				continue;
			}
		}

		// Skip very high objects (upper floors)
		if (obj->m_Pos.y >= MAX_WALKABLE_SURFACE_HEIGHT)
			continue;

		// Any other ground-level blocking object blocks the tile
		return false;
	}

	// Final check: if terrain blocks and no door cleared it, return false
	if (terrainBlocks)
		return false;

	return true;  // Nothing blocks this position
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

// Returns a sorted list of unique surface heights for world tile (x,z).
std::vector<float> PathfindingGrid::GetWalkableSurfaceHeights(int worldX, int worldZ) const
{
	std::vector<float> heights;

	// Bounds
	if (worldX < 0 || worldX >= 3072 || worldZ < 0 || worldZ >= 3072)
		return heights;

	// Ground always present
	heights.push_back(0.0f);

	// Check overlapping objects for known walkable surfaces
	auto objects = GetOverlappingObjects(worldX, worldZ);
	for (const auto& ov : objects)
	{
		U7Object* obj = ov.obj;
		if (!obj || !obj->m_objectData || !obj->m_shapeData)
			continue;

		int shapeID = obj->m_shapeData->GetShape();
		if (!PathfindingSystem::IsWalkableSurface(shapeID))
			continue;

		// Compute surface top height
		float surfaceH = obj->m_Pos.y + obj->m_objectData->m_height;

		// Debug: report walkable surfaces found
//#ifdef DEBUG_NPC_PATHFINDING
//		{
//			std::stringstream ss;
//			ss << "GetWalkableSurfaceHeights(" << worldX << "," << worldZ << "): found shape " << shapeID
//			   << " name=\"" << (obj->m_objectData ? obj->m_objectData->m_name : std::string("<nil>"))
//			   << "\" surfaceH=" << surfaceH;
//			NPCDebugPrint(ss.str());
//		}
//#endif

		// Add all surfaces; filtering for reachable/too-high will happen later
		heights.push_back(surfaceH);
	}

	// sort and deduplicate (small epsilon)
	std::sort(heights.begin(), heights.end());
	const float EPS = 0.001f;
	std::vector<float> uniqueHeights;
	for (float h : heights)
	{
		if (uniqueHeights.empty() || fabs(uniqueHeights.back() - h) > EPS)
			uniqueHeights.push_back(h);
	}
	return uniqueHeights;
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
std::vector<Vector3> AStar::FindPath(Vector3 start, Vector3 goal, PathfindingGrid* grid)
{
	if (!grid)
		return {};

	auto TileKey = [](int x, int z) -> int { return (x << 16) | (z & 0xFFFF); };
	std::unordered_map<int, bool> walkableCache;
	std::unordered_map<int, std::vector<float>> heightsCache;

	const int maxNodesToExplore = 500;
	std::vector<PathNode> nodePool;
	nodePool.reserve(maxNodesToExplore * 2); // keep contiguous memory

	std::unordered_set<int64_t> localVisitedNodeKeys;
	std::unordered_set<int64_t> localFinalPathKeys;

	int startX = (int)start.x;
	int startZ = (int)start.z;
	int goalX = (int)goal.x;
	int goalZ = (int)goal.z;

	// Bounds check
	if (startX < 0 || startX >= 3072 || startZ < 0 || startZ >= 3072 ||
		goalX < 0 || goalX >= 3072 || goalZ < 0 || goalZ >= 3072)
	{
		return {};
	}

	// Limit search distance to avoid searching entire map (performance)
	int distance = abs(goalX - startX) + abs(goalZ - startZ);
	// If distance is large, run chunk-level A* first (hierarchical)
	const int HIERARCHICAL_THRESHOLD = 240;
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
			// Convert chunk path to intermediate world targets (chunk centers)
			std::vector<Vector3> intermediates;
			for (const auto& pc : chunkPath)
			{
				int ccx = pc.first, ccz = pc.second;
				float wx = float(ccx * 16 + 8);
				float wz = float(ccz * 16 + 8);
				intermediates.push_back(Vector3{ wx, 0.0f, wz });
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
				auto segPath = FindPath(curStart, segGoal, grid); // recursion — segment distances are small
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
				auto lastSeg = FindPath(curStart, goal, grid);
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
	int nodesExplored = 0;


	// A* main loop
	while (!openSet.empty() && nodesExplored < maxNodesToExplore)
	{
		nodesExplored++;

		const int NODES_PER_TILE_FACTOR = 75;
		if (distance > 0)
		{
			// Allow at most `distance * NODES_PER_TILE_FACTOR` nodes, but never exceed maxNodesToExplore.
			int dynamicLimit = std::min(maxNodesToExplore, distance * NODES_PER_TILE_FACTOR);
			if (nodesExplored > dynamicLimit)
			{
				//AddConsoleString("A*: aborting search - expanded too many nodes relative to distance", YELLOW);
				break; // fall through to fallback logic that picks closest explored node
			}
		}
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

		// Check if we reached the goal (tile-level)
		if (current.x == goalX && current.z == goalZ)
		{
			const float GOAL_EPS = 0.01f;
			if (goalPreferredY <= 0.1f || fabsf(current.y - goalPreferredY) <= GOAL_EPS)
			{
				goalIndex = currentIndex;
				break;
			}
		}

		closedSet[currentKey64] = currentIndex;

		// Get neighbor indices
		std::vector<int> neighborIndices = GetNeighbors(currentIndex, grid, goalX, goalZ, walkableCache, heightsCache, nodePool);

		for (int neighborIndex : neighborIndices)
		{
			// Defensive index check
			if (neighborIndex < 0 || neighborIndex >= (int)nodePool.size())
				continue;

			PathNode& neighbor = nodePool[neighborIndex];

			int neighYIdx = QuantizeY(neighbor.y);
			int64_t neighborKey64 = MakeNodeKey(neighbor.x, neighbor.z, neighYIdx);

			if (closedSet.find(neighborKey64) != closedSet.end())
				continue;

			float moveCost;
			if (neighbor.y > 0.1f)
				moveCost = CLIMB_MOVEMENT_COST;
			else
				moveCost = GetMovementCost(neighbor.x, neighbor.z, grid);

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
						neighbor.g = tentativeG;
						neighbor.h = Heuristic(neighbor.x, neighbor.z, goalX, goalZ);
						neighbor.f = neighbor.g + neighbor.h;
						neighbor.parent = currentIndex;
						openSet.push({ neighbor.f, neighborIndex });
						openSetLookup[neighborKey64] = neighborIndex;
					}
				}
				else
				{
					// If existingIndex is invalid for some reason, treat as not present
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
	std::unordered_map<int, bool>& walkableCache,
	std::unordered_map<int, std::vector<float>>& heightsCache,
	std::vector<PathNode>& nodePool)
{
	std::vector<int> neighbors;

	if (nodeIndex < 0 || nodeIndex >= (int)nodePool.size())
		return neighbors;

	PathNode node = nodePool[nodeIndex];

	int directions[8][2] = {
		{0, -1},  {1, -1},  {-1, -1},
		{0, 1},   {1, 1},   {-1, 1},
		{1, 0},   {-1, 0}
	};

	for (int i = 0; i < 8; i++)
	{
		int nx = node.x + directions[i][0];
		int nz = node.z + directions[i][1];
		float currentHeight = node.y;

		if (nx < 0 || nx >= 3072 || nz < 0 || nz >= 3072)
			continue;

		bool isGoal = (nx == goalX && nz == goalZ);

		if (!isGoal)
		{
			int tkey = (nx << 16) | (nz & 0xFFFF);
			auto itWalk = walkableCache.find(tkey);
			bool tileWalkable = false;
			if (itWalk == walkableCache.end())
			{
				// PASS the agent's current base Y so the tile check is agent-aware
				tileWalkable = grid->IsPositionWalkable(nx, nz, currentHeight);
				walkableCache[tkey] = tileWalkable;
			}
			else
			{
				tileWalkable = itWalk->second;
			}
			if (!tileWalkable)
				continue;
		}

		int tileKey = (nx << 16) | (nz & 0xFFFF);
		std::vector<float> neighborHeights;
		auto itHe = heightsCache.find(tileKey);
		if (itHe == heightsCache.end())
		{
			neighborHeights = grid->GetWalkableSurfaceHeights(nx, nz);
			heightsCache[tileKey] = neighborHeights;
		}
		else
		{
			neighborHeights = itHe->second;
		}
		if (neighborHeights.empty())
			neighborHeights.push_back(0.0f);

		float chosenNeighborH = NAN;

		std::vector<float> reachablePos;
		for (float nh : neighborHeights)
		{
			if (nh > 0.001f && fabs(nh - currentHeight) <= MAX_CLIMBABLE_HEIGHT)
				reachablePos.push_back(nh);
		}
		if (!reachablePos.empty())
		{
			// Choose the reachable positive height closest to currentHeight (smallest step)
			float best = reachablePos[0];
			float bestd = fabs(best - currentHeight);
			for (float nh : reachablePos)
			{
				float d = fabs(nh - currentHeight);
				if (d < bestd) { bestd = d; best = nh; }
			}
			chosenNeighborH = best;
		}
		else
		{
			// 2) No reachable non-ground surfaces — pick the closest reachable (may be ground)
			float bestDiff = 9999.0f;
			for (float nh : neighborHeights)
			{
				float diff = fabs(nh - currentHeight);
				if (diff <= MAX_CLIMBABLE_HEIGHT && diff < bestDiff)
				{
					bestDiff = diff;
					chosenNeighborH = nh;
				}
			}
		}

		if (std::isnan(chosenNeighborH))
		{
			// Check overlapping objects on current and neighbor tile for stair shapes
			auto checkHasStair = [](PathfindingGrid* g, int tx, int tz) -> bool {
				auto objs = g->GetOverlappingObjects(tx, tz);
				for (const auto& ov : objs)
				{
					if (!ov.obj || !ov.obj->m_shapeData || !ov.obj->m_objectData) continue;
					int s = ov.obj->m_shapeData->GetShape();
					if ((s >= 426 && s <= 430))
						return true;
					std::string name = ov.obj->m_objectData->m_name;
					std::transform(name.begin(), name.end(), name.begin(), ::tolower);
					if (name.find("stair") != std::string::npos)
						return true;
				}
				return false;
				};

			bool stairPresent = checkHasStair(grid, node.x, node.z) || checkHasStair(grid, nx, nz);

			if (stairPresent)
			{
				// Only allow stair transitions that respect the MAX_CLIMBABLE_HEIGHT both up and down.
				// Collect neighbors that are within climbable range.
				std::vector<float> stairCandidates;
				for (float nh : neighborHeights)
				{
					if (fabs(nh - currentHeight) <= MAX_CLIMBABLE_HEIGHT)
						stairCandidates.push_back(nh);
				}

				if (!stairCandidates.empty())
				{
					float best = stairCandidates[0];
					float bestd = fabs(best - currentHeight);

					float cand_min = stairCandidates.front();
					float cand_max = stairCandidates.back();

					if (currentHeight > cand_max)
					{
						best = cand_max;
					}
					else if (currentHeight < cand_min)
					{
						best = cand_min;
					}
					else
					{
						for (float nh : stairCandidates)
						{
							float d = fabs(nh - currentHeight);
							if (d < bestd) { bestd = d; best = nh; }
						}
					}

					chosenNeighborH = best;
				}
			}
		}

		if (std::isnan(chosenNeighborH))
			continue;

		// Create neighbor node in nodePool
		nodePool.emplace_back(nx, nz, chosenNeighborH);
		int newIdx = (int)nodePool.size() - 1;
		nodePool[newIdx].parent = -1;
		neighbors.push_back(newIdx);
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

		Vector3 waypoint;
		waypoint.x = (float)current.x;
		waypoint.y = current.y;
		waypoint.z = (float)current.z;

		path.push_back(waypoint);
		currentIndex = current.parent;
	}

	std::reverse(path.begin(), path.end());
	return path;
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
			if (obj->m_isEgg) continue;

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

std::vector<Vector3> PathfindingSystem::FindPath(Vector3 start, Vector3 end)
{
	// Instrument A* runtime per call (ms)
	float t0 = GetTime();
	auto path = m_aStar->FindPath(start, end, m_pathfindingGrid.get());
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
		AddConsoleString("WARNING: Could not open object walkability file: " + filename, YELLOW);
		return;
	}

	std::string line;
	while (std::getline(file, line))
	{
		if (line.empty() || line[0] == '#')
		{
			continue;
		}

		std::stringstream ss(line);
		std::string item;
		std::vector<std::string> tokens;
		while (std::getline(ss, item, ','))
		{
			tokens.push_back(item);
		}

		if (tokens.size() >= 3)
		{
			ObjectWalkability ow;
			try {
				ow.shapeID = std::stoi(tokens[0]);
				ow.name = tokens[1];
				ow.walkability = tokens[2];
				ow.stepHeight = 0.0f;
				if (tokens.size() >= 4 && !tokens[3].empty())
				{
					ow.stepHeight = std::stof(tokens[3]);
				}
				m_objectWalkability[ow.shapeID] = ow;
			}
			catch (const std::exception&)
			{
				// Skip malformed lines
			}
		}
	}
	file.close();
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

			// Reset roof info (we don't currently infer roof groups here)
			info.hasRoof = false;
			info.roofGroupID = -1;

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
}
