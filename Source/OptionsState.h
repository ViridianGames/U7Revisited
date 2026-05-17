#ifndef _OptionsState_H_
#define _OptionsState_H_

#include "Geist/State.h"
#include <list>
#include <deque>
#include <math.h>

#include "Gui.h"

enum OptionGuiElements
{
   GUI_OPTIONS_PANEL,
   GUI_OPTIONS_TITLE,

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
};

class OptionsState : public State
{
public:
   OptionsState(){};
   ~OptionsState();


   virtual void Init(const std::string& configfile);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw();

   virtual void OnEnter();
   virtual void OnExit();

   void CreateOptionsGUI();

   std::shared_ptr<Gui> m_Gui = nullptr;

   int m_newDrawScale = 1;

};

#endif