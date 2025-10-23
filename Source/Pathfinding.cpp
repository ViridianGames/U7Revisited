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
	// Initialize 192x192 grid (all walkable by default)
	m_grid.resize(192, std::vector<bool>(192, true));
}

PathfindingGrid::~PathfindingGrid()
{
}

void PathfindingGrid::BuildFromWorld()
{
	AddConsoleString("Building pathfinding grid from world data...");

	int totalChunks = 0;
	int walkableChunks = 0;

	// Check all 192x192 chunks
	for (int chunkZ = 0; chunkZ < 192; chunkZ++)
	{
		for (int chunkX = 0; chunkX < 192; chunkX++)
		{
			m_grid[chunkZ][chunkX] = CheckChunkWalkable(chunkX, chunkZ);

			totalChunks++;
			if (m_grid[chunkZ][chunkX])
				walkableChunks++;
		}
	}

	AddConsoleString("Pathfinding grid built: " + std::to_string(walkableChunks) + "/" +
	                 std::to_string(totalChunks) + " chunks walkable");
}

void PathfindingGrid::UpdateChunk(int chunkX, int chunkZ)
{
	if (chunkX < 0 || chunkX >= 192 || chunkZ < 0 || chunkZ >= 192)
		return;

	m_grid[chunkZ][chunkX] = CheckChunkWalkable(chunkX, chunkZ);
}

void PathfindingGrid::UpdatePosition(int worldX, int worldZ)
{
	int chunkX = worldX / 16;
	int chunkZ = worldZ / 16;

	// Update this chunk and surrounding chunks
	for (int dz = -1; dz <= 1; dz++)
	{
		for (int dx = -1; dx <= 1; dx++)
		{
			int cx = chunkX + dx;
			int cz = chunkZ + dz;

			if (cx >= 0 && cx < 192 && cz >= 0 && cz < 192)
				UpdateChunk(cx, cz);
		}
	}
}

bool PathfindingGrid::IsChunkWalkable(int chunkX, int chunkZ) const
{
	if (chunkX < 0 || chunkX >= 192 || chunkZ < 0 || chunkZ >= 192)
		return false;

	return m_grid[chunkZ][chunkX];
}

bool PathfindingGrid::IsPositionWalkable(int worldX, int worldZ) const
{
	// Tile-level check
	return CheckTileWalkable(worldX, worldZ);
}

bool PathfindingGrid::CheckChunkWalkable(int chunkX, int chunkZ)
{
	// Sample tiles in this chunk to determine if mostly walkable
	int walkableTiles = 0;
	int totalTiles = 0;

	for (int tz = 0; tz < 16; tz++)
	{
		for (int tx = 0; tx < 16; tx++)
		{
			int worldX = chunkX * 16 + tx;
			int worldZ = chunkZ * 16 + tz;

			// Bounds check
			if (worldX < 0 || worldX >= 3072 || worldZ < 0 || worldZ >= 3072)
				continue;

			totalTiles++;
			if (CheckTileWalkable(worldX, worldZ))
				walkableTiles++;
		}
	}

	// Chunk is walkable if more than 25% of tiles are walkable
	// (Lower threshold needed for interiors with walls/furniture)
	return (totalTiles > 0 && walkableTiles > (totalTiles / 4));
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


	if (shapeID < 1024 && g_objectDataTable[shapeID].m_isNotWalkable)
	{
		// Special case: doors in terrain - check if open
		if (g_objectDataTable[shapeID].m_isDoor)
		{
			// Frame 0 = closed, frame > 0 = open
			if (frameID > 0)
				; // Open door, continue checking objects
			else
				return false;  // Closed door blocks movement
		}
		else
		{
			return false;  // Non-door terrain blocks movement
		}
	}

	// 2. Check objects in chunk (and neighboring chunks for overlaps)
	int chunkX = worldX / 16;
	int chunkZ = worldZ / 16;

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
				if (!obj)
					continue;

				// Skip NPCs (they don't block pathfinding grid, only runtime collision)
				if (obj->m_isNPC)
					continue;

				// Skip objects above ground level (roofs, bridges, etc.) - only check ground level
				// Objects at y > 2.0 are considered "above ground" and don't block movement
				if (obj->m_Pos.y > 2.0f)
					continue;


				// Check if this object blocks movement
				if (obj->m_objectData && obj->m_objectData->m_isNotWalkable)
				{
					// For doors and large objects, use their actual size from ObjectData
					// For most objects, they only occupy 1 tile
					int objWidth = (int)obj->m_objectData->m_width;
					int objDepth = (int)obj->m_objectData->m_depth;

					// Default to 1x1 if size is 0 or invalid
					if (objWidth <= 0) objWidth = 1;
					if (objDepth <= 0) objDepth = 1;

					// Object's base tile position
					int objTileX = (int)floor(obj->m_Pos.x);
					int objTileZ = (int)floor(obj->m_Pos.z);

					// Check if tile overlaps object's footprint
					// Objects extend from their position based on their size
					bool overlaps = (worldX >= objTileX - objWidth + 1 && worldX <= objTileX &&
					                 worldZ >= objTileZ - objDepth + 1 && worldZ <= objTileZ);

					if (overlaps)
					{
						// Special case: Open doors are walkable
						if (obj->m_objectData->m_isDoor)
						{
							// Frame 0 = closed, frame > 0 = open
							if (obj->m_Frame > 0)
								continue;  // Open door, walkable
						}

						// DEBUG: Log what's blocking interior tiles
						static int objDebugCount = 0;
						if (objDebugCount < 5 && worldX > 100 && worldX < 200 && worldZ > 100 && worldZ < 200)
						{
							AddConsoleString("Tile (" + std::to_string(worldX) + "," + std::to_string(worldZ) +
							                 ") blocked by object: " + obj->m_objectData->m_name +
							                 " at (" + std::to_string(objTileX) + "," + std::to_string(objTileZ) + ")" +
							                 " size=" + std::to_string(objWidth) + "x" + std::to_string(objDepth));
							objDebugCount++;
						}

						return false;  // Blocked by object
					}
				}
			}
		}
	}

	return true;  // Nothing blocks this position
}

