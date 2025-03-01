///////////////////////////////////////////////////////////////////////////
//
// Name:     MAIN.CPP
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  Contains the entry point for the program.
//
/////////////////////////////////////////////////////////////////////////// 

#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/Primitives.h"
#include "Geist/GuiManager.h"
#include "Geist/Logging.h"
#include "raylib.h"
#include "U7Globals.h"
#include "MainState.h"
#include "TitleState.h"
#include "OptionsState.h"
#include "LoadingState.h"
#include "ObjectEditorState.h"
#include "ShapeEditorState.h"
#include "WorldEditorState.h"
#include "ShapeData.h"
#include <string>
#include <sstream>
#include <memory>

#include "rlgl.h"

using namespace std;

int main(int argv, char** argc)
{
    SetTraceLogCallback(LoggingCallback);

   try
   {
      g_Engine = make_unique<Engine>();
      g_Engine->Init("Data/engine.cfg");

      g_alphaDiscard = LoadShader(NULL, "Data/Shaders/alphaDiscard.fs");

      rlDisableBackfaceCulling();
      rlEnableDepthTest();
      

      g_cameraDistance = g_Engine->m_EngineConfig.GetNumber("camera_close_limit");
      g_cameraRotation = 0.0f;

      //  Pick a random initial location
      g_VitalRNG = make_unique<RNG>();
      g_VitalRNG->SeedRNG(GetTime() * 1000);
      int x = g_VitalRNG->Random(7);

      switch (x)
      {
         case 0: //  Staring Location
			   g_camera.target = Vector3{ 1071.0f, 0.0f, 2209.0f };
			   break;

         case 1: //  Museum
            g_camera.target = Vector3{ 896.0f, 0.0f, 1328.0f };
            break;

         case 2: //  Moongate
            g_camera.target = Vector3{ 1025.0f, 0.0f, 2433.0f };
            break;
         
         case 3:
            g_camera.target = Vector3{ 294.0f, 0.0f, 1675.0f };
			   break;

         case 4:
            g_camera.target = Vector3{ 2192.0f, 0.0f, 1487.0f };
            break;

         case 5:
            g_camera.target = Vector3{ 1549.0f, 0.0f, 1287.0f };
            break;

         case 6:
            g_camera.target = Vector3{ 1064.0f, 0.0f, 2247.0f };
            break;

         case 7:
            g_camera.target = Vector3{ 965.0f, 0.0f, 2291.0f };
            break;

         default:
            g_camera.target = Vector3{ 1071.0f, 0.0f, 2209.0f };
            break;
      }

      g_camera.position = Vector3Add(g_camera.target, Vector3{ g_cameraDistance, g_cameraDistance, g_cameraDistance });
      g_camera.up = Vector3 { 0.0f, 1.0f, 0.0f };
      g_camera.fovy = g_cameraDistance;
      g_camera.projection = CAMERA_ORTHOGRAPHIC;

      //  Initialize globals
      g_Cursor = g_ResourceManager->GetTexture("Images/pointer.png");

      g_DrawScale = g_Engine->m_ScreenHeight / g_Engine->m_RenderHeight;

      float baseFontSize = 9;
      const char* fontPath = "Data/Fonts/softsquare.ttf";
      // const char* fontPath = "Data/Fonts/babyblocks.ttf";

      g_fontSize = baseFontSize * int(g_DrawScale);
      Font font = LoadFontEx(fontPath, g_fontSize, NULL, 0);
      g_Font = make_shared<Font>(font);

      Font smallFont = LoadFontEx(fontPath, baseFontSize, NULL, 0);
      g_SmallFont = make_shared<Font>(smallFont);

      g_renderTarget = LoadRenderTexture(g_Engine->m_RenderWidth, g_Engine->m_RenderHeight);
      SetTextureFilter(g_renderTarget.texture, RL_TEXTURE_FILTER_ANISOTROPIC_4X);
      g_guiRenderTarget = LoadRenderTexture(g_Engine->m_RenderWidth, g_Engine->m_RenderHeight);
      SetTextureFilter(g_guiRenderTarget.texture, RL_TEXTURE_FILTER_ANISOTROPIC_4X);

      g_VitalRNG = make_unique<RNG>();
      g_VitalRNG->SeedRNG(7777);
      g_NonVitalRNG = make_unique<RNG>();
      g_NonVitalRNG->SeedRNG(int(GetTime() * 1000));

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

      g_InactiveButtonL = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 15, 0, 4, 11);
      g_InactiveButtonM = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 18, 0, 1, 11);
      g_InactiveButtonR = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 19, 0, 4, 11);
      g_ActiveButtonL = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 7, 0, 4, 11);
      g_ActiveButtonM = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 10, 0, 1, 11);
      g_ActiveButtonR = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 11, 0, 4, 11);

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

      State* shapeEditorState = new ShapeEditorState;
      shapeEditorState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_SHAPEEDITORSTATE, shapeEditorState);

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