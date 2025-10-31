#include "U7LuaFuncs.h"

#include <algorithm>

#include "U7Globals.h"
#include "Geist/ScriptingSystem.h"
#include "Geist/StateMachine.h"
#include "ConversationState.h"
#include <iostream>
#include <cstring>

#include "Logging.h"
#include "U7GumpBook.h"
#include "MainState.h"

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
    DebugPrint(text);
    return 0;
}

static int LuaAddDialogue(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    cout << "Lua says: " << luaL_checkstring(L, 1) << "\n";
    DebugPrint("LUA: add_dialogue called with " + string(luaL_checkstring(L, 1)));
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
   DebugPrint ("LUA: start_conversation called");
    g_StateMachine->PushState(STATE_CONVERSATIONSTATE);
    return 0;
}

// Opcode 0003
static int LuaSecondSpeaker(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    int npc_id = luaL_checkinteger(L, 1);
    int frame = luaL_checkinteger(L, 2);
    string secondSpeakerDialog = luaL_checkstring(L, 3);
    DebugPrint("LUA: second_speaker called with " + std::to_string(npc_id));
    ConversationState::ConversationStep step;
    step.type = ConversationState::ConversationStepType::STEP_SECOND_SPEAKER;
    step.dialog = secondSpeakerDialog;
    step.npcId = npc_id;
    step.frame = frame;
    g_ConversationState->AddStep(step);

    return 0;
}

