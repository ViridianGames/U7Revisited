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
    cout << "Lua says: " << luaL_checkstring(L, 1) << "\n";
    const char* text = luaL_checkstring(L, 1);

    g_StateMachine->PushState(STATE_CONVERSATIONSTATE);
    g_ConversationState->AddDialogue(text);

    return 0;
}

static int LuaBark(lua_State* L)
{
    const char* text = luaL_checkstring(L, 1);
    int x = luaL_checkinteger(L, 2);
    int y = luaL_checkinteger(L, 3);
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
    //g_ConversationState->SetNPC(luaL_checkinteger(L, 1));
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
    //int unknown = luaL_checkinteger(L, 2); // Placeholder
    cout << "Switching talk to NPC ID: " << npc_id << "\n";
    //g_ConversationState->SetNPC(npc_id);
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
    //int npc_id = luaL_checkinteger(L, 1);
    //lua_getglobal(L, "party_members"); // Assume table from get_party_members
    //bool is_member = false; // TODO: Check if npc_id is in party_members
    //cout << "Checking if NPC ID " << npc_id << " is party member\n";
    lua_pushboolean(L, false);
    return 1;
}

static int LuaTriggerFerry(lua_State* L)
{
    int object_id = luaL_checkinteger(L, 1);
    cout << "Triggering ferry for object ID: " << object_id << "\n";
    // TODO: Start ferry transport (e.g., scene change to Skara Brae or mainland)
    return 0;
}

static int LuaAddAnswer(lua_State* L) {
    // Check stack for input argument
    if (lua_gettop(L) < 1) {
        return luaL_error(L, "Expected at least one argument");
    }

    // Get or create global answers table
    lua_getglobal(L, "answers");
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "answers");
        lua_getglobal(L, "answers");
    }
    if (!lua_istable(L, -1)) {
        return luaL_error(L, "Failed to create answers table");
    }

    // Store answers table index
    int answers_idx = lua_gettop(L);
    int len = lua_rawlen(L, answers_idx);

    // Check type of first argument
    int type = lua_type(L, 1);
    if (type == LUA_TSTRING) {
        // Single string: add it directly
        const char* answer = luaL_checkstring(L, 1);
        lua_pushstring(L, answer);
        if (!lua_istable(L, answers_idx)) {
            return luaL_error(L, "Answers table lost at index %d", answers_idx);
        }
        lua_rawseti(L, answers_idx, len + 1);
        std::cout << "Added answer: " << answer << "\n";
    } else if (type == LUA_TTABLE) {
        // Table: iterate over elements and add strings
        int table_len = lua_rawlen(L, 1);
        for (int i = 1; i <= table_len; ++i) {
            lua_rawgeti(L, 1, i); // Push table[i]
            if (lua_isstring(L, -1)) {
                const char* answer = lua_tostring(L, -1);
                lua_pushstring(L, answer); // Push copy for answers table
                if (!lua_istable(L, answers_idx)) {
                    return luaL_error(L, "Answers table lost at index %d", answers_idx);
                }
                lua_rawseti(L, answers_idx, len + 1);
                len++; // Increment for next insertion
                std::cout << "Added answer: " << answer << "\n";
            } else {
                std::cout << "Warning: Non-string element at index " << i << " ignored\n";
            }
            lua_pop(L, 1); // Pop table[i]
        }
    } else {
        return luaL_error(L, "Expected string or table, got %s", lua_typename(L, type));
    }

    // Clean up: pop answers table
    lua_pop(L, 1);
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

static int LuaGetItemType(lua_State* L) {
    int item_id = luaL_checkinteger(L, 1);
    int type = 0; // TODO: g_ItemManager->GetItemType(item_id)
    lua_pushinteger(L, type);
    return 1;
}

static int LuaGetItemFrame(lua_State* L) {
    int item_id = luaL_checkinteger(L, 1);
    int frame = 0; // TODO: g_ItemManager->GetItemFrame(item_id)
    lua_pushinteger(L, frame);
    return 1;
}

static int LuaSetItemFrame(lua_State* L) {
    int item_id = luaL_checkinteger(L, 1);
    int frame = luaL_checkinteger(L, 2);
    // TODO: g_ItemManager->SetItemFrame(item_id, frame)
    return 0;
}

static int LuaGetItemQuality(lua_State* L) {
    int item_id = luaL_checkinteger(L, 1);
    int quality = 0; // TODO: g_ItemManager->GetItemQuality(item_id)
    lua_pushinteger(L, quality);
    return 1;
}

static int LuaSetItemQuality(lua_State* L) {
    int item_id = luaL_checkinteger(L, 1);
    int quality = luaL_checkinteger(L, 2);
    // TODO: g_ItemManager->SetItemQuality(item_id, quality)
    return 0;
}

static int LuaGetItemInfo(lua_State* L) {
    int item_id = luaL_checkinteger(L, 1);
    lua_newtable(L);
    // TODO: Push x, y, z coordinates or other attributes
    return 1;
}

static int LuaGetContainerItems(lua_State* L) {
    int container_id = luaL_checkinteger(L, 1);
    int type = luaL_checkinteger(L, 2);
    int x = luaL_checkinteger(L, 3);
    int y = luaL_checkinteger(L, 4);
    lua_newtable(L);
    // TODO: Push list of item IDs
    return 1;
}

