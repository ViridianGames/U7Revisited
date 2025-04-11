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

// static int l_say(lua_State* L)
// {
// 	const char* message = luaL_checkstring(L, 1);
// 	printf("Lua says: %s\n", message);
// 	return 0;
// }

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

}

void ScriptingSystem::Shutdown()
{

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

void ScriptingSystem::CallScript(const std::string& func_name, int event)
{
    lua_getglobal(m_luaState, func_name.c_str());
    if (lua_isfunction(m_luaState, -1))
	{
        lua_pushinteger(m_luaState, event);
        if (lua_pcall(m_luaState, 1, 0, 0) != LUA_OK)
		{
            std::cerr << "Error in " << func_name << ": " << lua_tostring(m_luaState, -1) << "\n";
            lua_pop(m_luaState, 1);
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
