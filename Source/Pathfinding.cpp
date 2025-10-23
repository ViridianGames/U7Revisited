#include "Pathfinding.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "rlgl.h"
#include <algorithm>
#include <cmath>

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
					m_cachedGreenTiles.push_back({(float)worldX, 0.1f, (float)worldZ});
				else
					m_cachedRedTiles.push_back({(float)worldX, 0.1f, (float)worldZ});
			}
		}

		// Update cached camera position
		m_lastCameraCenterX = centerX;
		m_lastCameraCenterZ = centerZ;
	}

	// Draw all green tiles in one call (using cached data)
	rlBegin(RL_TRIANGLES);
	rlColor4ub(0, 255, 0, 128);  // Green, semi-transparent
	for (const auto& pos : m_cachedGreenTiles)
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

	// Check if start and goal are walkable
	if (!grid->IsPositionWalkable(startX, startZ))
	{
		AddConsoleString("  FAILED: Start tile not walkable!", RED);
		grid->DebugPrintTileInfo(startX, startZ);
		return std::vector<Vector3>();  // Start not walkable
	}

	if (!grid->IsPositionWalkable(goalX, goalZ))
	{
		AddConsoleString("  FAILED: Goal tile not walkable!", RED);
		// Debug: Print why goal is blocked
		grid->DebugPrintTileInfo(goalX, goalZ);
		return std::vector<Vector3>();  // Goal not walkable
	}

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

	// Open and closed sets
	std::vector<PathNode*> openSet;
	std::unordered_map<int, PathNode*> closedSet;  // Key = tileZ * 3072 + tileX

	openSet.push_back(startNode);

	PathNode* goalNode = nullptr;
	int nodesExplored = 0;
	const int maxNodesToExplore = 10000;  // Limit iterations for performance

	// A* main loop
	while (!openSet.empty() && nodesExplored < maxNodesToExplore)
	{
		nodesExplored++;

		// Find node with lowest f cost
		auto minIt = std::min_element(openSet.begin(), openSet.end(),
			[](PathNode* a, PathNode* b) { return a->f < b->f; });

		PathNode* current = *minIt;
		openSet.erase(minIt);

		// Check if we reached the goal
		if (current->x == goalX && current->z == goalZ)
		{
			goalNode = current;
			// Debug: Uncomment to see successful paths
			//AddConsoleString("  Path found! Explored " + std::to_string(nodesExplored) + " nodes", GREEN);
			break;
		}

		// Add to closed set
		int key = current->z * 3072 + current->x;
		closedSet[key] = current;

		// Get neighbors
		std::vector<PathNode*> neighbors = GetNeighbors(current, grid);

		for (PathNode* neighbor : neighbors)
		{
			int neighborKey = neighbor->z * 3072 + neighbor->x;

			// Skip if in closed set
			if (closedSet.find(neighborKey) != closedSet.end())
			{
				delete neighbor;
				continue;
			}

			// Calculate tentative g cost (higher cost for closed doors)
			float moveCost = GetMovementCost(neighbor->x, neighbor->z, grid);
			float tentativeG = current->g + moveCost;

			// Check if this path to neighbor is better
			auto openIt = std::find_if(openSet.begin(), openSet.end(),
				[neighbor](PathNode* n) { return n->x == neighbor->x && n->z == neighbor->z; });

			if (openIt == openSet.end())
			{
				// Not in open set, add it
				neighbor->g = tentativeG;
				neighbor->h = Heuristic(neighbor->x, neighbor->z, goalX, goalZ);
				neighbor->f = neighbor->g + neighbor->h;
				neighbor->parent = current;
				openSet.push_back(neighbor);
				m_allocatedNodes.push_back(neighbor);
			}
			else
			{
				// Already in open set
				if (tentativeG < (*openIt)->g)
				{
					// This path is better
					(*openIt)->g = tentativeG;
					(*openIt)->f = (*openIt)->g + (*openIt)->h;
					(*openIt)->parent = current;
				}
				delete neighbor;  // Don't need the duplicate
			}
		}
	}

	if (nodesExplored >= maxNodesToExplore)
	{
		AddConsoleString("  FAILED: Search limit reached (" + std::to_string(maxNodesToExplore) + " nodes)", RED);
	}
	else if (goalNode == nullptr)
	{
		// Debug: Uncomment to see fallback behavior
		//AddConsoleString("  No path to exact goal (explored " + std::to_string(nodesExplored) + " nodes)", YELLOW);

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

		if (furthest && minDist < 100.0f)  // Only use fallback if reasonably close
		{
			// Debug: Uncomment to see fallback behavior
			//AddConsoleString("  Using closest reachable point: (" + std::to_string(furthest->x) + "," + std::to_string(furthest->z) +
			//                 ") distance from goal: " + std::to_string((int)minDist) + " tiles", GREEN);
			goalNode = furthest;  // Use this as the goal instead
		}
		else
		{
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
	// Manhattan distance
	return (float)(abs(x2 - x1) + abs(z2 - z1));
}

std::vector<PathNode*> AStar::GetNeighbors(PathNode* node, PathfindingGrid* grid)
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

		// Walkability check (tile-level)
		if (!grid->IsPositionWalkable(nx, nz))
			continue;

		neighbors.push_back(new PathNode(nx, nz));
	}

	return neighbors;
}

float AStar::GetMovementCost(int worldX, int worldZ, PathfindingGrid* grid)
{
	// Check if this tile has a door
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
					// Door tiles have slightly higher cost to prefer non-door routes
					// but still allow pathfinding through doors when necessary
					return 2.0f;
				}
			}
		}
	}

	return 1.0f;  // Normal tile costs 1
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
