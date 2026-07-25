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
#include "Geist/InputSystem.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "U7Player.h"
#include "CombatState.h"
#include "MainState.h"

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

bool CombatState::IsPartyMemberObject(const U7Object* obj) const
{
	if (!obj || !g_Player)
		return false;

	if (obj->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_NPC)
		return false;

	return g_Player->NPCIDInParty(obj->m_NPCID);
}

bool CombatState::IsEnemyObject(const U7Object* obj) const
{
	if (!obj || obj->m_hp <= 0.0f)
		return false;

	if (IsPartyMemberObject(obj))
		return false;

	if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_MONSTER && obj->m_Team == 1)
		return true;

	if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC && obj->m_Team == 1)
		return true;

	return std::find(m_participants.begin(), m_participants.end(), obj->m_ID) != m_participants.end();
}

void CombatState::ClearPartyTargets()
{
	if (!g_Player)
		return;

	for (int npcId : g_Player->GetPartyMemberIds())
	{
		auto itNpc = g_NPCData.find(npcId);
		if (itNpc == g_NPCData.end() || !itNpc->second)
			continue;

		auto itObj = g_objectList.find(itNpc->second->m_objectID);
		if (itObj != g_objectList.end() && itObj->second)
		{
			itObj->second->m_target = 0;
			itObj->second->m_combatMoveOrder = false;
		}
	}
}

void CombatState::OnEnter()
{
	Log("CombatState::OnEnter() - Combat starting");

	g_isCombatMode = true;
	m_paused = true;
	m_selectedPartyMemberObjectId = -1;
	m_participants.clear();
	ClearPartyTargets();

	// Always include the avatar and party members.
	if (g_Player)
	{
		for (int pid : g_Player->GetPartyMemberIds())
		{
			auto itNpc = g_NPCData.find(pid);
			if (itNpc == g_NPCData.end() || !itNpc->second)
				continue;

			int objId = itNpc->second->m_objectID;
			if (std::find(m_participants.begin(), m_participants.end(), objId) == m_participants.end())
				m_participants.push_back(objId);
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
				m_participants.push_back(id);
		}
	}

	AddConsoleString("Combat! The game is paused.", YELLOW);
	AddConsoleString("Click a party member, then click an enemy or the ground to assign orders.", WHITE);
	AddConsoleString("Press Space to begin. Press Space again during combat to pause and reissue orders.", WHITE);

	LockCameraToAvatar();

	// TODO: Determine real-time vs turn-based based on player settings or situation
}

void CombatState::OnExit()
{
	Log("CombatState::OnExit() - Combat ending");

	AddConsoleString("Exiting combat mode.", GREEN);

	m_participants.clear();
	m_selectedPartyMemberObjectId = -1;
	m_isTurnBased = false;
	m_paused = true;
	g_isCombatMode = false;
	ClearPartyTargets();

	// TODO: Clean up any temporary combat effects, restore normal AI schedules, etc.
}

void CombatState::BeginCombat()
{
	m_paused = false;
	m_selectedPartyMemberObjectId = -1;
	LockCameraToAvatar();
	AddConsoleString("Fight!", RED);
}

void CombatState::PauseForOrders()
{
	m_paused = true;
	m_selectedPartyMemberObjectId = -1;
	LockCameraToAvatar();
	AddConsoleString("Combat paused.", YELLOW);
	AddConsoleString("Click a party member, then click an enemy or the ground to assign orders.", WHITE);
	AddConsoleString("Press Space when ready to resume.", WHITE);
}

void CombatState::IssueMoveOrder(U7Object* member, const Vector3& dest)
{
	if (!member)
		return;

	Vector3 moveDest = dest;
	moveDest.y = member->m_Pos.y;

	member->m_target = 0;
	member->m_combatMoveOrder = true;
	member->PathfindToDest(moveDest);

	AddConsoleString(
		member->m_name + " moving to ("
		+ std::to_string((int)moveDest.x) + ", "
		+ std::to_string((int)moveDest.z) + ").",
		GREEN);
}

void CombatState::HandleCombatClick()
{
	if (!m_paused || !g_InputSystem->WasLButtonClicked())
		return;

	if (g_gumpManager && (g_gumpManager->m_isMouseOverGump || g_gumpManager->m_draggingObject))
		return;

	if (g_mouseOverUI)
		return;

	U7Object* clicked = g_objectUnderMousePointer;

	if (clicked && IsPartyMemberObject(clicked))
	{
		m_selectedPartyMemberObjectId = clicked->m_ID;
		AddConsoleString("Selected " + clicked->m_name + " - click an enemy or the ground.", SKYBLUE);
		return;
	}

	if (m_selectedPartyMemberObjectId < 0)
	{
		AddConsoleString("Select a party member first.", YELLOW);
		return;
	}

	auto itMember = g_objectList.find(m_selectedPartyMemberObjectId);
	if (itMember == g_objectList.end() || !itMember->second)
		return;

	U7Object* member = itMember->second.get();

	if (clicked && IsEnemyObject(clicked))
	{
		member->m_target = clicked->m_ID;
		member->m_combatMoveOrder = false;
		AddConsoleString(member->m_name + " will attack " + clicked->m_name + ".", GREEN);
		return;
	}

	// Ground (or any non-enemy) click: reposition and disengage
	IssueMoveOrder(member, g_terrainUnderMousePointer);
}

void CombatState::HandleCombatInput()
{
	HandleCombatClick();

	if (IsKeyPressed(KEY_SPACE))
	{
		if (m_paused)
			BeginCombat();
		else
			PauseForOrders();
		return;
	}

	// Development escape hatch
	if (IsKeyPressed(KEY_ESCAPE))
		g_StateMachine->PopState();
}

void CombatState::Update()
{
	// Keep mouse picking and camera tracking alive while MainState is underneath us.
	g_mouseOverUI = false;
	UpdateSortedVisibleObjects();

	// Allow camera rotation/zoom during combat, including while paused for orders.
	if (g_mainState)
		g_mainState->ProcessCameraInput();

	CameraUpdate();

	HandleCombatInput();

	if (m_gui)
		m_gui->Update();

	// Prune dead participants from the unit list
	auto it = m_participants.begin();
	while (it != m_participants.end())
	{
		auto objIt = g_objectList.find(*it);
		if (objIt == g_objectList.end() || !objIt->second || objIt->second->GetIsDead())
			it = m_participants.erase(it);
		else
			++it;
	}

	// Drive updates for participants while combat is running.
	if (!m_paused)
	{
		for (int pid : m_participants)
		{
			auto objIt = g_objectList.find(pid);
			if (objIt != g_objectList.end() && objIt->second)
			{
				U7Object* obj = objIt->second.get();
				if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_MONSTER ||
				    obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC)
				{
					obj->Update();
				}
			}
		}

		// End combat when all hostiles are defeated
		bool anyHostiles = false;
		for (int pid : m_participants)
		{
			auto objIt = g_objectList.find(pid);
			if (objIt == g_objectList.end() || !objIt->second || objIt->second->GetIsDead())
				continue;

			if (IsEnemyObject(objIt->second.get()))
			{
				anyHostiles = true;
				break;
			}
		}

		if (!anyHostiles)
		{
			AddConsoleString("Combat over - all enemies defeated!", GREEN);
			g_StateMachine->PopState();
		}
	}
}

void CombatState::Draw()
{
	// The world (MainState + Terrain + objects) is drawn automatically
	// because m_RenderStack == true.

	if (m_gui)
		m_gui->Draw();
}