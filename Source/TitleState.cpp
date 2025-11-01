#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/StateMachine.h"
#include "Geist/ResourceManager.h"
#include "U7Globals.h"
#include "TitleState.h"
#include "MainState.h"
#include "rlgl.h"

#include <list>
#include <string>
#include <sstream>
#include <math.h>
#include <fstream>
#include <algorithm>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  TitleState
////////////////////////////////////////////////////////////////////////////////

TitleState::~TitleState()
{
	Shutdown();
}

void TitleState::Init(const string& configfile)
{
	CreateTitleGUI();
	CreateCreditsGUI();
	m_title = g_ResourceManager->GetTexture("Images/title.png");
	m_mouseMoved = false;
}

void TitleState::OnEnter()
{
	ClearConsole();
	m_LastUpdate = 0;
}

void TitleState::OnExit()
{
}

void TitleState::Shutdown()
{
}

void TitleState::Update()
{
	UpdateSortedVisibleObjects();

	//  Slow rotate on the title screen
	g_CameraRotateSpeed = 0.001f;
	g_cameraRotation += g_CameraRotateSpeed;

	Vector3 current = g_camera.target;

	Vector3 finalmovement = Vector3RotateByAxisAngle(g_CameraMovementSpeed, Vector3{0, 1, 0}, g_cameraRotation);

	current = Vector3Add(current, finalmovement);

	if (current.x < 0) current.x = 0;
	if (current.x > 3072) current.x = 3072;
	if (current.z < 0) current.z = 0;
	if (current.z > 3072) current.z = 3072;

	Vector3 camPos = {g_cameraDistance, g_cameraDistance, g_cameraDistance};
	camPos = Vector3RotateByAxisAngle(camPos, Vector3{0, 1, 0}, g_cameraRotation);

	g_camera.target = current;
	g_camera.position = Vector3Add(current, camPos);
	g_camera.fovy = g_cameraDistance;

	UpdateTitle();
	TestUpdate();

	g_Terrain->CalculateLighting();
	g_Terrain->Update();

	if (IsKeyPressed(KEY_F1))
	{
		g_StateMachine->MakeStateTransition(STATE_SHAPEEDITORSTATE);
	}
}


void TitleState::Draw()
{
	//rlSetBlendFactors(RL_SRC_ALPHA, RL_ONE_MINUS_SRC_ALPHA, RL_MIN);
	rlSetBlendMode(BLEND_ALPHA);
	BeginDrawing();

	ClearBackground(Color{0, 0, 0, 255});

	BeginMode3D(g_camera);

	//  Draw the terrain
	g_Terrain->Draw();

	//  Draw the objects
	for (auto object : g_sortedVisibleObjects)
	{
		if (object->m_Pos.y <= 4 && object->m_drawType != ShapeDrawType::OBJECT_DRAW_FLAT)
		{
			object->Draw();
		}
	}

	rlDisableDepthMask();
	for (auto object : g_sortedVisibleObjects)
	{
		if (object->m_Pos.y <= 4 && object->m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
		{
			object->Draw();
		}
	}
	rlEnableDepthMask();


	EndMode3D();

	//  Draw GUI overlay
	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({0, 0, 0, 0});

	//  Draw the minimap and marker

	DrawConsole();

	//  Draw version number in lower-right
	DrawOutlinedText(g_SmallFont, g_version.c_str(), Vector2{600, 340}, g_SmallFont->baseSize, 1, WHITE);

	if (m_mouseMoved)
	{
		m_TitleGui->Draw();
		m_CreditsGui->Draw();
	}

	//  Draw any tooltips
	EndTextureMode();
	DrawTexturePro(g_guiRenderTarget.texture,
	               {0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height)},
	               {
		               0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth),
		               -float(g_Engine->m_ScreenHeight)
	               },
	               {0, 0}, 0, WHITE);

	//DrawTexture(*m_title, 0, 0, WHITE);

	DrawTexturePro(*m_title, Rectangle{0, 0, float(m_title->width), float(m_title->height)}, Rectangle{
		               0, 0, float(m_title->width * g_DrawScale * .5f), float(m_title->height * g_DrawScale * .5f)
	               }, {0, 0}, 0, WHITE);

	if (m_mouseMoved)
	{
		DrawTextureEx(*g_Cursor, {float(GetMouseX()), float(GetMouseY())}, 0, g_DrawScale, WHITE);
	}

	//DrawFPS(10, 300);

	EndDrawing();
}

