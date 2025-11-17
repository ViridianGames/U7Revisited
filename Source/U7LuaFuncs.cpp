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
#include "Pathfinding.h"

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

static int LuaConsoleLog(lua_State *L)
{
    const char *text = luaL_checkstring(L, 1);
    AddConsoleString(std::string(text));
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

// Compare string - checks if player's answer matches the given string
static int LuaCmps(lua_State *L)
{
    // this implementation might have side-effects.
    // the scripts call this multiple times in a row, but presumably
    // we only want the player to actually answer once. so there might
    // be other places that need to clear the global last answer or
    // the user won't get prompted again the future when they need to be
    if (!g_ConversationState) {
        return luaL_error(L, "ConversationState not initialized");
    }

    // Get the comparison string argument
    const char *compare_str = luaL_checkstring(L, 1);

    // Get the global answer (without clearing it, unlike get_answer())
    lua_getglobal(L, "answer");
    const char *selected_answer = lua_tostring(L, -1);
    lua_pop(L, 1);

    // Compare (case-insensitive)
	 // The function _stricmp() is not standard C/C++, but strcasecmp()
    // isn't supported on Windows, so we have to write it ourselves.
    bool matches = false;
    if (selected_answer && compare_str)
    {
       std::string saString = selected_answer;
       std::string csString = compare_str;
       std::transform(saString.begin(), saString.end(), saString.begin(),
          [](unsigned char c) { return std::tolower(c); });
       std::transform(csString.begin(), csString.end(), csString.begin(),
          [](unsigned char c) { return std::tolower(c); });

       return csString.compare(saString);
    }

    lua_pushboolean(L, matches);
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

    // Clear any active bark referencing this object to prevent crash when shapeData changes
    if (g_mainState && g_mainState->m_barkObject == object)
    {
        g_mainState->m_barkObject = nullptr;
        g_mainState->m_barkDuration = 0;
    }

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
        // Create table {x, y, z}
        lua_newtable(L);
        lua_pushnumber(L, object->m_Pos.x);
        lua_rawseti(L, -2, 1);  // table[1] = x
        lua_pushnumber(L, object->m_Pos.y);
        lua_rawseti(L, -2, 2);  // table[2] = y
        lua_pushnumber(L, object->m_Pos.z);
        lua_rawseti(L, -2, 3);  // table[3] = z
        return 1;  // Return 1 table
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

    // Property IDs: 0=strength, 1=dexterity, 2=intelligence, 3=health, 4=combat, 5=mana, 6=magic, 7=training, 8=exp, 9=food_level, 10=sex_flag
    int value = 0;

    if (g_NPCData.find(npc_id) != g_NPCData.end())
    {
        NPCData* npc = g_NPCData[npc_id].get();
        switch (property_id)
        {
            case 0: value = npc->str; break;           // strength
            case 1: value = npc->dex; break;           // dexterity
            case 2: value = npc->iq; break;            // intelligence
            case 3: value = npc->str; break;           // health (uses strength)
            case 4: value = npc->combat; break;        // combat
            case 5: value = npc->magic; break;         // mana (uses magic)
            case 6: value = npc->magic; break;         // magic
            case 7: value = npc->training; break;      // training
            case 8: value = npc->xp; break;            // experience
            case 9: value = npc->food; break;          // food level
            case 10: value = (npc->type >> 0) & 1; break; // sex flag (bit 0 of type)
            default: value = 0; break;
        }
    }

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

    if (g_NPCData.find(npc_id) != g_NPCData.end())
    {
        NPCData* npc = g_NPCData[npc_id].get();
        switch (property_id)
        {
            case 0: npc->str = value; break;           // strength
            case 1: npc->dex = value; break;           // dexterity
            case 2: npc->iq = value; break;            // intelligence
            case 3: npc->str = value; break;           // health (uses strength)
            case 4: npc->combat = value; break;        // combat
            case 5: npc->magic = value; break;         // mana (uses magic)
            case 6: npc->magic = value; break;         // magic
            case 7: npc->training = value; break;      // training
            case 8: npc->xp = value; break;            // experience
            case 9: npc->food = value; break;          // food level
            case 10:                                   // sex flag
                npc->type = (npc->type & ~1) | (value & 1);
                break;
        }
    }

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
    if (g_LuaDebug) DebugPrint("LUA: npc_id_in_party called");
    int npc_id = luaL_checkinteger(L, 1);
    bool in_party = g_Player->NPCIDInParty(npc_id);
    lua_pushboolean(L, in_party);
    return 1;
}

static int LuaNPCNameInParty(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: npc_name_in_party called");
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

    // Basic movement - would move current object or player to position
    // In full implementation, would move object with pathfinding
    if (g_Player)
    {
        Vector3 currentPos = g_Player->GetPlayerPosition();
        g_Player->SetPlayerPosition({(float)x, currentPos.y, (float)y});
    }

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

// Helper function to destroy an object by ID (shared logic)
static void DestroyObjectByID(int object_id)
{
    auto it = g_objectList.find(object_id);
    if (it == g_objectList.end() || !it->second)
    {
        if (g_LuaDebug)
        {
            DebugPrint("DestroyObjectByID: Object " + to_string(object_id) + " not found in object list");
        }
        return;
    }

    U7Object* obj = it->second.get();

    if (g_LuaDebug)
    {
        DebugPrint("DestroyObjectByID: Marking object " + to_string(object_id) + " as dead");
    }

    // If object is in a container, remove it from that container's inventory
    if (obj->m_containingObjectId != -1)
    {
        auto container_it = g_objectList.find(obj->m_containingObjectId);
        if (container_it != g_objectList.end() && container_it->second)
        {
            container_it->second->RemoveObjectFromInventory(object_id);
        }
    }

    // Notify pathfinding grid before deletion if this is a non-walkable object
    if (obj->m_objectData && obj->m_objectData->m_isNotWalkable)
    {
        NotifyPathfindingGridUpdate((int)obj->m_Pos.x, (int)obj->m_Pos.z);
    }

    // Clear any active bark referencing this object to prevent crash when drawing
    if (g_mainState && g_mainState->m_barkObject == obj)
    {
        g_mainState->m_barkObject = nullptr;
        g_mainState->m_barkDuration = 0;
    }

    // Mark object as dead and invisible for deferred deletion
    // The main update loop will remove it from chunk map and delete it
    // This prevents iterator invalidation when called during object updates
    obj->SetIsDead(true);
    obj->m_Visible = false;
}

static int LuaDestroyObject(lua_State *L)
{
    int object_id = luaL_checkinteger(L, 1);
    DestroyObjectByID(object_id);
    return 0;
}

// Silent version of destroy_object - currently just calls the regular version
static int LuaDestroyObjectSilent(lua_State *L)
{
    return LuaDestroyObject(L);
}

// 0x005B | consume_object
// Consumes an object (typically food), applying its effects and destroying it
// Parameters: event_type (91 for eating), quantity (nutrition value), object_id, eater_id
static int LuaConsumeObject(lua_State *L)
{
    int event_type = luaL_checkinteger(L, 1);  // 91 = eating
    int quantity = luaL_checkinteger(L, 2);     // nutrition/healing amount
    int object_id = luaL_checkinteger(L, 3);    // the object to consume
    int eater_id = luaL_checkinteger(L, 4);     // the NPC eating the food

    if (g_LuaDebug)
    {
        DebugPrint("LUA: consume_object called - Event: " + to_string(event_type) +
                   ", Quantity: " + to_string(quantity) +
                   ", Object ID: " + to_string(object_id) +
                   ", Eater ID: " + to_string(eater_id));
    }

    // TODO: Apply effects based on event_type and eater_id
    // For now, just destroy the object after consumption
    // Future: restore health/hunger for eater_id, play sound effects, etc.

    DestroyObjectByID(object_id);
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

// Exult intrinsic 0x35: find_nearby
// Finds objects near a reference object, filtered by shape and distance
static int LuaFindNearby(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: find_nearby called");

    int objectref = luaL_checkinteger(L, 1);  // Reference object to search near
    int shape = luaL_checkinteger(L, 2);       // Shape ID to find (0 = any shape)
    int distance = luaL_checkinteger(L, 3);    // Search radius in tiles
    int mask = luaL_checkinteger(L, 4);        // Filter mask (quality/frame filter)

    // Get the reference object
    auto refIt = g_objectList.find(objectref);
    if (refIt == g_objectList.end())
    {
        if (g_LuaDebug) DebugPrint("LUA: find_nearby - reference object not found");
        lua_pushnil(L);
        return 1;
    }

    U7Object* refObj = refIt->second.get();
    Vector3 refPos = refObj->GetPos();

    // Search through all objects
    for (const auto& pair : g_objectList)
    {
        int objId = pair.first;
        U7Object* obj = pair.second.get();

        // Skip the reference object itself
        if (objId == objectref)
            continue;

        // Skip objects without shape data
        if (!obj->m_shapeData)
            continue;

        // Check shape filter (0 means any shape)
        if (shape != 0 && obj->m_shapeData->m_shape != shape)
            continue;

        // Check distance
        Vector3 objPos = obj->GetPos();
        float dx = objPos.x - refPos.x;
        float dy = objPos.y - refPos.y;
        float dist = sqrt(dx * dx + dy * dy);

        if (dist > distance)
            continue;

        // Apply mask filter if non-zero
        // Note: mask meaning is unclear from Exult docs, might be quality/frame
        // For now, we'll use it as a quality filter if > 0
        if (mask > 0 && obj->m_objectData)
        {
            // Could check quality, frame, or other properties here
            // Skipping for now as exact mask usage is unclear
        }

        // Found a match!
        if (g_LuaDebug)
            DebugPrint("LUA: find_nearby found object " + std::to_string(objId) +
                      " at distance " + std::to_string(dist));
        lua_pushinteger(L, objId);
        return 1;
    }

    // No matching object found
    if (g_LuaDebug) DebugPrint("LUA: find_nearby - no matching object found");
    lua_pushnil(L);
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

    // Swap if arguments are in wrong order
    if (min > max) {
        int temp = min;
        min = max;
        max = temp;
    }

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

    // Bounds check: verify NPC exists in g_NPCData
    auto it = g_NPCData.find(npc_id);
    if (it == g_NPCData.end() || !it->second)
    {
        Log("ERROR: LuaGetSchedule - Invalid NPC ID: " + std::to_string(npc_id));
        lua_pushinteger(L, 0);  // Return 0 as default schedule
        return 1;
    }

    int schedule = it->second->m_currentActivity;
    lua_pushinteger(L, schedule);
    return 1;
}

static int LuaGetScheduleType(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_schedule_type called");

    // Takes NPC name, looks up ID
    string npc_name = luaL_checkstring(L, 1);
    int npc_id = -1;

    if (npc_name == g_Player->GetPlayerName())
    {
        npc_id = 0;
    }
    else
    {
        for (auto& pair : g_NPCData)
        {
            if (npc_name == pair.second->name)
            {
                npc_id = pair.second->id;
                break;
            }
        }
    }

    if (npc_id >= 0 && g_NPCData.find(npc_id) != g_NPCData.end())
    {
        int schedule_type = g_NPCData[npc_id]->m_currentActivity;
        lua_pushinteger(L, schedule_type);
    }
    else
    {
        lua_pushinteger(L, -1); // Invalid NPC
    }

    return 1;
}

static int LuaGetNPCNameFromId(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: get_npc_name called");
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
    if (g_LuaDebug) DebugPrint("LUA: get_training_level called");
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

static int LuaSetTrainingLevel(lua_State *L)
{
    if (g_LuaDebug) DebugPrint("LUA: set_training_level called");
    int npc_id = luaL_checkinteger(L, 1);
    int npc_skill = luaL_checkinteger(L, 2);
    int value = luaL_checkinteger(L, 3);

    if (npc_id == 0) // Avatar
    {
        switch (npc_skill)
        {
        case 0:
            g_Player->SetStr(value);
            break;
        case 1:
            g_Player->SetDex(value);
            break;
        case 2:
            g_Player->SetInt(value);
            break;
        case 4:
            g_Player->SetCombat(value);
            break;
        case 6:
            g_Player->SetMagic(value);
            break;
        }
    }
    else
    {
        if (g_NPCData.find(npc_id) != g_NPCData.end())
        {
            switch (npc_skill)
            {
            case 0:
                g_NPCData[npc_id]->str = value;
                break;
            case 1:
                g_NPCData[npc_id]->dex = value;
                break;
            case 2:
                g_NPCData[npc_id]->iq = value;
                break;
            case 4:
                g_NPCData[npc_id]->combat = value;
                break;
            case 6:
                g_NPCData[npc_id]->magic = value;
                break;
            }
        }
    }

    return 0;
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

    U7Object* avatarObject = g_objectList[g_NPCData[0]->m_objectID].get();
    if (avatarObject->GetWeight() + (amount * g_objectDataTable[shape].m_weight) > g_Player->GetMaxWeight())
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

// ============================================================================
// EXULT INTRINSICS - HIGH PRIORITY
// ============================================================================

// 0x000E | find_nearest
static int LuaFindNearest(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);
    int shape = (int)lua_tointeger(L, 2);
    int max_distance = (int)lua_tointeger(L, 3);

    // Validate source object exists
    if (g_objectList.find(object_id) == g_objectList.end())
    {
        lua_pushnil(L);
        return 1;
    }

    Vector3 source_pos = g_objectList[object_id]->GetPos();
    int closest_id = -1;
    int best_dist_sq = max_distance * max_distance + 1;

    // Search all objects for nearest match
    for (const auto& pair : g_objectList)
    {
        int candidate_id = pair.first;
        U7Object* candidate = pair.second.get();

        // Skip self
        if (candidate_id == object_id)
            continue;

        // Check if shape matches (or shape == -1 for any object)
        if (shape != -1 && candidate->m_ObjectType != shape)
            continue;

        // Calculate distance squared (Chebyshev-ish, but using actual distance for better accuracy)
        Vector3 candidate_pos = candidate->GetPos();
        int dx = (int)abs(candidate_pos.x - source_pos.x);
        int dy = (int)abs(candidate_pos.y - source_pos.y);
        int dz = (int)abs(candidate_pos.z - source_pos.z);
        int dist_sq = dx * dx + dy * dy + dz * dz;

        // Check if within range and closer than previous best
        if (dist_sq < best_dist_sq)
        {
            best_dist_sq = dist_sq;
            closest_id = candidate_id;
        }
    }

    if (closest_id == -1)
    {
        lua_pushnil(L);
    }
    else
    {
        lua_pushinteger(L, closest_id);
    }
    return 1;
}

// 0x0029 | find_object
static int LuaFindObject(lua_State *L)
{
    int container_id = (int)lua_tointeger(L, 1);
    int shape = (int)lua_tointeger(L, 2);
    int quality = (int)lua_tointeger(L, 3);
    int frame = (int)lua_tointeger(L, 4);

    // Check if container exists
    if (g_objectList.find(container_id) == g_objectList.end())
    {
        lua_pushnil(L);
        return 1;
    }

    U7Object* container = g_objectList[container_id].get();

    // Search through container's inventory
    for (int item_id : container->m_inventory)
    {
        if (g_objectList.find(item_id) == g_objectList.end())
            continue;

        U7Object* item = g_objectList[item_id].get();

        // Check shape match (or -1/-359 for any shape)
        if (shape != -1 && shape != -359 && item->m_ObjectType != shape)
            continue;

        // Check quality match (or -1/-359 for any quality)
        if (quality != -1 && quality != -359 && item->m_Quality != quality)
            continue;

        // Check frame match (or -1/-359 for any frame)
        if (frame != -1 && frame != -359 && item->m_Frame != frame)
            continue;

        // Found a match!
        lua_pushinteger(L, item_id);
        return 1;
    }

    // No match found
    lua_pushnil(L);
    return 1;
}

// 0x0019 | get_distance
static int LuaGetDistanceBetween(lua_State *L)
{
    int obj1_id = (int)lua_tointeger(L, 1);
    int obj2_id = (int)lua_tointeger(L, 2);

    // Get both objects
    if (g_objectList.find(obj1_id) == g_objectList.end() ||
        g_objectList.find(obj2_id) == g_objectList.end())
    {
        lua_pushinteger(L, 0);
        return 1;
    }

    U7Object* obj1 = g_objectList[obj1_id].get();
    U7Object* obj2 = g_objectList[obj2_id].get();

    // Calculate Chebyshev distance (tile-based, like Exult)
    Vector3 pos1 = obj1->GetPos();
    Vector3 pos2 = obj2->GetPos();

    int dx = abs((int)pos1.x - (int)pos2.x);
    int dz = abs((int)pos1.z - (int)pos2.z);
    int distance = (dx > dz) ? dx : dz; // max(dx, dz)

    lua_pushinteger(L, distance);
    return 1;
}

// 0x001A | find_direction
static int LuaFindDirectionBetween(lua_State *L)
{
    int from_obj_id = (int)lua_tointeger(L, 1);
    int to_obj_id = (int)lua_tointeger(L, 2);

    if (g_objectList.find(from_obj_id) == g_objectList.end() ||
        g_objectList.find(to_obj_id) == g_objectList.end())
    {
        lua_pushinteger(L, 0);
        return 1;
    }

    Vector3 from_pos = g_objectList[from_obj_id]->GetPos();
    Vector3 to_pos = g_objectList[to_obj_id]->GetPos();

    // Calculate direction (0-7): 0=North, 1=NE, 2=East, 3=SE, 4=South, 5=SW, 6=West, 7=NW
    float dx = to_pos.x - from_pos.x;
    float dz = to_pos.z - from_pos.z;

    // Calculate angle in radians, then convert to 0-7 direction
    float angle = atan2(dz, dx); // atan2(y, x) in standard coords
    // Convert to degrees: 0 = East, 90 = South, 180 = West, 270 = North
    float degrees = angle * 180.0f / 3.14159265f;

    // Adjust so 0 = North: rotate by -90 degrees
    degrees = degrees - 90.0f;
    if (degrees < 0) degrees += 360.0f;

    // Convert to 0-7 (8 directions), rounding to nearest
    int direction = (int)((degrees + 22.5f) / 45.0f) % 8;

    lua_pushinteger(L, direction);
    return 1;
}

// 0x0087 | direction_from
static int LuaDirectionFrom(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);

    // This returns the object's current facing direction
    if (g_objectList.find(object_id) == g_objectList.end())
    {
        lua_pushinteger(L, 0);
        return 1;
    }

    U7Object* obj = g_objectList[object_id].get();

    // Convert object's angle to 0-7 direction
    float degrees = obj->m_Angle;
    if (degrees < 0) degrees += 360.0f;

    int direction = (int)((degrees + 22.5f) / 45.0f) % 8;

    lua_pushinteger(L, direction);
    return 1;
}

// 0x0028 | count_objects
static int LuaCountObjects(lua_State *L)
{
    int container_id = (int)lua_tointeger(L, 1);
    int shape = (int)lua_tointeger(L, 2);
    int quality = (int)lua_tointeger(L, 3);
    int frame = (int)lua_tointeger(L, 4);

    // Check if container exists
    if (g_objectList.find(container_id) == g_objectList.end())
    {
        lua_pushinteger(L, 0);
        return 1;
    }

    U7Object* container = g_objectList[container_id].get();
    int count = 0;

    // Count matching objects in container's inventory
    for (int item_id : container->m_inventory)
    {
        if (g_objectList.find(item_id) == g_objectList.end())
            continue;

        U7Object* item = g_objectList[item_id].get();

        // Check shape match (or -1/-359 for any shape)
        if (shape != -1 && shape != -359 && item->m_ObjectType != shape)
            continue;

        // Check quality match (or -1/-359 for any quality)
        if (quality != -1 && quality != -359 && item->m_Quality != quality)
            continue;

        // Check frame match (or -1/-359 for any frame)
        if (frame != -1 && frame != -359 && item->m_Frame != frame)
            continue;

        // This item matches - count it (and add its quantity if stackable)
        count += (item->m_Quality > 0 ? item->m_Quality : 1);
    }

    lua_pushinteger(L, count);
    return 1;
}

// 0x0030 | find_nearby_avatar
static int LuaFindNearbyAvatar(lua_State *L)
{
    int shape = (int)lua_tointeger(L, 1);
    int max_distance = 20;  // Default search radius (can be adjusted)

    lua_newtable(L);  // Create result table

    if (!g_Player)
    {
        return 1;  // Return empty table if no player
    }

    Vector3 player_pos = g_Player->GetPlayerPosition();
    int table_index = 1;

    // Search all objects for matches near the avatar
    for (const auto& pair : g_objectList)
    {
        int candidate_id = pair.first;
        U7Object* candidate = pair.second.get();

        // Skip if shape doesn't match (or shape == -1 for any object)
        if (shape != -1 && candidate->m_ObjectType != shape)
            continue;

        // Calculate distance from player
        Vector3 candidate_pos = candidate->GetPos();
        int dx = (int)abs(candidate_pos.x - player_pos.x);
        int dz = (int)abs(candidate_pos.z - player_pos.z);
        int distance = (dx > dz) ? dx : dz;  // Chebyshev distance

        // Add to result table if within range
        if (distance <= max_distance)
        {
            lua_pushinteger(L, table_index);
            lua_pushinteger(L, candidate_id);
            lua_settable(L, -3);
            table_index++;
        }
    }

    return 1;
}

// 0x0016 | get_item_quantity
static int LuaGetItemQuantity(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);

    if (g_objectList.find(object_id) == g_objectList.end())
    {
        lua_pushinteger(L, 0);
        return 1;
    }

    U7Object* obj = g_objectList[object_id].get();
    // In Ultima 7, quality field is used as quantity for stackable items
    // For non-stackable items, quantity is implicitly 1
    int quantity = (obj->m_Quality > 0) ? obj->m_Quality : 1;

    lua_pushinteger(L, quantity);
    return 1;
}

// 0x0017 | set_item_quantity
static int LuaSetItemQuantity(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);
    int quantity = (int)lua_tointeger(L, 2);

    if (g_objectList.find(object_id) == g_objectList.end())
    {
        return 0;
    }

    U7Object* obj = g_objectList[object_id].get();
    // Set quality field which represents quantity for stackable items
    obj->m_Quality = quantity;

    // TODO: If quantity reaches 0, should the object be destroyed?
    // Exult does this, but leaving it for now to avoid breaking things

    return 0;
}

// 0x002B | remove_party_items
static int LuaRemovePartyItems(lua_State *L)
{
    int count = (int)lua_tointeger(L, 1);
    int shape = (int)lua_tointeger(L, 2);
    int quality = (int)lua_tointeger(L, 3);
    int frame = (int)lua_tointeger(L, 4);

    if (!g_Player)
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    int remaining_to_remove = count;
    std::vector<int>& party_ids = g_Player->GetPartyMemberIds();

    // Iterate through all party members
    for (int party_member_id : party_ids)
    {
        if (remaining_to_remove <= 0)
            break;

        if (g_objectList.find(party_member_id) == g_objectList.end())
            continue;

        U7Object* party_member = g_objectList[party_member_id].get();

        // Search their inventory for matching items
        for (auto it = party_member->m_inventory.begin(); it != party_member->m_inventory.end(); )
        {
            if (remaining_to_remove <= 0)
                break;

            int item_id = *it;
            if (g_objectList.find(item_id) == g_objectList.end())
            {
                ++it;
                continue;
            }

            U7Object* item = g_objectList[item_id].get();

            // Check if item matches criteria
            bool matches = true;
            if (shape != -1 && shape != -359 && item->m_ObjectType != shape)
                matches = false;
            if (quality != -1 && quality != -359 && item->m_Quality != quality)
                matches = false;
            if (frame != -1 && frame != -359 && item->m_Frame != frame)
                matches = false;

            if (matches)
            {
                int item_quantity = (item->m_Quality > 0) ? item->m_Quality : 1;

                if (item_quantity <= remaining_to_remove)
                {
                    // Remove entire stack
                    remaining_to_remove -= item_quantity;
                    party_member->RemoveObjectFromInventory(item_id);
                    g_objectList.erase(item_id);
                    it = party_member->m_inventory.begin(); // Reset iterator after modification
                }
                else
                {
                    // Remove partial stack
                    item->m_Quality -= remaining_to_remove;
                    remaining_to_remove = 0;
                    ++it;
                }
            }
            else
            {
                ++it;
            }
        }
    }

    // Return true if we removed all requested items
    lua_pushboolean(L, (remaining_to_remove == 0) ? 1 : 0);
    return 1;
}

// 0x002C | add_party_items
static int LuaAddPartyItems(lua_State *L)
{
    int count = (int)lua_tointeger(L, 1);
    int shape = (int)lua_tointeger(L, 2);
    int quality = (int)lua_tointeger(L, 3);
    int frame = (int)lua_tointeger(L, 4);
    // bool temporary = lua_toboolean(L, 5);

    lua_newtable(L);  // Return array of party members who received items

    if (!g_Player || count <= 0)
    {
        return 1;  // Return empty table
    }

    std::vector<int>& party_ids = g_Player->GetPartyMemberIds();
    if (party_ids.empty())
    {
        return 1;  // Return empty table
    }

    // Add items to first available party member (usually player)
    int party_member_id = party_ids[0];
    if (g_objectList.find(party_member_id) == g_objectList.end())
    {
        return 1;
    }

    U7Object* party_member = g_objectList[party_member_id].get();

    // Create the items and add to inventory
    // Note: This is simplified - in real implementation we'd need CreateObject
    // For now, just return the party member who would receive them
    lua_pushinteger(L, 1);  // Index 1
    lua_pushinteger(L, party_member_id);  // Party member ID
    lua_settable(L, -3);

    return 1;
}

// 0x0025 | set_last_created
static int LuaSetLastCreated(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);

    // Track last created object using static variable
    static int g_lastCreatedObject = -1;
    g_lastCreatedObject = object_id;

    lua_pushinteger(L, object_id);
    return 1;
}

