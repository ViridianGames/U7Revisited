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

// Helper function to add an asset loading error to the global list
void AddAssetError(const std::string& filePath, const std::string& errorType, const std::string& errorMessage) {
    g_AssetLoadErrors.push_back({filePath, errorType, errorMessage});
    // Also log it immediately for visibility during loading
    Log("Asset Error [" + errorType + "]: File='" + filePath + "', Msg='" + errorMessage + "'", LOG_ERROR);
}

// Helper function to check file existence and log errors
bool CheckFileExists(const std::string& path) {
    if (!exists(path) || !is_regular_file(path)) { // Ensure it's a file
        AddAssetError(path, "FileNotFound", "Required file not found or is not a regular file.");
        return false;
    }
    return true;
}

// Helper function to check directory existence and log errors
bool CheckDirectoryExists(const std::string& path) {
    if (!exists(path) || !is_directory(path)) {
        AddAssetError(path, "DirectoryNotFound", "Required directory not found or is not a directory.");
        return false;
    }
    return true;
}

// Function to load core game assets or check their existence
// Returns true if successful, false otherwise.
bool LoadCoreGameAssets(bool isHealthCheck, bool isVerbose) {
    // Use LOG_INFO for progress messages, which will only print if verbose log level is set
    Log("Loading/Checking Core Game Assets...", LOG_INFO);
    bool criticalSuccess = true;
    g_AssetLoadErrors.clear();

    // --- Files required for core engine function ---
    const std::vector<std::string> requiredEngineFiles = {
        "Data/Shaders/alphaDiscard.fs",
        "Data/Fonts/softsquare.ttf",
        "Data/Fonts/lantern.ttf",
        "Data/Fonts/babyblocks.ttf",
        "Images/pointer.png",
        "Images/GUI/guielements.png",
        "Images/GUI/gumps.png"
    };

    Log("Checking required engine files...", LOG_INFO);
    for (const auto& file : requiredEngineFiles) {
        if (!CheckFileExists(file)) {
            criticalSuccess = false; // Mark critical failure
        }
    }

    // --- Check for essential U7 Data Directories ---
    Log("Checking required U7 data directories...", LOG_INFO);
    std::string staticPath = "Data/U7/STATIC";
    std::string gamedatPath = "Data/U7/GAMEDAT";

    if (!CheckDirectoryExists(staticPath)) {
        if (!isHealthCheck) { // In normal mode, this is a critical failure
            criticalSuccess = false;
        } else {
            // In health check, log a warning but don't fail critically
            // The AddAssetError in CheckDirectoryExists already logged the specific error
            Log("U7 data directory '" + staticPath + "' not found. Proceeding with health check for local assets.", LOG_WARNING);
        }
    }
    if (!CheckDirectoryExists(gamedatPath)) {
        if (!isHealthCheck) { // In normal mode, this is a critical failure
            criticalSuccess = false;
        } else {
             // In health check, log a warning but don't fail critically
            Log("U7 data directory '" + gamedatPath + "' not found. Proceeding with health check for local assets.", LOG_WARNING);
        }
    }
    // Optional: Check for a key file within one of them if directory check isn't enough?
    // We only perform further checks if the directories exist and it's NOT a CI health check
    // (or if it IS a health check but we want to check deeper locally)
    // bool performDeepU7Check = exists(staticPath) && exists(gamedatPath) && (!isHealthCheck /* || allowDeepHealthCheckFlag */ );
    // if (performDeepU7Check && !CheckFileExists("Data/U7/STATIC/U7CHUNKS")) { // Example
    //    criticalSuccess = false; // Failure here IS critical if we expect U7 data
    // }

    // --- Script Loading (Attempt load in both modes, report errors) ---
    Log("Loading scripts...", LOG_INFO);
    std::string scriptDirectoryPath("Data/Scripts");
    if (!CheckDirectoryExists(scriptDirectoryPath)) { // Use new helper
         criticalSuccess = false; // Script dir is critical
    } else {
        try {
            for (const auto& entry : directory_iterator(scriptDirectoryPath)) {
                if (entry.is_regular_file()) {
                    std::string ext = entry.path().extension().string();
                    if (ext == ".lua") {
                        std::string filepath = entry.path().string();
                        if (!g_ScriptingSystem->LoadScript(filepath)) {
                            // Script failed to load, add error to the list but DON'T mark critical failure
                            AddAssetError(filepath, "ScriptSyntaxError", g_ScriptingSystem->GetLastError());
                        }
                    }
                }
            }
            // Also load specific required scripts
            std::string erethianPath = "Data/Scripts/erethian.lua";
            if (!g_ScriptingSystem->LoadScript(erethianPath)) {
                 AddAssetError(erethianPath, "ScriptSyntaxError", g_ScriptingSystem->GetLastError());
                 // Decide if this specific script IS critical? For now, treat like others.
            }

        } catch (const std::exception& e) {
            AddAssetError(scriptDirectoryPath, "ScriptLoadingException", std::string("Exception during script directory iteration: ") + e.what());
            criticalSuccess = false;
        }
    }


    // --- Graphics-dependent loading (Only in normal mode) ---
    if (!isHealthCheck) {
        Log("Loading graphics-dependent assets...", LOG_INFO);
        // Shaders
        g_alphaDiscard = LoadShader(NULL, "Data/Shaders/alphaDiscard.fs");
        if (g_alphaDiscard.id == 0) { // Basic check if shader loading failed
             AddAssetError("Data/Shaders/alphaDiscard.fs", "ShaderLoadFailed", "LoadShader returned ID 0.");
             criticalSuccess = false;
        }

        // Fonts
        float baseFontSize = 9;
        g_fontSize = baseFontSize * int(g_DrawScale); // g_DrawScale calculated earlier

        const char* softsquarePath = "Data/Fonts/softsquare.ttf";
        Font font = LoadFontEx(softsquarePath, g_fontSize, NULL, 0);
        if (font.texture.id == 0) {
            AddAssetError(softsquarePath, "FontLoadFailed", "LoadFontEx failed for main font.");
            criticalSuccess = false;
        }
        else { g_Font = make_shared<Font>(font); }

        Font smallFont = LoadFontEx(softsquarePath, baseFontSize, NULL, 0);
         if (smallFont.texture.id == 0) {
             AddAssetError(softsquarePath, "FontLoadFailed", "LoadFontEx failed for small font.");
             criticalSuccess = false; // This might be less critical, adjust if needed
         }
        else { g_SmallFont = make_shared<Font>(smallFont); }

        const char* conversationFontPath = "Data/Fonts/lantern.ttf"; float conversationFontSize = 18;
        Font conversationFont = LoadFontEx(conversationFontPath, conversationFontSize, NULL, 0);
         if (conversationFont.texture.id == 0) {
             AddAssetError(conversationFontPath, "FontLoadFailed", "LoadFontEx failed for conversation font.");
             criticalSuccess = false;
         }
        else { g_ConversationFont = make_shared<Font>(conversationFont); }

        const char* guiFontPath = "Data/Fonts/babyblocks.ttf"; float guiFontSize = 8;
        Font guiFont = LoadFontEx(guiFontPath, guiFontSize, NULL, 0);
        if (guiFont.texture.id == 0) {
             AddAssetError(guiFontPath, "FontLoadFailed", "LoadFontEx failed for GUI font.");
             criticalSuccess = false;
         }
        else { g_guiFont = make_shared<Font>(guiFont); }

        // Render Targets - Check if LoadRenderTexture can fail meaningfully?
        // Raylib's LoadRenderTexture seems less likely to fail catastrophically unless OOM.
        // Assuming success unless specific errors arise.
        g_renderTarget = LoadRenderTexture(g_Engine->m_RenderWidth, g_Engine->m_RenderHeight);
        SetTextureFilter(g_renderTarget.texture, RL_TEXTURE_FILTER_ANISOTROPIC_4X);
        g_guiRenderTarget = LoadRenderTexture(g_Engine->m_RenderWidth, g_Engine->m_RenderHeight);
        SetTextureFilter(g_guiRenderTarget.texture, RL_TEXTURE_FILTER_ANISOTROPIC_4X);

        // GUI Sprites (uses ResourceManager)
        // Check if ResourceManager->GetTexture signals errors or if CheckFileExists is enough
        // Assuming CheckFileExists above covers the critical path for now.
        // If GetTexture can fail later (e.g., bad image format), add error reporting there.
        g_Cursor = g_ResourceManager->GetTexture("Images/pointer.png");

        g_Borders.clear();
        g_ConversationBorders.clear();

        // Sprite creation relies on textures loaded via ResourceManager.
        // Assuming GetTexture logs its own errors if loading fails after file existence check.
        // If not, we'd need to check texture validity here.
        try {
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
        } catch (const std::exception& e) {
             // Catch potential errors during sprite creation if GetTexture throws or dereferences null
             AddAssetError("Images/GUI/guielements.png or Images/GUI/gumps.png", "SpriteCreationFailed", std::string("Exception during sprite creation: ") + e.what());
             criticalSuccess = false;
         }


    } // End !isHealthCheck block

    // --- Assets needed in both modes (or construction is sufficient) ---
    Log("Creating terrain...", LOG_INFO);
    try {
        g_Terrain = make_unique<Terrain>(); // Assuming constructor is safe without graphics
    } catch (const std::exception& e) {
        AddAssetError("Terrain", "InitializationFailed", std::string("Exception during Terrain construction: ") + e.what());
        criticalSuccess = false;
    }

    // Random Number Generators (Unlikely to fail unless memory allocation fails)
    try {
        g_VitalRNG = make_unique<RNG>();
        g_VitalRNG->SeedRNG(isHealthCheck ? 7777 : (int)(GetTime() * 1000));
        g_NonVitalRNG = make_unique<RNG>();
        g_NonVitalRNG->SeedRNG(isHealthCheck ? 1234 : (int)(GetTime() * 1000 + 1));
    } catch (const std::exception& e) {
        AddAssetError("RNG", "InitializationFailed", std::string("Exception during RNG construction: ") + e.what());
        criticalSuccess = false; // RNG failure is likely critical
    }

    // --- Final Summary (ALWAYS PRINT ERRORS if any exist) --- 
    if (!g_AssetLoadErrors.empty()) {
        // Use LOG_WARNING for summary header so it appears even in quiet mode if there are errors
        Log("----------------------------------------", LOG_WARNING);
        Log("Asset Loading completed with ERRORS:", LOG_WARNING);
        for (const auto& error : g_AssetLoadErrors) {
            // Individual errors logged via AddAssetError use LOG_ERROR, which always shows
            Log("  - Type: " + error.errorType + ", File: '" + error.filePath + "', Msg: " + error.errorMessage, LOG_ERROR);
        }
        Log("----------------------------------------", LOG_WARNING);
    }

    // Final status message - Use LOG_INFO normally, but LOG_WARNING/ERROR for failures
    if (criticalSuccess) {
         if (g_AssetLoadErrors.empty()) {
             Log("Core Game Assets Load/Check: CRITICAL SUCCESS (All assets OK).", LOG_INFO);
         } else {
             Log("Core Game Assets Load/Check: CRITICAL SUCCESS (but non-critical errors found).", LOG_WARNING);
         }
    } else {
         Log("Core Game Assets Load/Check: CRITICAL FAILURE. See errors above.", LOG_ERROR);
    }

    return criticalSuccess;
}

