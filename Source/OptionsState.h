#ifndef _OptionsState_H_
#define _OptionsState_H_

#include "Geist/State.h"
#include <list>
#include <deque>
#include <math.h>
#include <vector>

#include "Gui.h"

enum OptionGuiElements
{
	GUI_OPTIONS_PANEL,
	GUI_OPTIONS_TITLE,

	GUI_OPTIONS_TAB_SYSTEM,
	GUI_OPTIONS_TAB_GAMEPLAY,

	GUI_OPTIONS_MUSIC_LABEL,
	GUI_OPTIONS_MUSIC_VOLUME_UP_BUTTON,
	GUI_OPTIONS_MUSIC_CURRENT_MUSIC_VOLUME_TEXTAREA,
	GUI_OPTIONS_MUSIC_VOLUME_DOWN_BUTTON,

	GUI_OPTIONS_SOUND_LABEL,
	GUI_OPTIONS_SOUND_VOLUME_UP_BUTTON,
	GUI_OPTIONS_SOUND_CURRENT_SOUND_VOLUME_TEXTAREA,
	GUI_OPTIONS_SOUND_VOLUME_DOWN_BUTTON,

	GUI_OPTIONS_RESOLUTION_LABEL,
	GUI_OPTIONS_PREV_RESOLUTION_BUTTON,
	GUI_OPTIONS_CURRENT_RESOLUTION_TEXT_AREA,
	GUI_OPTIONS_CHANGE_RESOLUTION_NOTIFICATION_TEXT_AREA,
	GUI_OPTIONS_NEXT_RESOLUTION_BUTTON,

	GUI_OPTIONS_FULLSCREEN_LABEL,
	GUI_OPTIONS_FULLSCREEN_CHECKBOX,
	GUI_OPTIONS_SAVE_GAME_BUTTON,
	GUI_OPTIONS_LOAD_GAME_BUTTON,
	GUI_OPTIONS_BACK_TO_GAME_BUTTON,
	GUI_OPTIONS_QUIT_GAME_BUTTON,

	GUI_OPTIONS_COMBAT_STYLE_LABEL,
	GUI_OPTIONS_COMBAT_STYLE_ORIGINAL,
	GUI_OPTIONS_COMBAT_STYLE_ORIGINAL_LABEL,
	GUI_OPTIONS_COMBAT_STYLE_RTWP,
	GUI_OPTIONS_COMBAT_STYLE_RTWP_LABEL,
	GUI_OPTIONS_COMBAT_STYLE_TURN,
	GUI_OPTIONS_COMBAT_STYLE_TURN_LABEL,
};

enum class OptionsTab
{
	System = 0,
	Gameplay = 1,
};

class OptionsState : public State
{
public:
	OptionsState() { m_RenderStack = true; m_DrawCursor = true; }
	~OptionsState();

	virtual void Init(const std::string& configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	virtual void OnEnter();
	virtual void OnExit();

	void CreateOptionsGUI();
	void SetActiveTab(OptionsTab tab);
	void SyncCombatStyleRadios();
	void ApplyCombatStyleFromRadios();

	std::shared_ptr<Gui> m_Gui = nullptr;

	int m_newDrawScale = 1;
	bool m_openedFromTitle = false;
	OptionsTab m_activeTab = OptionsTab::System;

	std::vector<int> m_systemElementIds;
	std::vector<int> m_gameplayElementIds;
};

#endif
