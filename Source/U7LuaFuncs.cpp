#include "U7LuaFuncs.h"
#include "U7Globals.h"
#include "Geist/ScriptingSystem.h"
#include "Geist/StateMachine.h"
#include "ConversationState.h"
#include <iostream>
#include <cstring>

using namespace std;

static int LuaSay(lua_State* L)
{
    cout << "Lua says: " << luaL_checkstring(L, 2) << "\n";
    const char* text = luaL_checkstring(L, 2);

    g_StateMachine->PushState(STATE_CONVERSATIONSTATE);
    g_ConversationState->SetNPC(luaL_checkinteger(L, 1));
    g_ConversationState->AddDialogue(text);

    return 0;
}

static int LuaMove(lua_State* L)
{
    int x = luaL_checkinteger(L, 1);
    int y = luaL_checkinteger(L, 2);
    cout << "Move to (" << x << ", " << y << ")\n";
    // TODO: Implement object movement
    return 0;
}

static int LuaStartConversation(lua_State* L)
{
    if (g_StateMachine->GetCurrentState() == STATE_CONVERSATIONSTATE)
    {
        return 0;
    }

    g_StateMachine->PushState(STATE_CONVERSATIONSTATE);
    g_ConversationState->SetNPC(luaL_checkinteger(L, 1));
    return 0;
}

static int LuaGetFlag(lua_State* L)
{
    int flag_id = luaL_checkinteger(L, 1);
    bool value = g_ScriptingSystem->GetFlag(flag_id);
    lua_pushboolean(L, value);
    return 1;
}

static int LuaSetFlag(lua_State* L)
{
    int flag_id = luaL_checkinteger(L, 1);
    bool value = lua_toboolean(L, 2);
    g_ScriptingSystem->SetFlag(flag_id, value);
    return 0;
}

static int LuaGetPlayerName(lua_State* L)
{
    const char* player_name = "Avatar"; // TODO: g_Player->GetName()
    if (player_name && player_name[0] != '\0')
    {
        lua_pushstring(L, player_name);
    }
    else
    {
        lua_pushstring(L, "Avatar");
    }
    return 1;
}

static int LuaHasItem(lua_State* L)
{
    int item_id = luaL_checkinteger(L, 1);
    bool has_item = false; // TODO: g_Player->HasItem(item_id)
    lua_pushboolean(L, has_item);
    return 1;
}

static int LuaIsPlayerFemale(lua_State* L)
{
    bool is_female = false; // TODO: g_Player->IsFemale()
    lua_pushboolean(L, is_female);
    return 1;
}

static int LuaGetStat(lua_State* L)
{
    int object_id = luaL_checkinteger(L, 1);
    int stat_id = luaL_checkinteger(L, 2);
    int value = 0; // TODO: g_Player->GetStat(object_id, stat_id)
    lua_pushinteger(L, value);
    return 1;
}

static int LuaSetStat(lua_State* L)
{
    int object_id = luaL_checkinteger(L, 1);
    int stat_id = luaL_checkinteger(L, 2);
    int value = luaL_checkinteger(L, 3);
    // TODO: g_Player->SetStat(object_id, stat_id, value)
    return 0;
}

static int LuaGetAnswer(lua_State* L)
{
    lua_getglobal(L, "answers");
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        lua_pushinteger(L, 0);
        return 1;
    }

    lua_getglobal(L, "answer");
    const char* selected_answer = lua_tostring(L, -1);
    lua_pop(L, 1);

    if (selected_answer) {
        for (int i = 1; i <= lua_rawlen(L, -1); i++) {
            lua_rawgeti(L, -1, i);
            if (strcmp(lua_tostring(L, -1), selected_answer) == 0) {
                lua_pop(L, 2); // Pop answer and answers table
                lua_pushinteger(L, i);
                return 1;
            }
            lua_pop(L, 1);
        }
    }

    lua_pop(L, 1); // Pop answers table
    lua_pushinteger(L, 0);
    return 1;
}

static int LuaSaveAnswers(lua_State* L)
{
    // TODO: Save answers table to a stack or temporary storage
    cout << "Saving answers\n";
    return 0;
}

static int LuaRestoreAnswers(lua_State* L)
{
    // TODO: Restore answers table from storage
    cout << "Restoring answers\n";
    return 0;
}

static int LuaBuyItem(lua_State* L)
{
    const char* prefix = luaL_checkstring(L, 1);
    int item_id = luaL_checkinteger(L, 2);
    int quantity = luaL_checkinteger(L, 3);
    int price = luaL_checkinteger(L, 4);
    const char* item_name = luaL_checkstring(L, 5);
    int result = 0; // 1=success, 2=can't carry, 3=no gold

    if (g_Player->GetGold() >= price * quantity && g_Player->CanCarry(item_id, quantity)) {
        g_Player->AddItem(item_id, quantity);
        g_Player->SpendGold(price * quantity);
        result = 1;
    } else if (!g_Player->CanCarry(item_id, quantity)) {
        result = 2;
    } else {
        result = 3;
    }

    lua_pushinteger(L, result);
    return 1;
}

static int LuaGetGold(lua_State* L)
{
    int gold = 0; // TODO: g_Player->GetGold()
    lua_pushinteger(L, gold);
    return 1;
}

static int LuaSpendGold(lua_State* L)
{
    int amount = luaL_checkinteger(L, 1);
    bool success = g_Player->GetGold() >= amount;
    if (success) {
        g_Player->SpendGold(amount);
    }
    lua_pushboolean(L, success);
    return 1;
}

