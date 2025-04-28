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
#include <string>
#include <sstream>
#include <memory>
#include <filesystem>
#include <cstring> // Required for strcmp
#include <vector>  // Required for vector of paths

#include "rlgl.h"

using namespace std;
using namespace std::filesystem;

// Helper function to check file existence and log errors
bool CheckFileExists(const std::string& path) {
    if (!exists(path)) {
        Log("Required file not found: " + path, LOG_ERROR);
        return false;
    }
    return true;
}

// Function to load core game assets or check their existence
// Returns true if successful, false otherwise.
bool LoadCoreGameAssets(bool isHealthCheck) {
    Log("Loading/Checking Core Game Assets...");
    bool success = true;

    // --- Files required for both modes (existence check minimum) ---
    const std::vector<std::string> requiredFiles = {
        "Data/Shaders/alphaDiscard.fs",
        "Data/Fonts/softsquare.ttf",
        "Data/Fonts/lantern.ttf",
        "Data/Fonts/babyblocks.ttf",
        "Images/pointer.png",
        "Images/GUI/guielements.png",
        "Images/GUI/gumps.png"
    };

    for (const auto& file : requiredFiles) {
        if (!CheckFileExists(file)) {
            success = false; // Mark failure but continue checking other files
        }
    }

    // --- Script Loading (Attempt load in both modes, ScriptingSystem handles errors) ---
    Log("Loading scripts...");
    string scriptDirectoryPath("Data/Scripts");
    if (!exists(scriptDirectoryPath) || !is_directory(scriptDirectoryPath)) {
         Log("Script directory not found: " + scriptDirectoryPath, LOG_ERROR);
         success = false;
    } else {
        try {
            for (const auto& entry : directory_iterator(scriptDirectoryPath)) {
                if (entry.is_regular_file()) {
                    std::string ext = entry.path().extension().string();
                    if (ext == ".lua") {
                        std::string filepath = entry.path().string();
                        // Re-added boolean check now that LoadScript returns bool
                        if (!g_ScriptingSystem->LoadScript(filepath)) {
                            // Log message already happens inside LoadScript on failure
                            success = false; // Mark failure for LoadCoreGameAssets
                        }
                    }
                }
            }
            // Also load specific required scripts
            // Re-added boolean check now that LoadScript returns bool
             if (!g_ScriptingSystem->LoadScript("Data/Scripts/erethian.lua")) {
                 // Log message already happens inside LoadScript on failure
                 success = false; // Mark failure for LoadCoreGameAssets
             }

        } catch (const std::exception& e) {
            Log(std::string("Exception during script loading: ") + e.what(), LOG_ERROR);
            success = false;
        }
    }


    // --- Graphics-dependent loading (Only in normal mode) ---
    if (!isHealthCheck) {
        Log("Loading graphics-dependent assets...");
        // Shaders
        g_alphaDiscard = LoadShader(NULL, "Data/Shaders/alphaDiscard.fs");
        if (g_alphaDiscard.id == 0) { // Basic check if shader loading failed
             Log("Failed to load shader: Data/Shaders/alphaDiscard.fs", LOG_ERROR);
             success = false;
        }


        // Fonts
        float baseFontSize = 9;
        g_fontSize = baseFontSize * int(g_DrawScale); // g_DrawScale calculated earlier

        Font font = LoadFontEx("Data/Fonts/softsquare.ttf", g_fontSize, NULL, 0);
        if (font.texture.id == 0) { Log("Failed to load font: Data/Fonts/softsquare.ttf", LOG_ERROR); success = false; }
        else { g_Font = make_shared<Font>(font); }

        Font smallFont = LoadFontEx("Data/Fonts/softsquare.ttf", baseFontSize, NULL, 0);
         if (smallFont.texture.id == 0) { Log("Failed to load small font: Data/Fonts/softsquare.ttf", LOG_ERROR); success = false; }
        else { g_SmallFont = make_shared<Font>(smallFont); }

        const char* conversationFontPath = "Data/Fonts/lantern.ttf"; float conversationFontSize = 18;
        Font conversationFont = LoadFontEx(conversationFontPath, conversationFontSize, NULL, 0);
         if (conversationFont.texture.id == 0) { Log("Failed to load font: " + string(conversationFontPath), LOG_ERROR); success = false; }
        else { g_ConversationFont = make_shared<Font>(conversationFont); }

        const char* guiFontPath = "Data/Fonts/babyblocks.ttf"; float guiFontSize = 8;
        Font guiFont = LoadFontEx(guiFontPath, guiFontSize, NULL, 0);
        if (guiFont.texture.id == 0) { Log("Failed to load font: " + string(guiFontPath), LOG_ERROR); success = false; }
        else { g_guiFont = make_shared<Font>(guiFont); }

        // Render Targets
        g_renderTarget = LoadRenderTexture(g_Engine->m_RenderWidth, g_Engine->m_RenderHeight);
        SetTextureFilter(g_renderTarget.texture, RL_TEXTURE_FILTER_ANISOTROPIC_4X);
        g_guiRenderTarget = LoadRenderTexture(g_Engine->m_RenderWidth, g_Engine->m_RenderHeight);
        SetTextureFilter(g_guiRenderTarget.texture, RL_TEXTURE_FILTER_ANISOTROPIC_4X);

        // GUI Sprites (uses ResourceManager which should handle errors internally, but we checked file existence above)
        g_Cursor = g_ResourceManager->GetTexture("Images/pointer.png"); // Assume GetTexture loads or queues, success depends on file check

        g_Borders.clear(); // Ensure vectors are empty before pushing
        g_ConversationBorders.clear();

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

        g_InactiveButtonL = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 15, 0, 4, 11);
        g_InactiveButtonM = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 18, 0, 1, 11);
        g_InactiveButtonR = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 19, 0, 4, 11);
        g_ActiveButtonL = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 7, 0, 4, 11);
        g_ActiveButtonM = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 10, 0, 1, 11);
        g_ActiveButtonR = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 11, 0, 4, 11);

        g_LeftArrow = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 67, 0, 8, 9);
        g_RightArrow = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/guielements.png", false), 76, 0, 8, 9);

        g_gumpBackground = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/gumps.png", false), 6, 176, 154, 98);
        g_gumpCheckmarkUp = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/gumps.png", false), 334, 12, 21, 21);
        g_gumpCheckmarkDown = make_unique<Sprite>(g_ResourceManager->GetTexture("Images/GUI/gumps.png", false), 334, 52, 21, 21);

    } // End !isHealthCheck block

    // --- Assets needed in both modes (or construction is sufficient) ---
    Log("Creating terrain...");
    g_Terrain = make_unique<Terrain>(); // Assuming constructor is safe without graphics

    // Random Number Generators
    g_VitalRNG = make_unique<RNG>();
    g_VitalRNG->SeedRNG(isHealthCheck ? 7777 : (int)(GetTime() * 1000)); // Use fixed seed for HC
    g_NonVitalRNG = make_unique<RNG>();
    g_NonVitalRNG->SeedRNG(isHealthCheck ? 1234 : (int)(GetTime() * 1000 + 1)); // Use fixed seed for HC

    if (success) {
         Log("Core Game Assets Load/Check Successful.");
    } else {
         Log("Core Game Assets Load/Check Failed. See errors above.", LOG_ERROR);
    }
    return success;
}

