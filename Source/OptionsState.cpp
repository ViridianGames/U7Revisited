#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/SoundSystem.h"
#include "raylib.h"
#include "OptionsState.h"
#include "U7Globals.h"
#include "CombatMode.h"
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
	SetFirstPersonMouseLook(false);

	m_openedFromTitle = (g_StateMachine && g_StateMachine->GetPreviousState() == STATE_TITLESTATE);

	if (auto* saveBtn = m_Gui->GetElement(GUI_OPTIONS_SAVE_GAME_BUTTON).get())
	{
		saveBtn->m_Visible = !m_openedFromTitle;
		saveBtn->m_Active = !m_openedFromTitle;
	}

	SyncCombatStyleRadios();
	SetActiveTab(OptionsTab::System);
}

void OptionsState::OnExit()
{
}

void OptionsState::Shutdown()
{
}

void OptionsState::SetActiveTab(OptionsTab tab)
{
	m_activeTab = tab;
	const bool showSystem = (tab == OptionsTab::System);
	const bool showGameplay = (tab == OptionsTab::Gameplay);

	for (int id : m_systemElementIds)
	{
		auto el = m_Gui->GetElement(id);
		if (!el)
			continue;
		if (id == GUI_OPTIONS_SAVE_GAME_BUTTON && m_openedFromTitle)
		{
			el->m_Visible = false;
			el->m_Active = false;
			continue;
		}
		el->m_Visible = showSystem;
		// Keep inactive notification inactive unless it has text.
		if (id == GUI_OPTIONS_CHANGE_RESOLUTION_NOTIFICATION_TEXT_AREA)
			continue;
		el->m_Active = showSystem;
	}

	for (int id : m_gameplayElementIds)
	{
		auto el = m_Gui->GetElement(id);
		if (!el)
			continue;
		el->m_Visible = showGameplay;
		el->m_Active = showGameplay;
	}

	// Tab buttons stay visible/active always.
	if (auto* sys = m_Gui->GetElement(GUI_OPTIONS_TAB_SYSTEM).get())
	{
		sys->m_Visible = true;
		sys->m_Active = true;
	}
	if (auto* gp = m_Gui->GetElement(GUI_OPTIONS_TAB_GAMEPLAY).get())
	{
		gp->m_Visible = true;
		gp->m_Active = true;
	}

	// Footer buttons stay on both tabs.
	for (int id : { GUI_OPTIONS_BACK_TO_GAME_BUTTON, GUI_OPTIONS_QUIT_GAME_BUTTON })
	{
		auto el = m_Gui->GetElement(id);
		if (!el)
			continue;
		el->m_Visible = true;
		el->m_Active = true;
	}
}

void OptionsState::SyncCombatStyleRadios()
{
	const CombatStyle style = GetCombatStylePreference();
	auto setSelected = [&](int id, bool selected) {
		auto el = m_Gui->GetElement(id);
		if (el)
			el->m_Selected = selected;
	};
	setSelected(GUI_OPTIONS_COMBAT_STYLE_ORIGINAL, style == CombatStyle::Original);
	setSelected(GUI_OPTIONS_COMBAT_STYLE_RTWP, style == CombatStyle::RealTimePause);
	setSelected(GUI_OPTIONS_COMBAT_STYLE_TURN, style == CombatStyle::TurnBased);
}

void OptionsState::ApplyCombatStyleFromRadios()
{
	auto isSelected = [&](int id) {
		auto el = m_Gui->GetElement(id);
		return el && el->m_Selected;
	};

	CombatStyle style = CombatStyle::RealTimePause;
	if (isSelected(GUI_OPTIONS_COMBAT_STYLE_ORIGINAL))
		style = CombatStyle::Original;
	else if (isSelected(GUI_OPTIONS_COMBAT_STYLE_TURN))
		style = CombatStyle::TurnBased;
	else
		style = CombatStyle::RealTimePause;

	SetCombatStylePreference(style);
}

