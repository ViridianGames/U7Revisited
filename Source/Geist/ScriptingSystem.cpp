#include "ScriptingSystem.h"
#include "Config.h"
#include "Logging.h"
#include "Globals.h"
#include "raylib.h"
#include "raymath.h"

#include <fstream>
#include <sstream>
#include <iostream>
#include <algorithm>

using namespace std;

ScriptingSystem::ScriptingSystem()
{
    m_luaState = luaL_newstate();
    luaL_openlibs(m_luaState);
}

ScriptingSystem::~ScriptingSystem()
{
    if (m_luaState)
    {
        lua_close(m_luaState);
        m_luaState = nullptr;
    }
}

void ScriptingSystem::Init(const std::string& configfile)
{
    // TODO: Load flags from save file
}

void ScriptingSystem::Shutdown()
{
    // TODO: Save flags to file
}

void ScriptingSystem::Update()
{
}

void ScriptingSystem::LoadScript(const std::string& path)
{
    // Get the actual function name from the path
    std::string func_name;
#if defined(_WINDOWS) || defined(_WIN32)
    func_name = path.substr(path.find_last_of('\\') + 1);
#else
    func_name = path.substr(path.find_last_of('/') + 1);
#endif
    func_name = func_name.substr(0, func_name.find_last_of('.'));

    if (path == "Data/Scripts\\func_0401.lua")
    {
        int stopper = 0;
    }

    if (luaL_dofile(m_luaState, path.c_str()) != LUA_OK)
    {
        std::cerr << "Failed to load " << path << ": " << lua_tostring(m_luaState, -1) << "\n";
        lua_pop(m_luaState, 1);
    }
    else
    {
        std::cout << "Loaded script: " << path << "\n";
    }

    string thispath = path;
    m_scriptFiles.push_back(make_pair(func_name, thispath));
}

void ScriptingSystem::SortScripts()
{
    // Sort the script files by name
    std::sort(m_scriptFiles.begin(), m_scriptFiles.end(), [](const std::pair<std::string, std::string>& a, const std::pair<std::string, std::string>& b)
    {
        return a.first < b.first;
    });
}

string ScriptingSystem::CallScript(const std::string& func_name, const std::vector<lua_Integer>& args)
{
    // Check if the function is loaded
    bool valid = false;
    string path = "";
    for (auto& script : m_scriptFiles)
    {
        if (script.first == func_name)
        {
            valid = true;
            std::cout << "Calling script: " << script.second << "\n";
            path = script.second;
            break;
        }
    }

    if (!valid)
    {
        string error = "Function " + func_name + " not loaded.";
        std::cerr << error << "\n";
        return error;
    }

    LoadScript(path);

    // Check if there's an active coroutine for this script
    lua_State* co = nullptr;
    int co_ref = -1;
    auto it = m_activeCoroutines.find(func_name);
    if (it != m_activeCoroutines.end())
    {
        co_ref = it->second;
        lua_rawgeti(m_luaState, LUA_REGISTRYINDEX, co_ref);
        co = lua_tothread(m_luaState, -1);
        lua_pop(m_luaState, 1);

        // Check if the coroutine is still alive
        if (lua_status(co) != LUA_YIELD)
        {
            cout << string("Coroutine for " + func_name + " is dead; creating new one.") << endl;
            luaL_unref(m_luaState, LUA_REGISTRYINDEX, co_ref);
            m_activeCoroutines.erase(func_name);
            co = nullptr;
        }
    }

    // Create a new coroutine if none exists or the previous one is dead
    if (!co)
    {
        co = lua_newthread(m_luaState);
        co_ref = luaL_ref(m_luaState, LUA_REGISTRYINDEX);
        m_activeCoroutines[func_name] = co_ref;

        // Load the function in the coroutine
        lua_getglobal(co, func_name.c_str());
        if (!lua_isfunction(co, -1))
        {
            lua_pop(co, 1);
            luaL_unref(m_luaState, LUA_REGISTRYINDEX, co_ref);
            m_activeCoroutines.erase(func_name);
            return "Function " + func_name + " is not a function.";
        }

        for (lua_Integer arg : args)
        {
            lua_pushinteger(co, arg);
        }
    }
    else
    {
        // Resume the existing coroutine with new args
        for (lua_Integer arg : args)
        {
            lua_pushinteger(co, arg);
        }
    }

    // Start or resume the coroutine
    int nresults;
    int status = lua_resume(co, nullptr, args.size(), &nresults);
    if (status == LUA_YIELD)
    {
        cout << string("Lua script yielded: " + func_name) << endl;
        return "";
    }
    else if (status != LUA_OK)
    {
        const char* error = lua_tostring(co, -1);
        cout << string("Lua script error: " + string(error)) << endl;
        lua_pop(co, 1);
        luaL_unref(m_luaState, LUA_REGISTRYINDEX, co_ref);
        m_activeCoroutines.erase(func_name);
        return error;
    }

    // Script completed: Get return value
    string result = "";
    if (nresults > 0)
    {
        if (lua_isstring(co, -1))
        {
            result = lua_tostring(co, -1);
        }
        else if (lua_isboolean(co, -1))
        {
            result = lua_toboolean(co, -1) ? "true" : "false";
        }
        else if (lua_isnumber(co, -1))
        {
            result = std::to_string(lua_tointeger(co, -1));
        }
        lua_pop(co, nresults);
    }

    // Clean up
    luaL_unref(m_luaState, LUA_REGISTRYINDEX, co_ref);
    m_activeCoroutines.erase(func_name);
    return result;
}

void ScriptingSystem::RegisterScriptFunction(const std::string& name, lua_CFunction function)
{
    lua_register(m_luaState, name.c_str(), function);
    m_scriptLibrary[name] = function;
}

void ScriptingSystem::SetFlag(int flag_id, bool value)
{
    m_flags[flag_id] = value;
}

bool ScriptingSystem::GetFlag(int flag_id)
{
    auto it = m_flags.find(flag_id);
    return it != m_flags.end() ? it->second : false;
}