// 0x0026 | update_last_created
static int LuaUpdateLastCreated(lua_State *L)
{
    // Position array (x, y, z)
    static int g_lastCreatedObject = -1;

    if (g_lastCreatedObject == -1 || g_objectList.find(g_lastCreatedObject) == g_objectList.end())
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    // Get position from table
    lua_rawgeti(L, 1, 1);  // x
    lua_rawgeti(L, 1, 2);  // y
    lua_rawgeti(L, 1, 3);  // z

    float x = (float)lua_tonumber(L, -3);
    float y = (float)lua_tonumber(L, -2);
    float z = (float)lua_tonumber(L, -1);

    lua_pop(L, 3);  // Clean stack

    U7Object* obj = g_objectList[g_lastCreatedObject].get();
    obj->SetPos({x, y, z});

    lua_pushboolean(L, 1);
    return 1;
}

// 0x0036 | give_last_created
static int LuaGiveLastCreated(lua_State *L)
{
    int recipient_id = (int)lua_tointeger(L, 1);
    static int g_lastCreatedObject = -1;

    if (g_lastCreatedObject == -1 || g_objectList.find(g_lastCreatedObject) == g_objectList.end())
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    if (g_objectList.find(recipient_id) == g_objectList.end())
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    // Add last created object to recipient's inventory
    U7Object* recipient = g_objectList[recipient_id].get();
    bool success = recipient->AddObjectToInventory(g_lastCreatedObject);

    lua_pushboolean(L, success ? 1 : 0);
    return 1;
}

