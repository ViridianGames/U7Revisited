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

// Lua wait function (unchanged)
static int LuaWait(lua_State *L)
{

    if (lua_gettop(L) != 1 || !lua_isnumber(L, 1))
    {
        luaL_error(L, "Expected one number argument (seconds)");
        return 0;
    }

    double delay = lua_tonumber(L, 1);
    if (delay < 0)
    {
        luaL_error(L, "Delay must be non-negative");
        return 0;
    }

    DebugPrint("LUA: wait called for " + to_string(delay) + " seconds");

    g_ScriptingSystem->m_waitTimer = (float)delay;
    g_ScriptingSystem->m_waitingScript = g_ScriptingSystem->m_currentScript;

    return lua_yield(L, 1);
}

// New: Lua converse function to start a conversation and yield until it finishes
static int LuaConverse(lua_State *L)
{
    if (lua_gettop(L) != 1 || !lua_isstring(L, 1))
    {
        DebugPrint("Calling lua_converse: Expected one string argument (func_name)");
        return 0;
    }

    std::string sub_func = lua_tostring(L, 1);

    std::string result = g_ScriptingSystem->CallScript(sub_func, {});

    if (result != "")
    {
        lua_pushstring(L, result.c_str());
        return 1;
    }

    DebugPrint("Calling lua_converse for function: " + sub_func);

    if (g_ScriptingSystem->IsCoroutineActive(sub_func))
    {
        std::string caller_func = g_ScriptingSystem->GetFuncNameFromCo(L);
        if (caller_func.empty())
        {
            DebugPrint("Converse must be called from a named scripted function");
            return 0;
        }

        g_ScriptingSystem->m_waiters[sub_func].push_back(caller_func);

        return lua_yield(L, 0);
    }
    else
    {
        lua_pushstring(L, "done");
        return 1;
    }
}

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
    RegisterScriptFunction("wait", LuaWait);
    RegisterScriptFunction("converse", LuaConverse); // New registration
}

void ScriptingSystem::Shutdown()
{
    // TODO: Save flags to file
}

void ScriptingSystem::Update()
{
    // Collect coroutines that are no longer yielded (completed or errored)
    std::vector<std::string> to_cleanup;
    for (const auto& pair : m_activeCoroutines)
    {
        lua_rawgeti(m_luaState, LUA_REGISTRYINDEX, pair.second);
        lua_State* co = lua_tothread(m_luaState, -1);
        lua_pop(m_luaState, 1);

        if (lua_status(co) != LUA_YIELD)
        {
            to_cleanup.push_back(pair.first);
        }
    }

    // Cleanup and potentially resume waiters
    for (const std::string& func : to_cleanup)
    {
        CleanupCoroutine(func);
    }

    if (m_waitTimer > 0.0f)
    {
        m_waitTimer -= GetFrameTime();
        if (m_waitTimer < 0.0f)
        {
            m_waitTimer = 0.0f;
            ResumeCoroutine(m_waitingScript, {0});
            //m_waitingScript = "";
        }
    }
}

void ScriptingSystem::LoadScript(const std::string& path)
{
    // (unchanged)
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
       stringstream st;
       st << "Failed to load " << path << ": " << lua_tostring(m_luaState, -1) << "\n";
       std::cerr << st.str();
        Log(st.str(), "debuglog.txt");
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
    // (unchanged)
    std::sort(m_scriptFiles.begin(), m_scriptFiles.end(), [](const std::pair<std::string, std::string>& a, const std::pair<std::string, std::string>& b)
    {
        return a.first < b.first;
    });
}

