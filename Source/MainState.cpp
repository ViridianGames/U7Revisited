#include "Geist/Globals.h"
#include "Geist/Logging.h"
#include "Geist/Gui.h"
#include "Geist/ParticleSystem.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/Primitives.h"
#include "Geist/Engine.h"
#include "Geist/ScriptingSystem.h"
#include "U7Globals.h"
#include "MainState.h"
#include "rlgl.h"
#include "U7Gump.h"
#include "U7GumpPaperdoll.h"
#include "U7GumpSpellbook.h"
#include "U7GumpMinimap.h"
#include "U7GumpStats.h"
#include "ConversationState.h"
#include "GumpManager.h"
#include "PathfindingSystem.h"
#include "Ghost/GhostWindow.h"
#include "Ghost/GhostSerializer.h"
#include "NpcListWindow.h"

#include <list>
#include <string>
#include <sstream>
#include <iomanip>
#include <math.h>
#include <fstream>
#include <algorithm>
#include <unordered_map>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <atomic>
#include <chrono>

#include "InputSystem.h"
#include "LoadSaveState.h"
#include "SoundSystem.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  MainState
////////////////////////////////////////////////////////////////////////////////

MainState::~MainState()
{
	Shutdown();
}

void MainState::Init(const string& configfile)
{
	m_Minimap = g_ResourceManager->GetTexture("Images/minimap.png");

	m_MinimapArrow = g_ResourceManager->GetTexture("Images/minimaparrow.png", false);
	GenTextureMipmaps(m_MinimapArrow);

	m_useCursor = g_ResourceManager->GetTexture("Images/usepointer.png");
	m_errorCursor = g_ResourceManager->GetTexture("Images/error.png");

	BuildDemoHelpGUI();
	BuildSandboxHelpGUI();

	m_Gui = new Gui();

	m_Gui->SetLayout(0, 0, 138, 384, g_DrawScale, Gui::GUIP_UPPERRIGHT);

	m_Gui->AddPanel(1000, 0, 0, 138, 384, Color{ 143, 128, 97, 255 });

	m_Gui->AddPanel(1002, 18, 136, 100, 8, Color{ 0, 0, 0, 255 });

	m_Gui->AddPanel(1003, 18, 136, 100, 8, Color{ 128, 255, 128, 255 });

	m_Gui->AddPanel(1004, 18, 136, 100, 8, Color{ 255, 255, 255, 255 }, false);

	m_Gui->m_InputScale = float(g_Engine->m_RenderHeight) / float(g_Engine->m_ScreenHeight);

	m_OptionsGui = new Gui();

	m_OptionsGui->m_Active = false;

	m_OptionsGui->SetLayout(0, 0, 250, 320, g_DrawScale, Gui::GUIP_CENTER);
	m_OptionsGui->AddPanel(1000, 0, 0, 250, 320, Color{ 0, 0, 0, 192 });
	m_OptionsGui->AddPanel(9999, 0, 0, 250, 320, Color{ 255, 255, 255, 255 }, false);
	m_OptionsGui->AddTextArea(1001, g_Font.get(), "", 125, 100, 0, 0, Color{ 255, 255, 255, 255 }, GuiTextArea::CENTERED);
	m_OptionsGui->AddTextButton(1002, 70, 98, "<-", g_Font.get(), Color{ 255, 255, 255, 255 }, Color{ 0, 0, 0, 192 }, Color{ 255, 255, 255, 255 });
	m_OptionsGui->AddTextButton(1003, 170, 98, "->", g_Font.get(), Color{ 255, 255, 255, 255 }, Color{ 0, 0, 0, 192 }, Color{ 255, 255, 255, 255 });

	m_LastUpdate = 0;

	int stopper = 0;

	m_NumberOfVisibleUnits = 0;

	g_CameraMoved = true;

	m_DrawMarker = false;
	m_MarkerRadius = 1.0f;

	m_GuiMode = 0;

	m_showObjects = true;

	// Initialize debug tools window (non-modal, always visible in sandbox mode)
	m_debugToolsWindow = new GhostWindow(
		"GUI/debug_tools.ghost",
		"Data/ghost.cfg",
		g_ResourceManager.get(),
		GetScreenWidth(),
		GetScreenHeight(),
		false);  // non-modal, uses default scale 1.0f

	if (m_debugToolsWindow && m_debugToolsWindow->IsValid())
	{
		// Position on right side of screen, halfway down
		int windowWidth, windowHeight;
		m_debugToolsWindow->GetSize(windowWidth, windowHeight);

		int x = GetScreenWidth() - windowWidth - 10;  // 10px from right edge
		int y = (GetScreenHeight() - windowHeight) / 2;  // Centered vertically

		m_debugToolsWindow->MoveTo(x, y);
		// Will be shown/hidden based on game mode in Update()
	}
	else
	{
		Log("ERROR: Failed to load debug_tools.ghost");
		delete m_debugToolsWindow;
		m_debugToolsWindow = nullptr;
	}

	// Initialize NPC list window
	m_npcListWindow = new NpcListWindow(g_ResourceManager.get(), GetScreenWidth(), GetScreenHeight());
	if (!m_npcListWindow || !m_npcListWindow->IsVisible())
	{
		m_npcListWindow->Hide();  // Start hidden
	}

	SetupGame();

	// Start background pathfinding worker (small pool)
	{
		std::lock_guard<std::mutex> lk(m_scheduleMutex);
		m_pathfinderRunning = true;
	}
	// Determine worker count: prefer (hardware_concurrency - 1) clamped to [1,4]
	{
		unsigned int hw = std::thread::hardware_concurrency();
		int workerCount = 2; // 2 default
		if (hw == 0)
		{
			workerCount = 2;
		}
		else if (hw > 2)
		{
			workerCount = std::min(4u, hw - 1u);
		}
		// Start worker threads
		for (int i = 0; i < workerCount; ++i)
		{
			m_pathfinderThreads.emplace_back(&MainState::PathfindingWorkerLoop, this);
		}
	}
}

void MainState::OnEnter()
{
	g_lastTime = 0;
	g_minute = 0;
	g_hour = 7;
	g_scheduleTime = 2;

	m_heightCutoff = 16.0f; // Draw everything unless the player is inside.

	// Initialize NPC activities based on starting schedule time (for new games)
	// This must happen AFTER g_scheduleTime is set, so NPCs get the correct activity for time slot 1
	InitializeNPCActivitiesFromSchedules();

	if (m_gameMode == MainStateModes::MAIN_STATE_MODE_TRINSIC_DEMO)
	{
		g_Player->AddPartyMember(1);
		// Enable schedules and pathfinding for demo mode so NPCs behave like sandbox
		m_npcSchedulesEnabled = true;
		m_npcPathfindingEnabled = true;

		// Mark loaded NPC objects to follow schedules, except party members
		for (const auto& [id, npcData] : g_NPCData)
		{
			if (!npcData) continue;
			if (npcData->m_objectID < 0) continue;
			// Skip NPCs in player's party so they stay under player control
			if (g_Player && g_Player->NPCIDInParty(id))
				continue;
			auto itObj = g_objectList.find(npcData->m_objectID);
			if (itObj != g_objectList.end() && itObj->second)
			{
				itObj->second->m_followingSchedule = true;
			}
		}

		// Force MainState schedule-check to run on next Update() (enqueue pathfinding)
		g_lastScheduleTimeCheck = -1;
		if (m_loadOnEntry)
		{
			m_loadOnEntry = false;
			m_ranIntroScript = true;
			m_introScriptRunning = false;
			g_isCameraLockedToAvatar = true;
			g_allowInput = true;
			dynamic_cast<LoadSaveState*>(g_StateMachine->GetState(STATE_LOADSAVESTATE))->SetAllowSaving(false);
			OpenLoadSaveGump();

			m_fadeState = FadeState::FADE_IN;
			m_fadeTime = 1.0;
			m_currentFadeAlpha = 0.0f;
			m_fadeDuration = 1.0f;
		}
		// Fade out.
		else
		{
			g_SoundSystem->PlaySound("Audio/Music/35bg.ogg");

			// Move camera to start position and rotation.
			g_camera.target = Vector3{ 1068.0f, 0.0f, 2213.0f };
			g_cameraRotation = 0;
			g_cameraDistance = 22.0f;
			g_isCameraLockedToAvatar = true;
			CameraUpdate();

			// Hack-move Petre and put him in the proper position.
			g_objectList[g_NPCData[11]->m_objectID]->m_Angle = 2 * (PI / 2);
			g_objectList[g_NPCData[11]->m_objectID]->Update();
		}
	}
	else
	{
		m_paused = false;
		g_Player->AddPartyMember(1);

		// Only show welcome messages on first OnEnter, not when returning from dialogs
		if (!m_hasShownWelcomeMessages)
		{
			m_hasShownWelcomeMessages = true;
			ClearConsole();
			AddConsoleString(std::string("Welcome to Ultima VII: Revisited!"));
			AddConsoleString(std::string("Press H at any time for help."));
		}
	}
}

void MainState::OnExit()
{
}

void MainState::Shutdown()
{
	// Stop background worker
	{
		{
			std::lock_guard<std::mutex> lk(m_scheduleMutex);
			m_pathfinderRunning = false;
		}
		m_scheduleCv.notify_all();
		for (auto& t : m_pathfinderThreads)
		{
			if (t.joinable()) t.join();
		}
		m_pathfinderThreads.clear();
	}

	// Clean up debug tools window
	if (m_debugToolsWindow)
	{
		delete m_debugToolsWindow;
		m_debugToolsWindow = nullptr;
	}

	// Clean up NPC list window
	if (m_npcListWindow)
	{
		delete m_npcListWindow;
		m_npcListWindow = nullptr;
	}

	UnloadRenderTexture(g_guiRenderTarget);
	UnloadRenderTexture(g_renderTarget);
}

void MainState::UpdateTime()
{
	if (!m_paused)
	{
		float thisTime = GetTime();
		if (thisTime - g_lastTime >= g_secsPerMinute)
		{
			g_lastTime = thisTime;
			++g_minute;
		}

		if (g_minute >= 60)
		{
			++g_hour;
			g_minute = 0;
		}

		if (g_hour >= 24)
		{
			g_hour = 0;
		}

		g_scheduleTime = g_hour / 3;
	}

	unsigned char darklevel = 64;
	unsigned char red_green_level = (darklevel / 2);

	if (g_hour == 20)
	{
		unsigned char darkness = 255 - ((float(g_minute) / 60.0f) * (255 - darklevel));
		unsigned char red_green = 255 - ((float(g_minute) / 60.0f) * (255 - red_green_level));
		g_dayNightColor = { red_green, red_green, darkness, 255 };
		g_isDay = false;
	}
	else if (g_hour == 6)
	{
		unsigned char darkness = darklevel + ((float(g_minute) / 60.0f) * (255 - darklevel));
		unsigned char red_green = (darklevel / 2.0f) + ((float(g_minute) / 60.0f) * (255 - red_green_level));
		g_dayNightColor = { red_green, red_green, darkness, 255 };
		g_isDay = darkness < .1f;
	}
	else if (g_hour > 20 || g_hour < 6)
	{
		g_dayNightColor = { red_green_level, red_green_level, darklevel, 255 };
		g_isDay = false;
	}
	else
	{
		g_dayNightColor = { 255, 255, 255, 255 };
		g_isDay = true;
	}
}

void MainState::CalculateMouseOverUI()
{
	g_mouseOverUI = false;

	if (!m_showUIElements || m_paused)
	{
		return;
	}

	// Stats panel (right side) - drawn at (512, 200), background is 133x136
	Rectangle statsPanelRect = { 512 * g_DrawScale, 200 * g_DrawScale, 133 * g_DrawScale, 136 * g_DrawScale };

	// Minimap (top-right corner)
	Rectangle minimapRect = {
		g_Engine->m_ScreenWidth - (g_minimapSize * g_DrawScale),
		0,
		g_minimapSize * g_DrawScale,
		g_minimapSize * g_DrawScale
	};

	// Character panel (below minimap)
	Rectangle charPanelRect = {
		g_Engine->m_ScreenWidth - (g_minimapSize * g_DrawScale),
		g_minimapSize * g_DrawScale,
		g_minimapSize * g_DrawScale,
		100 * g_DrawScale
	};

	Vector2 mousePos = GetMousePosition();
	bool overStats = g_InputSystem->IsMouseInRegion(statsPanelRect);
	bool overMinimap = g_InputSystem->IsMouseInRegion(minimapRect);
	bool overCharPanel = g_InputSystem->IsMouseInRegion(charPanelRect);

	// Check if mouse is over debug tools window
	bool overDebugTools = false;
	if (m_debugToolsWindow && m_debugToolsWindow->IsVisible())
	{
		Rectangle debugRect = m_debugToolsWindow->GetBounds();
		overDebugTools = CheckCollisionPointRec(mousePos, debugRect);
	}

	// Check if mouse is over NPC list window
	bool overNpcList = false;
	if (m_npcListWindow && m_npcListWindow->IsVisible())
	{
		Rectangle npcListRect = m_npcListWindow->GetWindow()->GetBounds();
		overNpcList = CheckCollisionPointRec(mousePos, npcListRect);
	}

	g_mouseOverUI = overStats || overMinimap || overCharPanel || overDebugTools || overNpcList || m_demoHelpScreen->m_Active || m_sandboxHelpScreen->m_Active;
}

