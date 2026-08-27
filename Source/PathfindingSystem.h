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

// Material family for roof typing (from roof shape IDs).
// Shapes 161/162 have empty TEXT.FLX names but are thatch in-game (not clay tile).
enum class RoofMaterial : int
{
	None = 0,
	Wood = 1,
	Slate = 2,
	Tile = 3,    // clay / red tile (156, 908, 966, …)
	Thatch = 4,  // shapes 161, 162 (unnamed in TEXT.FLX)
	Other = 5    // greenhouse, broken, wagon, …
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
// ChunkInfo: per-chunk visibility / connectivity (16×16 world chunk)
// ============================================================================
class ChunkInfo
{
public:
	ChunkInfo()
	{
		for (int z = 0; z < 16; ++z)
			for (int x = 0; x < 16; ++x)
				roofGroupTile[x][z] = -1;
	}

	// Building / roof map (filled by PathfindingSystem::BuildChunkBuildingData).
	// interior[][]: under-roof tiles (for future lighting).
	// roofGroupTile[][]: connected-building id per tile (-1 = no roof).
	bool interior[16][16] = { false };
	int  roofGroupTile[16][16];
	bool hasRoof = false;
	int  roofGroupID = -1;
	int  roofTypeID = -1;
	RoofMaterial roofMaterial = RoofMaterial::None;

	// Dungeon map (Exult mountain-top footprints). 0 = not under a mountain;
	// otherwise the mountain ceiling lift (Y) for that tile.
	unsigned char dungeonCeiling[16][16] = {};
	bool hasDungeon = false;

	// Connectivity flags for 8 directions (0 = North, 1 = NE, 2 = E, etc.)
	// True = center→center straight shot to that neighbor is clear.
	bool canReach[8] = { false };

	// Local tile queries (tx/tz in 0..15).
	bool IsInteriorTile(int tx, int tz) const
	{
		if (tx < 0 || tx >= 16 || tz < 0 || tz >= 16) return false;
		return interior[tx][tz];
	}

	int GetRoofGroupAt(int tx, int tz) const
	{
		if (tx < 0 || tx >= 16 || tz < 0 || tz >= 16) return -1;
		return roofGroupTile[tx][tz];
	}

	int GetRoofTypeAt() const { return roofTypeID; }

	RoofMaterial GetRoofMaterial() const { return roofMaterial; }

	int GetDungeonCeilingAt(int tx, int tz) const
	{
		if (tx < 0 || tx >= 16 || tz < 0 || tz >= 16) return -1;
		const unsigned char ceil = dungeonCeiling[tx][tz];
		return ceil == 0 ? -1 : (int)ceil;
	}

	bool IsDungeonTile(int tx, int tz) const
	{
		return GetDungeonCeilingAt(tx, tz) >= 0;
	}
};

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

enum ObjectWalkability
{
	OW_WALKABLE = 0,
	OW_BLOCKING,
	OW_CLIMBABLE,
	OW_DOOR,
	OW_LASTWALKABILITYTYPE
};

// ============================================================================
// PathfindingSystem: ground cost map, live walkability, A*, chunk connectivity/roofs
// ============================================================================
class PathfindingSystem : public Object
{
public:
	static constexpr float kImpassableTerrainCost = 99.0f;
	static constexpr int kWorldSize = 3072;

	struct OverlappingObject {
		U7Object* obj;
		int tileX;
		int tileZ;
		int width;
		int depth;
	};

	struct PathDiag
	{
		bool success = false;
		bool startWalkable = false;
		bool goalWalkable = false;
		bool hitNodeBudget = false;
		int nodesExplored = 0;
		int nodeBudget = 0;
		int manhattan = 0;
		float closestDistToGoal = 1e9f;
		int closestX = 0;
		int closestZ = 0;
		int startX = 0, startZ = 0;
		int goalX = 0, goalZ = 0;
	};

	PathfindingSystem() = default;
	~PathfindingSystem() = default;

	virtual void Init(const std::string& configfile);
	virtual void Shutdown(){};
	virtual void Update(){};
	void Draw() {};

	// --- Pathfinding ---
	// allowHierarchical: false forces flat tile A* (better for short walk-to-use
	// targets when chunk centers sit inside buildings).
	std::vector<Vector3> FindPath(Vector3 start, Vector3 goal, U7Object* agent = nullptr,
		bool allowHierarchical = true);

