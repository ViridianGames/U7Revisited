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

	m_Gui = new Gui();

	m_Gui->SetLayout(0, 0, 138, 384, g_DrawScale, Gui::GUIP_UPPERRIGHT);

	m_Gui->AddPanel(1000, 0, 0, 138, 384, Color{ 143, 128, 97, 255 });

	m_Gui->AddPanel(1002, 18, 136, 100, 8, Color{ 0, 0, 0, 255 });

	m_Gui->AddPanel(1003, 18, 136, 100, 8, Color{ 128, 255, 128, 255 });

	m_Gui->AddPanel(1004, 18, 136, 100, 8, Color{ 255, 255, 255, 255 }, false);

	m_ManaBar = m_Gui->GetElement(1003).get();

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
	ClearConsole();
	AddConsoleString(std::string("Welcome to Ultima VII: Revisited!"));
	AddConsoleString(std::string("Move with WASD, rotate with Q and E."));
	AddConsoleString(std::string("Zoom in and out with mousewheel."));
	AddConsoleString(std::string("Left-click in the minimap to teleport."));
	AddConsoleString(std::string("Press F1 to switch to the Object Viewer."));
	AddConsoleString(std::string("Press KP ENTER to advance time an hour."));
	AddConsoleString(std::string("Press SPACE to pause/unpause time."));
	AddConsoleString(std::string("Press ESC to exit."));

	g_lastTime = 0;
	g_minute = 0;
	g_hour = 7;
	g_scheduleTime = 1;

	m_paused = false;
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
}