////////////////////////////////////////////////////////////////////////////////
///  CREATORS
////////////////////////////////////////////////////////////////////////////////

void TitleState::CreateTitleGUI()
{
	m_TitleGui = make_shared<Gui>();
	m_TitleGui->m_Font = g_SmallFont;

	m_TitleGui->SetLayout(0, 0, g_Engine->m_RenderWidth, g_Engine->m_RenderHeight, g_DrawScale, Gui::GUIP_USE_XY);
	m_TitleGui->AddOctagonBox(GUI_TITLE_PANEL2, 220, 180, 200, 160, g_Borders);
	//m_TitleGui->AddTextArea(GUI_TITLE_TITLE, g_Font.get(), "Ultima VII: Revisited", (320 - (MeasureText("Ultima VII: Revisited", g_Font->baseSize * g_DrawScale))) / 2, 20,
	//   (MeasureText("Ultima VII: Revisited", g_Font->baseSize * g_DrawScale)), 0, Color{255, 255, 255, 255}, true);

	int y = 186;
	int yoffset = 22;

	m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_TRINSIC_DEMO, y, "Trinsic Demo",
	                                     g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                                     g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	y += yoffset;

	m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_SINGLE_PLAYER, y, "Sandbox Mode",
												 g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
												 g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	// y += yoffset;
	//
	// m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_SHAPE_EDITOR, y, "Shape Editor",
	//                                      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	//                                      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	y += yoffset;
	m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_OPTIONS, y, "Options",
	                                     g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                                     g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	y += yoffset;
	m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_CREDITS, y, "Credits",
	                                     g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                                     g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);


	y += yoffset;
	m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_QUIT, y, "Quit",
	                                     g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                                     g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	y += yoffset;
	int width = MeasureTextEx(*g_SmallFont, "GitHub", g_SmallFont->baseSize, 1).x * 1.3f;
	m_TitleGui->AddStretchButton(GUI_TITLE_BUTTON_GITHUB, 240, y, width, "GitHub",
	                             g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                             g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_YOUTUBE, y, "YouTube",
	                                     g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                                     g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	width = MeasureTextEx(*g_SmallFont, "X", g_SmallFont->baseSize, 1).x * 2.0f;
	m_TitleGui->AddStretchButton(GUI_TITLE_BUTTON_X, 360, y, width, "X",
	                             g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                             g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	y += yoffset;

	width = MeasureTextEx(*g_SmallFont, "Patreon", g_SmallFont->baseSize, 1).x * 1.3f;
	m_TitleGui->AddStretchButton(GUI_TITLE_BUTTON_PATREON, 260, y, width, "Patreon",
	                             g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                             g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	width = MeasureTextEx(*g_SmallFont, "Ko-Fi", g_SmallFont->baseSize, 1).x * 1.5f;
	m_TitleGui->AddStretchButton(GUI_TITLE_BUTTON_KOFI, 320, y, width, "Ko-Fi",
	                             g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                             g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);


	m_TitleGui->m_Active = true;

	m_TitleGui->m_Draggable = true;
}

void TitleState::CreateCreditsGUI()
{
	m_CreditsGui = make_shared<Gui>();
	m_CreditsGui->m_Font = g_SmallFont;

	m_CreditsGui->SetLayout(120, 80, 400, 260, g_DrawScale, Gui::GUIP_USE_XY);
	m_CreditsGui->AddOctagonBox(GUI_CREDITS_PANEL, 0, 0, 400, 260, g_Borders);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE, g_SmallFont.get(), "CREDITS!", 200, 10, 0, 0, Color{255, 255, 255, 255},
	                          GuiTextArea::CENTERED, 0, 1, true);

	int idOffset = 1;
	int yOffset = 12;
	int y = 10;

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Project Lead - Anthony Salter", 200,
	                          y += yOffset, 0, 0, GREEN, GuiTextArea::CENTERED, 0, 1, true);

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(),
	                          "u7revisited.com - youtube.com/viridiangames", 200, y += yOffset, 0, 0, GREEN,
	                          GuiTextArea::CENTERED, 0, 1, true);

	y += yOffset * 1.5f;

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "CodeTinkers!", 100, y, 0, 0, BLUE,
	                          GuiTextArea::CENTERED, 0, 1, true);

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Special Thanks!", 200, y, 0, 0, YELLOW,
	                          GuiTextArea::CENTERED, 0, 1, true);

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "ArtMages!", 300, y, 0, 0, RED,
	                          GuiTextArea::CENTERED, 0, 1, true);

	//y += yOffset * .5f;;

	//  Codetinkers!
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Clawjelly", 100, y += yOffset, 0, 0,
	                          BLUE, GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Daremon", 100, y += yOffset, 0, 0,
	                          BLUE, GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Rsaarelm", 100, y += yOffset, 0, 0,
	                          BLUE, GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Tibbonzero", 100, y += yOffset, 0, 0,
	                          BLUE, GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Wazoo", 100, y += yOffset, 0, 0, BLUE,
	                          GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Furroy", 100, y += yOffset, 0, 0, BLUE,
	                          GuiTextArea::CENTERED, 0, 1, true);

	y = 10 + 3.5f * yOffset; //  Reset y to the top of the art section

	//  ArtMages!
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "1crash007", 300, y += yOffset, 0, 0,
	                          RED, GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Aiden", 300, y += yOffset, 0, 0, RED,
	                          GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Blues", 300, y += yOffset, 0, 0, RED,
	                          GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Clawjelly", 300, y += yOffset, 0, 0,
	                          RED, GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "CYON4D", 300, y += yOffset, 0, 0, RED,
	                          GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Donkko", 300, y += yOffset, 0, 0, RED,
	                          GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "MementoMoree", 300, y += yOffset, 0, 0,
	                          RED, GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Rsaarelm", 300, y += yOffset, 0, 0,
	                          RED, GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "UrAnt", 300, y += yOffset, 0, 0, RED,
	                          GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Wudan07", 300, y += yOffset, 0, 0, RED,
	                          GuiTextArea::CENTERED, 0, 1, true);

	y = 10 + 3.5f * yOffset; //  Reset y to the top of the art section

	//  Special Thanks
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "ScouterVee", 200, y += yOffset, 0, 0,
	                          YELLOW, GuiTextArea::CENTERED, 0, 1, true);
	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "SolviteSekai", 200, y += yOffset, 0, 0,
	                          YELLOW, GuiTextArea::CENTERED, 0, 1, true);

	y = 142;

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Ko-Fi Buyers!", 100, y, 0, 0, WHITE,
	                          GuiTextArea::CENTERED, 0, 1, true);

	y = 118;

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Patrons!", 200, y, 0, 0, WHITE,
	                          GuiTextArea::CENTERED, 0, 1, true);

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Andrew Gaul", 200, y += yOffset, 0, 0,
	                          WHITE, GuiTextArea::CENTERED, 0, 1, true);

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Ben Citak", 200, y += yOffset, 0, 0,
	                          WHITE, GuiTextArea::CENTERED, 0, 1, true);

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Christoffer Erikson", 200,
	                          y += yOffset, 0, 0, WHITE, GuiTextArea::CENTERED, 0, 1, true);

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "FreeManPhil", 200, y += yOffset, 0, 0,
	                          WHITE, GuiTextArea::CENTERED, 0, 1, true);

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Gronkh", 200, y += yOffset, 0, 0,
	                          WHITE, GuiTextArea::CENTERED, 0, 1, true);

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Johnny Mellgren", 200, y += yOffset, 0,
	                          0, WHITE, GuiTextArea::CENTERED, 0, 1, true);

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Joseph", 200, y += yOffset, 0, 0,
	                          WHITE, GuiTextArea::CENTERED, 0, 1, true);

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Nighthawk", 200, y += yOffset, 0, 0,
	                          WHITE, GuiTextArea::CENTERED, 0, 1, true);

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Pachurice", 200, y += yOffset, 0, 0,
	                          WHITE, GuiTextArea::CENTERED, 0, 1, true);

	y = 142;

	m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Lord Brutish", 100, y += yOffset, 0, 0,
	                          WHITE, GuiTextArea::CENTERED, 0, 1, true);


	//m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Anthony Salter", 290, y += yOffset);


	// m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE, g_Font.get(), "CREDITS!", 220, 180, 100, 20, Color{255, 255, 255, 255}, false, 0, true, true);

	m_CreditsGui->AddStretchButtonCentered(GUI_CREDITS_BUTTON_BACK, 246, "Wow, these are all such cool people!",
	                                       g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                                       g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	m_CreditsGui->m_Active = false;

	m_CreditsGui->m_Draggable = true;
}


