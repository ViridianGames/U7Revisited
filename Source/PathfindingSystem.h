#ifndef _Pathfinding_H_
#define _Pathfinding_H_

#include <vector>
#include <unordered_map>
#include <queue>
#include <string>
#include <memory>
#include <mutex>
#include "raylib.h"
#include "raymath.h"

#include "Geist/Object.h"

// Forward declarations
class U7Object;

struct ChunkInfo
{
	bool walkable[16][16] = { false };

	bool hasRoof = false;
	int  roofGroupID = -1;          // -1 = no roof / no building

	// Connectivity flags for 8 directions (0 = North, 1 = NE, 2 = E, etc.)
	bool canReach[8] = { false };
};

// Direction constants for readability
enum Dir8
{
	DIR_N  = 0,
	DIR_NE = 1,
	DIR_E  = 2,
	DIR_SE = 3,
	DIR_S  = 4,
	DIR_SW = 5,
	DIR_W  = 6,
	DIR_NW = 7
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
// ChunkNode: Used by chunk-level A* algorithm
// ============================================================================
struct ChunkNode
{
	int x, z;           // Chunk coordinates (0-191)
	float g;            // Cost from start
	float h;            // Heuristic cost to goal
	float f;            // Total cost (g + h)
	ChunkNode* parent;  // For path reconstruction

	ChunkNode(int _x, int _z) : x(_x), z(_z), g(0), h(0), f(0), parent(nullptr) {}
};

class AStar
{
public:
	AStar();
	~AStar();

	// Load terrain movement costs from CSV file
	void LoadTerrainCosts(const std::string& filename);

	// Find path from start to goal (returns waypoints in world coordinates)
	std::vector<Vector3> FindPath(Vector3 start, Vector3 goal, PathfindingGrid* grid, ChunkInfo chunkMap[192][192] = nullptr);

	// Get movement cost for a tile (for debug visualization)
	float GetMovementCost(int worldX, int worldZ, PathfindingGrid* grid);

	// Get terrain name by shape ID (for debug)
	std::string GetTerrainName(int shapeID) const;

	// ===== HIERARCHICAL PATHFINDING =====
	
	// Find chunk-level path using chunk connectivity graph
	// Returns list of chunk coordinates to traverse, or empty if no path
	std::vector<Vector2> FindChunkPath(int startChunkX, int startChunkZ, 
	                                    int goalChunkX, int goalChunkZ,
	                                    ChunkInfo chunkMap[192][192]);
	
	// Find best exit tile from a chunk toward a neighbor chunk
	// direction: 0-7 (DIR_N, DIR_NE, etc.)
	Vector2 FindChunkExitPoint(int chunkX, int chunkZ, int direction, 
	                           PathfindingGrid* grid);
	
	// Find best entry tile into a chunk from a specific direction
	// direction: direction coming FROM (opposite of movement direction)
	Vector2 FindChunkEntryPoint(int chunkX, int chunkZ, int fromDirection,
	                            PathfindingGrid* grid);
	
	// Direct tile-level A* without hierarchical optimization
	std::vector<Vector3> FindPathDirect(Vector3 start, Vector3 goal, PathfindingGrid* grid);

private:
	// Heuristic function (Manhattan distance)
	float Heuristic(int x1, int z1, int x2, int z2);

	// Get walkable neighbors of a node
	std::vector<PathNode*> GetNeighbors(PathNode* node, PathfindingGrid* grid, int goalX, int goalZ);

	// Reconstruct path from goal to start
	std::vector<Vector3> ReconstructPath(PathNode* goal, PathfindingGrid* grid);

	// Cleanup allocated nodes
	void CleanupNodes();

	// Chunk-level pathfinding helpers
	void CleanupChunkNodes();
	std::vector<ChunkNode*> GetChunkNeighbors(ChunkNode* node, ChunkInfo chunkMap[192][192]);
	int GetDirectionToNeighbor(int fromX, int fromZ, int toX, int toZ);

	// Temporary storage for nodes during pathfinding
	std::vector<PathNode*> m_allocatedNodes;
	std::vector<ChunkNode*> m_allocatedChunkNodes;
	// Guard to make FindPath reentrant/thread-safe
	mutable std::mutex m_findMutex;
	// Terrain movement costs (shape ID -> cost multiplier)
	std::unordered_map<int, float> m_terrainCosts;

	// Terrain names (shape ID -> name)
	std::unordered_map<int, std::string> m_terrainNames;
};


class PathfindingSystem : public Object
{
public:
	PathfindingSystem(){};
	~PathfindingSystem(){};

	virtual void Init(const std::string& configfile);
	virtual void Shutdown(){};
	virtual void Update(){};
	void Draw() {};

	std::vector<Vector3> FindPath(Vector3 start, Vector3 goal);

	std::string GetTerrainName(int shapeID) const { return m_aStar->GetTerrainName(shapeID); }

	bool IsPositionWalkable(int worldX, int worldZ) const { return m_pathfindingGrid->IsPositionWalkable(worldX, worldZ); }

	float GetMovementCost(int worldX, int worldZ) { return m_aStar->GetMovementCost(worldX, worldZ, m_pathfindingGrid.get());}

	std::unique_ptr<PathfindingGrid> m_pathfindingGrid;
	std::unique_ptr<AStar> m_aStar;

	ChunkInfo m_chunkInfoMap[192][192];

	//  Since this looks both at the terrain and the objects, it needs to be called
	//  after all loading is finished.
	void PopulateChunkPathfindingGrid();
};

#endif
