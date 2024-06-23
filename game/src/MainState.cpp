#include "Geist/Globals.h"
#include "Geist/Logging.h"
#include "Geist/Gui.h"
#include "Geist/ParticleSystem.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/Engine.h"
#include "U7Globals.h"
#include "MainState.h"
#include "rlgl.h"

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

	m_Gui = new Gui();

	m_Gui->SetLayout(0, 0, 138, 384, g_DrawScale, Gui::GUIP_UPPERRIGHT);

	m_Gui->AddPanel(1000, 0, 0, 138, 384, Color{ 143, 128, 97, 255 });

	m_Gui->AddPanel(1002, 18, 136, 100, 8, Color{ 0, 0, 0, 255 });

	m_Gui->AddPanel(1003, 18, 136, 100, 8, Color{128, 255, 128, 255});

	m_Gui->AddPanel(1004, 18, 136, 100, 8, Color{255, 255, 255, 255}, false);

	m_ManaBar = m_Gui->GetElement(1003).get();

	m_Gui->m_Scale = float(GetRenderHeight()) / float(m_Gui->m_Height);

	m_SpellsPanel = new Gui();

	m_SpellsPanel->SetLayout(0, 0, 138, 384, g_DrawScale, Gui::GUIP_UPPERRIGHT);

	m_SpellsPanel->m_Scale = float(GetRenderHeight()) / float(m_Gui->m_Height);

	m_OptionsGui = new Gui();

	m_OptionsGui->m_Active = false;

	m_OptionsGui->SetLayout(0, 0, 250, 320, g_DrawScale, Gui::GUIP_CENTER);
	m_OptionsGui->AddPanel(1000, 0, 0, 250, 320, Color{ 0, 0, 0, 192 });
	m_OptionsGui->AddPanel(9999, 0, 0, 250, 320, Color{255, 255, 255, 255}, false);
	m_OptionsGui->AddTextArea(1001, g_SmallFont.get(), "", 125, 100, 0, 0, Color{255, 255, 255, 255}, GuiTextArea::CENTERED);
	m_OptionsGui->AddTextButton(1002, 70, 98, "<-", g_SmallFont.get(), Color{ 255, 255, 255, 255 }, Color{ 0, 0, 0, 192 }, Color{ 255, 255, 255, 255 });
	m_OptionsGui->AddTextButton(1003, 170, 98, "->", g_SmallFont.get(), Color{ 255, 255, 255, 255 }, Color{ 0, 0, 0, 192 }, Color{ 255, 255, 255, 255 });

	m_LastUpdate = 0;

	int stopper = 0;

	m_NumberOfVisibleUnits = 0;

	g_CameraMoved = true;

	m_DrawMarker = false;
	m_MarkerRadius = 1.0f;

	// Find all SDL resolutions.
//   m_Resolutions = SDL_ListModes(NULL, SDL_FULLSCREEN|SDL_HWSURFACE);
//   m_CurrentRes = 0;

	m_GuiMode = 0;

	//  Networking
	m_ArePlayersSetUp = false;
	m_TurnLength = g_Engine->m_EngineConfig.GetNumber("turn_length");
	g_CurrentUpdate = 1;
	m_NextTurnUpdate = g_CurrentUpdate + m_TurnLength;
	m_ClientAuthorizedUpdate = g_CurrentUpdate + (2 * m_TurnLength);
	m_SentServerEvents = false;

	m_showObjects = true;
	//   AddConsoleString("Welcome to Planitia!", Color(0, 1, 0, 1));
}

void MainState::OnEnter()
{
	ClearConsole();
	AddConsoleString(std::string("Welcome to Ultima VII: Revisited!"));
	AddConsoleString(std::string("Move with WASD, rotate with Q and E."));
	AddConsoleString(std::string("Zoom in and out with mousewheel."));
	AddConsoleString(std::string("Left-click in the minimap to teleport."));
	AddConsoleString(std::string("Press F1 to switch to the Object Viewer."));
	AddConsoleString(std::string("Press ESC to exit."));
}

void MainState::OnExit()
{

}

void MainState::Shutdown()
{

}