// Opcode 0004
static int LuaHideNPC(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    DebugPrint("LUA: hide_npc called");
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
    DebugPrint("LUA: add_answers called");
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
        std::vector<std::string> answers;
        answers.push_back(answer);
        g_ConversationState->AddAnswers(answers);
        std::cout << "Added answer: " << answer << "\n";
    }
    else if (type == LUA_TTABLE)
    {
        // Table: iterate over elements and add strings
        vector<string> localAnswers;
        int table_len = lua_rawlen(L, 1);
        for (int i = 1; i <= table_len; ++i)
        {

            lua_rawgeti(L, 1, i);
            if (lua_isstring(L, -1))
            {
                const char *answer = lua_tostring(L, -1);
                lua_pushstring(L, answer); // Push copy for answers table
                if (!lua_istable(L, answers_idx))
                {
                    return luaL_error(L, "Answers table lost at index %d", answers_idx);
                }
                localAnswers.push_back(answer);
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
        std::reverse(localAnswers.begin(), localAnswers.end());
        g_ConversationState->AddAnswers(localAnswers);
        string answersCombined;
        for (const auto& ans : localAnswers)
        {
            answersCombined += ans + ", ";
        }
        DebugPrint("LUA: add_answers called with " + answersCombined);
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
    if (g_LuaDebug) DebugPrint("LUA: remove_answers called");
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
    if (g_LuaDebug) DebugPrint("LUA: save_answers called");
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
    if (g_LuaDebug) DebugPrint("LUA: restore_answers called");
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

    lua_getglobal(L, "answer");
    const char *selected_answer = lua_tostring(L, -1);
    lua_pop(L, 1);

    if (selected_answer && strlen(selected_answer) > 0)
    {
        DebugPrint("LUA: get_answer called with " + string(selected_answer));
        lua_pushstring(L, selected_answer);

        // Clear the global answer after reading it so next get_answer() will yield
        lua_pushnil(L);
        lua_setglobal(L, "answer");
    }
    else
    {
        DebugPrint("Warning: get_answer called with no answer set, yielding");
        return lua_yield(L, 0);
    }
    return 1;
}

// Opcode 000B
static int LuaAskYesNo(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) DebugPrint("LUA: ask_yes_no called");

    // Create the yes/no step
    ConversationState::ConversationStep step;
    step.type = ConversationState::ConversationStepType::STEP_MULTIPLE_CHOICE;

    // Question is optional - if not provided, use empty string
    if (lua_gettop(L) >= 1 && lua_isstring(L, 1))
    {
        step.dialog = lua_tostring(L, 1);
    }
    else
    {
        step.dialog = "";
    }

    step.answers.push_back("Yes");
    step.answers.push_back("No");
    step.npcId = 0;
    step.frame = 0;
    g_ConversationState->AddStep(step);

    if (g_LuaDebug) DebugPrint("LUA: ask_yes_no called with question: " + string(step.dialog));

    // Yield the coroutine
    return lua_yield(L, 0);
}

static int LuaSelectPartyMemberByName(lua_State *L)
{
    if (!g_ConversationState)
    {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) DebugPrint("LUA: choose_party_member_by_name");

    // Create the yes/no step
    ConversationState::ConversationStep step;
    step.type = ConversationState::ConversationStepType::STEP_MULTIPLE_CHOICE;
    step.dialog =  luaL_checkstring(L, 1);;
    step.answers.push_back(g_Player->GetPlayerName());
    for (int i = 0; i < g_Player->GetPartyMemberNames().size(); ++i)
    {
        step.answers.push_back(g_Player->GetPartyMemberNames()[i]);
    }
    step.npcId = 0;
    step.frame = 0;
    g_ConversationState->AddStep(step);

    // Yield the coroutine
    return lua_yield(L, 0);
}

// Presents answer choices without a question prompt
// All elements in the table are treated as answer choices
static int LuaAskAnswer(lua_State *L)
{
    if (!g_ConversationState)
    {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) DebugPrint("LUA: ask_answer called");

    // Validate that we got a table as first argument
    if (!lua_istable(L, 1))
    {
        return luaL_error(L, "ask_answer: expected table as first argument, got %s",
                         lua_typename(L, lua_type(L, 1)));
    }

    ConversationState::ConversationStep step;
    step.type = ConversationState::ConversationStepType::STEP_MULTIPLE_CHOICE;
    step.dialog = ""; // No question, just answers

    // Table: iterate over elements and add all as answers
    int table_len = lua_rawlen(L, 1);
    for (int i = 1; i <= table_len; ++i)
    {
        lua_rawgeti(L, 1, i); // Push table[i]
        if (lua_isstring(L, -1))
        {
            const char *answer = lua_tostring(L, -1);
            if (answer == nullptr)
            {
                lua_pop(L, 1);
                return luaL_error(L, "ask_answer: lua_tostring returned nullptr at index %d", i);
            }
            step.answers.push_back(answer);
            std::cout << "Added answer: " << answer << "\n";
        }
        else
        {
            std::cout << "Warning: Non-string element at index " << i << " ignored\n";
        }
        lua_pop(L, 1); // Pop table[i]
    }

    std::reverse(step.answers.begin(), step.answers.end());
    step.npcId = 0;
    step.frame = 0;
    g_ConversationState->AddStep(step);

    // Yield the coroutine
    return lua_yield(L, 0);
}

static int LuaAskMultipleChoice(lua_State *L)
{
    if (!g_ConversationState)
    {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) DebugPrint("LUA: ask_multiple_choice called");

    // Validate that we got a table as first argument
    if (!lua_istable(L, 1))
    {
        return luaL_error(L, "ask_multiple_choice: expected table as first argument, got %s",
                         lua_typename(L, lua_type(L, 1)));
    }

    ConversationState::ConversationStep step;
    step.type = ConversationState::ConversationStepType::STEP_MULTIPLE_CHOICE;


    // Create the yes/no step
    // Table: iterate over elements and add strings
    int table_len = lua_rawlen(L, 1);
    for (int i = 1; i <= table_len; ++i)
    {
        lua_rawgeti(L, 1, i); // Push table[i]
        if (lua_isstring(L, -1))
        {
            const char *answer = lua_tostring(L, -1);
            if (answer == nullptr)
            {
                lua_pop(L, 1);
                return luaL_error(L, "ask_multiple_choice: lua_tostring returned nullptr at index %d", i);
            }
            if (i == 1) // Question
            {
                step.dialog = answer;
            }
            else
            {
                step.answers.push_back(answer);
            }
            std::cout << "Added answer: " << answer << "\n";
        }
        else
        {
            std::cout << "Warning: Non-string element at index " << i << " ignored\n";
        }
        lua_pop(L, 1); // Pop table[i]
    }

    std::reverse(step.answers.begin(), step.answers.end());
    step.npcId = 0;
    step.frame = 0;
    g_ConversationState->AddStep(step);

    // Yield the coroutine
    return lua_yield(L, 0);
}

//  This is a custom version of multiple-choice that returns
//  an array index instead of a string.  This makes it
//  easier to run stores inside the conversation system.
static int LuaGetPurchaseOption(lua_State *L)
{
    if (!g_ConversationState)
    {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) DebugPrint("LUA: get_purchase_option called");

    ConversationState::ConversationStep step;
    step.type = ConversationState::ConversationStepType::STEP_GET_PURCHASE_OPTION;


    // Create the yes/no step
    // Table: iterate over elements and add strings
    int table_len = lua_rawlen(L, 1);
    for (int i = 1; i <= table_len; ++i)
    {
        lua_rawgeti(L, 1, i); // Push table[i]
        if (lua_isstring(L, -1))
        {
            const char *answer = lua_tostring(L, -1);
            if (i == 1) // Question
            {
                step.dialog = answer;
            }
            else
            {
                step.answers.insert(step.answers.begin(), answer);
            }
            std::cout << "Added answer: " << answer << "\n";
        }
        else
        {
            std::cout << "Warning: Non-string element at index " << i << " ignored\n";
        }
        lua_pop(L, 1); // Pop table[i]
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
    if (!g_ConversationState)
    {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) DebugPrint("LUA: ask_number called");

    ConversationState::ConversationStep step;
    step.type = ConversationState::ConversationStepType::STEP_GET_AMOUNT_FROM_NUMBER_BAR;
    step.dialog = lua_tostring(L, 1);;
    step.data.clear();
    step.data.push_back(luaL_checkinteger(L, 2));;
    step.data.push_back(luaL_checkinteger(L, 3));;
    step.data.push_back(luaL_checkinteger(L, 4));;

    step.npcId = 0;
    step.frame = 0;
    g_ConversationState->AddStep(step);

    // Yield the coroutine
    return lua_yield(L, 0);
}

// Opcode 0033
static int LuaObjectSelectModal(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: object_select_modal called");

    if (g_StateMachine->GetCurrentState() == STATE_MAINSTATE)
    {
        dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE))->StartObjectSelectionMode();
    }

    return lua_yield(L, 0);
}

// Opcode 000D
static int LuaSetObjectShape(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: set_object_shape called");
    int object_id = luaL_checkinteger(L, 1);
    int shape = luaL_checkinteger(L, 2);
    U7Object *object = GetObjectFromID(object_id);

    // If the current object is a door, mark the new shape as a door too
    // This fixes doors that change shape when opened/closed
    bool wasDoor = object->m_objectData->m_isDoor;

    int currentFrame = object->m_shapeData->GetFrame();
    object->m_shapeData = &g_shapeTable[shape][currentFrame];
    object->m_objectData = &g_objectDataTable[shape];

    // Propagate door flag to new shape
    if (wasDoor)
    {
        g_objectDataTable[shape].m_isDoor = true;
    }

    return 0;
}

// Opcode 0011
static int LuaGetObjectShape(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_object_shape called");
    int object_id = luaL_checkinteger(L, 1);
    int shape = GetObjectFromID(object_id)->m_shapeData->GetShape();
    //DebugPrint("ID: " + to_string(object_id) +  " Shape: " + to_string(shape));
    lua_pushinteger(L, shape);
    return 1;
}

// Opcode 0012
static int LuaGetObjectFrame(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_object_frame called");
    int object_id = luaL_checkinteger(L, 1);
    int frame = GetObjectFromID(object_id)->m_shapeData->GetFrame();
    //DebugPrint("ID: " + to_string(object_id) +  " Frame: " + to_string(frame));
    lua_pushinteger(L, frame);
    return 1;
}

