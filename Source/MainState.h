#ifndef _MainState_H_
#define _MainState_H_

#include "Geist/State.h"
//#include "GumpManager.h"
#include <list>
#include <deque>
#include <array>
#include <math.h>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <atomic>
#include "U7Globals.h"

class ParticleSystem;
class Gui;
class GuiElement;
class GumpManager;
class GhostWindow;
class GumpPaperdoll;
class NpcListWindow;

enum class MainStateModes
{
	MAIN_STATE_MODE_SANDBOX = 0,
	MAIN_STATE_MODE_TRINSIC_DEMO,
	MAIN_STATE_MODE_LAST
};

class MainState : public State
{
public:
   MainState() { m_DrawCursor = false; }  // MainState draws its own cursor with custom logic
   ~MainState();

   void Init(const std::string& configfile) override;
   void Shutdown() override;
   void Update() override;
   void Draw() override;

   void OnEnter() override;
	void OnExit() override;
   
   void SetupGame();
   void RebuildWorldFromLoadedData();  // Rebuild spatial indexing after loading a save

   void OpenGump(int id);
   void OpenSpellbookGump(int npcId);
   void OpenMinimapGump(int npcId);
   void OpenStatsGump(int npcId);
   void OpenLoadSaveGump();

   // Paperdoll management
   bool HasAnyPaperdollOpen() const;
   void TogglePaperdoll(int npcId);
   GumpPaperdoll* FindPaperdollByNpcId(int npcId) const;

   void DrawStats();
   void UpdateStats();
	void CalculateMouseOverUI();  // Sets g_mouseOverUI based on UI element positions
	void UpdateInput();
	void UpdateTime();

	void SetLuaFunction(const std::string& func_name) { m_luaFunction = func_name; }
	void StartObjectSelectionMode() { m_objectSelectionMode = true; m_doingObjectSelection = true; }

	void Bark(U7Object* object, const std::string& text, float duration = 3.0f);

	void ShowErrorCursor() { m_errorCursorFramesRemaining = 5; }  // Show error cursor for 5 frames

	// Debug tools window button handlers
	void HandleScheduleButton();
	void HandlePathfindButton();
	void HandleShapeTableButton();
	void HandleGhostButton();
	void HandleRenameButton();
	void HandleNPCListButton();
	void UpdateDebugToolsWindow();
	void DumpNpcScheduleStats();

	void BuildDemoHelpGUI();
	void BuildSandboxHelpGUI();

  // void DrawDebugChunkPathfindingInfo();

   float m_waitTime = 0;

   Gui* m_Gui = nullptr;

   Gui* m_OptionsGui = nullptr;

   Gui* m_toolTipGui = nullptr;

	Gui* m_numberBarGui = nullptr;

	// Debug tools window (always visible in sandbox mode)
	GhostWindow* m_debugToolsWindow = nullptr;

	// NPC list window for debugging/navigation
	NpcListWindow* m_npcListWindow = nullptr;
		// Request for scheduled pathfinding (non-blocking enqueue)
		struct SchedulePathRequest
		{
		int npcID = -1;
		Vector3 start = { 0.0f, 0.0f, 0.0f }; // start position at enqueue time (avoid reading later)
		Vector3 dest = { 0.0f, 0.0f, 0.0f };
	};

	// Result posted back from background worker
	struct SchedulePathResult
	{
		int npcID = -1;
		std::vector<Vector3> path;
		bool success = false;
		Vector3 dest = { 0.0f, 0.0f, 0.0f };
	};
	
	std::deque<SchedulePathRequest> m_schedulePathQueue; // enqueued schedule pathfinding requests
	int m_schedulePathBudgetPerFrame = 6; // kept for legacy/budget reasons (not used for sync pathfinding)

	// Background worker threads + synchronization for pathfinding
	std::vector<std::thread> m_pathfinderThreads;
	std::mutex m_scheduleMutex;                 // protects m_schedulePathQueue
	std::condition_variable m_scheduleCv;
	bool m_pathfinderRunning = false;

	// Results produced by worker and consumed on main thread
	std::deque<SchedulePathResult> m_scheduleResults;
	std::mutex m_resultMutex;                   // protects m_scheduleResults

	// Worker loop entry
	void PathfindingWorkerLoop();

	// Telemetry: track synchronous FindPath calls observed on main thread
	std::atomic<uint64_t> m_syncFindPathCalls{0};

	// Telemetry aggregation (per-second dumps)
	float m_lastTelemetryDumpTime = 0.0f;
	uint64_t m_lastAstarTotalCalls = 0;
	uint64_t m_lastAstarTotalMs = 0;
	uint64_t m_lastScriptErrorTotal = 0;
	int m_resultsAppliedThisSecond = 0;

	std::string m_luaFunction;

	//  Bark variables.
	U7Object* m_barkObject = nullptr;
	std::string m_barkText = "";
	float m_barkDuration = 0;
	bool m_barkAutoUpdate = false;  // True if bark should regenerate from object name each frame
   
   float m_LastUpdate = 0.0f;
   
   int m_NumberOfVisibleUnits = 0;
   
