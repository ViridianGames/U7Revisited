#include "U7LuaFuncs.h"
#include "U7Globals.h"
#include "Geist/ScriptingSystem.h"
#include "Geist/StateMachine.h"
#include "ConversationState.h"
#include <iostream>

using namespace std;

static int LuaSay(lua_State *L)
{
    cout << "Lua says: " << luaL_checkstring(L, 2) << "\n";
    const char *text = luaL_checkstring(L, 2);

    g_StateMachine->PushState(STATE_CONVERSATIONSTATE);
    g_ConversationState->SetNPC(luaL_checkinteger(L, 1));
    g_ConversationState->AddDialogue(text);

    return 0;
}

static int LuaMove(lua_State *L)
{
    int x = luaL_checkinteger(L, 1);
    int y = luaL_checkinteger(L, 2);
    std::cout << "Move to (" << x << ", " << y << ")\n";
    return 0;
}

static int StartConversation(lua_State *L)
{
    if(g_StateMachine->GetCurrentState() == STATE_CONVERSATIONSTATE)
        return 0;

    g_StateMachine->PushState(STATE_CONVERSATIONSTATE);
    g_ConversationState->SetNPC(luaL_checkinteger(L, 1));
    return 0;
}

void RegisterAllLuaFunctions()
{
    g_ScriptingSystem->RegisterScriptFunction("say", LuaSay);
    g_ScriptingSystem->RegisterScriptFunction("move", LuaMove);
    g_ScriptingSystem->RegisterScriptFunction("StartConversation", StartConversation);
}
