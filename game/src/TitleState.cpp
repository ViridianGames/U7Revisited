#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/StateMachine.h"
#include "U7Globals.h"
#include "TitleState.h"

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
    MakeAnimationFrameMeshes();

   CreateTitleGUI();
}

void TitleState::OnEnter()
{
   ClearConsole();
}

void TitleState::OnExit()
{

}

void TitleState::Shutdown()
{

}

void TitleState::Update()
{
   UpdateTitle();
   //g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
}


void TitleState::Draw()
{
   ClearBackground(Color {0, 0, 0, 255});

   m_TitleGui->Draw();
   
   DrawConsole();

   DrawTexture(*g_shapeTable[m_shape][m_frame].GetTexture(), 0, 0, WHITE);

   //DrawTexture(g_Terrain->m_TerrainTexture, 0, 0, WHITE);

   DrawTexture(*g_Cursor, GetMouseX(), GetMouseY(), WHITE);
}

////////////////////////////////////////////////////////////////////////////////
///  CREATORS
////////////////////////////////////////////////////////////////////////////////

void TitleState::CreateTitleGUI()
{
   m_TitleGui = new Gui();
   m_TitleGui->m_Font = g_SmallFont;
   m_TitleGui->SetLayout(0, 0, 320, 180, g_DrawScale, Gui::GUIP_CENTER);
   m_TitleGui->AddOctagonBox(GUI_TITLE_PANEL2, 110, 90, 100, 80, g_Borders);
   m_TitleGui->AddTextArea(GUI_TITLE_TITLE, g_Font.get(), "Ultima VII: Revisited", (320 - (MeasureText("Ultima VII: Revisited", g_Font->baseSize * g_DrawScale))) / 2, 20,
      (MeasureText("Ultima VII: Revisited", g_Font->baseSize * g_DrawScale)), 0, Color{255, 255, 255, 255}, true);

   m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_SINGLE_PLAYER, 95, "Begin",
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_OBJECT_EDITOR, 115, "Object Editor",
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_WORLD_EDITOR, 135, "World Editor",
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_QUIT, 155, "Quit",
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   m_TitleGui->m_Active = true;
}

////////////////////////////////////////////////////////////////////////////////
///  UPDATERS
////////////////////////////////////////////////////////////////////////////////

void TitleState::UpdateTitle()
{
   m_TitleGui->Update();
   
   if(!m_TitleGui->m_Active)
      return;
   
   if(m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_QUIT)
   {
      g_Engine->m_Done = true;
   }
   
   if(m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_SINGLE_PLAYER)
   {
      g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
   }
   
   if(m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_OBJECT_EDITOR)
   {
      g_StateMachine->MakeStateTransition(STATE_OBJECTEDITORSTATE);
   }

   if(m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_WORLD_EDITOR)
   {
      g_StateMachine->MakeStateTransition(STATE_WORLDEDITORSTATE);
      
   }

   if (IsKeyPressed(KEY_ESCAPE))
   {
		g_Engine->m_Done = true;
	}

   if (IsKeyPressed(KEY_A))
   {
		++m_shape;
      m_frame = 0;
      if(m_shape >= 1024)
         m_shape = 150;
	}

   if (IsKeyPressed(KEY_D))
   {
		--m_shape;
      m_frame = 0;
		if(m_shape < 150)
			m_shape = 1023;
	}

   if (IsKeyPressed(KEY_W))
   {
      int newFrame = m_frame + 1;
      if (newFrame > 31)
      {
         newFrame = 0;
      }

      if (g_shapeTable[m_shape][newFrame].IsValid())
      {
         m_frame = newFrame;
      }
	}

   if (IsKeyPressed(KEY_S))
   {
      int newFrame = m_frame - 1;
      if (newFrame < 0)
      {
         newFrame = 31;
      }

      if (g_shapeTable[m_shape][newFrame].IsValid())
      {
         m_frame = newFrame;
      }
	}
}