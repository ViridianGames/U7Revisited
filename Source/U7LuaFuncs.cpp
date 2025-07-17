#include "U7LuaFuncs.h"
#include "U7Globals.h"
#include "Geist/ScriptingSystem.h"
#include "Geist/StateMachine.h"
#include "ConversationState.h"
#include <iostream>
#include <cstring>

extern "C"
{
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

using namespace std;

// '-' - Function stubbed but not implemented
// '+' - Function implemented

static int LuaDebugPrint(lua_State *L)
{
    const char *text = luaL_checkstring(L, 1);
    cout << "Lua console: " << text << "\n";
    if (g_LuaDebug) AddConsoleString(text, Color{255, 255, 255, 255});
    return 0;
}

static int LuaAddDialogue(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    cout << "Lua says: " << luaL_checkstring(L, 1) << "\n";
    const char *text = luaL_checkstring(L, 1);

    ConversationState::ConversationStep step;
    step.type = ConversationState::ConversationStepType::STEP_ADD_DIALOGUE;
    step.dialog = text;
    step.npcId = 0;
    step.frame = 0;
    g_ConversationState->AddStep(step);

    return 0;
}

// Opcode 0033
static int LuaStartConversation(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: start_conversation called");
    g_StateMachine->PushState(STATE_CONVERSATIONSTATE);
    return 0;
}

// Opcode 0003
static int LuaSwitchTalkTo(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    int npc_id = luaL_checkinteger(L, 1);
    int frame = 0;
    if (lua_gettop(L) > 1)
    {
        frame = luaL_checkinteger(L, 2);
    }
    if (g_LuaDebug) AddConsoleString("LUA: switch_talk_to called with " + std::to_string(npc_id));
    ConversationState::ConversationStep step;
    step.type = ConversationState::ConversationStepType::STEP_CHANGE_PORTRAIT;
    step.dialog = "";
    step.npcId = npc_id;
    step.frame = frame;
    g_ConversationState->AddStep(step);
    cout << "Switching talk to NPC ID: " << npc_id << "\n";

    return 0;
}

// Opcode 0004
static int LuaHideNPC(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) AddConsoleString("LUA: hide_npc called");
    int npc_id = luaL_checkinteger(L, 1);
    //g_ConversationState->SetNPC(npc_id, -1);
    cout << "Hiding NPC ID: " << npc_id << "\n";

    return 0;
}

// Opcode 0005
// Adds a list of answers to the conversation system. The list can just be one answer.
static int LuaAddAnswers(lua_State *L)
{
    if (!g_ConversationState)
    {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) AddConsoleString("LUA: add_answers called");
    // Check stack for input argument
    if (lua_gettop(L) < 1)
    {
        return luaL_error(L, "Expected at least one argument");
    }

    // Get or create global answers table
    lua_getglobal(L, "answers");
    if (!lua_istable(L, -1))
    {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "answers");
        lua_getglobal(L, "answers");
    }
    if (!lua_istable(L, -1))
    {
        return luaL_error(L, "Failed to create answers table");
    }

    // Store answers table index
    int answers_idx = lua_gettop(L);
    int len = lua_rawlen(L, answers_idx);

    // Check type of first argument
    int type = lua_type(L, 1);
    if (type == LUA_TSTRING)
    {
        // Single string: add it directly
        const char *answer = luaL_checkstring(L, 1);
        lua_pushstring(L, answer);
        if (!lua_istable(L, answers_idx))
        {
            return luaL_error(L, "Answers table lost at index %d", answers_idx);
        }
        lua_rawseti(L, answers_idx, len + 1);
        g_ConversationState->AddAnswer(answer);
        std::cout << "Added answer: " << answer << "\n";
    }
    else if (type == LUA_TTABLE)
    {
        // Table: iterate over elements and add strings
        int table_len = lua_rawlen(L, 1);
        for (int i = 1; i <= table_len; ++i)
        {
            lua_rawgeti(L, 1, i); // Push table[i]
            if (lua_isstring(L, -1))
            {
                const char *answer = lua_tostring(L, -1);
                lua_pushstring(L, answer); // Push copy for answers table
                if (!lua_istable(L, answers_idx))
                {
                    return luaL_error(L, "Answers table lost at index %d", answers_idx);
                }
                g_ConversationState->AddAnswer(answer);
                lua_rawseti(L, answers_idx, len + 1);
                len++; // Increment for next insertion
                std::cout << "Added answer: " << answer << "\n";
            }
            else
            {
                std::cout << "Warning: Non-string element at index " << i << " ignored\n";
            }
            lua_pop(L, 1); // Pop table[i]
        }
    }
    else
    {
        return luaL_error(L, "Expected string or table, got %s", lua_typename(L, type));
    }

    // Clean up: pop answers table
    lua_pop(L, 1);
    return 0;
}

