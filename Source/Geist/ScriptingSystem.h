///////////////////////////////////////////////////////////////////////////
//
// Name:     ScriptingSystem.H
// Author:   Anthony Salter
// Date:     04/07/2025
// Purpose:  Systems that handles running Lua scripts on in-game objects.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _SCRIPTINGSYSTEM_H_
#define _SCRIPTINGSYSTEM_H_

#include "Object.h"
#include "RaylibModel.h"
#include "raylib.h"
#include "lua.hpp"
#include <unordered_map>
#include <string>

#include <memory>
#include <map>

class Config;

class ScriptingSystem : public Object
{
public:
	ScriptingSystem();
	~ScriptingSystem();

	virtual void Init(const std::string& configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw() {};

	// Register a C++ function to be called from the Lua script "name"
	void LoadScript(const std::string& path);
	void RegisterScriptFunction(const std::string& name, lua_CFunction function);
	void CallScript(const std::string& func_name, int event);

	lua_State* m_luaState = nullptr;
	std::unordered_map<std::string, lua_CFunction> m_scriptLibrary;
};

#endif