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
	//  Check if the function is loaded
	bool valid = false;
	string path = "";
	for(auto& script : m_scriptFiles)
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

	lua_getglobal(m_luaState, func_name.c_str());
	if (lua_isfunction(m_luaState, -1))
	{
		for (lua_Integer arg : args)
		{
			lua_pushinteger(m_luaState, arg);
		}
		if (lua_pcall(m_luaState, args.size(), 0, 0) != LUA_OK)
		{
			std::string error = lua_tostring(m_luaState, -1);
			//std::cerr << "Error in " << func_name << ": " << lua_tostring(m_luaState, -1) << "\n";
			luaL_traceback(m_luaState, m_luaState, error.c_str(), 1);
			//std::string traceback = "Error in " + func_name + ":" + lua_tostring(m_luaState, -1);
			std::cerr << error << "\n";
			lua_pop(m_luaState, 2);
			return error;
		}
	}
	else
	{
		lua_pop(m_luaState, 1);
	}
	return "";
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