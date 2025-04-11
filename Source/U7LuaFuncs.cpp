#include "U7LuaFuncs.h"
#include "U7Globals.h"
#include "Geist/ScriptingSystem.h"
#include <iostream>

using namespace std;

static int LuaSay(lua_State *L)
{
    const char *text = luaL_checkstring(L, 1);
    std::cout << "Script says: " << text << "\n"; // Temporary—Raylib later
    return 0;
}

static int LuaMove(lua_State *L)
{
    int x = luaL_checkinteger(L, 1);
    int y = luaL_checkinteger(L, 2);
    std::cout << "Move to (" << x << ", " << y << ")\n";
    return 0;
}

void RegisterAllLuaFunctions()
{
    g_ScriptingSystem->RegisterScriptFunction("say", LuaSay);
    g_ScriptingSystem->RegisterScriptFunction("move", LuaMove);
}
