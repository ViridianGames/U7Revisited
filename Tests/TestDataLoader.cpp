///////////////////////////////////////////////////////////////////////////
//
// Name:     TestDataLoader.cpp
// Date:     01/26/2025
// Purpose:  Minimal game data loader for script testing (headless mode)
//
///////////////////////////////////////////////////////////////////////////

#include "TestDataLoader.h"
#include "U7Globals.h"
#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/State.h"
#include "Geist/Config.h"
#include "LoadingState.h"
#include "MainState.h"
#include "ShapeData.h"
#include "Terrain.h"
#include "U7Player.h"
#include "raylib.h"
#include <iostream>
#include <fstream>
#include <sstream>

TestDataLoader::TestDataLoader()
{
    // LoadingState expects data_path to point to where STATIC/ directory is
    // In our case, that's Data/U7
    m_dataPath = "Data/U7";
}

TestDataLoader::~TestDataLoader()
{
}

bool TestDataLoader::LoadEssentialData()
{
    std::cout << "Loading essential game data for script testing...\n";

    // Step 1: Initialize raylib in headless mode (offscreen)
    std::cout << "  Initializing raylib (offscreen mode)...\n";
    SetConfigFlags(FLAG_WINDOW_HIDDEN); // Hide the window
    InitWindow(800, 600, "ScriptTests");
    SetTargetFPS(60);

    // Step 2: Initialize Engine
    std::cout << "  Initializing Engine...\n";
    g_Engine = std::make_unique<Engine>();

    // Set engine config manually
    g_Engine->m_EngineConfig.SetString("data_path", m_dataPath);
    g_Engine->m_EngineConfig.SetNumber("h_res", 800);
    g_Engine->m_EngineConfig.SetNumber("v_res", 600);
    g_Engine->m_EngineConfig.SetNumber("h_renderres", 800);
    g_Engine->m_EngineConfig.SetNumber("v_renderres", 600);
    g_Engine->m_EngineConfig.SetNumber("full_screen", 0);

    // Initialize subsystems manually
    g_ResourceManager = std::make_unique<ResourceManager>();
    g_ResourceManager->Init("");

    g_StateMachine = std::make_unique<StateMachine>();
    g_StateMachine->Init("");

    // Register dummy states to prevent crashes when scripts push/pop states
    // We need at least ConversationState registered and a base state on the stack
    // Create minimal stub states
    class DummyState : public State
    {
    public:
        void Init(const std::string&) override {}
        void Shutdown() override {}
        void Update() override {}
        void Draw() override {}
        void OnEnter() override {}
        void OnExit() override {}
    };

    // Create a mock MainState that implements Bark() and other commonly used methods
    class MockMainStateForTests : public MainState
    {
    public:
        // Override State virtual methods to prevent crashes during state transitions
        void Init(const std::string& configfile) override
        {
            // Don't call base class Init - it requires full game setup
        }
        void Update() override
        {
            // Don't call base class Update - it tries to update terrain lighting, NPCs, etc.
            // For testing, we don't need any of that
        }
        void Draw() override
        {
            // Don't draw anything in test mode
        }
        void OnEnter() override
        {
            // Don't do anything on state enter
        }
        void OnExit() override
        {
            // Don't do anything on state exit
        }

        void Bark(U7Object* object, const std::string& text, float duration = 3.0f)
        {
            // Just ignore bark calls in test mode
        }
        void NPCBark(int npc_id, const std::string& text, float duration = 3.0f)
        {
            // Just ignore NPC bark calls in test mode
        }
    };

    // Register dummy states for the state IDs that scripts use
    g_StateMachine->RegisterState(STATE_MAINSTATE, new MockMainStateForTests(), "MockMainState");
    g_StateMachine->RegisterState(STATE_CONVERSATIONSTATE, new DummyState(), "DummyConversationState");

    // Start with a base state so StateStack isn't empty
    g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
    g_StateMachine->Update(); // Process the transition to actually push the state

    // Step 3: Initialize terrain (required for loading)
    std::cout << "  Initializing terrain...\n";
    g_Terrain = std::make_unique<Terrain>();

    // Step 4: Initialize player (required for NPC loading)
    std::cout << "  Initializing player...\n";
    g_Player = std::make_unique<U7Player>();
    g_Player->SetMale(true); // Default to male avatar

    // Step 5: Create LoadingState and load game data
    std::cout << "  Loading game data via LoadingState...\n";
    LoadingState loader;
    loader.Init("");

    // Run loading steps manually
    loader.LoadVersion();
    loader.LoadChunks();
    loader.LoadMap();
    loader.CreateObjectTable();
    loader.CreateShapeTable();
    loader.MakeMap();
    loader.LoadInitialGameState();

    std::cout << "Essential game data loaded successfully\n";
    std::cout << "  Objects in g_objectList: " << g_objectList.size() << "\n";
    std::cout << "  NPCs in g_NPCData: " << g_NPCData.size() << "\n";

    return true;
}

bool TestDataLoader::LoadShapeTableMetadata()
{
    std::cout << "  Loading shapetable.dat...\n";

    std::string shapetablePath = m_dataPath + "/shapetable.dat";
    std::ifstream file(shapetablePath);

    if (!file.good())
    {
        std::cerr << "    ERROR: Cannot open " << shapetablePath << "\n";
        return false;
    }

    int lineCount = 0;
    std::string line;

    while (std::getline(file, line))
    {
        if (line.empty()) continue;

        std::istringstream iss(line);
        int shape, frame;

        // Read first two fields: shape and frame
        if (!(iss >> shape >> frame))
        {
            continue; // Skip malformed lines
        }

        // For now, just initialize the ShapeData entry to exist
        // We don't need to load the actual graphics/textures
        if (shape >= 0 && shape < 1024 && frame >= 0 && frame < 32)
        {
            // Just mark that this shape/frame exists
            // The actual texture loading would happen in LoadingState
            // For testing, we just need the data structure to exist
            lineCount++;
        }
    }

    file.close();
    std::cout << "    Loaded " << lineCount << " shape/frame entries\n";
    return true;
}

bool TestDataLoader::LoadNPCData()
{
    std::cout << "  Loading NPC data from INITGAME.DAT...\n";

    // For now, skip loading INITGAME.DAT as it requires parsing FLX format
    // and creating actual U7Object instances which need graphics

    std::cout << "    NPC loading skipped (requires full game initialization)\n";
    return true;
}

bool TestDataLoader::CreateBasicObjects()
{
    std::cout << "  Creating basic test objects...\n";

    // Create a few dummy objects that scripts might reference
    // This prevents immediate crashes when scripts try to access object 0, 1, etc.

    // For now, we can't create real U7Objects without graphics initialization
    // because they require Texture pointers from raylib

    std::cout << "    Object creation skipped (requires graphics initialization)\n";
    std::cout << "    Note: Scripts that access objects will still crash\n";

    return true;
}