void PathfindingGrid::DrawDebugOverlay()
{
	// Draw semi-transparent colored quads over each chunk
	// Green = walkable, Red = blocked

	for (int chunkZ = 0; chunkZ < 192; chunkZ++)
	{
		for (int chunkX = 0; chunkX < 192; chunkX++)
		{
			// Convert chunk coordinates to world coordinates
			float worldX = chunkX * 16.0f + 8.0f;  // Center of chunk
			float worldZ = chunkZ * 16.0f + 8.0f;

			// Choose color based on walkability
			Color color = m_grid[chunkZ][chunkX] ?
				Color{0, 255, 0, 64} :   // Green, semi-transparent
				Color{255, 0, 0, 64};     // Red, semi-transparent

			// Draw a flat quad on the ground representing this chunk
			// Each chunk is 16x16 tiles
			Vector3 v1 = {worldX - 8.0f, 0.1f, worldZ - 8.0f};  // Slightly above ground
			Vector3 v2 = {worldX + 8.0f, 0.1f, worldZ - 8.0f};
			Vector3 v3 = {worldX + 8.0f, 0.1f, worldZ + 8.0f};
			Vector3 v4 = {worldX - 8.0f, 0.1f, worldZ + 8.0f};

			// Draw two triangles to form a quad
			DrawTriangle3D(v1, v2, v3, color);
			DrawTriangle3D(v1, v3, v4, color);

			// Optional: Draw chunk boundaries as wireframe
			// DrawLine3D(v1, v2, WHITE);
			// DrawLine3D(v2, v3, WHITE);
			// DrawLine3D(v3, v4, WHITE);
			// DrawLine3D(v4, v1, WHITE);
		}
	}
}

