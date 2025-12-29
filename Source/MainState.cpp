#include "Geist/Globals.h"
#include "Geist/Logging.h"
#include "Geist/Gui.h"
#include "Geist/ParticleSystem.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
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
#include "Pathfinding.h"
#include "PathfindingThreadPool.h"
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

	m_usePointer = g_ResourceManager->GetTexture("Images/usepointer.png");
	m_errorCursor = g_ResourceManager->GetTexture("Images/error.png");

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
}

void MainState::OnEnter()
{
	g_lastTime = 0;
	g_minute = 0;
	g_hour = 7;
	g_scheduleTime = 1;

	m_heightCutoff = 16.0f; // Draw everything unless the player is inside.

	// Initialize NPC activities based on starting schedule time (for new games)
	// This must happen AFTER g_scheduleTime is set, so NPCs get the correct activity for time slot 1
	InitializeNPCActivitiesFromSchedules();

	if (m_gameMode == MainStateModes::MAIN_STATE_MODE_TRINSIC_DEMO)
	{
		// Fade out.

		// Move camera to start position and rotation.
		g_camera.target = Vector3{ 1068.0f, 0.0f, 2213.0f };
		g_cameraRotation = 0;
		g_cameraDistance = 22.0f;
		DoCameraMovement();

		// Hack-move Petre and put him in the proper position.
		g_objectList[g_NPCData[11]->m_objectID]->m_Angle = 2 * (PI / 2);
		g_objectList[g_NPCData[11]->m_objectID]->Update();


		// Hack-move the Avatar off the screen.

		// Fade in.

		// Run Iolo's script to start the plotline flags

		//  Run Finnigan's script.
		//g_objectList[g_NPCData[12]->m_objectID]->Interact(1);
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
			AddConsoleString(std::string("Move with WASD, rotate with Q and E."));
			AddConsoleString(std::string("Zoom in and out with mousewheel."));
			AddConsoleString(std::string("Left-click in the minimap to teleport."));
			AddConsoleString(std::string("Press F1 to switch to the Object Viewer."));
			AddConsoleString(std::string("Press KP ENTER to advance time an hour."));
			AddConsoleString(std::string("Press SPACE to pause/unpause time."));
			AddConsoleString(std::string("Press ESC to exit."));
		}
	}
}

void MainState::OnExit()
{
}