void MainState::UpdateInput()
{
	if (!g_allowInput)
	{
		if (IsKeyPressed(KEY_ESCAPE) && !g_Engine->m_askedToExit)
		{
			g_Engine->m_askedToExit = true;
			g_StateMachine->PushState(STATE_ASKEXITSTATE);
		}
		return;
	}

	m_handledDoubleLeftClickThisFrame = false;

	HandleEscapeKey();
	HandleDebugKeys();
	HandleGameKeys();
	HandleObjectDrag();
	HandleMiddleClick();
	HandleRightDoubleClick();
	HandleMouseHoldTimers();
	HandleLeftDoubleClick();
	HandleLeftSingleClick();
	HandleAvatarMovement();
}

////////////////////////////////////////////////////////////////////////////////
// UpdateInput() sub-handlers
////////////////////////////////////////////////////////////////////////////////

void MainState::HandleEscapeKey()
{
	if (!IsKeyPressed(KEY_ESCAPE))
		return;

	if (!g_gumpManager->m_GumpList.empty())
		g_gumpManager->m_GumpList.back().get()->SetIsDead(true);
	else if (!g_Engine->m_askedToExit)
	{
		g_Engine->m_askedToExit = true;
		g_StateMachine->PushState(STATE_ASKEXITSTATE);
	}

	if (m_objectSelectionMode)
	{
		g_ScriptingSystem->ResumeCoroutine(m_luaFunction, {0});
		m_doingObjectSelection = false;
		m_objectSelectionMode = false;
		m_luaFunction.clear();
	}
}

void MainState::HandleDebugKeys()
{
	if (IsKeyPressed(KEY_F1))
		g_StateMachine->MakeStateTransition(STATE_SHAPEEDITORSTATE);

	if (IsKeyPressed(KEY_F5))
		g_isCameraLockedToAvatar = !g_isCameraLockedToAvatar;

	if (IsKeyPressed(KEY_F7))
	{
		m_allowMovingStaticObjects = !m_allowMovingStaticObjects;
		AddConsoleString(m_allowMovingStaticObjects ? "DEBUG: Can now move static objects" : "DEBUG: Static objects locked");
	}

	if (IsKeyPressed(KEY_F6))
	{
		g_pixelated = !g_pixelated;
	}

	if (IsKeyPressed(KEY_F8))
	{
		g_LuaDebug = !g_LuaDebug;
		AddConsoleString(g_LuaDebug ? "Lua debug mode ENABLED" : "Lua debug mode DISABLED");
	}

	if (IsKeyPressed(KEY_F10))
	{
		m_showPathfindingDebug = !m_showPathfindingDebug;
		AddConsoleString(m_showPathfindingDebug ? "Pathfinding Debug ON - showing tile walkability with objects" : "Pathfinding Debug OFF");
	}

	if (IsKeyPressed(KEY_F11) && m_gameMode == MainStateModes::MAIN_STATE_MODE_SANDBOX)
	{
		g_showScriptedObjects = !g_showScriptedObjects;
		AddConsoleString(g_showScriptedObjects ? "Script Debug ON - highlighting objects with scripts" : "Script Debug OFF");
	}

	if (IsKeyDown(KEY_LEFT_CONTROL) && IsKeyPressed(KEY_L))
		DumpNpcScheduleStats();

	if (m_showPathfindingDebug && g_InputSystem->WasRButtonClicked())
	{
		int worldX = (int)floor(g_terrainUnderMousePointer.x);
		int worldZ = (int)floor(g_terrainUnderMousePointer.z);
		g_pathfindingSystem->m_pathfindingGrid->DebugPrintTileInfo(worldX, worldZ);
	}
}

void MainState::HandleGameKeys()
{
	if (IsKeyPressed(KEY_KP_ENTER))
	{
		++g_hour;
		if (g_hour >= 24)
			g_hour = 0;
	}

	if (IsKeyPressed(KEY_SPACE))
		m_paused = !m_paused;

	if (IsKeyPressed(KEY_H))
	{
		if (m_gameMode == MainStateModes::MAIN_STATE_MODE_TRINSIC_DEMO)
		{
			m_demoHelpScreen->m_Active = true;
		}
		else
		{
			m_sandboxHelpScreen->m_Active = true;
		}
	}

	// Skip to next hour (Sandbox mode only)
	if (IsKeyPressed(KEY_RIGHT) && m_gameMode == MainStateModes::MAIN_STATE_MODE_SANDBOX)
	{
		g_hour++;
		if (g_hour >= 24)
			g_hour = 0;
		g_minute = 0;
		AddConsoleString("Time skipped to " + std::to_string(g_hour) + ":00");
	}

	if (IsKeyPressed(KEY_PAGE_UP) && m_gameMode == MainStateModes::MAIN_STATE_MODE_SANDBOX)
	{
		if (m_heightCutoff == 0.0f)
		{
			m_showObjects = true;
			m_heightCutoff = 4.0f;
			AddConsoleString("Viewing First Floor");
		}
		else if (m_heightCutoff == 4.0f)
		{
			m_heightCutoff = 10.0f;
			AddConsoleString("Viewing Second Floor");
		}
		else if (m_heightCutoff == 10.0f)
		{
			m_heightCutoff = 16.0f;
			AddConsoleString("Viewing Third Floor");
		}
	}

	if (IsKeyPressed(KEY_PAGE_DOWN) && m_gameMode == MainStateModes::MAIN_STATE_MODE_SANDBOX)
	{
		if (m_heightCutoff == 16.0f)
		{
			m_heightCutoff = 10.0f;
			AddConsoleString("Viewing Second Floor");
		}
		else if (m_heightCutoff == 10.0f)
		{
			m_heightCutoff = 4.0f;
			AddConsoleString("Viewing First Floor");
		}
		else if (m_heightCutoff == 4.0f)
		{
			m_heightCutoff = 0.0f;
			m_showObjects = false;
			AddConsoleString("Viewing Ground");
		}
	}

	if (IsKeyPressed(KEY_KP_SUBTRACT) || IsKeyPressed(KEY_MINUS))
	{
		g_secsPerMinute -= 0.1f;
		if (g_secsPerMinute < 0.1f)
			g_secsPerMinute = 0.1f;
		else
			AddConsoleString("Time Speed: " + to_string(g_secsPerMinute) + " seconds per minute");
	}

	if (IsKeyPressed(KEY_KP_ADD) || IsKeyPressed(KEY_EQUAL))
	{
		g_secsPerMinute += 0.1f;
		if (g_secsPerMinute > 5.0f)
			g_secsPerMinute = 5.0f;
		else
			AddConsoleString("Time Speed: " + to_string(g_secsPerMinute) + " seconds per minute");
	}
}

void MainState::HandleObjectDrag()
{
	if (!g_InputSystem->IsLButtonDown())
	{
		m_dragStart = { 0, 0 };
		return;
	}

	if (g_objectUnderMousePointer == nullptr || g_gumpManager->m_isMouseOverGump ||
		g_gumpManager->m_draggingObject || g_gumpManager->IsAnyGumpBeingDragged() || g_mouseOverUI)
		return;

	// Keep shape editor in sync with whatever object is under the cursor
	g_selectedShape = g_objectUnderMousePointer->m_shapeData->m_shape;
	g_selectedFrame = g_objectUnderMousePointer->m_shapeData->m_frame;

	// if (m_doingObjectSelection)
	// {
	// 	g_ScriptingSystem->ResumeCoroutine(m_luaFunction, { g_objectUnderMousePointer->m_ID });
	// 	m_doingObjectSelection = false;
	// 	m_objectSelectionMode = false;
	// 	m_luaFunction.clear();
	// }

	if (!m_allowMovingStaticObjects && g_objectUnderMousePointer->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_STATIC)
		return;

	if (m_dragStart.x == 0 && m_dragStart.y == 0)
	{
		m_dragStart = GetMousePosition();
	}
	else if (Vector2DistanceSqr(m_dragStart, GetMousePosition()) > 4 * g_DrawScale)
	{
		g_gumpManager->m_draggedObjectId = g_objectUnderMousePointer->m_ID;
		g_gumpManager->m_draggingObject = true;
		g_gumpManager->m_sourceGump = nullptr;
		g_gumpManager->m_sourceSlotIndex = -1;
		g_gumpManager->m_draggedObjectOriginalPos = g_objectUnderMousePointer->m_Pos;
		g_gumpManager->m_draggedObjectOriginalDest = g_objectUnderMousePointer->m_Dest;
		g_objectUnderMousePointer->m_isContained = true;
		Log("Removed object " + std::to_string(g_objectUnderMousePointer->m_ID) + " from world on drag start");
		g_gumpManager->CloseGumpForObject(g_objectUnderMousePointer->m_ID);
	}
}

void MainState::HandleMiddleClick()
{
	if (!g_InputSystem->WasMButtonClicked() || g_objectUnderMousePointer == nullptr || g_mouseOverUI)
		return;

	string scriptName;
	if (g_objectUnderMousePointer->m_hasConversationTree)
	{
		int NPCId = g_objectUnderMousePointer->m_NPCID;
		stringstream ss;
		ss << "func_04" << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << NPCId;
		scriptName = ss.str();
	}
	else
	{
		stringstream ss;
		ss << "func_0" << std::setw(3) << std::setfill('0') << std::hex << std::uppercase << g_objectUnderMousePointer->m_shapeData->m_shape;
		scriptName = ss.str();
	}

	int scriptIndex = 0;
	bool validScript = false;
	for (int i = 0; i < (int)g_ScriptingSystem->m_scriptFiles.size(); ++i)
	{
		if (g_ScriptingSystem->m_scriptFiles[i].first == scriptName)
		{
			scriptIndex = i;
			validScript = true;
			break;
		}
	}

	if (!validScript)
	{
		AddConsoleString("No script for object " + to_string(g_objectUnderMousePointer->m_shapeData->m_shape) +
			" (" + g_objectUnderMousePointer->m_objectData->m_name + ")");
		return;
	}

	std::string filePath = g_ScriptingSystem->m_scriptFiles[scriptIndex].second;
#ifdef _WIN32
	system(("start \"\" \"" + filePath + "\"").c_str());
#elif __APPLE__
	system(("open \"" + filePath + "\"").c_str());
#else
	system(("xdg-open \"" + filePath + "\"").c_str());
#endif
}

void MainState::HandleRightDoubleClick()
{
	if (!g_InputSystem->WasRButtonDoubleClicked())
		return;

	if (g_objectUnderMousePointer != nullptr)
	{
		// Pathfind onto walkable surfaces (stairs, rooftops, etc.) — skip interactive objects
		if (g_objectUnderMousePointer->m_isContainer ||
			g_objectUnderMousePointer->m_objectData->m_isDoor ||
			g_objectUnderMousePointer->m_hasConversationTree ||
			g_objectUnderMousePointer->m_shapeData->m_luaScript != "default")
			return;

		int objTileX = (int)floor(g_objectUnderMousePointer->m_Pos.x);
		int objTileZ = (int)floor(g_objectUnderMousePointer->m_Pos.z);

		float surfaceY = g_objectUnderMousePointer->m_Pos.y;
		if (g_objectUnderMousePointer->m_objectData)
			surfaceY += g_objectUnderMousePointer->m_objectData->m_height;

		bool hasWalkableLayer = false;
		if (g_pathfindingSystem && g_pathfindingSystem->m_pathfindingGrid)
		{
			g_pathfindingSystem->m_pathfindingGrid->DebugPrintTileInfo(objTileX, objTileZ);
			auto heights = g_pathfindingSystem->m_pathfindingGrid->GetWalkableSurfaceHeights(objTileX, objTileZ);
			if (!heights.empty())
			{
				for (float h : heights)
				{
					if (h > 0.1f) { hasWalkableLayer = true; surfaceY = h; break; }
				}
				if (heights.size() > 1) hasWalkableLayer = true;
			}
		}

		if (hasWalkableLayer)
		{
			U7Object* avatar = g_objectList[g_NPCData[0]->m_objectID].get();
			if (avatar)
				avatar->PathfindToDest({ (float)objTileX, surfaceY, (float)objTileZ });
		}
	}
	else if (!g_mouseOverUI && !g_gumpManager->m_isMouseOverGump)
	{
		int worldX = (int)floor(g_terrainUnderMousePointer.x);
		int worldZ = (int)floor(g_terrainUnderMousePointer.z);

		U7Object* avatar = g_objectList[g_NPCData[0]->m_objectID].get();
		avatar->PathfindToDest({ float(worldX), 0, float(worldZ) });

		int counter = 1;
		for (int id : g_Player->GetPartyMemberIds())
		{
			U7Object* partyMember = g_objectList[g_NPCData[id]->m_objectID].get();
			if (id % 2 == 0)
				partyMember->PathfindToDest({ float(worldX + counter), 0, float(worldZ + counter) });
			else
				partyMember->PathfindToDest({ float(worldX + counter), 0, float(worldZ - counter) });
			counter++;
		}

		if (worldX >= 0 && worldX < 3072 && worldZ >= 0 && worldZ < 3072)
		{
			unsigned short shapeframe = g_World[worldZ][worldX];
			int shapeID = shapeframe & 0x3ff;
			int frameID = (shapeframe >> 10) & 0x3f;
			string terrainName = g_pathfindingSystem->GetTerrainName(shapeID);
			AddConsoleString("=== " + terrainName + " (" + to_string(worldX) + ", " + to_string(worldZ) + ") ===", SKYBLUE);
			AddConsoleString("  Shape ID: " + to_string(shapeID) + ", Frame: " + to_string(frameID), WHITE);
			AddConsoleString("  Movement Cost: " + to_string(g_pathfindingSystem->GetMovementCost(worldX, worldZ)), GREEN);
			AddConsoleString("  Walkable: YES", GREEN);
		}
	}
}

