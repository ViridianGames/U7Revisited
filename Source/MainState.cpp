#include "Globals.h"
#include "U7Globals.h"
#include "MainState.h"
#include "Logging.h"

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

	m_Gui = new Gui();

	m_Gui->SetLayout(0, 0, 138, 384, Gui::GUIP_UPPERRIGHT);

	m_Gui->AddPanel(1000, 0, 0, 138, 384, Color(.56, .50, .375, 1.0));

	m_Gui->AddPanel(1002, 18, 136, 100, 8, Color(0, 0, 0, 1));

	m_Gui->AddPanel(1003, 18, 136, 100, 8, Color(.5, 1, .5, 1));

	m_Gui->AddPanel(1004, 18, 136, 100, 8, Color(1, 1, 1, 1), false);

	m_ManaBar = m_Gui->GetElement(1003).get();

	m_Gui->m_Scale = float(g_Display->GetHeight()) / float(m_Gui->m_Height);

	m_SpellsPanel = new Gui();

	m_SpellsPanel->SetLayout(0, 0, 138, 384, Gui::GUIP_UPPERRIGHT);

	m_SpellsPanel->m_Scale = float(g_Display->GetHeight()) / float(m_Gui->m_Height);

	m_OptionsGui = new Gui();

	m_OptionsGui->m_Active = false;

	m_OptionsGui->SetLayout(0, 0, 250, 320, Gui::GUIP_CENTER);
	m_OptionsGui->AddPanel(1000, 0, 0, 250, 320, Color(0, 0, 0, .75));
	m_OptionsGui->AddPanel(9999, 0, 0, 250, 320, Color(1, 1, 1, 1), false);
	m_OptionsGui->AddTextArea(1001, g_SmallFont.get(), "", 125, 100, 0, 0, Color(1, 1, 1, 1), GuiTextArea::CENTERED);
	m_OptionsGui->AddTextButton(1002, 70, 98, "<-", g_SmallFont.get(), Color(1, 1, 1, 1), Color(0, 0, 0, .75), Color(1, 1, 1, 1));
	m_OptionsGui->AddTextButton(1003, 170, 98, "->", g_SmallFont.get(), Color(1, 1, 1, 1), Color(0, 0, 0, .75), Color(1, 1, 1, 1));

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

	if (g_Engine->Time() - m_LastUpdate > g_Engine->m_MSBetweenUpdates)
	{
		g_CurrentUpdate++;

		m_NumberOfVisibleUnits = 0;

		for (unordered_map<int, shared_ptr<U7Object>>::iterator node = g_ObjectList.begin(); node != g_ObjectList.end(); ++node)
		{
			(*node).second->Update();
		}

		m_LastUpdate = g_Engine->Time();
	}

	m_cameraUpdateTime = DoCameraMovement();

	m_terrainUpdateTime = g_Engine->Time();
	g_Terrain->Update();
	m_terrainUpdateTime = g_Engine->Time() - m_terrainUpdateTime;

	//  Handle special keyboard keys
	if (g_Input->WasKeyPressed(KEY_ESCAPE))
	{
		g_Engine->m_Done = true;
	}

	if (g_Input->WasKeyPressed(KEY_SPACE))
	{
		m_showObjects = !m_showObjects;
	}
}

