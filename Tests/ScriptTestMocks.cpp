///////////////////////////////////////////////////////////////////////////
//
// Name:     ScriptTestMocks.cpp
// Date:     01/26/2025
// Purpose:  Mock implementations of game globals for script testing
//
///////////////////////////////////////////////////////////////////////////

#include "ScriptTestMocks.h"
#include "TestDataLoader.h"
#include "Geist/ScriptingSystem.h"
#include "Geist/Globals.h"
#include "U7Globals.h"
#include <memory>
#include <iostream>

// Mock ConversationState implementation
// Note: ConversationState already has AddStep() and SetNPC() methods that do what we need
// We don't need to override anything, just instantiate it

// Mock GumpManager implementation
class MockGumpManager : public GumpManager
{
public:
    // Inherit constructor if needed
};

// Mock MainState implementation
class MockMainState : public MainState
{
public:
    // Minimal mock
};

// Initialize all global pointers needed by Lua functions
void InitializeMockGlobals()
{
    std::cout << "Initializing mock globals for script testing...\n";

    // Geist globals
    g_ScriptingSystem = std::make_unique<ScriptingSystem>();
    g_ScriptingSystem->Init("");

    // Initialize RNG systems (needed by many Lua functions)
    g_VitalRNG = std::make_unique<RNG>();
    g_NonVitalRNG = std::make_unique<RNG>();

    // U7 game-specific globals
    // Note: Some of these are raw pointers, some are unique_ptr
    // We create minimal mocks just to prevent null pointer crashes

    // These are raw pointers - allocate on heap
    g_ConversationState = new ConversationState();
    // Don't call Init() yet - it needs g_Engine to be fully set up
    // Initialize the critical raw pointer to prevent crashes
    g_ConversationState->m_Gui = nullptr;
    g_mainState = new MockMainState();

    // These are unique_ptr - use make_unique
    g_gumpManager = std::make_unique<MockGumpManager>();

    // Initialize other critical globals to safe defaults
    g_hour = 12;
    g_minute = 0;
    g_scheduleTime = 4; // Noon schedule time
    g_isDay = true;

    // Enable Lua debug logging to see what scripts are calling
    g_LuaDebug = true;

    // Create a dummy object with ID 0 to prevent crashes when scripts reference objects
    // Most scripts pass objectref=0 or similar, so having this prevents null dereferences
    // Note: Creating a full U7Object requires ShapeData which requires loading game files
    // For now, we'll just document that object-related functions will fail gracefully

    std::cout << "Mock globals initialized\n";
    std::cout << "Lua debug logging enabled\n";
}

// Load essential game data needed for scripts to run
bool LoadEssentialGameData()
{
    // Use TestDataLoader to initialize game data
    TestDataLoader loader;
    return loader.LoadEssentialData();
}

// Clean up allocated globals
void CleanupMockGlobals()
{
    std::cout << "Cleaning up mock globals...\n";

    // Delete raw pointers
    delete g_ConversationState;
    g_ConversationState = nullptr;

    delete g_mainState;
    g_mainState = nullptr;

    // unique_ptr will auto-cleanup:
    // g_gumpManager, g_ScriptingSystem

    std::cout << "Mock globals cleaned up\n";
}