// Opcode 0006
// Removes a list of answers from the conversation system. The list can be just one answer.
static int LuaRemoveAnswers(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) AddConsoleString("LUA: remove_answers called");
    // Check stack for input argument
    if (lua_gettop(L) < 1)
    {
        return luaL_error(L, "Expected at least one argument");
    }

    // Get or create global answers table
    lua_getglobal(L, "answers");
    if (!lua_istable(L, -1))
    {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "answers");
        lua_getglobal(L, "answers");
    }
    if (!lua_istable(L, -1))
    {
        return luaL_error(L, "Failed to create answers table");
    }

    // Store answers table index
    int answers_idx = lua_gettop(L);
    int len = lua_rawlen(L, answers_idx);

    // Check type of first argument
    int type = lua_type(L, 1);
    if (type == LUA_TSTRING)
    {
        // Single string: add it directly
        const char *answer = luaL_checkstring(L, 1);
        lua_pushstring(L, answer);
        if (!lua_istable(L, answers_idx))
        {
            return luaL_error(L, "Answers table lost at index %d", answers_idx);
        }
        lua_rawseti(L, answers_idx, len + 1);
        g_ConversationState->RemoveAnswer(answer);
        std::cout << "Removed answer: " << answer << "\n";
    }
    else if (type == LUA_TTABLE)
    {
        // Table: iterate over elements and add strings
        int table_len = lua_rawlen(L, 1);
        for (int i = 1; i <= table_len; ++i)
        {
            lua_rawgeti(L, 1, i); // Push table[i]
            if (lua_isstring(L, -1))
            {
                const char *answer = lua_tostring(L, -1);
                lua_pushstring(L, answer); // Push copy for answers table
                if (!lua_istable(L, answers_idx))
                {
                    return luaL_error(L, "Answers table lost at index %d", answers_idx);
                }
                g_ConversationState->RemoveAnswer(answer);
                lua_rawseti(L, answers_idx, len + 1);
                len++; // Increment for next insertion
                std::cout << "Remove answer: " << answer << "\n";
            }
            else
            {
                std::cout << "Warning: Non-string element at index " << i << " ignored\n";
            }
            lua_pop(L, 1); // Pop table[i]
        }
    }
    else
    {
        return luaL_error(L, "Expected string or table, got %s", lua_typename(L, type));
    }

    // Clean up: pop answers table
    lua_pop(L, 1);
    return 0;
}

// Opcode 0007
static int LuaSaveAnswers(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) AddConsoleString("LUA: save_answers called");
    g_ConversationState->SaveAnswers();
    cout << "Saving answers\n";
    return 0;
}

// Opcode 0008
static int LuaRestoreAnswers(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) AddConsoleString("LUA: restore_answers called");
    g_ConversationState->RestoreAnswers();
    cout << "Restoring answers\n";
    return 0;
}

// Opcode 000A
static int LuaGetAnswer(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) AddConsoleString("LUA: get_answer called");
    lua_getglobal(L, "answer");
    const char *selected_answer = lua_tostring(L, -1);
    lua_pop(L, 1);

    if (selected_answer)
    {
        lua_pushstring(L, selected_answer);
    }
    else
    {
        lua_pushstring(L, "nil");
    }
    return 1;
}

// Opcode 000B
static int LuaAskYesNo(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) AddConsoleString("LUA: ask_yes_no called");

    // Create the yes/no step
    ConversationState::ConversationStep step;
    step.type = ConversationState::ConversationStepType::STEP_MULTIPLE_CHOICE;
    step.dialog =  luaL_checkstring(L, 1);;
    step.answers.push_back("Yes");
    step.answers.push_back("No");
    step.npcId = 0;
    step.frame = 0;
    g_ConversationState->AddStep(step);

    // Yield the coroutine
    return lua_yield(L, 0);
}

