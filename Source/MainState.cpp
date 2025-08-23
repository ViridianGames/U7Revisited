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

void MainState::Init(const string &configfile)
{
	m_Minimap = g_ResourceManager->GetTexture("Images/minimap.png");

	m_MinimapArrow = g_ResourceManager->GetTexture("Images/minimaparrow.png", false);
	GenTextureMipmaps(m_MinimapArrow);

	m_Gui = new Gui();

	m_Gui->SetLayout(0, 0, 138, 384, g_DrawScale, Gui::GUIP_UPPERRIGHT);

	m_Gui->AddPanel(1000, 0, 0, 138, 384, Color{143, 128, 97, 255});

	m_Gui->AddPanel(1002, 18, 136, 100, 8, Color{0, 0, 0, 255});

	m_Gui->AddPanel(1003, 18, 136, 100, 8, Color{128, 255, 128, 255});

	m_Gui->AddPanel(1004, 18, 136, 100, 8, Color{255, 255, 255, 255}, false);

	m_ManaBar = m_Gui->GetElement(1003).get();

	m_Gui->m_InputScale = float(g_Engine->m_RenderHeight) / float(g_Engine->m_ScreenHeight);

	m_OptionsGui = new Gui();

	m_OptionsGui->m_Active = false;

	m_OptionsGui->SetLayout(0, 0, 250, 320, g_DrawScale, Gui::GUIP_CENTER);
	m_OptionsGui->AddPanel(1000, 0, 0, 250, 320, Color{0, 0, 0, 192});
	m_OptionsGui->AddPanel(9999, 0, 0, 250, 320, Color{255, 255, 255, 255}, false);
	m_OptionsGui->AddTextArea(1001, g_Font.get(), "", 125, 100, 0, 0, Color{255, 255, 255, 255}, GuiTextArea::CENTERED);
	m_OptionsGui->AddTextButton(1002, 70, 98, "<-", g_Font.get(), Color{255, 255, 255, 255}, Color{0, 0, 0, 192}, Color{255, 255, 255, 255});
	m_OptionsGui->AddTextButton(1003, 170, 98, "->", g_Font.get(), Color{255, 255, 255, 255}, Color{0, 0, 0, 192}, Color{255, 255, 255, 255});

	m_LastUpdate = 0;

	int stopper = 0;

	m_NumberOfVisibleUnits = 0;

	g_CameraMoved = true;

	m_DrawMarker = false;
	m_MarkerRadius = 1.0f;

	m_GuiMode = 0;

	m_showObjects = true;

	m_GumpManager = make_unique<GumpManager>();

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

void MainState::Update()
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

	unsigned char darklevel = 24; // Blue will go down to this level.  Red/Green will go down to half this level.
	unsigned char red_green_level = (darklevel / 2);

	if(g_hour == 20)
	{
		unsigned char darkness = 255 - ((float(g_minute) / 60.0f) * (255 - darklevel));
		unsigned char red_green = 255 - ((float(g_minute) / 60.0f) * (255 - red_green_level));
		g_dayNightColor = {red_green, red_green, darkness, 255};
		g_isDay = false;
	}
	//  Sunrise
	else if (g_hour == 6)
	{
		unsigned char darkness = darklevel + ((float(g_minute) / 60.0f) * (255 - darklevel));
		unsigned char red_green = (darklevel / 2) + ((float(g_minute) / 60.0f) * (255 - red_green_level));
		g_dayNightColor = {red_green, red_green, darkness, 255};
		if (darkness < .1f)
		{
			g_isDay = true;
		}
		else
		{
			g_isDay = false;
		}
	}
	//  Night
	else if (g_hour > 20 || g_hour < 6)
	{
		g_dayNightColor = {red_green_level, red_green_level, darklevel, 255};
		g_isDay = false;
	}
	else
	{
		g_dayNightColor = {255, 255, 255, 255};
		g_isDay = true;
	}

	if(m_GumpManager->m_GumpList.size() > 0)
	{
		m_GumpManager->Update();
	}

	if (GetTime() - m_LastUpdate > GetFrameTime())
	{
		g_CurrentUpdate++;

		m_NumberOfVisibleUnits = 0;

		if (m_showObjects)
		{
			g_sortedVisibleObjects.clear();
			float drawRange = TILEWIDTH / 2;
			for (unordered_map<int, shared_ptr<U7Object>>::iterator node = g_ObjectList.begin(); node != g_ObjectList.end(); ++node)
			{
				if (!m_paused)
				{
					(*node).second->Update();
				}
				if (g_objectDataTable[(*node).second->m_shapeData->m_shape].m_height == 0)
				{
					int stopper = 0;
				}

				Vector3 boundingBoxCenterPoint = {g_objectDataTable[(*node).second->m_shapeData->m_shape].m_width / 2,
												  g_objectDataTable[(*node).second->m_shapeData->m_shape].m_height / 2,
												  g_objectDataTable[(*node).second->m_shapeData->m_shape].m_depth / 2};
				Vector3 centerPoint = Vector3Add((*node).second->m_Pos, boundingBoxCenterPoint);

				if (abs(centerPoint.x - g_camera.target.x) > drawRange || abs(centerPoint.z - g_camera.target.z) > drawRange)
				{
					continue;
				}

				float distance = Vector3Distance(centerPoint, g_camera.target);
				distance -= (*node).second->m_Pos.y;
				if (distance < drawRange && (*node).second->m_Pos.y <= m_heightCutoff)
				{
					double distanceFromCamera = Vector3Distance((*node).second->m_Pos, g_camera.position) - (*node).second->m_Pos.y;
					(*node).second->m_distanceFromCamera = distanceFromCamera;
					g_sortedVisibleObjects.push_back((*node).second);
					m_numberofDrawnUnits++;
				}
			}

			std::sort(g_sortedVisibleObjects.begin(), g_sortedVisibleObjects.end(), [](shared_ptr<U7Object> a, shared_ptr<U7Object> b)
					  { return a->m_distanceFromCamera > b->m_distanceFromCamera; });

			for (auto object : g_sortedVisibleObjects)
			{
				object->CheckLighting();
			}
		}

		m_LastUpdate = GetTime();
	}

	m_cameraUpdateTime = DoCameraMovement();

	m_terrainUpdateTime = GetTime();
	g_Terrain->CalculateLighting();

	m_terrainUpdateTime = GetTime() - m_terrainUpdateTime;

	// Pick cell under mouse pointer
	Ray ray = GetMouseRay(GetMousePosition(), g_camera);
	float pickx = 0;
	float picky = 0;

	// Plane at y=0 (terrain height)
	Vector3 planeNormal = {0.0f, 1.0f, 0.0f};
	Vector3 planePoint = {0.0f, 0.0f, 0.0f};
	float denominator = Vector3DotProduct(ray.direction, planeNormal);

	if (fabs(denominator) > 0.0001f)
	{
		// Avoid division by zero
		Vector3 pointToPlane = Vector3Subtract(planePoint, ray.position);
		float t = Vector3DotProduct(pointToPlane, planeNormal) / denominator;
		if (t >= 0.0f) { // Ray hits plane
			Vector3 hitPoint = Vector3Add(ray.position, Vector3Scale(ray.direction, t));
			// Map to grid (x, z in world space = x, y in grid)
			int x = static_cast<int>(floor(hitPoint.x));
			int y = static_cast<int>(floor(hitPoint.z));
			if (x >= 0 && x < 3072 && y >= 0 && y < 3072)
			{
				pickx = x;
				picky = y;
			}
		}
	}

	int cellx = (TILEWIDTH / 2) + pickx - int(g_camera.target.x);
	int celly = (TILEHEIGHT / 2) + picky - int(g_camera.target.z);
	g_Terrain->m_cellLighting[cellx][celly] = {255, 0, 255, 255};

	g_Terrain->Update();

	//  Handle special keyboard keys
	if (IsKeyPressed(KEY_ESCAPE))
	{
		g_Engine->m_Done = true;
	}

	if (IsKeyPressed(KEY_F1))
	{
		g_StateMachine->MakeStateTransition(STATE_SHAPEEDITORSTATE);
	}

	if(IsKeyPressed(KEY_F8))
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

	//if (IsKeyPressed(KEY_SPACE))
	//{
	//	g_pixelated = !g_pixelated;
	//}

	if (IsKeyPressed(KEY_KP_SUBTRACT))
	{
		g_secsPerMinute -= 0.1f;
		if(g_secsPerMinute < 0.1f)
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
		if(g_secsPerMinute > 5.0f)
		{
			g_secsPerMinute = 5.0f;
		}
		else
		{
			AddConsoleString("Time Speed: " + to_string(g_secsPerMinute) + " seconds per minute");
		}
	}

	if (IsMouseButtonPressed(MOUSE_BUTTON_MIDDLE))
	{
		// AddConsoleString("Right Double-clicked at " + to_string(GetMouseX()) + ", " + to_string(GetMouseY()));

		std::vector<shared_ptr<U7Object>>::reverse_iterator node;

		for (node = g_sortedVisibleObjects.rbegin(); node != g_sortedVisibleObjects.rend(); ++node)
		{
			if (*node == nullptr || !(*node)->m_Visible)
			{
				continue;
			}

			float picked = (*node)->Pick();

			if (picked != -1)
			{
				if((*node)->m_hasConversationTree)
				{
					int NPCId = (*node)->m_NPCID;
					string scriptName = "func_04";
					stringstream ss;
					ss << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << NPCId;
					scriptName += ss.str();
			  
					//  Find the script path from the script name
					int newScriptIndex = 0;
					for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
					{
						if (g_ScriptingSystem->m_scriptFiles[i].first == scriptName)
						{
							newScriptIndex = i;
							break;
						}
					}
	
					std::string filePath = g_ScriptingSystem->m_scriptFiles[newScriptIndex].second;
	
					// Open the file with the default system application
					#ifdef _WIN32
						system(("start \"\" \"" + std::string(filePath) + "\"").c_str());
					#elif __APPLE__
						system(("open \"" + std::string(filePath) + "\"").c_str());
					#else // Linux and others
						system(("xdg-open \"" + std::string(filePath) + "\"").c_str());
					#endif


					break;
				}
			}
		}
	}

	UpdateStats();

	if (WasLMBDoubleClicked())
	{
		// AddConsoleString("Right Double-clicked at " + to_string(GetMouseX()) + ", " + to_string(GetMouseY()));

		std::vector<shared_ptr<U7Object>>::reverse_iterator node;

		for (node = g_sortedVisibleObjects.rbegin(); node != g_sortedVisibleObjects.rend(); ++node)
		{
			if (*node == nullptr || !(*node)->m_Visible)
			{
				continue;
			}

			float picked = (*node)->Pick();

			if (picked != -1)
			{
				g_selectedShape = (*node)->m_shapeData->GetShape();
				g_selectedFrame = (*node)->m_shapeData->GetFrame();
				m_selectedObject = (*node)->m_ID;

				(*node)->Interact(1);
				break;
			}
		}
	}

	if (WasRMBDoubleClicked())
	{
		// AddConsoleString("Left Double-clicked at " + to_string(GetMouseX()) + ", " + to_string(GetMouseY()));

		std::vector<shared_ptr<U7Object>>::reverse_iterator node;

		for (node = g_sortedVisibleObjects.rbegin(); node != g_sortedVisibleObjects.rend(); ++node)
		{
			if (*node == nullptr || !(*node)->m_Visible)
			{
				continue;
			}

			float picked = (*node)->Pick();

			if (picked != -1)
			{
				g_selectedShape = (*node)->m_shapeData->GetShape();
				g_selectedFrame = (*node)->m_shapeData->GetFrame();
				m_selectedObject = (*node)->m_ID;
				if ((*node)->m_isContainer)
				{
					OpenGump((*node)->m_ID);
				}
				break;
			}
		}
	}

	//  Get terrain hit for highlight mesh
	else if (IsMouseButtonReleased(MOUSE_BUTTON_LEFT))
	{
		std::vector<shared_ptr<U7Object>>::reverse_iterator node;

		float closest = 1000000.0f;
		int closestObject = 0;

		for (node = g_sortedVisibleObjects.rbegin(); node != g_sortedVisibleObjects.rend(); ++node)
		{
			if (*node == nullptr || !(*node)->m_Visible)
			{
				continue;
			}

			float picked = (*node)->Pick();

			if (picked != -1)
			{
				if (picked < closest)
				{
					closest = picked;
					closestObject = (*node)->m_ID;
				}
			}
		}
		if (closestObject != 0)
		{
			g_selectedShape = g_ObjectList[closestObject]->m_shapeData->GetShape();
			g_selectedFrame = g_ObjectList[closestObject]->m_shapeData->GetFrame();
			m_selectedObject = closestObject;
		}
	}
}

