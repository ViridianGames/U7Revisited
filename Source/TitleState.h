#ifndef _TitleState_H_
#define _TitleState_H_

#include "Geist/State.h"
#include "Geist/Gui.h"
#include "U7Object.h"
#include <list>
#include <deque>
#include <math.h>

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

   GUI_TITLE_SCREEN_LAST
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
   void UpdateTitle();

   void TestUpdate();
   void TestDraw();
   
   Gui* m_TitleGui = nullptr;

   std::vector<std::shared_ptr<U7Object>> m_sortedVisibleObjects;

   float m_LastUpdate;

   bool m_mouseMoved;
   Texture* m_title;
};

#endif