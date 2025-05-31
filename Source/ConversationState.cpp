#include "Geist/Globals.h"
#include "Geist/Logging.h"
#include "Geist/Gui.h"
#include "Geist/ParticleSystem.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/GuiManager.h"
#include "Geist/Engine.h"
#include "Geist/ScriptingSystem.h"
#include "U7Globals.h"
#include "ConversationState.h"
#include "rlgl.h"
#include "U7Gump.h"
#include "lua.hpp"

#include <list>
#include <string>
#include <sstream>
#include <iomanip>
#include <math.h>
#include <fstream>
#include <algorithm>
#include <unordered_map>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  ConversationState
////////////////////////////////////////////////////////////////////////////////

ConversationState::~ConversationState()
{
	Shutdown();
}

void ConversationState::Init(const string& configfile)
{
    m_Gui = new Gui();
    m_Gui->Init(configfile);
    m_Gui->SetLayout(0, 0, g_Engine->m_RenderWidth, g_Engine->m_RenderHeight, g_DrawScale, Gui::GUIP_USE_XY);
    m_answers.clear();
    m_steps.clear();
    m_waitingForAnswer = false;
    m_scriptFinished = false;
    m_conversationActive = false;
}

void ConversationState::OnEnter()
{
    m_answerPending = false;
    m_waitingForAnswer = false;
    m_scriptFinished = false;
    m_conversationActive = true;
}

void ConversationState::OnExit()
{
    m_answers.clear();
    m_steps.clear();
    m_answerPending = false;
    m_waitingForAnswer = false;
    m_conversationActive = false;
    m_scriptFinished = false;
    m_currentDialogue.clear();

    // Clean up coroutine
    if (!m_luaFunction.empty())
    {
        auto it = g_ScriptingSystem->m_activeCoroutines.find(m_luaFunction);
        if (it != g_ScriptingSystem->m_activeCoroutines.end())
        {
            int co_ref = it->second;
            lua_rawgeti(g_ScriptingSystem->m_luaState, LUA_REGISTRYINDEX, co_ref);
            lua_State* co = lua_tothread(g_ScriptingSystem->m_luaState, -1);
            lua_pop(g_ScriptingSystem->m_luaState, 1);

            //AddConsoleString("Cleaning up coroutine for " + m_luaFunction);
            luaL_unref(g_ScriptingSystem->m_luaState, LUA_REGISTRYINDEX, co_ref);
            g_ScriptingSystem->m_activeCoroutines.erase(m_luaFunction);
        }
    }

    lua_pushstring(g_ScriptingSystem->m_luaState, "nil");
    lua_setglobal(g_ScriptingSystem->m_luaState, "answer");
}

void ConversationState::Shutdown()
{
	
}

void ConversationState::Update()
{
    // AddConsoleString("Update: waitingForAnswer = " + std::string(m_waitingForAnswer ? "true" : "false") + ", steps = " + std::to_string(m_steps.size()) + ", answers = " + std::to_string(m_answers.size()) + ", scriptFinished = " + std::string(m_scriptFinished ? "true" : "false"));

    if (m_steps.empty())
    {
        //if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) {
            g_StateMachine->PopState();
        //}
        return;
    }

    // Check if the script is still yielded
    auto it = g_ScriptingSystem->m_activeCoroutines.find(m_luaFunction);
    bool scriptYielded = (it != g_ScriptingSystem->m_activeCoroutines.end());
    if (it != g_ScriptingSystem->m_activeCoroutines.end())
    {
        lua_rawgeti(g_ScriptingSystem->m_luaState, LUA_REGISTRYINDEX, it->second);
        lua_State* co = lua_tothread(g_ScriptingSystem->m_luaState, -1);
        lua_pop(g_ScriptingSystem->m_luaState, 1);
        scriptYielded = (lua_status(co) == LUA_YIELD);
    }

    // Handle current step
    switch(m_steps[0].type)
    {
        case ConversationStepType::STEP_ADD_DIALOGUE:
            m_currentDialogue = m_steps[0].str;
            if(m_steps.size() == 1 && m_answers.size() > 0)
            {
                m_waitingForAnswer = true;
            }
            if (!m_waitingForAnswer && IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
            {
                m_steps.erase(m_steps.begin());
            }
            break;
        case ConversationStepType::STEP_CHANGE_PORTRAIT:
            m_npcId = m_steps[0].npcId;
            m_npcFrame = m_steps[0].frame;
            m_steps.erase(m_steps.begin());
            return;
            break;
        case ConversationStepType::STEP_ASK_YES_NO:
            if(!m_waitingForAnswer)
            {
                SaveAnswers();
                ClearAnswers();
                AddAnswer("Yes");
                AddAnswer("No");
                m_yesNoCallback = m_steps[0].yesNoCallback;
                m_waitingForAnswer = true;
            }
            break;
    }

    // Handle answer selection (Yes/No or regular answers)
    if (m_waitingForAnswer)
    {
        if (!m_answerPending) {
            for (int i = 0; i < m_answers.size(); i++) {
                std::string adjustedAnswer = std::string("* ") + m_answers[i];
                Vector2 dims = MeasureTextEx(*g_SmallFont.get(), adjustedAnswer.c_str(), g_SmallFont.get()->baseSize, 1);

                Vector2 mousePosition = GetMousePosition();
                if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON) &&
                    CheckCollisionPointRec(mousePosition, { 115 * g_DrawScale,
                        float((140 + (i * g_SmallFont.get()->baseSize * 1.3)) * g_DrawScale),
                        dims.x * g_DrawScale,
                        float((g_SmallFont.get()->baseSize * 1.3) * g_DrawScale) }))
                {
                    if(m_answers[i] == "Yes" || m_answers[i] == "No")
                    {
                        bool yes = (m_answers[i] == "Yes");
                        SelectYesNo(yes);
                        return;
                    }
                    else
                    {
                        SetAnswer(m_luaFunction, m_answers[i]);
                        m_answers.clear();
                        m_steps.clear();
                        m_answerPending = true;
                        m_waitingForAnswer = false;
                        if (!m_steps.empty()) {
                            m_steps.erase(m_steps.begin());
                        }
                    }
                }
            }
        }
    }
    else
    {
        // If the script has finished, just display remaining dialogue
        if (m_scriptFinished && IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
        {
            //if (!m_steps.empty() && m_steps[0].type == ConversationStepType::STEP_ADD_DIALOGUE) {
//                m_steps.erase(m_steps.begin());
  //          } else {
            if(m_steps.empty())
            {
                g_StateMachine->PopState();
            }
        }
    }

    if (m_answerPending && !scriptYielded && !m_scriptFinished)
    {
        m_answerPending = false;
        AddConsoleString("Calling Lua function: " + m_luaFunction);
        try {
            std::string result = g_ScriptingSystem->CallScript(m_luaFunction, {1, m_npcId});
            AddConsoleString("Lua function completed: " + m_luaFunction + ", result: " + result);
        } catch (const std::exception& e) {
            AddConsoleString("Exception in CallScript: " + std::string(e.what()));
        }
    }

    if (IsKeyReleased(KEY_ESCAPE)) {
        g_StateMachine->PopState();
    }
}