////////////////////////////////////////////////////////////////////////////////
///  UPDATERS
////////////////////////////////////////////////////////////////////////////////

void TitleState::UpdateTitle()
{
	m_TitleGui->Update();
	m_CreditsGui->Update();

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_QUIT)
	{
		g_Engine->m_Done = true;
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_SINGLE_PLAYER)
	{
		dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE))->m_gameMode = MainStateModes::MAIN_STATE_MODE_SANDBOX;
		g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_TRINSIC_DEMO)
	{
		dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE))->m_gameMode = MainStateModes::MAIN_STATE_MODE_TRINSIC_DEMO;
		g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_SHAPE_EDITOR)
	{
		g_StateMachine->MakeStateTransition(STATE_SHAPEEDITORSTATE);
	}

	if (m_CreditsGui->m_ActiveElement == GUI_CREDITS_BUTTON_BACK)
	{
		m_TitleGui->m_Active = true;
		m_CreditsGui->m_Active = false;
		m_CreditsGui->m_ActiveElement = -1;
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_CREDITS)
	{
		m_TitleGui->m_Active = false;
		m_CreditsGui->m_Active = true;
		m_TitleGui->m_ActiveElement = -1;
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_GITHUB)
	{
		OpenURL("https://github.com/ViridianGames/U7Revisited/?tab=readme-ov-file#ultima-vii-revisited");
		m_TitleGui->m_ActiveElement = -1;
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_YOUTUBE)
	{
		OpenURL("https://www.youtube.com/@viridiangames");
		m_TitleGui->m_ActiveElement = -1;
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_X)
	{
		OpenURL("https://x.com/ViridianGames");
		m_TitleGui->m_ActiveElement = -1;
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_PATREON)
	{
		OpenURL("https://www.patreon.com/ViridianGames");
		m_TitleGui->m_ActiveElement = -1;
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_KOFI)
	{
		OpenURL("https://ko-fi.com/viridiangames");
		m_TitleGui->m_ActiveElement = -1;
	}

	if (IsKeyPressed(KEY_ESCAPE))
	{
		g_Engine->m_Done = true;
	}

	if (abs(GetMouseDelta().x) > 25 || abs(GetMouseDelta().y) > 25)
	{
		m_mouseMoved = true;
	}
}

void TitleState::TestUpdate()
{
	ModTexture& modTexture = *g_shapeTable[150][0].m_texture;
	if (IsKeyPressed(KEY_A))
	{
		modTexture.ResizeImage(modTexture.m_Image.width - 1, modTexture.m_Image.height);
		modTexture.UpdateTexture();
	}

	if (IsKeyPressed(KEY_D))
	{
		modTexture.ResizeImage(modTexture.m_Image.width + 1, modTexture.m_Image.height);
		modTexture.UpdateTexture();
	}

	if (IsKeyPressed(KEY_W))
	{
		modTexture.ResizeImage(modTexture.m_Image.width, modTexture.m_Image.height - 1);
		modTexture.UpdateTexture();
	}

	if (IsKeyPressed(KEY_S))
	{
		modTexture.ResizeImage(modTexture.m_Image.width, modTexture.m_Image.height + 1);
		modTexture.UpdateTexture();
	}
}

void TitleState::TestDraw()
{
	DrawTexture(g_shapeTable[150][0].m_texture->m_Texture, 0, 0, WHITE);
}
