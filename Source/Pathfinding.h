#ifndef _Pathfinding_H_
#define _Pathfinding_H_

#include <vector>
#include <unordered_map>
#include <queue>
#include "raylib.h"
#include "raymath.h"

// Forward declarations
class U7Object;

// ============================================================================
// PathNode: Used by A* algorithm
// ============================================================================
struct PathNode
{
	int x, z;           // Chunk coordinates
	float g;            // Cost from start
	float h;            // Heuristic cost to goal
	float f;            // Total cost (g + h)
	PathNode* parent;   // For path reconstruction

	PathNode(int _x, int _z) : x(_x), z(_z), g(0), h(0), f(0), parent(nullptr) {}
};

// ============================================================================
// PathfindingGrid: Maintains 192x192 walkability grid
// ============================================================================
class PathfindingGrid
{
public:
	PathfindingGrid();
	~PathfindingGrid();

	// Build/update the walkability grid
	void BuildFromWorld();                          // Initial build from world data
	void UpdateChunk(int chunkX, int chunkZ);      // Rebuild single chunk
	void UpdatePosition(int worldX, int worldZ);   // Update area around world position

	// Query walkability
	bool IsChunkWalkable(int chunkX, int chunkZ) const;
	bool IsPositionWalkable(int worldX, int worldZ) const;  // For tile-level checks

	// Debug visualization
	void DrawDebugOverlay();                              // Chunk-level (fast, less accurate)
	void DrawDebugOverlayTileLevel();                     // Tile-level (slow, shows objects)
	void DebugPrintTileInfo(int worldX, int worldZ);      // Print why a tile is blocked

private:
	std::vector<std::vector<bool>> m_grid;  // 192x192 chunk grid (true = walkable)

	// Helper: Check if a chunk is mostly walkable
	bool CheckChunkWalkable(int chunkX, int chunkZ);

	// Helper: Check if specific tile is walkable
	bool CheckTileWalkable(int worldX, int worldZ) const;
};

// ============================================================================
// AStar: Pathfinding algorithm
// ============================================================================
class AStar
{
public:
	AStar();
	~AStar();

	// Find path from start to goal (returns waypoints in world coordinates)
	std::vector<Vector3> FindPath(Vector3 start, Vector3 goal, PathfindingGrid* grid);

private:
	// Heuristic function (Manhattan distance)
	float Heuristic(int x1, int z1, int x2, int z2);

	// Get walkable neighbors of a node
	std::vector<PathNode*> GetNeighbors(PathNode* node, PathfindingGrid* grid);

	// Reconstruct path from goal to start
	std::vector<Vector3> ReconstructPath(PathNode* goal);

	// Cleanup allocated nodes
	void CleanupNodes();

	// Temporary storage for nodes during pathfinding
	std::vector<PathNode*> m_allocatedNodes;
};

#endif
