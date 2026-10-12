#include "PerfTelemetry.h"

#include "U7Globals.h"
#include "U7Object.h"
#include "U7Player.h"
#include "PathfindingSystem.h"
#include "Terrain.h"
#include "Geist/Engine.h"
#include "Geist/Logging.h"
#include "CombatState.h"

#include "raylib.h"

#include <fstream>
#include <sstream>
#include <iomanip>
#include <algorithm>
#include <cmath>

PerfTelemetry g_perf;

static int MinChunkEdgeDist(int tileCoord)
{
	const int local = ((tileCoord % 16) + 16) % 16;
	return std::min(local, 15 - local);
}

void PerfTelemetry::NoteValidateMove(int srcX, int srcZ, int destX, int destZ, bool accepted)
{
	++validateMoveCalls;
	if (!accepted)
		++validateMoveRejects;

	const bool crossChunk =
		(srcX / 16) != (destX / 16) ||
		(srcZ / 16) != (destZ / 16);
	const int edgeSrc = std::min(MinChunkEdgeDist(srcX), MinChunkEdgeDist(srcZ));
	const int edgeDst = std::min(MinChunkEdgeDist(destX), MinChunkEdgeDist(destZ));
	const bool nearEdge = (edgeSrc <= 1) || (edgeDst <= 1);

	if (crossChunk)
	{
		++vmCrossChunkCalls;
		if (!accepted)
			++vmCrossChunkRejects;
	}
	if (nearEdge)
	{
		++vmNearEdgeCalls;
		if (!accepted)
			++vmNearEdgeRejects;
	}
	if (!crossChunk && !nearEdge)
	{
		++vmInteriorCalls;
		if (!accepted)
			++vmInteriorRejects;
	}
}

void PerfTelemetrySampleAvatar()
{
	if (!g_Player)
		return;
	U7Object* avatar = g_Player->GetAvatarObject();
	if (!avatar)
		return;

	static Vector3 s_lastPos = { 0, 0, 0 };
	static bool s_haveLast = false;
	const Vector3 pos = avatar->GetPos();
	if (s_haveLast)
	{
		const float dx = pos.x - s_lastPos.x;
		const float dz = pos.z - s_lastPos.z;
		g_perf.avatarDistXZ += sqrtf(dx * dx + dz * dz);
	}
	s_lastPos = pos;
	s_haveLast = true;

	g_perf.avatarSpeedSetting = avatar->m_speed;
	g_perf.avatarWasMoving = avatar->m_isMoving || !avatar->m_pathWaypoints.empty();

	// Cheap per-frame: terrain + chunk position. Overlap scan is dump-time only.
	const int tx = (int)floorf(pos.x);
	const int tz = (int)floorf(pos.z);
	if (tx >= 0 && tx < 3072 && tz >= 0 && tz < 3072)
	{
		const unsigned short shapeframe = g_World[tz][tx];
		const int shapeID = shapeframe & 0x3ff;
		g_perf.avatarTerrainShape = shapeID;
		g_perf.avatarTileX = tx;
		g_perf.avatarTileZ = tz;
		g_perf.avatarLocalX = ((tx % 16) + 16) % 16;
		g_perf.avatarLocalZ = ((tz % 16) + 16) % 16;
		g_perf.avatarChunkX = tx / 16;
		g_perf.avatarChunkZ = tz / 16;
		g_perf.avatarEdgeDist = std::min(MinChunkEdgeDist(tx), MinChunkEdgeDist(tz));
		if (g_perf.avatarEdgeDist <= 1)
			++g_perf.framesNearChunkEdge;
		else if (g_perf.avatarEdgeDist >= 4)
			++g_perf.framesChunkInterior;
		if (g_pathfindingSystem)
		{
			g_perf.avatarTerrainCost = g_pathfindingSystem->GetGroundCost(tx, tz);
			g_perf.avatarTerrainName = g_pathfindingSystem->GetTerrainName(shapeID);
		}
	}
}

