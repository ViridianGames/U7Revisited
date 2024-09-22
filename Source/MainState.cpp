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

	m_renderTarget = LoadRenderTexture(g_Engine->m_RenderWidth, g_Engine->m_RenderHeight);
	SetTextureFilter(m_renderTarget.texture, RL_TEXTURE_FILTER_ANISOTROPIC_4X);

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
}

void MainState::OnExit()
{

}

void MainState::Shutdown()
{
	UnloadRenderTexture(m_renderTarget);
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
				float distance = Vector3Distance((*node).second->m_Pos, g_camera.target);
				if (distance < drawRange && (*node).second->m_Pos.y <= m_heightCutoff)
				{
					double distanceFromCamera = Vector3Distance((*node).second->m_Pos, g_camera.position);
					(*node).second->m_distanceFromCamera = distanceFromCamera * 1.5f;
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
		m_heightCutoff += 1.0f;
		if (m_heightCutoff > 15.0f)
		{
			m_heightCutoff = 15.0f;
		}
		else
		{
			AddConsoleString("Height Cutoff: " + to_string(m_heightCutoff));
		}
	}

	if (IsKeyPressed(KEY_PAGE_DOWN))
	{
		m_heightCutoff -= 1.0f;
		if (m_heightCutoff < 0.0f)
		{
			m_heightCutoff = 0.0f;
		}
		else
		{
			AddConsoleString("Height Cutoff: " + to_string(m_heightCutoff));
		}
	}

	if (IsKeyPressed(KEY_SPACE))
	{
		m_pixelated = !m_pixelated;
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

			bool picked = (*node)->m_shapeData->Pick((*node)->m_Pos);

			if (picked)
			{
				g_selectedShape = (*node)->m_shapeData->GetShape();
				g_selectedFrame = (*node)->m_shapeData->GetFrame();
				m_selectedObject = (*node)->m_ID;

				AddConsoleString("Selected Object: " + to_string(g_selectedShape) + " Frame: " + to_string(g_selectedFrame));

				break;
			}
		}
	}

	//UpdateCamera(&g_camera, CAMERA_THIRD_PERSON);
}

void MainState::Draw()
{
	if (m_pixelated)
	{
		BeginTextureMode(m_renderTarget);
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

	if (m_pixelated)
	{
		float ratio = float(g_Engine->m_ScreenWidth) / float(g_Engine->m_RenderWidth);
		//EndDrawing();
		EndTextureMode();
		//BeginDrawing();
		DrawTexturePro(m_renderTarget.texture, { 0, 0, g_Engine->m_RenderWidth, -g_Engine->m_RenderHeight }, { -ratio, -ratio, g_Engine->m_ScreenWidth + (ratio * 2), g_Engine->m_ScreenHeight + (ratio * 2)}, {0, 0}, 0, WHITE);
	}

	//  Draw the minimap and marker
	DrawTexturePro(*m_Minimap, Rectangle{ 0, 0, float(m_Minimap->width), float(m_Minimap->height) }, Rectangle{ float(GetRenderWidth() - g_minimapSize), 0, float(g_minimapSize), float(g_minimapSize) }, Vector2{ 0, 0 }, 0, WHITE);

	float _ScaleX = g_minimapSize / float(g_Terrain->m_width);
	float _ScaleZ = g_minimapSize / float(g_Terrain->m_height);

	float pointer = float(g_minimapSize) / float(m_MinimapArrow->width);

	DrawTexturePro(*m_MinimapArrow, Rectangle{ 0, 0, float(m_MinimapArrow->width), float(m_MinimapArrow->height) },
		Rectangle{ float(GetRenderWidth() - g_minimapSize) + ((g_camera.target.x) * _ScaleX) - (pointer / 2), ((g_camera.target.z) * _ScaleZ) - (pointer / 2), pointer, pointer}, Vector2{0, 0}, 0, WHITE);

	DrawConsole();

	//  Draw XY coordinates below the minimap
	string minimapXY = "X: " + to_string(int(g_camera.target.x)) + " Y: " + to_string(int(g_camera.target.z)) + " ";
	float textWidth = MeasureText(minimapXY.c_str(), g_Font->baseSize);
	DrawTextEx(*g_Font, minimapXY.c_str(), Vector2{ GetScreenWidth() - textWidth, GetScreenHeight() * .30f }, g_fontSize, 1, WHITE);

	//  Draw version number in lower-right
	DrawTextEx(*g_Font, g_version.c_str(), Vector2{GetRenderWidth() * .92f, GetRenderHeight() * .94f}, g_fontSize, 1, WHITE);

	DrawTexture(*g_Cursor, GetMouseX(), GetMouseY(), WHITE);

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

