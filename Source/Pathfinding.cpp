#include "Pathfinding.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "rlgl.h"
#include <algorithm>
#include <cmath>
#include <fstream>
#include <sstream>

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

bool PathfindingGrid::IsPositionWalkable(int worldX, int worldZ) const
{
	// Tile-level check
	return CheckTileWalkable(worldX, worldZ);
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

				if (obj->m_objectData && obj->m_objectData->m_isNotWalkable)
				{
					int objWidth = (int)obj->m_objectData->m_width;
					int objDepth = (int)obj->m_objectData->m_depth;
					if (objWidth <= 0) objWidth = 1;
					if (objDepth <= 0) objDepth = 1;

					int objTileX = (int)floor(obj->m_Pos.x);
					int objTileZ = (int)floor(obj->m_Pos.z);

					bool overlaps = (worldX >= objTileX - objWidth + 1 && worldX <= objTileX &&
					                 worldZ >= objTileZ - objDepth + 1 && worldZ <= objTileZ);

					if (overlaps)
					{
						OverlappingObject ovObj;
						ovObj.obj = obj;
						ovObj.tileX = objTileX;
						ovObj.tileZ = objTileZ;
						ovObj.width = objWidth;
						ovObj.depth = objDepth;
						result.push_back(ovObj);
					}
				}
			}
		}
	}

	return result;
}

bool PathfindingGrid::CheckTileWalkable(int worldX, int worldZ) const
{
	// Bounds check
	if (worldX < 0 || worldX >= 3072 || worldZ < 0 || worldZ >= 3072)
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

		// Skip objects above ground level (roofs, bridges, etc.) - only check ground level
		// Note: Doors are checked above BEFORE this check
		if (obj->m_Pos.y > 2.0f)
			continue;

		// If we already found a door, ignore other blocking objects
		if (hasDoor)
			continue;

		return false;  // Blocked by non-door object
	}

	// Final check: if terrain blocks and no door cleared it, return false
	if (terrainBlocks)
		return false;

	return true;  // Nothing blocks this position
}

