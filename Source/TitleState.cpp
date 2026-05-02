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

#include "LoadSaveState.h"
#include "Logging.h"
#include "SoundSystem.h"

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
	g_SoundSystem->PlayMusic("Audio/Music/22bg.ogg");
}

void TitleState::OnExit()
{
	g_SoundSystem->StopMusic("Audio/Music/22bg.ogg");
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
}

void TitleState::FadeIn(float fadeTime)
{
	m_fadeState = FadeState::FADE_IN;
	m_fadeDuration = fadeTime;
	m_fadeTime = 0;
}

void TitleState::FadeOut(float fadeTime)
{
	m_fadeState = FadeState::FADE_OUT;
	m_fadeDuration = fadeTime;
	m_fadeTime = 0;
}


void TitleState::Draw()
{
	//rlSetBlendFactors(RL_SRC_ALPHA, RL_ONE_MINUS_SRC_ALPHA, RL_MIN);
	rlSetBlendMode(BLEND_ALPHA);

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

	DrawRectangleRounded({0, 0, 206, 80}, .25, 100, {0, 0, 0, 224});

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
		               g_DrawScale * 1.5f, g_DrawScale, float(m_title->width * g_DrawScale * .5f), float(m_title->height * g_DrawScale * .5f)
	               }, {0, 0}, 0, WHITE);

	if (m_mouseMoved)
	{
		DrawTextureEx(*g_Cursor, {float(GetMouseX()), float(GetMouseY())}, 0, g_DrawScale, WHITE);
	}

	DrawRectangle(0, 0, g_Engine->m_ScreenWidth, g_Engine->m_ScreenHeight, { 0, 0, 0, m_currentFadeAlpha });

	//DrawFPS(10, 300);
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

	m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_START_TRINSIC_DEMO, y, "Start Trinsic Demo",
	                                     g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                                     g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	y += yoffset;

	m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_LOAD_TRINSIC_DEMO, y, "Load Game",
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
	m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_PATREON_VILLAGE, y, "Visit Patreon Village!",
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

	y += 16;
	Texture* githubIcon = g_ResourceManager->GetTexture("Images/GUI/github.png");

	Texture* youtubeIcon = g_ResourceManager->GetTexture("Images/GUI/youtube.png");
	m_TitleGui->AddIconButton(GUI_TITLE_BUTTON_YOUTUBE, youtubeIcon, 238, y, 0, 0, githubIcon->width, githubIcon->height);

	Texture* xIcon = g_ResourceManager->GetTexture("Images/GUI/x.png");
	m_TitleGui->AddIconButton(GUI_TITLE_BUTTON_X, xIcon, 273, y, 0, 0, githubIcon->width, githubIcon->height);

	m_TitleGui->AddIconButton(GUI_TITLE_BUTTON_GITHUB, githubIcon, 308, y, 0, 0, githubIcon->width, githubIcon->height);

	Texture* patreonIcon = g_ResourceManager->GetTexture("Images/GUI/patreon.png");
	m_TitleGui->AddIconButton(GUI_TITLE_BUTTON_PATREON, patreonIcon, 343, y, 0, 0, githubIcon->width, githubIcon->height);

	Texture* kofiIcon = g_ResourceManager->GetTexture("Images/GUI/kofi.png");
	m_TitleGui->AddIconButton(GUI_TITLE_BUTTON_KOFI, kofiIcon, 378, y, 0, 0, githubIcon->width, githubIcon->height);

	m_TitleGui->m_Active = true;

	m_TitleGui->m_Draggable = true;
}

