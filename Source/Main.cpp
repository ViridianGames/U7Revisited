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
#include "Geist/ScriptingSystem.h"
#include "Geist/Logging.h"
#include "raylib.h"
#include "U7Globals.h"
#include "U7LuaFuncs.h"
#include "MainState.h"
#include "TitleState.h"
#include "OptionsState.h"
#include "LoadingState.h"
#include "ObjectEditorState.h"
#include "ShapeEditorState.h"
#include "WorldEditorState.h"
#include "ConversationState.h"
#include "ShapeData.h"
#include "GumpManager.h"
#include <string>
#include <sstream>
#include <memory>
#include <filesystem>

#include "rlgl.h"

using namespace std;
using namespace std::filesystem;

int main(int argv, char** argc)
{
   try
   {
      g_Engine = make_unique<Engine>();
      g_Engine->Init("Data/engine.cfg");

      g_alphaDiscard = LoadShader(NULL, "Data/Shaders/alphaDiscard.fs");

      rlDisableBackfaceCulling();
      rlEnableDepthTest();

      g_cameraDistance = 26;
      g_cameraRotation = 0.0f;

      //  Pick a random initial location
      g_VitalRNG = make_unique<RNG>();
      int seed = (unsigned int)time(NULL);
      g_VitalRNG->SeedRNG(seed);
      int x = g_VitalRNG->Random(7);

      switch (x)
      {
         case 0: //  Starting Location
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

      g_Player = make_unique<U7Player>();

      g_camera.position = Vector3Add(g_camera.target, Vector3{ g_cameraDistance, g_cameraDistance, g_cameraDistance });
      g_camera.up = Vector3 { 0.0f, 1.0f, 0.0f };
      g_camera.fovy = g_cameraDistance;
      g_camera.projection = CAMERA_ORTHOGRAPHIC;

      //  Initialize globals
      g_Cursor = g_ResourceManager->GetTexture("Images/pointer.png");

      g_DrawScale = g_Engine->m_ScreenHeight / g_Engine->m_RenderHeight;

      float baseFontSize = 9;
      const char* fontPath = "Data/Fonts/softsquare.ttf";
      //const char* fontPath = "Data/Fonts/babyblocks.ttf";

      g_fontSize = baseFontSize * int(g_DrawScale);
      Font font = LoadFontEx(fontPath, g_fontSize, NULL, 0);
      g_Font = make_shared<Font>(font);

      Font smallFont = LoadFontEx(fontPath, baseFontSize, NULL, 0);
      g_SmallFont = make_shared<Font>(smallFont);

      const char* conversationFontPath = "Data/Fonts/lantern.ttf"; float conversationFontSize = 18;
      //const char* conversationFontPath = "Data/Fonts/magicbook.ttf"; float conversationFontSize = 24;
      //const char* conversationFontPath = "Data/Fonts/curse.ttf"; float conversationFontSize = 28;
      //const char* conversationFontPath = "Data/Fonts/softsquare.ttf"; float conversationFontSize = 18;
      Font conversationFont = LoadFontEx(conversationFontPath, conversationFontSize, NULL, 0);
      g_ConversationFont = make_shared<Font>(conversationFont);

      const char* guiFontPath = "Data/Fonts/babyblocks.ttf"; float guiFontSize = 8;
      Font guiFont = LoadFontEx(guiFontPath, guiFontSize, NULL, 0);
      g_guiFont = make_shared<Font>(guiFont);


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
      g_Borders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 0, 0, 2, 2));
      g_Borders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false),  2, 0, 2, 2));
      g_Borders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 4, 0, 2, 2));
      g_Borders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false),  0, 2, 2, 2));
      g_Borders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false),  2, 2, 2, 2));
      g_Borders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false),  4, 2, 2, 2));
      g_Borders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 0, 4, 2, 2));
      g_Borders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false),  2, 4, 2, 2));
      g_Borders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 4, 4, 2, 2));

      g_ConversationBorders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 0, 28, 8, 8));
      g_ConversationBorders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 8, 28, 8, 8));
      g_ConversationBorders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 16, 28, 8, 8));
      g_ConversationBorders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 0, 36, 8, 8));
      g_ConversationBorders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 8, 36, 8, 8));
      g_ConversationBorders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 16, 36, 8, 8));
      g_ConversationBorders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 0, 42, 8, 8));
      g_ConversationBorders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 8, 42, 8, 8));
      g_ConversationBorders.push_back(make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 16, 42, 8, 8));

      g_InactiveButtonL = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 15, 0, 4, 12);
      g_InactiveButtonM = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 18, 0, 1, 12);
      g_InactiveButtonR = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 19, 0, 4, 12);
      g_ActiveButtonL = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 7, 0, 4, 12);
      g_ActiveButtonM = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 10, 0, 1, 12);
      g_ActiveButtonR = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 11, 0, 4, 12);

      g_LeftArrow = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 67, 0, 8, 9);
      g_RightArrow = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 76, 0, 8, 9);

      g_gumpBackground = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/gumps.png", false), 166, 177, 145, 102);

      //g_gumpCheckmarkUp = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/gumps.png", false), 334, 12, 21, 21);
      //g_gumpCheckmarkDown = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/gumps.png", false), 334, 52, 21, 21);
      g_gumpCheckmarkUp = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/biggumps.png", false), 501, 18, 32, 32);
      g_gumpCheckmarkDown = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/biggumps.png", false), 501, 78, 32, 32);

      g_gumpNumberBarBackground = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/gumps.png", false), 489, 176, 133, 21);
      g_gumpNumberBarMarker = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/gumps.png", false), 625, 175, 10, 10);
      g_gumpNumberBarRightArrow = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/gumps.png", false), 638, 175, 10, 10);
      g_gumpNumberBarLeftArrow = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/gumps.png", false), 651, 175, 10, 10);

      g_XButton = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 128, 0, 20, 20);
      g_GitHubButton = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 148, 0, 16, 16);

      Image image = LoadImage("Images/GUI/gumps.png");
      g_statsBackground = make_shared<Texture2D>(LoadTextureFromImage(ImageFromImage(image, {233, 436, 133, 136})));
      UnloadImage(image);

      g_CuboidModel = nullptr;
      
      //  Initialize scripts

      string directoryPath("Data/Scripts");
      g_ScriptingSystem->LoadScript(directoryPath + "global_flags_and_constants.lua");

      for (const auto& entry : directory_iterator(directoryPath))
      {
           if (entry.is_regular_file())
         {
               std::string ext = entry.path().extension().string();
   
               if (ext == ".lua")
            {
                   std::string filepath = entry.path().string();
                  g_ScriptingSystem->LoadScript(filepath);
               }
           }
       }

       g_ScriptingSystem->LoadScript("Data/Scripts/erethian.lua");

      g_ScriptingSystem->SortScripts();

      RegisterAllLuaFunctions();

      //  Make walk frames
		//g_ResourceManager->GetTexture("Images/VillagerWalkFixed.png", false);

		Image frames = LoadImage("Images/VillagerWalkFixed.png");

      g_scheduleTime = 0;
      g_hour = 0;
      g_minute = 0;
		g_secsPerMinute = 2.0f;

      for(int i = 0; i < 8; i++)
      {
         std::vector<Texture> thisVector;
			thisVector.resize(8);
			g_walkFrames.push_back(thisVector);
		}

      for(int i = 0; i < 8; i++)
      {
         for(int j = 0; j < 8; j++)
         {
				Image img = ImageFromImage(frames, Rectangle{j * 128.0f, i * 128.0f, 128, 128});
            g_walkFrames[i][j] = LoadTextureFromImage(img);
				UnloadImage(img);
         }
		}

      g_gumpManager = make_unique<GumpManager>();

      //  Initialize states
      Log("Initializing states.");
      State* _titleState = new TitleState;
      _titleState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_TITLESTATE, _titleState, "TITLE_STATE");
      
      State* _mainState = new MainState;
      _mainState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_MAINSTATE, _mainState, "MAIN_STATE");

      State* _optionsState = new OptionsState;
      _optionsState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_OPTIONSSTATE, _optionsState, "OPTIONS_STATE");

      State* loadingState = new LoadingState;
      loadingState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_LOADINGSTATE, loadingState, "LOADING_STATE");

      State* objectEditorState = new ObjectEditorState;
      objectEditorState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_OBJECTEDITORSTATE, objectEditorState, "OBJECT_EDITOR_STATE");

      State* shapeEditorState = new ShapeEditorState;
      shapeEditorState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_SHAPEEDITORSTATE, shapeEditorState, "SHAPE_EDITOR_STATE");

      State* worldEditorState = new WorldEditorState;
      worldEditorState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_WORLDEDITORSTATE, worldEditorState, "WORLD_EDITOR_STATE");
      
      ConversationState* conversationState = new ConversationState;
      g_ConversationState = conversationState;
      conversationState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_CONVERSATIONSTATE, conversationState, "CONVERSATION_STATE");

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
      Log(errorCode);
      exit(0);
   }

   if (g_Engine)
   {
      g_Engine.reset();
   }

   return 0;
}