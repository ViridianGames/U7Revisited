#ifndef _TitleState_H_
#define _TitleState_H_

#include "Geist/State.h"
#include "Geist/Gui.h"
#include "Geist/GuiManager.h"
#include <list>
#include <deque>
#include <math.h>

class GuiManager;

enum GUIIDS
{
   GUI_TITLE_PANEL1 = 0,
   GUI_TITLE_PANEL2,
   GUI_TITLE_TITLE,
   GUI_TITLE_BUTTON_SINGLE_PLAYER,
   GUI_TITLE_BUTTON_SHAPE_EDITOR,
   GUI_TITLE_BUTTON_OBJECT_EDITOR,
   GUI_TITLE_BUTTON_WORLD_EDITOR,
   GUI_TITLE_BUTTON_OPTIONS,
   GUI_TITLE_BUTTON_QUIT,
   GUI_TITLE_BUTTON_CREDITS,
   GUI_TITLE_BUTTON_X,
   GUI_TITLE_BUTTON_YOUTUBE,
   GUI_TITLE_BUTTON_PATREON,
   GUI_TITLE_BUTTON_KOFI,
   GUI_TITLE_BUTTON_GITHUB,

   GUI_TITLE_SCREEN_LAST
};

enum CREDITSIDS
{
   GUI_CREDITS_PANEL = 0,
   GUI_CREDITS_BUTTON_BACK,
   GUI_CREDITS_TITLE,
   GUI_CREDITS_SCREEN_LAST = 1000
};

class TitleState : public State
{
public:
   TitleState(){};
   ~TitleState();


   virtual void Init(const std::string& configfile);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw();

   virtual void OnEnter();
   virtual void OnExit();
   
   void CreateTitleGUI();
   void CreateCreditsGUI();
   void UpdateTitle();

   void TestUpdate();
   void TestDraw();
   
   std::shared_ptr<Gui> m_TitleGui;
   std::shared_ptr<Gui> m_CreditsGui;

   float m_LastUpdate;

   bool m_mouseMoved;
   Texture* m_title;
};

#endif