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
   CreateTitleGUI();
}

void TitleState::OnEnter()
{

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
   m_TitleGui->SetLayout(0, 0, 138, 384, Gui::GUIP_CENTER);
   m_TitleGui->AddPanel(GUI_TITLE_PANEL1, 0, 0, 138, 384, Color(0, 0, 0, .75));
   m_TitleGui->AddPanel(GUI_TITLE_PANEL2, 0, 0, 138, 384, Color(1, 1, 1, 1), false);
   m_TitleGui->AddTextArea(GUI_TITLE_TITLE, g_SmallFont.get(), "Planitia", m_TitleGui->m_Width / 2, 60, 0, 0, Color(1, 1, 1, 1), true);
   m_TitleGui->AddTextButton(GUI_TITLE_BUTTON_SINGLE_PLAYER, (138 - (g_SmallFont->GetStringMetrics("Single Player") + 4)) / 2, 120, "Single Player", g_SmallFont.get());
   m_TitleGui->AddTextButton(GUI_TITLE_BUTTON_MULTIPLAYER_SERVER, (138 - (g_SmallFont->GetStringMetrics("Multiplayer Server") + 4)) / 2, 140, "Multiplayer Server", g_SmallFont.get());
   m_TitleGui->AddTextButton(GUI_TITLE_BUTTON_MULTIPLAYER_CLIENT, (138 - (g_SmallFont->GetStringMetrics("Multiplayer Client") + 4)) / 2, 160, "Multiplayer Client", g_SmallFont.get());
   m_TitleGui->AddTextButton(GUI_TITLE_BUTTON_QUIT, (138 - (g_SmallFont->GetStringMetrics("Quit") + 4)) / 2, 210, "Quit", g_SmallFont.get());
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
      g_IsSinglePlayer = true;
      g_IsServer = true;
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
   
   if(m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_MULTIPLAYER_SERVER)
   {
      g_IsSinglePlayer = false;
      g_IsServer = true;
//      g_Server = new Server();
//      g_Server->Init("");
//      g_Client = new Client();
//      g_Client->Init("");
//      if(g_Client->Connect("127.0.0.1", g_Engine->m_EngineConfig["port"].numdata))
//      {
//         g_Server->m_NumberOfConnectedClients += 1;
//      }
   }

   if(m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_MULTIPLAYER_CLIENT)
   {
      g_IsSinglePlayer = false;
      g_IsServer = false;
//      g_Client = new Client();
//      g_Client->Init("");
      
   }
}