static int LuaRemoveItem(lua_State* L) {
    int item_id = luaL_checkinteger(L, 1);
    // TODO: g_ItemManager->RemoveItem(item_id)
    return 0;
}

static int LuaGetDistance(lua_State* L) {
    int obj1_id = luaL_checkinteger(L, 1);
    int obj2_id = luaL_checkinteger(L, 2);
    int distance = 0; // TODO: g_World->GetDistance(obj1_id, obj2_id)
    lua_pushinteger(L, distance);
    return 1;
}

static int LuaPlayMusic(lua_State* L) {
    int track = luaL_checkinteger(L, 1);
    int loop = luaL_checkinteger(L, 2);
    // TODO: g_AudioSystem->PlayMusic(track, loop)
    return 0;
}

static int LuaSetItemState(lua_State* L) {
    int item_id = luaL_checkinteger(L, 1);
    // TODO: g_ItemManager->SetItemState(item_id)
    return 0;
}

static int LuaGetWearer(lua_State* L) {
    int item_id = luaL_checkinteger(L, 1);
    int wearer_id = 0; // TODO: g_ItemManager->GetWearer(item_id)
    lua_pushinteger(L, wearer_id);
    return 1;
}

static int LuaGetItemShape(lua_State* L) {
    int item_id = luaL_checkinteger(L, 1);
    int shape = 0; // TODO: g_ItemManager->GetItemShape(item_id)
    lua_pushinteger(L, shape);
    return 1;
}

static int LuaCheckItemState(lua_State* L) {
    int item_id = luaL_checkinteger(L, 1);
    int state = 0; // TODO: g_ItemManager->CheckItemState(item_id)
    lua_pushinteger(L, state);
    return 1;
}

static int LuaFindItems(lua_State* L) {
    int obj_id = luaL_checkinteger(L, 1);
    int type = luaL_checkinteger(L, 2);
    int distance = luaL_checkinteger(L, 3);
    int flags = luaL_checkinteger(L, 4);
    lua_newtable(L);
    // TODO: g_World->FindItems(obj_id, type, distance, flags)
    return 1;
}

static int LuaApplyEffect(lua_State* L) {
    int obj_id = luaL_checkinteger(L, 1);
    int effect = luaL_checkinteger(L, 2);
    // TODO: g_EffectSystem->ApplyEffect(obj_id, effect)
    return 0;
}

static int LuaGetLordOrLady(lua_State* L)
{
    int lord_or_lady = 0; // TODO: g_Player->GetLordOrLady()
    if (g_Player->GetIsMale())
    {
        lua_pushstring(L, "Milord");
    } else
    {
        lua_pushstring(L, "Milady");
    }
    return 0;
}

static int LuaIsAvatarFemale(lua_State* L)
{
    lua_pushboolean(L, !g_Player->GetIsMale());
    return 0;
}

//  TODO:  This is a placeholder function.  It should check if a certain character is in the party.
static int LuaIsInParty(lua_State* L)
{
    int obj_id = luaL_checkinteger(L, 1);
    lua_pushboolean(L, false);
    return 0;
}

void RegisterAllLuaFunctions()
{
    cout << "Registering Lua functions\n";
    g_ScriptingSystem->RegisterScriptFunction("say", LuaSay);
    g_ScriptingSystem->RegisterScriptFunction("bark", LuaSay);
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
    g_ScriptingSystem->RegisterScriptFunction("get_item_type", LuaGetItemType);
    g_ScriptingSystem->RegisterScriptFunction("get_item_frame", LuaGetItemFrame);
    g_ScriptingSystem->RegisterScriptFunction("set_item_frame", LuaSetItemFrame);
    g_ScriptingSystem->RegisterScriptFunction("get_item_quality", LuaGetItemQuality);
    g_ScriptingSystem->RegisterScriptFunction("get_item_frame", LuaSetItemQuality);
    g_ScriptingSystem->RegisterScriptFunction("get_item_info", LuaGetItemInfo);    
    g_ScriptingSystem->RegisterScriptFunction("get_container_items", LuaGetContainerItems);    
    g_ScriptingSystem->RegisterScriptFunction("remove_item", LuaRemoveItem);
    g_ScriptingSystem->RegisterScriptFunction("get_distance", LuaGetDistance);
    g_ScriptingSystem->RegisterScriptFunction("play_music", LuaPlayMusic);
    g_ScriptingSystem->RegisterScriptFunction("set_item_state", LuaSetItemState);
    g_ScriptingSystem->RegisterScriptFunction("get_wearer", LuaGetWearer);
    g_ScriptingSystem->RegisterScriptFunction("get_item_shape", LuaGetItemShape);
    g_ScriptingSystem->RegisterScriptFunction("check_item_state", LuaCheckItemState);
    g_ScriptingSystem->RegisterScriptFunction("find_items", LuaFindItems);
    g_ScriptingSystem->RegisterScriptFunction("apply_effect", LuaApplyEffect);
    g_ScriptingSystem->RegisterScriptFunction("get_lord_or_lady", LuaGetLordOrLady);
    g_ScriptingSystem->RegisterScriptFunction("get_is_female_avatar", LuaIsAvatarFemale);
    g_ScriptingSystem->RegisterScriptFunction("is_in_party", LuaIsInParty);

    cout << "Registered all Lua functions\n";
}
