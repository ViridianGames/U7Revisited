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
	m_dialogue.clear();

}

void ConversationState::OnEnter()
{
	ClearConsole();
}

void ConversationState::OnExit()
{
	m_answers.clear();
	m_dialogue.clear();
}

void ConversationState::Shutdown()
{
	
}

void ConversationState::Update()
{
	if(m_answers.size() > 0)
	{
		for(int i = 0; i < m_answers.size(); i++)
		{

			if (IsLeftButtonDownInRect({ 115 * g_DrawScale,
				 float((140 + (i * g_SmallFont.get()->baseSize * 1.3)) * g_DrawScale),
				 400 * g_DrawScale,
				 float((g_SmallFont.get()->baseSize * 1.3) * g_DrawScale) }))
			{
				SetAnswer(m_luaFunction, m_answers[i]);
				
				m_answers.clear();
				m_dialogue.clear();
				m_answerPending = true;
				//g_StateMachine->PopState();
			}
		}
	}

	if(m_answerPending)
	{
		m_answerPending = false;
		g_ScriptingSystem->CallScript(m_luaFunction, {m_npcId, 2});  
	}

   if (IsKeyReleased(KEY_SPACE))
	{
		if(m_dialogue.size() <= 1)
		{
			GetAnswers(m_luaFunction);
			if(m_answers.size() == 0)
			{
				m_dialogue.clear();
				m_answers.clear();
				SetAnswer(m_luaFunction, "nil");
				g_StateMachine->PopState();
			}
		}	
		else
		{
			m_dialogue.erase(m_dialogue.begin());
		}
	}

	if (IsKeyReleased(KEY_F1))
	{
		g_StateMachine->PopState();
	}
}

void ConversationState::Draw()
{
	ClearBackground(Color{ 0, 0, 0, 255 });

	BeginDrawing();

	BeginMode3D(g_camera);

	//  Draw the terrain
	g_Terrain->Draw();

	for (auto& unit : g_sortedVisibleObjects)
	{
		unit->Draw();
	}

	EndMode3D();

	float ratio = float(g_Engine->m_ScreenWidth) / float(g_Engine->m_RenderWidth);

	//  Draw the GUI
	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({0, 0, 0, 0});
	//DrawTextureRec(* g_ResourceManager->GetTexture("Images/GUI/guielements.png"), {0, 28, 640, 388}, { 0, 0 }, WHITE);
	DrawRectangleRounded({100, 10, 500, 110}, .25, 100, { 0, 0, 0, 224 });

	m_Gui->Draw();

	DrawTextureEx(*g_ResourceManager->GetTexture("U7FACES" + to_string(m_npcId)), { 4, 10 }, 0, 2, WHITE);	

	if(m_dialogue.size() > 0)
	{
		DrawParagraph(g_ConversationFont, m_dialogue[0], { 115, 20 }, 400,
			g_ConversationFont.get()->baseSize, 1, YELLOW);
	}

	if(m_dialogue.size() == 1)
	{
		for(int i = 0; i < m_answers.size(); i++)
		{
			DrawOutlinedText(g_SmallFont, "* " + m_answers[i], { 115, float(140 + (i * g_SmallFont.get()->baseSize * 1.3)) }, g_SmallFont.get()->baseSize, 1, YELLOW);
		}
	}

	DrawConsole();

	//  Draw version number in lower-right
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

void ConversationState::SetAnswer(const std::string& func_name, const std::string& answer)
{
    lua_getglobal(g_ScriptingSystem->m_luaState, "answer");
	if(answer == "nil")
	{
		lua_pushnil(g_ScriptingSystem->m_luaState);
		lua_setglobal(g_ScriptingSystem->m_luaState, "answer");
		return;
	}
	//lua_pop(g_ScriptingSystem->m_luaState, 1);
    lua_pushstring(g_ScriptingSystem->m_luaState, answer.c_str());
    lua_setglobal(g_ScriptingSystem->m_luaState, "answer");
}