string ScriptingSystem::CallScript(const string& func_name, const vector<LuaArg>& args)
{
    // (mostly unchanged, but replace unref/erase with CleanupCoroutine)
    // Check if the function is loaded
    bool valid = false;
    string path = "";
    for (auto& script : m_scriptFiles)
    {
        if (script.first == func_name)
        {
            valid = true;
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
    m_currentScript = func_name;

    lua_State* co = nullptr;
    int co_ref = -1;
    auto it = m_activeCoroutines.find(func_name);
    if (it != m_activeCoroutines.end())
    {
        co_ref = it->second;
        lua_rawgeti(m_luaState, LUA_REGISTRYINDEX, co_ref);
        co = lua_tothread(m_luaState, -1);
        lua_pop(m_luaState, 1);

        if (lua_status(co) != LUA_YIELD)
        {
            CleanupCoroutine(func_name); // Changed
            co = nullptr;
        }
    }

    if (!co)
    {
        co = lua_newthread(m_luaState);
        co_ref = luaL_ref(m_luaState, LUA_REGISTRYINDEX);
        m_activeCoroutines[func_name] = co_ref;

        lua_getglobal(co, func_name.c_str());
        if (!lua_isfunction(co, -1))
        {
            lua_pop(co, 1);
            CleanupCoroutine(func_name); // Changed
            return "Function " + func_name + " is not a function.";
        }

        for (const auto& arg : args)
        {
            std::visit([&](const auto& value) {
                using T = std::decay_t<decltype(value)>;
                if constexpr (std::is_same_v<T, lua_Integer>) {
                    lua_pushinteger(co, value);
                } else if constexpr (std::is_same_v<T, std::string>) {
                    lua_pushstring(co, value.c_str());
                } else if constexpr (std::is_same_v<T, bool>) {
                    lua_pushboolean(co, value);
                }
            }, arg);
        }
    }
    else
    {
        for (const auto& arg : args)
        {
            std::visit([&](const auto& value) {
                using T = std::decay_t<decltype(value)>;
                if constexpr (std::is_same_v<T, lua_Integer>) {
                    lua_pushinteger(co, value);
                } else if constexpr (std::is_same_v<T, std::string>) {
                    lua_pushstring(co, value.c_str());
                } else if constexpr (std::is_same_v<T, bool>) {
                    lua_pushboolean(co, value);
                }
            }, arg);
        }
    }

    int nresults;
    int status = lua_resume(co, nullptr, args.size(), &nresults);
    if (status == LUA_YIELD)
    {
        return "";
    }
    else if (status != LUA_OK)
    {
        const char* error = lua_tostring(co, -1);
        lua_pop(co, 1);
        CleanupCoroutine(func_name); // Changed
        return error ? error : "Unknown error";
    }

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

    CleanupCoroutine(func_name); // Changed
    return result;
}

bool ScriptingSystem::IsCoroutineActive(const string& func_name) const
{
    return m_activeCoroutines.find(func_name) != m_activeCoroutines.end();
}

bool ScriptingSystem::IsCoroutineYielded(const string& func_name) const
{
    auto it = m_activeCoroutines.find(func_name);
    if (it == m_activeCoroutines.end())
        return false;

    lua_rawgeti(m_luaState, LUA_REGISTRYINDEX, it->second);
    lua_State* co = lua_tothread(m_luaState, -1);
    lua_pop(m_luaState, 1);
    return lua_status(co) == LUA_YIELD;
}

string ScriptingSystem::ResumeCoroutine(const string& func_name, const vector<LuaArg>& args)
{
    auto it = m_activeCoroutines.find(func_name);
    if (it == m_activeCoroutines.end())
        return "No active coroutine for " + func_name;

    lua_rawgeti(m_luaState, LUA_REGISTRYINDEX, it->second);
    lua_State* co = lua_tothread(m_luaState, -1);
    lua_pop(m_luaState, 1);

    if (lua_status(co) != LUA_YIELD)
    {
        CleanupCoroutine(func_name); // Changed
        return "Coroutine for " + func_name + " is not yielded.";
    }

    for (const auto& arg : args)
    {
        std::visit([&](const auto& value) {
            using T = std::decay_t<decltype(value)>;
            if constexpr (std::is_same_v<T, lua_Integer>) {
                lua_pushinteger(co, value);
            } else if constexpr (std::is_same_v<T, std::string>) {
                lua_pushstring(co, value.c_str());
            } else if constexpr (std::is_same_v<T, bool>) {
                lua_pushboolean(co, value);
            }
        }, arg);
    }

    int nresults;
    int status = lua_resume(co, nullptr, args.size(), &nresults);
    if (status == LUA_YIELD)
    {
        return "";
    }
    else if (status != LUA_OK)
    {
        const char* error = lua_tostring(co, -1);
        lua_pop(co, 1);
        CleanupCoroutine(func_name); // Changed
        return error ? error : "Unknown error";
    }

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

    CleanupCoroutine(func_name); // Changed
    return result;
}

void ScriptingSystem::CleanupCoroutine(const string& func_name)
{
    auto it = m_activeCoroutines.find(func_name);
    if (it != m_activeCoroutines.end())
    {
        luaL_unref(m_luaState, LUA_REGISTRYINDEX, it->second);
        m_activeCoroutines.erase(it);
    }

    // Resume any coroutines waiting on this one to complete
    auto wit = m_waiters.find(func_name);
    if (wit != m_waiters.end())
    {
        for (const std::string& waiter_name : wit->second)
        {
            auto w_it = m_activeCoroutines.find(waiter_name);
            if (w_it != m_activeCoroutines.end())
            {
                lua_rawgeti(m_luaState, LUA_REGISTRYINDEX, w_it->second);
                lua_State* co = lua_tothread(m_luaState, -1);
                lua_pop(m_luaState, 1);

                int nres;
                int status = lua_resume(co, nullptr, 0, &nres);
                if (status == LUA_ERRRUN)
                {
                    const char* err = lua_tostring(co, -1);
                    lua_pop(co, 1);
                    Log("Resume error in waiter " + waiter_name + ": " + (err ? err : "unknown"));
                    CleanupCoroutine(waiter_name);
                }
                else if (status == LUA_OK)
                {
                    // Waiter completed after resume
                    CleanupCoroutine(waiter_name);
                }
                // If still yielded, leave it active
            }
        }
        m_waiters.erase(wit);
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
    auto it = m_flags.find(flag_id);
    return it != m_flags.end() ? it->second : false;
}

void ScriptingSystem::SetAnswer(const std::string& answer)
{
    lua_getglobal(m_luaState, "answer");
    if (answer == "nil")
    {
        lua_pushnil(m_luaState);
    }
    else
    {
        lua_pushstring(m_luaState, answer.c_str());
    }
    lua_setglobal(m_luaState, "answer");
}

std::vector<std::string> ScriptingSystem::GetAnswers()
{
    std::vector<std::string> answers;
    lua_getglobal(m_luaState, "answers");
    if (lua_istable(m_luaState, -1))
    {
        lua_pushnil(m_luaState);
        while (lua_next(m_luaState, -2))
        {
            if (lua_isstring(m_luaState, -1))
            {
                answers.push_back(lua_tostring(m_luaState, -1));
            }
            lua_pop(m_luaState, 1);
        }
    }
    lua_pop(m_luaState, 1);
    return answers;
}

std::string ScriptingSystem::GetFuncNameFromCo(lua_State* co) const
{
    for (const auto& pair : m_activeCoroutines)
    {
        lua_rawgeti(m_luaState, LUA_REGISTRYINDEX, pair.second);
        lua_State* this_co = lua_tothread(m_luaState, -1);
        lua_pop(m_luaState, 1);
        if (this_co == co)
        {
            return pair.first;
        }
    }
    return "";
}