static int LuaSelectPartyMemberByName(lua_State *L)
{
    if (!g_ConversationState)
    {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) AddConsoleString("LUA: choose_party_member_by_name");

    // Create the yes/no step
    ConversationState::ConversationStep step;
    step.type = ConversationState::ConversationStepType::STEP_MULTIPLE_CHOICE;
    step.dialog =  luaL_checkstring(L, 1);;
    step.answers.push_back(g_Player->GetPlayerName());
    for (int i = 0; i < g_Player->GetPartyMembers().size(); ++i)
    {
        step.answers.push_back(g_Player->GetPartyMembers()[i]);
    }
    step.npcId = 0;
    step.frame = 0;
    g_ConversationState->AddStep(step);

    // Yield the coroutine
    return lua_yield(L, 0);
}

// Opcode 000C
// Pops up a modal dialog allowing the player to enter a number with a slider.
static int LuaAskNumber(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: ask_number called");
    return 0;
}

// Opcode 000D
static int LuaSetObjectShape(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: set_object_shape called");
    int object_id = luaL_checkinteger(L, 1);
    int shape = luaL_checkinteger(L, 2);
    U7Object *object = GetObjectFromID(object_id).get();
    int currentFrame = object->m_shapeData->GetFrame();
    object->m_shapeData = &g_shapeTable[shape][currentFrame];
    return 0;
}

// Opcode 0011
static int LuaGetObjectShape(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_object_shape called");
    int object_id = luaL_checkinteger(L, 1);
    int shape = GetObjectFromID(object_id)->m_shapeData->GetShape();
    lua_pushinteger(L, shape);
    return 1;
}

// Opcode 0012
static int LuaGetObjectFrame(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_object_frame called");
    int object_id = luaL_checkinteger(L, 1);
    int frame = GetObjectFromID(object_id)->m_shapeData->GetFrame();
    lua_pushinteger(L, frame);
    return 1;
}

// Opcode 0013
static int LuaSetObjectFrame(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: set_object_frame called");
    int object_id = luaL_checkinteger(L, 1);
    int frame = luaL_checkinteger(L, 2);
    U7Object *object = GetObjectFromID(object_id).get();
    int currentShape = object->m_shapeData->GetShape();
    object->m_shapeData = &g_shapeTable[currentShape][frame];
    return 0;
}

// Opcode 0014
static int LuaGetObjectQuality(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_object_quality called");
    int object_id = luaL_checkinteger(L, 1);
    int quality = GetObjectFromID(object_id)->m_Quality;
    lua_pushinteger(L, quality);
    return 1;
}

static int LuaSetObjectQuality(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: set_object_quality called");
    int object_id = luaL_checkinteger(L, 1);
    int quality = luaL_checkinteger(L, 2);
    GetObjectFromID(object_id)->m_Quality = quality;
    return 0;
}

// Opcode 0020
static int LuaGetNPCProperty(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_npc_property called");
    int npc_id = luaL_checkinteger(L, 1);
    int property_id = luaL_checkinteger(L, 2);
    int value = 0; // TODO: g_NPCManager->GetProperty(npc_id, property_id)
    lua_pushinteger(L, value);
    return 1;
}

// Opcode 0021
static int LuaSetNPCProperty(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: set_npc_property called");
    int npc_id = luaL_checkinteger(L, 1);
    int property_id = luaL_checkinteger(L, 2);
    int value = luaL_checkinteger(L, 3);
    return 0;
}

// Opcode 0023
static int LuaGetPartyMembers(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_party_members called");
    lua_newtable(L);
    vector<string> party_members = g_Player->GetPartyMembers();
    for (size_t i = 0; i < party_members.size(); ++i)
    {
        lua_pushstring(L, party_members[i].c_str());
        lua_rawseti(L, -2, i + 1);
    }
    return 1;
}

