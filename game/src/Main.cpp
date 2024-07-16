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

#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/Primitives.h"
#include "Geist/Logging.h"
#include "raylib.h"
#include "U7Globals.h"
#include "MainState.h"
#include "TitleState.h"
#include "OptionsState.h"
#include "LoadingState.h"
#include "ObjectEditorState.h"
#include "WorldEditorState.h"
#include "ShapeData.h"
#include <string>
#include <sstream>
#include <memory>

using namespace std;

int main(int argv, char** argc)
{
    SetTraceLogCallback(LoggingCallback);

   try
   {
      g_Engine = make_unique<Engine>();
      g_Engine->Init("Data/engine.cfg");

      g_cameraDistance = g_Engine->m_EngineConfig.GetNumber("camera_close_limit");
      g_cameraRotation = 0.0f;

      g_camera.target = Vector3 { 1071.0f, 0.0f, 2209.0f };
      g_camera.position = Vector3Add(g_camera.target, Vector3{ g_cameraDistance, g_cameraDistance, g_cameraDistance });
      g_camera.up = Vector3 { 0.0f, 1.0f, 0.0f };
      g_camera.fovy = g_cameraDistance;
      g_camera.projection = CAMERA_ORTHOGRAPHIC;

      RenderTexture2D m_renderTarget = LoadRenderTexture(640, 360);

      //BeginDrawing();

      //ClearBackground(BLACK);

      //EndDrawing();

      //  Initialize globals
      g_Cursor = g_ResourceManager->GetTexture("Images/pointer.png");

      //Texture* g_Ground = g_ResourceManager->GetTexture("Images/Terrain/U7Baseplates/u7map8-3.png");

      g_DrawScale = float(GetRenderHeight()) / 180.0f;

      g_smallFontSize = static_cast<int>(8 * g_DrawScale) - (static_cast<int>(8 * g_DrawScale) % 8);
      g_fontSize = g_smallFontSize * 2;

      Font font = LoadFontEx("Data/Fonts/babyblocks.ttf", g_fontSize, NULL, 0);
      g_Font = make_shared<Font>(font);

      Font smallFont = LoadFontEx("Data/Fonts/babyblocks.ttf", g_smallFontSize, NULL, 0);
      g_SmallFont = make_shared<Font>(smallFont);

      g_VitalRNG = make_unique<RNG>();
      g_VitalRNG->SeedRNG(7777);//GetTime());
      g_NonVitalRNG = make_unique<RNG>();
      g_NonVitalRNG->SeedRNG(GetTime());

      Log("Creating terrain.");
      g_Terrain = make_unique<Terrain>();

      //  Create GUI elements
      g_BoxTL = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 0, 0, 2, 2);
      g_BoxT = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false),  2, 0, 2, 2);
      g_BoxTR = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 4, 0, 2, 2);
      g_BoxL = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false),  0, 2, 2, 2);
      g_BoxC = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false),  2, 2, 2, 2);
      g_BoxR = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false),  4, 2, 2, 2);
      g_BoxBL = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 0, 4, 2, 2);
      g_BoxB = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false),  2, 4, 2, 2);
      g_BoxBR = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 4, 4, 2, 2);

      g_Borders.push_back(g_BoxTL);
      g_Borders.push_back(g_BoxT);
      g_Borders.push_back(g_BoxTR);
      g_Borders.push_back(g_BoxL);
      g_Borders.push_back(g_BoxC);
      g_Borders.push_back(g_BoxR);
      g_Borders.push_back(g_BoxBL);
      g_Borders.push_back(g_BoxB);
      g_Borders.push_back(g_BoxBR);

      g_InactiveButtonL = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 15, 0, 3, 11);
      g_InactiveButtonM = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 18, 0, 1, 11);
      g_InactiveButtonR = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 19, 0, 3, 11);
      g_ActiveButtonL = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 7, 0, 3, 11);
      g_ActiveButtonM = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 10, 0, 1, 11);
      g_ActiveButtonR = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 11, 0, 3, 11);

      g_LeftArrow = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 67, 0, 8, 9);
      g_RightArrow = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 76, 0, 8, 9);

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

      State* loadingState = new LoadingState;
      loadingState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_LOADINGSTATE, loadingState);

      State* objectEditorState = new ObjectEditorState;
      objectEditorState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_OBJECTEDITORSTATE, objectEditorState);

      State* worldEditorState = new WorldEditorState;
      worldEditorState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_WORLDEDITORSTATE, worldEditorState);


      g_StateMachine->MakeStateTransition(STATE_LOADINGSTATE);

      Log("Starting main loop.");
      while (!g_Engine->m_Done)
      {
         g_Engine->Update();
         g_Engine->Draw();
      }
   }

   catch (string errorCode)
   {
      Log(errorCode, LOG_ERROR);
      exit(0);
   }

   if (g_Engine)
   {
      g_Engine.reset();
   }

   return 0;
}