void MainState::HandleMouseHoldTimers()
{
	double now = GetTime();

	if (g_InputSystem->IsRButtonDown() && !g_mouseOverUI && !g_gumpManager->m_isMouseOverGump)
	{
		if (m_rightMouseHoldStart == 0.0f)
			m_rightMouseHoldStart = (float)now;
		else if (!m_rightMouseHeld && (now - m_rightMouseHoldStart) >= m_rightMouseHoldThreshold)
			m_rightMouseHeld = true;
	}
	else
	{
		m_rightMouseHoldStart = 0.0f;
		m_rightMouseHeld = false;
	}

	if (g_InputSystem->IsLButtonDown() && !g_mouseOverUI && !g_gumpManager->m_isMouseOverGump)
	{
		if (m_leftMouseHoldStart == 0.0f)
			m_leftMouseHoldStart = (float)now;
		else if (!m_leftMouseHeld && (now - m_leftMouseHoldStart) >= m_leftMouseHoldThreshold)
			m_leftMouseHeld = true;
	}
	else
	{
		m_leftMouseHoldStart = 0.0f;
		m_leftMouseHeld = false;
	}

	HandleRightMouseHoldMovement();
}

void MainState::HandleRightMouseHoldMovement()
{
	if (!m_rightMouseHeld || g_mouseOverUI || g_gumpManager->m_isMouseOverGump || !g_isCameraLockedToAvatar)
	{
		if (m_cameraDragging)
			EndCameraDrag();
		return;
	}

	U7Object* avatar = g_Player ? g_Player->GetAvatarObject() : nullptr;
	if (!avatar)
		return;

	Vector3 toMouse = Vector3Subtract(g_terrainUnderMousePointer, avatar->GetPos());
	toMouse.y = 0.0f;
	float dist = Vector3Length(toMouse);

	const float DEADZONE = 0.25f;
	if (dist > DEADZONE)
	{
		Vector3 dir = Vector3Normalize(toMouse);

		const float MAX_EFFECT_DISTANCE = 10.0f;
		const float MIN_SPEED_MULT = 0.20f;
		const float MAX_SPEED_MULT = 1.50f;
		float t = std::fmin(std::fmax(dist / MAX_EFFECT_DISTANCE, 0.0f), 1.0f);
		float speedMult = MIN_SPEED_MULT + (MAX_SPEED_MULT - MIN_SPEED_MULT) * t;
		float baseSpeed = avatar->GetSpeed();
		if (baseSpeed <= 0.0f) baseSpeed = 3.0f;

		float dt = GetFrameTime();
		Vector3 desired = Vector3Add(avatar->GetPos(), Vector3Scale(dir, baseSpeed * speedMult * dt));
		desired.x = std::fmax(0.0f, std::fmin(3072.0f, desired.x));
		desired.z = std::fmax(0.0f, std::fmin(3072.0f, desired.z));

		if (g_Player)
			g_Player->TryMove(desired);
		else
			avatar->SetDest(desired);

		if (Vector3Length(dir) > 0.0001f)
		{
			Vector3 flatDir = Vector3Normalize(dir);
			g_Player->SetPlayerDirection(flatDir);
			avatar->m_Direction = flatDir;
		}
	}

	// Hold Left+Right together to drag the camera
	if (m_leftMouseHeld)
	{
		if (!m_cameraDragging)
			StartCameraDrag();
		UpdateCameraDrag();
	}
	else if (m_cameraDragging)
	{
		EndCameraDrag();
	}
}

void MainState::HandleLeftDoubleClick()
{
	if (!g_InputSystem->WasLButtonDoubleClicked())
		return;

	if (g_objectUnderMousePointer != nullptr)
	{
		bool isAvatar = g_objectUnderMousePointer->m_isNPC && g_objectUnderMousePointer->m_NPCID == 0;
		bool isPartyMember = g_objectUnderMousePointer->m_isNPC &&
			g_Player->NPCIDInParty(g_objectUnderMousePointer->m_NPCID);

		if (isAvatar || isPartyMember)
		{
			int npcId = g_objectUnderMousePointer->m_NPCID;
			bool anyPaperdollOpen = HasAnyPaperdollOpen();
			Log("Double-clicked NPC " + std::to_string(npcId) +
				", isAvatar=" + std::to_string(isAvatar) +
				", anyPaperdollOpen=" + std::to_string(anyPaperdollOpen));

			if (isAvatar || anyPaperdollOpen)
				TogglePaperdoll(npcId);
			else
			{
				Log("Running normal interaction for NPC " + std::to_string(npcId));
				m_handledDoubleLeftClickThisFrame = true;
				g_objectUnderMousePointer->Interact(1);
			}
		}
		else if (g_objectUnderMousePointer->m_objectData->m_isDoor ||
			g_objectUnderMousePointer->m_hasConversationTree ||
			g_objectUnderMousePointer->m_shapeData->m_luaScript != "default")
		{
			if (!m_objectSelectionMode)
			{
				m_handledDoubleLeftClickThisFrame = true;
				g_objectUnderMousePointer->Interact(1);
			}
		}
		else if (g_objectUnderMousePointer->m_isContainer && !g_objectUnderMousePointer->IsLocked())
		{
			m_handledDoubleLeftClickThisFrame = true;
			OpenGump(g_objectUnderMousePointer->m_ID);
		}
		else if (g_objectUnderMousePointer->m_isContainer)
		{
			m_handledDoubleLeftClickThisFrame = true;
			Bark(g_objectUnderMousePointer, "Locked", 3.0f);
		}
	}
	else if (!g_mouseOverUI && !g_gumpManager->m_isMouseOverGump)
	{
		int worldX = (int)floor(g_terrainUnderMousePointer.x);
		int worldZ = (int)floor(g_terrainUnderMousePointer.z);
		if (worldX >= 0 && worldX < 3072 && worldZ >= 0 && worldZ < 3072)
		{
			unsigned short shapeframe = g_World[worldZ][worldX];
			int shapeID = shapeframe & 0x3ff;
			int frameID = (shapeframe >> 10) & 0x3f;
			string terrainName = g_pathfindingSystem->GetTerrainName(shapeID);
			AddConsoleString("=== " + terrainName + " (" + to_string(worldX) + ", " + to_string(worldZ) + ") ===", SKYBLUE);
			AddConsoleString("  Shape ID: " + to_string(shapeID) + ", Frame: " + to_string(frameID), WHITE);
			AddConsoleString("  Movement Cost: " + to_string(g_pathfindingSystem->GetMovementCost(worldX, worldZ)), GREEN);
			AddConsoleString("  Walkable: YES", GREEN);
		}
	}
}

void MainState::HandleLeftSingleClick()
{
	if (!g_InputSystem->WasLButtonClicked())
		return;

	if (g_gumpManager->m_isMouseOverGump || g_gumpManager->m_draggingObject || g_mouseOverUI)
		return;

	if (g_objectUnderMousePointer != nullptr)
	{
		if (m_objectSelectionMode)
		{
			if (g_ScriptingSystem->IsCoroutineYielded(m_luaFunction))
			{
				m_objectSelectionMode = false;
				g_ScriptingSystem->ResumeCoroutine(m_luaFunction, { g_objectUnderMousePointer->m_ID });
			}
		}
		else
		{
			//Bark(g_objectUnderMousePointer, GetObjectDisplayName(g_objectUnderMousePointer), 1.0f);

			if (g_objectUnderMousePointer->m_isNPC && m_npcListWindow && m_npcListWindow->IsVisible())
				m_npcListWindow->SelectNPC(g_objectUnderMousePointer->m_NPCID);

			if (g_LuaDebug && g_objectUnderMousePointer->m_isNPC)
				DebugPrintNpcSchedule(g_objectUnderMousePointer);
		}
	}
}

void MainState::DebugPrintNpcSchedule(U7Object* npc)
{
	int npcID = npc->m_NPCID;

	if (g_NPCSchedules.find(npcID) == g_NPCSchedules.end() || g_NPCSchedules[npcID].empty())
	{
		AddConsoleString("  No schedule data for this NPC");
	}
	else
	{
		vector<int> sortedIndices(g_NPCSchedules[npcID].size());
		for (int i = 0; i < (int)sortedIndices.size(); i++)
			sortedIndices[i] = i;

		std::sort(sortedIndices.begin(), sortedIndices.end(),
			[npcID](int a, int b) {
				return g_NPCSchedules[npcID][a].m_time < g_NPCSchedules[npcID][b].m_time;
			});

		// Find the currently active schedule block
		int activeScheduleIndex = -1;
		for (int idx : sortedIndices)
		{
			if (g_NPCSchedules[npcID][idx].m_time <= g_scheduleTime)
				activeScheduleIndex = idx;
			else
				break;
		}
		if (activeScheduleIndex == -1 && !g_NPCSchedules[npcID].empty())
			activeScheduleIndex = sortedIndices.back();

		for (int idx : sortedIndices)
		{
			const auto& schedule = g_NPCSchedules[npcID][idx];
			string timeStr;
			switch (schedule.m_time)
			{
			case 0: timeStr = "0:00 (Midnight)"; break;
			case 1: timeStr = "3:00";  break;
			case 2: timeStr = "6:00";  break;
			case 3: timeStr = "9:00";  break;
			case 4: timeStr = "12:00 (Noon)"; break;
			case 5: timeStr = "15:00"; break;
			case 6: timeStr = "18:00"; break;
			case 7: timeStr = "21:00"; break;
			default: timeStr = to_string(schedule.m_time); break;
			}
			Color lineColor = (idx == activeScheduleIndex) ? GOLD : WHITE;
			AddConsoleString("  [" + to_string(idx) + "] Time: " + timeStr +
				", Dest: (" + to_string(schedule.m_destX) + ", " + to_string(schedule.m_destY) + ")" +
				", Activity: " + to_string(schedule.m_activity), lineColor);
		}
	}

	if (npc->m_pathWaypoints.empty())
		AddConsoleString("No active waypoints", GRAY);
}

void MainState::HandleAvatarMovement()
{
	if (!g_isCameraLockedToAvatar)
		return;

	if (g_firstPersonEnabled)
	{
		U7Object* avatar = g_Player->GetAvatarObject();
		if (!avatar) return;

		float dt = GetFrameTime();
		Vector3 camForward = Vector3Subtract(g_camera.target, g_camera.position);
		camForward.y = 0.0f;
		if (Vector3Length(camForward) < 0.0001f)
		{
			camForward = avatar->m_Direction;
			camForward.y = 0.0f;
		}
		Vector3 flatForward = Vector3Normalize(camForward);
		Vector3 right = Vector3Normalize(Vector3{ flatForward.z, 0.0f, -flatForward.x });

		float speed = g_Player->GetAvatarObject()->GetSpeed();
		Vector3 move = { 0.0f, 0.0f, 0.0f };
		if (IsKeyDown(KEY_W)) move = Vector3Add(move, Vector3Scale(flatForward,  speed * dt));
		if (IsKeyDown(KEY_S)) move = Vector3Add(move, Vector3Scale(flatForward, -speed * dt));
		if (IsKeyDown(KEY_D)) move = Vector3Add(move, Vector3Scale(right,       -speed * dt));
		if (IsKeyDown(KEY_A)) move = Vector3Add(move, Vector3Scale(right,        speed * dt));

		if (move.x != 0.0f || move.z != 0.0f)
		{
			Vector3 finalDest = Vector3Add(g_Player->GetAvatarObject()->GetPos(), move);
			finalDest.x = std::fmax(0.0f, std::fmin(3072.0f, finalDest.x));
			finalDest.z = std::fmax(0.0f, std::fmin(3072.0f, finalDest.z));

			if (g_Player)
				g_Player->TryMove(finalDest);
			else
				g_Player->GetAvatarObject()->SetDest(finalDest);

			Vector3 flatForDir = Vector3Normalize(flatForward);
			if (Vector3Length(flatForDir) > 0.0001f)
			{
				g_Player->SetPlayerDirection(flatForDir);
				g_Player->GetAvatarObject()->m_Direction = flatForDir;
			}
		}
	}
	else
	{
		// Rotation-based movement
		Vector3 direction = { 0, 0, 0 };
		bool avatarMoved = false;
		//float speed = g_Player->GetAvatarObject()->GetSpeed() * GetFrameTime();

		if (IsKeyDown(KEY_A)) { direction = Vector3Add(direction, { -1,  0, 1 }); avatarMoved = true; }
		if (IsKeyDown(KEY_D)) { direction = Vector3Add(direction, {  1,  0, -1 }); avatarMoved = true; }
		if (IsKeyDown(KEY_W)) { direction = Vector3Add(direction, { -1,  0, -1 }); avatarMoved = true; }
		if (IsKeyDown(KEY_S)) { direction = Vector3Add(direction, {  1,  0,  1 }); avatarMoved = true; }

		if (avatarMoved)
		{
			direction = Vector3Normalize(direction);
			//direction = Vector3Multiply(direction, {speed, speed, speed} );
			direction = Vector3RotateByAxisAngle(direction, Vector3{ 0, 1, 0 }, g_cameraRotation);
			Vector3 desired = Vector3Add(g_Player->GetAvatarObject()->GetPos(), direction);

			g_Player->TryMove(desired);
		}
	}

	MaybeUpdatePartyFollowing();
}


