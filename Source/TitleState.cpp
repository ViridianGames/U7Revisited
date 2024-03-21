#include "Globals.h"
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
   g_Display->ClearScreen();

   m_TitleGui->Draw();
   
   DrawConsole();
   
   g_Display->DrawImage(g_Cursor, g_Input->m_MouseX, g_Input->m_MouseY);

}

////////////////////////////////////////////////////////////////////////////////
///  CREATORS
////////////////////////////////////////////////////////////////////////////////

void TitleState::CreateTitleGUI()
{
   m_TitleGui = new Gui();
   m_TitleGui->m_Scale = g_DrawScale;
   m_TitleGui->m_Font = g_SmallFont;
   m_TitleGui->SetLayout(0, 0, 320, 180, Gui::GUIP_CENTER);
   m_TitleGui->AddOctagonBox(GUI_TITLE_PANEL2, 110, 90, 100, 80, g_Borders);
   //m_TitleGui->AddPanel(GUI_TITLE_PANEL1, 0, 0, 138, 384, Color(0, 0, 0, .75));
   //m_TitleGui->AddPanel(GUI_TITLE_PANEL2, 0, 0, 320, 180, Color(1, 1, 1, 1), false);
   m_TitleGui->AddTextArea(GUI_TITLE_TITLE, g_Font.get(), "Ultima VII: Revisited", (320 - (g_Font->GetStringMetrics("Ultima VII: Revisited"))) / 2, 20, (g_Font->GetStringMetrics("Ultima VII: Revisited")), 0, Color(1, 1, 1, 1), true);

   //m_Gui->AddStretchButton(GE_AWARDS_EXITBTN, scrWid - (4 * 158 + 77) / 2 - 600 / 2 - 5, 768 - 5 - g_Font->GetHeight(), 600, "Exit to Menu",
   //   g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
   //   g_InactiveButtonL, g_InactiveButtonR, g_InactiveButtonM, 37);

   m_TitleGui->AddStretchButton(GUI_TITLE_BUTTON_SINGLE_PLAYER, (320 - (g_SmallFont->GetStringMetrics("Begin") / g_DrawScale * 1.5f)) / 2, 95, g_SmallFont->GetStringMetrics("Begin") / g_DrawScale * 1.5f, "Begin",
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   m_TitleGui->AddStretchButton(GUI_TITLE_BUTTON_OBJECT_EDITOR, (320 - (g_SmallFont->GetStringMetrics("Object Editor") / g_DrawScale * 1.5f)) / 2, 115, g_SmallFont->GetStringMetrics("Object Editor") / g_DrawScale * 1.5f, "Object Editor",
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   m_TitleGui->AddStretchButton(GUI_TITLE_BUTTON_WORLD_EDITOR, (320 - (g_SmallFont->GetStringMetrics("World Editor") / g_DrawScale * 1.5f)) / 2, 135, g_SmallFont->GetStringMetrics("World Editor") / g_DrawScale * 1.5f, "World Editor",
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   m_TitleGui->AddStretchButton(GUI_TITLE_BUTTON_QUIT, (320 - (g_SmallFont->GetStringMetrics("Quit") / g_DrawScale * 1.5f)) / 2, 155, g_SmallFont->GetStringMetrics("Quit") / g_DrawScale * 1.5f, "Quit",
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);


   //m_TitleGui->AddStretchButton(GUI_TITLE_BUTTON_OBJECT_EDITOR, (320 - (g_SmallFont->GetStringMetrics("Object Editor"))) / 2, 115, "Object Editor", g_SmallFont.get());
   //m_TitleGui->AddStretchButton(GUI_TITLE_BUTTON_WORLD_EDITOR, (320 - (g_SmallFont->GetStringMetrics("World Editor"))) / 2, 130, "World Editor", g_SmallFont.get());
   //m_TitleGui->AddStretchButton(GUI_TITLE_BUTTON_QUIT, (320 - (g_SmallFont->GetStringMetrics("Quit"))) / 2, 150, "Quit", g_SmallFont.get());
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
//      g_Server = new Server();
//      g_Server->Init("");
//      g_Client = new Client();
//      g_Client->Init("");
//      if(g_Client->Connect("127.0.0.1", g_Engine->m_EngineConfig["port"].numdata))
//      {
         //g_Server->m_NumberOfConnectedClients += 1;
      //}
      g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
   }
   
   if(m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_OBJECT_EDITOR)
   {
//      g_Server = new Server();
//      g_Server->Init("");
//      g_Client = new Client();
//      g_Client->Init("");
//      if(g_Client->Connect("127.0.0.1", g_Engine->m_EngineConfig["port"].numdata))
//      {
//         g_Server->m_NumberOfConnectedClients += 1;
//      }
      g_StateMachine->MakeStateTransition(STATE_OBJECTEDITORSTATE);
   }

   if(m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_WORLD_EDITOR)
   {
//      g_Client = new Client();
//      g_Client->Init("");
      g_StateMachine->MakeStateTransition(STATE_WORLDEDITORSTATE);
      
   }
}