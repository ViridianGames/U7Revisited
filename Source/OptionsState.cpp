#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/SoundSystem.h"
#include "raylib.h"
#include "OptionsState.h"
#include "U7Globals.h"
#include "rlgl.h"
#include <list>
#include <string>
#include <sstream>
#include <math.h>
#include <fstream>
#include <algorithm>

#include "StateMachine.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  OptionsState
////////////////////////////////////////////////////////////////////////////////

OptionsState::~OptionsState()
{
   Shutdown();
}

void OptionsState::Init(const string& configfile)
{
	CreateOptionsGUI();
}

void OptionsState::OnEnter()
{
	m_newDrawScale = g_DrawScale;
}

void OptionsState::OnExit()
{

}

void OptionsState::Shutdown()
{

}

void OptionsState::Update()
{
   if( IsKeyPressed(KEY_ESCAPE) )
   {
   	g_Engine->m_EngineConfig.SetNumber("music_volume", g_SoundSystem->GetGlobalMusicVolume());
   	g_Engine->m_EngineConfig.SetNumber("sound_volume", g_SoundSystem->GetGlobalSoundVolume());
   	g_Engine->m_EngineConfig.Save();
      g_StateMachine->PopState(); // Pop this state.
   }

	m_Gui->Update();

	if (m_Gui->GetActiveElementID() == GUI_OPTIONS_BACK_TO_GAME_BUTTON)
	{
		g_Engine->m_EngineConfig.SetNumber("music_volume", g_SoundSystem->GetGlobalMusicVolume());
		g_Engine->m_EngineConfig.SetNumber("sound_volume", g_SoundSystem->GetGlobalSoundVolume());
		g_Engine->m_EngineConfig.Save();
		g_StateMachine->PopState(); // Pop this state.
		g_StateMachine->PopState(); // Pop this state.
	}

	if (m_Gui->GetActiveElementID() == GUI_OPTIONS_QUIT_GAME_BUTTON)
	{
		g_Engine->m_EngineConfig.SetNumber("music_volume", g_SoundSystem->GetGlobalMusicVolume());
		g_Engine->m_EngineConfig.SetNumber("sound_volume", g_SoundSystem->GetGlobalSoundVolume());
		g_Engine->m_EngineConfig.Save();
		g_StateMachine->PopState(); // Pop this state.
		g_Engine->m_Done = true;
	}

	m_Gui->GetElement(GUI_OPTIONS_MUSIC_CURRENT_MUSIC_VOLUME_TEXTAREA)->m_String = to_string(int(g_SoundSystem->GetGlobalMusicVolume()));

	m_Gui->GetElement(GUI_OPTIONS_SOUND_CURRENT_SOUND_VOLUME_TEXTAREA)->m_String = to_string(int(g_SoundSystem->GetGlobalSoundVolume()));

	m_Gui->GetElement(GUI_OPTIONS_CURRENT_RESOLUTION_TEXT_AREA)->m_String = to_string( int(g_Engine->m_EngineConfig.GetNumber("h_res"))) + " x " + to_string(int(g_Engine->m_EngineConfig.GetNumber("v_res")));

	if (m_Gui->GetActiveElementID() == GUI_OPTIONS_FULLSCREEN_CHECKBOX)
	{
		ToggleFullscreen();
	}

	if (m_Gui->GetActiveElementID() == GUI_OPTIONS_MUSIC_VOLUME_DOWN_BUTTON)
	{
		g_SoundSystem->SetGlobalMusicVolume(g_SoundSystem->GetGlobalMusicVolume() - 1.0f);
	}

	if (m_Gui->GetActiveElementID() == GUI_OPTIONS_MUSIC_VOLUME_UP_BUTTON)
	{
		g_SoundSystem->SetGlobalMusicVolume(g_SoundSystem->GetGlobalMusicVolume() + 1.0f);
	}

	if (m_Gui->GetActiveElementID() == GUI_OPTIONS_SOUND_VOLUME_DOWN_BUTTON)
	{
		g_SoundSystem->SetGlobalSoundVolume(g_SoundSystem->GetGlobalSoundVolume() - 1.0f);
	}

	if (m_Gui->GetActiveElementID() == GUI_OPTIONS_SOUND_VOLUME_UP_BUTTON)
	{
		g_SoundSystem->SetGlobalSoundVolume(g_SoundSystem->GetGlobalSoundVolume() + 1.0f);
	}

	if(m_Gui->GetActiveElementID() == GUI_OPTIONS_PREV_RESOLUTION_BUTTON)
	{
		if (m_newDrawScale > 1)
		{
			m_newDrawScale -= 1;
			g_Engine->m_EngineConfig.SetNumber("h_res", g_Engine->m_RenderWidth * m_newDrawScale);
			g_Engine->m_EngineConfig.SetNumber("v_res", g_Engine->m_RenderHeight * m_newDrawScale);
			g_Engine->m_EngineConfig.Save();
			m_Gui->GetElement(GUI_OPTIONS_CHANGE_RESOLUTION_NOTIFICATION_TEXT_AREA)->m_String = "Please restart to change resolution.";
		}
	}

	if(m_Gui->GetActiveElementID() == GUI_OPTIONS_NEXT_RESOLUTION_BUTTON)
	{
		int currentMonitor = GetCurrentMonitor();
		int maxWidth = GetMonitorWidth(currentMonitor);

		if ((m_newDrawScale + 1) * g_Engine->m_RenderWidth <= maxWidth)
		{
			m_newDrawScale += 1;
			g_Engine->m_EngineConfig.SetNumber("h_res", g_Engine->m_RenderWidth * (m_newDrawScale));
			g_Engine->m_EngineConfig.SetNumber("v_res", g_Engine->m_RenderHeight * (m_newDrawScale));
			g_Engine->m_EngineConfig.Save();
			m_Gui->GetElement(GUI_OPTIONS_CHANGE_RESOLUTION_NOTIFICATION_TEXT_AREA)->m_String = "Please restart to change resolution.";
		}
	}

	if (m_Gui->GetActiveElementID() == GUI_OPTIONS_SAVE_GAME_BUTTON)
	{
		g_StateMachine->PopState();
		g_StateMachine->PushState(STATE_LOADSAVESTATE);
	}
}