void MainState::StartCameraDrag()
{
	// Record lock point (use current mouse pos by default)
	m_cameraDragLockPos = GetMousePosition();
	// Center-locking option: set to screen center instead if you prefer
	// m_cameraDragLockPos = { float(GetScreenWidth())/2.0f, float(GetScreenHeight())/2.0f };

	// Initialize state
	m_cameraDragging = true;
	m_cameraDragLockPos.x = std::round(m_cameraDragLockPos.x);
	m_cameraDragLockPos.y = std::round(m_cameraDragLockPos.y);

	// Disable/hide OS cursor (raylib)
	DisableCursor();
	m_cursorLocked = true;

	// Ensure pointer visually stays at lock pos
	SetMousePosition((int)m_cameraDragLockPos.x, (int)m_cameraDragLockPos.y);
}

void MainState::UpdateCameraDrag()
{
	if (!m_cameraDragging) return;

	// Use raylib delta for smooth rotation while cursor is locked
	Vector2 delta = GetMouseDelta();

	// Apply horizontal drag to camera rotation (yaw)
	g_cameraRotation += -delta.x * m_cameraDragSensitivity; // flip sign if direction feels reversed
	g_CameraMoved = true;

	// Keep cursor pinned (safety) so it doesn't wander visually on some platforms
	SetMousePosition((int)m_cameraDragLockPos.x, (int)m_cameraDragLockPos.y);
}

void MainState::EndCameraDrag()
{
	if (m_cursorLocked)
	{
		EnableCursor();
		m_cursorLocked = false;
	}
	m_cameraDragging = false;
}
void MainState::Bark(U7Object* object, const std::string& text, float duration)
{
	m_barkDuration = duration;
	m_barkObject = object;

	// If text is empty, auto-generate it from object's shape/frame/quantity each frame
	if (text.empty() && object)
	{
		m_barkAutoUpdate = true;
		m_barkText = GetObjectDisplayName(object);
	}
	else
	{
		m_barkAutoUpdate = false;
		m_barkText = text;
	}
}

void MainState::Update()
{
	// Decrement error cursor frame counter
	if (m_errorCursorFramesRemaining > 0)
	{
		m_errorCursorFramesRemaining--;
	}

	UpdateTime();

	if (MainStateModes::MAIN_STATE_MODE_TRINSIC_DEMO == m_gameMode && m_ranIntroScript && g_allowInput && !m_helpConsoleLineShown)
	{
		AddConsoleString("Welcome to Ultima VII Revisited!", WHITE);
		AddConsoleString("Press H for help.", WHITE);
		m_helpConsoleLineShown = true;
	}

	m_demoHelpScreen->Update();
	if (m_demoHelpScreen->m_ActiveElement == GUI_DEMO_HELP_BACK)
	{
		m_demoHelpScreen->m_Active = false;
	}

	m_sandboxHelpScreen->Update();
	if (m_sandboxHelpScreen->m_ActiveElement == GUI_SANDBOX_HELP_BACK)
	{
		m_sandboxHelpScreen->m_Active = false;
	}

	unsigned short currentTargetTile = g_World[(int)g_camera.target.z][(int)g_camera.target.x];
	currentTargetTile = currentTargetTile & 0x3ff; // We just need the shape, not the frame.
	if (MainStateModes::MAIN_STATE_MODE_SANDBOX != m_gameMode)
	{
		U7Object* avatar = (g_Player ? g_Player->GetAvatarObject() : nullptr);
		if (currentTargetTile == 0 || currentTargetTile == 5 || currentTargetTile == 17 || currentTargetTile == 18 ||
			currentTargetTile == 21 || currentTargetTile == 23 || currentTargetTile == 27 || currentTargetTile == 47 || currentTargetTile >= 149)
		{
			float avatarY = avatar->m_Pos.y;
			if (avatarY < 3.5f) m_heightCutoff = 4.0f;
			else if (avatarY < 11.0f) m_heightCutoff = 10.0f;
			else m_heightCutoff = 16.0f;
		}
		else
		{
			m_heightCutoff = 16.0f;
		}
	}

	// Check if schedule time has changed and populate pathfinding queue
	if (g_scheduleTime != g_lastScheduleTimeCheck)
	{
		// Update last-checked value immediately to avoid re-entrancy in this frame
		g_lastScheduleTimeCheck = g_scheduleTime;

		// Walk every NPC and update those that follow schedules
		for (const auto& [npcID, npcDataPtr] : g_NPCData)
		{
			if (!npcDataPtr) continue;
			NPCData* npcData = npcDataPtr.get();
			if (npcData->m_objectID < 0) continue;

			// Skip NPCs without schedules or that are not following schedules
			auto schedulesIt = g_NPCSchedules.find(npcID);
			if (schedulesIt == g_NPCSchedules.end() || schedulesIt->second.empty())
				continue;

			U7Object* npcObj = nullptr;
			auto objIt = g_objectList.find(npcData->m_objectID);
			if (objIt != g_objectList.end())
				npcObj = objIt->second.get();

			if (!npcObj) continue;
			if (!npcObj->m_followingSchedule) continue;

			// Find an exact schedule entry for the current timeslot (g_scheduleTime)
			const NPCSchedule* exactSchedule = nullptr;
			for (const auto& s : schedulesIt->second)
			{
				if ((int)s.m_time == (int)g_scheduleTime)
				{
					exactSchedule = &s;
					break;
				}
			}

			// If there is no exact entry for this timeslot, do not change activity (preserve current).
			if (!exactSchedule)
				continue;

			// If activity or last-schedule time changed, apply update
			bool activityChanged = (npcData->m_currentActivity != (int)exactSchedule->m_activity);
			bool timeChanged = (npcObj->m_lastSchedule != (int)g_scheduleTime);

			if (activityChanged || timeChanged)
			{
				// Update NPC activity and last schedule marker
				npcData->m_currentActivity = (int)exactSchedule->m_activity;
				npcObj->m_lastSchedule = (int)g_scheduleTime;

				// Clear schedule-path flag; we'll set it when a path is applied.
				npcObj->m_isSchedulePath = false;

				// Build destination
				Vector3 dest = { float(exactSchedule->m_destX), 0.0f, float(exactSchedule->m_destY) };

				// If pathfinding is enabled, enqueue path request for worker thread.
				if (m_npcPathfindingEnabled)
				{
					// Skip if we already have a pending path for this NPC or dest matches current dest
					if (npcObj->m_pathfindingPending)
					{
						// already pending -> skip
					}
					else if ((int)npcObj->m_Dest.x == (int)dest.x && (int)npcObj->m_Dest.z == (int)dest.z)
					{
						// already destined to same tile -> skip
						npcObj->m_isSchedulePath = true; // keep state consistent
					}
					else
					{
						// Mark pending AFTER we decide to enqueue to avoid races / duplicate pushes
						npcObj->m_pathfindingPending = true;

						SchedulePathRequest req;
						req.npcID = npcID;
						req.start = npcObj->GetPos();  // snapshot start position now
						req.dest = dest;

						{
							std::lock_guard<std::mutex> lk(m_scheduleMutex);
							m_schedulePathQueue.push_back(std::move(req));
						}
						m_scheduleCv.notify_one();
					}
				}
				else
				{
					// Pathfinding disabled: teleport NPC to scheduled location immediately.
					npcObj->SetPos(dest);
					npcObj->SetDest(dest);
					npcObj->m_isSchedulePath = false;
					NPCDebugPrint("Schedule: NPC " + std::to_string(npcID) + " teleported to (" +
						std::to_string((int)dest.x) + "," + std::to_string((int)dest.z) + ") (pathfinding disabled)");
				}

				// Ensure activity coroutines will be restarted on next NPC updates
				// (m_lastActivity is managed when coroutines are started/cleaned up inside U7Object::NPCUpdate)
			}
		}
	}

	g_gumpManager->Update();

	if (GetTime() - m_LastUpdate > GetFrameTime())
	{
		g_CurrentUpdate++;

		// Reset per-frame scripting counters to enforce throttling budgets
		if (g_ScriptingSystem)
		{
			g_ScriptingSystem->ResetPerFrameScriptCounters();
		}

		m_NumberOfVisibleUnits = 0;
		m_numberofDrawnObjects = 0;
		m_numberofObjectsPassingFirstCheck = 0;

		// Apply any completed paths from the background worker
		{
			// Measure time spent applying results this frame (helps identify main-thread stall)
			float applyStart = GetTime();
			std::lock_guard<std::mutex> resLock(m_resultMutex);

			int processed = 0;

			// Adaptive budget: reduce work if frame time is high to avoid visible stalls.
			float frameTime = GetFrameTime(); // current frame delta
			int budget = m_schedulePathBudgetPerFrame; // baseline
			if (frameTime > 0.033f)            // worse than ~30 FPS
				budget = 1;
			else if (frameTime > 0.020f)       // between ~30-50 FPS
				budget = std::max(1, m_schedulePathBudgetPerFrame / 3);
			else                                // ~60 FPS or better
				budget = m_schedulePathBudgetPerFrame;

			// Always allow at least one result per frame
			budget = std::max(1, budget);

			while (!m_scheduleResults.empty() && processed < budget)
			{
				auto res = std::move(m_scheduleResults.front());
				m_scheduleResults.pop_front();
				++processed;
				++m_resultsAppliedThisSecond; // telemetry

				// Validate NPC & object
				auto itNpc = g_NPCData.find(res.npcID);
				if (itNpc == g_NPCData.end() || !itNpc->second) continue;
				int objId = itNpc->second->m_objectID;
				auto itObj = g_objectList.find(objId);
				if (itObj == g_objectList.end() || !itObj->second) continue;
				U7Object* npcObj = itObj->second.get();

				if (res.success && !res.path.empty())
				{
					// Assign waypoints computed by worker
					npcObj->m_pathWaypoints = std::move(res.path);
					npcObj->m_pathfindingPending = false;
					npcObj->m_isSchedulePath = true;

					// Determine starting index (mirror PathfindToDest logic)
					if (npcObj->m_pathWaypoints.size() > 1)
						npcObj->m_currentWaypointIndex = 1;
					else
						npcObj->m_currentWaypointIndex = 0;

					if (npcObj->m_currentWaypointIndex >= 0 && npcObj->m_currentWaypointIndex < static_cast<int>(npcObj->m_pathWaypoints.size()))
					{
						npcObj->SetDest(npcObj->m_pathWaypoints[npcObj->m_currentWaypointIndex]);
						npcObj->m_isMoving = true;
					}

					// Keep a concise debug print (can be gated by a flag)
					NPCDebugPrint("Schedule: NPC " + std::to_string(res.npcID) + " assigned path to (" +
						std::to_string((int)res.dest.x) + "," + std::to_string((int)res.dest.z) + ") (background)");
				}
				else
				{
					// No path found: teleport as fallback and clear pending flag.
					npcObj->SetPos(res.dest);
					npcObj->SetDest(res.dest);
					npcObj->m_isSchedulePath = false;
					npcObj->m_pathfindingPending = false;
					NPCDebugPrint("Schedule: NPC " + std::to_string(res.npcID) + " had no path, teleported (" +
						std::to_string((int)res.dest.x) + "," + std::to_string((int)res.dest.z) + ")");
				}
			}

			float applyEnd = GetTime();
			float applyMs = (applyEnd - applyStart) * 1000.0f;
			// Optionally log heavy apply cost (only if > 10ms to avoid noise)
			if (applyMs > 10.0f)
			{
				DebugPrint("MAIN: apply-results took " + std::to_string(applyMs) + " ms, processed=" + std::to_string(processed));
			}
			// leave remainder for next frame if any
		}

		for (const auto& [id, object] : g_objectList)
		{
			if (!object) continue;

			if (!m_paused)
			{
				object->Update();
				if (object->m_Pos.y > m_heightCutoff)
				{
					object->m_Visible = false;
				}
				else
				{
					if (!object->GetIsDead()) object->m_Visible = true;
				}
			}
		}

		for (unordered_map<int, std::unique_ptr<U7Object> >::iterator node = g_objectList.begin(); node != g_objectList.end();)
		{
			if (!node->second)
			{
				++node;
				continue;
			}

			if (node->second->GetIsDead())
			{
				if (g_LuaDebug)
				{
					AddConsoleString("Cleanup: Removing dead object ID " + std::to_string(node->first));
				}
				UnassignObjectChunk(node->second.get());
				node = g_objectList.erase(node);
				if (g_LuaDebug)
				{
					AddConsoleString("Cleanup: Object erased from g_objectList");
				}
			}
			else
			{
				++node;
			}
		}

		// Calculate g_mouseOverUI RIGHT BEFORE UpdateSortedVisibleObjects
		CalculateMouseOverUI();

		UpdateSortedVisibleObjects();

		for (auto& object : g_sortedVisibleObjects)
		{
			object->CheckLighting();
		}

		m_LastUpdate = GetTime();
	}

	if (!m_paused && g_allowInput)
	{
		CameraInput();
	}

	CameraUpdate();

	m_terrainUpdateTime = GetTime();
	g_Terrain->CalculateLighting();

	m_terrainUpdateTime = GetTime() - m_terrainUpdateTime;

	g_Terrain->Update();

	UpdateStats();
	// Show/hide debug tools window based on game mode
	if (m_debugToolsWindow)
	{
		if (m_gameMode == MainStateModes::MAIN_STATE_MODE_SANDBOX)
		{
			if (!m_debugToolsWindow->IsVisible())
			{
				// Position on right side of screen, halfway down
				int windowWidth, windowHeight;
				m_debugToolsWindow->GetSize(windowWidth, windowHeight);

				int x = GetScreenWidth() - windowWidth - 10;  // 10px from right edge
				int y = (GetScreenHeight() - windowHeight) / 2;  // Centered vertically

				m_debugToolsWindow->MoveTo(x, y);
				m_debugToolsWindow->Show();
			}
		}
		else
		{
			if (m_debugToolsWindow->IsVisible())
				m_debugToolsWindow->Hide();
		}

		// Update debug tools window
		m_debugToolsWindow->Update();
		UpdateDebugToolsWindow();
	}

	// Update NPC list window
	if (m_npcListWindow)
	{
		m_npcListWindow->Update(m_npcSchedulesEnabled);
	}

	// Process game input
	UpdateInput();

	if (m_barkDuration > 0 && m_barkObject != nullptr)
	{
		m_barkDuration -= GetFrameTime();
		if (m_barkDuration <= 0)
		{
			m_barkDuration = 0;
			m_barkObject = nullptr;
			m_barkText = "";
		}
	}

	if (m_waitTime > 0)
	{
		m_waitTime -= GetFrameTime();
		if (m_waitTime < 0)
		{
			m_waitTime = 0;
			g_ScriptingSystem->ResumeCoroutine(m_luaFunction, { 0 }); // Lua arrays are 1-indexed
		}
	}

	if (m_fadeState == FadeState::FADE_OUT)
	{
		m_fadeTime += GetFrameTime();
		if (m_fadeTime > m_fadeDuration)
		{
			m_fadeTime = m_fadeDuration;
			m_fadeState = FadeState::FADE_NONE;
		}
		m_currentFadeAlpha = int(255 * (m_fadeTime / m_fadeDuration));
	}

	else if (m_fadeState == FadeState::FADE_IN)
	{
		m_fadeTime -= GetFrameTime();
		if (m_fadeTime < 0)
		{
			m_fadeTime = 0;
			m_fadeState = FadeState::FADE_NONE;
		}
		m_currentFadeAlpha = int(255 * (m_fadeTime / m_fadeDuration));
	}
	else
	{
		m_currentFadeAlpha = 0;
	}

	if (m_gameMode == MainStateModes::MAIN_STATE_MODE_TRINSIC_DEMO)
	{
		if (m_ranIntroScript && g_StateMachine->GetCurrentState() == STATE_CONVERSATIONSTATE)
		{
			m_introScriptRunning = true;
		}
		else if (!m_ranIntroScript)
		{
			m_ranIntroScript = true;
			NPCDebugPrint(g_ScriptingSystem->CallScript("utility_intro_script", { 1, 0 }));
			//g_objectList[g_NPCData[1]->m_objectID]->Interact(3);
		}
	}

	if (int(g_terrainUnderMousePointer.x / 16) == 66 && int(g_terrainUnderMousePointer.z / 16 == 137) && g_ScriptingSystem->GetFlag(60) == false)
	{
		g_ScriptingSystem->SetFlag(60, true);
	}

	// Check if we've hovered over an object long enough to trigger a bark.
	if (g_objectUnderMousePointer == m_previousObjectUnderMousePointer && g_allowInput && g_mouseOverUI == false)
	{
		m_barkTimer -= GetFrameTime();
		if (m_barkTimer <= 0)
		{
			Bark(g_objectUnderMousePointer, GetObjectDisplayName(g_objectUnderMousePointer), 1.0f);
		}
	}
	else
	{
		m_previousObjectUnderMousePointer = g_objectUnderMousePointer;
		m_barkTimer = 1.25f;
	}
}