void OptionsState::Update()
{
	if (IsKeyPressed(KEY_ESCAPE))
	{
		g_Engine->m_EngineConfig.SetNumber("music_volume", g_SoundSystem->GetGlobalMusicVolume());
		g_Engine->m_EngineConfig.SetNumber("sound_volume", g_SoundSystem->GetGlobalSoundVolume());
		g_Engine->m_EngineConfig.Save();
		g_StateMachine->PopState();
		return;
	}

	m_Gui->Update();

	const int activeId = m_Gui->GetActiveElementID();

	if (activeId == GUI_OPTIONS_TAB_SYSTEM)
	{
		SetActiveTab(OptionsTab::System);
		return;
	}
	if (activeId == GUI_OPTIONS_TAB_GAMEPLAY)
	{
		SetActiveTab(OptionsTab::Gameplay);
		return;
	}

	if (activeId == GUI_OPTIONS_COMBAT_STYLE_ORIGINAL ||
	    activeId == GUI_OPTIONS_COMBAT_STYLE_RTWP ||
	    activeId == GUI_OPTIONS_COMBAT_STYLE_TURN)
	{
		ApplyCombatStyleFromRadios();
		return;
	}

	if (activeId == GUI_OPTIONS_BACK_TO_GAME_BUTTON)
	{
		g_Engine->m_EngineConfig.SetNumber("music_volume", g_SoundSystem->GetGlobalMusicVolume());
		g_Engine->m_EngineConfig.SetNumber("sound_volume", g_SoundSystem->GetGlobalSoundVolume());
		g_Engine->m_EngineConfig.Save();
		g_StateMachine->PopState();
		return;
	}

	if (activeId == GUI_OPTIONS_QUIT_GAME_BUTTON)
	{
		g_Engine->m_EngineConfig.SetNumber("music_volume", g_SoundSystem->GetGlobalMusicVolume());
		g_Engine->m_EngineConfig.SetNumber("sound_volume", g_SoundSystem->GetGlobalSoundVolume());
		g_Engine->m_EngineConfig.Save();
		g_StateMachine->PopState();
		g_Engine->m_Done = true;
		return;
	}

	if (m_activeTab == OptionsTab::System)
	{
		m_Gui->GetElement(GUI_OPTIONS_MUSIC_CURRENT_MUSIC_VOLUME_TEXTAREA)->m_String =
			to_string(int(g_SoundSystem->GetGlobalMusicVolume()));
		m_Gui->GetElement(GUI_OPTIONS_SOUND_CURRENT_SOUND_VOLUME_TEXTAREA)->m_String =
			to_string(int(g_SoundSystem->GetGlobalSoundVolume()));
		m_Gui->GetElement(GUI_OPTIONS_CURRENT_RESOLUTION_TEXT_AREA)->m_String =
			to_string(int(g_Engine->m_EngineConfig.GetNumber("h_res"))) + " x " +
			to_string(int(g_Engine->m_EngineConfig.GetNumber("v_res")));

		if (activeId == GUI_OPTIONS_FULLSCREEN_CHECKBOX)
		{
			GuiCheckBox* checkbox = static_cast<GuiCheckBox*>(m_Gui->GetElement(GUI_OPTIONS_FULLSCREEN_CHECKBOX).get());
			g_Engine->m_EngineConfig.SetNumber("full_screen", checkbox->GetValue());
			g_Engine->m_EngineConfig.Save();
			m_Gui->GetElement(GUI_OPTIONS_CHANGE_RESOLUTION_NOTIFICATION_TEXT_AREA)->m_String =
				"Please restart to change resolution.";
		}

		if (activeId == GUI_OPTIONS_MUSIC_VOLUME_DOWN_BUTTON)
			g_SoundSystem->SetGlobalMusicVolume(g_SoundSystem->GetGlobalMusicVolume() - 1.0f);
		if (activeId == GUI_OPTIONS_MUSIC_VOLUME_UP_BUTTON)
			g_SoundSystem->SetGlobalMusicVolume(g_SoundSystem->GetGlobalMusicVolume() + 1.0f);
		if (activeId == GUI_OPTIONS_SOUND_VOLUME_DOWN_BUTTON)
			g_SoundSystem->SetGlobalSoundVolume(g_SoundSystem->GetGlobalSoundVolume() - 1.0f);
		if (activeId == GUI_OPTIONS_SOUND_VOLUME_UP_BUTTON)
			g_SoundSystem->SetGlobalSoundVolume(g_SoundSystem->GetGlobalSoundVolume() + 1.0f);

		if (activeId == GUI_OPTIONS_PREV_RESOLUTION_BUTTON)
		{
			if (m_newDrawScale > 1)
			{
				m_newDrawScale -= 1;
				g_Engine->m_EngineConfig.SetNumber("h_res", g_Engine->m_RenderWidth * m_newDrawScale);
				g_Engine->m_EngineConfig.SetNumber("v_res", g_Engine->m_RenderHeight * m_newDrawScale);
				g_Engine->m_EngineConfig.Save();
				m_Gui->GetElement(GUI_OPTIONS_CHANGE_RESOLUTION_NOTIFICATION_TEXT_AREA)->m_String =
					"Please restart to change resolution.";
			}
		}

		if (activeId == GUI_OPTIONS_NEXT_RESOLUTION_BUTTON)
		{
			int currentMonitor = GetCurrentMonitor();
			int maxWidth = GetMonitorWidth(currentMonitor);
			if ((m_newDrawScale + 1) * g_Engine->m_RenderWidth <= maxWidth)
			{
				m_newDrawScale += 1;
				g_Engine->m_EngineConfig.SetNumber("h_res", g_Engine->m_RenderWidth * (m_newDrawScale));
				g_Engine->m_EngineConfig.SetNumber("v_res", g_Engine->m_RenderHeight * (m_newDrawScale));
				g_Engine->m_EngineConfig.Save();
				m_Gui->GetElement(GUI_OPTIONS_CHANGE_RESOLUTION_NOTIFICATION_TEXT_AREA)->m_String =
					"Please restart to change resolution.";
			}
		}

		if (activeId == GUI_OPTIONS_SAVE_GAME_BUTTON && !m_openedFromTitle)
		{
			g_StateMachine->PopState();
			g_StateMachine->PushState(STATE_LOADSAVESTATE);
		}
	}
}

