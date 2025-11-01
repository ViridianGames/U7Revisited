///////////////////////////////////////////////////////////////////////////
//
// Name:     ScriptTests.cpp
// Date:     01/26/2025
// Purpose:  Test harness for validating all Lua scripts
//
///////////////////////////////////////////////////////////////////////////

#include "ScriptTestMocks.h"
#include "U7LuaFuncs.h"
#include "Geist/ScriptingSystem.h"
#include "Geist/Globals.h"
#include <iostream>
#include <filesystem>
#include <vector>
#include <string>
#include <limits>

extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

namespace fs = std::filesystem;

// Test result structure
struct TestResult
{
    std::string scriptPath;
    std::string scriptName;
    bool passed;
    std::string errorMessage;
};

// Extract function name from file path
std::string GetFunctionNameFromPath(const std::string& path)
{
    fs::path p(path);
    std::string filename = p.stem().string(); // Get filename without extension
    return filename;
}

// Test a single script by loading and optionally executing it
TestResult TestScript(const fs::path& scriptPath, bool executeScript = false)
{
    TestResult result;
    result.scriptPath = scriptPath.string();
    result.scriptName = GetFunctionNameFromPath(scriptPath.string());
    result.passed = false;
    result.errorMessage = "";

    lua_State* L = g_ScriptingSystem->m_luaState;

    // Load the script file - this validates syntax
    int loadResult = luaL_dofile(L, scriptPath.string().c_str());
    if (loadResult != LUA_OK)
    {
        // Syntax error or loading error
        const char* error = lua_tostring(L, -1);
        result.errorMessage = error ? error : "Unknown load error";
        lua_pop(L, 1);
        return result;
    }

    // Verify the function exists (it's already on the stack from luaL_dofile)
    lua_getglobal(L, result.scriptName.c_str());
    if (!lua_isfunction(L, -1))
    {
        result.errorMessage = "Function '" + result.scriptName + "' not found in file";
        lua_pop(L, 1);
        return result;
    }

    if (executeScript)
    {
        // Set up Lua hook to detect infinite loops / long-running scripts
        auto timeoutHook = [](lua_State* L, lua_Debug* ar) {
            luaL_error(L, "Script timeout - exceeded 1 second execution time");
        };

        // Wrap execution in try-catch to catch C++ exceptions
        try
        {
            // Set hook to check every 100,000 instructions (roughly ~1 second)
            lua_sethook(L, timeoutHook, LUA_MASKCOUNT, 100000);

            // Function is already on stack from lua_getglobal above
            // Push arguments
            lua_pushinteger(L, 1); // eventid = 1 (common "use" event)
            lua_pushinteger(L, 0); // objectref = 0 (dummy object reference)

            // Use lua_pcall for protected call to catch Lua runtime errors
            int callResult = lua_pcall(L, 2, 0, 0);

            // Clear the hook after execution
            lua_sethook(L, nullptr, 0, 0);

            if (callResult != LUA_OK)
            {
                // Runtime error in Lua or error thrown from C function
                const char* error = lua_tostring(L, -1);
                std::string errorMsg = error ? error : "Unknown";

                // Note: "yield from outside coroutine" is expected for scripts that use wait()
                // These scripts need to be called as coroutines, not direct function calls
                result.errorMessage = std::string("Lua error: ") + errorMsg;
                lua_pop(L, 1);
                return result;
            }
        }
        catch (const std::exception& e)
        {
            // Clear hook on exception
            lua_sethook(L, nullptr, 0, 0);
            result.errorMessage = std::string("C++ exception: ") + e.what();
            return result;
        }
        catch (...)
        {
            // Clear hook on crash
            lua_sethook(L, nullptr, 0, 0);
            result.errorMessage = "C++ crash (likely null pointer dereference in C function)";
            return result;
        }
    }
    else
    {
        lua_pop(L, 1); // Pop the function without calling it
    }

    // If we got here, the script loaded (and possibly executed) successfully
    result.passed = true;
    return result;
}

