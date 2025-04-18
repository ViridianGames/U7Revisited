#include "ScriptingSystem.h"
#include "Config.h"
#include "Logging.h"
#include "Globals.h"
#include "raylib.h"
#include "raymath.h"

#include <fstream>
#include <sstream>
#include <iostream>

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
    if (luaL_dofile(m_luaState, path.c_str()) != LUA_OK)
    {
        std::cerr << "Failed to load " << path << ": " << lua_tostring(m_luaState, -1) << "\n";
        lua_pop(m_luaState, 1);
    }
}

void ScriptingSystem::CallScript(const std::string& func_name, const std::vector<lua_Integer>& args)
{
    lua_getglobal(m_luaState, func_name.c_str());
    if (lua_isfunction(m_luaState, -1))
    {
        for (lua_Integer arg : args)
        {
            lua_pushinteger(m_luaState, arg);
        }
        if (lua_pcall(m_luaState, args.size(), 0, 0) != LUA_OK)
        {
            std::cerr << "Error in " << func_name << ": " << lua_tostring(m_luaState, -1) << "\n";
            luaL_traceback(m_luaState, m_luaState, nullptr, 1);
            std::cerr << lua_tostring(m_luaState, -1) << "\n";
            lua_pop(m_luaState, 2);
        }
    }
    else
    {
        lua_pop(m_luaState, 1);
    }
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
    // Return false for uninitialized flags to match Usecode behavior
    auto it = m_flags.find(flag_id);
    return it != m_flags.end() ? it->second : false;
}