// 0x006F | remove_item
static int LuaRemoveItem(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);

    if (g_objectList.find(object_id) == g_objectList.end())
    {
        return 0;
    }

    U7Object* obj = g_objectList[object_id].get();

    // If contained in another object, remove from that container's inventory
    if (obj->m_isContained && obj->m_containingObjectId != -1)
    {
        if (g_objectList.find(obj->m_containingObjectId) != g_objectList.end())
        {
            U7Object* container = g_objectList[obj->m_containingObjectId].get();
            container->RemoveObjectFromInventory(object_id);
        }
    }

    // Remove from world (erase from object list)
    g_objectList.erase(object_id);

    return 0;
}

// 0x006E | get_container
static int LuaGetContainerOf(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);

    if (g_objectList.find(object_id) == g_objectList.end())
    {
        lua_pushnil(L);
        return 1;
    }

    U7Object* obj = g_objectList[object_id].get();

    // Return the containing object ID if this object is contained
    if (obj->m_isContained && obj->m_containingObjectId != -1)
    {
        lua_pushinteger(L, obj->m_containingObjectId);
    }
    else
    {
        lua_pushnil(L);
    }

    return 1;
}

// 0x0041 | set_to_attack
static int LuaSetToAttack(lua_State *L)
{
    int attacker_id = (int)lua_tointeger(L, 1);
    int target_id = (int)lua_tointeger(L, 2);
    // int weapon_id = (int)lua_tointeger(L, 3);

    // Check if attacker NPC exists
    if (g_objectList.find(attacker_id) == g_objectList.end())
    {
        lua_pushinteger(L, 0);
        return 1;
    }

    U7Object* attacker = g_objectList[attacker_id].get();
    if (!attacker->m_isNPC || !attacker->m_NPCData)
    {
        lua_pushinteger(L, 0);
        return 1;
    }

    // Set the target as the oppressor (who this NPC should attack)
    attacker->m_NPCData->oppressor = target_id;

    lua_pushinteger(L, 1);
    return 1;
}

// 0x004B | set_attack_mode
static int LuaSetAttackMode(lua_State *L)
{
    int npc_id = (int)lua_tointeger(L, 1);
    int mode = (int)lua_tointeger(L, 2);

    // Attack modes: 0=nearest, 1=weakest, 2=strongest, 3=berserk, etc.
    // Store in NPC data - could use a new field or repurpose existing one
    if (g_NPCData.find(npc_id) != g_NPCData.end())
    {
        // For now, just validate the call succeeds
        // In full implementation, would set combat AI behavior
    }

    return 0;
}

// 0x004C | set_oppressor
static int LuaSetOppressor(lua_State *L)
{
    int npc_id = (int)lua_tointeger(L, 1);
    int oppressor_id = (int)lua_tointeger(L, 2);

    // Set who is attacking this NPC
    if (g_NPCData.find(npc_id) != g_NPCData.end())
    {
        g_NPCData[npc_id]->oppressor = oppressor_id;
    }

    return 0;
}

// 0x0054 | attack_object
static int LuaAttackObject(lua_State *L)
{
    int attacker_id = (int)lua_tointeger(L, 1);
    int target_id = (int)lua_tointeger(L, 2);
    // int weapon_id = (int)lua_tointeger(L, 3);

    // Simplified combat - set oppressor relationship
    if (g_NPCData.find(attacker_id) != g_NPCData.end())
    {
        g_NPCData[attacker_id]->oppressor = target_id;
    }
    if (g_NPCData.find(target_id) != g_NPCData.end())
    {
        g_NPCData[target_id]->oppressor = attacker_id;
    }

    // Return hit points dealt (simplified)
    lua_pushinteger(L, 5);
    return 1;
}