void ConversationState::Draw()
{
	ClearBackground(Color{ 0, 0, 0, 255 });

	BeginDrawing();

	BeginMode3D(g_camera);

	// Draw the terrain
	g_Terrain->Draw();

	for (auto& unit : g_sortedVisibleObjects) {
		unit->Draw();
	}

	EndMode3D();

	float ratio = float(g_Engine->m_ScreenWidth) / float(g_Engine->m_RenderWidth);

	// Draw the GUI
	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({0, 0, 0, 0});
	DrawRectangleRounded({100, 10, 500, 110}, .25, 100, { 0, 0, 0, 224 });

	m_Gui->Draw();

	DrawTextureEx(*g_ResourceManager->GetTexture("U7FACES" + to_string(m_npcId) + to_string(m_npcFrame)), {4, 10}, 0, 2, WHITE);

	//if (!m_steps.empty() && m_steps[0].type == ConversationStepType::STEP_ADD_DIALOGUE) {
	DrawParagraph(g_ConversationFont, m_currentDialogue, { 115, 20 }, 380,
		g_ConversationFont.get()->baseSize, 1, YELLOW);
	//}

	for (int i = 0; i < m_answers.size(); i++) {
		DrawOutlinedText(g_SmallFont, "* " + m_answers[i], { 115, float(140 + (i * g_SmallFont.get()->baseSize * 1.3)) }, g_SmallFont.get()->baseSize, 1, YELLOW);
	}

	DrawConsole();

	// Draw version number in lower-right
	DrawOutlinedText(g_SmallFont, g_version.c_str(), Vector2{600, 340}, g_SmallFont->baseSize, 1, WHITE);

	EndTextureMode();
	DrawTexturePro(g_guiRenderTarget.texture,
		{ 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
		{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
		{ 0, 0 }, 0, WHITE);

	DrawTextureEx(*g_Cursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale , WHITE);

	EndDrawing();
}

void ConversationState::GetAnswers(const std::string& func_name)
{
    m_answers.clear();
    lua_getglobal(g_ScriptingSystem->m_luaState, "answers");
    if (lua_istable(g_ScriptingSystem->m_luaState, -1))
	{
        lua_pushnil(g_ScriptingSystem->m_luaState);
        while (lua_next(g_ScriptingSystem->m_luaState, -2))
		{
            if (lua_isstring(g_ScriptingSystem->m_luaState, -1))
			{
                m_answers.push_back(lua_tostring(g_ScriptingSystem->m_luaState, -1));
            }
            lua_pop(g_ScriptingSystem->m_luaState, 1);
        }
    }
    lua_pop(g_ScriptingSystem->m_luaState, 1);
}

void ConversationState::RemoveAnswer(std::string answer)
{
    auto it = std::remove(m_answers.begin(), m_answers.end(), answer);
    m_answers.erase(it, m_answers.end());
}

void ConversationState::SetAnswer(const std::string& func_name, const std::string& answer)
{
    lua_getglobal(g_ScriptingSystem->m_luaState, "answer");
	if (answer == "nil")
	{
		lua_pushnil(g_ScriptingSystem->m_luaState);
		lua_setglobal(g_ScriptingSystem->m_luaState, "answer");
		return;
	}
	lua_pushstring(g_ScriptingSystem->m_luaState, answer.c_str());
	lua_setglobal(g_ScriptingSystem->m_luaState, "answer");
	m_answerPending = false;
}

void ConversationState::SelectYesNo(bool yes)
{
	if (!m_waitingForAnswer) return;

	// Notify Lua via callback
	if (m_yesNoCallback)
	{
		m_yesNoCallback(yes);
	}

	// Restore previous answers
	m_answers = m_savedAnswers;
	m_savedAnswers.clear();
	m_waitingForAnswer = false;
	m_steps.erase(m_steps.begin());
}