int main(int argv, char** argc)
{
    SetTraceLogCallback(LoggingCallback);

    bool isHealthCheck = false;
    if (argv > 1 && strcmp(argc[1], "--healthcheck") == 0) {
        isHealthCheck = true;
        Log("Health check mode enabled.");
    }

   try
   {
      g_Engine = make_unique<Engine>();
      g_Engine->Init("Data/engine.cfg", isHealthCheck);

      if (isHealthCheck) {
         // --- Health Check Path ---
         Log("Running health check initialization...");

         // Load/check core assets needed for basic functionality
         if (!LoadCoreGameAssets(true)) { // Pass true for isHealthCheck
             Log("Health check failed: Core asset loading/checking failed.", LOG_ERROR);
             exit(1); // Exit with non-zero code on failure
         }

         // TODO: Add more specific health checks if needed, e.g.,
         // - Check if essential U7 data files exist (if expected)?
         // - Instantiate LoadingState and call specific non-graphical Load* methods?

         Log("Health check finished successfully.");
         exit(0); // Exit with zero code on success
      }
      else {
         // --- Normal Game Initialization & Main Loop ---

         // Basic graphics setup (moved up slightly for context)
         rlDisableBackfaceCulling();
         rlEnableDepthTest();

         // Calculate draw scale needed for font loading
          g_DrawScale = g_Engine->m_ScreenHeight / g_Engine->m_RenderHeight;

         // Load core assets (pass false for isHealthCheck)
         if (!LoadCoreGameAssets(false)) {
             // Throw an exception or log fatal error if essential assets fail in normal mode
             throw std::runtime_error("Failed to load essential game assets. Check logs.");
         }

         // Camera and Player setup (remains here as it's part of game setup)
         g_cameraDistance = 26;
         g_cameraRotation = 0.0f;
         g_Player = make_unique<U7Player>();

         // Pick a random initial location (uses RNG initialized in LoadCoreGameAssets)
         int x = g_VitalRNG->Random(7);
         switch (0) // TODO: Use 'x' or remove randomization? Keep 0 for consistency for now.
         {
             // ... (cases remain the same)
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

         g_camera.position = Vector3Add(g_camera.target, Vector3{ g_cameraDistance, g_cameraDistance, g_cameraDistance });
         g_camera.up = Vector3 { 0.0f, 1.0f, 0.0f };
         g_camera.fovy = g_cameraDistance;
         g_camera.projection = CAMERA_ORTHOGRAPHIC;

         // Lua function registration (after scripts are loaded)
         RegisterAllLuaFunctions();

         // Initialize states (remains here, depends on assets being loaded)
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

         ConversationState* conversationState = new ConversationState;
         g_ConversationState = conversationState;
         conversationState->Init("engine.cfg");
         g_StateMachine->RegisterState(STATE_CONVERSATIONSTATE, conversationState);


         g_StateMachine->MakeStateTransition(STATE_LOADINGSTATE);

         // --- Main Loop ---
         Log("Starting main loop.");
         while (!g_Engine->m_Done)
         {
            g_Engine->Update();
            g_Engine->Draw();
         }
      } // End normal game path
   } // End try block
 catch (string errorCode)
   {
      Log(errorCode, LOG_ERROR);
      // Ensure non-zero exit on caught error string
      // Check if we need specific handling for health check errors here?
      // For now, any caught string error indicates failure.
      exit(1); 
   }
   catch (const std::exception& e) 
   {
      // Catch standard exceptions too
      Log(std::string("Caught exception: ") + e.what(), LOG_ERROR);
      exit(1);
   }
   catch (...) 
   {
       Log("Caught unknown exception.", LOG_ERROR);
       exit(1);
   }

   if (g_Engine)
   {
      g_Engine.reset();
   }

   return 0;
}