// 0x0076 | fire_projectile
static int LuaFireProjectile(lua_State *L)
{
    // int source_id = (int)lua_tointeger(L, 1);
    // int direction = (int)lua_tointeger(L, 2);
    // int projectile_shape = (int)lua_tointeger(L, 3);
    // int attack_points = (int)lua_tointeger(L, 4);
    // int weapon_id = (int)lua_tointeger(L, 5);
    // int ammo_id = (int)lua_tointeger(L, 6);

    // Projectile system not implemented
    // Would spawn moving projectile with damage
    return 0;
}

// 0x007A | call_guards
static int LuaCallGuards(lua_State *L)
{
    // int caller_id = (int)lua_tointeger(L, 1);

    // Guard summoning not implemented
    // Would spawn/teleport guards to location
    return 0;
}

// 0x008E | in_combat
static int LuaInCombat(lua_State *L)
{
    // Check if any NPC is currently engaged in combat
    // This is a simple heuristic - a more complete implementation would check
    // for active combat state, but for now check if any NPC is attacking
    bool in_combat = false;

    for (const auto& pair : g_NPCData)
    {
        NPCData* npc = pair.second.get();
        // Check if NPC has an oppressor (is being attacked)
        if (npc->oppressor != 0)
        {
            in_combat = true;
            break;
        }
    }

    lua_pushboolean(L, in_combat);
    return 1;
}

// 0x0061 | apply_damage
static int LuaApplyDamage(lua_State *L)
{
    int base_damage = (int)lua_tointeger(L, 1);
    int hit_points = (int)lua_tointeger(L, 2);
    int damage_type = (int)lua_tointeger(L, 3);
    int target_id = (int)lua_tointeger(L, 4);

    // Simplified damage application
    if (g_objectList.find(target_id) != g_objectList.end())
    {
        U7Object* target = g_objectList[target_id].get();
        // Reduce HP (simplified - full implementation would use combat system)
        target->m_hp -= hit_points;

        // Check if target died
        if (target->m_hp <= 0 && target->m_isNPC && target->m_NPCData)
        {
            target->m_NPCData->status |= 0x0008;  // Set dead bit
            lua_pushboolean(L, 1);  // Target died
            return 1;
        }
    }

    lua_pushboolean(L, 0);  // Target survived
    return 1;
}

// 0x0071 | reduce_health
static int LuaReduceHealth(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);
    int hit_points = (int)lua_tointeger(L, 2);
    // int damage_type = (int)lua_tointeger(L, 3);

    // Direct HP reduction
    if (g_objectList.find(object_id) != g_objectList.end())
    {
        U7Object* target = g_objectList[object_id].get();
        target->m_hp -= hit_points;

        // Check if target died
        if (target->m_hp <= 0 && target->m_isNPC && target->m_NPCData)
        {
            target->m_NPCData->status |= 0x0008;  // Set dead bit
        }
    }

    return 0;
}

// 0x0088 | get_item_flag
static int LuaGetItemFlag(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);
    int flag_id = (int)lua_tointeger(L, 2);

    if (g_objectList.find(object_id) == g_objectList.end())
    {
        lua_pushinteger(L, 0);
        return 1;
    }

    U7Object* obj = g_objectList[object_id].get();

    // Check if the bit is set (1 << flag_id creates a mask for that bit)
    int flag_value = (obj->m_flags & (1 << flag_id)) ? 1 : 0;

    lua_pushinteger(L, flag_value);
    return 1;
}

// 0x0089 | set_item_flag
static int LuaSetItemFlag(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);
    int flag_id = (int)lua_tointeger(L, 2);

    if (g_objectList.find(object_id) == g_objectList.end())
    {
        return 0;
    }

    U7Object* obj = g_objectList[object_id].get();

    // Set the bit to 1 using bitwise OR
    obj->m_flags |= (1 << flag_id);

    return 0;
}

// 0x008A | clear_item_flag
static int LuaClearItemFlag(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);
    int flag_id = (int)lua_tointeger(L, 2);

    if (g_objectList.find(object_id) == g_objectList.end())
    {
        return 0;
    }

    U7Object* obj = g_objectList[object_id].get();

    // Clear the bit to 0 using bitwise AND with inverted mask
    obj->m_flags &= ~(1 << flag_id);

    return 0;
}

// 0x0042 | get_lift
static int LuaGetLift(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);

    if (g_objectList.find(object_id) == g_objectList.end())
    {
        lua_pushinteger(L, 0);
        return 1;
    }

    U7Object* obj = g_objectList[object_id].get();
    // Lift is the Y coordinate (vertical position/elevation)
    int lift = (int)obj->m_Pos.y;

    lua_pushinteger(L, lift);
    return 1;
}

// 0x0043 | set_lift
static int LuaSetLift(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);
    int lift = (int)lua_tointeger(L, 2);

    if (g_objectList.find(object_id) == g_objectList.end())
    {
        return 0;
    }

    U7Object* obj = g_objectList[object_id].get();
    Vector3 pos = obj->GetPos();
    pos.y = (float)lift;
    obj->SetPos(pos);

    return 0;
}

// ============================================================================
// EXULT INTRINSICS - MEDIUM PRIORITY
// ============================================================================

// 0x0031 | is_npc
static int LuaIsNPC(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);

    if (g_objectList.find(object_id) == g_objectList.end())
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    U7Object* obj = g_objectList[object_id].get();
    bool is_npc = obj->m_isNPC || (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC);

    lua_pushboolean(L, is_npc);
    return 1;
}

// 0x0037 | is_dead
static int LuaIsDead(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);

    // Check if object exists and is an NPC
    if (g_objectList.find(object_id) == g_objectList.end())
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    U7Object* obj = g_objectList[object_id].get();
    if (!obj->m_isNPC || !obj->m_NPCData)
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    // In Exult, status bit 3 (value 0x0008) indicates dead
    bool is_dead = (obj->m_NPCData->status & 0x0008) != 0;

    lua_pushboolean(L, is_dead);
    return 1;
}

// 0x003A | get_npc_number
static int LuaGetNPCNumber(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);

    if (g_objectList.find(object_id) == g_objectList.end())
    {
        lua_pushinteger(L, -1);
        return 1;
    }

    U7Object* obj = g_objectList[object_id].get();
    if (obj->m_isNPC)
    {
        lua_pushinteger(L, obj->m_NPCID);
    }
    else
    {
        lua_pushinteger(L, -1); // Not an NPC
    }
    return 1;
}

// 0x003C | get_alignment
static int LuaGetAlignment(lua_State *L)
{
    int npc_id = (int)lua_tointeger(L, 1);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        lua_pushinteger(L, 0);
        return 1;
    }

    NPCData* npc = g_NPCData[npc_id].get();
    // In Exult, alignment is stored in bits 2-3 of status
    // 0=good/friendly, 1=neutral, 2=chaotic/hostile, 3=evil
    int alignment = (npc->status >> 2) & 0x03;

    lua_pushinteger(L, alignment);
    return 1;
}

// 0x003D | set_alignment
static int LuaSetAlignment(lua_State *L)
{
    int npc_id = (int)lua_tointeger(L, 1);
    int alignment = (int)lua_tointeger(L, 2);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        return 0;
    }

    NPCData* npc = g_NPCData[npc_id].get();
    // Clear bits 2-3 and set new alignment
    npc->status = (npc->status & ~0x000C) | ((alignment & 0x03) << 2);

    return 0;
}

// 0x0049 | kill_npc
static int LuaKillNPC(lua_State *L)
{
    int npc_id = (int)lua_tointeger(L, 1);

    // Set NPC's dead status bit
    if (g_NPCData.find(npc_id) != g_NPCData.end())
    {
        // Set bit 3 (0x0008) to mark as dead
        g_NPCData[npc_id]->status |= 0x0008;
    }

    return 0;
}

// 0x0051 | resurrect
static int LuaResurrect(lua_State *L)
{
    int npc_id = (int)lua_tointeger(L, 1);

    // Clear NPC's dead status bit and restore health
    if (g_NPCData.find(npc_id) != g_NPCData.end())
    {
        NPCData* npc = g_NPCData[npc_id].get();

        // Clear bit 3 (0x0008) to mark as alive
        npc->status &= ~0x0008;

        // Restore health to full (strength is max HP)
        // In full implementation, would also restore HP in U7Object
    }

    return 0;
}

// 0x0047 | summon
static int LuaSummon(lua_State *L)
{
    int shape = (int)lua_tointeger(L, 1);
    // bool unknown = (lua_gettop(L) >= 2) ? lua_toboolean(L, 2) : false;

    // In full implementation, would create a new creature object
    // For now, return nil to indicate summoning not fully implemented
    lua_pushnil(L);
    return 1;
}

// 0x0046 | sit_down
static int LuaSitDown(lua_State *L)
{
    int npc_id = (int)lua_tointeger(L, 1);
    int chair_id = (int)lua_tointeger(L, 2);

    // In full implementation, would:
    // 1. Move NPC to chair position
    // 2. Change NPC animation to sitting
    // 3. Set NPC state to sitting

    if (g_objectList.find(npc_id) != g_objectList.end() &&
        g_objectList.find(chair_id) != g_objectList.end())
    {
        U7Object* npc = g_objectList[npc_id].get();
        U7Object* chair = g_objectList[chair_id].get();

        // Move NPC to chair position
        npc->SetPos(chair->GetPos());
    }

    return 0;
}

// 0x001D | set_schedule_type
static int LuaSetScheduleType(lua_State *L)
{
    int npc_id = (int)lua_tointeger(L, 1);
    int schedule_type = (int)lua_tointeger(L, 2);

    // Set NPC's current activity
    if (g_NPCData.find(npc_id) != g_NPCData.end())
    {
        g_NPCData[npc_id]->m_currentActivity = schedule_type;
    }

    return 0;
}

// 0x0022 | get_avatar_ref
static int LuaGetAvatarRef(lua_State *L)
{
    // Return the player's object ID (Avatar is always NPC 0)
    if (g_NPCData.find(0) != g_NPCData.end())
    {
        lua_pushinteger(L, g_NPCData[0]->m_objectID);
    }
    else
    {
        lua_pushinteger(L, -1); // -1 if no player
    }
    return 1;
}

// 0x008D | get_party_list2
static int LuaGetPartyList2(lua_State *L)
{
    lua_newtable(L);

    if (!g_Player)
    {
        return 1;  // Return empty table
    }

    std::vector<int>& party_ids = g_Player->GetPartyMemberIds();
    int table_index = 1;

    for (int party_member_id : party_ids)
    {
        lua_pushinteger(L, table_index);
        lua_pushinteger(L, party_member_id);
        lua_settable(L, -3);
        table_index++;
    }

    return 1;
}

