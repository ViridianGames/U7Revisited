#ifndef _Pathfinding_H_
#define _Pathfinding_H_

#include <vector>
#include <unordered_map>
#include <queue>
#include <string>
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
	void DrawDebugOverlayTileLevel();                     // Tile-level visualization (3D with cost cubes)
	void DebugPrintTileInfo(int worldX, int worldZ);      // Print why a tile is blocked

	// Helper: Get all objects that overlap a tile (used by pathfinding and door opening)
	struct OverlappingObject {
		U7Object* obj;
		int tileX;
		int tileZ;
		int width;
		int depth;
	};
	std::vector<OverlappingObject> GetOverlappingObjects(int worldX, int worldZ) const;

	// Get the effective walkable height at a tile (obj.y + obj.height if object present, else 0.0)
	float GetTileHeight(int worldX, int worldZ) const;

private:
	// Helper: Check if specific tile is walkable
	bool CheckTileWalkable(int worldX, int worldZ) const;

	// Cache for debug visualization
	struct TileWithCost {
		Vector3 pos;
		float cost;
	};
	mutable std::vector<TileWithCost> m_cachedGreenTiles;
	mutable std::vector<Vector3> m_cachedRedTiles;
	mutable std::vector<Vector3> m_cachedBlueTiles;  // NPC waypoints
	mutable int m_lastCameraCenterX = -9999;
	mutable int m_lastCameraCenterZ = -9999;
};

// ============================================================================
// AStar: Pathfinding algorithm
// ============================================================================
class AStar
{
public:
	AStar();
	~AStar();

	// Load terrain movement costs from CSV file
	void LoadTerrainCosts(const std::string& filename);

	// Find path from start to goal (returns waypoints in world coordinates)
	std::vector<Vector3> FindPath(Vector3 start, Vector3 goal, PathfindingGrid* grid);

	// Get movement cost for a tile (for debug visualization)
	float GetMovementCost(int worldX, int worldZ, PathfindingGrid* grid);

	// Get terrain name by shape ID (for debug)
	std::string GetTerrainName(int shapeID) const;

private:
	// Heuristic function (Manhattan distance)
	float Heuristic(int x1, int z1, int x2, int z2);

	// Get walkable neighbors of a node
	std::vector<PathNode*> GetNeighbors(PathNode* node, PathfindingGrid* grid, int goalX, int goalZ);

	// Reconstruct path from goal to start
	std::vector<Vector3> ReconstructPath(PathNode* goal, PathfindingGrid* grid);

	// Cleanup allocated nodes
	void CleanupNodes();

	// Temporary storage for nodes during pathfinding
	std::vector<PathNode*> m_allocatedNodes;

	// Terrain movement costs (shape ID -> cost multiplier)
	std::unordered_map<int, float> m_terrainCosts;

	// Terrain names (shape ID -> name)
	std::unordered_map<int, std::string> m_terrainNames;
};

#endif