	bool IsPositionWalkable(int worldX, int worldZ, float agentBaseY, const U7Object* agent = nullptr) const;
	bool EvaluateTileWalkable(int worldX, int worldZ, float agentBaseY, const U7Object* agent = nullptr) const;

	std::string GetTerrainName(int shapeID) const;
	float GetMovementCost(int worldX, int worldZ);

	// Ground cost map: terrain_walkable.csv + tall ground solids (height >= 2, not walkable).
	// cost >= 99 = impassable. Doors / walkable / climbable surfaces / raised objects ignored.
	float GetGroundCost(int worldX, int worldZ) const;
	bool IsGroundTerrainWalkable(int worldX, int worldZ) const;

	// Nearest walkable stand near a (possibly blocked) dest — for path_run_usecode.
	// Returns false if none within maxRadius Chebyshev tiles.
	bool FindNearestWalkableStand(Vector3 nearPos, float preferY, const U7Object* agent,
		Vector3& outStand, int maxRadius = 2) const;

	// object_walkability.csv lookup (not used for ground bake currently; kept for later).
	ObjectWalkability GetObjectWalkability(int shapeID, const U7Object* obj = nullptr) const;

	// Legacy name used by callers; now means ground cost < 99.
	bool GetCachedGroundWalkable(int worldX, int worldZ) const { return IsGroundTerrainWalkable(worldX, worldZ); }

	static bool AreUnitsHostile(const U7Object* agent, const U7Object* other);

	// Overlap / surface helpers (former PathfindingGrid)
	std::vector<OverlappingObject> GetOverlappingObjects(int worldX, int worldZ) const;
	float GetTileHeight(int worldX, int worldZ) const;
	std::vector<float> GetWalkableSurfaceHeights(int worldX, int worldZ) const;
	std::vector<float> GetWalkableSurfaceHeightsFromObjects(
		const std::vector<OverlappingObject>& objects) const;

	// Debug visualization
	void DrawDebugOverlayTileLevel(float lowerY, float upperY);
	void InvalidateDebugTileCache() { m_lastCameraCenterX = -9999; m_lastCameraCenterZ = -9999; }
	void DebugPrintTileInfo(int worldX, int worldZ);

	// Build / refresh pathfinding + chunk building data (after world load).
	void BuildChunkBuildingData();
	void PopulateChunkPathfindingGrid();

	void UpdateBuildingRoofVisibility(float avatarWorldX, float avatarWorldZ, float avatarWorldY);

	// World-coord wrappers → ChunkInfo local queries
	bool IsInteriorTile(int worldX, int worldZ) const;
	int GetRoofGroupAt(int worldX, int worldZ) const;
	int GetRoofTypeAt(int worldX, int worldZ) const;
	const ChunkInfo* GetChunkInfo(int chunkX, int chunkZ) const;

	int GetDungeonCeilingAt(int worldX, int worldZ) const;
	bool IsDungeonTile(int worldX, int worldZ) const;

	static bool IsRoofShape(int shapeId);
	static RoofMaterial GetRoofMaterial(int shapeId);
	static bool IsMountainTopShape(int shapeId);

	ChunkInfo m_chunkInfoMap[192][192];

	// True after ground cost map is filled.
	bool m_groundCostValid = false;
	bool m_walkableCacheValid = false; // alias kept for older call sites; mirrors m_groundCostValid

	// A* debug / diagnostics (former AStar public state)
	std::unordered_set<int64_t> m_visitedNodeKeys;
	std::unordered_set<int64_t> m_finalPathKeys;
	PathDiag m_lastPathDiag;
	std::unordered_set<int64_t> CopyVisitedKeys();
	void ClearDebugMarkers();
	bool IsNodeVisited(int x, int z, float y) const;
	bool IsNodeOnFinalPath(int x, int z, float y) const;