void PathfindingGrid::DrawDebugOverlayTileLevel()
{
	// Draw tile-level walkability using batched meshes (2 draw calls total!)
	extern Camera3D g_camera;

	// Only draw tiles within 40 tiles of camera
	int centerX = (int)g_camera.target.x;
	int centerZ = (int)g_camera.target.z;
	int range = 40;

	// Collect green and red tile positions
	std::vector<Vector3> greenTiles;
	std::vector<Vector3> redTiles;
	greenTiles.reserve(6400);  // Pre-allocate for 80x80 area
	redTiles.reserve(6400);

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
				greenTiles.push_back({(float)worldX, 0.1f, (float)worldZ});
			else
				redTiles.push_back({(float)worldX, 0.1f, (float)worldZ});
		}
	}

	// Draw all green tiles in one call
	rlBegin(RL_TRIANGLES);
	rlColor4ub(0, 255, 0, 128);  // Green, semi-transparent
	for (const auto& pos : greenTiles)
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

	// Draw all red tiles in one call
	rlBegin(RL_TRIANGLES);
	rlColor4ub(255, 0, 0, 128);  // Red, semi-transparent
	for (const auto& pos : redTiles)
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

	// Check objects in surrounding chunks
	int chunkX = worldX / 16;
	int chunkZ = worldZ / 16;
	bool foundBlockingObject = false;

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
						std::string skipReason = "";
						if (obj->m_Pos.y > 2.0f)
							skipReason = " [SKIPPED: above ground y=" + std::to_string(obj->m_Pos.y) + "]";

						std::string msg = std::string("Object ") + (skipReason.empty() ? "BLOCKS" : "found") + ": " + obj->m_objectData->m_name +
						                 " at (" + std::to_string(objTileX) + "," + std::to_string(objTileZ) + ")" +
						                 " size=" + std::to_string(objWidth) + "x" + std::to_string(objDepth) +
						                 (obj->m_objectData->m_isDoor ? std::string(" [DOOR frame=") + std::to_string(obj->m_Frame) + "]" : "") +
						                 skipReason;
						AddConsoleString(msg);

						if (skipReason.empty())
							foundBlockingObject = true;
					}
				}
			}
		}
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

	// Convert world coordinates to chunk coordinates
	int startChunkX = (int)(start.x / 16.0f);
	int startChunkZ = (int)(start.z / 16.0f);
	int goalChunkX = (int)(goal.x / 16.0f);
	int goalChunkZ = (int)(goal.z / 16.0f);

	// Bounds check
	if (startChunkX < 0 || startChunkX >= 192 || startChunkZ < 0 || startChunkZ >= 192 ||
	    goalChunkX < 0 || goalChunkX >= 192 || goalChunkZ < 0 || goalChunkZ >= 192)
	{
		return std::vector<Vector3>();  // Out of bounds
	}

	// Check if start and goal are walkable
	if (!grid->IsChunkWalkable(startChunkX, startChunkZ))
		return std::vector<Vector3>();  // Start not walkable

	if (!grid->IsChunkWalkable(goalChunkX, goalChunkZ))
		return std::vector<Vector3>();  // Goal not walkable

	// Cleanup any previous pathfinding data
	CleanupNodes();

	// Create start node
	PathNode* startNode = new PathNode(startChunkX, startChunkZ);
	startNode->g = 0;
	startNode->h = Heuristic(startChunkX, startChunkZ, goalChunkX, goalChunkZ);
	startNode->f = startNode->g + startNode->h;
	m_allocatedNodes.push_back(startNode);

	// Open and closed sets
	std::vector<PathNode*> openSet;
	std::unordered_map<int, PathNode*> closedSet;  // Key = chunkZ * 192 + chunkX

	openSet.push_back(startNode);

	PathNode* goalNode = nullptr;

	// A* main loop
	while (!openSet.empty())
	{
		// Find node with lowest f cost
		auto minIt = std::min_element(openSet.begin(), openSet.end(),
			[](PathNode* a, PathNode* b) { return a->f < b->f; });

		PathNode* current = *minIt;
		openSet.erase(minIt);

		// Check if we reached the goal
		if (current->x == goalChunkX && current->z == goalChunkZ)
		{
			goalNode = current;
			break;
		}

		// Add to closed set
		int key = current->z * 192 + current->x;
		closedSet[key] = current;

		// Get neighbors
		std::vector<PathNode*> neighbors = GetNeighbors(current, grid);

		for (PathNode* neighbor : neighbors)
		{
			int neighborKey = neighbor->z * 192 + neighbor->x;

			// Skip if in closed set
			if (closedSet.find(neighborKey) != closedSet.end())
			{
				delete neighbor;
				continue;
			}

			// Calculate tentative g cost
			float tentativeG = current->g + 1.0f;  // Assuming uniform cost

			// Check if this path to neighbor is better
			auto openIt = std::find_if(openSet.begin(), openSet.end(),
				[neighbor](PathNode* n) { return n->x == neighbor->x && n->z == neighbor->z; });

			if (openIt == openSet.end())
			{
				// Not in open set, add it
				neighbor->g = tentativeG;
				neighbor->h = Heuristic(neighbor->x, neighbor->z, goalChunkX, goalChunkZ);
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

		// Bounds check
		if (nx < 0 || nx >= 192 || nz < 0 || nz >= 192)
			continue;

		// Walkability check
		if (!grid->IsChunkWalkable(nx, nz))
			continue;

		neighbors.push_back(new PathNode(nx, nz));
	}

	return neighbors;
}

std::vector<Vector3> AStar::ReconstructPath(PathNode* goal)
{
	std::vector<Vector3> path;
	PathNode* current = goal;

	while (current != nullptr)
	{
		// Convert chunk coordinates to world coordinates (center of chunk)
		Vector3 waypoint;
		waypoint.x = current->x * 16.0f + 8.0f;  // Center of chunk
		waypoint.y = 0;
		waypoint.z = current->z * 16.0f + 8.0f;

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
