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
#include <variant> // For flexible argument types

class Config;

class ScriptingSystem : public Object
{
public:
    using LuaArg = std::variant<lua_Integer, std::string, bool>; // Support integers, strings, booleans

    ScriptingSystem();
    ~ScriptingSystem();

    virtual void Init(const std::string& configfile);
    virtual void Shutdown();
    virtual void Update();
    void Draw() {};

    void LoadScript(const std::string& path);
    void SortScripts();
    void RegisterScriptFunction(const std::string& name, lua_CFunction function);
    std::string CallScript(const std::string& func_name, const std::vector<LuaArg>& args);

    // New coroutine management methods
    bool IsCoroutineActive(const std::string& func_name) const;
    bool IsCoroutineYielded(const std::string& func_name) const;
    std::string ResumeCoroutine(const std::string& func_name, const std::vector<LuaArg>& args);
    void CleanupCoroutine(const std::string& func_name);

    // Flag management
    void SetFlag(int flag_id, bool value);
    bool GetFlag(int flag_id);

    // Conversation management
    void SetAnswer(const std::string& answer);
    std::vector<std::string> GetAnswers();

    // New: Get func_name from a coroutine state (for waiter identification)
    std::string GetFuncNameFromCo(lua_State* co) const;

    lua_State* m_luaState = nullptr;
    std::unordered_map<std::string, lua_CFunction> m_scriptLibrary;
    std::unordered_map<int, bool> m_flags;
    std::string m_currentScript;

    std::vector<std::pair<std::string, std::string>> m_scriptFiles;
    std::unordered_map<std::string, int> m_activeCoroutines; // Store coroutine references

    // New: Map for coroutines waiting on other coroutines to complete (sub_func -> list of waiter funcs)
    std::unordered_map<std::string, std::vector<std::string>> m_waiters;

    // Per-script wait timers (each script can wait independently)
    std::unordered_map<std::string, float> m_waitTimers;

    // Track when each script started executing to detect lockups
    std::unordered_map<std::string, float> m_scriptStartTime;

    // Max time a script can run without yielding (in seconds)
    static constexpr float MAX_SCRIPT_TIME = 0.1f;  // 100ms

};

#endif