// 0x0093 | get_dead_party
static int LuaGetDeadParty(lua_State *L)
{
    lua_newtable(L);

    if (!g_Player)
    {
        return 1;  // Return empty table
    }

    std::vector<int>& party_ids = g_Player->GetPartyMemberIds();
    int table_index = 1;

    // Check each party member for dead status
    for (int party_member_id : party_ids)
    {
        if (g_objectList.find(party_member_id) == g_objectList.end())
            continue;

        U7Object* party_member = g_objectList[party_member_id].get();
        if (!party_member->m_isNPC || !party_member->m_NPCData)
            continue;

        // Check if dead (status bit 3)
        if (party_member->m_NPCData->status & 0x0008)
        {
            lua_pushinteger(L, table_index);
            lua_pushinteger(L, party_member_id);
            lua_settable(L, -3);
            table_index++;
        }
    }

    return 1;
}

// 0x0001 | execute_usecode_array
static int LuaExecuteUsecodeArray(lua_State *L)
{
    // int object_id = (int)lua_tointeger(L, 1);
    // table script_array = lua_totable(L, 2);
    // MASSIVE TODO
    // Scripted sequences not fully implemented
    // Would execute array of animation/movement commands
    // Return event ID (0 = no event)
    lua_pushinteger(L, 0);
    return 1;
}

// 0x0002 | delayed_execute_usecode_array
static int LuaDelayedExecuteUsecodeArray(lua_State *L)
{
    // int object_id = (int)lua_tointeger(L, 1);
    // table script_array = lua_totable(L, 2);
    // int delay = (int)lua_tointeger(L, 3);

    // MASSIVE TODO
    // Scripted sequences not fully implemented
    // Would execute array after delay
    // Return event ID (0 = no event)
    lua_pushinteger(L, 0);
    return 1;
}

// 0x0079 | in_usecode
static int LuaInUsecode(lua_State *L)
{
    // int object_id = (int)lua_tointeger(L, 1);

    // For most cases, objects are not currently executing usecode
    // This would require tracking execution state per-object
    // Return false for now (simplified implementation)
    lua_pushboolean(L, 0);
    return 1;
}

// 0x007D | path_run_usecode
static int LuaPathRunUsecode(lua_State *L)
{
    // Position table, callback function, object_id, event, simode
    // Pathfinding + callback not fully implemented
    // Would walk NPC to position then execute callback
    lua_pushboolean(L, 0);  // Failed (not implemented)
    return 1;
}

// 0x005C | halt_scheduled
static int LuaHaltScheduled(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);

    // Stop NPC's scheduled activity
    if (g_NPCData.find(object_id) != g_NPCData.end())
    {
        g_NPCData[object_id]->m_currentActivity = -1;  // Clear activity
    }

    return 0;
}

// 0x008B | set_path_failure
static int LuaSetPathFailure(lua_State *L)
{
    // callback function, object_id, event
    // Pathfinding callback not fully implemented
    // Would set function to call when pathfinding fails
    return 0;
}

// 0x0044 | get_weather
static int LuaGetWeather(lua_State *L)
{
    // Simple weather system using static variable
    // 0 = clear, 1 = rain, 2 = snow, etc.
    static int g_currentWeather = 0;

    lua_pushinteger(L, g_currentWeather);
    return 1;
}

// 0x0045 | set_weather
static int LuaSetWeather(lua_State *L)
{
    int weather_type = (int)lua_tointeger(L, 1);

    // Simple weather system using static variable
    static int g_currentWeather = 0;
    g_currentWeather = weather_type;

    return 0;
}

// 0x0090 | is_water
static int LuaIsWater(lua_State *L)
{
    int x = (int)lua_tointeger(L, 1);
    int y = (int)lua_tointeger(L, 2);

    // Check if coordinates are valid
    if (x < 0 || x >= 3072 || y < 0 || y >= 3072)
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    // In Ultima 7, tiles 0-79 are typically water
    // Check the terrain tile at this position
    if (g_World.size() > (size_t)y && g_World[y].size() > (size_t)x)
    {
        unsigned short tile = g_World[y][x];
        bool is_water = (tile >= 0 && tile <= 79);
        lua_pushboolean(L, is_water);
    }
    else
    {
        lua_pushboolean(L, 0);
    }

    return 1;
}

// 0x000F | play_sound_effect
static int LuaPlaySoundEffect(lua_State *L)
{
    // int sound_id = (int)lua_tointeger(L, 1);

    // Audio not yet implemented in U7Revisited
    // In full implementation, would play audio file by ID
    return 0;
}

// 0x0069 | get_speech_track
static int LuaGetSpeechTrack(lua_State *L)
{
    // Audio not yet implemented
    // Would return ID of currently playing speech
    lua_pushinteger(L, 0);
    return 1;
}

// 0x0053 | sprite_effect
static int LuaSpriteEffect(lua_State *L)
{
    // int effect_num = (int)lua_tointeger(L, 1);
    // int x = (int)lua_tointeger(L, 2);
    // int y = (int)lua_tointeger(L, 3);
    // int dx = (int)lua_tointeger(L, 4);
    // int dy = (int)lua_tointeger(L, 5);

    // Visual effects not yet implemented
    // Would spawn particle effect at world position
    return 0;
}

// 0x007B | obj_sprite_effect
static int LuaObjSpriteEffect(lua_State *L)
{
    // int object_id = (int)lua_tointeger(L, 1);
    // int effect_num = (int)lua_tointeger(L, 2);
    // int dx = (int)lua_tointeger(L, 3);
    // int dy = (int)lua_tointeger(L, 4);
    // int delay = (int)lua_tointeger(L, 5);

    // Visual effects not yet implemented
    // Would spawn particle effect on object
    return 0;
}

// 0x008C | fade_palette
static int LuaFadePalette(lua_State *L)
{
    // int cycles = (int)lua_tointeger(L, 1);
    // int in_or_out = (int)lua_tointeger(L, 2);
    // int unknown = (int)lua_tointeger(L, 3);

    // Screen fading not yet implemented
    // Would fade screen to/from black
    return 0;
}

// 0x0092 | set_camera
static int LuaSetCameraTarget(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);

    // In full implementation, would center camera on object
    // For now, just validate object exists
    if (g_objectList.find(object_id) != g_objectList.end())
    {
        // Could set g_CameraTarget or similar
    }

    return 0;
}

// 0x0091 | reset_conv_face
static int LuaResetConvFace(lua_State *L)
{
    // Conversation UI not yet implemented
    // Would reset portrait display to default
    return 0;
}

// 0x0085 | is_not_blocked
static int LuaIsNotBlocked(lua_State *L)
{
    // Position table (x, y, z), shape, frame
    // In full implementation, would check pathfinding grid
    // For now, assume locations are passable
    lua_pushboolean(L, 1); // true = not blocked
    return 1;
}

// 0x0072 | is_readied
static int LuaIsReadied(lua_State *L)
{
    // int object_id = (int)lua_tointeger(L, 1);
    // int equipment_slot = (int)lua_tointeger(L, 2);
    // int npc_id = (int)lua_tointeger(L, 3);

    // Equipment system not yet fully implemented
    // Would check if item is in NPC's equipment slot
    lua_pushboolean(L, 0);
    return 1;
}

// 0x0010 | die_roll
static int LuaDieRoll(lua_State *L)
{
    int num_dice = (int)lua_tointeger(L, 1);
    int num_sides = (int)lua_tointeger(L, 2);

    // Roll num_dice dice with num_sides each, return sum
    int total = 0;
    for (int i = 0; i < num_dice; i++)
    {
        total += g_NonVitalRNG->RandomRange(1, num_sides);
    }

    lua_pushinteger(L, total);
    return 1;
}

// 0x004A | roll_to_win
static int LuaRollToWin(lua_State *L)
{
    int odds = (int)lua_tointeger(L, 1);

    // Roll 1-100, success if <= odds
    int roll = g_NonVitalRNG->RandomRange(1, 100);
    bool success = (roll <= odds);

    lua_pushboolean(L, success);
    return 1;
}

// ============================================================================
// EXULT INTRINSICS - LOW PRIORITY
// ============================================================================

// 0x007E | close_gumps
static int LuaCloseGumps(lua_State *L)
{
    // Gump UI system not yet implemented
    // Would close all open UI windows
    return 0;
}

// 0x0080 | close_gump
static int LuaCloseGump(lua_State *L)
{
    // Gump UI system not yet implemented
    // Would close current/top UI window
    return 0;
}

// 0x0081 | in_gump_mode
static int LuaInGumpMode(lua_State *L)
{
    // Gump UI system not yet implemented
    // Would check if any UI window is open
    lua_pushboolean(L, 0);
    return 1;
}

// 0x0055 | book_mode
static int LuaBookMode(lua_State *L)
{
    // Book reading UI not yet implemented
    // Would enter book reading mode
    return 0;
}

// 0x0033 | click_on_item
static int LuaClickOnItem(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);

    // Would simulate user clicking on object
    // Could trigger object's usecode/script
    if (g_objectList.find(object_id) != g_objectList.end())
    {
        // In full implementation, would trigger object interaction
    }

    return 0;
}

// 0x000C | input_numeric_value
static int LuaInputNumericValue(lua_State *L)
{
    // int min = (int)lua_tointeger(L, 1);
    // int max = (int)lua_tointeger(L, 2);
    // int step = (int)lua_tointeger(L, 3);
    int default_value = (int)lua_tointeger(L, 4);

    // Input dialog not yet implemented
    // Would show slider or numeric input
    // For now, return default value
    lua_pushinteger(L, default_value);
    return 1;
}

// 0x0009 | clear_answers
static int LuaClearAnswersExult(lua_State *L)
{
    // Conversation system exists separately
    // This would clear answer options in conversation UI
    // Note: Different from existing LuaClearAnswers which is our custom implementation
    return 0;
}

// 0x0059 | earthquake
static int LuaEarthquake(lua_State *L)
{
    // int duration = (int)lua_tointeger(L, 1);

    // Screen shake effect not yet implemented
    // Would shake camera for duration
    return 0;
}

// 0x005B | armageddon
static int LuaArmageddon(lua_State *L)
{
    // End of world event not implemented
    // Would kill all NPCs and trigger finale
    return 0;
}

// 0x0050 | wizard_eye
static int LuaWizardEye(lua_State *L)
{
    // bool enable = lua_toboolean(L, 1);

    // Free camera mode not yet implemented
    // Would detach camera from player for exploration
    return 0;
}

