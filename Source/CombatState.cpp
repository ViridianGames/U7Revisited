///////////////////////////////////////////////////////////////////////////
//
// Name:     COMBATSTATE.CPP
// Author:   Anthony Salter (framework by existing states)
// Date:     
// Purpose:  Handles real-time and turn-based combat for Ultima VII Revisited.
//           Pushed onto the state stack when combat begins.
//
///////////////////////////////////////////////////////////////////////////

#include "Geist/Globals.h"
#include "Geist/Logging.h"
#include "Geist/Gui.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/Engine.h"
#include "U7Globals.h"
#include "CombatState.h"

#include <string>

using namespace std;

CombatState::CombatState()
{
	// Combat overlays the game world (we want to see the battlefield)
	m_RenderStack = true;

	// We may want custom cursor handling later; start with default
	m_DrawCursor = true;
}

CombatState::~CombatState()
{
}

void CombatState::Init(const string& configfile)
{
	Log("CombatState::Init()");

	m_Gui = new Gui();
	m_Gui->Init(configfile);
	m_Gui->SetLayout(0, 0, g_Engine->m_RenderWidth, g_Engine->m_RenderHeight, g_DrawScale, Gui::GUIP_USE_XY);

	m_isTurnBased = false;
	m_participants.clear();
}

void CombatState::Shutdown()
{
	Log("CombatState::Shutdown()");

	if (m_Gui)
	{
		delete m_Gui;
		m_Gui = nullptr;
	}
}

void CombatState::OnEnter()
{
	Log("CombatState::OnEnter() - Combat starting");

	// Reset per-combat state
	m_participants.clear();

	// TODO: Detect nearby hostiles and populate participants
	// TODO: Determine real-time vs turn-based based on player settings or situation
}

void CombatState::OnExit()
{
	Log("CombatState::OnExit() - Combat ending");

	m_participants.clear();
	m_isTurnBased = false;

	// TODO: Clean up any temporary combat effects, restore normal AI schedules, etc.
}

void CombatState::Update()
{
	// TODO: Core combat loop
	// - Handle player combat actions (attack, cast, use item, flee)
	// - Update AI for enemies (or initiative system if turn-based)
	// - Check win/lose conditions (all enemies dead, all party dead, flee successful)
	// - Handle camera / targeting during combat

	if (m_Gui)
	{
		m_Gui->Update();
	}

	// Temporary escape hatch for development: press ESC or a key to exit combat
	// This will be replaced by proper flee / victory / defeat logic.
	if (IsKeyPressed(KEY_ESCAPE))
	{
		// For now, just pop out of combat (development only)
		g_StateMachine->PopState();
	}
}

void CombatState::Draw()
{
	// The world (MainState + Terrain + objects) is drawn automatically
	// because m_RenderStack == true.

	// Draw combat-specific UI on top (targeting reticles, action bars, portraits, etc.)
	if (m_Gui)
	{
		m_Gui->Draw();
	}

	// TODO: Draw combat overlays, floating damage numbers, range indicators, etc.
}
