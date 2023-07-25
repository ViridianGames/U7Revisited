///////////////////////////////////////////////////////////////////////////
//
// Name:     MAIN.CPP
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  Contains the Windows-specific WinMain() function, which
//           defines the entry point of the program, and the WndProc()
//           function, which controls the handling of Windows-specific
//           events.  The WinMain() contains the game's main loop.
//
/////////////////////////////////////////////////////////////////////////// 

#include "Globals.h"
#include "U7Globals.h"
#include "MainState.h"
#include "TitleState.h"
#include "OptionsState.h"
#include <string>
#include <sstream>

using namespace std;

// WinMain

int main(int argv, char** argc)
{

   try
   {
      g_Engine = make_unique<Engine>();
      g_Engine->Init("Data/engine.cfg");
      
      //  Initialize globals
      g_Cursor = g_ResourceManager->GetTexture("Images/cursor.png");

      //Texture* g_Ground = g_ResourceManager->GetTexture("Images/Terrain/U7Baseplates/u7map8-3.png");

      g_DrawScale = float(g_Display->GetHeight()) / 768.0f;

      g_Font = make_shared<Font>();
      g_Font->Init("Data/Fonts/softsquare.ttf", 9 * g_DrawScale);

      g_SmallFont = make_shared<Font>();
      g_SmallFont->Init("Data/Fonts/babyblocks.ttf", 24 * g_DrawScale);

//      g_SmallFixedFont = new Font();
//      g_SmallFixedFont->Init("Data/Fonts/font8x8.txt");
//      g_SmallFixedFont->SetFixedWidth();

      g_VitalRNG = make_unique<RNG>();
      g_VitalRNG->SeedRNG(7777);//g_Engine->Time());
      g_NonVitalRNG = make_unique<RNG>();
      g_NonVitalRNG->SeedRNG(g_Engine->Time());

      Log("Creating terrain.");
      g_Terrain = make_unique<Terrain>();
      g_Terrain->Init("");
      Log("Done creating terrain.");

      //  Initialize states
      Log("Initializing states.");
      State* _titleState = new TitleState;
      _titleState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_TITLESTATE, _titleState);
      
      State* _mainState = new MainState;
      _mainState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_MAINSTATE, _mainState);

      State* _optionsState = new OptionsState;
      _optionsState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_OPTIONSSTATE, _optionsState);

      g_StateMachine->MakeStateTransition(STATE_TITLESTATE);

      Log("Starting main loop.");
      while (!g_Engine->m_Done)
      {
         g_Engine->Update();
         g_Engine->Draw();
      }
   }

   catch (string errorCode)
   {
      assert(errorCode.c_str());
   }

   if (g_Engine)
   {
      g_Engine.reset();
   }

   return 0;
}
