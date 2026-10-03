#ifndef _PerfTelemetry_H_
#define _PerfTelemetry_H_

#include <string>
#include <cstdint>

// Lightweight per-second subsystem timing for swamp-speed + combat-FPS diagnosis.
// Both MainState and CombatState feed these; dump runs from MainState::Draw
// (still executes under combat because CombatState m_RenderStack=true).

struct PerfTelemetry
{
	// Wall-clock dump gate
	float lastDumpTime = 0.0f;
	int frames = 0;
	double sumFrameMs = 0.0;
	double maxFrameMs = 0.0;

	// Update sections (ms accumulated over the second)
	double msInterest = 0.0;
	double msObjects = 0.0;       // full interest object Update pass (MainState)
	double msCombatUpdate = 0.0;  // CombatState participant Update loop
	double msCombatOther = 0.0;   // enroll/input/prune in CombatState
	double msSort = 0.0;
	double msTerrainUp = 0.0;
	double msPalette = 0.0;
	double msScripts = 0.0;
	double msCamera = 0.0;
	double msValidateMove = 0.0;
	double msDrawTerrain = 0.0;
	double msDrawObjects = 0.0;

	double maxMsInterest = 0.0;
	double maxMsObjects = 0.0;
	double maxMsCombatUpdate = 0.0;
	double maxMsSort = 0.0;
	double maxMsTerrainUp = 0.0;
	double maxMsValidateMove = 0.0;
	double maxMsDrawObjects = 0.0;
	double maxMsFrameSections = 0.0;

	// Counts this second
	int validateMoveCalls = 0;
	int validateMoveRejects = 0;
	// Chunk-border hypothesis (16×16 world chunks): split ValidateMove by geometry.
	int vmCrossChunkCalls = 0;     // dest chunk != src chunk
	int vmCrossChunkRejects = 0;
	int vmNearEdgeCalls = 0;       // src or dest within 1 tile of a chunk edge
	int vmNearEdgeRejects = 0;
	int vmInteriorCalls = 0;       // neither cross-chunk nor near-edge
	int vmInteriorRejects = 0;
	int interestObjSamples = 0;   // last-frame sample accumulated as sum → avg
	int interestObjSum = 0;
	int visibleObjSum = 0;
	int npcUpdates = 0;
	int monsterUpdates = 0;
	int eggUpdates = 0;
	int otherUpdates = 0;
	int combatParticipantsMax = 0;
	int engageCombatCalls = 0;
	int combatRepaths = 0;

	// Avatar movement / swamp diagnosis
	double avatarDistXZ = 0.0;    // world units walked this second
	float avatarSpeedSetting = 0.0f;
	int avatarTerrainShape = -1;
	float avatarTerrainCost = 0.0f;
	std::string avatarTerrainName;
	int avatarOverlapCount = 0;   // overlapping objects on feet tile (last sample)
	int avatarTileX = -1;
	int avatarTileZ = -1;
	int avatarLocalX = -1;        // tile X within chunk [0,15]
	int avatarLocalZ = -1;
	int avatarChunkX = -1;
	int avatarChunkZ = -1;
	int avatarEdgeDist = 99;      // min tiles to nearest chunk edge (0 = on border)
	int framesNearChunkEdge = 0;  // frames with edgeDist <= 1
	int framesChunkInterior = 0;  // frames with edgeDist >= 4
	bool avatarWasMoving = false;
	bool inCombat = false;
	std::string mode;             // "main" or "combat"

	void AddMs(double& bucket, double& peak, double ms)
	{
		bucket += ms;
		if (ms > peak) peak = ms;
	}

	// Classify a ValidateMove attempt for chunk-border correlation.
	void NoteValidateMove(int srcX, int srcZ, int destX, int destZ, bool accepted);

	void ResetSecond()
	{
		frames = 0;
		sumFrameMs = 0.0;
		maxFrameMs = 0.0;
		msInterest = msObjects = msCombatUpdate = msCombatOther = 0.0;
		msSort = msTerrainUp = msPalette = msScripts = msCamera = 0.0;
		msValidateMove = msDrawTerrain = msDrawObjects = 0.0;
		maxMsInterest = maxMsObjects = maxMsCombatUpdate = maxMsSort = 0.0;
		maxMsTerrainUp = maxMsValidateMove = maxMsDrawObjects = maxMsFrameSections = 0.0;
		validateMoveCalls = validateMoveRejects = 0;
		vmCrossChunkCalls = vmCrossChunkRejects = 0;
		vmNearEdgeCalls = vmNearEdgeRejects = 0;
		vmInteriorCalls = vmInteriorRejects = 0;
		interestObjSamples = interestObjSum = visibleObjSum = 0;
		npcUpdates = monsterUpdates = eggUpdates = otherUpdates = 0;
		combatParticipantsMax = engageCombatCalls = combatRepaths = 0;
		avatarDistXZ = 0.0;
		framesNearChunkEdge = framesChunkInterior = 0;
		avatarWasMoving = false;
	}
};

extern PerfTelemetry g_perf;

// Call once per rendered frame from MainState::Draw (works in combat too).
void PerfTelemetryOnFrame();

// Sample Avatar feet terrain + accumulate displacement since last sample.
void PerfTelemetrySampleAvatar();

#endif