void MainState::Shutdown()
{
	// Clean up pathfinding thread pool (must be done before cleaning up g_pathfindingGrid)
	if (g_pathfindingThreadPool)
	{
		delete g_pathfindingThreadPool;
		g_pathfindingThreadPool = nullptr;
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

	unsigned char darklevel = 24;
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
	bool overStats = IsPosInRect(mousePos, statsPanelRect);
	bool overMinimap = IsPosInRect(mousePos, minimapRect);
	bool overCharPanel = IsPosInRect(mousePos, charPanelRect);

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

	g_mouseOverUI = overStats || overMinimap || overCharPanel || overDebugTools || overNpcList;
}

void MainState::UpdateInput()
{
	if (!g_allowInput)
	{
		return;
	}

	if (IsKeyPressed(KEY_ESCAPE))
	{
		if (!g_gumpManager->m_GumpList.empty())
		{
			g_gumpManager->m_GumpList.back().get()->SetIsDead(true);
		}
		else if (!g_Engine->m_askedToExit)
		{
			g_Engine->m_askedToExit = true;
			g_StateMachine->PushState(STATE_ASKEXITSTATE);
		}
	}

	if (IsKeyPressed(KEY_F1))
	{
		g_StateMachine->MakeStateTransition(STATE_SHAPEEDITORSTATE);
	}

	if (IsKeyPressed(KEY_F7))
	{
		m_allowMovingStaticObjects = !m_allowMovingStaticObjects;
		AddConsoleString(m_allowMovingStaticObjects ? "DEBUG: Can now move static objects" : "DEBUG: Static objects locked");
	}

	if (IsKeyPressed(KEY_F8))
	{
		g_LuaDebug = !g_LuaDebug;
		if (g_LuaDebug)
		{
			AddConsoleString("Lua debug mode ENABLED");
		}
		else
		{
			AddConsoleString("Lua debug mode DISABLED");
		}
	}

	if (IsKeyPressed(KEY_F5))
	{
		g_isCameraLockedToAvatar = !g_isCameraLockedToAvatar;
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

	// Right-click to debug specific tile when pathfinding debug is on
	if (m_showPathfindingDebug && IsMouseButtonPressed(MOUSE_BUTTON_RIGHT) && g_pathfindingGrid)
	{
		// Get world position where mouse clicked
		int worldX = (int)floor(g_terrainUnderMousePointer.x);
		int worldZ = (int)floor(g_terrainUnderMousePointer.z);
		g_pathfindingGrid->DebugPrintTileInfo(worldX, worldZ);
	}

	if (IsKeyPressed(KEY_KP_ENTER))
	{
		++g_hour;
		if (g_hour >= 24)
			g_hour = 0;
	}

	if (IsKeyPressed(KEY_PAGE_UP))
	{
		//if (m_gameMode == MainStateModes::MAIN_STATE_MODE_SANDBOX)
		//{
		if (m_heightCutoff == 4.0f)
		{
			m_heightCutoff = 10.0f;
			AddConsoleString("Viewing Second Floor");
		}
		else if (m_heightCutoff == 10.0f)
		{
			m_heightCutoff = 16.0f;
			AddConsoleString("Viewing Third Floor");
		}
		//}
	}

	if (IsKeyPressed(KEY_SPACE))
	{
		m_paused = !m_paused;
	}

	// Skip to next hour (Sandbox mode only)
	if (IsKeyPressed(KEY_RIGHT) && m_gameMode == MainStateModes::MAIN_STATE_MODE_SANDBOX)
	{
		// Advance to next full hour
		if (g_minute > 0)
		{
			// If not on the hour, go to next hour
			g_hour++;
			if (g_hour >= 24)
				g_hour = 0;
			g_minute = 0;
		}
		else
		{
			// Already on the hour, go to next hour
			g_hour++;
			if (g_hour >= 24)
				g_hour = 0;
		}

		AddConsoleString("Time skipped to " + std::to_string(g_hour) + ":00");
	}

	if (IsKeyPressed(KEY_PAGE_DOWN))
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
	}

	if (IsKeyPressed(KEY_F7))
	{
		g_pixelated = !g_pixelated;
	}

	if (IsKeyPressed(KEY_KP_SUBTRACT) || IsKeyPressed(KEY_MINUS))
	{
		g_secsPerMinute -= 0.1f;
		if (g_secsPerMinute < 0.1f)
		{
			g_secsPerMinute = 0.1f;
		}
		else
		{
			AddConsoleString("Time Speed: " + to_string(g_secsPerMinute) + " seconds per minute");
		}
	}

	if (IsKeyPressed(KEY_KP_ADD) || IsKeyPressed(KEY_EQUAL))
	{
		g_secsPerMinute += 0.1f;
		if (g_secsPerMinute > 5.0f)
		{
			g_secsPerMinute = 5.0f;
		}
		else
		{
			AddConsoleString("Time Speed: " + to_string(g_secsPerMinute) + " seconds per minute");
		}
	}
	if (!IsMouseButtonDown(MOUSE_LEFT_BUTTON))
	{
		m_dragStart = { 0, 0 };
	}

	// Always update selected shape/frame when clicking an object (for F1 shape editor)
	if (IsMouseButtonDown(MOUSE_LEFT_BUTTON) && g_objectUnderMousePointer != nullptr && !g_gumpManager->m_isMouseOverGump && !g_gumpManager->m_draggingObject && !g_gumpManager->IsAnyGumpBeingDragged() && !g_mouseOverUI)
	{
		g_selectedShape = g_objectUnderMousePointer->m_shapeData->m_shape;
		g_selectedFrame = g_objectUnderMousePointer->m_shapeData->m_frame;

		if (m_doingObjectSelection)
		{
			g_ScriptingSystem->ResumeCoroutine(m_luaFunction, { g_objectUnderMousePointer->m_ID }); // Lua arrays are 1-indexed
		}

		// Only allow dragging if not a static object (or if static movement is enabled)
		if (m_allowMovingStaticObjects || g_objectUnderMousePointer->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_STATIC )
		{
			if (m_dragStart.x == 0 && m_dragStart.y == 0)
			{
				m_dragStart = GetMousePosition();
			}
			else
			{
				if (Vector2DistanceSqr(m_dragStart, GetMousePosition()) > 4 * g_DrawScale)
				{
					g_gumpManager->m_draggedObjectId = g_objectUnderMousePointer->m_ID;
					g_gumpManager->m_draggingObject = true;
					g_gumpManager->m_sourceGump = nullptr;
					g_gumpManager->m_sourceSlotIndex = -1;  // Not from a paperdoll slot
					g_gumpManager->m_draggedObjectOriginalPos = g_objectUnderMousePointer->m_Pos;  // Store original world position
					g_gumpManager->m_draggedObjectOriginalDest = g_objectUnderMousePointer->m_Dest;  // Store original destination (for NPCs)

					// Remove object from world immediately when drag starts
					g_objectUnderMousePointer->m_isContained = true;  // Mark as contained so it won't be drawn in world
					Log("Removed object " + std::to_string(g_objectUnderMousePointer->m_ID) + " from world on drag start");

					// Close any gump associated with this object to prevent dragging into itself
					g_gumpManager->CloseGumpForObject(g_objectUnderMousePointer->m_ID);

				}
			}
		}
	}

	if (IsMouseButtonPressed(MOUSE_BUTTON_MIDDLE) && g_objectUnderMousePointer != nullptr && !g_mouseOverUI)
	{
		std::string filePath;
		string scriptName;
		bool validScript = false;
		if (g_objectUnderMousePointer->m_hasConversationTree)
		{
			int NPCId = g_objectUnderMousePointer->m_NPCID;
			scriptName = "func_04";
			stringstream ss;
			ss << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << NPCId;
			scriptName += ss.str();
		}
		else
		{
			scriptName = "func_0";
			stringstream ss;
			ss << std::setw(3) << std::setfill('0') << std::hex << std::uppercase << g_objectUnderMousePointer->m_shapeData->m_shape;
			scriptName += ss.str();
		}

		//  Find the script path from the script name
		int newScriptIndex = 0;
		for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
		{
			if (g_ScriptingSystem->m_scriptFiles[i].first == scriptName)
			{
				newScriptIndex = i;
				validScript = true;
				break;
			}
		}

		if (!validScript)
		{
			AddConsoleString("No script for object " + to_string(g_objectUnderMousePointer->m_shapeData->m_shape) + " (" + g_objectUnderMousePointer->m_objectData->m_name + ")");
		}
		else
		{
			filePath = g_ScriptingSystem->m_scriptFiles[newScriptIndex].second;

			// Open the file with the default system application
#ifdef _WIN32
			system(("start \"\" \"" + std::string(filePath) + "\"").c_str());
#elif __APPLE__
			system(("open \"" + std::string(filePath) + "\"").c_str());
#else // Linux and others
			system(("xdg-open \"" + std::string(filePath) + "\"").c_str());
#endif
		}
	}

	if (WasMouseButtonDoubleClicked(MOUSE_BUTTON_LEFT))// && !g_mouseOverUI && !g_gumpManager->m_isMouseOverGump)
	{
		if (g_objectUnderMousePointer != nullptr)
		{
			// Check if this is the avatar or a party member NPC
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
				{
					// Open/toggle paperdoll
					TogglePaperdoll(npcId);
				}
				else
				{
					// No paperdoll open and not avatar - run normal NPC interaction
					Log("Running normal interaction for NPC " + std::to_string(npcId));
					g_objectUnderMousePointer->Interact(1);
				}
			}
			// Handle doors and objects with scripts/conversations
			else if (g_objectUnderMousePointer->m_objectData->m_isDoor ||
				g_objectUnderMousePointer->m_hasConversationTree ||
				g_objectUnderMousePointer->m_shapeData->m_luaScript != "default")
			{
				g_objectUnderMousePointer->Interact(1);;
			}
			else if (g_objectUnderMousePointer->m_isContainer && !g_objectUnderMousePointer->IsLocked())
			{
				OpenGump(g_objectUnderMousePointer->m_ID);
			}
			else if (g_objectUnderMousePointer->m_isContainer)
			{
				Bark(g_objectUnderMousePointer, "Locked", 3.0f);
			}
			else if (!g_objectUnderMousePointer->m_isContainer)
			{
				AddConsoleString("Object " + to_string(g_objectUnderMousePointer->m_ID) + " is not a container.");
			}
		}
		else
		{
			int worldX = (int)floor(g_terrainUnderMousePointer.x);
			int worldZ = (int)floor(g_terrainUnderMousePointer.z);

			U7Object* avatar = g_objectList[g_NPCData[0]->m_objectID].get();
			//avatar->SetDest({float(worldX), 0, float(worldZ)});
			avatar->PathfindToDest({float(worldX), 0, float(worldZ)});

			int counter = 1;
			for (int id : g_Player->GetPartyMemberIds())
			{
				U7Object* partyMember = g_objectList[g_NPCData[id]->m_objectID].get();
				if (id % 2 == 0)
					partyMember->PathfindToDest({float(worldX + counter), 0, float(worldZ + counter)});
				else
					partyMember->PathfindToDest({float(worldX + counter), 0, float(worldZ - counter)});

				counter += 1;
			}

			if (worldX >= 0 && worldX < 3072 && worldZ >= 0 && worldZ < 3072)
			{
				// Get terrain shape
				unsigned short shapeframe = g_World[worldZ][worldX];
				int shapeID = shapeframe & 0x3ff;  // Bits 0-9
				int frameID = (shapeframe >> 10) & 0x3f;  // Bits 10-15

				// Look up name and cost from terrain costs
				extern AStar* g_aStar;
				string terrainName = g_aStar ? g_aStar->GetTerrainName(shapeID) : "Unknown";
				bool walkable = g_pathfindingGrid->IsPositionWalkable(worldX, worldZ);

				//AddConsoleString("=== " + terrainName + " (" + to_string(worldX) + ", " + to_string(worldZ) + ") ===", SKYBLUE);
				//AddConsoleString("  Shape ID: " + to_string(shapeID) + ", Frame: " + to_string(frameID), WHITE);

				if (walkable)
				{
					float cost = g_aStar ? g_aStar->GetMovementCost(worldX, worldZ, g_pathfindingGrid) : 1.0f;
					//AddConsoleString("  Movement Cost: " + to_string(cost), GREEN);
					//AddConsoleString("  Walkable: YES", GREEN);
				}
				else
				{
					//AddConsoleString("  Walkable: NO", RED);
				}
			}
		}

	}
	else if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
	{
		if (!g_gumpManager->m_isMouseOverGump && !g_gumpManager->m_draggingObject && !g_mouseOverUI && g_objectUnderMousePointer != nullptr)
		{
			if (m_objectSelectionMode == true)
			{
				if (g_ScriptingSystem->IsCoroutineYielded(m_luaFunction))
				{
					m_objectSelectionMode = false;
					g_ScriptingSystem->ResumeCoroutine(m_luaFunction, { g_objectUnderMousePointer->m_ID }); // Lua arrays are 1-indexed
				}
			}
			else
			{
				Bark(g_objectUnderMousePointer, "", 3.0f);  // Empty string = use object's current name

				// If NPC list window is open and this is an NPC, select it in the list
				if (g_objectUnderMousePointer->m_isNPC && m_npcListWindow && m_npcListWindow->IsVisible())
				{
					m_npcListWindow->SelectNPC(g_objectUnderMousePointer->m_NPCID);
				}

				// Debug mode: Print NPC schedule when clicking on NPCs
				if (g_LuaDebug && g_objectUnderMousePointer->m_isNPC)
				{
					int npcID = g_objectUnderMousePointer->m_NPCID;
					string npcName = g_NPCData[npcID] ? g_NPCData[npcID]->name : "Unknown";
//					AddConsoleString("=== NPC #" + to_string(npcID) + " (" + npcName + ") Schedule ===");
//					AddConsoleString("Current game time: " + to_string(g_hour) + ":" + (g_minute < 10 ? "0" : "") + to_string(g_minute) +
						//" (schedule block: " + to_string(g_scheduleTime) + ")");

					if (g_NPCSchedules.find(npcID) != g_NPCSchedules.end() && !g_NPCSchedules[npcID].empty())
					{
						// Create sorted indices based on schedule time
						vector<int> sortedIndices(g_NPCSchedules[npcID].size());
						for (int i = 0; i < static_cast<int>(sortedIndices.size()); i++)
							sortedIndices[i] = i;

						std::sort(sortedIndices.begin(), sortedIndices.end(),
							[npcID](int a, int b) {
							return g_NPCSchedules[npcID][a].m_time < g_NPCSchedules[npcID][b].m_time;
						});

						// Find the currently active schedule (most recent schedule where time <= current time)
						int activeScheduleIndex = -1;
						for (int idx : sortedIndices)
						{
							if (g_NPCSchedules[npcID][idx].m_time <= g_scheduleTime)
							{
								activeScheduleIndex = idx;
							}
							else
							{
								break;  // Now sorted, so we can break early
							}
						}

						// If no schedule found, use the last one in sorted order (wraps from midnight)
						if (activeScheduleIndex == -1 && g_NPCSchedules[npcID].size() > 0)
						{
							activeScheduleIndex = sortedIndices[sortedIndices.size() - 1];
						}

						// Display schedules in chronological order
						for (int idx : sortedIndices)
						{
							const auto& schedule = g_NPCSchedules[npcID][idx];
							string timeStr;
							switch (schedule.m_time)
							{
							case 0: timeStr = "0:00 (Midnight)"; break;
							case 1: timeStr = "3:00"; break;
							case 2: timeStr = "6:00"; break;
							case 3: timeStr = "9:00"; break;
							case 4: timeStr = "12:00 (Noon)"; break;
							case 5: timeStr = "15:00"; break;
							case 6: timeStr = "18:00"; break;
							case 7: timeStr = "21:00"; break;
							default: timeStr = to_string(schedule.m_time); break;
							}

							// Print active schedule in gold, others in white
							bool isActive = (idx == activeScheduleIndex);
							Color lineColor = isActive ? GOLD : WHITE;
							AddConsoleString("  [" + to_string(idx) + "] Time: " + timeStr +
								", Dest: (" + to_string(schedule.m_destX) + ", " + to_string(schedule.m_destY) + ")" +
								", Activity: " + to_string(schedule.m_activity), lineColor);
						}
					}
					else
					{
						AddConsoleString("  No schedule data for this NPC");
					}

					// Print current waypoints if any
					if (!g_objectUnderMousePointer->m_pathWaypoints.empty())
					{
						// AddConsoleString("=== Current Waypoints ===", YELLOW);
						// AddConsoleString("  Total waypoints: " + to_string(g_objectUnderMousePointer->m_pathWaypoints.size()) +
						// 	", Current index: " + to_string(g_objectUnderMousePointer->m_currentWaypointIndex));
						for (size_t i = 0; i < g_objectUnderMousePointer->m_pathWaypoints.size(); i++)
						{
							const auto& wp = g_objectUnderMousePointer->m_pathWaypoints[i];
							string marker = (i == g_objectUnderMousePointer->m_currentWaypointIndex) ? " <-- CURRENT" : "";
							// AddConsoleString("  [" + to_string(i) + "] (" +
							// 	to_string((int)wp.x) + ", " + to_string((int)wp.z) + ")" + marker);
						}
					}
					else
					{
						AddConsoleString("No active waypoints", GRAY);
					}
				}
			}
		}
		else if (!g_gumpManager->m_isMouseOverGump && !g_gumpManager->m_draggingObject && !g_mouseOverUI && g_objectUnderMousePointer == nullptr)
		{
#ifdef DEBUG_NPC_PATHFINDING
			// Clicked on terrain (no object) - show terrain debug info (sandbox mode only)
			if (m_gameMode == MainStateModes::MAIN_STATE_MODE_SANDBOX)
			{

			}
#endif
		}
	}

	// if (WasMouseButtonDoubleClicked(MOUSE_BUTTON_RIGHT) && g_objectUnderMousePointer != nullptr)
	// {
	// 	if (g_objectUnderMousePointer->m_isContainer && !g_objectUnderMousePointer->IsLocked())
	// 	{
	// 		OpenGump(g_objectUnderMousePointer->m_ID);
	// 	}
	// 	else if (g_objectUnderMousePointer->m_isContainer)
	// 	{
	// 		Bark(g_objectUnderMousePointer, "Locked", 3.0f);
	// 	}
	//
	// }

	if (g_isCameraLockedToAvatar && g_allowInput)
	{
		Vector3 direction = { 0, 0, 0 };
		bool avatarMoved = false;
		if (IsKeyDown(KEY_A))
		{
			direction = Vector3Add(direction, { -GetFrameTime() * g_Player->GetAvatarObject()->GetSpeed(), 0, GetFrameTime() * g_Player->GetAvatarObject()->GetSpeed() });
			avatarMoved = true;

		}

		if (IsKeyDown(KEY_D))
		{
			direction = Vector3Add(direction, { GetFrameTime() * g_Player->GetAvatarObject()->GetSpeed(), 0, -GetFrameTime() * g_Player->GetAvatarObject()->GetSpeed() });
			avatarMoved = true;
		}

		if (IsKeyDown(KEY_W))
		{
			direction = Vector3Add(direction, { -GetFrameTime() * g_Player->GetAvatarObject()->GetSpeed(), 0, -GetFrameTime() * g_Player->GetAvatarObject()->GetSpeed() });
			avatarMoved = true;
		}

		if (IsKeyDown(KEY_S))
		{
			direction = Vector3Add(direction, { GetFrameTime() * g_Player->GetAvatarObject()->GetSpeed(), 0, GetFrameTime() * g_Player->GetAvatarObject()->GetSpeed() });
			avatarMoved = true;
		}

		if (avatarMoved)
		{
			Vector3 finalmovement = Vector3RotateByAxisAngle(direction, Vector3{ 0, 1, 0 }, g_cameraRotation);
			g_Player->GetAvatarObject()->SetDest(Vector3Add(g_Player->GetAvatarObject()->GetPos(), finalmovement));
		}
	}
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

	unsigned short currentTargetTile = g_World[g_camera.target.z][g_camera.target.x];
	currentTargetTile = currentTargetTile & 0x3ff; // We just need the shape, not the frame.
	if (currentTargetTile == 0 || currentTargetTile == 5 || currentTargetTile == 17 || currentTargetTile == 18 ||
		currentTargetTile == 21 || currentTargetTile == 23 || currentTargetTile == 27 || currentTargetTile == 47 || currentTargetTile >= 149)
	{
		m_heightCutoff = 4.0f;
	}
	else
	{
		m_heightCutoff = 16.0f;
	}

	// Check if schedule time has changed and populate pathfinding queue
	if (g_scheduleTime != g_lastScheduleTimeCheck)
	{
		g_lastScheduleTimeCheck = g_scheduleTime;

		// Clear any pending pathfinding requests from previous schedule
		while (!g_npcPathfindQueue.empty())
			g_npcPathfindQueue.pop();

		// Enqueue all NPCs that need to move to a new destination
		for (const auto& [npcID, npcData] : g_NPCData)
		{
			if (!npcData || npcData->m_objectID < 0)
				continue;

			// Check if this NPC has schedules and is following them
			if (g_NPCSchedules.find(npcID) == g_NPCSchedules.end() || g_NPCSchedules[npcID].empty())
				continue;

			U7Object* npcObj = g_objectList[npcData->m_objectID].get();
			if (!npcObj || !npcObj->m_followingSchedule)
				continue;

			// Find the most recent schedule entry <= current time
			// This ensures NPCs update to correct activity even when time skips or when loading
			int mostRecentScheduleTime = -1;
			int mostRecentActivity = -1;
			for (const auto& schedule : g_NPCSchedules[npcID])
			{
				if (schedule.m_time <= g_scheduleTime && (int)schedule.m_time > mostRecentScheduleTime)
				{
					mostRecentScheduleTime = (int)schedule.m_time;
					mostRecentActivity = (int)schedule.m_activity;
				}
			}

			// If we found a valid schedule and it's different from current, update it
			if (mostRecentScheduleTime >= 0)
			{
				// Only update activity if there's an EXACT schedule entry for current time
				// This prevents "None" entries (which don't exist in SCHEDULE.DAT) from changing activities
				// InitializeNPCActivitiesFromSchedules() already filled in activities at startup
				if (mostRecentScheduleTime == g_scheduleTime)
				{
					// Check if this is a NEW schedule (different time or activity changed)
					bool needsUpdate = (mostRecentScheduleTime != npcObj->m_lastSchedule) ||
					                   (mostRecentActivity != npcData->m_currentActivity);

					if (needsUpdate)
					{
						// Update the schedule time and activity
						npcObj->m_lastSchedule = mostRecentScheduleTime;
						npcData->m_currentActivity = mostRecentActivity;
					// Clear schedule path flag - will be set again if new schedule has destination
					npcObj->m_isSchedulePath = false;


						// Only queue for pathfinding if pathfinding is enabled
						if (m_npcPathfindingEnabled)
						{
							g_npcPathfindQueue.push(npcID);
						}
					}
				}
				// else: no exact match for current time = "None" entry, keep current activity
			}
		}

		// Debug: Show schedule changes
		if (!g_npcPathfindQueue.empty())
		{
			AddConsoleString("Schedule changed to block " + std::to_string(g_scheduleTime) +
			                 ", queued " + std::to_string(g_npcPathfindQueue.size()) + " NPCs for pathfinding", YELLOW);
		}
	}

	// Process pathfinding results from background threads
	if (g_pathfindingThreadPool)
	{
		PathResult result;
		while (g_pathfindingThreadPool->PopResult(result))
		{
			// Find the NPC and apply waypoints
			if (g_NPCData.find(result.npcID) != g_NPCData.end() && g_NPCData[result.npcID])
			{
				U7Object* npcObj = g_objectList[g_NPCData[result.npcID]->m_objectID].get();
				if (npcObj && result.success)
				{
					npcObj->m_pathWaypoints = result.waypoints;
					npcObj->m_currentWaypointIndex = 0;
					npcObj->m_pathfindingPending = false;  // Path is ready!

					// If this was a tracked request, mark it as ready for Lua
					// Lua will call start_following_path() to begin movement
					if (result.requestID > 0)
					{
						NPCDebugPrint("MainState: Tracked path ready for NPC " + std::to_string(result.npcID) +
						           ", request ID " + std::to_string(result.requestID) +
						           ", " + std::to_string(result.waypoints.size()) + " waypoints");
						npcObj->m_isSchedulePath = false;  // Lua activity path
						g_pathfindingThreadPool->MarkRequestReady(result.requestID);
					}
					// Fire-and-forget requests (requestID == 0) start movement immediately
					else if (!result.waypoints.empty())
					{
						NPCDebugPrint("MainState: Fire-and-forget path ready for NPC " + std::to_string(result.npcID) +
						           ", " + std::to_string(result.waypoints.size()) + " waypoints, auto-starting");
						npcObj->m_isSchedulePath = true;  // C++ schedule path
						npcObj->SetDest(result.waypoints[0]);
						npcObj->m_isMoving = true;
					}

#ifdef DEBUG_NPC_PATHFINDING
					// Track longest path for this NPC
					if (!result.waypoints.empty())
					{
						float pathDistance = Vector3Distance(result.waypoints.front(), result.waypoints.back());
						auto it = g_npcMaxPathStats.find(result.npcID);
						if (it == g_npcMaxPathStats.end() || pathDistance > it->second.distance)
						{
							NPCPathStats stats;
							stats.npcID = result.npcID;
							stats.startPos = result.waypoints.front();
							stats.endPos = result.waypoints.back();
							stats.distance = pathDistance;
							stats.waypointCount = (int)result.waypoints.size();
							g_npcMaxPathStats[result.npcID] = stats;
						}
					}
#endif
				}
			}
		}
	}

	// Process one NPC from pathfinding queue per frame (submit to thread pool or fall back to sync)
	if (!g_npcPathfindQueue.empty())
	{
		int npcID = g_npcPathfindQueue.front();
		g_npcPathfindQueue.pop();

		// Find the most recent schedule entry <= current time
		if (g_NPCData.find(npcID) != g_NPCData.end() && g_NPCData[npcID])
		{
			U7Object* npcObj = g_objectList[g_NPCData[npcID]->m_objectID].get();
			if (npcObj && g_NPCSchedules.find(npcID) != g_NPCSchedules.end())
			{
				// Find most recent schedule
				int mostRecentScheduleTime = -1;
				const NPCSchedule* mostRecentSchedule = nullptr;

				for (const auto& schedule : g_NPCSchedules[npcID])
				{
					if (schedule.m_time <= g_scheduleTime && (int)schedule.m_time > mostRecentScheduleTime)
					{
						mostRecentScheduleTime = (int)schedule.m_time;
						mostRecentSchedule = &schedule;
					}
				}

				if (mostRecentSchedule)
				{
					// Pathfind to destination (will use thread pool if available, otherwise sync A*)
					npcObj->m_isSchedulePath = true;  // Mark as schedule path to block activity scripts
					npcObj->PathfindToDest(Vector3{ float(mostRecentSchedule->m_destX), 0, float(mostRecentSchedule->m_destY) });
					npcObj->m_isMoving = true;
				}
			else
			{
				// No schedule destination ("None" entry) - clear schedule path flag so activity can run
				npcObj->m_isSchedulePath = false;
			}
			}
		}
	}

	g_gumpManager->Update();

	if (GetTime() - m_LastUpdate > GetFrameTime())
	{
		g_CurrentUpdate++;

		m_NumberOfVisibleUnits = 0;
		m_numberofDrawnObjects = 0;
		m_numberofObjectsPassingFirstCheck = 0;

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

	if (!m_paused)
	{
		m_cameraUpdateTime = DoCameraMovement();
	}

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
		if (m_ranIolosScript && g_StateMachine->GetCurrentState() == STATE_CONVERSATIONSTATE)
		{
			m_iolosScriptRunning = true;
		}
		else if (!m_ranIolosScript)
		{
			m_ranIolosScript = true;
			g_objectList[g_NPCData[1]->m_objectID]->Interact(3);
		}

		// if (m_iolosScriptRunning && g_StateMachine->GetCurrentState() != STATE_CONVERSATIONSTATE) // Iolo's script finished.
		// {
		// 	m_iolosScriptRunning = false;
		// 	if (!m_ranFinnigansScript) // Run Finnigan's script only once.
		// 	{
		// 		m_ranFinnigansScript = true;
		// 		g_objectList[g_NPCData[12]->m_objectID]->Interact(1);
		// 	}
		// }
	}

	if (int(g_terrainUnderMousePointer.x / 16) == 66 && int(g_terrainUnderMousePointer.z / 16 == 137) && g_ScriptingSystem->GetFlag(60) == false)
	{
		g_ScriptingSystem->SetFlag(60, true);
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

	if (g_gumpManager->m_draggingObject && !g_gumpManager->m_isMouseOverGump)
	{
		U7Object* draggedObject = g_objectList[g_gumpManager->m_draggedObjectId].get();
		BoundingBox box = { Vector3{0, 0, 0}, Vector3{0, 0, 0} };
		box.min = Vector3Subtract(g_terrainUnderMousePointer, { draggedObject->m_shapeData->m_Dims.x - 1, 0, draggedObject->m_shapeData->m_Dims.z - 1 });//, {draggedObject->m_shapeData->m_Dims.x / 2, draggedObject->m_shapeData->m_Dims.y / 2, draggedObject->m_shapeData->m_Dims.z / 2});
		box.max = Vector3Add(box.min, draggedObject->m_shapeData->m_Dims);
		DrawBoundingBox(box, WHITE);
	}

	// Draw pathfinding debug overlay (tile-level - shows objects)
	if (m_showPathfindingDebug && g_pathfindingGrid)
	{
		g_pathfindingGrid->DrawDebugOverlayTileLevel();
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
					{object->m_Pos.x, object->m_Pos.z},
					{g_camera.target.x, g_camera.target.z}
				);

				if (distToCamera < 50.0f)  // Within 50 tiles of camera
				{
					// Draw waypoints: Orange for C++ schedule paths, Blue for Lua activity paths
					Color pathColor = object->m_isSchedulePath ?
						Color{255, 128, 0, 255} :   // Orange for schedule paths
						Color{50, 50, 255, 255};     // Blue for Lua paths

					for (size_t i = 0; i < object->m_pathWaypoints.size(); i++)
					{
						const auto& waypoint = object->m_pathWaypoints[i];
						// Waypoint already contains correct Y coordinate from pathfinding
						Vector3 tilePos = {waypoint.x + 0.5f, waypoint.y + 0.05f, waypoint.z + 0.5f};
						// First tile is black, rest use the path color (orange/blue)
						Color tileColor = (i == 0) ? Color{0, 0, 0, 255} : pathColor;
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
	// This prevents anti-aliased text from creating transparent "holes" in gump backgrounds
	// RGB: Normal alpha blending (SRC_ALPHA, ONE_MINUS_SRC_ALPHA)
	// Alpha: Use MAX to preserve background alpha (ONE, ONE_MINUS_SRC_ALPHA gives us max(src.a, dst.a))
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
		DrawOutlinedText(g_SmallFont, g_version.c_str(), Vector2{ 600, 340 }, g_SmallFont->baseSize, 1, WHITE);

		// Draw FPS counter next to version
		int fps = GetFPS();
		string fpsText = "FPS: " + to_string(fps);
		Color fpsColor = fps >= 60 ? GREEN : (fps >= 30 ? YELLOW : RED);
		DrawOutlinedText(g_SmallFont, fpsText.c_str(), Vector2{ 520, 340 }, g_SmallFont->baseSize, 1, fpsColor);

		// Clamp camera coordinates to valid world bounds before accessing g_World
		int worldX = int(g_camera.target.x);
		int worldZ = int(g_camera.target.z);
		if (worldX < 0) worldX = 0;
		if (worldX >= 3072) worldX = 3071;
		if (worldZ < 0) worldZ = 0;
		if (worldZ >= 3072) worldZ = 3071;

		unsigned short shapeframe = g_World[worldZ][worldX];
		int shape = shapeframe & 0x3ff;

		if (g_objectUnderMousePointer != nullptr && !g_gumpManager->m_isMouseOverGump)
		{
			std::string objectDescription;
			if (g_objectUnderMousePointer->m_isContainer)
				objectDescription = "Container ";
			else if (g_objectUnderMousePointer->m_isNPC)
				objectDescription = "NPC ";
			else if (g_objectUnderMousePointer->m_isEgg)
				objectDescription = "Egg ";
			else
				objectDescription = "Object ";

			objectDescription += GetObjectDisplayName(g_objectUnderMousePointer) + " at " +
				to_string(int(g_objectUnderMousePointer->m_Pos.x)) +
				" " +
				to_string(int(g_objectUnderMousePointer->m_Pos.z)) +
				" Quality: " +
				to_string(int(g_objectUnderMousePointer->m_Quality));

			// Show frame for doors
			if (g_objectUnderMousePointer->m_objectData && g_objectUnderMousePointer->m_objectData->m_isDoor)
			{
				objectDescription += " Frame: " + to_string(g_objectUnderMousePointer->m_Frame);
			}

			// Show lua script if not default
			if (g_objectUnderMousePointer->m_isNPC && g_objectUnderMousePointer->m_hasConversationTree)
			{
				// NPCs look up scripts by NPC ID suffix: npc_*_XXXX
				string scriptName = FindNPCScriptByID(g_objectUnderMousePointer->m_NPCID);
				if (!scriptName.empty())
				{
					objectDescription += " Script: " + scriptName;
				}
			}
			else
			{
				// Regular objects use shape table scripts
				int shape = g_objectUnderMousePointer->m_shapeData->GetShape();
				int frame = g_objectUnderMousePointer->m_shapeData->GetFrame();
				if (shape < g_shapeTable.size() && frame < g_shapeTable[shape].size())
				{
					const std::string& scriptName = g_shapeTable[shape][frame].m_luaScript;
					if (!scriptName.empty() && scriptName != "default")
					{
						objectDescription += " Script: " + scriptName;
					}
				}
			}

			if (g_objectUnderMousePointer->m_isContained)
			{
				objectDescription += " This object is contained.";
			}

			//DrawOutlinedText(g_SmallFont, objectDescription, Vector2{ 10, 288 }, g_SmallFont->baseSize, 1, WHITE);
		}
		//DrawOutlinedText(g_SmallFont, "Current chunk: " + to_string(int(g_camera.target.x / 16.0f)) + " x " + to_string(int(g_camera.target.z / 16.0f)), Vector2{ 10, 304 }, g_SmallFont->baseSize, 1, WHITE);
		//DrawOutlinedText(g_SmallFont, "Objects: " + to_string(g_ObjectList.size()) + " Visible: " + to_string(g_sortedVisibleObjects.size()), Vector2{ 10, 320 }, g_SmallFont->baseSize, 1, WHITE);
	}
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

		// Bark text is already set in Bark() function (either custom text or generated from object name)
		float width = MeasureTextEx(*g_ConversationFont, m_barkText.c_str(), g_ConversationFont->baseSize, 1).x * 1.2;
		screenPos.x -= width / 2;
		float height = g_ConversationFont->baseSize * 1.2;

		DrawRectangleRounded({ screenPos.x, screenPos.y, width, height }, 5, 100, { 0, 0, 0, 192 });
		DrawTextEx(*g_ConversationFont, m_barkText.c_str(), { float(screenPos.x) + (width * .1f), float(screenPos.y) + (height * .1f) }, g_ConversationFont->baseSize, 1, YELLOW);
	}

	//unsigned short shapenum = g_World[j][i] & 0x3ff;
	//unsigned short framenum = (g_World[j][i] >> 10) & 0x1f;

	//unsigned short shapenum = g_World[static_cast<unsigned short>(g_camera.target.z)][static_cast<unsigned short>(g_camera.target.x)] & 0x3ff;
	//unsigned short shapenum = currentTargetTile & 0x3ff;
	//unsigned short framenum = (g_World[static_cast<unsigned short>(g_camera.target.z)][static_cast<unsigned short>(g_camera.target.x)] >> 10) & 0x1f;
	//currentTargetTile = currentTargetTile & 0x3ff;
	//DrawOutlinedText(g_SmallFont, "Tile under camera target: " + to_string(shapenum) + " " + to_string(framenum), Vector2{ 10, 288 }, g_SmallFont->baseSize, 1, WHITE);
	//DrawOutlinedText(g_SmallFont, "Camera Target: " + to_string(g_camera.target.x) + " " + to_string(g_camera.target.y) + " " + to_string(g_camera.target.z), Vector2{ 10, 308 }, g_SmallFont->baseSize, 1, WHITE);

	if (!m_paused && m_showUIElements)
	{
		g_gumpManager->Draw();
	}

	// Restore default blend mode
	rlSetBlendMode(BLEND_ALPHA);

	EndTextureMode();


	DrawTexturePro(g_guiRenderTarget.texture,
		{ 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
		{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
		{ 0, 0 }, 0, WHITE);

	if (!m_paused && m_showUIElements)
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

	DrawRectangle(0, 0, g_Engine->m_ScreenWidth, g_Engine->m_ScreenHeight, { 0, 0, 0, m_currentFadeAlpha });
}

void MainState::SetupGame()
{

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
			//  I'm a pretty girl!
			thisTexture = g_ResourceManager->GetTexture("U7FACES" + to_string(i) + to_string(1));
		}
		else
		{
			thisTexture = g_ResourceManager->GetTexture("U7FACES" + to_string(i) + to_string(0));
		}

		//DrawTextureEx(*thisTexture, {538.0f - thisTexture->width, 200.0f + 48.0f * counter}, 0, 1, WHITE);
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



	//  Draw backpack
	DrawTextureEx(*g_shapeTable[801][0].GetTexture(), Vector2{ 610, 314 }, 0, 1, Color{ 255, 255, 255, 255 });


}

void MainState::UpdateStats()
{
	int counter = 0;
	for (int i = 0; i < g_Player->GetPartyMemberIds().size(); ++i)
	{
		Texture* thisTexture = g_ResourceManager->GetTexture("U7FACES" + to_string(i) + to_string(0));
		Rectangle portraitRect = { (538.0f - thisTexture->width) * g_DrawScale, (200.0f + 40.0f * counter) * g_DrawScale, thisTexture->width * g_DrawScale, thisTexture->height * g_DrawScale };

		// Check for double-click to toggle paperdoll
		if (WasMouseButtonDoubleClicked(MOUSE_LEFT_BUTTON) && CheckCollisionPointRec(GetMousePosition(), portraitRect))
		{
			TogglePaperdoll(g_Player->GetPartyMemberIds()[i]);
		}
		// Check for single click to select party member
		else if (WasLeftButtonClickedInRect(portraitRect.x, portraitRect.y, portraitRect.width, portraitRect.height))
		{
			g_Player->SetSelectedPartyMember(g_Player->GetPartyMemberIds()[i]);
		}
		++counter;
	}

	if (WasLeftButtonClickedInRect({ 610 * g_DrawScale, 314 * g_DrawScale, 16 * g_DrawScale, 10 * g_DrawScale }))
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

////////////////////////////////////////////////////////////////////////////////
//  Debug Tools Window Handler Functions
////////////////////////////////////////////////////////////////////////////////

void MainState::HandleScheduleButton()
{
	m_npcSchedulesEnabled = !m_npcSchedulesEnabled;

	// Update all NPCs
	for (const auto& [id, npcData] : g_NPCData)
	{
		if (npcData && npcData->m_objectID >= 0)
		{
			g_objectList[npcData->m_objectID]->m_followingSchedule = m_npcSchedulesEnabled;
		}
	}

	AddConsoleString(m_npcSchedulesEnabled ? "NPC Schedules ENABLED" : "NPC Schedules DISABLED");
}

void MainState::HandlePathfindButton()
{
	m_npcPathfindingEnabled = !m_npcPathfindingEnabled;

	// Clear the pathfinding queue when disabling pathfinding
	if (!m_npcPathfindingEnabled)
	{
		while (!g_npcPathfindQueue.empty())
		{
			g_npcPathfindQueue.pop();
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
