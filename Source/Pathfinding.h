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
	int x, z;           // World tile coordinates
	float g;            // Cost from start
	float h;            // Heuristic cost to goal
	float f;            // Total cost (g + h)
	PathNode* parent;   // For path reconstruction

	PathNode(int _x, int _z) : x(_x), z(_z), g(0), h(0), f(0), parent(nullptr) {}
};

// ============================================================================
// PathfindingGrid: Tile-level walkability checking
// ============================================================================
class PathfindingGrid
{
public:
	PathfindingGrid();
	~PathfindingGrid();

	// Query walkability
	bool IsPositionWalkable(int worldX, int worldZ) const;  // Check if tile is walkable

	// Debug visualization
	void DrawDebugOverlayTileLevel();                     // Tile-level visualization
	void DebugPrintTileInfo(int worldX, int worldZ);      // Print why a tile is blocked

private:
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