// 0x0095 | telekenesis
static int LuaTelekenesis(lua_State *L)
{
    // callback function

    // Remote object manipulation not yet implemented
    // Would allow moving objects from distance
    return 0;
}

// 0x0057 | cause_light
static int LuaCauseLight(lua_State *L)
{
    // int light_level = (int)lua_tointeger(L, 1);

    // Lighting effects not yet implemented
    // Would create temporary light source
    return 0;
}

// 0x0048 | display_map
static int LuaDisplayMap(lua_State *L)
{
    // Map UI not yet implemented
    // Would show world map overlay
    return 0;
}

// 0x004F | display_area
static int LuaDisplayArea(lua_State *L)
{
    // int object_id = (int)lua_tointeger(L, 1);

    // Debug UI not implemented - would show region around object
    return 0;
}

// 0x0094 | view_tile
static int LuaViewTile(lua_State *L)
{
    // Debug UI not implemented - would show tile data
    return 0;
}

// 0x006A | flash_mouse
static int LuaFlashMouse(lua_State *L)
{
    // int flash_type = (int)lua_tointeger(L, 1);

    // Mouse cursor effects not implemented
    return 0;
}

// 0x0056 | stop_time
static int LuaStopTime(lua_State *L)
{
    // int duration = (int)lua_tointeger(L, 1);

    // Time pause not implemented - would freeze game clock
    return 0;
}

// 0x0073 | restart_game
static int LuaRestartGame(lua_State *L)
{
    // Game restart not implemented - would reload from start
    return 0;
}

// 0x0075 | run_endgame
static int LuaRunEndgame(lua_State *L)
{
    // int ending_number = (int)lua_tointeger(L, 1);

    // Endgame sequence not implemented - would play finale
    return 0;
}

// 0x006B | get_item_frame_rot
static int LuaGetItemFrameRot(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);

    // Frame rotation for rotatable objects (chairs, etc.)
    // Return 0 for default orientation
    lua_pushinteger(L, 0);
    return 1;
}

// 0x006C | set_item_frame_rot
static int LuaSetItemFrameRot(lua_State *L)
{
    int object_id = (int)lua_tointeger(L, 1);
    int rotation_frame = (int)lua_tointeger(L, 2);

    // Frame rotation - would set orientation of object
    return 0;
}

// 0x0058 | get_barge
static int LuaGetBarge(lua_State *L)
{
    // int object_id = (int)lua_tointeger(L, 1);

    // Vehicle system not implemented - would return ship/barge ID
    lua_pushnil(L);
    return 1;
}

// 0x0065 | get_timer
static int LuaGetTimer(lua_State *L)
{
    // int object_id = (int)lua_tointeger(L, 1);

    // Object timers not implemented - would return countdown value
    lua_pushinteger(L, 0);
    return 1;
}

// 0x0066 | set_timer
static int LuaSetTimer(lua_State *L)
{
    // int object_id = (int)lua_tointeger(L, 1);
    // int delay = (int)lua_tointeger(L, 2);

    // Object timers not implemented - would set countdown
    return 0;
}

// 0x0062 | is_pc_inside
static int LuaIsPCInside(lua_State *L)
{
    // Indoor/outdoor detection not implemented
    // Would check if player in building/dungeon
    lua_pushboolean(L, 0);
    return 1;
}

// 0x0063 | set_orrery
static int LuaSetOrrery(lua_State *L)
{
    // int value = (int)lua_tointeger(L, 1);

    // Orrery (planetarium) state not implemented
    return 0;
}

// 0x005E | get_array_size
static int LuaGetArraySize(lua_State *L)
{
    // Get size of Lua table
    size_t size = lua_rawlen(L, 1);
    lua_pushinteger(L, size);
    return 1;
}

// 0x005F | mark_virtue_stone
static int LuaMarkVirtueStone(lua_State *L)
{
    // int stone_index = (int)lua_tointeger(L, 1);

    // Virtue stone system not implemented - would save location
    return 0;
}

// 0x0060 | recall_virtue_stone
static int LuaRecallVirtueStone(lua_State *L)
{
    // int stone_index = (int)lua_tointeger(L, 1);

    // Virtue stone system not implemented - would teleport to location
    return 0;
}

// 0x0083 | UNKNOWN (set_time_palette)
static int LuaSetTimePalette(lua_State *L)
{
    // Time-based palette not implemented - would adjust colors for time of day
    return 0;
}

// ============================================================================
// NPC Activity System Helper Functions
// ============================================================================

// distance_to(npc_id, object_id) -> number
static int LuaDistanceTo(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    int object_id = luaL_checkinteger(L, 2);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        return luaL_error(L, "Invalid NPC ID: %d", npc_id);
    }

    U7Object* npc = g_objectList[g_NPCData[npc_id]->m_objectID].get();
    U7Object* target = GetObjectFromID(object_id);

    if (!npc || !target)
    {
        lua_pushnumber(L, 999999.0);  // Return huge distance if invalid
        return 1;
    }

    Vector3 npcPos = npc->GetPos();
    Vector3 targetPos = target->GetPos();
    float distance = Vector3Distance(npcPos, targetPos);

    lua_pushnumber(L, distance);
    return 1;
}

// is_near_object(npc_id, object_id, distance) -> boolean
static int LuaIsNearObject(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    int object_id = luaL_checkinteger(L, 2);
    float max_distance = (float)luaL_checknumber(L, 3);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    U7Object* npc = g_objectList[g_NPCData[npc_id]->m_objectID].get();
    U7Object* target = GetObjectFromID(object_id);

    if (!npc || !target)
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    Vector3 npcPos = npc->GetPos();
    Vector3 targetPos = target->GetPos();
    float distance = Vector3Distance(npcPos, targetPos);

    lua_pushboolean(L, distance <= max_distance);
    return 1;
}

// get_npc_position(npc_id) -> x, y, z
static int LuaGetNPCPosition(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        return luaL_error(L, "Invalid NPC ID: %d", npc_id);
    }

    U7Object* npc = g_objectList[g_NPCData[npc_id]->m_objectID].get();
    if (!npc)
    {
        lua_pushnumber(L, 0);
        lua_pushnumber(L, 0);
        lua_pushnumber(L, 0);
        return 3;
    }

    Vector3 pos = npc->GetPos();
    lua_pushnumber(L, pos.x);
    lua_pushnumber(L, pos.y);
    lua_pushnumber(L, pos.z);
    return 3;
}

// find_nearest_object_of_shape(npc_id, shape_id) -> object_id or nil
static int LuaFindNearestObjectOfShape(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    int shape_id = luaL_checkinteger(L, 2);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        lua_pushnil(L);
        return 1;
    }

    U7Object* npc = g_objectList[g_NPCData[npc_id]->m_objectID].get();
    if (!npc)
    {
        lua_pushnil(L);
        return 1;
    }

    Vector3 npcPos = npc->GetPos();
    float minDistance = 999999.0f;
    int nearestObjectId = -1;

    for (auto& objPair : g_objectList)
    {
        U7Object* obj = objPair.second.get();
        if (obj && obj->m_ObjectType == shape_id)
        {
            Vector3 objPos = obj->GetPos();
            float distance = Vector3Distance(npcPos, objPos);
            if (distance < minDistance)
            {
                minDistance = distance;
                nearestObjectId = obj->m_ID;
            }
        }
    }

    if (nearestObjectId >= 0)
    {
        lua_pushinteger(L, nearestObjectId);
    }
    else
    {
        lua_pushnil(L);
    }
    return 1;
}

// find_nearest_bed(npc_id) -> object_id or nil
// Beds are shapes 696, 1011 in Ultima 7
static int LuaFindNearestBed(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        lua_pushnil(L);
        return 1;
    }

    U7Object* npc = g_objectList[g_NPCData[npc_id]->m_objectID].get();
    if (!npc)
    {
        lua_pushnil(L);
        return 1;
    }

    Vector3 npcPos = npc->GetPos();
    float minDistance = 999999.0f;
    int nearestObjectId = -1;

    // Check for multiple bed shapes
    const int bedShapes[] = {696, 1011};

    for (auto& objPair : g_objectList)
    {
        U7Object* obj = objPair.second.get();
        if (obj)
        {
            // Check if this object is any of the bed shapes
            bool isBed = false;
            for (int bedShape : bedShapes)
            {
                if (obj->m_ObjectType == bedShape)
                {
                    isBed = true;
                    break;
                }
            }

            if (isBed)
            {
                Vector3 objPos = obj->GetPos();
                float distance = Vector3Distance(npcPos, objPos);
                if (distance < minDistance)
                {
                    minDistance = distance;
                    nearestObjectId = obj->m_ID;
                }
            }
        }
    }

    if (nearestObjectId >= 0)
    {
        lua_pushinteger(L, nearestObjectId);
    }
    else
    {
        lua_pushnil(L);
    }
    return 1;
}

// find_nearest_chair(npc_id) -> object_id or nil
// Chairs are shape 873 in Ultima 7
static int LuaFindNearestChair(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        lua_pushnil(L);
        return 1;
    }

    U7Object* npc = g_objectList[g_NPCData[npc_id]->m_objectID].get();
    if (!npc)
    {
        lua_pushnil(L);
        return 1;
    }

    Vector3 npcPos = npc->GetPos();
    float minDistance = 999999.0f;
    int nearestObjectId = -1;

    // Check for multiple chair shapes (add more as needed)
    const int chairShapes[] = {873, 897};

    for (auto& objPair : g_objectList)
    {
        U7Object* obj = objPair.second.get();
        if (obj)
        {
            // Check if this object is any of the chair shapes
            bool isChair = false;
            for (int chairShape : chairShapes)
            {
                if (obj->m_ObjectType == chairShape)
                {
                    isChair = true;
                    break;
                }
            }

            if (isChair)
            {
                Vector3 objPos = obj->GetPos();
                float distance = Vector3Distance(npcPos, objPos);
                if (distance < minDistance)
                {
                    minDistance = distance;
                    nearestObjectId = obj->m_ID;
                }
            }
        }
    }

    if (nearestObjectId >= 0)
    {
        lua_pushinteger(L, nearestObjectId);
    }
    else
    {
        lua_pushnil(L);
    }
    return 1;
}