void MainState::PathfindingWorkerLoop()
{
	// Worker loop: wait for requests, compute path using PathfindingSystem, post results.
	while (true)
	{
		SchedulePathRequest req;
		bool haveRequest = false;
		{
			std::unique_lock<std::mutex> lk(m_scheduleMutex);
			m_scheduleCv.wait(lk, [&]() { return !m_schedulePathQueue.empty() || !m_pathfinderRunning; });

			if (!m_pathfinderRunning && m_schedulePathQueue.empty())
				return; // shutdown requested and no work left

			if (!m_schedulePathQueue.empty())
			{
				req = std::move(m_schedulePathQueue.front());
				m_schedulePathQueue.pop_front();
				haveRequest = true;
			}
		}

		if (!haveRequest)
			continue;

		// Compute path off the main thread.
		std::vector<Vector3> path;
		bool success = false;
		try
		{
			if (g_pathfindingSystem)
			{
				path = g_pathfindingSystem->FindPath(req.start, req.dest);
				success = !path.empty();
			}
		}
		catch (...)
		{
			success = false;
			path.clear();
		}

		SchedulePathResult result;
		result.npcID = req.npcID;
		result.path = std::move(path);
		result.success = success;
		result.dest = req.dest;

		{
			std::lock_guard<std::mutex> lk(m_resultMutex);
			m_scheduleResults.push_back(std::move(result));
		}
	}
}

void MainState::OpenGump(int id)
{
	for (const auto& gump : g_gumpManager->m_GumpList)
	{
		if (gump.get()->GetContainerId() == id)
		{
			return; // Do not double-gump.
		}
	}

	auto gump = std::make_shared<Gump>();

	gump->SetContainerId(id);
	gump->OnEnter();

	g_gumpManager->AddGump(gump);
}

void MainState::OpenSpellbookGump(int npcId)
{
	// Check if this NPC already has a spellbook gump open
	for (auto& gump : g_gumpManager->m_GumpList)
	{
		GumpSpellbook* spellbook = dynamic_cast<GumpSpellbook*>(gump.get());
		if (spellbook && spellbook->GetNpcId() == npcId)
		{
			Log("MainState::OpenSpellbookGump - Spellbook already open for NPC " + std::to_string(npcId));
			return; // Spellbook already open for this NPC
		}
	}

	Log("MainState::OpenSpellbookGump - Creating spellbook gump for NPC " + std::to_string(npcId));
	auto spellbookGump = std::make_shared<GumpSpellbook>();
	spellbookGump->Setup(npcId);
	spellbookGump->Init();
	spellbookGump->OnEnter();
	g_gumpManager->AddGump(spellbookGump);
}

bool MainState::HasAnyPaperdollOpen() const
{
	for (const auto& gump : g_gumpManager->m_GumpList)
	{
		if (dynamic_cast<GumpPaperdoll*>(gump.get()))
		{
			return true;
		}
	}
	return false;
}

GumpPaperdoll* MainState::FindPaperdollByNpcId(int npcId) const
{
	for (const auto& gump : g_gumpManager->m_GumpList)
	{
		GumpPaperdoll* paperdoll = dynamic_cast<GumpPaperdoll*>(gump.get());
		if (paperdoll && paperdoll->GetNpcId() == npcId)
		{
			return paperdoll;
		}
	}
	return nullptr;
}

void MainState::TogglePaperdoll(int npcId)
{
	Log("TogglePaperdoll for NPC " + std::to_string(npcId));

	// Check if paperdoll already open for this NPC
	GumpPaperdoll* existing = FindPaperdollByNpcId(npcId);

	if (existing)
	{
		// Close existing paperdoll
		Log("Closing existing paperdoll for NPC " + std::to_string(npcId));
		existing->OnExit();
		return;
	}

	// Create new paperdoll
	Log("Creating new paperdoll for NPC " + std::to_string(npcId));
	auto paperdoll = std::make_shared<GumpPaperdoll>();
	paperdoll->Setup(npcId);
	paperdoll->OnEnter();
	g_gumpManager->AddGump(paperdoll);
}

void MainState::OpenMinimapGump(int npcId)
{
	// Check if a minimap gump is already open
	for (auto& gump : g_gumpManager->m_GumpList)
	{
		GumpMinimap* minimap = dynamic_cast<GumpMinimap*>(gump.get());
		if (minimap)
		{
			Log("MainState::OpenMinimapGump - Minimap already open, closing it");
			minimap->OnExit();
			return; // Close existing minimap
		}
	}

	Log("MainState::OpenMinimapGump - Creating minimap gump for NPC " + std::to_string(npcId));
	auto minimapGump = std::make_shared<GumpMinimap>();
	minimapGump->Setup(npcId);
	minimapGump->Init();
	minimapGump->OnEnter();
	g_gumpManager->AddGump(minimapGump);
}

void MainState::OpenStatsGump(int npcId)
{
	// Check if this NPC already has a stats gump open
	for (auto& gump : g_gumpManager->m_GumpList)
	{
		GumpStats* stats = dynamic_cast<GumpStats*>(gump.get());
		if (stats && stats->GetNpcId() == npcId)
		{
			Log("MainState::OpenStatsGump - Stats already open for NPC " + std::to_string(npcId));
			return; // Stats already open for this NPC
		}
	}

	Log("MainState::OpenStatsGump - Creating stats gump for NPC " + std::to_string(npcId));
	auto statsGump = std::make_shared<GumpStats>();
	statsGump->Setup(npcId);
	statsGump->Init();
	statsGump->OnEnter();
	g_gumpManager->AddGump(statsGump);
}

void MainState::OpenLoadSaveGump()
{
	Log("MainState::OpenLoadSaveGump - Pushing load/save state");
	g_StateMachine->PushState(STATE_LOADSAVESTATE);
}