// Opcode 0013
static int LuaSetObjectFrame(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: set_object_frame called");
    int object_id = luaL_checkinteger(L, 1);
    int frame = luaL_checkinteger(L, 2);
    U7Object *object = GetObjectFromID(object_id);
    if (object)
    {
        object->SetFrame(frame);  // Now includes pathfinding grid update for doors
    }
    return 0;
}

// Get object position (returns x, y, z)
static int LuaGetObjectPosition(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_object_position called");
    int object_id = luaL_checkinteger(L, 1);
    U7Object *object = GetObjectFromID(object_id);
    if (object)
    {
        lua_pushnumber(L, object->m_Pos.x);
        lua_pushnumber(L, object->m_Pos.y);
        lua_pushnumber(L, object->m_Pos.z);
        return 3;  // Return 3 values
    }
    return 0;
}

// Set object position
static int LuaSetObjectPosition(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: set_object_position called");
    int object_id = luaL_checkinteger(L, 1);
    float x = luaL_checknumber(L, 2);
    float y = luaL_checknumber(L, 3);
    float z = luaL_checknumber(L, 4);
    U7Object *object = GetObjectFromID(object_id);
    if (object)
    {
        object->SetPos({x, y, z});
    }
    return 0;
}

// NOTE: LuaFindNearbyObjects removed - not needed for single door implementation
// Double door support can be added back later if needed

// Opcode 0014
static int LuaGetObjectQuality(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_object_quality called");
    int object_id = luaL_checkinteger(L, 1);
    int quality = GetObjectFromID(object_id)->m_Quality;
    DebugPrint("ID: " + to_string(object_id) +  " Quality: " + to_string(quality));
    lua_pushinteger(L, quality);
    return 1;
}

static int LuaSetObjectQuality(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: set_object_quality called");
    int object_id = luaL_checkinteger(L, 1);
    int quality = luaL_checkinteger(L, 2);
    GetObjectFromID(object_id)->m_Quality = quality;
    return 0;
}

// Opcode 0020
static int LuaGetNPCProperty(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_npc_property called");
    int npc_id = luaL_checkinteger(L, 1);
    int property_id = luaL_checkinteger(L, 2);
    int value = 0; // TODO: g_NPCManager->GetProperty(npc_id, property_id)
    lua_pushinteger(L, value);
    return 1;
}

// Opcode 0021
static int LuaSetNPCProperty(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: set_npc_property called");
    int npc_id = luaL_checkinteger(L, 1);
    int property_id = luaL_checkinteger(L, 2);
    int value = luaL_checkinteger(L, 3);
    return 0;
}

// Opcode 0023
static int LuaGetPartyMemberNames(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_party_members called");
    lua_newtable(L);
    vector<string> party_members = g_Player->GetPartyMemberNames();
    for (size_t i = 0; i < party_members.size(); ++i)
    {
        string text = "Party member: " + party_members[i];
        cout << "Lua console: " << text << "\n";
        if (g_LuaDebug) DebugPrint(text);
        lua_pushstring(L, party_members[i].c_str());
        lua_rawseti(L, -2, i + 1);
    }
    return 1;
}

// Opcode 0027
static int LuaGetPlayerName(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_player_name called");
    lua_pushstring(L, g_Player->GetPlayerName().c_str());
    return 1;
}

// Opcode 002A
static int LuaGetContainerObjects(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_container_objects called");
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
    if (g_LuaDebug) DebugPrint("LUA: play_music called");
    int track = luaL_checkinteger(L, 1);
    int loop = luaL_checkinteger(L, 2);
    // TODO: g_AudioSystem->PlayMusic(track, loop)
    return 0;
}

// Opcode 002F
static int LuaNPCIDInParty(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: npc_in_party called");
    int npc_id = luaL_checkinteger(L, 1);
    bool in_party = g_Player->NPCIDInParty(npc_id);
    lua_pushboolean(L, in_party);
    return 1;
}

static int LuaNPCNameInParty(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: npc_in_party called");
    const char* text = luaL_checkstring(L, 1);
    bool in_party = g_Player->NPCNameInParty(text);
    lua_pushboolean(L, in_party);
    return 1;
}

// Opcode 0038
static int LuaGetTimeHour(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_time_hour called");
    int hour = 0; // TODO: g_TimeSystem->GetHour()
    lua_pushinteger(L, hour);
    return 1;
}

// Opcode 0039
static int LuaGetTimeMinute(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_time_minute called");
    int minute = 0; // TODO: g_TimeSystem->GetMinute()
    lua_pushinteger(L, minute);
    return 1;
}

// Opcode 0040
static int LuaBark(lua_State *L)
{
    int objectref = luaL_checkinteger(L, 1);
    const char *text = luaL_checkstring(L, 2);
    if (g_LuaDebug) DebugPrint("LUA: bark called with object " + to_string(objectref) + " text: " + string(text));
    if (g_StateMachine->GetCurrentState() == STATE_MAINSTATE)
    {
        dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE))->Bark(GetObjectFromID(objectref), text, 3.0f);
    }
    return 0;
}

static int LuaBarkNPC(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    const char *text = luaL_checkstring(L, 2);
    if (g_LuaDebug) DebugPrint("LUA: bark_npc called with NPC " + string(g_NPCData[npc_id]->name) + " text: " + string(text));
    if (g_StateMachine->GetCurrentState() == STATE_MAINSTATE)
    {
        dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE))->Bark(GetObjectFromID(g_NPCData[npc_id]->m_objectID), text, 3.0f);
    }
    return 0;
}