	// F10: freeze A* visited graph for a selected NPC after a failed path.
	void FreezeFailedSearchGraph(int objectId);
	void FreezeFailedSearchGraph(int objectId, const std::unordered_set<int64_t>& keys,
		int startX = -1, int startZ = -1, int goalX = -1, int goalZ = -1,
		int closestX = -1, int closestZ = -1);
	void ClearFrozenSearchGraph();
	bool HasFrozenSearchGraph() const { return !m_frozenSearchVisited.empty(); }
	int GetFrozenSearchObjectId() const { return m_frozenSearchObjectId; }
	const std::vector<Vector3>& GetFrozenSearchVisited() const { return m_frozenSearchVisited; }
	bool HasFrozenSearchMarkers() const { return m_frozenSearchHasMarkers; }
	Vector3 GetFrozenSearchStart() const { return m_frozenSearchStart; }
	Vector3 GetFrozenSearchGoal() const { return m_frozenSearchGoal; }
	Vector3 GetFrozenSearchClosest() const { return m_frozenSearchClosest; }

	std::vector<Vector3> m_frozenSearchVisited;
	int m_frozenSearchObjectId = -1;
	bool m_frozenSearchHasMarkers = false;
	Vector3 m_frozenSearchStart = { 0, 0, 0 };
	Vector3 m_frozenSearchGoal = { 0, 0, 0 };
	Vector3 m_frozenSearchClosest = { 0, 0, 0 };

	int m_roofGroupCount = 0;
	int m_roofTypeCount = 0;

	std::unordered_map<int, ObjectWalkability> m_objectWalkability;
	void LoadObjectWalkability(const std::string& filename);

	std::atomic<uint64_t> m_astarTotalCalls{0};
	std::atomic<uint64_t> m_astarTotalMs{0};
	std::atomic<uint64_t> m_astarMaxMs{0};
	std::atomic<uint64_t> m_astarQueueTotalMs{0};
	std::atomic<uint64_t> m_astarQueueCalls{0};

	double m_astarEmaMs = 0.0;
	float  m_astarEmaAlpha = 0.10f;
	std::mutex m_instrumentMutex;

	void RecordQueueLatency(uint64_t ms);

	static bool IsWalkableSurface(int shapeID);
	static bool IsPassThroughObject(int shapeID);
	static bool IsNonBlockingWalkSurface(int shapeID);
	static bool IsStandableObjectTop(const U7Object* obj);
	static float GetObjectSurfaceY(const U7Object* obj);
	static bool ValidateMove(U7Object* agent, const Vector3& desiredPos, float& outDestH);

	// Guard for FindPath / visited snapshot
	mutable std::mutex m_findMutex;

private:
	void LoadTerrainCosts(const std::string& filename);
	void PopulateGroundCostMap();
	void BakeBlockingObjectsIntoGroundCost();

	bool CheckTileWalkable(int worldX, int worldZ, float agentBaseY, const U7Object* agent = nullptr) const;

	float Heuristic(int x1, int z1, int x2, int z2);
	std::vector<int> GetNeighbors(int nodeIndex, int goalX, int goalZ,
		std::unordered_map<int64_t, bool>& walkableCache,
		std::unordered_map<int, std::vector<float>>& heightsCache,
		std::vector<PathNode>& nodePool,
		const std::unordered_map<int64_t, int>* closedSet = nullptr,
		const std::unordered_map<int64_t, int>* openSetLookup = nullptr,
		const U7Object* agent = nullptr,
		float floorBandMin = -1e9f,
		float floorBandMax = 1e9f);

	std::vector<Vector3> ReconstructPath(int goalIndex, std::vector<PathNode>& nodePool);
	std::vector<Vector3> SmoothPath(const std::vector<Vector3>& path, const U7Object* agent);
	std::vector<Vector3> FindPathInternal(Vector3 start, Vector3 goal, const U7Object* agent,
		bool allowHierarchical = true);

	void CleanupNodes();

	// Ground terrain costs: m_groundCost[z][x], size 3072×3072. 99 = impassable.
	std::vector<std::vector<float>> m_groundCost;

	std::unordered_map<int, float> m_terrainCosts;
	std::unordered_map<int, std::string> m_terrainNames;

	std::vector<PathNode*> m_allocatedNodes;

	// Debug overlay cache
	struct TileWithCost {
		Vector3 pos;
		float cost;
		bool visited;
		bool onPath;
	};
	mutable std::vector<TileWithCost> m_cachedGreenTiles;
	mutable std::vector<Vector3> m_cachedRedTiles;
	mutable std::vector<Vector3> m_cachedBlueTiles;
	mutable int m_lastCameraCenterX = -9999;
	mutable int m_lastCameraCenterZ = -9999;
};

#endif