// Opcode 0027
static int LuaGetPlayerName(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_player_name called");
    const char *player_name = "Avatar"; // TODO: g_Player->GetName()
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

// Opcode 002A
static int LuaGetContainerObjects(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_container_objects called");
    int container_id = luaL_checkinteger(L, 1);
    int type = luaL_checkinteger(L, 2);
    int x = luaL_checkinteger(L, 3);
    int y = luaL_checkinteger(L, 4);
    lua_newtable(L);
    // TODO: Push list of object IDs
    return 1;
}

// Opcode 002E
static int LuaPlayMusic(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: play_music called");
    int track = luaL_checkinteger(L, 1);
    int loop = luaL_checkinteger(L, 2);
    // TODO: g_AudioSystem->PlayMusic(track, loop)
    return 0;
}

// Opcode 002F
static int LuaNPCIDInParty(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: npc_in_party called");
    int npc_id = luaL_checkinteger(L, 1);
    bool in_party = g_Player->NPCIDInParty(npc_id);
    lua_pushboolean(L, in_party);
    return 1;
}

static int LuaNPCNameInParty(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: npc_in_party called");
    const char* text = luaL_checkstring(L, 1);
    bool in_party = g_Player->NPCNameInParty(text);
    lua_pushboolean(L, in_party);
    return 1;
}

// Opcode 0032
static int LuaDisplaySign(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: display_sign called");
    int object_id = luaL_checkinteger(L, 1);
    const char *text = luaL_checkstring(L, 2);
    cout << "Displaying sign for object ID: " << object_id << "\n";
    return 0;
}

// Opcode 0033
static int LuaObjectSelectModal(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: object_select_modal called");
    int object_id = luaL_checkinteger(L, 1);
    const char *text = luaL_checkstring(L, 2);
    cout << "Object select modal for object ID: " << object_id << "\n";
    lua_pushinteger(L, 0);
    return 1;
}

// Opcode 0038
static int LuaGetTimeHour(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_time_hour called");
    int hour = 0; // TODO: g_TimeSystem->GetHour()
    lua_pushinteger(L, hour);
    return 1;
}

// Opcode 0039
static int LuaGetTimeMinute(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_time_minute called");
    int minute = 0; // TODO: g_TimeSystem->GetMinute()
    lua_pushinteger(L, minute);
    return 1;
}

// Opcode 0040
static int LuaBark(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: bark called");
    int objectref = luaL_checkinteger(L, 1);
    const char *text = luaL_checkstring(L, 1);
    return 0;
}

// Opcode 005A
static int LuaIsAvatarFemale(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: is_avatar_female called");
    lua_pushboolean(L, !g_Player->GetIsMale());
    return 0;
}

static int LuaMove(lua_State *L)
{
    int x = luaL_checkinteger(L, 1);
    int y = luaL_checkinteger(L, 2);
    cout << "Move to (" << x << ", " << y << ")\n";
    // TODO: Implement object movement
    return 0;
}

static int LuaGetFlag(lua_State *L)
{
    int flag_id = luaL_checkinteger(L, 1);
    bool value = g_ScriptingSystem->GetFlag(flag_id);
    lua_pushboolean(L, value);
    return 1;
}

static int LuaSetFlag(lua_State *L)
{
    int flag_id = luaL_checkinteger(L, 1);
    bool value = lua_toboolean(L, 2);
    g_ScriptingSystem->SetFlag(flag_id, value);
    return 0;
}

static int LuaGetStat(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    int stat_id = luaL_checkinteger(L, 2);
    int value = 0; // TODO: g_Player->GetStat(object_id, stat_id)
    lua_pushinteger(L, value);
    return 1;
}

static int LuaSetStat(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    int stat_id = luaL_checkinteger(L, 2);
    int value = luaL_checkinteger(L, 3);
    // TODO: g_Player->SetStat(object_id, stat_id, value)
    return 0;
}

static int LuaBuyObject(lua_State *L)
{
    const char *prefix = luaL_checkstring(L, 1);
    int object_id = luaL_checkinteger(L, 2);
    int quantity = luaL_checkinteger(L, 3);
    int price = luaL_checkinteger(L, 4);
    const char *object_name = luaL_checkstring(L, 5);
    int result = 0; // 1=success, 2=can't carry, 3=no gold

    // if (g_Player->GetGold() >= price * quantity && g_Player->CanCarry(object_id, quantity))
    // {
    //     g_Player->AddObject(object_id, quantity);
    //     g_Player->SpendGold(price * quantity);
    //     result = 1;
    // }
    // else if (!g_Player->CanCarry(object_id, quantity))
    // {
    //     result = 2;
    // }
    // else
    // {
    //     result = 3;
    // }

    lua_pushinteger(L, result);
    return 1;
}

static int LuaGetPartyGold(lua_State *L)
{
    int gold = g_Player->GetGold();
    lua_pushinteger(L, gold);
    return 1;
}

static int LuaSpendGold(lua_State *L)
{
    int amount = luaL_checkinteger(L, 1);
    bool success = g_Player->GetGold() >= amount;
    if (success)
    {
        g_Player->SpendGold(amount);
    }
    lua_pushboolean(L, success);
    return 1;
}

static int LuaGetPartyMember(lua_State *L)
{
    int index = luaL_checkinteger(L, 1);
    int npc_id = 0; // TODO: Return NPC ID for party member at index (e.g., 2=Shamino)
    cout << "Getting party member at index: " << index << "\n";
    lua_pushinteger(L, npc_id);
    return 1;
}

static int LuaTriggerFerry(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    cout << "Triggering ferry for object ID: " << object_id << "\n";
    // TODO: Start ferry transport (e.g., scene change to Skara Brae or mainland)
    return 0;
}

static int LuaGetObjectInfo(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    lua_newtable(L);
    // TODO: Push x, y, z coordinates or other attributes
    return 1;
}

static int LuaRemoveObject(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    return 0;
}

static int LuaGetDistance(lua_State *L)
{
    int obj1_id = luaL_checkinteger(L, 1);
    int obj2_id = luaL_checkinteger(L, 2);
    int distance = 0; // TODO: g_World->GetDistance(obj1_id, obj2_id)
    lua_pushinteger(L, distance);
    return 1;
}

static int LuaSetObjectState(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    return 0;
}

static int LuaGetWearer(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    int wearer_id = 0;
    lua_pushinteger(L, wearer_id);
    return 1;
}

static int LuaCheckObjectState(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    int state = 0;
    lua_pushinteger(L, state);
    return 1;
}

static int LuaFindObjects(lua_State *L)
{
    int obj_id = luaL_checkinteger(L, 1);
    int type = luaL_checkinteger(L, 2);
    int distance = luaL_checkinteger(L, 3);
    int flags = luaL_checkinteger(L, 4);
    lua_newtable(L);
    // TODO: g_World->FindObjects(obj_id, type, distance, flags)
    return 1;
}

static int LuaApplyEffect(lua_State *L)
{
    int obj_id = luaL_checkinteger(L, 1);
    int effect = luaL_checkinteger(L, 2);
    // TODO: g_EffectSystem->ApplyEffect(obj_id, effect)
    // Note: Could yield coroutine for asynchronous effects
    return 0;
}

static int LuaGetLordOrLady(lua_State *L)
{
    int lord_or_lady = 0; // TODO: g_Player->GetLordOrLady()
    if (g_Player->GetIsMale())
    {
        lua_pushstring(L, "Milord");
    }
    else
    {
        lua_pushstring(L, "Milady");
    }
    return 1;
}

static int LuaRandom(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: random called");
    int min = luaL_checkinteger(L, 1);
    int max = luaL_checkinteger(L, 2);
    int random_value = g_VitalRNG->Random(max - (min - 1)) + min;
    lua_pushinteger(L, random_value);
    return 1;
}

static int LuaRemoveFromParty(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: remove_from_party called");
    int npc_id = luaL_checkinteger(L, 1);
    return 0;
}

static int LuaAddToParty(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: add_to_party called");
    int npc_id = luaL_checkinteger(L, 1);
    return 0;
}

static int LuaIsInIntArray(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: is_in_array called");
    int value = luaL_checkinteger(L, 1);
    lua_getglobal(L, "array");
    if (!lua_istable(L, -1))
    {
        lua_pop(L, 1);
        return 0;
    }

    int len = lua_rawlen(L, -1);
    for (int i = 1; i <= len; i++)
    {
        lua_rawgeti(L, -1, i);
        if (lua_isinteger(L, -1) && lua_tointeger(L, -1) == value)
        {
            lua_pop(L, 2); // Pop value and array
            lua_pushboolean(L, true);
            return 1;
        }
        lua_pop(L, 1); // Pop value
    }

    lua_pop(L, 1); // Pop array
    lua_pushboolean(L, false);
    return 1;
}

static int LuaIsInStringArray(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: is_in_string_array called");
    const char *value = luaL_checkstring(L, 1);
    lua_getglobal(L, "string_array");
    if (!lua_istable(L, -1))
    {
        lua_pop(L, 1);
        return 0;
    }

    int len = lua_rawlen(L, -1);
    for (int i = 1; i <= len; i++)
    {
        lua_rawgeti(L, -1, i);
        if (lua_isstring(L, -1) && strcmp(lua_tostring(L, -1), value) == 0)
        {
            lua_pop(L, 2); // Pop value and array
            lua_pushboolean(L, true);
            return 1;
        }
        lua_pop(L, 1); // Pop value
    }

    lua_pop(L, 1); // Pop array
    lua_pushboolean(L, false);
    return 1;
}

// Does the container contain this specific object?
static int LuaHasObject(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: has_object called");
    // int objectref = luaL_checkinteger(L, 1);
    // int object_id = luaL_checkinteger(L, 2);

    // if(GetObjectFromID(object_id)->IsInInventory(object_id))
    // {
    //     lua_pushboolean(L, true);
    //     return 1;
    // }
    // else
    // {
        lua_pushboolean(L, false);
        return 1;
    //}
}

// Does the container contain any object of this shape/frame type?
static int LuaHasObjectOfType(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_object called");
    int objectref = luaL_checkinteger(L, 1);
    int object_id = luaL_checkinteger(L, 2);

    if (GetObjectFromID(object_id)->IsInInventory(object_id))
    {
        lua_pushboolean(L, true);
        return 1;
    }
    else
    {
        lua_pushboolean(L, false);
        return 1;
    }
}

static int LuaGetSchedule(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_schedule called");
    int npc_id = luaL_checkinteger(L, 1);
    int schedule = g_NPCData[npc_id]->m_currentActivity; // TODO: g_ScheduleSystem->GetSchedule(object_id)
    lua_pushinteger(L, schedule);
    return 1;
}

static int LuaGetNPCNameFromId(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_npc_name_from_id called");
    int npc_id = luaL_checkinteger(L, 1);
    string npc_name = "NPC";
    npc_name = g_NPCData[npc_id]->name;
    if (g_LuaDebug) AddConsoleString("NPC name: " + npc_name);
    cout << "NPC name: " << npc_name << "\n";

    lua_pushstring(L, npc_name.c_str());
    return 1;
}

static int LuaGetNPCIdFromName(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_npc_id_from_name called");
    string npc_name = luaL_checkstring(L, 1);
    int npc_id = 1;
    if (npc_name == g_Player->GetPlayerName())
    {
        npc_id = 356;
    }
    else
    {
        for (int i = 0; i < g_NPCData.size(); i++)
        {
            if (npc_name == g_NPCData[i]->name)
            {
                npc_id = g_NPCData[i]->id;
            }
        }
    }
    if (g_LuaDebug) AddConsoleString("NPC Id: " + npc_id);

    lua_pushinteger(L, npc_id);
    return 1;
}


static int LuaUpdateConversation(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    g_ConversationState->Update();
    g_ConversationState->Draw();
    return 0;
}

static int LuaClearAnswers(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    g_ConversationState->ClearAnswers();
    return 0;
}

static int LuaIsPlayerWearingMedallion(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: is_player_wearing_fellowship_medallion called");
    bool wearing = g_Player->IsWearingFellowshipMedallion();
    lua_pushboolean(L, wearing);
    return 1;
}

static int LuaGetScheduleTime(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_schedule_time called");
    lua_pushinteger(L, g_scheduleTime);
    return 1;
}

static int LuaGetNPCTrainingPoints(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_npc_training_points called");
    int npc_id = luaL_checkinteger(L, 1);
    int training_points = 0;
    if (npc_id == 356) // Avatar
    {
        training_points = g_Player->GetTrainingPoints();
    }
    else
    {
        training_points = g_NPCData[npc_id]->training;
    }

    lua_pushinteger(L, training_points);
    return 1;
}
// 0 - Strength
// 1 - Dexterity
// 2 - Intelligence
// 4 - Combat skill
// 6 - Magic skill

static int LuaGetNPCTrainingLevel(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: get_npc_training_level called");
    int npc_id = luaL_checkinteger(L, 1);
    int npc_skill = luaL_checkinteger(L, 2);
    int training_level = 0;

    if (npc_id == 356) // Avatar
    {
        switch (npc_skill)
        {
        case 0:
            training_level = g_Player->GetStr();
            break;
        case 1:
            training_level = g_Player->GetDex();
            break;
        case 2:
            training_level = g_Player->GetInt();
            break;
        case 4:
            training_level = g_Player->GetCombat();
            break;
        case 6:
            training_level = g_Player->GetMagic();
            break;
        }
    }
    else
    {
        switch (npc_skill)
        {
        case 0:
            training_level = g_NPCData[npc_id]->str;
            break;
        case 1:
            training_level = g_NPCData[npc_id]->dex;
            break;
        case 2:
            training_level = g_NPCData[npc_id]->iq;
            break;
        case 4:
            training_level = g_NPCData[npc_id]->combat;
            break;
        case 6:
            training_level = g_NPCData[npc_id]->magic;
            break;

        }
    }

    lua_pushinteger(L, training_level);
    return 1;
}

static int LuaRemovePartyGold(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: remove_party_gold called");
    int gold_to_remove = luaL_checkinteger(L, 1);
    g_Player->SetGold(g_Player->GetGold() - gold_to_remove);
    return 0;
}

static int LuaIncreaseNPCCombatLevel(lua_State *L)
{
    if (g_LuaDebug) AddConsoleString("LUA: increase_npc_combat_level called");
    int npc_id = luaL_checkinteger(L, 1);
    int amount_to_increase = luaL_checkinteger(L, 2);

    if (npc_id == 356)
    {
        g_Player->SetCombat(g_Player->GetCombat() + amount_to_increase);
        g_Player->SetTrainingPoints(g_Player->GetTrainingPoints() - 1);
    }
    else
    {
        g_NPCData[npc_id]->combat += amount_to_increase;
        g_NPCData[npc_id]->training -= amount_to_increase;
    }

    return 0;
}


void RegisterAllLuaFunctions()
{
    cout << "Registering Lua functions\n";

    // These functions handle the conversation system.
    g_ScriptingSystem->RegisterScriptFunction("switch_talk_to", LuaSwitchTalkTo);
    g_ScriptingSystem->RegisterScriptFunction("hide_npc", LuaHideNPC);
    g_ScriptingSystem->RegisterScriptFunction("add_dialogue", LuaAddDialogue);
    g_ScriptingSystem->RegisterScriptFunction("add_answer", LuaAddAnswers);
    g_ScriptingSystem->RegisterScriptFunction("start_conversation", LuaStartConversation);
    g_ScriptingSystem->RegisterScriptFunction("remove_answer", LuaRemoveAnswers);
    g_ScriptingSystem->RegisterScriptFunction("save_answers", LuaSaveAnswers);
    g_ScriptingSystem->RegisterScriptFunction("restore_answers", LuaRestoreAnswers);
    g_ScriptingSystem->RegisterScriptFunction("get_answer", LuaGetAnswer);
    g_ScriptingSystem->RegisterScriptFunction("clear_answers", LuaClearAnswers);

    // These are general utility functions.
    g_ScriptingSystem->RegisterScriptFunction("ask_yes_no", LuaAskYesNo);
    g_ScriptingSystem->RegisterScriptFunction("ask_number", LuaAskNumber);
    g_ScriptingSystem->RegisterScriptFunction("object_select_modal", LuaObjectSelectModal);
    g_ScriptingSystem->RegisterScriptFunction("random", LuaRandom);
    g_ScriptingSystem->RegisterScriptFunction("has_object", LuaHasObject);
    g_ScriptingSystem->RegisterScriptFunction("has_object_of_type", LuaHasObjectOfType);

    // These functions are used to manipulate the game world.
    g_ScriptingSystem->RegisterScriptFunction("get_object_shape", LuaGetObjectShape);
    g_ScriptingSystem->RegisterScriptFunction("set_object_shape", LuaSetObjectShape);
    g_ScriptingSystem->RegisterScriptFunction("get_object_frame", LuaGetObjectFrame);
    g_ScriptingSystem->RegisterScriptFunction("set_object_frame", LuaSetObjectFrame);
    g_ScriptingSystem->RegisterScriptFunction("get_object_quality", LuaGetObjectQuality);
    g_ScriptingSystem->RegisterScriptFunction("set_object_quality", LuaSetObjectQuality);
    g_ScriptingSystem->RegisterScriptFunction("get_npc_property", LuaGetNPCProperty);
    g_ScriptingSystem->RegisterScriptFunction("set_npc_property", LuaSetNPCProperty);

    // These functions are used to manipulate the party.
    g_ScriptingSystem->RegisterScriptFunction("get_party_member", LuaGetPartyMember);
    g_ScriptingSystem->RegisterScriptFunction("get_party_members", LuaGetPartyMembers);
    g_ScriptingSystem->RegisterScriptFunction("npc_id_in_party", LuaNPCIDInParty);
    g_ScriptingSystem->RegisterScriptFunction("npc_name_in_party", LuaNPCNameInParty);
    g_ScriptingSystem->RegisterScriptFunction("add_to_party", LuaAddToParty);
    g_ScriptingSystem->RegisterScriptFunction("remove_from_party", LuaRemoveFromParty);
    g_ScriptingSystem->RegisterScriptFunction("get_npc_name_from_id", LuaGetNPCNameFromId);
    g_ScriptingSystem->RegisterScriptFunction("get_npc_id_from_name", LuaGetNPCIdFromName);
    g_ScriptingSystem->RegisterScriptFunction("select_party_member_by_name", LuaSelectPartyMemberByName); //  Used in dialogue, presents a list of party members and allows user to click on one to select it
    g_ScriptingSystem->RegisterScriptFunction("get_party_gold", LuaGetPartyGold);
    g_ScriptingSystem->RegisterScriptFunction("remove_party_gold", LuaRemovePartyGold);
    g_ScriptingSystem->RegisterScriptFunction("get_npc_training_points", LuaGetNPCTrainingPoints);
    g_ScriptingSystem->RegisterScriptFunction("get_npc_training_level", LuaGetNPCTrainingLevel);
    g_ScriptingSystem->RegisterScriptFunction("increase_npc_combat_level", LuaIncreaseNPCCombatLevel);


    // These functions are used to get information about the Avatar/player.
    g_ScriptingSystem->RegisterScriptFunction("get_player_name", LuaGetPlayerName);
    g_ScriptingSystem->RegisterScriptFunction("is_player_female", LuaIsAvatarFemale);
    g_ScriptingSystem->RegisterScriptFunction("get_lord_or_lady", LuaGetLordOrLady);

    // These functions are used to get information about the world and objects.
    g_ScriptingSystem->RegisterScriptFunction("get_time_hour", LuaGetTimeHour);
    g_ScriptingSystem->RegisterScriptFunction("get_time_minute", LuaGetTimeMinute);
    g_ScriptingSystem->RegisterScriptFunction("get_schedule_time", LuaGetScheduleTime);
    g_ScriptingSystem->RegisterScriptFunction("display_sign", LuaDisplaySign);
    g_ScriptingSystem->RegisterScriptFunction("bark", LuaBark);

    // These are new functions designed to be called by Lua scripts.
    g_ScriptingSystem->RegisterScriptFunction("get_flag", LuaGetFlag);
    g_ScriptingSystem->RegisterScriptFunction("set_flag", LuaSetFlag);
    g_ScriptingSystem->RegisterScriptFunction("is_in_int_array", LuaIsInIntArray);
    g_ScriptingSystem->RegisterScriptFunction("is_in_string_array", LuaIsInStringArray);

    g_ScriptingSystem->RegisterScriptFunction("get_schedule", LuaGetSchedule);
    
    g_ScriptingSystem->RegisterScriptFunction("debug_print", LuaDebugPrint);

    g_ScriptingSystem->RegisterScriptFunction("update_conversation", LuaUpdateConversation);

    g_ScriptingSystem->RegisterScriptFunction("is_player_wearing_fellowship_medallion", LuaIsPlayerWearingMedallion);

    cout << "Registered all Lua functions\n";
}