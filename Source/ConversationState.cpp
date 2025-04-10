#include "Geist/Globals.h"
#include "Geist/Logging.h"
#include "Geist/Gui.h"
#include "Geist/ParticleSystem.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/GuiManager.h"
#include "Geist/Engine.h"
#include "U7Globals.h"
#include "ConversationState.h"
#include "rlgl.h"
#include "U7Gump.h"

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
	
}

void ConversationState::OnEnter()
{
	ClearConsole();
	AddConsoleString(std::string("You have entered conversation state!"));
}

void ConversationState::OnExit()
{

}

void ConversationState::Shutdown()
{
	UnloadRenderTexture(g_guiRenderTarget);
	UnloadRenderTexture(g_renderTarget);
	
}

void ConversationState::Update()
{
   if (IsKeyReleased(KEY_SPACE))
	{
      ClearConsole();
      AddConsoleString(std::string("Leaving conversation state!"));
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

	DrawConsole();

	//  Draw version number in lower-right
	DrawTextEx(*g_SmallFont, g_version.c_str(), Vector2{600, 340}, g_SmallFont->baseSize, 1, WHITE);

	EndTextureMode();
   DrawTexturePro(g_guiRenderTarget.texture,
		{ 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
		{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
		{ 0, 0 }, 0, WHITE);

	DrawTextureEx(*g_Cursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale , WHITE);

	EndDrawing();
   
}