int main(int argc, char* argv[])
{
    // Check for --execute flag
    bool executeScripts = false;
    for (int i = 1; i < argc; i++)
    {
        if (std::string(argv[i]) == "--execute")
        {
            executeScripts = true;
        }
    }

    std::cout << "================================================\n";
    std::cout << "  Ultima 7 Revisited - Script Testing Tool\n";
    std::cout << "================================================\n\n";

    if (executeScripts)
    {
        std::cout << "Test Mode: SYNTAX + EXECUTION\n";
        std::cout << "This tool validates that all Lua scripts:\n";
        std::cout << "  - Have correct Lua syntax\n";
        std::cout << "  - Can be loaded by the Lua interpreter\n";
        std::cout << "  - Have a function matching the filename\n";
        std::cout << "  - Can execute without crashing (eventid=1, objectref=0)\n";
        std::cout << "\n";
        std::cout << "Game data will be loaded (shapes, NPCs, objects).\n";
        std::cout << "This will take a moment...\n";
    }
    else
    {
        std::cout << "Test Mode: SYNTAX VALIDATION ONLY\n";
        std::cout << "This tool validates that all Lua scripts:\n";
        std::cout << "  - Have correct Lua syntax\n";
        std::cout << "  - Can be loaded by the Lua interpreter\n";
        std::cout << "  - Have a function matching the filename\n";
        std::cout << "\n";
        std::cout << "NOTE: Scripts are NOT executed, so runtime errors\n";
        std::cout << "      won't be detected. This is a syntax-only check.\n";
        std::cout << "      Use --execute flag to run scripts (requires game data).\n";
    }
    std::cout << "================================================\n\n";

    // Initialize mock globals
    InitializeMockGlobals();

    // Load game data if we're going to execute scripts
    bool gameDataLoaded = false;
    if (executeScripts)
    {
        gameDataLoaded = LoadEssentialGameData();
        if (!gameDataLoaded)
        {
            std::cerr << "\nERROR: Failed to load game data!\n";
            std::cerr << "Cannot run scripts in execute mode without game data.\n";
            std::cerr << "Falling back to syntax-only testing.\n\n";
            executeScripts = false; // Disable execution if loading failed
        }
    }

    // Register all Lua functions
    std::cout << "\nRegistering Lua functions...\n";
    RegisterAllLuaFunctions();
    std::cout << "Lua functions registered\n\n";

    // Find all script files
    std::string scriptDir = "Data/Scripts";
    std::vector<fs::path> scriptPaths;

    std::cout << "Scanning for .lua files in " << scriptDir << "...\n";
    if (!fs::exists(scriptDir))
    {
        std::cerr << "ERROR: Scripts directory not found: " << scriptDir << "\n";
        std::cerr << "Make sure to run this from the Redist/ directory\n";
        CleanupMockGlobals();
        return 1;
    }

    for (const auto& entry : fs::directory_iterator(scriptDir))
    {
        if (entry.path().extension() == ".lua")
        {
            scriptPaths.push_back(entry.path());
        }
    }

    std::cout << "Found " << scriptPaths.size() << " script files\n\n";

    if (scriptPaths.empty())
    {
        std::cout << "No scripts found to test\n";
        CleanupMockGlobals();
        return 0;
    }

    // Test all scripts
    std::cout << "Testing scripts...\n";
    std::cout << "================================================\n";

    std::vector<TestResult> results;
    int passCount = 0;
    int failCount = 0;

    for (size_t i = 0; i < scriptPaths.size(); i++)
    {
        const auto& scriptPath = scriptPaths[i];

        // Show progress
        if (i % 100 == 0 && i > 0)
        {
            std::cout << "Tested " << i << "/" << scriptPaths.size() << " scripts...\n";
        }

        TestResult result = TestScript(scriptPath, executeScripts);
        results.push_back(result);

        if (result.passed)
        {
            passCount++;
        }
        else
        {
            failCount++;
            // Print failures immediately
            std::cout << "[FAIL] " << result.scriptName << ".lua\n";
            std::cout << "       " << result.errorMessage << "\n";
        }
    }

    // Print summary
    std::cout << "\n================================================\n";
    std::cout << "  Test Summary\n";
    std::cout << "================================================\n";
    std::cout << "Total Scripts:  " << scriptPaths.size() << "\n";
    std::cout << "Passed:         " << passCount << " ("
              << (100.0 * passCount / scriptPaths.size()) << "%)\n";
    std::cout << "Failed:         " << failCount << " ("
              << (100.0 * failCount / scriptPaths.size()) << "%)\n";
    std::cout << "================================================\n";

    // Print detailed failure list if any
    if (failCount > 0)
    {
        std::cout << "\nFailed Scripts:\n";
        std::cout << "================================================\n";
        for (const auto& result : results)
        {
            if (!result.passed)
            {
                std::cout << result.scriptName << ".lua\n";
                std::cout << "  Error: " << result.errorMessage << "\n\n";
            }
        }
    }

    // Wait for user input before closing
    std::cout << "\n\nPress ENTER to exit...";
    std::cin.get(); // Wait for Enter

    // Cleanup (happens after user presses Enter to avoid extra output)
    CleanupMockGlobals();

    // Return 0 if all passed, 1 if any failed
    return (failCount == 0) ? 0 : 1;
}