void OptionsState::Draw()
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

	m_Gui->Draw();

	EndTextureMode();
	DrawTexturePro(g_guiRenderTarget.texture,
	               {0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height)},
	               {
		               0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth),
		               -float(g_Engine->m_ScreenHeight)
	               },
	               {0, 0}, 0, WHITE);

	DrawTextureEx(*g_Cursor, {float(GetMouseX()), float(GetMouseY())}, 0, g_DrawScale, WHITE);

	//DrawRectangle(0, 0, g_Engine->m_ScreenWidth, g_Engine->m_ScreenHeight, { 0, 0, 0, m_currentFadeAlpha });

}

void OptionsState::CreateOptionsGUI()
{
   m_Gui = make_shared<Gui>();
   m_Gui->m_Font = g_SmallFont;

   m_Gui->SetLayout(0, 0, g_Engine->m_RenderWidth, g_Engine->m_RenderHeight, g_DrawScale, Gui::GUIP_USE_XY);
   m_Gui->AddOctagonBox(GUI_OPTIONS_PANEL, 200, 80, 240, 140, g_Borders);

   int x = 210;
   int y = 90;
   int yoffset = 20;

   m_Gui->AddTextArea(GUI_OPTIONS_TITLE, g_SmallFont.get(), "Options", 320, y, 0, 0,
                          Color{255, 255, 255, 255}, GuiTextArea::CENTERED, 0, 1, true);

	y += yoffset + 5;

   m_Gui->AddTextArea(GUI_OPTIONS_MUSIC_LABEL, g_SmallFont.get(), "Music Volume:", x, y, 0, 0,
                       Color{255, 255, 255, 255}, GuiTextArea::LEFT, 0, 1, true);
	GuiIconButton* downButton = m_Gui->AddIconButton(GUI_OPTIONS_MUSIC_VOLUME_DOWN_BUTTON, 300, y, g_LeftArrow);
	downButton->m_CanBeHeld = true;
	m_Gui->AddIconButton(GUI_OPTIONS_MUSIC_VOLUME_UP_BUTTON, 280, y, g_RightArrow);
	GuiIconButton* upButton = m_Gui->AddIconButton(GUI_OPTIONS_MUSIC_VOLUME_UP_BUTTON, 340, y, g_RightArrow);
	upButton->m_CanBeHeld = true;
	m_Gui->AddTextArea(GUI_OPTIONS_MUSIC_CURRENT_MUSIC_VOLUME_TEXTAREA, g_SmallFont.get(), "0", 320, y, 0, 0);

	y += yoffset;

	m_Gui->AddTextArea(GUI_OPTIONS_SOUND_LABEL, g_SmallFont.get(), "Sound Volume:", x, y, 0, 0,
							  Color{255, 255, 255, 255}, GuiTextArea::LEFT, 0, 1, true);
	GuiIconButton* downSButton = m_Gui->AddIconButton(GUI_OPTIONS_SOUND_VOLUME_DOWN_BUTTON, 300, y, g_LeftArrow);
	downSButton->m_CanBeHeld = true;
	GuiIconButton* upSButton = m_Gui->AddIconButton(GUI_OPTIONS_SOUND_VOLUME_UP_BUTTON, 340, y, g_RightArrow);
	upSButton->m_CanBeHeld = true;
	m_Gui->AddTextArea(GUI_OPTIONS_SOUND_CURRENT_SOUND_VOLUME_TEXTAREA, g_SmallFont.get(), "0", 320, y, 0, 0);

	y += yoffset;

   m_Gui->AddTextArea(GUI_OPTIONS_RESOLUTION_LABEL, g_SmallFont.get(), "Resolution:", x, y, 0, 0,
                    Color{255, 255, 255, 255}, GuiTextArea::LEFT, 0, 1, true);

	m_Gui->AddIconButton(GUI_OPTIONS_PREV_RESOLUTION_BUTTON, 300, y, g_LeftArrow);
	m_Gui->AddIconButton(GUI_OPTIONS_NEXT_RESOLUTION_BUTTON, 400, y, g_RightArrow);

	m_Gui->AddTextArea(GUI_OPTIONS_CURRENT_RESOLUTION_TEXT_AREA, g_SmallFont.get(), "0", 320, y, 0, 0);
	y += yoffset;
	GuiTextArea* reso = m_Gui->AddTextArea(GUI_OPTIONS_CHANGE_RESOLUTION_NOTIFICATION_TEXT_AREA, g_SmallFont.get(), "", x, y, 0, 0);
	reso->m_Active = false;

	y += yoffset;

   // m_Gui->AddTextArea(GUI_OPTIONS_FULLSCREEN_LABEL, g_SmallFont.get(), "Fullscreen:", x, y, 0, 0,
   //               Color{255, 255, 255, 255}, GuiTextArea::LEFT, 0, 1, true);
   //
   // m_Gui->AddCheckBox(GUI_OPTIONS_FULLSCREEN_CHECKBOX, 320, y, 10, 10, 1, 1, GRAY, 0, true);

	//y += yoffset + 10;

   m_Gui->AddStretchButton(GUI_OPTIONS_SAVE_GAME_BUTTON, 224, y, 70, "Save/Load",
                                        g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
                                        g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   // m_Gui->AddStretchButton(GUI_OPTIONS_LOAD_GAME_BUTTON, 265, y, 50, "Load",
   //                          g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
   //                          g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	m_Gui->AddStretchButton(GUI_OPTIONS_BACK_TO_GAME_BUTTON, 300, y, 50, "Back",
								 g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
								 g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   m_Gui->AddStretchButton(GUI_OPTIONS_QUIT_GAME_BUTTON, 355, y, 50, "Quit",
                            g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
                            g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);


   m_Gui->m_Active = true;

   m_Gui->m_Draggable = false;
}