void TitleState::CreateCreditsGUI()
{
    m_CreditsGui = make_shared<Gui>();
    m_CreditsGui->m_Font = g_SmallFont;

    // Panel size adjusted to comfortably fit the new layout
    m_CreditsGui->SetLayout(90, 75, 420, 250, g_DrawScale, Gui::GUIP_USE_XY);
    m_CreditsGui->AddOctagonBox(GUI_CREDITS_PANEL, 0, 0, 420, 250, g_Borders);

    m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE, g_SmallFont.get(), "CREDITS!", 210, 12, 0, 0,
                              Color{255, 255, 255, 255}, GuiTextArea::CENTERED, 0, 1, true);

    int idOffset = 1;
    const int lineSpacing = 14;

    // ==================== ArtMages! (Centered under title) ====================
    int artY = 48;
    m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "ArtMages!", 210, artY,
                              0, 0, RED, GuiTextArea::CENTERED, 0, 1, true);

    const std::vector<std::string> artmages = {
        "1crash007", "Aiden", "clawjelly", "CYONN4D", "Donkko",
        "MementoMoree", "rsaarelm", "UrAnt", "Wudan07"
    };

    artY += lineSpacing;
    for (const auto& name : artmages)
    {
        m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), name, 210,
                                  artY, 0, 0, RED, GuiTextArea::CENTERED, 0, 1, true);
        artY += lineSpacing;
    }

    // ==================== CodeTinkers (Left Column) ====================
    int leftY = 48;
    m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "CodeTinkers!", 110, leftY,
                              0, 0, BLUE, GuiTextArea::CENTERED, 0, 1, true);

    const std::vector<std::string> codetinkers = {
        "clawjelly", "daremon", "DLB", "Furroy", "Richard Szalay", "rsaarelm", "tibbonzero"
    };

    leftY += lineSpacing;
    for (const auto& name : codetinkers)
    {
        m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), name, 110,
                                  leftY, 0, 0, BLUE, GuiTextArea::CENTERED, 0, 1, true);
        leftY += lineSpacing;
    }

    // ==================== Special Thanks (Right Column) ====================
    int rightY = 48;
    m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Special Thanks!", 310, rightY,
                              0, 0, YELLOW, GuiTextArea::CENTERED, 0, 1, true);

    const std::vector<std::string> specialThanks = {
        "ScouterVee", "SolviteSekai"
    };

    rightY += lineSpacing;
    for (const auto& name : specialThanks)
    {
        m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), name, 310,
                                  rightY, 0, 0, YELLOW, GuiTextArea::CENTERED, 0, 1, true);
        rightY += lineSpacing;
    }

    // ==================== Ko-Fi Buyers (Under Special Thanks) ====================
    rightY += lineSpacing * 1.2f;   // Small gap
    m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), "Ko-Fi Buyers!", 310, rightY,
                              0, 0, WHITE, GuiTextArea::CENTERED, 0, 1, true);

    rightY += lineSpacing;

    const std::vector<std::string> kofi = {
        "Lord Brutish", "Pontifex", "Fabik_LPU"
    };

    for (const auto& name : kofi)
    {
        m_CreditsGui->AddTextArea(GUI_CREDITS_TITLE + idOffset++, g_SmallFont.get(), name, 310,
                                  rightY, 0, 0, WHITE, GuiTextArea::CENTERED, 0, 1, true);
        rightY += lineSpacing;
    }



    // Back button at bottom center
    m_CreditsGui->AddStretchButtonCentered(GUI_CREDITS_BUTTON_BACK, 216,
        "Wow, these are all such cool people!",
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

	if (m_fadingOut && int(m_currentFadeAlpha) > 250) // Fully faded
	{
		g_StateMachine->MakeStateTransition(m_targetState);
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_QUIT)
	{
		g_Engine->m_Done = true;
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_SINGLE_PLAYER)
	{
		dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE))->m_gameMode = MainStateModes::MAIN_STATE_MODE_SANDBOX;
		g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_START_TRINSIC_DEMO)
	{
		if (m_fadeState != FadeState::FADE_OUT)
		{
			m_fadingOut = true;
			FadeOut(1.5);
			dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE))->m_gameMode = MainStateModes::MAIN_STATE_MODE_TRINSIC_DEMO;
			m_TitleGui->m_AcceptingInput = false;
			m_targetState = STATE_MAINSTATE;
		}
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_LOAD_TRINSIC_DEMO)
	{
		Log("MainState::OpenLoadSaveGump - Pushing load/save state");
		dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE))->m_gameMode = MainStateModes::MAIN_STATE_MODE_TRINSIC_DEMO;
		dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE))->m_loadOnEntry = true;
		g_StateMachine->MakeStateTransition(STATE_MAINSTATE);

		//		FixObjectListForLoading();
		// if (m_fadeState != FadeState::FADE_OUT)
		// {
		// 	m_fadingOut = true;
		// 	FadeOut(1.5);
		// 	dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE))->m_gameMode = MainStateModes::MAIN_STATE_MODE_TRINSIC_DEMO;
		// 	m_TitleGui->m_AcceptingInput = false;
		// }
	}

	if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_PATREON_VILLAGE)
	{
		if (m_fadeState != FadeState::FADE_OUT)
		{
			m_fadingOut = true;
			FadeOut(1.5);
			m_TitleGui->m_AcceptingInput = false;
			m_targetState = STATE_PATREONVILLAGESTATE;
		}
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

void TitleState::FixObjectListForLoading()
{
	//  We're about to load a save, so purge any non-static object from the object list.
	for (auto it = g_objectList.begin(); it != g_objectList.end(); )
	{
		U7Object* obj = it->second.get();
		if (obj && obj->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_STATIC)
		{
			it = g_objectList.erase(it);
		}
		else
		{
			++it;
		}
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
