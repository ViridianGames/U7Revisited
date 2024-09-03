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
   TestUpdate();
}


void TitleState::Draw()
{
   BeginDrawing();

   ClearBackground(Color {0, 0, 0, 255});

   m_TitleGui->Draw();
   
   DrawConsole();

   //TestDraw();

   DrawTexture(*g_Cursor, GetMouseX(), GetMouseY(), WHITE);

   EndDrawing();
}

////////////////////////////////////////////////////////////////////////////////
///  CREATORS
////////////////////////////////////////////////////////////////////////////////

void TitleState::CreateTitleGUI()
{
   m_TitleGui = new Gui();
   m_TitleGui->m_Font = g_Font;
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
}

void TitleState::TestUpdate()
{
   ModTexture& modTexture = *g_shapeTable[150][0].m_topTexture;
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
   DrawTexture(g_shapeTable[150][0].m_topTexture->m_Texture, 0, 0, WHITE);
}