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

				if (obj->m_isContained)
					continue;

				// Use object's world-space bounding box to determine tile overlap.
				const BoundingBox& bbox = obj->m_boundingBox;

				// Convert bbox to tile extents (floor to include partial coverage)
				int minTileX = (int)floor(bbox.min.x);
				int maxTileX = (int)floor(bbox.max.x);
				int minTileZ = (int)floor(bbox.min.z);
				int maxTileZ = (int)floor(bbox.max.z);

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
static bool IsWalkableSurface(int shapeID)
{
	// Bridge/floor pieces: 367-370
	if (shapeID >= 367 && shapeID <= 370)
		return true;

	// Additional floor shapes
	if (shapeID == 1014)
		return true;

	// Stairs: 426-430
	if (shapeID >= 426 && shapeID <= 430)
		return true;

	if (shapeID == 150)
		return true;

	if (shapeID == 193)
		return true;

	if (shapeID == 192)
		return true;

	if (shapeID == 973 || shapeID == 974)
		return true;


	if (shapeID >= 385 && shapeID <= 387)
		return true;

	// TODO: Add more walkable surface shape IDs as we discover them
	// This might include stairs, platforms, etc.

	return false;
}

float PathfindingGrid::GetTileHeight(int worldX, int worldZ) const
{
	// Bounds check
	if (worldX < 0 || worldX >= 3072 || worldZ < 0 || worldZ >= 3072)
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

		int shapeID = obj->m_shapeData->GetShape();

		// Skip very high objects (upper floors)
		// This filters out second story floors while keeping tall bridges
		if (obj->m_Pos.y >= MAX_WALKABLE_SURFACE_HEIGHT)
			continue;

		// Check if this is a known walkable surface
		if (IsWalkableSurface(shapeID))
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

		// If we already found a door, ignore other blocking objects
		if (hasDoor)
			continue;

		// Check if this is a walkable surface (floor, bridge, stairs)
		if (obj->m_shapeData)
		{
			int shapeID = obj->m_shapeData->GetShape();

			// DEBUG: Log all floor shapes
			if (shapeID >= 367 && shapeID <= 370)
			{
				std::stringstream ss;
				ss << "CheckTileWalkable(" << worldX << "," << worldZ << "): Found floor shape "
				   << shapeID << ", y=" << obj->m_Pos.y << ", IsWalkableSurface=" << (IsWalkableSurface(shapeID) ? 1 : 0);
				//NPCDebugPrint(ss.str());
			}

			if (IsWalkableSurface(shapeID))
			{
				// Skip very high walkable surfaces (upper floors)
				if (obj->m_Pos.y >= MAX_WALKABLE_SURFACE_HEIGHT)
					continue;
					
				// This is a known walkable surface - clear terrain blocking and allow tile
				std::stringstream ss;
				ss << "  -> Allowing tile (" << worldX << "," << worldZ << ") with floor shape " << shapeID;
				//NPCDebugPrint(ss.str());
				terrainBlocks = false;  // Clear any terrain blocking below this walkable surface
				continue;
			}
		}

		// Skip very high objects (upper floors)
		if (obj->m_Pos.y >= MAX_WALKABLE_SURFACE_HEIGHT)
			continue;

		// Any other ground-level blocking object blocks the tile
		// (Height difference validation happens later in A* neighbor checking)
		return false;
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
				// Get tile height for walkable tiles only
				float tileHeight = GetTileHeight(worldX, worldZ);
				float displayHeight = tileHeight + 0.1f;  // Slightly above surface to avoid z-fighting

				float cost = g_pathfindingSystem->m_aStar ? g_pathfindingSystem->m_aStar->GetMovementCost(worldX, worldZ, this) : 1.0f;
				// Check if on object to get actual movement cost
				if (tileHeight > 0.1f)
					cost = CLIMB_MOVEMENT_COST;  // Override with climbing cost

				// Get all surface layers for this tile
				auto heights = GetWalkableSurfaceHeights(worldX, worldZ);

				// If no heights, ground only
				if (heights.empty())
					heights.push_back(0.0f);

				for (float h : heights)
				{
					float displayHeight = h + 0.05f;

					TileWithCost t;
					t.pos = { (float)worldX, displayHeight, (float)worldZ };
					t.cost = g_pathfindingSystem->m_aStar ? g_pathfindingSystem->m_aStar->GetMovementCost(worldX, worldZ, this) : 1.0f;

					// If this layer is an object surface, mark cost as climb cost
					if (h > 0.1f)
						t.cost = CLIMB_MOVEMENT_COST;

					// Check debug markers
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
			else
			{
				// Blocked tiles always at ground level
				m_cachedRedTiles.push_back({ (float)worldX, 0.1f, (float)worldZ });
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
	// Two triangles forming a 1x1 quad
	Vector3 v1 = { pos.x, pos.y, pos.z };
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
		AddConsoleString(msg);
		NPCDebugPrint("Tile (" + std::to_string(worldX) + "," + std::to_string(worldZ) + "): " + msg);
		if (skipReason.empty())
			foundBlockingObject = true;
	}

	if (!foundBlockingObject)
	{
		AddConsoleString("No blocking objects found");
		NPCDebugPrint("Tile (" + std::to_string(worldX) + "," + std::to_string(worldZ) + "): No blocking objects found");
	}

	// Final verdict
	bool walkable = CheckTileWalkable(worldX, worldZ);
	AddConsoleString("RESULT: " + std::string(walkable ? "WALKABLE" : "BLOCKED"));
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
		if (!IsWalkableSurface(shapeID))
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

// Quantize y into an integer index (same scheme used by A*)
// Packs yIndex (signed int) in the high bits, z in the middle, x in the low bits.
// yIndex is expected to be a small integer (we quantize world Y into an index).
static inline int QuantizeY(float y)
{
    return (int)roundf(y * 100.0f); // 0.01 precision
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
		//AddConsoleString("  FAILED: Out of bounds!", RED);
		return std::vector<Vector3>();  // Out of bounds
	}

	// Note: We don't check if start/goal are walkable - NPCs can spawn on blocked tiles
	// (like sitting on chairs) and destinations might be blocked objects (like altars).
	// Pathfinding will work around obstacles to get as close as possible.

	// Limit search distance to avoid searching entire map (performance)
	int distance = abs(goalX - startX) + abs(goalZ - startZ);
	const int HIERARCHICAL_THRESHOLD = 100;
	int maxDistance = HIERARCHICAL_THRESHOLD;  // Max 500 tiles
	if (distance > maxDistance)
	{
		return std::vector<Vector3>();
	}

	// Cleanup any previous pathfinding data
	CleanupNodes();

	// Choose start surface closest to provided start.y
	float startPrefY = start.y;
	float startY = PickClosestSurface(grid, startX, startZ, startPrefY);
	PathNode* startNode = new PathNode(startX, startZ, startY);
	startNode->g = 0;
	startNode->h = Heuristic(startX, startZ, goalX, goalZ);
	startNode->f = startNode->g + startNode->h;
	m_allocatedNodes.push_back(startNode);

	// Priority queue comparator (min-heap by f)
	auto cmp = [](PathNode* a, PathNode* b) { return a->f > b->f; };
	std::priority_queue<PathNode*, std::vector<PathNode*>, decltype(cmp)> openSet(cmp);
	std::unordered_map<int64_t, PathNode*> openSetLookup;  // key includes y index
	std::unordered_map<int64_t, PathNode*> closedSet;

	int startYIdx = QuantizeY(startY);
	int64_t startKey64 = MakeNodeKey(startX, startZ, startYIdx);
	openSet.push(startNode);
	openSetLookup[startKey64] = startNode;

	PathNode* goalNode = nullptr;
	int nodesExplored = 0;
	const int maxNodesToExplore = 40000;  // Limit iterations for performance

	// Clear debug markers
	m_visitedNodeKeys.clear();
	m_finalPathKeys.clear();

	// A* main loop
	while (!openSet.empty() && nodesExplored < maxNodesToExplore)
	{
		nodesExplored++;

		// Get node with lowest f cost (top of priority queue)
		PathNode* current = openSet.top();
		openSet.pop();

		int curYIdx = QuantizeY(current->y);
		int64_t currentKey64 = MakeNodeKey(current->x, current->z, curYIdx);

		// Skip if this node is outdated (a better version was already added to queue)
		auto lookupIt = openSetLookup.find(currentKey64);
		if (lookupIt != openSetLookup.end() && lookupIt->second != current)
		{
			// This is an outdated duplicate, skip it
			continue;
		}
		// Remove from open lookup now that we are processing it
		openSetLookup.erase(currentKey64);

		// Mark current as visited (for debug)
		m_visitedNodeKeys.insert(currentKey64);

		// For debug: log every 1000 nodes explored
		float goalPreferredY = PickClosestSurface(grid, goalX, goalZ, goal.y);

		// Check if we reached the goal (tile-level)
		if (current->x == goalX && current->z == goalZ)
		{
			// If the caller requested a non-ground surface (goal.y > 0.1), require a node
            // with matching surface Y (small epsilon). Otherwise accept any y (ground).
            const float GOAL_EPS = 0.01f;
            if (goalPreferredY <= 0.1f || fabsf(current->y - goalPreferredY) <= GOAL_EPS)
            {
                goalNode = current;
#ifdef DEBUG_NPC_PATHFINDING
                AddConsoleString("A*: reached goal tile with matching surface Y", GREEN);
#endif
                break;
            }
            // else: keep searching — do not accept ground node if caller wanted the upper surface
		}

		// Add to closed set
		closedSet[currentKey64] = current;

		// Get neighbors (they will be created with chosen reachable surface heights)
		std::vector<PathNode*> neighbors = GetNeighbors(current, grid, goalX, goalZ);

		for (PathNode* neighbor : neighbors)
		{
			// Build neighbor key (x,z,yIndex)
			int neighYIdx = QuantizeY(neighbor->y);
			int64_t neighborKey64 = MakeNodeKey(neighbor->x, neighbor->z, neighYIdx);

			// Skip if in closed set
			if (closedSet.find(neighborKey64) != closedSet.end())
			{
				delete neighbor;
				continue;
			}
		
			// Calculate tentative g cost
			float neighborHeight = neighbor->y;
			float moveCost;

			if (neighborHeight > 0.1f)  // On an object, not ground
			{
				// Walking on an object (stairs, platform, etc.) - use climbing cost
				moveCost = CLIMB_MOVEMENT_COST;
			}
			else
			{
				// Walking on ground - use terrain cost
				moveCost = GetMovementCost(neighbor->x, neighbor->z, grid);
			}

			// If this neighbor is a diagonal (dx != 0 && dz != 0), apply diagonal multiplier
			// This prevents diagonal shortcuts being cheaper than sequences of orthogonal moves.
			int ddx = neighbor->x - current->x;
			int ddz = neighbor->z - current->z;
			const float DIAGONAL_COST = 1.41421356237f; // sqrt(2)
			float dirMultiplier = ( (ddx != 0) && (ddz != 0) ) ? DIAGONAL_COST : 1.0f;

			float tentativeG = current->g + moveCost * dirMultiplier;

			// Check if neighbor is in open set
			auto openIt = openSetLookup.find(neighborKey64);

			if (openIt == openSetLookup.end())
			{
				// Not in open set, add it
				neighbor->g = tentativeG;
				neighbor->h = Heuristic(neighbor->x, neighbor->z, goalX, goalZ);
				neighbor->f = neighbor->g + neighbor->h;
				neighbor->parent = current;
				openSet.push(neighbor);
				openSetLookup[neighborKey64] = neighbor;
				m_allocatedNodes.push_back(neighbor);
			}
			else
			{
				// Already in open set - check if this path is better
				PathNode* existingNode = openIt->second;
				if (tentativeG < existingNode->g)
				{
					// This path is better - add new node with better cost to queue
					neighbor->g = tentativeG;
					neighbor->h = Heuristic(neighbor->x, neighbor->z, goalX, goalZ);
					neighbor->f = neighbor->g + neighbor->h;
					neighbor->parent = current;
					openSet.push(neighbor);
					openSetLookup[neighborKey64] = neighbor;  // Update lookup to point to new better node
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
			goalNode = furthest;  // Use this as the goal instead
		}
		else
		{
			if (nodesExplored >= maxNodesToExplore)
			{
				AddConsoleString("  FAILED: Search limit reached (" + std::to_string(maxNodesToExplore) + " nodes)", RED);
			}
			AddConsoleString("  FAILED: No reachable point found near goal", RED);
		}
	}

	// Reconstruct path
	std::vector<Vector3> path;
	if (goalNode != nullptr)
	{
		// Collect final path keys for debug overlay
		PathNode* walk = goalNode;
		while (walk)
		{
			int yidx = QuantizeY(walk->y);
			int64_t k = MakeNodeKey(walk->x, walk->z, yidx);
			m_finalPathKeys.insert(k);
			walk = walk->parent;
		}

		path = ReconstructPath(goalNode, grid);
	}

	return path;
}

float AStar::Heuristic(int x1, int z1, int x2, int z2)
{
	// Octile distance is admissible for 8-directional movement with diagonal cost = sqrt(2)
	const float DIAGONAL_COST = 1.41421356237f; // sqrt(2)
	int dx = abs(x2 - x1);
	int dz = abs(z2 - z1);

	int mn = std::min(dx, dz);
	int mx = std::max(dx, dz);

	// (mx - mn) orthogonal steps + DIAGONAL_COST * mn diagonal steps
	return (float)((mx - mn) + DIAGONAL_COST * mn);
}

std::vector<PathNode*> AStar::GetNeighbors(PathNode* node, PathfindingGrid* grid, int goalX, int goalZ)
{
	std::vector<PathNode*> neighbors;

	// 4-directional neighbors (N, S, E, W)
	int directions[8][2] = {
		{0, -1},  // North
		{1, -1},  // Northeast
		{-1, -1}, // Northwest
		{0, 1},   // South
		{1, 1},   // Southeast
		{-1, 1},  // Southwest
		{1, 0},   // East
		{-1, 0}   // West
	};

	for (int i = 0; i < 8; i++)
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
		{
			// DEBUG: Log rejected walkability near bridge
			static int walkDebugCount = 0;
			if (walkDebugCount < 10 && nx >= 955 && nx <= 970 && nz >= 1165 && nz <= 1195)
			{
				std::stringstream ss;
				ss << "A* rejected tile (" << nx << "," << nz << ") as non-walkable from (" << node->x << "," << node->z << ")";
				//NPCDebugPrint(ss.str());
				walkDebugCount++;
			}
			continue;
		}

		// Height difference check - NPCs can only climb/descend a limited amount
		float currentHeight = node->y; // use node's chosen surface

		// Get all candidate surface heights for neighbor tile
		auto neighborHeights = grid->GetWalkableSurfaceHeights(nx, nz);
		if (neighborHeights.empty())
			neighborHeights.push_back(0.0f);

		// Try to find a neighbor height that is reachable from currentHeight.
		// Prefer reachable non-ground surfaces (stairs/platforms) when available,
		// otherwise fall back to the closest reachable surface (including ground).
		float chosenNeighborH = NAN;

		// 1) Prefer reachable positive (non-ground) heights (useful for stairs)
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

		// If no reachable surface found yet, check for stairs bridging these tiles (existing fallback),
		// but enforce symmetric climb/descent limits so descending cannot exceed MAX_CLIMBABLE_HEIGHT.
		if (std::isnan(chosenNeighborH))
		{
			// Check overlapping objects on current and neighbor tile for stair shapes
			auto checkHasStair = [](PathfindingGrid* g, int tx, int tz) -> bool {
				auto objs = g->GetOverlappingObjects(tx, tz);
				for (const auto& ov : objs)
				{
					if (!ov.obj || !ov.obj->m_shapeData || !ov.obj->m_objectData) continue;
					int s = ov.obj->m_shapeData->GetShape();
					// Prefer shape ID range, but also accept objects whose name contains "stair"
					if ((s >= 426 && s <= 430))
						return true;
					std::string name = ov.obj->m_objectData->m_name;
					std::transform(name.begin(), name.end(), name.begin(), ::tolower);
					if (name.find("stair") != std::string::npos)
						return true;
				}
				return false;
			};

			bool stairPresent = checkHasStair(grid, node->x, node->z) || checkHasStair(grid, nx, nz);

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
					// neighborHeights are sorted ascending in GetWalkableSurfaceHeights; stairCandidates will be too.
					// Prefer monotonic stair movement:
					// - if currentHeight is above all candidates, step to the highest candidate (descend one step)
					// - if currentHeight is below all candidates, step to the lowest candidate (ascend one step)
					// - otherwise pick the candidate closest to currentHeight
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
#ifdef DEBUG_NPC_PATHFINDING
					{
						std::stringstream ss;
						ss << "GetNeighbors: stair fallback between (" << node->x << "," << node->z << ") and ("
						   << nx << "," << nz << ") -> chosenH=" << chosenNeighborH << " currentH=" << currentHeight;
						NPCDebugPrint(ss.str());
					}
#endif
				}
				// else: no stair candidate within climb limit -> do not allow this neighbor via stair fallback
			}
		}

		// If still no reachable surface found, skip neighbor
		if (std::isnan(chosenNeighborH))
			continue;

		// Create neighbor node with chosen height
		PathNode* pn = new PathNode(nx, nz, chosenNeighborH);
		neighbors.push_back(pn);
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

std::vector<Vector3> AStar::ReconstructPath(PathNode* goal, PathfindingGrid* grid)
{
	std::vector<Vector3> path;
	PathNode* current = goal;

	while (current != nullptr)
	{
		// Get the actual height of this waypoint tile
		float tileHeight = grid ? grid->GetTileHeight(current->x, current->z) : 0.0f;

		// Create waypoint with correct 3D position
		Vector3 waypoint;
		waypoint.x = (float)current->x;
		waypoint.y = current->y;
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

//----------------------------------------------
// High-level chunk-based initial pathfinding
//---------------------------------------------

//  By building a high-level map of which chunk has a clear path to which
//  neighboring chunk, we can assign pathfinding nodes much more quickly.
//
//  We'll still need A* to reach the final destination within a chunk.

// 3D Line vs full AABB intersection (slab method)
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
		else if (p < (&boxMin.x)[i] || p > (&boxMax.x)[i])
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

			Vector3 half = Vector3Multiply(obj->m_shapeData->m_Dims, {0.5f, 0.5f, 0.5f});
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
	PopulateChunkPathfindingGrid();
}



void PathfindingSystem::PopulateChunkPathfindingGrid()
{
	for (int cz = 0; cz < 192; ++cz)
	{
		for (int cx = 0; cx < 192; ++cx)
		{
			ChunkInfo& ci = m_chunkInfoMap[cz][cx];

			Vector3 center = { cx * 16.0f + 8.0f, 0.0f, cz * 16.0f + 8.0f };
			for(int i = 0; i < 8; ++i)
			{
				ci.canReach[i] = AreAllTilesInDirectionWalkable({center.x, center.z}, Dir8(i));
			}

			// North
			if (ci.canReach[DIR_N]) //  Tiles passable?  Check for objects in the way.
			{
				ci.canReach[DIR_N] = LineOfTilesIsWalkable3D(center, { center.x, center.y, center.z - 16.0f });
			}

			// North-East
			if (ci.canReach[DIR_NE]) //  Tiles passable?  Check for objects in the way.
			{
				ci.canReach[DIR_NE] = LineOfTilesIsWalkable3D(center, { center.x + 16.0f, center.y, center.z - 16.0f });
			}

			// East
			if (ci.canReach[DIR_E]) //  Tiles passable?  Check for objects in the way.
			{
				ci.canReach[DIR_E] = LineOfTilesIsWalkable3D(center, { center.x + 16.0f, center.y, center.z });
			}

			// South-East
			if (ci.canReach[DIR_SE]) //  Tiles passable?  Check for objects in the way.
			{
				ci.canReach[DIR_SE] = LineOfTilesIsWalkable3D(center, { center.x + 16.0f, center.y, center.z  + 16.0f });
			}

			// South
			if (ci.canReach[DIR_S]) //  Tiles passable?  Check for objects in the way.
			{
				ci.canReach[DIR_S] = LineOfTilesIsWalkable3D(center, { center.x, center.y, center.z  + 16.0f });
			}

			// South-West
			if (ci.canReach[DIR_SW]) //  Tiles passable?  Check for objects in the way.
			{
				ci.canReach[DIR_SW] = LineOfTilesIsWalkable3D(center, { center.x - 16.0f, center.y, center.z  + 16.0f });
			}

			// West
			if (ci.canReach[DIR_W]) //  Tiles passable?  Check for objects in the way.
			{
				ci.canReach[DIR_W] = LineOfTilesIsWalkable3D(center, { center.x - 16.0f, center.y, center.z });
			}
		}
	}
}

std::vector<Vector3> PathfindingSystem::FindPath(Vector3 start, Vector3 end)
{
	return m_aStar->FindPath(start, end, m_pathfindingGrid.get());
}

// Implement debug helpers (must match declarations)
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