void OptionsState::Draw()
{
	rlSetBlendMode(BLEND_ALPHA);

	// Overlay only — Title or MainState draws underneath via m_RenderStack.
	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({ 0, 0, 0, 0 });

	// Dim the screen behind the panel.
	DrawRectangle(0, 0, g_Engine->m_RenderWidth, g_Engine->m_RenderHeight, Color{ 0, 0, 0, 120 });

	m_Gui->Draw();

	EndTextureMode();
	DrawTexturePro(g_guiRenderTarget.texture,
	               { 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
	               {
		               0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth),
		               -float(g_Engine->m_ScreenHeight)
	               },
	               { 0, 0 }, 0, WHITE);

	DrawTextureEx(*g_Cursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale, WHITE);
}

void OptionsState::CreateOptionsGUI()
{
	m_Gui = make_shared<Gui>();
	m_Gui->m_Font = g_SmallFont;

	m_Gui->SetLayout(0, 0, g_Engine->m_RenderWidth, g_Engine->m_RenderHeight, g_DrawScale, Gui::GUIP_USE_XY);
	m_Gui->AddOctagonBox(GUI_OPTIONS_PANEL, 190, 60, 260, 220, g_Borders);

	int x = 210;
	int y = 70;

	m_Gui->AddTextArea(GUI_OPTIONS_TITLE, g_SmallFont.get(), "Options", 320, y, 0, 0,
	                   Color{ 255, 255, 255, 255 }, GuiTextArea::CENTERED, 0, 1, true);

	y += 18;

	m_Gui->AddStretchButton(GUI_OPTIONS_TAB_SYSTEM, 210, y, 70, "System",
	                        g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                        g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);
	m_Gui->AddStretchButton(GUI_OPTIONS_TAB_GAMEPLAY, 290, y, 80, "Gameplay",
	                        g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                        g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	y += 28;
	const int contentTop = y;

	// ---- System tab content ----
	m_systemElementIds.clear();

	m_Gui->AddTextArea(GUI_OPTIONS_MUSIC_LABEL, g_SmallFont.get(), "Music Volume:", x, y, 0, 0,
	                   Color{ 255, 255, 255, 255 }, GuiTextArea::LEFT, 0, 1, true);
	m_systemElementIds.push_back(GUI_OPTIONS_MUSIC_LABEL);
	GuiIconButton* downButton = m_Gui->AddIconButton(GUI_OPTIONS_MUSIC_VOLUME_DOWN_BUTTON, 300, y, g_LeftArrow);
	downButton->m_CanBeHeld = true;
	m_systemElementIds.push_back(GUI_OPTIONS_MUSIC_VOLUME_DOWN_BUTTON);
	GuiIconButton* upButton = m_Gui->AddIconButton(GUI_OPTIONS_MUSIC_VOLUME_UP_BUTTON, 340, y, g_RightArrow);
	upButton->m_CanBeHeld = true;
	m_systemElementIds.push_back(GUI_OPTIONS_MUSIC_VOLUME_UP_BUTTON);
	m_Gui->AddTextArea(GUI_OPTIONS_MUSIC_CURRENT_MUSIC_VOLUME_TEXTAREA, g_SmallFont.get(), "0", 320, y, 0, 0);
	m_systemElementIds.push_back(GUI_OPTIONS_MUSIC_CURRENT_MUSIC_VOLUME_TEXTAREA);

	y += 20;

	m_Gui->AddTextArea(GUI_OPTIONS_SOUND_LABEL, g_SmallFont.get(), "Sound Volume:", x, y, 0, 0,
	                   Color{ 255, 255, 255, 255 }, GuiTextArea::LEFT, 0, 1, true);
	m_systemElementIds.push_back(GUI_OPTIONS_SOUND_LABEL);
	GuiIconButton* downSButton = m_Gui->AddIconButton(GUI_OPTIONS_SOUND_VOLUME_DOWN_BUTTON, 300, y, g_LeftArrow);
	downSButton->m_CanBeHeld = true;
	m_systemElementIds.push_back(GUI_OPTIONS_SOUND_VOLUME_DOWN_BUTTON);
	GuiIconButton* upSButton = m_Gui->AddIconButton(GUI_OPTIONS_SOUND_VOLUME_UP_BUTTON, 340, y, g_RightArrow);
	upSButton->m_CanBeHeld = true;
	m_systemElementIds.push_back(GUI_OPTIONS_SOUND_VOLUME_UP_BUTTON);
	m_Gui->AddTextArea(GUI_OPTIONS_SOUND_CURRENT_SOUND_VOLUME_TEXTAREA, g_SmallFont.get(), "0", 320, y, 0, 0);
	m_systemElementIds.push_back(GUI_OPTIONS_SOUND_CURRENT_SOUND_VOLUME_TEXTAREA);

	y += 20;

	m_Gui->AddTextArea(GUI_OPTIONS_RESOLUTION_LABEL, g_SmallFont.get(), "Resolution:", x, y, 0, 0,
	                   Color{ 255, 255, 255, 255 }, GuiTextArea::LEFT, 0, 1, true);
	m_systemElementIds.push_back(GUI_OPTIONS_RESOLUTION_LABEL);
	m_Gui->AddIconButton(GUI_OPTIONS_PREV_RESOLUTION_BUTTON, 300, y, g_LeftArrow);
	m_systemElementIds.push_back(GUI_OPTIONS_PREV_RESOLUTION_BUTTON);
	m_Gui->AddIconButton(GUI_OPTIONS_NEXT_RESOLUTION_BUTTON, 400, y, g_RightArrow);
	m_systemElementIds.push_back(GUI_OPTIONS_NEXT_RESOLUTION_BUTTON);
	m_Gui->AddTextArea(GUI_OPTIONS_CURRENT_RESOLUTION_TEXT_AREA, g_SmallFont.get(), "0", 320, y, 0, 0);
	m_systemElementIds.push_back(GUI_OPTIONS_CURRENT_RESOLUTION_TEXT_AREA);

	y += 20;

	m_Gui->AddTextArea(GUI_OPTIONS_FULLSCREEN_LABEL, g_SmallFont.get(), "Fullscreen:", x, y, 0, 0,
	                   Color{ 255, 255, 255, 255 }, GuiTextArea::LEFT, 0, 1, true);
	m_systemElementIds.push_back(GUI_OPTIONS_FULLSCREEN_LABEL);
	GuiCheckBox* fullscreenCheckBox = m_Gui->AddCheckBox(GUI_OPTIONS_FULLSCREEN_CHECKBOX, 320, y, 10, 10, 1, 1, GRAY, 0, true);
	fullscreenCheckBox->m_Selected = g_Engine->m_EngineConfig.GetNumber("full_screen") == 1;
	m_systemElementIds.push_back(GUI_OPTIONS_FULLSCREEN_CHECKBOX);

	y += 20;
	GuiTextArea* reso = m_Gui->AddTextArea(GUI_OPTIONS_CHANGE_RESOLUTION_NOTIFICATION_TEXT_AREA, g_SmallFont.get(), "", x, y, 0, 0);
	reso->m_Active = false;
	m_systemElementIds.push_back(GUI_OPTIONS_CHANGE_RESOLUTION_NOTIFICATION_TEXT_AREA);

	y += 30;
	m_Gui->AddStretchButton(GUI_OPTIONS_SAVE_GAME_BUTTON, 224, y, 70, "Save/Load",
	                        g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                        g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);
	m_systemElementIds.push_back(GUI_OPTIONS_SAVE_GAME_BUTTON);

	// ---- Gameplay tab content (same contentTop) ----
	m_gameplayElementIds.clear();
	y = contentTop;

	m_Gui->AddTextArea(GUI_OPTIONS_COMBAT_STYLE_LABEL, g_SmallFont.get(), "Combat Style:", x, y, 0, 0,
	                   Color{ 255, 255, 255, 255 }, GuiTextArea::LEFT, 0, 1, true);
	m_gameplayElementIds.push_back(GUI_OPTIONS_COMBAT_STYLE_LABEL);

	y += 22;
	constexpr int kCombatRadioGroup = 42;

	m_Gui->AddRadioButton(GUI_OPTIONS_COMBAT_STYLE_ORIGINAL, x, y, 10, 10, 1, 1, WHITE, kCombatRadioGroup, true);
	m_gameplayElementIds.push_back(GUI_OPTIONS_COMBAT_STYLE_ORIGINAL);
	m_Gui->AddTextArea(GUI_OPTIONS_COMBAT_STYLE_ORIGINAL_LABEL, g_SmallFont.get(), "Original", x + 16, y - 1, 0, 0,
	                   Color{ 255, 255, 255, 255 }, GuiTextArea::LEFT, 0, 1, true);
	m_gameplayElementIds.push_back(GUI_OPTIONS_COMBAT_STYLE_ORIGINAL_LABEL);

	y += 18;
	m_Gui->AddRadioButton(GUI_OPTIONS_COMBAT_STYLE_RTWP, x, y, 10, 10, 1, 1, WHITE, kCombatRadioGroup, true);
	m_gameplayElementIds.push_back(GUI_OPTIONS_COMBAT_STYLE_RTWP);
	m_Gui->AddTextArea(GUI_OPTIONS_COMBAT_STYLE_RTWP_LABEL, g_SmallFont.get(), "Real-Time-Pause", x + 16, y - 1, 0, 0,
	                   Color{ 255, 255, 255, 255 }, GuiTextArea::LEFT, 0, 1, true);
	m_gameplayElementIds.push_back(GUI_OPTIONS_COMBAT_STYLE_RTWP_LABEL);

	y += 18;
	m_Gui->AddRadioButton(GUI_OPTIONS_COMBAT_STYLE_TURN, x, y, 10, 10, 1, 1, WHITE, kCombatRadioGroup, true);
	m_gameplayElementIds.push_back(GUI_OPTIONS_COMBAT_STYLE_TURN);
	m_Gui->AddTextArea(GUI_OPTIONS_COMBAT_STYLE_TURN_LABEL, g_SmallFont.get(), "Turn-Based", x + 16, y - 1, 0, 0,
	                   Color{ 255, 255, 255, 255 }, GuiTextArea::LEFT, 0, 1, true);
	m_gameplayElementIds.push_back(GUI_OPTIONS_COMBAT_STYLE_TURN_LABEL);

	// Footer (always visible)
	y = 240;
	m_Gui->AddStretchButton(GUI_OPTIONS_BACK_TO_GAME_BUTTON, 260, y, 50, "Back",
	                        g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                        g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);
	m_Gui->AddStretchButton(GUI_OPTIONS_QUIT_GAME_BUTTON, 320, y, 50, "Quit",
	                        g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
	                        g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

	m_Gui->m_Active = true;
	m_Gui->m_Draggable = false;

	SyncCombatStyleRadios();
	SetActiveTab(OptionsTab::System);
}
