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
	GenTextureMipmaps(m_MinimapArrow);

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
	m_OptionsGui->AddTextArea(1001, g_Font.get(), "", 125, 100, 0, 0, Color{255, 255, 255, 255}, GuiTextArea::CENTERED);
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
	AddConsoleString(std::string("Press SPACE to toggle pixelation."));
	AddConsoleString(std::string("Press ESC to exit."));
	AddConsoleString(std::string("TOO HEAVY"));
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
	bool canupdate = false;

	if (GetTime() - m_LastUpdate > GetFrameTime())
	{
		g_CurrentUpdate++;

		m_NumberOfVisibleUnits = 0;

		if (m_showObjects)
		{
			m_sortedVisibleObjects.clear();
			float drawRange = g_cameraDistance * 1.5f;
			for (unordered_map<int, shared_ptr<U7Object>>::iterator node = g_ObjectList.begin(); node != g_ObjectList.end(); ++node)
			{
				(*node).second->Update();
				//Vector3 centerPoint = Vector3Add((*node).second->m_Pos, (*node).second.get()->m_shapeData->m_boundingBoxCenterPoint);

				float distance = Vector3Distance((*node).second->m_Pos, g_camera.target);
				distance -= (*node).second->m_Pos.y;
				if (distance < drawRange && (*node).second->m_Pos.y <= m_heightCutoff)
				{
					double distanceFromCamera = Vector3Distance((*node).second->m_Pos, g_camera.position) - (*node).second->m_Pos.y;
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

	if (IsKeyPressed(KEY_F1))
	{
		g_StateMachine->MakeStateTransition(STATE_SHAPEEDITORSTATE);

	}

	if (IsKeyPressed(KEY_PAGE_UP))
	{
		if (m_heightCutoff == 4.0f)
		{
			m_heightCutoff = 9.0f;
			AddConsoleString("Viewing Second Floor");
		}
		else if (m_heightCutoff == 9.0f)
		{
			m_heightCutoff = 15.0f;
			AddConsoleString("Viewing Third Floor");
		}
	}

	if (IsKeyPressed(KEY_PAGE_DOWN))
	{
		if (m_heightCutoff == 15.0f)
		{
			m_heightCutoff = 9.0f;
			AddConsoleString("Viewing Second Floor");
		}
		else if (m_heightCutoff == 9.0f)
		{
			m_heightCutoff = 4.0f;
			AddConsoleString("Viewing First Floor");
		}
	}

	if (IsKeyPressed(KEY_SPACE))
	{
		g_pixelated = !g_pixelated;
	}

	//  Get terrain hit for highlight mesh
	if (IsMouseButtonReleased(MOUSE_BUTTON_LEFT))
	{
		std::vector<shared_ptr<U7Object>>::reverse_iterator node;

		for (node = m_sortedVisibleObjects.rbegin(); node != m_sortedVisibleObjects.rend(); ++node)
		{
			if (*node == nullptr || !(*node)->m_Visible)
			{
				continue;
			}

			bool picked = (*node)->Pick();

			if (picked)
			{
				g_selectedShape = (*node)->m_shapeData->GetShape();
				g_selectedFrame = (*node)->m_shapeData->GetFrame();
				m_selectedObject = (*node)->m_ID;

				if((*node)->m_isContainer)
				{
					AddConsoleString("Object is a container, with " + to_string((*node)->m_inventory.size()) + " objects inside.");

					for (auto& item : (*node)->m_inventory)
					{
						auto object = GetObjectFromID(item);
						AddConsoleString("Item: " + g_objectTable[object->m_shapeData->m_shape].m_name + " ID: " + to_string(item));
					}
				}
				AddConsoleString("Selected Object: " + to_string(g_selectedShape) + " Frame: " + to_string(g_selectedFrame) + " Name: " + g_objectTable[g_selectedShape].m_name);

				break;
			}
		}
	}

	//UpdateCamera(&g_camera, CAMERA_THIRD_PERSON);
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

	EndMode3D();

	float ratio = float(g_Engine->m_ScreenWidth) / float(g_Engine->m_RenderWidth);
	if (g_pixelated)
	{
		
		EndTextureMode();
		DrawTexturePro(g_renderTarget.texture,
			{ 0, 0, float(g_renderTarget.texture.width), float(g_renderTarget.texture.height) },
			{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
			{ 0, 0 }, 0, WHITE);
		//DrawTexturePro(g_renderTarget.texture, { 0, 0, g_Engine->m_RenderWidth, -g_Engine->m_RenderHeight }, { -ratio, -ratio, g_Engine->m_ScreenWidth + (ratio * 2), g_Engine->m_ScreenHeight + (ratio * 2)}, {0, 0}, 0, WHITE);
	}

	//  Draw the GUI
	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({0, 0, 0, 0});
	//m_Gui->Draw();

	//  Draw the minimap and marker

	DrawConsole();

	//  Draw XY coordinates below the minimap
	string minimapXY = "X: " + to_string(int(g_camera.target.x)) + " Y: " + to_string(int(g_camera.target.z)) + " ";
	float textWidth = MeasureText(minimapXY.c_str(), g_Font->baseSize);
	DrawTextEx(*g_SmallFont, minimapXY.c_str(), Vector2{ 640.0f - g_minimapSize, g_minimapSize * 1.05f }, g_SmallFont->baseSize, 1, WHITE);

	//  Draw version number in lower-right
	DrawTextEx(*g_SmallFont, g_version.c_str(), Vector2{600, 340}, g_SmallFont->baseSize, 1, WHITE);

	//DrawTexture(*g_Cursor, GetMouseX(), GetMouseY(), WHITE);

	//  Draw any tooltips
	EndTextureMode();
	DrawTexturePro(g_guiRenderTarget.texture,
		{ 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
		{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
		{ 0, 0 }, 0, WHITE);

	//DrawTexturePro(g_guiRenderTarget.texture, { 0, 0, g_Engine->m_RenderWidth, -g_Engine->m_RenderHeight }, { -ratio, -ratio, g_Engine->m_ScreenWidth + (ratio * 2), g_Engine->m_ScreenHeight + (ratio * 2) }, { 0, 0 }, 0, WHITE);

	DrawTextureEx(*m_Minimap, { g_Engine->m_ScreenWidth - float(g_minimapSize * g_DrawScale), 0 }, 0, float(g_minimapSize * g_DrawScale) / float(m_Minimap->width), WHITE);
	//DrawTexture(*m_Minimap, g_Engine->m_RenderWidth - float(m_Minimap->width), 0, WHITE);

	float _ScaleX = (g_minimapSize * g_DrawScale) / float(g_Terrain->m_width) * g_camera.target.x;
	float _ScaleZ = (g_minimapSize * g_DrawScale) / float(g_Terrain->m_height) * g_camera.target.z;

	float half = float(g_DrawScale) * float(m_MinimapArrow->width) / 2;

	DrawTextureEx(*m_MinimapArrow, { g_Engine->m_ScreenWidth - float(g_minimapSize * g_DrawScale) + _ScaleX - half, _ScaleZ - half }, 0, g_DrawScale, WHITE);



	DrawTextureEx(*g_Cursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale , WHITE);
	

	//DrawFPS(10, 300);

	EndDrawing();
}

void MainState::SetupGame()
{
	//  Set up map
	int width = 3072;
	int height = 3072;
	g_Terrain->Init();
}

//void MainState::CreateTooltip()
//{
//
//}