int main(int argv, char** argc)
{
    // Set default log level (can be overridden)
    // LOG_WARNING: Only warnings, errors, fatals will be shown by default
    SetTraceLogLevel(LOG_WARNING);
    SetTraceLogCallback(LoggingCallback);

    bool isHealthCheck = false;
    bool isVerbose = false;

    // Simple argument parsing
    for (int i = 1; i < argv; ++i) {
        if (strcmp(argc[i], "--healthcheck") == 0) {
            isHealthCheck = true;
            // Health check implies verbose logging during check
            isVerbose = true;
            Log("Health check mode enabled.", LOG_INFO); // Log at INFO level
        } else if (strcmp(argc[i], "--verbose") == 0) {
            isVerbose = true;
            Log("Verbose mode enabled.", LOG_INFO); // Log at INFO level
        }
        // Add other argument checks here if needed
    }

    // Set log level based on flags
    if (isVerbose) {
        SetTraceLogLevel(LOG_INFO); // Show info, warnings, errors, fatals
    }

   try
   {
      g_Engine = make_unique<Engine>();
      g_Engine->Init("Data/engine.cfg", isHealthCheck);

      if (isHealthCheck) {
         // --- Health Check Path ---
         Log("Running health check initialization...", LOG_INFO);

         Log("Registering Lua C++ functions...", LOG_INFO);
         // Register Lua functions first so scripts can find them during load
         RegisterAllLuaFunctions(); 
         Log("Lua C++ functions registered.", LOG_INFO);

         // Load/check core assets needed for basic functionality
         bool criticalAssetsOk = LoadCoreGameAssets(true, isVerbose);

         if (!criticalAssetsOk) {
             // LoadCoreGameAssets already logged the details and summary.
             Log("Health check FAILED due to CRITICAL asset errors.", LOG_FATAL); // Keep fatal wording
             exit(1); // Exit with non-zero code on critical failure
         }

         // If we reached here, critical assets are OK.
         // Now check if there were *any* asset errors (including non-critical like scripts).
         if (!g_AssetLoadErrors.empty()) {
            // Check if the U7 data directories were among the errors
            bool u7DataMissing = false;
            for (const auto& error : g_AssetLoadErrors) {
                if ((error.filePath == "Data/U7/STATIC" || error.filePath == "Data/U7/GAMEDAT") && error.errorType == "DirectoryNotFound") {
                    u7DataMissing = true;
                    break;
                }
            }

            if (u7DataMissing) {
                Log("Health check PASSED (OK) but required U7 data directories were missing (" + std::to_string(g_AssetLoadErrors.size()) + " total non-critical errors found).", LOG_WARNING);
            } else {
                Log("Health check PASSED (OK) with " + std::to_string(g_AssetLoadErrors.size()) + " non-critical errors (see details above).", LOG_WARNING);
            }
            // Still exit 0 because critical assets loaded, but log indicates issues.
            exit(0);
         }
         else {
            // Only log pure success if critical assets loaded AND no errors were recorded.
            // Log("Health check finished successfully.", LOG_INFO);
            Log("Health check PASSED (OK) successfully.", LOG_INFO);
            exit(0); // Exit with zero code on success
         }
      }
      else {
         // --- Normal Game Initialization & Main Loop ---
         Log("Initializing game (Normal Mode)...", LOG_INFO);

         rlDisableBackfaceCulling();
         rlEnableDepthTest();

         g_DrawScale = g_Engine->m_ScreenHeight / g_Engine->m_RenderHeight;

         Log("Registering Lua C++ functions...", LOG_INFO);
         RegisterAllLuaFunctions();
         Log("Lua C++ functions registered.", LOG_INFO);

         // Pass isHealthCheck=false AND isVerbose flag to asset loader
         if (!LoadCoreGameAssets(false, isVerbose)) {
             // Still throw error on critical failure in normal mode
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