static int LuaSwitchTalkTo(lua_State* L)
{
    int npc_id = luaL_checkinteger(L, 1);
    int unknown = luaL_checkinteger(L, 2); // Placeholder
    cout << "Switching talk to NPC ID: " << npc_id << "\n";
    // TODO: Set conversation focus to npc_id
    return 0;
}

static int LuaHideNPC(lua_State* L)
{
    int npc_id = luaL_checkinteger(L, 1);
    cout << "Hiding NPC ID: " << npc_id << "\n";
    // TODO: Hide NPC from conversation
    return 0;
}

static int LuaGetPartyMember(lua_State* L)
{
    int index = luaL_checkinteger(L, 1);
    int npc_id = 0; // TODO: Return NPC ID for party member at index (e.g., -2=Shamino)
    cout << "Getting party member at index: " << index << "\n";
    lua_pushinteger(L, npc_id);
    return 1;
}

static int LuaGetPartyMembers(lua_State* L)
{
    // TODO: Return list of party member IDs
    lua_newtable(L);
    cout << "Getting party members\n";
    return 1;
}

static int LuaIsPartyMember(lua_State* L)
{
    int npc_id = luaL_checkinteger(L, 1);
    lua_getglobal(L, "party_members"); // Assume table from get_party_members
    bool is_member = false; // TODO: Check if npc_id is in party_members
    cout << "Checking if NPC ID " << npc_id << " is party member\n";
    lua_pushboolean(L, is_member);
    return 1;
}

static int LuaTriggerFerry(lua_State* L)
{
    int object_id = luaL_checkinteger(L, 1);
    cout << "Triggering ferry for object ID: " << object_id << "\n";
    // TODO: Start ferry transport (e.g., scene change to Skara Brae or mainland)
    return 0;
}

static int LuaAddAnswer(lua_State* L)
{
    const char* answer = luaL_checkstring(L, 1);
    lua_getglobal(L, "answers");
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "answers");
        lua_getglobal(L, "answers");
    }

    int len = lua_rawlen(L, -1);
    lua_pushstring(L, answer);
    lua_rawseti(L, -2, len + 1);
    lua_pop(L, 1); // Pop answers table
    cout << "Added answer: " << answer << "\n";
    return 0;
}

static int LuaRemoveAnswer(lua_State* L)
{
    const char* answer = luaL_checkstring(L, 1);
    lua_getglobal(L, "answers");
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        return 0;
    }

    int len = lua_rawlen(L, -1);
    lua_newtable(L); // New answers table
    int new_index = 1;

    for (int i = 1; i <= len; i++) {
        lua_rawgeti(L, -2, i);
        const char* current = lua_tostring(L, -1);
        if (current && strcmp(current, answer) != 0) {
            lua_pushstring(L, current);
            lua_rawseti(L, -3, new_index);
            new_index++;
        }
        lua_pop(L, 1);
    }

    lua_setglobal(L, "answers");
    lua_pop(L, 1); // Pop old answers table
    cout << "Removed answer: " << answer << "\n";
    return 0;
}

void RegisterAllLuaFunctions()
{
    cout << "Registering Lua functions\n";
    g_ScriptingSystem->RegisterScriptFunction("say", LuaSay);
    g_ScriptingSystem->RegisterScriptFunction("move", LuaMove);
    g_ScriptingSystem->RegisterScriptFunction("StartConversation", LuaStartConversation);
    g_ScriptingSystem->RegisterScriptFunction("get_flag", LuaGetFlag);
    g_ScriptingSystem->RegisterScriptFunction("set_flag", LuaSetFlag);
    g_ScriptingSystem->RegisterScriptFunction("get_player_name", LuaGetPlayerName);
    g_ScriptingSystem->RegisterScriptFunction("has_item", LuaHasItem);
    g_ScriptingSystem->RegisterScriptFunction("is_player_female", LuaIsPlayerFemale);
    g_ScriptingSystem->RegisterScriptFunction("get_stat", LuaGetStat);
    g_ScriptingSystem->RegisterScriptFunction("set_stat", LuaSetStat);
    g_ScriptingSystem->RegisterScriptFunction("get_answer", LuaGetAnswer);
    g_ScriptingSystem->RegisterScriptFunction("buy_item", LuaBuyItem);
    g_ScriptingSystem->RegisterScriptFunction("save_answers", LuaSaveAnswers);
    g_ScriptingSystem->RegisterScriptFunction("restore_answers", LuaRestoreAnswers);
    g_ScriptingSystem->RegisterScriptFunction("get_gold", LuaGetGold);
    g_ScriptingSystem->RegisterScriptFunction("spend_gold", LuaSpendGold);
    g_ScriptingSystem->RegisterScriptFunction("switch_talk_to", LuaSwitchTalkTo);
    g_ScriptingSystem->RegisterScriptFunction("hide_npc", LuaHideNPC);
    g_ScriptingSystem->RegisterScriptFunction("get_party_member", LuaGetPartyMember);
    g_ScriptingSystem->RegisterScriptFunction("get_party_members", LuaGetPartyMembers);
    g_ScriptingSystem->RegisterScriptFunction("is_party_member", LuaIsPartyMember);
    g_ScriptingSystem->RegisterScriptFunction("trigger_ferry", LuaTriggerFerry);
    g_ScriptingSystem->RegisterScriptFunction("add_answer", LuaAddAnswer);
    g_ScriptingSystem->RegisterScriptFunction("remove_answer", LuaRemoveAnswer);
    cout << "Registered all Lua functions\n";
}