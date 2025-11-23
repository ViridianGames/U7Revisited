///////////////////////////////////////////////////////////////////////////
//
// Name:     PATHFINDINGTHREADPOOL.H
// Author:   Anthony Salter
// Date:     1/17/25
// Purpose:  Thread pool for background NPC pathfinding
///////////////////////////////////////////////////////////////////////////

#ifndef _PathfindingThreadPool_H_
#define _PathfindingThreadPool_H_

#include <vector>
#include <queue>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <atomic>
#include <unordered_map>
#include "raylib.h"

class AStar;
class PathfindingGrid;

// Pathfinding request structure
struct PathRequest
{
	int npcID;
	Vector3 start;
	Vector3 goal;
	int requestID;  // For staleness detection
};

// Pathfinding result structure
struct PathResult
{
	int npcID;
	std::vector<Vector3> waypoints;
	int requestID;
	bool success;
};

class PathfindingThreadPool
{
public:
	PathfindingThreadPool(int numThreads, PathfindingGrid* grid);
	~PathfindingThreadPool();

	// Submit a pathfinding request (called from main thread)
	void SubmitRequest(const PathRequest& request);

	// Get completed results (called from main thread)
	bool PopResult(PathResult& result);

	// Check if there are pending requests
	bool HasPendingRequests();

	// Get queue sizes for debugging
	int GetRequestQueueSize();
	int GetResultQueueSize();

	// Request ID tracking (for Lua async pathfinding)
	int GetNextRequestID();  // Get unique request ID
	bool IsPathReady(int requestID);  // Check if path is ready (consumes the result)
	void MarkRequestReady(int requestID);  // Mark a request as ready (called by MainState)
	void StorePendingLuaPath(int requestID, const std::vector<Vector3>& waypoints);  // Store waypoints for Lua
	std::vector<Vector3> RetrievePendingLuaPath(int requestID);  // Get and remove waypoints for Lua

private:
	void WorkerThread(int workerID);

	std::vector<std::thread> m_workers;
	std::vector<AStar*> m_astarInstances;  // One per worker thread
	PathfindingGrid* m_pathfindingGrid;

	std::queue<PathRequest> m_requestQueue;
	std::queue<PathResult> m_resultQueue;

	std::mutex m_requestMutex;
	std::mutex m_resultMutex;
	std::condition_variable m_requestCV;

	std::atomic<bool> m_shutdown;
	std::atomic<int> m_nextRequestID;

	// Request tracking for Lua
	std::unordered_map<int, bool> m_readyResults;  // requestID -> ready?
	std::unordered_map<int, std::vector<Vector3>> m_pendingLuaPaths;  // requestID -> waypoints
	std::mutex m_readyResultsMutex;
};

#endif