void MainState::Draw()
{
	g_Display->ClearScreen();

	g_Terrain->Draw();

	m_numberofDrawnUnits = 0;

	if (m_showObjects)
	{
		std::vector<shared_ptr<U7Object>> sortedObjects;
		float drawRange = g_Display->GetCameraDistance() / 2.5;
		for (unordered_map<int, shared_ptr<U7Object>>::iterator node = g_ObjectList.begin(); node != g_ObjectList.end(); ++node)
		{
			float distance = glm::distance((*node).second->m_Pos, g_Display->GetCameraLookAtPoint());
			if (distance < drawRange)
			{
				(*node).second->m_distanceFromCamera = glm::distance((*node).second->m_Pos, g_Display->GetCameraPosition());
				sortedObjects.push_back((*node).second);
				m_numberofDrawnUnits++;
			}
		}

		std::sort(sortedObjects.begin(), sortedObjects.end(), [](shared_ptr<U7Object> a, shared_ptr<U7Object> b) { return a->m_distanceFromCamera > b->m_distanceFromCamera; });
		for (auto& unit : sortedObjects)
		{
			unit->Draw();
		}
	}


	g_Display->DrawImage(m_Minimap, g_Display->GetWidth() - g_minimapSize, 0, g_minimapSize, g_minimapSize, Color(1, 1, 1, 1), false, 0, 0);



	//int ypos = -g_SmallFont->GetHeight();
	//int offset = g_SmallFont->GetHeight();
	//int xoffset = g_SmallFont->GetStringMetrics(" ") / 5;


	//welcome = "";
	//g_SmallFont->DrawString(welcome, 0, ypos += 24);
	//int nextLine = g_SmallFont->GetHeight() * 1.5;

	//string visibleCells = "Visible Cells: " + to_string(g_Terrain->m_VisibleCells.size());
	//g_SmallFont->DrawString(visibleCells, 0, ypos += nextLine);

	//string numDrawnUnits = "Drawn Units: " + to_string(m_numberofDrawnUnits);
	//g_SmallFont->DrawString(numDrawnUnits, 0, ypos += nextLine);

	string welcome = "X: " + to_string(static_cast<int>(g_Display->GetCameraLookAtPoint().x)) + " Y: " + to_string(static_cast<int>(g_Display->GetCameraLookAtPoint().z)) + " ";
	float textwidth = g_SmallFont->GetStringMetrics(welcome);
	g_SmallFont->DrawString(welcome, g_Display->GetWidth() - textwidth, g_Display->GetHeight() * .30, Color(1, 1, 1, 1));
	//g_SmallFont->DrawString(welcome, 0, ypos);

	//ypos += nextLine;

	//string visibleTest = "Visible Cell Test Time: " + to_string(g_Terrain->m_DurationOfVisibleTest);
	//g_SmallFont->DrawString(visibleTest, 0, ypos += nextLine);

	//string cameraTest = "Camera Update Time: " + to_string(m_cameraUpdateTime);
	//g_SmallFont->DrawString(cameraTest, 0, ypos += nextLine);

	//string terrainTest = "Terrain Update Time: " + to_string(m_terrainUpdateTime);
	//g_SmallFont->DrawString(terrainTest, 0, ypos += nextLine);

	//string xcoordstring = "CamLookAt  X: " + to_string(g_Display->GetCameraLookAtPoint().x) + " Y: " + to_string(g_Display->GetCameraLookAtPoint().y) + " Z: " + to_string(g_Display->GetCameraLookAtPoint().z);
	//g_SmallFont->DrawString(xcoordstring, 0, ypos += 32);

	//xcoordstring = "CamPos      X: " + to_string(g_Display->GetCameraPosition().x) + " Y: " + to_string(g_Display->GetCameraPosition().y) + " Z: " + to_string(g_Display->GetCameraPosition().z);
	//g_SmallFont->DrawString(xcoordstring, 0, ypos += 32);

	DrawConsole();


	//g_Display->DrawPerfCounter(g_SmallFont);

	int shape = 192;
	int frame = 0;
	//g_Display->DrawImage(g_shapeTable[shape][frame], 0, ypos, g_shapeTable[shape][frame]->GetWidth() * g_Display->GetWidth() / 320, g_shapeTable[shape][frame]->GetHeight() * g_Display->GetWidth() / 320);


	g_SmallFont->DrawString(g_VERSION, g_Display->GetWidth() - 100, g_Display->GetHeight() - 50, Color(1, 1, 0, 1));

	g_Display->DrawImage(g_Cursor, g_Input->m_MouseX, g_Input->m_MouseY);

}

void MainState::SetupGame()
{
	//g_UnitList.clear();

	m_TerrainTexture = g_ResourceManager->GetTexture("Images/Terrain/terrain_texture.png", false);

	//  Set up map
	int width = 3072;
	int height = 3072;
	g_Display->SetCameraPosition(glm::vec3(1071, 0, 2209));
	//g_Display->SetCameraPosition(glm::vec3(1068, 0, 2211));
	g_Terrain->Init(width, height);
	g_Terrain->InitializeMap(7777);   //  Check for a packet that tells us how to set up the game.

	//  Set the terrain types for each cell.
	g_Terrain->InitializeTerrainMesh();

	//  Since the terrain cannot be initialized until the game data has been sent
	//  but the main gui has already been created, we have to do a hacky bit of
	//  fixup to assign the minimap texture to the main gui.
	m_Gui->AddSprite(1001, 5, 5, make_shared<Sprite>(g_Terrain->m_Minimap, 0, 0, g_Terrain->m_Minimap->GetWidth(), g_Terrain->m_Minimap->GetHeight()));

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

