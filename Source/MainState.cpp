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
#include "ConversationState.h"
#include "GumpManager.h"
#include "Pathfinding.h"

#include <list>
#include <string>
#include <sstream>
#include <iomanip>
#include <math.h>
#include <fstream>
#include <algorithm>
#include <unordered_map>

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

	SetupGame();
}

void MainState::OnEnter()
{
	g_lastTime = 0;
	g_minute = 0;
	g_hour = 7;
	g_scheduleTime = 1;

	if (m_gameMode == MainStateModes::MAIN_STATE_MODE_TRINSIC_DEMO)
	{
		m_heightCutoff = 16.0f; // Draw everything unless the player is inside.

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

void MainState::OnExit()
{
}

void MainState::Shutdown()
{
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
		unsigned char red_green = (darklevel / 2) + ((float(g_minute) / 60.0f) * (255 - red_green_level));
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

	// unsigned short shapeframe = g_World[int(g_camera.target.z)][int(g_camera.target.x)];
	// int shape = shapeframe & 0x3ff;
	// if (shape == 0 || shape == 5 || shape == 17 || shape == 18 || shape == 21 || shape == 27 || shape == 47 || shape >= 149)
	// {
	// 	m_heightCutoff = 4.0f;
	// }
	// else
	// {
	// 	m_heightCutoff = 16.0f;
	// }

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

	// Schedule button (sandbox mode only)
	Rectangle scheduleButtonRect = {
		m_scheduleToggleButton.x * g_DrawScale,
		m_scheduleToggleButton.y * g_DrawScale,
		m_scheduleToggleButton.width * g_DrawScale,
		m_scheduleToggleButton.height * g_DrawScale
	};

	Vector2 mousePos = GetMousePosition();
	bool overStats = IsPosInRect(mousePos, statsPanelRect);
	bool overMinimap = IsPosInRect(mousePos, minimapRect);
	bool overCharPanel = IsPosInRect(mousePos, charPanelRect);
	bool overSchedule = (m_gameMode == MainStateModes::MAIN_STATE_MODE_SANDBOX && IsPosInRect(mousePos, scheduleButtonRect));

	g_mouseOverUI = overStats || overMinimap || overCharPanel || overSchedule;
}

void MainState::UpdateInput()
{
	if (!m_allowInput)
	{
		return;
	}

	// Handle NPC Schedule Toggle Button clicks (Sandbox mode only)
	if (m_gameMode == MainStateModes::MAIN_STATE_MODE_SANDBOX && m_showUIElements && !m_paused)
	{
		Rectangle scaledButton = {
			m_scheduleToggleButton.x * g_DrawScale,
			m_scheduleToggleButton.y * g_DrawScale,
			m_scheduleToggleButton.width * g_DrawScale,
			m_scheduleToggleButton.height * g_DrawScale
		};

		if (WasLeftButtonClickedInRect(scaledButton))
		{
			m_npcSchedulesEnabled = !m_npcSchedulesEnabled;

			// Toggle schedules for all NPCs
			for (const auto& [id, npcData] : g_NPCData)
			{
				if (npcData && npcData->m_objectID >= 0)
				{
					g_objectList[npcData->m_objectID]->m_followingSchedule = m_npcSchedulesEnabled;
				}
			}

			AddConsoleString(m_npcSchedulesEnabled ? "NPC Schedules ENABLED" : "NPC Schedules DISABLED");

#ifdef DEBUG_NPC_PATHFINDING
			// When schedules are disabled, print path statistics
			if (!m_npcSchedulesEnabled)
			{
				PrintNPCPathStats();
			}
#endif
		}
	}

	if (IsKeyPressed(KEY_ESCAPE))
	{
		if (!g_gumpManager->m_GumpList.empty())
		{
			g_gumpManager->m_GumpList.back().get()->SetIsDead(true);
		}
		else
		{
			g_Engine->m_Done = true;
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

	if (IsKeyPressed(KEY_KP_SUBTRACT))
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

	if (IsKeyPressed(KEY_KP_ADD))
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
		m_dragStart = {0, 0};
	}

	// Always update selected shape/frame when clicking an object (for F1 shape editor)
	if (IsMouseButtonDown(MOUSE_LEFT_BUTTON) && g_objectUnderMousePointer != nullptr && !g_gumpManager->m_isMouseOverGump && !g_gumpManager->m_draggingObject && !g_mouseOverUI)
	{
		g_selectedShape = g_objectUnderMousePointer->m_shapeData->m_shape;
		g_selectedFrame = g_objectUnderMousePointer->m_shapeData->m_frame;

		if (m_doingObjectSelection)
		{
			g_ScriptingSystem->ResumeCoroutine(m_luaFunction, {g_objectUnderMousePointer->m_ID}); // Lua arrays are 1-indexed
		}

		// Only allow dragging if not a static object (or if static movement is enabled)
		if (m_allowMovingStaticObjects || g_objectUnderMousePointer->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_STATIC)
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

	if (WasMouseButtonDoubleClicked(MOUSE_BUTTON_LEFT) && g_objectUnderMousePointer != nullptr && !g_mouseOverUI)
	{
		// Handle doors and objects with scripts/conversations
		if (g_objectUnderMousePointer->m_objectData->m_isDoor ||
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
	else if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
	{
		if (!g_gumpManager->m_isMouseOverGump && !g_gumpManager->m_draggingObject && !g_mouseOverUI && g_objectUnderMousePointer != nullptr)
		{
			if (m_objectSelectionMode == true)
			{
				if (g_ScriptingSystem->IsCoroutineYielded(m_luaFunction))
				{
					m_objectSelectionMode = false;
					g_ScriptingSystem->ResumeCoroutine(m_luaFunction, {g_objectUnderMousePointer->m_ID}); // Lua arrays are 1-indexed
				}
			}
			else
			{
				Bark(g_objectUnderMousePointer, "", 3.0f);  // Empty string = use object's current name

				// Visualize NPC waypoints as blue tiles when clicking on any NPC
				if (g_objectUnderMousePointer->m_isNPC)
				{
					if (!g_objectUnderMousePointer->m_pathWaypoints.empty())
					{
						g_pathfindingGrid->SetDebugWaypoints(g_objectUnderMousePointer->m_pathWaypoints);
					}
					else
					{
						// Clear waypoint visualization if no waypoints
						g_pathfindingGrid->SetDebugWaypoints({});
					}
				}

				// Debug mode: Print NPC schedule when clicking on NPCs
				if (g_LuaDebug && g_objectUnderMousePointer->m_isNPC)
				{
					int npcID = g_objectUnderMousePointer->m_NPCID;
					string npcName = g_NPCData[npcID] ? g_NPCData[npcID]->name : "Unknown";
					AddConsoleString("=== NPC #" + to_string(npcID) + " (" + npcName + ") Schedule ===");
					AddConsoleString("Current game time: " + to_string(g_hour) + ":" + (g_minute < 10 ? "0" : "") + to_string(g_minute) +
					                 " (schedule block: " + to_string(g_scheduleTime) + ")");

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
						AddConsoleString("=== Current Waypoints ===", YELLOW);
						AddConsoleString("  Total waypoints: " + to_string(g_objectUnderMousePointer->m_pathWaypoints.size()) +
						                 ", Current index: " + to_string(g_objectUnderMousePointer->m_currentWaypointIndex));
						for (size_t i = 0; i < g_objectUnderMousePointer->m_pathWaypoints.size(); i++)
						{
							const auto& wp = g_objectUnderMousePointer->m_pathWaypoints[i];
							string marker = (i == g_objectUnderMousePointer->m_currentWaypointIndex) ? " <-- CURRENT" : "";
							AddConsoleString("  [" + to_string(i) + "] (" +
							                 to_string((int)wp.x) + ", " + to_string((int)wp.z) + ")" + marker);
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
			// Clicked on terrain (no object) - show terrain debug info
			int worldX = (int)floor(g_terrainUnderMousePointer.x);
			int worldZ = (int)floor(g_terrainUnderMousePointer.z);

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

				AddConsoleString("=== " + terrainName + " (" + to_string(worldX) + ", " + to_string(worldZ) + ") ===", SKYBLUE);
				AddConsoleString("  Shape ID: " + to_string(shapeID) + ", Frame: " + to_string(frameID), WHITE);

				if (walkable)
				{
					float cost = g_aStar ? g_aStar->GetMovementCost(worldX, worldZ, g_pathfindingGrid) : 1.0f;
					AddConsoleString("  Movement Cost: " + to_string(cost), GREEN);
					AddConsoleString("  Walkable: YES", GREEN);
				}
				else
				{
					AddConsoleString("  Walkable: NO", RED);
				}
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
}

void MainState::Bark(U7Object* object, const std::string& text, float duration)
{
	m_barkDuration = duration;
	m_barkObject = object;

	// If text is empty, auto-generate it from object's shape/frame/quantity each frame
	if (text.empty() && object)
	{
		m_barkAutoUpdate = true;
		int quantity = (object->m_Quality > 0) ? object->m_Quality : 1;
		m_barkText = GetShapeFrameName(object->m_shapeData->GetShape(), object->m_shapeData->GetFrame(), quantity);
	}
	else
	{
		m_barkAutoUpdate = false;
		m_barkText = text;
	}
}

void MainState::Update()
{
	UpdateTime();

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

			// Check if NPC has a schedule for this time
			for (const auto& schedule : g_NPCSchedules[npcID])
			{
				if (schedule.m_time == g_scheduleTime)
				{
					g_npcPathfindQueue.push(npcID);
					break;
				}
			}
		}

		// Debug: Uncomment to see schedule changes
		//if (!g_npcPathfindQueue.empty())
		//{
		//	AddConsoleString("Schedule changed to block " + std::to_string(g_scheduleTime) +
		//	                 ", queued " + std::to_string(g_npcPathfindQueue.size()) + " NPCs for pathfinding", YELLOW);
		//}
	}

	// Process one NPC from pathfinding queue per frame
	if (!g_npcPathfindQueue.empty())
	{
		int npcID = g_npcPathfindQueue.front();
		g_npcPathfindQueue.pop();

		// Find the schedule entry for current time
		if (g_NPCData.find(npcID) != g_NPCData.end() && g_NPCData[npcID])
		{
			U7Object* npcObj = g_objectList[g_NPCData[npcID]->m_objectID].get();
			if (npcObj)
			{
				for (const auto& schedule : g_NPCSchedules[npcID])
				{
					if (schedule.m_time == g_scheduleTime)
					{
						npcObj->PathfindToDest(Vector3{ float(schedule.m_destX), 0, float(schedule.m_destY) });
						npcObj->m_isMoving = true;
						npcObj->m_lastSchedule = schedule.m_time;
						g_NPCData[npcID]->m_currentActivity = schedule.m_activity;
						break;
					}
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
					object->m_Visible = true;
				}
			}
		}

		for (unordered_map<int, std::unique_ptr<U7Object> >::iterator node = g_objectList.begin(); node != g_objectList.end();)
		{
			if (!node->second)
				continue;

			if (node->second->GetIsDead())
			{
				UnassignObjectChunk(node->second.get());
				node = g_objectList.erase(node);
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
			g_ScriptingSystem->ResumeCoroutine(m_luaFunction, {0}); // Lua arrays are 1-indexed
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
		g_ScriptingSystem->SetFlag(60 , true);
	}
}

void MainState::OpenGump(int id)
{
	for (auto gump : g_gumpManager->m_GumpList)
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

void MainState::Draw()
{
	if (g_pixelated)
	{
		BeginTextureMode(g_renderTarget);
	}

	ClearBackground(Color{ 0, 0, 0, 255 });

	BeginDrawing();

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

	if (g_gumpManager->m_draggingObject)
	{
		U7Object* draggedObject = g_objectList[g_gumpManager->m_draggedObjectId].get();
		BoundingBox box;
		box.min = Vector3Subtract(g_terrainUnderMousePointer, {draggedObject->m_shapeData->m_Dims.x - 1, 0, draggedObject->m_shapeData->m_Dims.z - 1});//, {draggedObject->m_shapeData->m_Dims.x / 2, draggedObject->m_shapeData->m_Dims.y / 2, draggedObject->m_shapeData->m_Dims.z / 2});
		box.max = Vector3Add(box.min, draggedObject->m_shapeData->m_Dims);
		DrawBoundingBox(box, WHITE);
	}

	// Draw pathfinding debug overlay (tile-level - shows objects)
	if (m_showPathfindingDebug && g_pathfindingGrid)
	{
		g_pathfindingGrid->DrawDebugOverlayTileLevel();
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

		if (m_gameMode == MainStateModes::MAIN_STATE_MODE_SANDBOX && m_showUIElements && !m_paused)
		{
			// Draw NPC Schedule Toggle Button
			Color buttonColor = m_npcSchedulesEnabled ? Color{0, 200, 0, 255} : Color{200, 0, 0, 255}; // Green if on, red if off
			DrawRectangle(m_scheduleToggleButton.x, m_scheduleToggleButton.y,
			              m_scheduleToggleButton.width, m_scheduleToggleButton.height, buttonColor);
			DrawRectangleLines(m_scheduleToggleButton.x, m_scheduleToggleButton.y,
			                   m_scheduleToggleButton.width, m_scheduleToggleButton.height, WHITE);

			// Draw text label next to button
			string scheduleText = m_npcSchedulesEnabled ? "ON" : "OFF";
			DrawTextEx(*g_SmallFont, scheduleText.c_str(),
			           Vector2{m_scheduleToggleButton.x + m_scheduleToggleButton.width + 5,
			                   m_scheduleToggleButton.y + 8},
			           g_SmallFont->baseSize, 1, WHITE);

			//DrawOutlinedText(g_SmallFont, "Cell under mouse: " + to_string(int(g_terrainUnderMousePointer.x)) + " " + to_string(int(g_terrainUnderMousePointer.y))
			// + " " + to_string((int(g_terrainUnderMousePointer.z))) + ", Terrain type " + to_string(shape), Vector2{ 10, 272 }, g_SmallFont->baseSize, 1, WHITE);

			//DrawOutlinedText(g_SmallFont, "Center terrain cell: " + to_string(int(g_camera.target.x)) + " " + to_string(int(g_camera.target.z))
			//				 + ", Terrain type " + to_string(shape), Vector2{ 10, 292 }, g_SmallFont->baseSize, 1, WHITE);
		}

		if (g_objectUnderMousePointer != nullptr)
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

			int quantity = (g_objectUnderMousePointer->m_Quality > 0) ? g_objectUnderMousePointer->m_Quality : 1;
			objectDescription += GetShapeFrameName(g_objectUnderMousePointer->m_shapeData->GetShape(),
			                                        g_objectUnderMousePointer->m_shapeData->GetFrame(),
			                                        quantity) + " at " +
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

			if (g_objectUnderMousePointer->m_isContained)
			{
				objectDescription += " This object is contained.";
			}

			DrawOutlinedText(g_SmallFont, objectDescription, Vector2{ 10, 288 }, g_SmallFont->baseSize, 1, WHITE);
		}
		//DrawOutlinedText(g_SmallFont, "Current chunk: " + to_string(int(g_camera.target.x / 16.0f)) + " x " + to_string(int(g_camera.target.z / 16.0f)), Vector2{ 10, 304 }, g_SmallFont->baseSize, 1, WHITE);
		//DrawOutlinedText(g_SmallFont, "Objects: " + to_string(g_ObjectList.size()) + " Visible: " + to_string(g_sortedVisibleObjects.size()), Vector2{ 10, 320 }, g_SmallFont->baseSize, 1, WHITE);
	}
	// Draw bark text if active
	if (m_barkDuration > 0 && m_barkObject != nullptr)
	{
		// If auto-update is enabled, regenerate bark text from current object state
		if (m_barkAutoUpdate)
		{
			int quantity = (m_barkObject->m_Quality > 0) ? m_barkObject->m_Quality : 1;
			m_barkText = GetShapeFrameName(m_barkObject->m_shapeData->GetShape(), m_barkObject->m_shapeData->GetFrame(), quantity);
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

		DrawRectangleRounded({screenPos.x, screenPos.y, width, height}, 5, 100, {0, 0, 0, 192});
		DrawTextEx(*g_ConversationFont, m_barkText.c_str(), { float(screenPos.x) + (width * .1f), float(screenPos.y) + (height * .1f) }, g_ConversationFont->baseSize, 1, YELLOW);
	}

	if (!m_paused && m_showUIElements)
	{
		g_gumpManager->Draw();
	}

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

		float half = float(g_DrawScale) * float(m_MinimapArrow->width) / 2;

		DrawTextureEx(*m_MinimapArrow, { g_Engine->m_ScreenWidth - float(g_minimapSize * g_DrawScale) + _ScaleX - half, _ScaleZ - half }, 0, g_DrawScale, WHITE);

		if (m_objectSelectionMode)
		{
			DrawTextureEx(*g_objectSelectCursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale, WHITE);
		}
		else
		{
			DrawTextureEx(*g_Cursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale, WHITE);
		}
	}

	DrawRectangle(0, 0, g_Engine->m_ScreenWidth, g_Engine->m_ScreenHeight, { 0, 0, 0, m_currentFadeAlpha });


	EndDrawing();
}

void MainState::SetupGame()
{

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
	DrawOutlinedText(g_SmallFont, "Weight: " + to_string(int(g_Player->GetWeight())) + "/" + to_string(int(g_Player->GetMaxWeight())), { 542, 208.0f + 12 * yoffset + 9 }, g_SmallFont.get()->baseSize, 1, WHITE);



	//  Draw backpack
	DrawTextureEx(*g_shapeTable[801][0].GetTexture(), Vector2{ 610, 314 }, 0, 1, Color{ 255, 255, 255, 255 });


}

void MainState::UpdateStats()
{
	int counter = 0;
	for (int i = 0; i < g_Player->GetPartyMemberIds().size(); ++i)
	{
		Texture* thisTexture = g_ResourceManager->GetTexture("U7FACES" + to_string(i) + to_string(0));
		if (WasLeftButtonClickedInRect((538.0f - thisTexture->width) * g_DrawScale, (200.0f + 40.0f * counter) * g_DrawScale, thisTexture->width * g_DrawScale, thisTexture->height * g_DrawScale))
		{
			g_Player->SetSelectedPartyMember(g_Player->GetPartyMemberIds()[i]);
		}
		++counter;
	}

	if (WasLeftButtonClickedInRect({ 610 * g_DrawScale, 314 * g_DrawScale, 16 * g_DrawScale, 10 * g_DrawScale }))
	{
		OpenGump(g_NPCData[g_Player->GetSelectedPartyMember()]->m_objectID);
	}
}