void MainState::OpenGump(int id)
{
	auto gump = std::make_shared<Gump>();

	gump->SetContainerId(id);
	gump->OnEnter();

	m_GumpManager->AddGump(gump);
}

void MainState::Draw()
{
	if (g_pixelated)
	{
		BeginTextureMode(g_renderTarget);
	}

	ClearBackground(Color{0, 0, 0, 255});

	BeginDrawing();

	BeginMode3D(g_camera);

	//  Draw the terrain
	g_Terrain->Draw();

	//  Draw the objects
	m_numberofDrawnUnits = 0;

	if (m_showObjects)
	{
		for (auto &unit : g_sortedVisibleObjects)
		{
			unit->Draw();
			++m_numberofDrawnUnits;
		}
	}

	EndMode3D();

	float ratio = float(g_Engine->m_ScreenWidth) / float(g_Engine->m_RenderWidth);
	if (g_pixelated)
	{

		EndTextureMode();
		DrawTexturePro(g_renderTarget.texture,
					   {0, 0, float(g_renderTarget.texture.width), float(g_renderTarget.texture.height)},
					   {0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight)},
					   {0, 0}, 0, WHITE);
	}

	//  Draw the GUI
	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({0, 0, 0, 0});

	//  Draw the minimap and marker

	DrawConsole();

	//  Draw XY coordinates below the minimap
	string minimapXY = "X: " + to_string(int(g_camera.target.x)) + " Y: " + to_string(int(g_camera.target.z)) + " ";
	float textWidth = MeasureText(minimapXY.c_str(), g_Font->baseSize);
	DrawTextEx(*g_SmallFont, minimapXY.c_str(), Vector2{640.0f - g_minimapSize, g_minimapSize * 1.05f}, g_SmallFont->baseSize, 1, WHITE);

	string timeString = "Time: " + to_string(g_hour) + ":" + (g_minute < 10 ? "0" : "") + to_string(g_minute) + " (" + to_string(g_scheduleTime) + ")";
	DrawTextEx(*g_SmallFont, timeString.c_str(), Vector2{ 640.0f - g_minimapSize, g_minimapSize * 1.05f + g_SmallFont->baseSize }, g_SmallFont->baseSize, 1, WHITE);

	// Draw character panel below xy/time
	DrawStats();

	//  Draw version number in lower-right
	DrawOutlinedText(g_SmallFont, g_version.c_str(), Vector2{600, 340}, g_SmallFont->baseSize, 1, WHITE);

	m_GumpManager->Draw();

	EndTextureMode();

	DrawTexturePro(g_guiRenderTarget.texture,
				   {0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height)},
				   {0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight)},
				   {0, 0}, 0, WHITE);

	DrawTextureEx(*m_Minimap, {g_Engine->m_ScreenWidth - float(g_minimapSize * g_DrawScale), 0}, 0, float(g_minimapSize * g_DrawScale) / float(m_Minimap->width), WHITE);

	float _ScaleX = (g_minimapSize * g_DrawScale) / float(g_Terrain->m_width) * g_camera.target.x;
	float _ScaleZ = (g_minimapSize * g_DrawScale) / float(g_Terrain->m_height) * g_camera.target.z;

	float half = float(g_DrawScale) * float(m_MinimapArrow->width) / 2;

	DrawTextureEx(*m_MinimapArrow, {g_Engine->m_ScreenWidth - float(g_minimapSize * g_DrawScale) + _ScaleX - half, _ScaleZ - half}, 0, g_DrawScale, WHITE);

	DrawTextureEx(*g_Cursor, {float(GetMouseX()), float(GetMouseY())}, 0, g_DrawScale, WHITE);

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
	DrawOutlinedText(g_SmallFont, to_string(str), { 622, 208.0f +  yoffset }, g_SmallFont.get()->baseSize, 1, WHITE);
	DrawOutlinedText(g_SmallFont, to_string(dex), { 622, 208.0f +  2 * yoffset }, g_SmallFont.get()->baseSize, 1, WHITE);
	DrawOutlinedText(g_SmallFont, to_string(iq), { 622, 208.0f +  3 * yoffset }, g_SmallFont.get()->baseSize, 1, WHITE);
	DrawOutlinedText(g_SmallFont, to_string(combat), { 622, 208.0f +  4 * yoffset + 2 }, g_SmallFont.get()->baseSize, 1, WHITE);
	DrawOutlinedText(g_SmallFont, to_string(magic), { 622, 208.0f +  5 * yoffset + 2 }, g_SmallFont.get()->baseSize, 1, WHITE);
	DrawOutlinedText(g_SmallFont, to_string(trainingpoints), { 622, 208.0f +  10 * yoffset + 6 }, g_SmallFont.get()->baseSize, 1, WHITE);


	//  Draw party members
	int counter = 0;
	for (int i = 0; i < g_Player->GetPartyMemberIds().size(); ++i)
	{
		Texture * thisTexture = nullptr;
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
		DrawTexturePro(*thisTexture, {float(thisTexture->width - 40) / 2.0f, float(thisTexture->height - 40) / 2.0f, 40, 40  },{538.0f - 40, 200.0f + 40.0f * counter, 40, 40}, {0, 0}, 0, WHITE);
		if (g_Player->GetPartyMemberIds()[i] != g_Player->GetSelectedPartyMember())
		{
			DrawRectangle(538.0f - 40, 200.0f + 40.0f * counter, 40, 40, {0, 0, 0, 128});
		}
		++counter;
	}

	DrawOutlinedText(g_SmallFont, "Gold: " + to_string(g_Player->GetGold()), { 542, 208.0f +  11 * yoffset + 8 }, g_SmallFont.get()->baseSize, 1, WHITE);
	DrawOutlinedText(g_SmallFont, "Weight: " + to_string(int(g_Player->GetWeight())) + "/" + to_string(int(g_Player->GetMaxWeight())), { 542, 208.0f +  12 * yoffset + 9 }, g_SmallFont.get()->baseSize, 1, WHITE);



	//  Draw backpack
	DrawTextureEx(*g_shapeTable[801][0].GetTexture(), Vector2{610, 314}, 0, 1, Color{255, 255, 255, 255});


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

	if (WasLeftButtonClickedInRect({610 * g_DrawScale, 314 * g_DrawScale, 16 * g_DrawScale, 10 * g_DrawScale}))
	{
		OpenGump(g_NPCData[g_Player->GetSelectedPartyMember()]->m_objectID);
	}
}
