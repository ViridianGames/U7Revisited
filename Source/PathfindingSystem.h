#ifndef _Pathfinding_H_
#define _Pathfinding_H_

#include <vector>
#include <unordered_map>
#include <unordered_set>
#include <queue>
#include <string>
#include <memory>
#include <mutex>
#include <deque>
#include "raylib.h"
#include "raymath.h"
#include <cstdint>
#include "Geist/Object.h"
#include <atomic>

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
	bool IsPositionWalkable(int worldX, int worldZ, float agentBaseY) const;  // Check if tile is walkable

	// Debug visualization
	void DrawDebugOverlayTileLevel(float lowerY, float upperY);                  // Tile-level visualization (3D with cost cubes)
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

	// New helper: collect all walkable surface heights (including ground 0.0)
	std::vector<float> GetWalkableSurfaceHeights(int worldX, int worldZ) const;

private:
	// Helper: Check if specific tile is walkable
	bool CheckTileWalkable(int worldX, int worldZ, float agentBaseY) const;

	// Cache for debug visualization
	struct TileWithCost {
		Vector3 pos;
		float cost;
		bool visited;   // visited by A*
		bool onPath;    // on final path
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
	float y;            // Chosen surface height for this node (world Y)
	float g;            // Cost from start
	float h;            // Heuristic cost to goal
	float f;            // Total cost (g + h)
	int parent;         // Index into node pool for parent (-1 = none)

	PathNode(int _x, int _z, float _y = 0.0f) : x(_x), z(_z), y(_y), g(0), h(0), f(0), parent(-1) {}
};

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

	// Debug markers recorded during FindPath()
	// These are public so debug drawing code can query them.
	std::unordered_set<int64_t> m_visitedNodeKeys; // quantized x/z/y keys visited during search
	std::unordered_set<int64_t> m_finalPathKeys;   // quantized keys on the reconstructed final path

	// Clear markers
	void ClearDebugMarkers();

	// Query markers (helpers for debug drawing)
	bool IsNodeVisited(int x, int z, float y) const;
	bool IsNodeOnFinalPath(int x, int z, float y) const;

private:
	// Heuristic function (Manhattan/Octile distance)
	float Heuristic(int x1, int z1, int x2, int z2);

	// Get walkable neighbors of a node: now index-based (returns indices into nodePool)
	std::vector<int> GetNeighbors(int nodeIndex, PathfindingGrid* grid, int goalX, int goalZ,
		std::unordered_map<int, bool>& walkableCache,
		std::unordered_map<int, std::vector<float>>& heightsCache,
		std::vector<PathNode>& nodePool);

	// Reconstruct path from goal index
	std::vector<Vector3> ReconstructPath(int goalIndex, PathfindingGrid* grid, std::vector<PathNode>& nodePool);

	// Cleanup allocated nodes (legacy)
	void CleanupNodes();

	// Temporary storage for nodes during pathfinding (legacy pointer storage not used)
	std::vector<PathNode*> m_allocatedNodes;

	// Terrain movement costs (shape ID -> cost multiplier)
	std::unordered_map<int, float> m_terrainCosts;

	// Terrain names (shape ID -> name)
	std::unordered_map<int, std::string> m_terrainNames;

	// Mutex to make FindPath reentrant/thread-safe
	std::mutex m_findMutex;
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

	// Guard to make FindPath reentrant/thread-safe
	mutable std::mutex m_findMutex;

	std::string GetTerrainName(int shapeID) const { return m_aStar->GetTerrainName(shapeID); }

	bool IsPositionWalkable(int worldX, int worldZ, float agentBaseY) const { return m_pathfindingGrid->IsPositionWalkable(worldX, worldZ, agentBaseY); }

	float GetMovementCost(int worldX, int worldZ) { return m_aStar->GetMovementCost(worldX, worldZ, m_pathfindingGrid.get());}

	std::unique_ptr<PathfindingGrid> m_pathfindingGrid;
	std::unique_ptr<AStar> m_aStar;

	ChunkInfo m_chunkInfoMap[192][192];

	// Simple atomic telemetry counters for A* timing (monotonic totals)
	std::atomic<uint64_t> m_astarTotalCalls{0};
	std::atomic<uint64_t> m_astarTotalMs{0};
	std::atomic<uint64_t> m_astarMaxMs{0};
	// Queue/worker latency instrumentation (collected even if no worker yet)
	std::atomic<uint64_t> m_astarQueueTotalMs{0};
	std::atomic<uint64_t> m_astarQueueCalls{0};

	// Moving-average of per-call A* duration (ms) for realtime telemetry
	// Protected by m_instrumentMutex
	double m_astarEmaMs = 0.0;
	float  m_astarEmaAlpha = 0.10f; // EMA alpha (tunable)
	std::mutex m_instrumentMutex;

	// Record queue latency (ms) for a request that spent time waiting before worker handled it.
	// Call from producer / worker when appropriate.
	void RecordQueueLatency(uint64_t ms);

	//  Since this looks both at the terrain and the objects, it needs to be called
	//  after all loading is finished.
	void PopulateChunkPathfindingGrid();

	// Utility: determine whether a shape id represents a walkable surface (stairs/floors/bridges/etc.)
	// Implemented inline below to keep header-only convenience for callers like U7Player.cpp.
	static bool IsWalkableSurface(int shapeID);
};

#endif