   int m_GuiMode = 0;
   
   bool m_DrawMarker = false;
   float m_MarkerRadius = 0.0f;
   
   ParticleSystem* m_Particles = nullptr;
   
//   SDL_Rect** m_Resolutions;
//   int m_CurrentRes;
   
   // Game options
   unsigned int m_NumberOfPlayers = 1;
   unsigned int m_PlayerID = 0;
   unsigned int m_GameType = 0;
   unsigned int m_RNGSeed = 0;
   
   //Texture* m_TerrainTexture;
   Texture* m_Minimap = nullptr;
   Texture* m_MinimapArrow = nullptr;
	Texture* m_useCursor = nullptr;
	Texture* m_errorCursor = nullptr;


   bool m_showObjects = true;

	// Error cursor display (shown for 5 frames after drag/drop error)
	int m_errorCursorFramesRemaining = 0;

	bool m_objectSelectionMode = false;

	int m_numberofObjects = 0;
	int m_numberofObjectsPassingFirstCheck = 0;
   int m_numberofDrawnObjects = 0;

   int m_cameraUpdateTime = 0;

   int m_terrainUpdateTime = 0;

	bool m_doingObjectSelection = false;

   unsigned int m_terrainDrawHeight = 0;

   unsigned int m_selectedObject = 0;

   float m_heightCutoff = 16.0f;

   bool m_isPopupShowing = false;  //  If true, the game is paused and a popup is showing

   bool m_paused = false;

	Vector2 m_dragStart = {0, 0};

	MainStateModes m_gameMode = MainStateModes::MAIN_STATE_MODE_SANDBOX;

	enum class FadeState
	{
		FADE_NONE = 0,
		FADE_OUT,
		FADE_IN
	};

	FadeState m_fadeState = FadeState::FADE_NONE; // 0 = no fade, 1 = fade out, 2 = fade in
	float m_fadeDuration = 0; // 0.0 to 1.0
	float m_fadeTime = 0;
	unsigned char m_currentFadeAlpha = 255;

	bool m_ranIntroScript = false;
	bool m_introScriptRunning = false;

	bool m_showUIElements = true;

	// Track if we've shown the initial welcome messages (only show once, not on every OnEnter)
	bool m_hasShownWelcomeMessages = false;

	// NPC Schedule toggle
	bool m_npcSchedulesEnabled = false;  // Default disabled - user must enable

	// NPC Pathfinding on schedule change toggle
	bool m_npcPathfindingEnabled = false;  // Default disabled - NPCs stay in place when schedules change

	// Pathfinding debug visualization
	bool m_showPathfindingDebug = false;  // F10: Tile-level visualization (shows objects)

	// Debug: Allow moving static objects
	bool m_allowMovingStaticObjects = false;  // F7: Toggle moving static objects

	bool m_loadOnEntry = false;

	// added near the other public members
	void SetFollowingScheduleForNpc(int npcId, bool follow);
	bool IsNpcSchedulesEnabled() const;

	void MaybeUpdatePartyFollowing();

	Vector3 m_lastPartyAnchorPos = { 0.0f, 0.0f, 0.0f };
	float  m_lastPartyFollowTime = 0.0f;
	float  m_partyFollowCooldown = 0.5f;        // seconds
	float  m_partyAnchorThreshold = 3.0f;       // tiles moved since last anchor -> update
	float  m_partyMemberFollowThreshold = 2.0f; // distance per member to trigger pathfind
	float  m_partySpacing = 1.0f;               // tiles between members in the line

	// Camera-drag while holding left+right: state & helpers
	void StartCameraDrag();
	void UpdateCameraDrag();
	void EndCameraDrag();

private:
	// UpdateInput() sub-handlers — each owns one concern
	void HandleEscapeKey();
	void HandleDebugKeys();
	void HandleGameKeys();
	void HandleObjectDrag();
	void HandleMiddleClick();
	void HandleRightDoubleClick();
	void HandleMouseHoldTimers();
	void HandleRightMouseHoldMovement();
	void HandleLeftDoubleClick();
	void HandleLeftSingleClick();
	void DebugPrintNpcSchedule(U7Object* npc);
	void HandleAvatarMovement();

	// Mouse-hold detection (prevents quick clicks from triggering hold movement)
	float m_rightMouseHoldStart = 0.0f;
	bool  m_rightMouseHeld = false;
	float m_rightMouseHoldThreshold = 0.15f; // seconds required to be considered a "hold"

	float m_leftMouseHoldStart = 0.0f;
	bool  m_leftMouseHeld = false;
	float m_leftMouseHoldThreshold = 0.15f;  // seconds required to be considered a "hold"

	// Camera-drag state (used while holding left+right)
	Vector2 m_cameraDragLockPos = { 0.0f, 0.0f };
	bool    m_cameraDragging = false;
	bool    m_cursorLocked = false;
	float   m_cameraDragSensitivity = 0.008f; // radians per pixel (tune as needed)

	bool m_handledDoubleLeftClickThisFrame = false;

	float m_barkTimer = 0.0f;
	U7Object* m_previousObjectUnderMousePointer = nullptr;
};

#endif