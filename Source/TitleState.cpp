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
    g_TestMesh = g_ResourceManager->GetMesh("Data/Meshes/standard.txt");

    g_Sprites = g_ResourceManager->GetTexture("Images/sprites.png");

    g_Cursor = g_ResourceManager->GetTexture("Images/cursor.png");

    g_minimapSize = g_Display->GetWidth() / 6;

    g_WalkerTexture = g_ResourceManager->GetTexture("Images/VillagerWalkFixed.png", false);
    g_WalkerMask = g_ResourceManager->GetTexture("Images/VillagerWalkMask.png", false);
    MakeAnimationFrameMeshes();

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
   m_TitleGui->SetLayout(0, 0, 138, 640, Gui::GUIP_CENTER);
   m_TitleGui->AddPanel(GUI_TITLE_PANEL1, 0, 0, 138, 384, Color(0, 0, 0, .75));
   m_TitleGui->AddPanel(GUI_TITLE_PANEL2, 0, 0, 138, 384, Color(1, 1, 1, 1), false);
   m_TitleGui->AddTextArea(GUI_TITLE_TITLE, g_SmallFont.get(), "Ultima VII: Revisited", (g_Display->GetWidth() - (g_SmallFont->GetStringMetrics("Ultima VII: Revisited"))) / 2, 60, g_Display->GetWidth() / 2, 0, Color(1, 1, 1, 1), true);
   m_TitleGui->AddTextButton(GUI_TITLE_BUTTON_SINGLE_PLAYER, (138 - (g_SmallFont->GetStringMetrics("Begin") + 4)) / 2, 240, "Begin", g_SmallFont.get());
   m_TitleGui->AddTextButton(GUI_TITLE_BUTTON_QUIT, (138 - (g_SmallFont->GetStringMetrics("Quit") + 4)) / 2, 280, "Quit", g_SmallFont.get());
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