void PathfindingGrid::DrawDebugOverlayTileLevel()
{
	// Draw tile-level walkability using batched meshes (2 draw calls total!)
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

				// Check if this specific tile is walkable
				bool walkable = CheckTileWalkable(worldX, worldZ);

				if (walkable)
				{
					float cost = g_aStar ? g_aStar->GetMovementCost(worldX, worldZ, this) : 1.0f;
					m_cachedGreenTiles.push_back({{(float)worldX, 0.1f, (float)worldZ}, cost});
				}
				else
				{
					m_cachedRedTiles.push_back({(float)worldX, 0.1f, (float)worldZ});
				}
			}
		}

		// Update cached camera position
		m_lastCameraCenterX = centerX;
		m_lastCameraCenterZ = centerZ;
	}

	// Draw all green tiles with color-coded costs (using cached data)
	rlBegin(RL_TRIANGLES);
	for (const auto& tile : m_cachedGreenTiles)
	{
		// Color code by cost: 0.5=cyan, 1.0=green, 1.5=yellow, 2.0=orange, 3.0+=red
		Color costColor;
		if (tile.cost < 0.75f)
			costColor = Color{0, 255, 255, 128};  // Cyan - Carpet (0.5)
		else if (tile.cost < 1.25f)
			costColor = Color{0, 255, 0, 128};    // Green - Normal (1.0)
		else if (tile.cost < 1.75f)
			costColor = Color{255, 255, 0, 128};  // Yellow - Door or easy terrain (1.5)
		else if (tile.cost < 2.5f)
			costColor = Color{255, 165, 0, 128};  // Orange - Harder terrain (2.0)
		else
			costColor = Color{255, 100, 100, 128}; // Light red - Difficult terrain (3.0+)

		rlColor4ub(costColor.r, costColor.g, costColor.b, costColor.a);

		// Two triangles forming a 1x1 quad
		Vector3 v1 = {tile.pos.x, tile.pos.y, tile.pos.z};
		Vector3 v2 = {tile.pos.x + 1.0f, tile.pos.y, tile.pos.z};
		Vector3 v3 = {tile.pos.x + 1.0f, tile.pos.y, tile.pos.z + 1.0f};
		Vector3 v4 = {tile.pos.x, tile.pos.y, tile.pos.z + 1.0f};

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
		// Two triangles forming a 1x1 quad
		Vector3 v1 = {pos.x, pos.y, pos.z};
		Vector3 v2 = {pos.x + 1.0f, pos.y, pos.z};
		Vector3 v3 = {pos.x + 1.0f, pos.y, pos.z + 1.0f};
		Vector3 v4 = {pos.x, pos.y, pos.z + 1.0f};

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

	// Draw blue tiles for NPC waypoints (third draw call - only when NPC selected)
	if (!m_cachedBlueTiles.empty())
	{
		rlBegin(RL_TRIANGLES);
		rlColor4ub(0, 0, 255, 192);  // Blue, more opaque than red/green
		for (const auto& pos : m_cachedBlueTiles)
		{
			// Two triangles forming a 1x1 quad
			Vector3 v1 = {pos.x, pos.y, pos.z};
			Vector3 v2 = {pos.x + 1.0f, pos.y, pos.z};
			Vector3 v3 = {pos.x + 1.0f, pos.y, pos.z + 1.0f};
			Vector3 v4 = {pos.x, pos.y, pos.z + 1.0f};

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
}

void PathfindingGrid::SetDebugWaypoints(const std::vector<Vector3>& waypoints)
{
	m_cachedBlueTiles.clear();
	m_cachedBlueTiles.reserve(waypoints.size());

	for (const auto& wp : waypoints)
	{
		// Convert waypoint position to tile coordinates
		int tileX = (int)wp.x;
		int tileZ = (int)wp.z;

		// Add to blue tiles cache
		m_cachedBlueTiles.push_back({(float)tileX, 0.15f, (float)tileZ});  // Slightly higher than red/green
	}
}

void PathfindingGrid::DebugPrintTileInfo(int worldX, int worldZ)
{
	AddConsoleString("=== Debug Tile (" + std::to_string(worldX) + ", " + std::to_string(worldZ) + ") ===");

	// Check terrain
	unsigned short shapeframe = g_World[worldZ][worldX];
	int shapeID = shapeframe & 0x3ff;
	int frameID = (shapeframe >> 10) & 0x3f;

	AddConsoleString("Terrain: shape=" + std::to_string(shapeID) +
	                 " frame=" + std::to_string(frameID) +
	                 " name=" + g_objectDataTable[shapeID].m_name);

	if (shapeID < 1024 && g_objectDataTable[shapeID].m_isNotWalkable)
	{
		if (g_objectDataTable[shapeID].m_isDoor)
		{
			AddConsoleString("  -> Terrain is DOOR, frame=" + std::to_string(frameID) +
			                 (frameID > 0 ? " (OPEN)" : " (CLOSED)"));
		}
		else
		{
			AddConsoleString("  -> Terrain is NOT WALKABLE");
		}
	}
	else
	{
		AddConsoleString("  -> Terrain is walkable");
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
		AddConsoleString(msg);

		if (skipReason.empty())
			foundBlockingObject = true;
	}

	if (!foundBlockingObject)
	{
		AddConsoleString("No blocking objects found");
	}

	// Final verdict
	bool walkable = CheckTileWalkable(worldX, worldZ);
	AddConsoleString("RESULT: " + std::string(walkable ? "WALKABLE" : "BLOCKED"));
}

// ============================================================================
// AStar Implementation
// ============================================================================

AStar::AStar()
{
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

std::vector<Vector3> AStar::FindPath(Vector3 start, Vector3 goal, PathfindingGrid* grid)
{
	if (!grid)
		return std::vector<Vector3>();  // No grid, can't pathfind

	// Use tile coordinates directly
	int startX = (int)start.x;
	int startZ = (int)start.z;
	int goalX = (int)goal.x;
	int goalZ = (int)goal.z;

	// Debug: Uncomment to see all pathfinding attempts
	//AddConsoleString("A* pathfinding: Start tile (" + std::to_string(startX) + "," + std::to_string(startZ) +
	//                 ") Goal tile (" + std::to_string(goalX) + "," + std::to_string(goalZ) + ")");

	// Bounds check
	if (startX < 0 || startX >= 3072 || startZ < 0 || startZ >= 3072 ||
	    goalX < 0 || goalX >= 3072 || goalZ < 0 || goalZ >= 3072)
	{
		AddConsoleString("  FAILED: Out of bounds!", RED);
		return std::vector<Vector3>();  // Out of bounds
	}

	// Note: We don't check if start/goal are walkable - NPCs can spawn on blocked tiles
	// (like sitting on chairs) and destinations might be blocked objects (like altars).
	// Pathfinding will work around obstacles to get as close as possible.

	// Limit search distance to avoid searching entire map (performance)
	int maxDistance = 500;  // Max 500 tiles (enough for cross-map NPC schedules)
	int distance = abs(goalX - startX) + abs(goalZ - startZ);
	if (distance > maxDistance)
	{
		AddConsoleString("  FAILED: Distance too far (" + std::to_string(distance) + " tiles, max " + std::to_string(maxDistance) + ")", RED);
		return std::vector<Vector3>();
	}

	// Cleanup any previous pathfinding data
	CleanupNodes();

	// Create start node
	PathNode* startNode = new PathNode(startX, startZ);
	startNode->g = 0;
	startNode->h = Heuristic(startX, startZ, goalX, goalZ);
	startNode->f = startNode->g + startNode->h;
	m_allocatedNodes.push_back(startNode);

	// Priority queue comparator (max heap by default, so invert comparison for min heap)
	auto cmp = [](PathNode* a, PathNode* b) { return a->f > b->f; };
	std::priority_queue<PathNode*, std::vector<PathNode*>, decltype(cmp)> openSet(cmp);
	std::unordered_map<int, PathNode*> openSetLookup;  // For fast membership checks
	std::unordered_map<int, PathNode*> closedSet;  // Key = tileZ * 3072 + tileX

	int startKey = startZ * 3072 + startX;
	openSet.push(startNode);
	openSetLookup[startKey] = startNode;

	PathNode* goalNode = nullptr;
	int nodesExplored = 0;
	const int maxNodesToExplore = 40000;  // Limit iterations for performance

	// A* main loop
	while (!openSet.empty() && nodesExplored < maxNodesToExplore)
	{
		nodesExplored++;

		// Get node with lowest f cost (top of priority queue)
		PathNode* current = openSet.top();
		openSet.pop();

		int currentKey = current->z * 3072 + current->x;

		// Skip if this node is outdated (a better version was already added to queue)
		auto lookupIt = openSetLookup.find(currentKey);
		if (lookupIt != openSetLookup.end() && lookupIt->second != current)
		{
			// This is an outdated duplicate, skip it
			continue;
		}

		openSetLookup.erase(currentKey);

		// Check if we reached the goal
		if (current->x == goalX && current->z == goalZ)
		{
			goalNode = current;
#ifdef DEBUG_NPC_PATHFINDING
			// Track maximum nodes used
			static int maxNodesUsed = 0;
			if (nodesExplored > maxNodesUsed)
			{
				maxNodesUsed = nodesExplored;
				AddConsoleString("  NEW MAX: Path found using " + std::to_string(nodesExplored) + " nodes", GREEN);
			}
#endif
			break;
		}

		// Add to closed set
		int key = current->z * 3072 + current->x;
		closedSet[key] = current;

		// Get neighbors
		std::vector<PathNode*> neighbors = GetNeighbors(current, grid, goalX, goalZ);

		for (PathNode* neighbor : neighbors)
		{
			int neighborKey = neighbor->z * 3072 + neighbor->x;

			// Skip if in closed set
			if (closedSet.find(neighborKey) != closedSet.end())
			{
				delete neighbor;
				continue;
			}

			// Calculate tentative g cost
			float moveCost = GetMovementCost(neighbor->x, neighbor->z, grid);
			float tentativeG = current->g + moveCost;

			// Check if neighbor is in open set
			auto openIt = openSetLookup.find(neighborKey);

			if (openIt == openSetLookup.end())
			{
				// Not in open set, add it
				neighbor->g = tentativeG;
				neighbor->h = Heuristic(neighbor->x, neighbor->z, goalX, goalZ);
				neighbor->f = neighbor->g + neighbor->h;
				neighbor->parent = current;
				openSet.push(neighbor);
				openSetLookup[neighborKey] = neighbor;
				m_allocatedNodes.push_back(neighbor);
			}
			else
			{
				// Already in open set - check if this path is better
				PathNode* existingNode = openIt->second;
				if (tentativeG < existingNode->g)
				{
					// This path is better - add new node with better cost to queue
					// The old node will be skipped when popped (outdated duplicate check)
					neighbor->g = tentativeG;
					neighbor->h = Heuristic(neighbor->x, neighbor->z, goalX, goalZ);
					neighbor->f = neighbor->g + neighbor->h;
					neighbor->parent = current;
					openSet.push(neighbor);
					openSetLookup[neighborKey] = neighbor;  // Update lookup to point to new better node
					m_allocatedNodes.push_back(neighbor);
				}
				else
				{
					delete neighbor;  // This path is not better
				}
			}
		}
	}

	// If we didn't find the exact goal, try fallback to closest point
	if (goalNode == nullptr)
	{
		// Find the closest explored node to the goal
		PathNode* furthest = nullptr;
		float minDist = 9999999.0f;
		for (const auto& pair : closedSet)
		{
			PathNode* node = pair.second;
			float dist = sqrtf((float)((node->x - goalX) * (node->x - goalX) + (node->z - goalZ) * (node->z - goalZ)));
			if (dist < minDist)
			{
				minDist = dist;
				furthest = node;
			}
		}

		if (furthest && minDist < 150.0f)  // Only use fallback if reasonably close
		{
			// Debug: Uncomment to see fallback behavior
			//AddConsoleString("  Using closest reachable point: (" + std::to_string(furthest->x) + "," + std::to_string(furthest->z) +
			//                 ") distance from goal: " + std::to_string((int)minDist) + " tiles", GREEN);
			goalNode = furthest;  // Use this as the goal instead
		}
		else
		{
			// Debug diagnostics for failed search
			if (nodesExplored >= maxNodesToExplore)
			{
				AddConsoleString("  FAILED: Search limit reached (" + std::to_string(maxNodesToExplore) + " nodes)", RED);
			}

#ifdef DEBUG_NPC_PATHFINDING
			// Diagnostic info
			AddConsoleString("  DEBUG: Start=(" + std::to_string(startX) + "," + std::to_string(startZ) +
			                 ") Goal=(" + std::to_string(goalX) + "," + std::to_string(goalZ) + ")", YELLOW);
			AddConsoleString("  DEBUG: Open set size=" + std::to_string(openSetLookup.size()) +
			                 ", Closed set size=" + std::to_string(closedSet.size()), YELLOW);

			if (furthest)
			{
				AddConsoleString("  DEBUG: Closest explored node to goal: (" + std::to_string(furthest->x) +
				                 "," + std::to_string(furthest->z) + ") distance=" +
				                 std::to_string((int)minDist) + " tiles", YELLOW);
			}

			// Check if goal is still walkable
			bool goalStillWalkable = grid->IsPositionWalkable(goalX, goalZ);
			AddConsoleString("  DEBUG: Goal walkable check: " + std::string(goalStillWalkable ? "YES" : "NO"),
			                 goalStillWalkable ? GREEN : RED);
#endif

			AddConsoleString("  FAILED: No reachable point found near goal", RED);
		}
	}

	// Reconstruct path
	std::vector<Vector3> path;
	if (goalNode != nullptr)
	{
		path = ReconstructPath(goalNode);
	}

	return path;
}

float AStar::Heuristic(int x1, int z1, int x2, int z2)
{
	// Manhattan distance (admissible heuristic for 4-directional movement)
	// This guarantees optimal paths
	return (float)(abs(x2 - x1) + abs(z2 - z1));
}

std::vector<PathNode*> AStar::GetNeighbors(PathNode* node, PathfindingGrid* grid, int goalX, int goalZ)
{
	std::vector<PathNode*> neighbors;

	// 4-directional neighbors (N, S, E, W)
	int directions[4][2] = {
		{0, -1},  // North
		{0, 1},   // South
		{1, 0},   // East
		{-1, 0}   // West
	};

	for (int i = 0; i < 4; i++)
	{
		int nx = node->x + directions[i][0];
		int nz = node->z + directions[i][1];

		// Bounds check (tile coordinates: 3072x3072)
		if (nx < 0 || nx >= 3072 || nz < 0 || nz >= 3072)
			continue;

		// Allow goal tile even if not walkable (NPCs may need to reach blocked destinations like altars)
		bool isGoal = (nx == goalX && nz == goalZ);

		// Walkability check (tile-level) - skip for goal tile
		if (!isGoal && !grid->IsPositionWalkable(nx, nz))
			continue;

		neighbors.push_back(new PathNode(nx, nz));
	}

	return neighbors;
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

std::vector<Vector3> AStar::ReconstructPath(PathNode* goal)
{
	std::vector<Vector3> path;
	PathNode* current = goal;

	while (current != nullptr)
	{
		// Use tile coordinates directly
		Vector3 waypoint;
		waypoint.x = (float)current->x;
		waypoint.y = 0;
		waypoint.z = (float)current->z;

		path.push_back(waypoint);
		current = current->parent;
	}

	// Reverse path (currently goal -> start, we want start -> goal)
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