void MainState::Draw()
{
	if (g_pixelated)
	{
		BeginTextureMode(g_renderTarget);
	}

	ClearBackground(Color{ 0, 0, 0, 255 });

	BeginMode3D(g_camera);
	//  Draw the terrain
	g_Terrain->Draw();

	// A* timing deltas
	uint64_t totalCalls = g_pathfindingSystem ? g_pathfindingSystem->m_astarTotalCalls.load() : 0;
	uint64_t totalMs = g_pathfindingSystem ? g_pathfindingSystem->m_astarTotalMs.load() : 0;
	uint64_t callsDelta = totalCalls - m_lastAstarTotalCalls;
	uint64_t msDelta = totalMs - m_lastAstarTotalMs;
	double avgAstarMs = callsDelta ? (double)msDelta / (double)callsDelta : 0.0;
	m_lastAstarTotalCalls = totalCalls;
	m_lastAstarTotalMs = totalMs;

	if (m_showPathfindingDebug)
	{
		//DrawDebugChunkPathfindingInfo();
	}

	if (m_showObjects)
	{
		for (auto object : g_sortedVisibleObjects)
		{
			if (object->m_drawType != ShapeDrawType::OBJECT_DRAW_FLAT)
			{
				object->Draw();
			}
		}

		//  Flats require disabling the depth mask to draw correctly.
		rlDisableDepthMask();
		for (auto object : g_sortedVisibleObjects)
		{
			if (object->m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
			{
				object->Draw();
			}
		}
		rlEnableDepthMask();
	}

	if (g_gumpManager->m_draggingObject && !g_gumpManager->m_isMouseOverGump && g_objectUnderMousePointer != g_Player->GetAvatarObject())
	{
		U7Object* draggedObject = nullptr;
		{
			auto it = g_objectList.find(g_gumpManager->m_draggedObjectId);
			if (it != g_objectList.end()) draggedObject = it->second.get();
		}
		if (draggedObject)
		{
			BoundingBox box = { Vector3{0, 0, 0}, Vector3{0, 0, 0} };
			box.min = Vector3Subtract(g_terrainUnderMousePointer, { draggedObject->m_shapeData->m_Dims.x - 1, 0, draggedObject->m_shapeData->m_Dims.z - 1 });
			box.max = Vector3Add(box.min, draggedObject->m_shapeData->m_Dims);
			DrawBoundingBox(box, WHITE);
		}
	}

	// Draw pathfinding debug overlay (tile-level - shows objects)
	if (m_showPathfindingDebug)
	{
		g_pathfindingSystem->m_pathfindingGrid->DrawDebugOverlayTileLevel();
	}

	// Draw NPC paths as blue highlight tiles for NPCs with active waypoints
	if (m_showPathfindingDebug)
	{
		for (auto& object : g_sortedVisibleObjects)
		{
			if (object->m_isNPC && !object->m_pathWaypoints.empty())
			{
				// Check if NPC is on screen or near camera
				float distToCamera = Vector2Distance(
					{ object->m_Pos.x, object->m_Pos.z },
					{ g_camera.target.x, g_camera.target.z }
				);

				if (distToCamera < 50.0f)  // Within 50 tiles of camera
				{
					// Draw waypoints: Orange for C++ schedule paths, Blue for Lua activity paths
					Color pathColor = object->m_isSchedulePath ?
						Color{ 255, 128, 0, 255 } :   // Orange for schedule paths
						Color{ 50, 50, 255, 255 };     // Blue for Lua paths

					for (size_t i = 0; i < object->m_pathWaypoints.size(); i++)
					{
						const auto& waypoint = object->m_pathWaypoints[i];
						// Waypoint already contains correct Y coordinate from pathfinding
						Vector3 tilePos = { waypoint.x + 0.5f, waypoint.y + 0.05f, waypoint.z + 0.5f };
						// First tile is black, rest use the path color (orange/blue)
						Color tileColor = (i == 0) ? Color{ 0, 0, 0, 255 } : pathColor;
						DrawCube(tilePos, 1.0f, 0.1f, 1.0f, tileColor);
					}
				}
			}
		}
	}

	EndMode3D();

	float ratio = float(g_Engine->m_ScreenWidth) / float(g_Engine->m_RenderWidth);
	if (g_pixelated)
	{
		EndTextureMode();
		DrawTexturePro(g_renderTarget.texture,
			{ 0, 0, float(g_renderTarget.texture.width), float(g_renderTarget.texture.height) },
			{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
			{ 0, 0 }, 0, WHITE);
	}

	//  Draw the GUI
	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({ 0, 0, 0, 0 });

	// Set custom blend mode to preserve destination alpha while blending RGB
	rlSetBlendMode(BLEND_CUSTOM_SEPARATE);
	rlSetBlendFactorsSeparate(RL_SRC_ALPHA, RL_ONE_MINUS_SRC_ALPHA, RL_ONE, RL_ONE_MINUS_SRC_ALPHA, RL_FUNC_ADD, RL_MAX);

	//  Draw the minimap and marker

	if (!m_paused && m_showUIElements)
	{
		DrawConsole();

		//  Draw XY coordinates below the minimap
		string minimapXY = "X: " + to_string(int(g_camera.target.x)) + " Y: " + to_string(int(g_camera.target.z)) + " ";
		float textWidth = MeasureText(minimapXY.c_str(), g_Font->baseSize);
		DrawTextEx(*g_SmallFont, minimapXY.c_str(), Vector2{ 640.0f - g_minimapSize, g_minimapSize * 1.05f }, g_SmallFont->baseSize, 1, WHITE);

		string timeString = "Time: " + to_string(g_hour) + ":" + (g_minute < 10 ? "0" : "") + to_string(g_minute) + " (" + to_string(g_scheduleTime) + ")";
		DrawTextEx(*g_SmallFont, timeString.c_str(), Vector2{ 640.0f - g_minimapSize, g_minimapSize * 1.05f + g_SmallFont->baseSize }, g_SmallFont->baseSize, 1, WHITE);

		// Draw character panel below xy/time
		DrawStats();

		//  Draw version number in lower-right
		DrawOutlinedText(g_SmallFont, g_version.c_str(), Vector2{ 600, 340 }, g_SmallFont.get()->baseSize, 1, WHITE);

		// Draw FPS counter next to version
		int fps = GetFPS();
		string fpsText = "FPS: " + to_string(fps);
		Color fpsColor = fps >= 60 ? GREEN : (fps >= 30 ? YELLOW : RED);
		DrawOutlinedText(g_SmallFont, fpsText.c_str(), Vector2{ 520, 340 }, g_SmallFont.get()->baseSize, 1, fpsColor);

		// Clamp camera coordinates to valid world bounds before accessing g_World
		int worldX = int(g_camera.target.x);
		int worldZ = int(g_camera.target.z);
		if (worldX < 0) worldX = 0;
		if (worldX >= 3072) worldX = 3071;
		if (worldZ < 0) worldZ = 0;
		if (worldZ >= 3072) worldZ = 3071;

		unsigned short shapeframe = g_World[worldZ][worldX];
		int shape = shapeframe & 0x3ff;
	}

	float xoffset = g_Engine->m_ScreenWidth - float(g_minimapSize * g_DrawScale);

	// Draw bark text if active
	if (m_barkDuration > 0 && m_barkObject != nullptr && m_barkObject->m_shapeData != nullptr)
	{
		// If auto-update is enabled, regenerate bark text from current object state
		if (m_barkAutoUpdate)
		{
			m_barkText = GetObjectDisplayName(m_barkObject);
		}

		Vector3 textPos = { m_barkObject->m_Pos.x, m_barkObject->m_Pos.y + m_barkObject->m_shapeData->m_Dims.y, m_barkObject->m_Pos.z };

		// Convert 3D world position to 2D screen coordinates
		Vector2 screenPos = GetWorldToScreen(textPos, g_camera);
		screenPos.x /= g_DrawScale;
		screenPos.x = int(screenPos.x);
		screenPos.y /= g_DrawScale;
		screenPos.y = int(screenPos.y);
		screenPos.y -= g_ConversationFont->baseSize * 1.5f; // Offset above the object

		int xoffset = 8 * g_DrawScale;
		float width = MeasureTextEx(*g_ConversationFont, m_barkText.c_str(), g_ConversationFont->baseSize, 1).x + xoffset;
		screenPos.x -= width / 2;
		float height = g_ConversationFont->baseSize * 1.2;

		DrawRectangleRounded({ screenPos.x, screenPos.y, width, height }, 5, 100, { 0, 0, 0, 192 });
		DrawTextEx(*g_ConversationFont, m_barkText.c_str(), { float(screenPos.x) + xoffset / 2, float(screenPos.y) + (height * .1f) }, g_ConversationFont->baseSize, 1, YELLOW);
	}

	if (!m_paused && m_showUIElements)
	{
		g_gumpManager->Draw();
	}

	// Restore default blend mode
	rlSetBlendMode(BLEND_ALPHA);

	m_demoHelpScreen->Draw();
	m_sandboxHelpScreen->Draw();

	EndTextureMode();

	DrawTexturePro(g_guiRenderTarget.texture,
		{ 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
		{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
		{ 0, 0 }, 0, WHITE);

	if (!m_paused && m_showUIElements  && !m_demoHelpScreen->m_Active && !m_sandboxHelpScreen->m_Active)
	{
		DrawTextureEx(*m_Minimap, { g_Engine->m_ScreenWidth - float(g_minimapSize * g_DrawScale), 0 }, 0, float(g_minimapSize * g_DrawScale) / float(m_Minimap->width), WHITE);

		float _ScaleX = (g_minimapSize * g_DrawScale) / float(g_Terrain->m_width) * g_camera.target.x;
		float _ScaleZ = (g_minimapSize * g_DrawScale) / float(g_Terrain->m_height) * g_camera.target.z;

		// Draw minimap arrow rotated by camera angle around its center
		float centerX = g_Engine->m_ScreenWidth - float(g_minimapSize * g_DrawScale) + _ScaleX;
		float centerZ = _ScaleZ;
		float rotation = -g_cameraRotation * RAD2DEG - 45.0f;  // Negate to match camera rotation direction, subtract 45° for isometric offset

		// Setup source and destination rectangles for proper centered rotation
		Rectangle source = { 0, 0, (float)m_MinimapArrow->width, (float)m_MinimapArrow->height };
		Rectangle dest = { centerX, centerZ, m_MinimapArrow->width * g_DrawScale, m_MinimapArrow->height * g_DrawScale };
		Vector2 origin = { m_MinimapArrow->width * g_DrawScale / 2.0f, m_MinimapArrow->height * g_DrawScale / 2.0f };

		DrawTexturePro(*m_MinimapArrow, source, dest, origin, rotation, WHITE);
	}

	// Draw debug tools window if valid
	if (m_debugToolsWindow)
	{
		m_debugToolsWindow->Draw();
	}

	// Draw NPC list window if valid
	if (m_npcListWindow)
	{
		m_npcListWindow->Draw();
	}

	// Draw cursor AFTER dialog so it appears on top
	if (!m_paused && m_showUIElements)
	{
		if (m_errorCursorFramesRemaining > 0 && m_errorCursor != nullptr)
		{
			// Show error cursor for 5 frames after drag/drop error
			DrawTextureEx(*m_errorCursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale, WHITE);
		}
		else if (m_objectSelectionMode)
		{
			DrawTextureEx(*g_objectSelectCursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale, WHITE);
		}
		else
		{
			DrawTextureEx(*g_Cursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale, WHITE);
		}
	}

	if (m_showPathfindingDebug)
	{
		float length = 2.225;
		for (int y = 0; y < 192; ++y)
		{
			for (int x = 0; x < 192; ++x)
			{
				ChunkInfo& chunk = g_pathfindingSystem->m_chunkInfoMap[x][y];
				for (int dir = 0; dir < 8; ++dir)
				{
					if (chunk.canReach[dir])
					{
						Vector2 dirVector = g_DirVectors[dir];
						DrawLine(xoffset + x * length, y * length, xoffset + (x + dirVector.x) * length, (y + dirVector.y) * length, WHITE);
					}
				}
			}
		}
	}

	DrawRectangle(0, 0, g_Engine->m_ScreenWidth, g_Engine->m_ScreenHeight, { 0, 0, 0, m_currentFadeAlpha });

	// Telemetry summary (per-second aggregation)
	{
		float now = GetTime();
		if (now - m_lastTelemetryDumpTime >= 1.0f)
		{
			m_lastTelemetryDumpTime = now;

			// Queue sizes (sample under locks)
			size_t reqQueueSize = 0;
			{
				std::lock_guard<std::mutex> lk(m_scheduleMutex);
				reqQueueSize = m_schedulePathQueue.size();
			}
			size_t resQueueSize = 0;
			{
				std::lock_guard<std::mutex> lk(m_resultMutex);
				resQueueSize = m_scheduleResults.size();
			}

			// Script errors delta
			uint64_t totalScriptErrors = g_ScriptingSystem ? g_ScriptingSystem->m_totalScriptErrors.load() : 0;
			uint64_t scriptErrorsDelta = totalScriptErrors - m_lastScriptErrorTotal;
			m_lastScriptErrorTotal = totalScriptErrors;

			// Synchronous FindPath calls observed on main thread
			uint64_t syncFinds = m_syncFindPathCalls.exchange(0);

			// Results applied this second (accumulated)
			int resultsApplied = m_resultsAppliedThisSecond;
			m_resultsAppliedThisSecond = 0;

			std::ostringstream ss;
			ss << "TELEMETRY: reqQ=" << reqQueueSize
				<< " resQ=" << resQueueSize
				<< " resultsApplied/sec=" << resultsApplied
				<< " AStarCalls/sec=" << callsDelta
				<< " avgAstarMs=" << (int)avgAstarMs
				<< " syncFindMain/sec=" << syncFinds
				<< " luaErrors/sec=" << scriptErrorsDelta;
			DebugPrint(ss.str());
		}
	}
}

void MainState::SetupGame()
{
	// Safe minimal setup to ensure subsystems are initialized.
	if (!g_gumpManager)
	{
		g_gumpManager = std::make_unique<GumpManager>();
		g_gumpManager->Init(std::string(""));
	}

	if (!g_pathfindingSystem)
	{
		g_pathfindingSystem = std::make_unique<PathfindingSystem>();
		g_pathfindingSystem->Init(std::string(""));
	}

	// Ensure chunk mapping is consistent
	for (int cx = 0; cx < 192; ++cx)
		for (int cz = 0; cz < 192; ++cz)
			g_chunkObjectMap[cx][cz].clear();

	for (const auto& p : g_objectList)
	{
		if (p.second)
			AssignObjectChunk(p.second.get());
	}

	// Load optional configs
	//LoadSpellData();
	LoadEquipmentSlotsConfig();
}

void MainState::RebuildWorldFromLoadedData()
{
	Log("MainState::RebuildWorldFromLoadedData - Rebuilding world after load");

	// Clear visible objects list (contains dangling pointers to deleted objects)
	g_sortedVisibleObjects.clear();

	// Clear chunk object map (contains dangling pointers to deleted objects)
	for (int x = 0; x < 192; x++)
	{
		for (int y = 0; y < 192; y++)
		{
			g_chunkObjectMap[x][y].clear();
		}
	}

	// Repopulate chunk object map with ALL objects (static and dynamic)
	// BUT skip contained objects (they're in inventories, not in the world)
	int staticCount = 0;
	int dynamicCount = 0;
	int containedCount = 0;
	int npcCount = 0;
	for (auto& [id, obj] : g_objectList)
	{
		if (obj != nullptr)
		{
			if (obj->m_isContained)
			{
				containedCount++;
			}
			else
			{
				if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_STATIC)
					staticCount++;
				else if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC)
					npcCount++;
				else
					dynamicCount++;

				AssignObjectChunk(obj.get());
			}
		}
	}
	Log("MainState::RebuildWorldFromLoadedData - Assigned to chunks: " + std::to_string(staticCount) + " static, " + std::to_string(dynamicCount) + " objects, " + std::to_string(npcCount) + " NPCs, " + std::to_string(containedCount) + " contained (skipped)");

	// Initialize NPC activities based on current schedule time (after loading saved game)
	Log("MainState::RebuildWorldFromLoadedData - Initializing NPC activities from schedules...");
	InitializeNPCActivitiesFromSchedules();

	// Force immediate update of visible objects after loading
	Log("MainState::RebuildWorldFromLoadedData - Calling UpdateSortedVisibleObjects now...");
	UpdateSortedVisibleObjects();
	Log("MainState::RebuildWorldFromLoadedData - UpdateSortedVisibleObjects returned, g_sortedVisibleObjects.size() = " + std::to_string(g_sortedVisibleObjects.size()));

	// Debug: Verify objects are still in g_objectList after rebuild
	int finalStatic = 0, finalObjects = 0, finalNpcs = 0, finalTotal = 0;
	for (const auto& [id, obj] : g_objectList)
	{
		if (obj != nullptr)
		{
			finalTotal++;
			if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_STATIC)
				finalStatic++;
			else if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC)
				finalNpcs++;
			else
				finalObjects++;
		}
	}
	Log("MainState::RebuildWorldFromLoadedData - g_objectList after rebuild: " + std::to_string(finalTotal) +
		" total (" + std::to_string(finalStatic) + " static, " + std::to_string(finalObjects) +
		" objects, " + std::to_string(finalNpcs) + " NPCs)");

	Log("MainState::RebuildWorldFromLoadedData - Complete");
}