// find_nearest_shape(npc_id, shape_table) -> object_id or nil
// Generic function to find nearest object matching any shape ID in the table
// shape_table is a Lua table of shape IDs: {696, 1011, ...}
static int LuaFindNearestShape(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);

    // Second argument must be a table
    if (!lua_istable(L, 2))
    {
        luaL_error(L, "find_nearest_shape: second argument must be a table of shape IDs");
        return 0;
    }

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        lua_pushnil(L);
        return 1;
    }

    U7Object* npc = g_objectList[g_NPCData[npc_id]->m_objectID].get();
    if (!npc)
    {
        lua_pushnil(L);
        return 1;
    }

    // Read shape IDs from Lua table into a vector
    std::vector<int> shapeIds;
    lua_pushnil(L);  // First key
    while (lua_next(L, 2) != 0)
    {
        // Key is at -2, value is at -1
        if (lua_isnumber(L, -1))
        {
            shapeIds.push_back(lua_tointeger(L, -1));
        }
        lua_pop(L, 1);  // Remove value, keep key for next iteration
    }

    if (shapeIds.empty())
    {
        lua_pushnil(L);
        return 1;
    }

    Vector3 npcPos = npc->GetPos();
    float minDistance = 999999.0f;
    int nearestObjectId = -1;

    // Search through all objects
    for (auto& objPair : g_objectList)
    {
        U7Object* obj = objPair.second.get();
        if (obj)
        {
            // Check if this object matches any of the shape IDs
            bool matchesShape = false;
            for (int shapeId : shapeIds)
            {
                if (obj->m_ObjectType == shapeId)
                {
                    matchesShape = true;
                    break;
                }
            }

            if (matchesShape)
            {
                Vector3 objPos = obj->GetPos();
                float distance = Vector3Distance(npcPos, objPos);
                if (distance < minDistance)
                {
                    minDistance = distance;
                    nearestObjectId = obj->m_ID;
                }
            }
        }
    }

    if (nearestObjectId >= 0)
    {
        lua_pushinteger(L, nearestObjectId);
    }
    else
    {
        lua_pushnil(L);
    }
    return 1;
}

// find_random_walkable(npc_id, radius) -> x, y, z or nil
// Finds a random walkable position within radius tiles of the NPC
// Ensures the position is walkable AND pathfinding can reach it
static int LuaFindRandomWalkable(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    float radius = (float)luaL_checknumber(L, 2);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        lua_pushnil(L);
        return 1;
    }

    U7Object* npc = g_objectList[g_NPCData[npc_id]->m_objectID].get();
    if (!npc)
    {
        lua_pushnil(L);
        return 1;
    }

    extern PathfindingGrid* g_pathfindingGrid;
    extern AStar* g_aStar;

    if (!g_pathfindingGrid || !g_aStar)
    {
        lua_pushnil(L);
        return 1;
    }

    Vector3 npcPos = npc->GetPos();
    int anchorX = (int)npcPos.x;
    int anchorZ = (int)npcPos.z;

    // Pick ONE random offset within radius (caller should retry with yields if needed)
    float offsetX = ((float)rand() / RAND_MAX * 2.0f - 1.0f) * radius;
    float offsetZ = ((float)rand() / RAND_MAX * 2.0f - 1.0f) * radius;

    int targetX = anchorX + (int)offsetX;
    int targetZ = anchorZ + (int)offsetZ;

    // Only check if position is walkable - NO pathfinding (too expensive)
    if (!g_pathfindingGrid->IsPositionWalkable(targetX, targetZ))
    {
        lua_pushnil(L);
        return 1;
    }

    // Position is walkable, return it
    lua_pushnumber(L, (float)targetX);
    lua_pushnumber(L, npcPos.y);
    lua_pushnumber(L, (float)targetZ);
    return 3;
}

// get_current_animation(npc_id) -> frameX, frameY
static int LuaGetCurrentAnimation(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        lua_pushinteger(L, 0);
        lua_pushinteger(L, 0);
        return 2;
    }

    U7Object* npc = g_objectList[g_NPCData[npc_id]->m_objectID].get();
    if (!npc)
    {
        lua_pushinteger(L, 0);
        lua_pushinteger(L, 0);
        return 2;
    }

    lua_pushinteger(L, npc->m_currentFrameX);
    lua_pushinteger(L, npc->m_currentFrameY);
    return 2;
}

// play_animation(npc_id, frameX, frameY)
static int LuaPlayAnimation(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    int frameX = luaL_checkinteger(L, 2);
    int frameY = luaL_checkinteger(L, 3);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        return 0;
    }

    U7Object* npc = g_objectList[g_NPCData[npc_id]->m_objectID].get();
    if (npc)
    {
        npc->SetFrames(frameX, frameY);
    }

    return 0;
}

// is_sleeping(npc_id) -> boolean
// NPCs are sleeping if they're in a lying down animation (frameY == 16 for lying down)
static int LuaIsSleeping(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    U7Object* npc = g_objectList[g_NPCData[npc_id]->m_objectID].get();
    if (!npc)
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    // Frame 16 is the lying down animation in U7
    lua_pushboolean(L, npc->m_currentFrameY == 16);
    return 1;
}

// is_sitting(npc_id) -> boolean
// NPCs are sitting if they're in a sitting animation (frameY == 8 for sitting)
static int LuaIsSitting(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    U7Object* npc = g_objectList[g_NPCData[npc_id]->m_objectID].get();
    if (!npc)
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    // Frame 26 is the sitting animation in U7
    lua_pushboolean(L, npc->m_currentFrameY == 26);
    return 1;
}

// walk_to_object(npc_id, object_id)
static int LuaWalkToObject(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    int object_id = luaL_checkinteger(L, 2);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        return 0;
    }

    U7Object* target = GetObjectFromID(object_id);
    if (!target)
    {
        return 0;
    }

    Vector3 targetPos = target->GetPos();
    g_objectList[g_NPCData[npc_id]->m_objectID]->PathfindToDest(targetPos);

    return 0;
}

// walk_to_position(npc_id, x, y, z)
static int LuaWalkToPosition(lua_State *L)
{
    int npc_id = luaL_checkinteger(L, 1);
    float x = (float)luaL_checknumber(L, 2);
    float y = (float)luaL_checknumber(L, 3);
    float z = (float)luaL_checknumber(L, 4);

    if (g_NPCData.find(npc_id) == g_NPCData.end())
    {
        return 0;
    }

    g_objectList[g_NPCData[npc_id]->m_objectID]->PathfindToDest({x, y, z});

    return 0;
}

// get_current_hour() -> hour (0-23)
static int LuaGetCurrentHour(lua_State *L)
{
    lua_pushinteger(L, g_hour);
    return 1;
}

