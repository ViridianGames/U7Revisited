///////////////////////////////////////////////////////////////////////////
//
// Name:     PATHFINDINGTHREADPOOL.CPP
// Author:   Anthony Salter
// Date:     1/17/25
// Purpose:  Thread pool for background NPC pathfinding
///////////////////////////////////////////////////////////////////////////

#include "PathfindingThreadPool.h"
#include "Pathfinding.h"
#include "U7Globals.h"

PathfindingThreadPool::PathfindingThreadPool(int numThreads, PathfindingGrid* grid)
	: m_pathfindingGrid(grid)
	, m_shutdown(false)
	, m_nextRequestID(0)
{
	// Create one AStar instance per worker thread
	for (int i = 0; i < numThreads; i++)
	{
		m_astarInstances.push_back(new AStar());
	}

	// Start worker threads
	for (int i = 0; i < numThreads; i++)
	{
		m_workers.emplace_back(&PathfindingThreadPool::WorkerThread, this, i);
	}
}

PathfindingThreadPool::~PathfindingThreadPool()
{
	// Signal shutdown
	m_shutdown = true;
	m_requestCV.notify_all();

	// Wait for all threads to finish
	for (auto& worker : m_workers)
	{
		if (worker.joinable())
			worker.join();
	}

	// Clean up AStar instances
	for (auto* astar : m_astarInstances)
	{
		delete astar;
	}
}

void PathfindingThreadPool::SubmitRequest(const PathRequest& request)
{
	std::lock_guard<std::mutex> lock(m_requestMutex);
	m_requestQueue.push(request);
	m_requestCV.notify_one();  // Wake up one worker thread
}

bool PathfindingThreadPool::PopResult(PathResult& result)
{
	std::lock_guard<std::mutex> lock(m_resultMutex);

	if (m_resultQueue.empty())
		return false;

	result = m_resultQueue.front();
	m_resultQueue.pop();
	return true;
}

bool PathfindingThreadPool::HasPendingRequests()
{
	std::lock_guard<std::mutex> lock(m_requestMutex);
	return !m_requestQueue.empty();
}

int PathfindingThreadPool::GetRequestQueueSize()
{
	std::lock_guard<std::mutex> lock(m_requestMutex);
	return (int)m_requestQueue.size();
}

int PathfindingThreadPool::GetResultQueueSize()
{
	std::lock_guard<std::mutex> lock(m_resultMutex);
	return (int)m_resultQueue.size();
}

int PathfindingThreadPool::GetNextRequestID()
{
	return ++m_nextRequestID;
}

bool PathfindingThreadPool::IsPathReady(int requestID)
{
	std::lock_guard<std::mutex> lock(m_readyResultsMutex);
	auto it = m_readyResults.find(requestID);
	if (it != m_readyResults.end() && it->second)
	{
		m_readyResults.erase(it);  // Consume the result
		return true;
	}
	return false;
}

void PathfindingThreadPool::MarkRequestReady(int requestID)
{
	std::lock_guard<std::mutex> lock(m_readyResultsMutex);
	m_readyResults[requestID] = true;
}

void PathfindingThreadPool::WorkerThread(int workerID)
{
	AStar* localAStar = m_astarInstances[workerID];

	while (!m_shutdown)
	{
		PathRequest req;

		// Wait for a request or shutdown signal
		{
			std::unique_lock<std::mutex> lock(m_requestMutex);
			m_requestCV.wait(lock, [this] {
				return !m_requestQueue.empty() || m_shutdown;
			});

			if (m_shutdown)
				break;

			if (m_requestQueue.empty())
				continue;

			req = m_requestQueue.front();
			m_requestQueue.pop();
		}

		// Pathfind (no locks held - reads from read-only data and g_chunkObjectMap with shared_lock)
		std::vector<Vector3> path = localAStar->FindPath(req.start, req.goal, m_pathfindingGrid);

		// Push result
		{
			std::lock_guard<std::mutex> lock(m_resultMutex);
			PathResult result;
			result.npcID = req.npcID;
			result.waypoints = path;
			result.requestID = req.requestID;
			result.success = !path.empty();
			m_resultQueue.push(result);
		}
	}
}
