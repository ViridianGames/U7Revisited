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
#include <vector>
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

    void LoadScript(const std::string& path);
    void SortScripts();
    void RegisterScriptFunction(const std::string& name, lua_CFunction function);
    std::string CallScript(const std::string& func_name, const std::vector<lua_Integer>& args);

    // Flag management
    void SetFlag(int flag_id, bool value);
    bool GetFlag(int flag_id);

    lua_State* m_luaState = nullptr;
    std::unordered_map<std::string, lua_CFunction> m_scriptLibrary;
    std::unordered_map<int, bool> m_flags;

    std::vector<std::pair<std::string, std::string> > m_scriptFiles;
    std::unordered_map<std::string, int> m_activeCoroutines;  // Store coroutine references
};

#endif