// get_current_minute() -> minute (0-59)
static int LuaGetCurrentMinute(lua_State *L)
{
    lua_pushinteger(L, g_minute);
    return 1;
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
    g_ScriptingSystem->RegisterScriptFunction("cmps", LuaCmps);
    g_ScriptingSystem->RegisterScriptFunction("clear_answers", LuaClearAnswers);
    g_ScriptingSystem->RegisterScriptFunction("get_purchase_option", LuaGetPurchaseOption);
    g_ScriptingSystem->RegisterScriptFunction("purchase_object", LuaPurchaseObject);
    g_ScriptingSystem->RegisterScriptFunction("is_conversation_running", LuaIsConversationRunning);

    // These are general utility functions.
    g_ScriptingSystem->RegisterScriptFunction("ask_yes_no", LuaAskYesNo);
    g_ScriptingSystem->RegisterScriptFunction("select_option", LuaAskYesNo); // Alias for ask_yes_no() with no parameter
    g_ScriptingSystem->RegisterScriptFunction("ask_answer", LuaAskAnswer);
    g_ScriptingSystem->RegisterScriptFunction("ask_multiple_choice", LuaAskMultipleChoice);
    g_ScriptingSystem->RegisterScriptFunction("ask_number", LuaAskNumber);
    g_ScriptingSystem->RegisterScriptFunction("object_select_modal", LuaObjectSelectModal);
    g_ScriptingSystem->RegisterScriptFunction("random", LuaRandom);
    g_ScriptingSystem->RegisterScriptFunction("random2", LuaRandom); // Alias for random()
    g_ScriptingSystem->RegisterScriptFunction("find_nearby", LuaFindNearby);
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
    g_ScriptingSystem->RegisterScriptFunction("get_npc_name", LuaGetNPCNameFromId);
    g_ScriptingSystem->RegisterScriptFunction("get_npc_id_from_name", LuaGetNPCIdFromName);
    g_ScriptingSystem->RegisterScriptFunction("select_party_member_by_name", LuaSelectPartyMemberByName); //  Used in dialogue, presents a list of party members and allows user to click on one to select it
    g_ScriptingSystem->RegisterScriptFunction("get_party_gold", LuaGetPartyGold);
    g_ScriptingSystem->RegisterScriptFunction("remove_party_gold", LuaRemovePartyGold);
    g_ScriptingSystem->RegisterScriptFunction("get_npc_training_points", LuaGetNPCTrainingPoints);
    g_ScriptingSystem->RegisterScriptFunction("get_training_level", LuaGetNPCTrainingLevel);
    g_ScriptingSystem->RegisterScriptFunction("set_training_level", LuaSetTrainingLevel);
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
    g_ScriptingSystem->RegisterScriptFunction("get_schedule_type", LuaGetScheduleType);

    g_ScriptingSystem->RegisterScriptFunction("debug_print", LuaDebugPrint);
    g_ScriptingSystem->RegisterScriptFunction("console_log", LuaConsoleLog);

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
    g_ScriptingSystem->RegisterScriptFunction( "destroy_object_silent", LuaDestroyObjectSilent);
    g_ScriptingSystem->RegisterScriptFunction( "consume_object", LuaConsumeObject);

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

    // Exult Intrinsics - HIGH PRIORITY
    g_ScriptingSystem->RegisterScriptFunction( "find_nearest", LuaFindNearest);
    g_ScriptingSystem->RegisterScriptFunction( "find_object", LuaFindObject);
    g_ScriptingSystem->RegisterScriptFunction( "get_distance", LuaGetDistanceBetween);
    g_ScriptingSystem->RegisterScriptFunction( "find_direction", LuaFindDirectionBetween);
    g_ScriptingSystem->RegisterScriptFunction( "direction_from", LuaDirectionFrom);
    g_ScriptingSystem->RegisterScriptFunction( "count_objects", LuaCountObjects);
    g_ScriptingSystem->RegisterScriptFunction( "find_nearby_avatar", LuaFindNearbyAvatar);
    g_ScriptingSystem->RegisterScriptFunction( "get_item_quantity", LuaGetItemQuantity);
    g_ScriptingSystem->RegisterScriptFunction( "set_item_quantity", LuaSetItemQuantity);
    g_ScriptingSystem->RegisterScriptFunction( "remove_party_items", LuaRemovePartyItems);
    g_ScriptingSystem->RegisterScriptFunction( "add_party_items", LuaAddPartyItems);
    g_ScriptingSystem->RegisterScriptFunction( "set_last_created", LuaSetLastCreated);
    g_ScriptingSystem->RegisterScriptFunction( "update_last_created", LuaUpdateLastCreated);
    g_ScriptingSystem->RegisterScriptFunction( "give_last_created", LuaGiveLastCreated);
    g_ScriptingSystem->RegisterScriptFunction( "remove_item", LuaRemoveItem);
    g_ScriptingSystem->RegisterScriptFunction( "get_container", LuaGetContainerOf);
    g_ScriptingSystem->RegisterScriptFunction( "set_to_attack", LuaSetToAttack);
    g_ScriptingSystem->RegisterScriptFunction( "set_attack_mode", LuaSetAttackMode);
    g_ScriptingSystem->RegisterScriptFunction( "set_oppressor", LuaSetOppressor);
    g_ScriptingSystem->RegisterScriptFunction( "attack_object", LuaAttackObject);
    g_ScriptingSystem->RegisterScriptFunction( "fire_projectile", LuaFireProjectile);
    g_ScriptingSystem->RegisterScriptFunction( "call_guards", LuaCallGuards);
    g_ScriptingSystem->RegisterScriptFunction( "in_combat", LuaInCombat);
    g_ScriptingSystem->RegisterScriptFunction( "apply_damage", LuaApplyDamage);
    g_ScriptingSystem->RegisterScriptFunction( "reduce_health", LuaReduceHealth);
    g_ScriptingSystem->RegisterScriptFunction( "get_item_flag", LuaGetItemFlag);
    g_ScriptingSystem->RegisterScriptFunction( "set_item_flag", LuaSetItemFlag);
    g_ScriptingSystem->RegisterScriptFunction( "clear_item_flag", LuaClearItemFlag);
    g_ScriptingSystem->RegisterScriptFunction( "get_lift", LuaGetLift);
    g_ScriptingSystem->RegisterScriptFunction( "set_lift", LuaSetLift);

    // Exult Intrinsics - MEDIUM PRIORITY
    g_ScriptingSystem->RegisterScriptFunction( "is_npc", LuaIsNPC);
    g_ScriptingSystem->RegisterScriptFunction( "is_dead", LuaIsDead);
    g_ScriptingSystem->RegisterScriptFunction( "get_npc_number", LuaGetNPCNumber);
    g_ScriptingSystem->RegisterScriptFunction( "get_alignment", LuaGetAlignment);
    g_ScriptingSystem->RegisterScriptFunction( "set_alignment", LuaSetAlignment);
    g_ScriptingSystem->RegisterScriptFunction( "kill_npc", LuaKillNPC);
    g_ScriptingSystem->RegisterScriptFunction( "resurrect", LuaResurrect);
    g_ScriptingSystem->RegisterScriptFunction( "summon", LuaSummon);
    g_ScriptingSystem->RegisterScriptFunction( "sit_down", LuaSitDown);
    g_ScriptingSystem->RegisterScriptFunction( "set_schedule_type", LuaSetScheduleType);
    g_ScriptingSystem->RegisterScriptFunction( "get_avatar_ref", LuaGetAvatarRef);
    g_ScriptingSystem->RegisterScriptFunction( "get_party_list2", LuaGetPartyList2);
    g_ScriptingSystem->RegisterScriptFunction( "get_dead_party", LuaGetDeadParty);
    g_ScriptingSystem->RegisterScriptFunction( "execute_usecode_array", LuaExecuteUsecodeArray);
    g_ScriptingSystem->RegisterScriptFunction( "delayed_execute_usecode_array", LuaDelayedExecuteUsecodeArray);
    g_ScriptingSystem->RegisterScriptFunction( "in_usecode", LuaInUsecode);
    g_ScriptingSystem->RegisterScriptFunction( "path_run_usecode", LuaPathRunUsecode);
    g_ScriptingSystem->RegisterScriptFunction( "halt_scheduled", LuaHaltScheduled);
    g_ScriptingSystem->RegisterScriptFunction( "set_path_failure", LuaSetPathFailure);
    g_ScriptingSystem->RegisterScriptFunction( "get_weather", LuaGetWeather);
    g_ScriptingSystem->RegisterScriptFunction( "set_weather", LuaSetWeather);
    g_ScriptingSystem->RegisterScriptFunction( "is_water", LuaIsWater);
    g_ScriptingSystem->RegisterScriptFunction( "play_sound_effect", LuaPlaySoundEffect);
    g_ScriptingSystem->RegisterScriptFunction( "get_speech_track", LuaGetSpeechTrack);
    g_ScriptingSystem->RegisterScriptFunction( "sprite_effect", LuaSpriteEffect);
    g_ScriptingSystem->RegisterScriptFunction( "obj_sprite_effect", LuaObjSpriteEffect);
    g_ScriptingSystem->RegisterScriptFunction( "fade_palette", LuaFadePalette);
    g_ScriptingSystem->RegisterScriptFunction( "set_camera", LuaSetCameraTarget);
    g_ScriptingSystem->RegisterScriptFunction( "reset_conv_face", LuaResetConvFace);
    g_ScriptingSystem->RegisterScriptFunction( "is_not_blocked", LuaIsNotBlocked);
    g_ScriptingSystem->RegisterScriptFunction( "is_readied", LuaIsReadied);
    g_ScriptingSystem->RegisterScriptFunction( "die_roll", LuaDieRoll);
    g_ScriptingSystem->RegisterScriptFunction( "roll_to_win", LuaRollToWin);

    // Exult Intrinsics - LOW PRIORITY
    g_ScriptingSystem->RegisterScriptFunction( "close_gumps", LuaCloseGumps);
    g_ScriptingSystem->RegisterScriptFunction( "close_gump", LuaCloseGump);
    g_ScriptingSystem->RegisterScriptFunction( "in_gump_mode", LuaInGumpMode);
    g_ScriptingSystem->RegisterScriptFunction( "book_mode", LuaBookMode);
    g_ScriptingSystem->RegisterScriptFunction( "click_on_item", LuaClickOnItem);
    g_ScriptingSystem->RegisterScriptFunction( "input_numeric_value", LuaInputNumericValue);
    // Note: clear_answers registered as LuaClearAnswersExult to avoid conflict with existing LuaClearAnswers
    g_ScriptingSystem->RegisterScriptFunction( "earthquake", LuaEarthquake);
    g_ScriptingSystem->RegisterScriptFunction( "armageddon", LuaArmageddon);
    g_ScriptingSystem->RegisterScriptFunction( "wizard_eye", LuaWizardEye);
    g_ScriptingSystem->RegisterScriptFunction( "telekenesis", LuaTelekenesis);
    g_ScriptingSystem->RegisterScriptFunction( "cause_light", LuaCauseLight);
    g_ScriptingSystem->RegisterScriptFunction( "display_map", LuaDisplayMap);
    g_ScriptingSystem->RegisterScriptFunction( "display_area", LuaDisplayArea);
    g_ScriptingSystem->RegisterScriptFunction( "view_tile", LuaViewTile);
    g_ScriptingSystem->RegisterScriptFunction( "flash_mouse", LuaFlashMouse);
    g_ScriptingSystem->RegisterScriptFunction( "stop_time", LuaStopTime);
    g_ScriptingSystem->RegisterScriptFunction( "restart_game", LuaRestartGame);
    g_ScriptingSystem->RegisterScriptFunction( "run_endgame", LuaRunEndgame);
    g_ScriptingSystem->RegisterScriptFunction( "get_item_frame_rot", LuaGetItemFrameRot);
    g_ScriptingSystem->RegisterScriptFunction( "set_item_frame_rot", LuaSetItemFrameRot);
    g_ScriptingSystem->RegisterScriptFunction( "get_barge", LuaGetBarge);
    g_ScriptingSystem->RegisterScriptFunction( "get_timer", LuaGetTimer);
    g_ScriptingSystem->RegisterScriptFunction( "set_timer", LuaSetTimer);
    g_ScriptingSystem->RegisterScriptFunction( "is_pc_inside", LuaIsPCInside);
    g_ScriptingSystem->RegisterScriptFunction( "set_orrery", LuaSetOrrery);
    g_ScriptingSystem->RegisterScriptFunction( "get_array_size", LuaGetArraySize);
    g_ScriptingSystem->RegisterScriptFunction( "mark_virtue_stone", LuaMarkVirtueStone);
    g_ScriptingSystem->RegisterScriptFunction( "recall_virtue_stone", LuaRecallVirtueStone);
    g_ScriptingSystem->RegisterScriptFunction( "set_time_palette", LuaSetTimePalette);

    // NPC Activity System functions
    g_ScriptingSystem->RegisterScriptFunction( "distance_to", LuaDistanceTo);
    g_ScriptingSystem->RegisterScriptFunction( "is_near_object", LuaIsNearObject);
    g_ScriptingSystem->RegisterScriptFunction( "get_npc_position", LuaGetNPCPosition);
    g_ScriptingSystem->RegisterScriptFunction( "find_nearest_object_of_shape", LuaFindNearestObjectOfShape);
    g_ScriptingSystem->RegisterScriptFunction( "find_nearest_bed", LuaFindNearestBed);
    g_ScriptingSystem->RegisterScriptFunction( "find_nearest_chair", LuaFindNearestChair);
    g_ScriptingSystem->RegisterScriptFunction( "find_nearest_shape", LuaFindNearestShape);
    g_ScriptingSystem->RegisterScriptFunction( "find_random_walkable", LuaFindRandomWalkable);
    g_ScriptingSystem->RegisterScriptFunction( "get_current_animation", LuaGetCurrentAnimation);
    g_ScriptingSystem->RegisterScriptFunction( "play_animation", LuaPlayAnimation);
    g_ScriptingSystem->RegisterScriptFunction( "is_sleeping", LuaIsSleeping);
    g_ScriptingSystem->RegisterScriptFunction( "is_sitting", LuaIsSitting);
    g_ScriptingSystem->RegisterScriptFunction( "walk_to_object", LuaWalkToObject);
    g_ScriptingSystem->RegisterScriptFunction( "walk_to_position", LuaWalkToPosition);
    g_ScriptingSystem->RegisterScriptFunction( "get_current_hour", LuaGetCurrentHour);
    g_ScriptingSystem->RegisterScriptFunction( "get_current_minute", LuaGetCurrentMinute);

    cout << "Registered all Lua functions\n";
}