void MainState::DrawStats()
{
	//  Draw background
	DrawTexture(*g_statsBackground.get(), 512, 200, WHITE);

	//  Draw stat numbers
	int str;
	int dex;
	int iq;
	int combat;
	int magic;
	int trainingpoints;

	if (g_Player->GetSelectedPartyMember() == 0) // Avatar
	{
		str = g_Player->GetStr();
		dex = g_Player->GetDex();
		iq = g_Player->GetInt();
		combat = g_Player->GetCombat();
		magic = g_Player->GetMagic();
		trainingpoints = g_Player->GetTrainingPoints();

		DrawOutlinedText(g_SmallFont, g_Player->GetPlayerName().c_str(), { 546, 206 }, g_SmallFont.get()->baseSize, 1, WHITE);
	}
	else
	{
		str = g_NPCData[g_Player->GetSelectedPartyMember()]->str;
		dex = g_NPCData[g_Player->GetSelectedPartyMember()]->dex;
		iq = g_NPCData[g_Player->GetSelectedPartyMember()]->iq;
		combat = g_NPCData[g_Player->GetSelectedPartyMember()]->combat;
		magic = g_NPCData[g_Player->GetSelectedPartyMember()]->magic;
		trainingpoints = g_NPCData[g_Player->GetSelectedPartyMember()]->training;

		DrawOutlinedText(g_SmallFont, g_NPCData[g_Player->GetSelectedPartyMember()]->name, { 546, 206 }, g_SmallFont.get()->baseSize, 1, WHITE);
	}

	int yoffset = g_SmallFont.get()->baseSize;
	DrawOutlinedText(g_SmallFont, to_string(str), { 622, 208.0f + yoffset }, g_SmallFont.get()->baseSize, 1, WHITE);
	DrawOutlinedText(g_SmallFont, to_string(dex), { 622, 208.0f + 2 * yoffset }, g_SmallFont.get()->baseSize, 1, WHITE);
	DrawOutlinedText(g_SmallFont, to_string(iq), { 622, 208.0f + 3 * yoffset }, g_SmallFont.get()->baseSize, 1, WHITE);
	DrawOutlinedText(g_SmallFont, to_string(combat), { 622, 208.0f + 4 * yoffset + 2 }, g_SmallFont.get()->baseSize, 1, WHITE);
	DrawOutlinedText(g_SmallFont, to_string(magic), { 622, 208.0f + 5 * yoffset + 2 }, g_SmallFont.get()->baseSize, 1, WHITE);
	DrawOutlinedText(g_SmallFont, to_string(trainingpoints), { 622, 208.0f + 10 * yoffset + 6 }, g_SmallFont.get()->baseSize, 1, WHITE);

	//  Draw party members
	int counter = 0;
	for (int i = 0; i < g_Player->GetPartyMemberIds().size(); ++i)
	{
		Texture* thisTexture = nullptr;
		if (i == 0 && !g_Player->GetIsMale()) // Avatar is always a special case
		{
			thisTexture = g_ResourceManager->GetTexture("U7FACES" + to_string(i) + to_string(1));
		}
		else
		{
			thisTexture = g_ResourceManager->GetTexture("U7FACES" + to_string(i) + to_string(0));
		}

		DrawTexturePro(*thisTexture, { float(thisTexture->width - 40) / 2.0f, float(thisTexture->height - 40) / 2.0f, 40, 40 }, { 538.0f - 40, 200.0f + 40.0f * counter, 40, 40 }, { 0, 0 }, 0, WHITE);
		if (g_Player->GetPartyMemberIds()[i] != g_Player->GetSelectedPartyMember())
		{
			DrawRectangle(538.0f - 40, 200.0f + 40.0f * counter, 40, 40, { 0, 0, 0, 128 });
		}
		++counter;
	}

	DrawOutlinedText(g_SmallFont, "Gold: " + to_string(g_Player->GetGold()), { 542, 208.0f + 11 * yoffset + 8 }, g_SmallFont.get()->baseSize, 1, WHITE);
	U7Object* avatarObject = g_objectList[g_NPCData[0]->m_objectID].get();
	DrawOutlinedText(g_SmallFont, "Weight: " + to_string(int(avatarObject->GetWeight())) + "/" + to_string(int(g_Player->GetMaxWeight())), { 542, 208.0f + 12 * yoffset + 9 }, g_SmallFont.get()->baseSize, 1, WHITE);
}

void MainState::UpdateStats()
{
	int counter = 0;
	for (int i = 0; i < g_Player->GetPartyMemberIds().size(); ++i)
	{
		Texture* thisTexture = g_ResourceManager->GetTexture("U7FACES" + to_string(i) + to_string(0));
		Rectangle portraitRect = { (538.0f - thisTexture->width) * g_DrawScale, (200.0f + 40.0f * counter) * g_DrawScale, thisTexture->width * g_DrawScale, thisTexture->height * g_DrawScale };

		// Check for double-click to toggle paperdoll
		if (g_InputSystem->WasLButtonDoubleClicked() && CheckCollisionPointRec(GetMousePosition(), portraitRect))
		{
			TogglePaperdoll(g_Player->GetPartyMemberIds()[i]);
		}
		// Check for single click to select party member
		else if (g_InputSystem->WasLButtonClickedInRegion(portraitRect.x, portraitRect.y, portraitRect.width, portraitRect.height))
		{
			g_Player->SetSelectedPartyMember(g_Player->GetPartyMemberIds()[i]);
		}
		++counter;
	}

	if (g_InputSystem->WasLButtonClickedInRegion(610 * g_DrawScale, 314 * g_DrawScale, 16 * g_DrawScale, 10 * g_DrawScale ))
	{
		// Open the equipped backpack, not the NPC itself
		int npcIndex = g_Player->GetSelectedPartyMember();
		int backpackId = g_NPCData[npcIndex]->GetEquippedItem(EquipmentSlot::SLOT_BACKPACK);
		int npcId = g_NPCData[npcIndex]->m_objectID;

		if (backpackId != -1)
		{
			Log("Opening backpack: backpackId=" + std::to_string(backpackId) + ", npcId=" + std::to_string(npcId));
			OpenGump(backpackId);
		}
		else
		{
			Log("No backpack equipped, opening NPC inventory: npcId=" + std::to_string(npcId));
			// Fallback to NPC inventory if no backpack equipped
			OpenGump(npcId);
		}
	}
}

void MainState::DumpNpcScheduleStats()
{
	try
	{
		NPCDebugPrint("DumpNpcScheduleStats: ENTER");
		// Defensive: ensure globals exist / initialized
		if (g_NPCData.empty())
		{
			AddConsoleString("DumpNpcScheduleStats: No NPC data loaded");
			NPCDebugPrint("DumpNpcScheduleStats: g_NPCData is empty");
			return;
		}

		int totalNpc = 0;
		int following = 0;
		int pendingPath = 0;
		int schedulePath = 0;
		int noSchedule = 0;
		int inParty = 0;

		std::vector<int> samplePending;
		std::vector<int> sampleNotFollowing;

		for (const auto& kv : g_NPCData)
		{
			if (!kv.second) continue;
			int npcId = kv.first;
			++totalNpc;

			int objId = kv.second->m_objectID;
			if (objId < 0) continue;

			auto it = g_objectList.find(objId);
			if (it == g_objectList.end() || !it->second)
			{
				NPCDebugPrint("DumpNpcScheduleStats: missing object for NPC " + std::to_string(npcId) + " (objId=" + std::to_string(objId) + ")");
				continue;
			}

			U7Object* obj = it->second.get();
			if (!obj)
			{
				NPCDebugPrint("DumpNpcScheduleStats: null object pointer for NPC " + std::to_string(npcId));
				continue;
			}

			bool hasSchedule = (g_NPCSchedules.find(npcId) != g_NPCSchedules.end() && !g_NPCSchedules[npcId].empty());
			if (!hasSchedule) ++noSchedule;

			if (obj->m_followingSchedule) ++following;
			else if (sampleNotFollowing.size() < 8) sampleNotFollowing.push_back(npcId);

			if (obj->m_pathfindingPending)
			{
				++pendingPath;
				if (samplePending.size() < 8) samplePending.push_back(npcId);
			}

			if (obj->m_isSchedulePath) ++schedulePath;

			if (g_Player && g_Player->NPCIDInParty(npcId)) ++inParty;
		}

		std::stringstream ss;
		ss << "NPC schedule stats: total=" << totalNpc
			<< " following=" << following
			<< " pendingPath=" << pendingPath
			<< " schedulePath=" << schedulePath
			<< " noSchedule=" << noSchedule
			<< " inParty=" << inParty;

		NPCDebugPrint(ss.str());

		if (!samplePending.empty())
		{
			std::stringstream s2; s2 << "Sample pending NPCs:";
			for (int id : samplePending) s2 << " " << id;
			NPCDebugPrint(s2.str());
		}
		if (!sampleNotFollowing.empty())
		{
			std::stringstream s3; s3 << "Sample not-following NPCs:";
			for (int id : sampleNotFollowing) s3 << " " << id;
			NPCDebugPrint(s3.str());
		}
	}
	catch (const std::exception& e)
	{
		Log(std::string("Exception in DumpNpcScheduleStats: ") + e.what());
		AddConsoleString("Error: DumpNpcScheduleStats threw an exception; see debug log", RED);
	}
	catch (...)
	{
		Log("Unknown exception in DumpNpcScheduleStats");
		AddConsoleString("Error: DumpNpcScheduleStats crashed with unknown error; see debug log", RED);
	}
}

void MainState::HandleScheduleButton()
{
	m_npcSchedulesEnabled = !m_npcSchedulesEnabled;

	// Update NPCs: when enabling, skip party members; when disabling, clear for all.
	for (const auto& [id, npcData] : g_NPCData)
	{
		if (!npcData || npcData->m_objectID < 0) continue;

		// If schedules were just enabled, only enable for NPCs not in player's party.
		if (m_npcSchedulesEnabled)
		{
			if (g_Player && g_Player->NPCIDInParty(id))
				continue;
			g_objectList[npcData->m_objectID]->m_followingSchedule = true;
		}
		else
		{
			// When disabling, turn off for everyone.
			g_objectList[npcData->m_objectID]->m_followingSchedule = false;
		}
	}

	AddConsoleString(m_npcSchedulesEnabled ? "NPC Schedules ENABLED" : "NPC Schedules DISABLED");
}

void MainState::HandlePathfindButton()
{
	m_npcPathfindingEnabled = !m_npcPathfindingEnabled;

	// Distance-based heuristic: teleport NPCs that are far from the camera
	// to avoid consuming A* resources for objects the player won't see.
	// Tune this threshold as needed (tiles).
	const float TELEPORT_DISTANCE_THRESHOLD = 120.0f; // tiles (tunable)
	for (const auto& [id, npcDataPtr] : g_NPCData)
	{
		if (!npcDataPtr) continue;
		NPCData* npcData = npcDataPtr.get();
		if (npcData->m_objectID < 0) continue;

		U7Object* npcObj = nullptr;
		auto objIt = g_objectList.find(npcData->m_objectID);
		if (objIt != g_objectList.end())
			npcObj = objIt->second.get();

		if (!npcObj) continue;

		// Distance check
		float dist = Vector2Distance({ npcObj->m_Pos.x, npcObj->m_Pos.z }, { g_camera.target.x, g_camera.target.z });
		if (dist > TELEPORT_DISTANCE_THRESHOLD)
		{
			// Teleport directly: avoid pathfinding and mark schedule state accordingly.
			npcObj->SetPos(npcObj->m_Dest);
			npcObj->SetDest(npcObj->m_Dest);
			npcObj->m_isSchedulePath = false;
			npcObj->m_pathfindingPending = false;

			NPCDebugPrint("Schedule: NPC " + std::to_string(npcData->m_objectID) +
				" far (" + std::to_string((int)dist) + " tiles), teleported to (" +
				std::to_string((int)npcObj->m_Dest.x) + "," + std::to_string((int)npcObj->m_Dest.z) + ")");
		}
	}

	AddConsoleString(m_npcPathfindingEnabled ? "NPC Pathfinding ENABLED" : "NPC Pathfinding DISABLED");
}

void MainState::HandleShapeTableButton()
{
	// Open shape editor (same as F1 key)
	g_StateMachine->MakeStateTransition(STATE_SHAPEEDITORSTATE);
}

void MainState::HandleGhostButton()
{
	Log("HandleGhostButton: Launching Ghost editor");

	// Check if Ghost executable exists
#ifdef _WIN32
	const char* ghostPath = "Ghost.exe";
#else
	const char* ghostPath = "./Ghost";
#endif

	std::ifstream ghostFile(ghostPath);
	if (!ghostFile.good())
	{
		Log("ERROR: Ghost executable not found: " + std::string(ghostPath));
		AddConsoleString("ERROR: Ghost.exe not found - please build Ghost first", RED);
		return;
	}
	ghostFile.close();

	AddConsoleString("Launching Ghost GUI Editor...");

	// Launch Ghost in a background thread so it doesn't block the game
	// Thread is detached so it cleans up automatically when Ghost exits
	std::thread([=]() {
#ifdef _WIN32
		// Windows: Use start command to launch in new window
		int result = system("start Ghost.exe");
#else
		// Linux/Mac: Launch in background
		int result = system("./Ghost &");
#endif

		if (result != 0)
		{
			Log("ERROR: Failed to launch Ghost - system() returned error code " + std::to_string(result));
		}
		}).detach();
}

void MainState::HandleRenameButton()
{
	Log("HandleRenameButton called");
	AddConsoleString("Rename button clicked - opening rename dialog");

	// Clear hover text from debug tools window
	if (m_debugToolsWindow)
	{
		m_debugToolsWindow->ClearHoverText();
	}

	// Push the script rename dialog state
	g_StateMachine->PushState(STATE_SCRIPTRENAMESTATE);
	Log("PushState(STATE_SCRIPTRENAMESTATE) called");
}

void MainState::HandleNPCListButton()
{
	Log("HandleNPCListButton called");

	// Clear hover text from debug tools window
	if (m_debugToolsWindow)
	{
		m_debugToolsWindow->ClearHoverText();
	}

	// Toggle NPC list window visibility
	if (m_npcListWindow)
	{
		m_npcListWindow->Toggle();
		if (m_npcListWindow->IsVisible())
		{
			AddConsoleString("NPC list window opened");
		}
		else
		{
			AddConsoleString("NPC list window closed");
		}
	}
}