// Opcode 005A
static int LuaIsAvatarFemale(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: is_avatar_female called");
    bool is_female = !g_Player->GetIsMale();
    lua_pushboolean(L, is_female);
    return 1;
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

static int LuaSpawnObject(lua_State *L)
{
    int shape = luaL_checkinteger(L, 1);
    int frame = luaL_checkinteger(L, 2);
    int x = luaL_checkinteger(L, 3);
    int y = luaL_checkinteger(L, 4);
    int z = luaL_checkinteger(L, 5);

    int spawned_id = GetNextID();
    AddObject(shape, frame, spawned_id, x, y, z);

    lua_pushinteger(L, spawned_id);
    return 1;
}

static int LuaDestroyObject(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    U7Object* obj = g_objectList[object_id].get();

    // Notify pathfinding grid before deleting if this is a non-walkable object
    if (obj && obj->m_objectData && obj->m_objectData->m_isNotWalkable)
    {
        NotifyPathfindingGridUpdate((int)obj->m_Pos.x, (int)obj->m_Pos.z);
    }

    UnassignObjectChunk(obj);
    g_objectList.erase(object_id);
    UpdateSortedVisibleObjects();
    return 0;
}

static int LuaMoveObject(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    int x = luaL_checkinteger(L, 2);
    int y = luaL_checkinteger(L, 3);
    int z = luaL_checkinteger(L, 4);
    cout << "Moving object ID " << object_id << " to (" << x << ", " << y << ", " << z << ")\n";
    g_objectList[object_id]->SetPos( {float(x), float(y), float(z)} );
    return 0;
}

static int LuaStopNPCSchedule(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    DebugPrint("stop_npc_schedule called, NPC ID " + to_string(npc_id));
    g_objectList[g_NPCData[npc_id].get()->m_objectID]->m_followingSchedule = false;
    return 0;
}

static int LuaStartNPCSchedule(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    DebugPrint("stop_npc_schedule called, NPC ID " + to_string(npc_id));
    g_objectList[g_NPCData[npc_id].get()->m_objectID]->m_followingSchedule = true;
    return 0;
}

static int LuaSetNPCPos(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    int x = luaL_checkinteger(L, 2);
    int y = luaL_checkinteger(L, 3);
    int z = luaL_checkinteger(L, 4);
    cout << "set_npc_pos called, moving NPC ID " << npc_id << " to (" << x << ", " << y << ", " << z << ")\n";
    g_objectList[g_NPCData[npc_id]->m_objectID].get()->SetPos( {float(x), float(y), float(z)});
    return 0;
}

static int LuaSetNPCDest(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    int x = luaL_checkinteger(L, 2);
    int y = luaL_checkinteger(L, 3);
    int z = luaL_checkinteger(L, 4);
    cout << "set_npc_dest called, setting " << npc_id << " destination to (" << x << ", " << y << ", " << z << ")\n";
    g_objectList[g_NPCData[npc_id]->m_objectID]->SetDest( {float(x), float(y), float(z)} );
    return 0;
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

static int LuaGetHimOrHer(lua_State *L)
{
    int lord_or_lady = 0; // TODO: g_Player->GetLordOrLady()
    if (g_Player->GetIsMale())
    {
        lua_pushstring(L, "him");
    }
    else
    {
        lua_pushstring(L, "her");
    }
    return 1;
}

static int LuaRandom(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: random called");
    int min = luaL_checkinteger(L, 1);
    int max = luaL_checkinteger(L, 2);
    int random_value = g_VitalRNG->Random(max - (min - 1)) + min;
    lua_pushinteger(L, random_value);
    return 1;
}

static int LuaRemoveFromParty(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: remove_from_party called");
    int npc_id = luaL_checkinteger(L, 1);
    g_Player->RemovePartyMember(npc_id);
    return 0;
}

static int LuaAddToParty(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: add_to_party called");
    int npc_id = luaL_checkinteger(L, 1);
    g_Player->AddPartyMember(npc_id);
    return 0;
}

static int LuaIsIntInArray(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: is_int_in_array called");

    // Validate number of arguments
    if (lua_gettop(L) != 2)
    {
        DebugPrint("Expected 2 arguments: integer and table");
        return 0;
    }

    // Check first argument is an integer
    if (!lua_isinteger(L, 1))
    {
        DebugPrint( "First argument must be an integer");
        return 0;
    }
    lua_Integer value = lua_tointeger(L, 1);

    // Check second argument is a table
    if (!lua_istable(L, 2)) {
        DebugPrint( "Second argument must be a table");
        return 0;
    }

    // Get table length
    size_t len = lua_rawlen(L, 2);

    // Iterate through table
    for (size_t i = 1; i <= len; i++)
    {
        lua_rawgeti(L, 2, i); // Push table[i] onto stack
        if (lua_isinteger(L, -1))
        {
            lua_Integer array_value = lua_tointeger(L, -1);
            if (array_value == value)
            {
                lua_pop(L, 1); // Pop array value
                lua_pushboolean(L, true);
                return 1;
            }
        }
        lua_pop(L, 1); // Pop array value
    }

    // Value not found
    lua_pushboolean(L, false);
    return 1;
}

static int LuaIsStringInArray(lua_State *L)
{
    if (g_LuaDebug)
    {
        DebugPrint("LUA: is_in_string_array called");
    }

    // Validate number of arguments
    if (lua_gettop(L) != 2)
    {
        DebugPrint( "Expected 2 arguments: string and table");
        return 0;
    }

    // Check first argument is a string
    if (!lua_isstring(L, 1))
    {
        DebugPrint("First argument must be a string");
        return 0;
    }
    std::string value = lua_tostring(L, 1);

    // Check second argument is a table
    if (!lua_istable(L, 2))
    {
        DebugPrint("Second argument must be a table");
        return 0;
    }

    // Get table length
    size_t len = lua_rawlen(L, 2);

    // Iterate through table
    for (size_t i = 1; i <= len; i++)
    {
        lua_rawgeti(L, 2, i); // Push table[i] onto stack
        if (lua_isstring(L, -1))
        {
            std::string array_value = lua_tostring(L, -1);
            if (array_value == value)
            {
                lua_pop(L, 1); // Pop array value
                lua_pushboolean(L, true);
                return 1;
            }
        }
        lua_pop(L, 1); // Pop array value
    }

    // Value not found
    lua_pushboolean(L, false);
    return 1;
}

// Does the container contain this specific object?
static int LuaIsObjectInNPCInventory(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    int shape = luaL_checkinteger(L, 2);

    int frame = 0;
    if (lua_isinteger(L, 3))
    {
        frame = lua_tointeger(L, 3);
    }

    int quality = -1;
    if (lua_isinteger(L, 4))
    {
        quality = lua_tointeger(L, 4);
    }
    DebugPrint("LUA: is_object_in_inventory called for NPC ID " + to_string(npc_id) +
               " shape " + to_string(shape) +
               " frame " + to_string(frame) +
               " quality " + to_string(quality));

    if(GetObjectFromID(g_NPCData[npc_id].get()->m_objectID)->IsInInventory(shape, frame, quality))
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

// Does the container contain this specific object?
static int LuaIsObjectInContainer(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    int shape = luaL_checkinteger(L, 2);

    int frame = 0;
    if (lua_isinteger(L, 3))
    {
        frame = lua_tointeger(L, 3);
    }

    int quality = -1;
    if (lua_isinteger(L, 4))
    {
        quality = lua_tointeger(L, 4);
    }
    DebugPrint("LUA: is_object_in_inventory called for NPC ID " + to_string(npc_id) +
               " shape " + to_string(shape) +
               " frame " + to_string(frame) +
               " quality " + to_string(quality));

    if(GetObjectFromID(g_NPCData[npc_id].get()->m_objectID)->IsInInventory(shape, frame, quality))
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

// Does the container contain this specific object?
static int LuaAddObjectToContainer(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    int shape = luaL_checkinteger(L, 2);

    int frame = 0;
    if (lua_isinteger(L, 3))
    {
        frame = lua_tointeger(L, 3);
    }

    int quality = -1;
    if (lua_isinteger(L, 4))
    {
        quality = lua_tointeger(L, 4);
    }
    DebugPrint("LUA: add_object_to_container called for object ID " + to_string(object_id) +
               " shape " + to_string(shape) +
               " frame " + to_string(frame) +
               " quality " + to_string(quality));

    int id = GetNextID();
    AddObject(shape, frame, id, 0, 0, 0); //  Since this is going into an inventory, position doesn't matter
    g_objectList[id]->m_Quality = quality;

    bool success = GetObjectFromID(object_id)->AddObjectToInventory(id);
    lua_pushboolean(L, success);
    return 1;
}

static int LuaAddObjectToNPCInventory(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    int shape = luaL_checkinteger(L, 2);

    int frame = 0;
    if (lua_isinteger(L, 3))
    {
        frame = lua_tointeger(L, 3);
    }

    int quality = -1;
    if (lua_isinteger(L, 4))
    {
        quality = lua_tointeger(L, 4);
    }
    DebugPrint("LUA: add_object_to_npc_inventory called for NPC ID " + to_string(npc_id) +
               " shape " + to_string(shape) +
               " frame " + to_string(frame) +
               " quality " + to_string(quality));

    int nextId = GetNextID();
    AddObject(shape, frame, nextId, 0, 0, 0); //  Since this is going into an inventory, position doesn't matter
    g_objectList[nextId]->m_Quality = quality;

    bool success = GetObjectFromID(g_NPCData[npc_id].get()->m_objectID)->AddObjectToInventory(nextId);
    lua_pushboolean(L, success);
    return 1;
}

// Does the container contain any object of this shape/frame type?
static int LuaHasObjectOfType(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_object called");
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
    if (g_LuaDebug) DebugPrint("LUA: get_schedule called");
    int npc_id = luaL_checkinteger(L, 1);
    int schedule = g_NPCData[npc_id]->m_currentActivity; // TODO: g_ScheduleSystem->GetSchedule(object_id)
    lua_pushinteger(L, schedule);
    return 1;
}

static int LuaGetNPCNameFromId(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_npc_name_from_id called");
    int npc_id = luaL_checkinteger(L, 1);
    string npc_name = "NPC";
    npc_name = g_NPCData[npc_id]->name;
    if (g_LuaDebug) DebugPrint("NPC name: " + npc_name);
    cout << "NPC name: " << npc_name << "\n";

    lua_pushstring(L, npc_name.c_str());
    return 1;
}

static int LuaGetNPCIdFromName(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_npc_id_from_name called");
    string npc_name = luaL_checkstring(L, 1);
    int npc_id = 1;
    if (npc_name == g_Player->GetPlayerName())
    {
        npc_id = 0;
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
    if (g_LuaDebug) DebugPrint("NPC Id: " + npc_id);

    lua_pushinteger(L, npc_id);
    return 1;
}

static int LuaEndConversation(lua_State *L)
{
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }
    if (g_LuaDebug) DebugPrint("LUA: end_conversation called");
    g_ConversationState->m_conversationActive = false;
    g_StateMachine->PopState();
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
    if (g_LuaDebug) DebugPrint("LUA: is_player_wearing_fellowship_medallion called");
    bool wearing = g_Player->IsWearingFellowshipMedallion();
    lua_pushboolean(L, wearing);
    return 1;
}

static int LuaGetScheduleTime(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_schedule_time called");
    lua_pushinteger(L, g_scheduleTime);
    return 1;
}

static int LuaGetNPCTrainingPoints(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_npc_training_points called");
    int npc_id = luaL_checkinteger(L, 1);
    int training_points = 0;
    if (npc_id == 0) // Avatar
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
    if (g_LuaDebug) DebugPrint("LUA: get_npc_training_level called");
    int npc_id = luaL_checkinteger(L, 1);
    int npc_skill = luaL_checkinteger(L, 2);
    int training_level = 0;

    if (npc_id == 0) // Avatar
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

static int LuaSetCameraAngle(lua_State *L)
{
    int new_angle = luaL_checkinteger(L, 1);
    if (g_LuaDebug) DebugPrint("LUA: set_camera_angle called with angle " + to_string(new_angle));
    //  Convert angle to radians
    float new_angle_rads = new_angle % 360;
    if (new_angle_rads < 0) new_angle_rads += 360;
    new_angle_rads = (new_angle_rads * 3.14159f) / 180.0f;
    g_cameraRotationTarget = new_angle_rads;
    g_autoRotate = true;
    return 0;
}

static int LuaJumpCameraAngle(lua_State *L)
{
    int new_angle = luaL_checkinteger(L, 1);
    if (g_LuaDebug) DebugPrint("LUA: set_camera_angle called with angle " + to_string(new_angle));
    //  Convert angle to radians
    float new_angle_rads = new_angle % 360;
    if (new_angle_rads < 0) new_angle_rads += 360;
    new_angle_rads = (new_angle_rads * 3.14159f) / 180.0f;
    g_cameraRotation = new_angle_rads;
    DoCameraMovement(true);
    return 0;
}

static int LuaRemovePartyGold(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: remove_party_gold called");
    int gold_to_remove = luaL_checkinteger(L, 1);
    g_Player->SetGold(g_Player->GetGold() - gold_to_remove);
    return 0;
}

static int LuaIncreaseNPCCombatLevel(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: increase_npc_combat_level called");
    int npc_id = luaL_checkinteger(L, 1);
    int amount_to_increase = luaL_checkinteger(L, 2);

    if (npc_id == 0)
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

//  Parameters: shape, frame, cost per, amount
//  Return flags: 1 - success, 2 - too heavy, 3 - can't afford
static int LuaPurchaseObject(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: purchase_object called");
    int shape = luaL_checkinteger(L, 1);
    int frame = luaL_checkinteger(L, 2);
    int cost_per = luaL_checkinteger(L, 3);
    int amount = luaL_checkinteger(L, 4);

    //  Player aborted by choosing 0 units
    if (amount == 0)
    {
        lua_pushinteger(L, 0);
        return 1;
    }

    //  Check cost
    if (cost_per * amount > g_Player->GetGold())
    {
        lua_pushinteger(L, 3);
        return 1;
    }

    if (g_Player->GetWeight() + (amount * g_objectDataTable[shape].m_weight) > g_Player->GetMaxWeight())
    {
        lua_pushinteger(L, 2);
        return 1;
    }

    //  Yay, we can actually purchase it!
    for (int i = 0; i < amount; ++i)
    {
        unsigned int nextID = GetNextID();
        AddObject(shape, frame, nextID, 0, 0, 0);

        AddObjectToContainer(nextID, g_NPCData[0]->m_objectID);
    }

    g_Player->SetGold(g_Player->GetGold() - (cost_per * amount));
    lua_pushinteger(L, 1);
    return 1;
}

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
    if (g_LuaDebug) DebugPrint("LUA: switch_talk_to called with " + std::to_string(npc_id));
    ConversationState::ConversationStep step;
    step.type = ConversationState::ConversationStepType::STEP_CHANGE_PORTRAIT;
    step.dialog = "";
    step.npcId = npc_id;
    step.frame = frame;
    g_ConversationState->AddStep(step);
    cout << "Switching talk to NPC ID: " << npc_id << "\n";

    return 0;
}

// A "book" is a static image with static text overlaid, so it encompasses scripts, plaques, signs and gravestones as well.
static int LuaOpenBook(lua_State *L)
{
    int book_type = luaL_checkinteger(L, 1);

    // Table: iterate over elements and add strings
    vector<string> bookText;
    int table_len = lua_rawlen(L, 2);
    for (int i = 1; i <= table_len; ++i)
    {
        lua_rawgeti(L, 2, i);
        if (lua_isstring(L, -1))
        {
            const char *thisBookText = lua_tostring(L, -1);
            bookText.push_back(thisBookText);
            std::cout << "Added book text: " << thisBookText << "\n";
        }
        else
        {
            std::cout << "Warning: Non-string element at index " << i << " ignored\n";
        }
    }

     lua_pop(L, 2); // Pop value and array

    GumpBook bookGump;
    bookGump.Setup(book_type, bookText);
    g_gumpManager->AddGump(make_shared<GumpBook>(bookGump));

    return 0;
}

// static int LuaWait(lua_State *L)
// {
//     if (g_LuaDebug)
//     {
//         DebugPrint("LUA: wait called");
//     }
//
//     // Validate argument
//     if (lua_gettop(L) != 1 || !lua_isnumber(L, 1))
//     {
//         luaL_error(L, "Expected one number argument (seconds)");
//         return 0;
//     }
//
//     // Get delay time and current game time
//     double delay = lua_tonumber(L, 1);
//     if (delay < 0)
//     {
//         luaL_error(L, "Delay must be non-negative");
//         return 0;
//     }
//
//     // Add coroutine to waiting list
//     g_mainState->m_waitTime = delay;
//
//     // Yield coroutine
//     return lua_yield(L, 0);
// }

// static int LuaWait(lua_State *L)
// {
//     if (g_LuaDebug)
//     {
//         DebugPrint("LUA: wait called");
//     }
//
//     if (lua_gettop(L) != 1 || !lua_isnumber(L, 1))
//     {
//         luaL_error(L, "Expected one number argument (seconds)");
//         return 0;
//     }
//
//     double delay = lua_tonumber(L, 1);
//     if (delay < 0)
//     {
//         luaL_error(L, "Delay must be non-negative");
//         return 0;
//     }
//
//     if (!lua_isthread(L, -1))
//     {
//         luaL_error(L, "wait must be called from a coroutine");
//         return 0;
//     }
//
//     // Push delay as yield result
//     lua_pushnumber(L, delay);
//     return lua_yield(L, 1);
// }

static int LuaShowUIElements(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: block_input called");
    g_mainState->m_showUIElements = true;
    return 0;
}

static int LuaHideUIElements(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: block_input called");
    g_mainState->m_showUIElements = false;
    return 0;
}


static int LuaBlockInput(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: block_input called");
    g_mainState->m_allowInput = false;
    return 0;
}

static int LuaResumeInput(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: resume_input called");
    g_mainState->m_allowInput = true;
    return 0;
}

static int LuaSetPause(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: pause_game called");
    int paused = luaL_checkinteger(L, 1);
    g_mainState->m_paused = bool(paused);
    return 0;
}

static int LuaFadeIn(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: fade_in called");
    int duration = luaL_checkinteger(L, 1);
    g_mainState->m_fadeState = MainState::FadeState::FADE_IN;
    g_mainState->m_fadeDuration = duration;
    g_mainState->m_fadeTime = duration;
    return 0;
}

static int LuaFadeOut(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: fade_out called");
    int duration = luaL_checkinteger(L, 1);
    g_mainState->m_fadeState = MainState::FadeState::FADE_OUT;
    g_mainState->m_fadeDuration = duration;
    g_mainState->m_fadeTime = 0;
    return 0;
}

static int LuaIsConversationRunning(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: is_conversation_running called");
    bool running = g_ConversationState && g_StateMachine->GetCurrentState() == STATE_CONVERSATIONSTATE;
    DebugPrint("Conversation is running: " + string(running ? "true" : "false"));
    lua_pushboolean(L, running);
    return 1;
}

static int LuaSetModelAnimationFrame(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    string anim = luaL_checkstring(L, 2);
    int frame = luaL_checkinteger(L, 3);
    if (g_objectList.find(object_id) != g_objectList.end())
    {
        if (g_LuaDebug) DebugPrint("LUA: set_model_animation_frame called on object ID " + to_string(object_id) + " anim " + anim + " frame " + to_string(frame));
        g_objectList[object_id]->m_shapeData->m_customMesh->SetAnimationFrame(anim, frame);
    }
    return 0;
}

//  Force an NPC to a specific frame in their current animation
static int LuaSetNPCFrame(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    int framex = luaL_checkinteger(L, 2);
    int framey = luaL_checkinteger(L, 3);
    if (g_objectList.find(g_NPCData[npc_id].get()->m_objectID) != g_objectList.end())
    {
        if (g_LuaDebug) DebugPrint("LUA: set_npc_frame called on npc " + to_string(npc_id) +
        " frame " + to_string(framex) + "," + to_string(framey));
        g_objectList[g_NPCData[npc_id].get()->m_objectID].get()->SetFrames(framex, framey);
    }
    return 0;
}

static int LuaSetObjectVisibility(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    bool visible = lua_toboolean(L, 2);

    if (g_objectList.find(object_id) != g_objectList.end())
    {
        if (g_LuaDebug) DebugPrint("LUA: set_object_visibility called on object " + to_string(object_id) +
        " set to " + to_string(visible));
        g_objectList[object_id]->m_ShouldDraw = visible;
    }
    return 0;
}

static int LuaSetNPCVisibility(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    bool visible = lua_toboolean(L, 2);

    if (g_objectList.find(g_NPCData[npc_id]->m_objectID) != g_objectList.end())
    {
        if (g_LuaDebug) DebugPrint("LUA: set_object_visibility called on " + to_string(npc_id) +
        " set to " + to_string(visible));
        g_objectList[g_NPCData[npc_id]->m_objectID]->m_ShouldDraw = visible;
    }
    return 0;
}

static int LuaAbort(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: abort called - terminating script");
    return luaL_error(L, "SCRIPT_ABORTED");
}

void RegisterAllLuaFunctions()
{
    cout << "Registering Lua functions\n";

    // These functions handle the conversation system.
    g_ScriptingSystem->RegisterScriptFunction("switch_talk_to", LuaSwitchTalkTo);
    g_ScriptingSystem->RegisterScriptFunction("second_speaker", LuaSecondSpeaker);
    g_ScriptingSystem->RegisterScriptFunction("hide_npc", LuaHideNPC);
    g_ScriptingSystem->RegisterScriptFunction("add_dialogue", LuaAddDialogue);
    g_ScriptingSystem->RegisterScriptFunction("add_answer", LuaAddAnswers);
    g_ScriptingSystem->RegisterScriptFunction("start_conversation", LuaStartConversation);
    g_ScriptingSystem->RegisterScriptFunction("end_conversation", LuaEndConversation);
    g_ScriptingSystem->RegisterScriptFunction("abort", LuaAbort);

    g_ScriptingSystem->RegisterScriptFunction("remove_answer", LuaRemoveAnswers);
    g_ScriptingSystem->RegisterScriptFunction("save_answers", LuaSaveAnswers);
    g_ScriptingSystem->RegisterScriptFunction("restore_answers", LuaRestoreAnswers);
    g_ScriptingSystem->RegisterScriptFunction("get_answer", LuaGetAnswer);
    g_ScriptingSystem->RegisterScriptFunction("clear_answers", LuaClearAnswers);
    g_ScriptingSystem->RegisterScriptFunction("get_purchase_option", LuaGetPurchaseOption);
    g_ScriptingSystem->RegisterScriptFunction("purchase_object", LuaPurchaseObject);
    g_ScriptingSystem->RegisterScriptFunction("is_conversation_running", LuaIsConversationRunning);

    // These are general utility functions.
    g_ScriptingSystem->RegisterScriptFunction("ask_yes_no", LuaAskYesNo);
    g_ScriptingSystem->RegisterScriptFunction("ask_answer", LuaAskAnswer);
    g_ScriptingSystem->RegisterScriptFunction("ask_multiple_choice", LuaAskMultipleChoice);
    g_ScriptingSystem->RegisterScriptFunction("ask_number", LuaAskNumber);
    g_ScriptingSystem->RegisterScriptFunction("object_select_modal", LuaObjectSelectModal);
    g_ScriptingSystem->RegisterScriptFunction("random", LuaRandom);
    g_ScriptingSystem->RegisterScriptFunction("is_object_in_npc_inventory", LuaIsObjectInNPCInventory);
    g_ScriptingSystem->RegisterScriptFunction("is_object_in_container", LuaIsObjectInContainer);
    g_ScriptingSystem->RegisterScriptFunction("has_object_of_type", LuaHasObjectOfType);
    g_ScriptingSystem->RegisterScriptFunction("add_object_to_container", LuaAddObjectToContainer);
    g_ScriptingSystem->RegisterScriptFunction("add_object_to_npc_inventory", LuaAddObjectToNPCInventory);

    // These functions are used to manipulate the game world.
    g_ScriptingSystem->RegisterScriptFunction("get_object_shape", LuaGetObjectShape);
    g_ScriptingSystem->RegisterScriptFunction("set_object_shape", LuaSetObjectShape);
    g_ScriptingSystem->RegisterScriptFunction("get_object_frame", LuaGetObjectFrame);
    g_ScriptingSystem->RegisterScriptFunction("set_object_frame", LuaSetObjectFrame);
    g_ScriptingSystem->RegisterScriptFunction("get_object_quality", LuaGetObjectQuality);
    g_ScriptingSystem->RegisterScriptFunction("set_object_quality", LuaSetObjectQuality);
    g_ScriptingSystem->RegisterScriptFunction("get_object_position", LuaGetObjectPosition);
    g_ScriptingSystem->RegisterScriptFunction("set_object_position", LuaSetObjectPosition);
    // NOTE: find_nearby_objects removed - not needed for single door implementation
    g_ScriptingSystem->RegisterScriptFunction("get_npc_property", LuaGetNPCProperty);
    g_ScriptingSystem->RegisterScriptFunction("set_npc_property", LuaSetNPCProperty);

    // These functions are used to manipulate the party.
    g_ScriptingSystem->RegisterScriptFunction("get_party_member", LuaGetPartyMember);
    g_ScriptingSystem->RegisterScriptFunction("get_party_members", LuaGetPartyMemberNames);
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
    g_ScriptingSystem->RegisterScriptFunction("get_him_or_her", LuaGetHimOrHer);

    // These functions are used to get information about the world and objects.
    g_ScriptingSystem->RegisterScriptFunction("get_time_hour", LuaGetTimeHour);
    g_ScriptingSystem->RegisterScriptFunction("get_time_minute", LuaGetTimeMinute);
    g_ScriptingSystem->RegisterScriptFunction("get_schedule_time", LuaGetScheduleTime);
    g_ScriptingSystem->RegisterScriptFunction("open_book", LuaOpenBook);
    g_ScriptingSystem->RegisterScriptFunction("bark", LuaBark);
    g_ScriptingSystem->RegisterScriptFunction("play_music", LuaPlayMusic);

    // These functions manipulate NPCs.
    g_ScriptingSystem->RegisterScriptFunction("set_npc_pos", LuaSetNPCPos);
    g_ScriptingSystem->RegisterScriptFunction("set_npc_dest", LuaSetNPCDest);



    // These are new functions designed to be called by Lua scripts.
    g_ScriptingSystem->RegisterScriptFunction("get_flag", LuaGetFlag);
    g_ScriptingSystem->RegisterScriptFunction("set_flag", LuaSetFlag);
    g_ScriptingSystem->RegisterScriptFunction("is_int_in_array", LuaIsIntInArray);
    g_ScriptingSystem->RegisterScriptFunction("is_string_in_array", LuaIsStringInArray);

    g_ScriptingSystem->RegisterScriptFunction("get_schedule", LuaGetSchedule);
    
    g_ScriptingSystem->RegisterScriptFunction("debug_print", LuaDebugPrint);

    g_ScriptingSystem->RegisterScriptFunction("is_player_wearing_fellowship_medallion", LuaIsPlayerWearingMedallion);

    //g_ScriptingSystem->RegisterScriptFunction( "wait", LuaWait);

    g_ScriptingSystem->RegisterScriptFunction( "bark_npc", LuaBarkNPC);

    g_ScriptingSystem->RegisterScriptFunction( "block_input", LuaBlockInput);
    g_ScriptingSystem->RegisterScriptFunction( "resume_input", LuaResumeInput);

    g_ScriptingSystem->RegisterScriptFunction( "set_pause", LuaSetPause);

    g_ScriptingSystem->RegisterScriptFunction( "fade_out", LuaFadeOut);
    g_ScriptingSystem->RegisterScriptFunction( "fade_in", LuaFadeIn);

    g_ScriptingSystem->RegisterScriptFunction( "spawn_object", LuaSpawnObject);
    g_ScriptingSystem->RegisterScriptFunction( "destroy_object", LuaDestroyObject);

    g_ScriptingSystem->RegisterScriptFunction( "set_camera_angle", LuaSetCameraAngle);
    g_ScriptingSystem->RegisterScriptFunction( "jump_camera_angle", LuaJumpCameraAngle);
    g_ScriptingSystem->RegisterScriptFunction( "show_ui_elements", LuaShowUIElements);
    g_ScriptingSystem->RegisterScriptFunction( "hide_ui_elements", LuaHideUIElements);

    g_ScriptingSystem->RegisterScriptFunction( "start_npc_schedule", LuaStartNPCSchedule);
    g_ScriptingSystem->RegisterScriptFunction( "stop_npc_schedule", LuaStopNPCSchedule);

    g_ScriptingSystem->RegisterScriptFunction( "set_npc_frame", LuaSetNPCFrame);
    g_ScriptingSystem->RegisterScriptFunction( "set_model_animation_frame", LuaSetModelAnimationFrame);

    g_ScriptingSystem->RegisterScriptFunction( "set_object_visibility", LuaSetObjectVisibility);
    g_ScriptingSystem->RegisterScriptFunction( "set_npc_visibility", LuaSetNPCVisibility);

    cout << "Registered all Lua functions\n";
}
