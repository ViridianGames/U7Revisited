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
#include <algorithm>

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

	m_gui = new Gui();
	m_gui->Init(configfile);
	m_gui->SetLayout(0, 0, g_Engine->m_RenderWidth, g_Engine->m_RenderHeight, g_DrawScale, Gui::GUIP_USE_XY);

	m_isTurnBased = false;
	m_participants.clear();
}

void CombatState::Shutdown()
{
	Log("CombatState::Shutdown()");

	if (m_gui)
	{
		delete m_gui;
		m_gui = nullptr;
	}
}

void CombatState::OnEnter()
{
	Log("CombatState::OnEnter() - Combat starting");

	// Reset per-combat state
	m_participants.clear();

	// Detect hostiles (e.g. combat-activity monsters spawned when egg requirements fulfilled, or other NPCs with hostile team)
	// and the player's party, and add them to the participants unit list. This ensures
	// hostile monsters from eggs (when their requirements are fulfilled) are included in combat.
	// Always include the avatar and party members.
	if (g_Player)
	{
		for (int pid : g_Player->GetPartyMemberIds())
		{
			if (std::find(m_participants.begin(), m_participants.end(), pid) == m_participants.end())
			{
				m_participants.push_back(pid);
			}
		}
	}

	// Add hostiles
	for (const auto& [id, obj] : g_objectList)
	{
		if (obj && !obj->GetIsDead() &&
		    (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_MONSTER ||
		     obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC) &&
		    obj->m_Team == 1)
		{
			if (std::find(m_participants.begin(), m_participants.end(), id) == m_participants.end())
			{
				m_participants.push_back(id);
			}
		}
	}

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

	if (m_gui)
	{
		m_gui->Update();
	}

	// Prune dead participants from the unit list
	auto it = m_participants.begin();
	while (it != m_participants.end())
	{
		auto objIt = g_objectList.find(*it);
		if (objIt == g_objectList.end() || !objIt->second || objIt->second->GetIsDead())
		{
			it = m_participants.erase(it);
		}
		else
		{
			++it;
		}
	}

	// Drive updates for participants in the unit list while in combat.
	// This ensures hostile (combat-activity) monsters (added when egg requirements fulfilled) and other units
	// continue to get AI/movement (MonsterUpdate/NPCUpdate etc.) even though main
	// world update is suspended during the pushed combat state.
	for (int pid : m_participants)
	{
		auto objIt = g_objectList.find(pid);
		if (objIt != g_objectList.end() && objIt->second)
		{
			U7Object* obj = objIt->second.get();
			// Update monsters and NPCs in the combat; avatar/player may have special handling elsewhere.
			if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_MONSTER ||
			    obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC)
			{
				obj->Update();
			}
		}
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
	if (m_gui)
	{
		m_gui->Draw();
	}

	// TODO: Draw combat overlays, floating damage numbers, range indicators, etc.
}