void MainState::Update()
{
	if (!m_ArePlayersSetUp)
	{
		SetupGame();
		return;
	}

	bool canupdate = false;

	if (GetTime() - m_LastUpdate > GetFrameTime())
	{
		g_CurrentUpdate++;

		m_NumberOfVisibleUnits = 0;

		if (m_showObjects)
		{
			m_sortedVisibleObjects.clear();
			float drawRange = g_cameraDistance;
			for (unordered_map<int, shared_ptr<U7Object>>::iterator node = g_ObjectList.begin(); node != g_ObjectList.end(); ++node)
			{
				if (!(*node).second->m_Visible)
				{
					continue;
				}

				float distance = Vector3Distance((*node).second->m_Pos, g_camera.target);
				if (distance < drawRange)
				{
					float distanceFromCamera = Vector3Distance((*node).second->m_Pos, g_camera.position);
					(*node).second->m_distanceFromCamera = distanceFromCamera;
					m_sortedVisibleObjects.push_back((*node).second);
					m_numberofDrawnUnits++;
				}
			}

			std::sort(m_sortedVisibleObjects.begin(), m_sortedVisibleObjects.end(), [](shared_ptr<U7Object> a, shared_ptr<U7Object> b) { return a->m_distanceFromCamera > b->m_distanceFromCamera; });
		}

		m_LastUpdate = GetTime();
	}

	m_cameraUpdateTime = DoCameraMovement();

	m_terrainUpdateTime = GetTime();
	g_Terrain->Update();
	m_terrainUpdateTime = GetTime() - m_terrainUpdateTime;

	//  Handle special keyboard keys
	if (IsKeyPressed(KEY_ESCAPE))
	{
		g_Engine->m_Done = true;
	}

	if (IsKeyPressed(KEY_SPACE))
	{
		m_showObjects = !m_showObjects;
	}

	if (IsKeyPressed(KEY_F1))
	{
		g_StateMachine->MakeStateTransition(STATE_OBJECTEDITORSTATE);

	}

	//  Get terrain hit for highlight mesh
	if (IsMouseButtonReleased(MOUSE_BUTTON_LEFT))
	{
		std::vector<shared_ptr<U7Object>>::reverse_iterator node;

		for (node = m_sortedVisibleObjects.rbegin(); node != m_sortedVisibleObjects.rend(); ++node)
		{
			//bool picked = (*node)->m_shapeData->Pick((*node)->GetPos(), GetCameraAngle());

			//if (picked)
			//{
			//	g_selectedShape = (*node)->m_shapeData->GetShape();
			//	g_selectedFrame = (*node)->m_shapeData->GetFrame();
			//	(*node)->m_color.g = 0;
			//	(*node)->m_color.b = 0;
			//	m_selectedObject = (*node)->m_ID;


			//	AddConsoleString("Selected Object: " + to_string(g_selectedShape) + " Frame: " + to_string(g_selectedFrame));

			//	break;
			//}
		}
	}
}

void MainState::Draw()
{
	ClearBackground(Color {0, 0, 0, 255});

	BeginMode3D(g_camera);
	rlEnableDepthTest();
	//  Draw the terrain
	g_Terrain->Draw();

	//  Draw the objects
	m_numberofDrawnUnits = 0;

	if (m_showObjects)
	{
		for (auto& unit : m_sortedVisibleObjects)
		{
			unit->Draw();
			++m_numberofDrawnUnits;
		}
	}

	rlDisableDepthTest();
	EndMode3D();

	//  Draw the minimap and marker
	DrawTextureEx(*m_Minimap, Vector2{ float(GetRenderWidth() - g_minimapSize), 0 }, 0, float(g_minimapSize) / float(GetRenderHeight()), WHITE);

	float _ScaleX = g_minimapSize / float(g_Terrain->m_width);
	float _ScaleZ = g_minimapSize / float(g_Terrain->m_height);

	DrawTextureEx(*m_MinimapArrow, Vector2{ float(GetRenderWidth() - g_minimapSize) + ((g_camera.target.x - 64) * _ScaleX), ((g_camera.target.z - 64) * _ScaleZ) }, 0, 1, WHITE);

	DrawConsole();

	DrawTextEx(*g_SmallFont, g_VERSION.c_str(), Vector2{GetRenderWidth() * .92f, GetRenderHeight() * .94f}, g_smallFontSize, 1, WHITE);
	DrawTexture(*g_Cursor, GetMouseX(), GetMouseY(), WHITE);
}

void MainState::SetupGame()
{
	//g_UnitList.clear();

	//m_TerrainTexture = g_ResourceManager->GetTexture("Images/Terrain/terrain_texture.png", false);

	//  Set up map
	int width = 3072;
	int height = 3072;
	//SetCameraPosition(Vector3{ 980, 0, 2126 });
	//SetCameraPosition(Vector3(1068, 0, 2211));
	g_Terrain->Init();

	//  Since the terrain cannot be initialized until the game data has been sent
	//  but the main gui has already been created, we have to do a hacky bit of
	//  fixup to assign the minimap texture to the main gui.
	//m_Gui->AddSprite(1001, 5, 5, make_shared<Sprite>(g_Terrain->m_Minimap, 0, 0, g_Terrain->m_Minimap->width, g_Terrain->m_Minimap->height));

	//for(int i = 0; i < 3; ++i)
	//{
	//   AddUnitActual(0, UNIT_WALKER, GetNextID(), 16, g_Terrain->GetHeight(16, 16), 16);
	//}
	//
	//for(int i = 0; i < 3; ++i)
	//{
	//   AddUnitActual(1, UNIT_WALKER, GetNextID(), 48, g_Terrain->GetHeight(48, 48), 48);
	//}

	m_ArePlayersSetUp = true;

	//for( int j = 15; j < 18; ++j )
	//{
	//   g_Terrain->SetTerrainType(j, 15, TT_FARMLAND);
	//   g_Terrain->SetTerrainType(j, 16, TT_FARMLAND);
	//   g_Terrain->SetTerrainType(j, 17, TT_FARMLAND);
	//   
	//   g_Terrain->SetTerrainType(j + 32, 47, TT_FARMLAND);
	//   g_Terrain->SetTerrainType(j + 32, 48, TT_FARMLAND);
	//   g_Terrain->SetTerrainType(j + 32, 49, TT_FARMLAND);
	//}
	//
	//
	//for( int j = 16; j < 17; ++j )
	//{
	//   g_Terrain->SetTerrainType(j, 16, TT_COBBLESTONE);
	//   //g_Terrain->SetTerrainType(j, 17, TT_COBBLESTONE);
	//   
	//   g_Terrain->SetTerrainType(j + 32, 48, TT_COBBLESTONE);
	//   //g_Terrain->SetTerrainType(j + 32, 49, TT_COBBLESTONE);
	//}



//   g_Terrain->UpdateMinimapTerrain();


	//  Otherwise, return.

	//  Create the world map and load its data from U7MAP and U7CHUNKS

}