void MainState::UpdateInput()
{
	if (IsKeyPressed(KEY_ESCAPE))
	{
		g_Engine->m_Done = true;
	}

	if (IsKeyPressed(KEY_F1))
	{
		g_StateMachine->MakeStateTransition(STATE_SHAPEEDITORSTATE);
	}

	if (IsKeyPressed(KEY_F8))
	{
		g_LuaDebug = !g_LuaDebug;
	}

	if (IsKeyPressed(KEY_KP_ENTER))
	{
		++g_hour;
		if (g_hour >= 24)
			g_hour = 0;
	}

	if (IsKeyPressed(KEY_PAGE_UP))
	{
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
	}

	if (IsKeyPressed(KEY_SPACE))
	{
		m_paused = !m_paused;
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

	if (IsMouseButtonDown(MOUSE_LEFT_BUTTON) && g_objectUnderMousePointer != nullptr && !g_gumpManager->m_mouseOverGump && !g_gumpManager->m_draggingObject)
	{
		g_selectedShape = g_objectUnderMousePointer->m_shapeData->m_shape;
		g_selectedFrame = g_objectUnderMousePointer->m_shapeData->m_frame;

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

	if (IsMouseButtonReleased(MOUSE_LEFT_BUTTON))
	{
		if (!g_gumpManager->m_mouseOverGump && !g_gumpManager->m_draggingObject && g_objectUnderMousePointer != nullptr)
		{
			AddConsoleString(g_objectUnderMousePointer->m_objectData->m_name);
		}
	}

	if (IsMouseButtonPressed(MOUSE_BUTTON_MIDDLE) && g_objectUnderMousePointer != nullptr)
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

	if (WasMouseButtonDoubleClicked(MOUSE_BUTTON_LEFT) && g_objectUnderMousePointer != nullptr)
	{
		g_objectUnderMousePointer->Interact(1);;
	}

	if (WasMouseButtonDoubleClicked(MOUSE_BUTTON_RIGHT) && g_objectUnderMousePointer != nullptr)
	{
		if (g_objectUnderMousePointer->m_isContainer)
		{
			OpenGump(g_objectUnderMousePointer->m_ID);
		}
	}
}

void MainState::Update()
{
	UpdateTime();

	UpdateSortedVisibleObjects();

	g_gumpManager->Update();

	if (GetTime() - m_LastUpdate > GetFrameTime())
	{
		g_CurrentUpdate++;

		m_NumberOfVisibleUnits = 0;
		m_numberofDrawnObjects = 0;
		m_numberofObjectsPassingFirstCheck = 0;

		for (const auto& [id, object] : g_ObjectList)
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

		for (auto& object : g_sortedVisibleObjects)
		{
			object->CheckLighting();
		}

		m_LastUpdate = GetTime();
	}

	m_cameraUpdateTime = DoCameraMovement();

	m_terrainUpdateTime = GetTime();
	g_Terrain->CalculateLighting();

	m_terrainUpdateTime = GetTime() - m_terrainUpdateTime;

	g_Terrain->Update();

	UpdateStats();

	UpdateInput();



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
		U7Object* draggedObject = g_ObjectList[g_gumpManager->m_draggedObjectId].get();
		BoundingBox box;
		box.min = Vector3Subtract(g_terrainUnderMousePointer, {draggedObject->m_shapeData->m_Dims.x - 1, 0, draggedObject->m_shapeData->m_Dims.z - 1});//, {draggedObject->m_shapeData->m_Dims.x / 2, draggedObject->m_shapeData->m_Dims.y / 2, draggedObject->m_shapeData->m_Dims.z / 2});
		box.max = Vector3Add(box.min, draggedObject->m_shapeData->m_Dims);
		DrawBoundingBox(box, WHITE);
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

	DrawOutlinedText(g_SmallFont, "Cell under mouse: " + to_string(int(g_terrainUnderMousePointer.x)) + " " + to_string(int(g_terrainUnderMousePointer.y))
	+ " " + to_string((int(g_terrainUnderMousePointer.z))), Vector2{ 10, 272 }, g_SmallFont->baseSize, 1, WHITE);

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

		 objectDescription += g_objectUnderMousePointer->m_objectData->m_name + " at " +
			to_string(int(g_objectUnderMousePointer->m_Pos.x)) +
			" " +
			to_string(int(g_objectUnderMousePointer->m_Pos.z)) +
			" Quality: " +
			to_string(int(g_objectUnderMousePointer->m_Quality));

		if (g_objectUnderMousePointer->m_isContained)
		{
			objectDescription += " This object is contained.";
		}

		DrawOutlinedText(g_SmallFont, objectDescription, Vector2{ 10, 288 }, g_SmallFont->baseSize, 1, WHITE);
	}
	//DrawOutlinedText(g_SmallFont, "Current chunk: " + to_string(int(g_camera.target.x / 16.0f)) + " x " + to_string(int(g_camera.target.z / 16.0f)), Vector2{ 10, 304 }, g_SmallFont->baseSize, 1, WHITE);
	//DrawOutlinedText(g_SmallFont, "Objects: " + to_string(g_ObjectList.size()) + " Visible: " + to_string(g_sortedVisibleObjects.size()), Vector2{ 10, 320 }, g_SmallFont->baseSize, 1, WHITE);

	g_gumpManager->Draw();

	EndTextureMode();

	DrawTexturePro(g_guiRenderTarget.texture,
		{ 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
		{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
		{ 0, 0 }, 0, WHITE);

	DrawTextureEx(*m_Minimap, { g_Engine->m_ScreenWidth - float(g_minimapSize * g_DrawScale), 0 }, 0, float(g_minimapSize * g_DrawScale) / float(m_Minimap->width), WHITE);

	float _ScaleX = (g_minimapSize * g_DrawScale) / float(g_Terrain->m_width) * g_camera.target.x;
	float _ScaleZ = (g_minimapSize * g_DrawScale) / float(g_Terrain->m_height) * g_camera.target.z;

	float half = float(g_DrawScale) * float(m_MinimapArrow->width) / 2;

	DrawTextureEx(*m_MinimapArrow, { g_Engine->m_ScreenWidth - float(g_minimapSize * g_DrawScale) + _ScaleX - half, _ScaleZ - half }, 0, g_DrawScale, WHITE);

	DrawTextureEx(*g_Cursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale, WHITE);

	DrawFPS(10, 300);

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