void PerfTelemetryOnFrame()
{
	const float now = GetTime();
	const double frameMs = g_Engine ? (g_Engine->LastFrameInSeconds() * 1000.0) : 0.0;

	++g_perf.frames;
	g_perf.sumFrameMs += frameMs;
	if (frameMs > g_perf.maxFrameMs)
		g_perf.maxFrameMs = frameMs;

	g_perf.inCombat = g_isCombatMode;
	if (g_isCombatMode && g_mainState && g_mainState->GetActiveCombatMode())
	{
		switch (g_mainState->GetActiveCombatMode()->GetStyle())
		{
		case CombatStyle::Original: g_perf.mode = "combat:original"; break;
		case CombatStyle::RealTimePause: g_perf.mode = "combat:rtwp"; break;
		case CombatStyle::TurnBased: g_perf.mode = "combat:turn"; break;
		default: g_perf.mode = "combat"; break;
		}
	}
	else
		g_perf.mode = g_isCombatMode ? "combat" : "main";

	PerfTelemetrySampleAvatar();

	g_perf.interestObjSum += g_interestObjectsUpdated;
	g_perf.visibleObjSum += (int)g_sortedVisibleObjects.size();
	++g_perf.interestObjSamples;

	if (g_mainState && g_isCombatMode)
		g_perf.combatParticipantsMax =
			std::max(g_perf.combatParticipantsMax, (int)g_mainState->m_combatParticipants.size());

	if (g_perf.lastDumpTime <= 0.0f)
		g_perf.lastDumpTime = now;

	if (now - g_perf.lastDumpTime < 1.0f)
		return;

	g_perf.lastDumpTime = now;

	// Heavier Avatar feet sample once per dump (overlap count).
	if (g_Player && g_pathfindingSystem)
	{
		if (U7Object* avatar = g_Player->GetAvatarObject())
		{
			const int tx = (int)floorf(avatar->m_Pos.x);
			const int tz = (int)floorf(avatar->m_Pos.z);
			if (tx >= 0 && tx < 3072 && tz >= 0 && tz < 3072)
				g_perf.avatarOverlapCount =
					(int)g_pathfindingSystem->GetOverlappingObjects(tx, tz).size();
		}
	}

	const int frames = std::max(1, g_perf.frames);
	const double avgFrameMs = g_perf.sumFrameMs / frames;
	const double fps = g_perf.sumFrameMs > 0.0 ? (1000.0 * frames / g_perf.sumFrameMs) : (double)frames;

	const int avgInterest = g_perf.interestObjSamples
		? (g_perf.interestObjSum / g_perf.interestObjSamples) : 0;
	const int avgVisible = g_perf.interestObjSamples
		? (g_perf.visibleObjSum / g_perf.interestObjSamples) : 0;

	// Pathfinding tag deltas
	uint64_t tagCalls[static_cast<int>(PathCallerTag::Count)]{};
	uint64_t tagMs[static_cast<int>(PathCallerTag::Count)]{};
	uint64_t tagNodes[static_cast<int>(PathCallerTag::Count)]{};
	static uint64_t s_lastTagCalls[static_cast<int>(PathCallerTag::Count)]{};
	static uint64_t s_lastTagMs[static_cast<int>(PathCallerTag::Count)]{};
	static uint64_t s_lastTagNodes[static_cast<int>(PathCallerTag::Count)]{};
	uint64_t pathMsTotal = 0;
	uint64_t pathCallsTotal = 0;
	if (g_pathfindingSystem)
	{
		for (int i = 0; i < static_cast<int>(PathCallerTag::Count); ++i)
		{
			const uint64_t c = g_pathfindingSystem->m_pfCallsByTag[i].load();
			const uint64_t m = g_pathfindingSystem->m_pfMsByTag[i].load();
			const uint64_t n = g_pathfindingSystem->m_pfNodesByTag[i].load();
			tagCalls[i] = c - s_lastTagCalls[i];
			tagMs[i] = m - s_lastTagMs[i];
			tagNodes[i] = n - s_lastTagNodes[i];
			s_lastTagCalls[i] = c;
			s_lastTagMs[i] = m;
			s_lastTagNodes[i] = n;
			pathCallsTotal += tagCalls[i];
			pathMsTotal += tagMs[i];
		}
	}

	const int terrainRebuilds = g_Terrain ? g_Terrain->m_rebuildsThisSecond : 0;
	const int terrainSkips = g_Terrain ? g_Terrain->m_skipsThisSecond : 0;
	const double terrainRebuildMs = g_Terrain ? g_Terrain->m_rebuildMsThisSecond : 0.0;
	const char* dirtyReason = g_Terrain ? g_Terrain->m_lastDirtyReason : "n/a";

	std::ostringstream ss;
	ss << std::fixed << std::setprecision(2);
	ss << "TELEMETRY: mode=" << g_perf.mode
		<< " fps~" << (int)(fps + 0.5)
		<< " avgFrameMs=" << avgFrameMs
		<< " maxFrameMs=" << g_perf.maxFrameMs
		<< " combat=" << (g_perf.inCombat ? 1 : 0)
		<< " participants=" << g_perf.combatParticipantsMax;

	ss << " | upd interest=" << (g_perf.msInterest / frames)
		<< " objects=" << (g_perf.msObjects / frames)
		<< " combatAI=" << (g_perf.msCombatUpdate / frames)
		<< " combatOther=" << (g_perf.msCombatOther / frames)
		<< " sort=" << (g_perf.msSort / frames)
		<< " terrainUp=" << (g_perf.msTerrainUp / frames)
		<< " palette=" << (g_perf.msPalette / frames)
		<< " scripts=" << (g_perf.msScripts / frames)
		<< " camera=" << (g_perf.msCamera / frames)
		<< " validate=" << (g_perf.msValidateMove / frames);

	ss << " | draw terrain=" << (g_perf.msDrawTerrain / frames)
		<< " objects=" << (g_perf.msDrawObjects / frames);

	ss << " | max interest=" << g_perf.maxMsInterest
		<< " objects=" << g_perf.maxMsObjects
		<< " combatAI=" << g_perf.maxMsCombatUpdate
		<< " sort=" << g_perf.maxMsSort
		<< " terrainUp=" << g_perf.maxMsTerrainUp
		<< " validate=" << g_perf.maxMsValidateMove
		<< " drawObj=" << g_perf.maxMsDrawObjects;

	ss << " | counts interestObj~" << avgInterest
		<< " visible~" << avgVisible
		<< " chunks=" << g_interestChunkCount
		<< " npcUp=" << g_perf.npcUpdates
		<< " monUp=" << g_perf.monsterUpdates
		<< " eggUp=" << g_perf.eggUpdates
		<< " otherUp=" << g_perf.otherUpdates
		<< " engage=" << g_perf.engageCombatCalls
		<< " repaths=" << g_perf.combatRepaths
		<< " vmCalls=" << g_perf.validateMoveCalls
		<< " vmReject=" << g_perf.validateMoveRejects
		<< " vmCross=" << g_perf.vmCrossChunkRejects << "/" << g_perf.vmCrossChunkCalls
		<< " vmEdge=" << g_perf.vmNearEdgeRejects << "/" << g_perf.vmNearEdgeCalls
		<< " vmInt=" << g_perf.vmInteriorRejects << "/" << g_perf.vmInteriorCalls;

	ss << " | avatar tiles/s=" << g_perf.avatarDistXZ
		<< " speedSet=" << g_perf.avatarSpeedSetting
		<< " moving=" << (g_perf.avatarWasMoving ? 1 : 0)
		<< " terrain=" << g_perf.avatarTerrainName
		<< "(" << g_perf.avatarTerrainShape << ")"
		<< " cost=" << g_perf.avatarTerrainCost
		<< " overlap=" << g_perf.avatarOverlapCount
		<< " tile=(" << g_perf.avatarTileX << "," << g_perf.avatarTileZ << ")"
		<< " chunk=(" << g_perf.avatarChunkX << "," << g_perf.avatarChunkZ << ")"
		<< " local=(" << g_perf.avatarLocalX << "," << g_perf.avatarLocalZ << ")"
		<< " edgeDist=" << g_perf.avatarEdgeDist
		<< " nearEdgeFrames=" << g_perf.framesNearChunkEdge
		<< " intFrames=" << g_perf.framesChunkInterior;

	ss << " | terrain rebuilds/s=" << terrainRebuilds
		<< " skips/s=" << terrainSkips
		<< " rebuildMs/s=" << (int)terrainRebuildMs
		<< " lastDirty=" << dirtyReason;

	ss << " | pathCalls/s=" << pathCallsTotal
		<< " pathMs/s=" << pathMsTotal;
	ss << " | #FindPath";
	for (int i = 0; i < static_cast<int>(PathCallerTag::Count); ++i)
	{
		ss << " " << PathCallerTagName(static_cast<PathCallerTag>(i))
			<< "=" << tagCalls[i]
			<< "/" << tagMs[i] << "ms"
			<< "/n" << tagNodes[i];
	}

	const std::string line = ss.str();
	Log(line);
	std::ofstream tel("telemetry.txt", std::ios::app);
	if (tel)
	{
		tel << line << '\n';
		tel.flush();
	}

	if (g_Terrain)
	{
		g_Terrain->m_rebuildsThisSecond = 0;
		g_Terrain->m_skipsThisSecond = 0;
		g_Terrain->m_rebuildMsThisSecond = 0.0;
	}

	g_perf.ResetSecond();
}