void MainState::UpdateDebugToolsWindow()
{
	if (!m_debugToolsWindow || !m_debugToolsWindow->IsVisible())
		return;

	Gui* gui = m_debugToolsWindow->GetGui();
	if (!gui)
		return;

	// Check SCHEDULE_BUTTON
	int scheduleButtonID = m_debugToolsWindow->GetElementID("SCHEDULE_BUTTON");
	if (scheduleButtonID != -1)
	{
		auto elem = gui->GetElement(scheduleButtonID);
		if (elem && (elem->m_Type == GUI_ICONBUTTON || elem->m_Type == GUI_CHECKBOX))
		{
			if (elem->m_Type == GUI_ICONBUTTON)
			{
				auto button = static_cast<GuiIconButton*>(elem.get());
				if (button->m_Clicked)
				{
					HandleScheduleButton();
				}
			}
			else if (elem->m_Type == GUI_CHECKBOX)
			{
				auto checkbox = static_cast<GuiCheckBox*>(elem.get());

				// Check if user clicked and toggled the checkbox
				if (checkbox->m_Selected != m_npcSchedulesEnabled)
				{
					// User toggled the checkbox, so toggle the flag
					HandleScheduleButton();
				}
			}
		}
	}

	// Check PATHFIND_BUTTON
	int pathfindButtonID = m_debugToolsWindow->GetElementID("PATHFIND_BUTTON");
	if (pathfindButtonID != -1)
	{
		auto elem = gui->GetElement(pathfindButtonID);
		if (elem && (elem->m_Type == GUI_ICONBUTTON || elem->m_Type == GUI_CHECKBOX))
		{
			if (elem->m_Type == GUI_ICONBUTTON)
			{
				auto button = static_cast<GuiIconButton*>(elem.get());
				if (button->m_Clicked)
				{
					HandlePathfindButton();
				}
			}
			else if (elem->m_Type == GUI_CHECKBOX)
			{
				auto checkbox = static_cast<GuiCheckBox*>(elem.get());

				// Check if user clicked and toggled the checkbox
				if (checkbox->m_Selected != m_npcPathfindingEnabled)
				{
					// User toggled the checkbox, so toggle the flag
					HandlePathfindButton();
				}
			}
		}
	}

	// Check SHAPETABLE_BUTTON
	int shapeTableButtonID = m_debugToolsWindow->GetElementID("SHAPETABLE_BUTTON");
	if (shapeTableButtonID != -1)
	{
		auto elem = gui->GetElement(shapeTableButtonID);
		if (elem && elem->m_Type == GUI_ICONBUTTON)
		{
			auto button = static_cast<GuiIconButton*>(elem.get());
			if (button->m_Clicked)
			{
				HandleShapeTableButton();
			}
		}
	}

	// Check GHOST_BUTTON
	int ghostButtonID = m_debugToolsWindow->GetElementID("GHOST_BUTTON");
	if (ghostButtonID != -1)
	{
		auto elem = gui->GetElement(ghostButtonID);
		if (elem && elem->m_Type == GUI_ICONBUTTON)
		{
			auto button = static_cast<GuiIconButton*>(elem.get());
			if (button->m_Clicked)
			{
				HandleGhostButton();
			}
		}
	}

	// Check RENAME_BUTTON
	int renameButtonID = m_debugToolsWindow->GetElementID("RENAME_BUTTON");
	if (renameButtonID != -1)
	{
		auto elem = gui->GetElement(renameButtonID);
		if (elem && elem->m_Type == GUI_ICONBUTTON)
		{
			auto button = static_cast<GuiIconButton*>(elem.get());
			if (button->m_Clicked)
			{
				HandleRenameButton();
			}
		}
	}

	// Check NPC_LIST_BUTTON
	int npcListButtonID = m_debugToolsWindow->GetElementID("NPC_LIST_BUTTON");
	if (npcListButtonID != -1)
	{
		auto elem = gui->GetElement(npcListButtonID);
		if (elem && elem->m_Type == GUI_ICONBUTTON)
		{
			auto button = static_cast<GuiIconButton*>(elem.get());
			if (button->m_Clicked)
			{
				HandleNPCListButton();
			}
		}
	}
}


void MainState::SetFollowingScheduleForNpc(int npcId, bool follow)
{
	auto itNpc = g_NPCData.find(npcId);
	if (itNpc == g_NPCData.end() || !itNpc->second) return;
	int objId = itNpc->second->m_objectID;
	if (objId < 0) return;
	auto itObj = g_objectList.find(objId);
	if (itObj == g_objectList.end() || !itObj->second) return;
	itObj->second->m_followingSchedule = follow;
}

bool MainState::IsNpcSchedulesEnabled() const
{
	return m_npcSchedulesEnabled;
}

void MainState::MaybeUpdatePartyFollowing()
{
    // Only run when camera is locked and input is allowed and player exists
    if (!g_Player || !g_isCameraLockedToAvatar || !g_allowInput)
        return;

    U7Object* avatar = g_Player->GetAvatarObject();
    if (!avatar) return;

    float now = GetTime();
    if (now - m_lastPartyFollowTime < m_partyFollowCooldown)
        return;

    Vector3 avatarPos = avatar->GetPos();
    // measure horizontal distance
    Vector3 delta = Vector3Subtract(avatarPos, m_lastPartyAnchorPos);
    delta.y = 0.0f;
    float moved = Vector3Length(delta);

    if (m_lastPartyAnchorPos.x == 0.0f && m_lastPartyAnchorPos.z == 0.0f)
    {
        // initialize anchor on first run
        m_lastPartyAnchorPos = avatarPos;
        m_lastPartyFollowTime = now;
        return;
    }

    if (moved < m_partyAnchorThreshold)
        return;

    // commit
    m_lastPartyAnchorPos = avatarPos;
    m_lastPartyFollowTime = now;

    // Compute formation direction (behind avatar)
    Vector3 dir = avatar->m_Direction;
    dir.y = 0.0f;
    if (Vector3Length(dir) < 0.0001f)
    {
        // fallback to camera-facing horizontal if avatar direction degenerate
        Vector3 camForward = Vector3Subtract(g_camera.target, g_camera.position);
        camForward.y = 0.0f;
        if (Vector3Length(camForward) > 0.0001f)
            dir = Vector3Normalize(camForward);
        else
            dir = Vector3{0.0f, 0.0f, 1.0f};
    }
    dir = Vector3Normalize(dir);

    // For each party member (skip avatar id 0)
    const auto& party = g_Player->GetPartyMemberIds();
    int counter = 1;
    for (int npcId : party)
    {
        if (npcId == 0) { ++counter; continue; } // avatar

        // Guard: ensure NPC data & object
        auto itNpc = g_NPCData.find(npcId);
        if (itNpc == g_NPCData.end() || !itNpc->second) { ++counter; continue; }
        int objId = itNpc->second->m_objectID;
        auto itObj = g_objectList.find(objId);
        if (itObj == g_objectList.end() || !itObj->second) { ++counter; continue; }
        U7Object* member = itObj->second.get();

        // Skip if it already has a pending schedule/pathfinding request
        if (member->m_pathfindingPending)
        {
            ++counter;
            continue;
        }

        // Desired position: behind avatar along dir, offset by spacing * counter
        float offset = m_partySpacing * float(counter);
        Vector3 desired = Vector3Subtract(avatarPos, Vector3Scale(dir, offset));
        // Snap to tile center to match other pathfind usage
        desired.x = floorf(desired.x + 0.5f);
        desired.z = floorf(desired.z + 0.5f);
        desired.y = 0.0f; // let A*/TryMove resolve proper height

        // Only issue pathfind if the member is sufficiently far from desired
        Vector3 diff = Vector3Subtract(member->GetPos(), desired);
        diff.y = 0.0f;
        float dist = Vector3Length(diff);
        if (dist > m_partyMemberFollowThreshold)
        {
            // Use pathfind (fire-and-forget) to desired tile
            member->PathfindToDest(desired);
        }

        ++counter;
    }
}

void MainState::BuildDemoHelpGUI()
{
    m_demoHelpScreen = new Gui();
    m_demoHelpScreen->m_Font = g_SmallFont;

    // Panel size adjusted to comfortably fit the new layout
    m_demoHelpScreen->SetLayout(20, 30, 600, 300, g_DrawScale, Gui::GUIP_USE_XY);
    m_demoHelpScreen->AddOctagonBox(GUI_DEMO_HELP_PANEL, 0, 0, 600, 300, g_Borders);

    m_demoHelpScreen->AddTextArea(GUI_DEMO_HELP_TITLE, g_SmallFont.get(), "How to play Ultima VII Revisited", 320, 12, 0, 0,
                              Color{255, 255, 255, 255}, GuiTextArea::CENTERED, 0, 1, true);

	int idOffset = 1;
	int textY = 18;

	m_demoHelpScreen->AddTextArea(GUI_DEMO_HELP_TITLE + idOffset++, g_SmallFont.get(), "MOVEMENT:\nTo move the Avatar, you can:\n* Double-Right-Click to move to a location.\n* Use the WASD keys to move and Q and E to rotate the camera.\n* Hold the right mouse button to make the Avatar move towards the mouse cursor.", 10, textY,
	                           0, 0, WHITE, GuiTextArea::LEFT, 0, 1, false);

	textY += 76;

	m_demoHelpScreen->AddTextArea(GUI_DEMO_HELP_TITLE + idOffset++, g_SmallFont.get(), "CHARACTER SCREENS:\nDouble-Click the Avatar to open the Avatar's character screen.\nDouble-click the backpack to open it. From here, you can drag items onto the Avatar or into the world.\nClick the heart icon on a character's screen to see that character's stats.\nClick the disk icon to bring up the Save/Load screen.\nClick the check mark to close any open screen.", 10, textY,
									0, 0, WHITE, GuiTextArea::LEFT, 0, 1, false);

	textY += 92;

	m_demoHelpScreen->AddTextArea(GUI_DEMO_HELP_TITLE + idOffset++, g_SmallFont.get(), "INTERACTIONS:\nHold the mouse over an object to get a popup saying what it is.\nDrag objects and drop them on the Avatar or over an open backpack to add them to the Avatar's inventory.\nDouble-click objects in the world to interact with them. If you can use an object on another object (like a key),\n     you get a green target cursor. Use this to select the target.\nDouble-click NPCs to talk to them.\n", 10, textY,
								0, 0, WHITE, GuiTextArea::LEFT, 0, 1, false);


    // Back button at bottom center
	 m_demoHelpScreen->AddStretchButtonCentered(GUI_DEMO_HELP_BACK, 280,
	 	 "Back to Game",
	 	 g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	 	 g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

    m_demoHelpScreen->m_Active = false;
    m_demoHelpScreen->m_Draggable = false;
}


void MainState::BuildSandboxHelpGUI()
{
    m_sandboxHelpScreen = new Gui();
    m_sandboxHelpScreen->m_Font = g_SmallFont;

    // Panel size adjusted to comfortably fit the new layout
    m_sandboxHelpScreen->SetLayout(20, 30, 600, 300, g_DrawScale, Gui::GUIP_USE_XY);
    m_sandboxHelpScreen->AddOctagonBox(GUI_DEMO_HELP_PANEL, 0, 0, 600, 300, g_Borders);

    m_sandboxHelpScreen->AddTextArea(GUI_DEMO_HELP_TITLE, g_SmallFont.get(), "Welcome to Ultima VII Revisited Sandbox Mode!", 320, 12, 0, 0,
                              Color{255, 255, 255, 255}, GuiTextArea::CENTERED, 0, 1, true);

	int idOffset = 1;
	int textY = 22;

	m_sandboxHelpScreen->AddTextArea(GUI_DEMO_HELP_TITLE + idOffset++, g_SmallFont.get(), "In sandbox mode, you can pick the game apart and see how it works behind the scenes.", 10, textY,
	                           0, 0, WHITE, GuiTextArea::LEFT, 0, 1, false);

	textY += 16;

	m_sandboxHelpScreen->AddTextArea(GUI_DEMO_HELP_TITLE + idOffset++, g_SmallFont.get(), "Click anywhere on the minimap to go there.\nTry out the debug menu on the right to turn NPC schedules on/off,\nfind specific NPCs and rename scripts.", 10, textY,
									0, 0, WHITE, GuiTextArea::LEFT, 0, 1, false);

	textY += 48;

	m_sandboxHelpScreen->AddTextArea(GUI_DEMO_HELP_TITLE + idOffset++, g_SmallFont.get(), "F1 - Shape Editor\nF5 - Lock/Unlock the camera to the Avatar\nF6 - SUPER PIXELLATION MODE\nF7 - Allow hack moving (move anything)\nF8 - Lua script debug text\nF9 - Show object bounding boxes\nF10 - Show pathfinding info\nF11 - Highlight objects with scripts\nPageUp - Move the camera up one floor\nPageDown - Move the camera down one floor\nMinus Key - Speed up time\nPlus Key - Slow down time\nKeypad Enter - Jump time forward one hour.", 10, textY,
								0, 0, WHITE, GuiTextArea::LEFT, 0, 1, false);


    // Back button at bottom center
	 m_sandboxHelpScreen->AddStretchButtonCentered(GUI_SANDBOX_HELP_BACK, 280,
	 	 "Back to Game",
	 	 g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	 	 g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

    m_sandboxHelpScreen->m_Active = false;
    m_sandboxHelpScreen->m_Draggable = false;
}
