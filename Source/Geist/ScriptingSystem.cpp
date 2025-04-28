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
#include <filesystem>

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

bool ScriptingSystem::LoadScript(const std::string& scriptName)
{
	std::string fullPath = scriptName;
	// Ensure using consistent path separators if needed, although filesystem::path should handle it

	// Check if script is already loaded by path
	for (const auto& pair : m_scriptFiles)
	{
		if (pair.first == fullPath)
		{
			Log("Script already loaded: " + fullPath, LOG_DEBUG);
			return true; // Already loaded, treat as success
		}
	}

	// Attempt to load the script file
	if (luaL_dofile(m_luaState, fullPath.c_str()) != LUA_OK)
	{
		m_lastError = lua_tostring(m_luaState, -1); // Store the error message
		lua_pop(m_luaState, 1); // Pop the error message from the stack
		// Log is now handled by AddAssetError in Main.cpp
		// Log("Failed to load " + fullPath + ": " + m_lastError, LOG_ERROR);
		return false; // Signal failure
	}

	// If successful, add to the list
	// Extract just the filename part for lookup? Or keep full path?
	// Let's keep the full path for consistency and the filename for potential lookup needs.
	std::filesystem::path p(fullPath);
	std::string filename = p.filename().string();
	m_scriptFiles.push_back({fullPath, filename});
	Log("Loaded script: " + fullPath, LOG_INFO);
	m_lastError.clear(); // Clear last error on success
	return true;
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