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
#include "PerfTelemetry.h"

#include <string>
#include <algorithm>
#include <cctype>

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

	if (IsHostileCombatUnit(obj))
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
	SetFirstPersonMouseLook(false);

	g_isCombatMode = true;
	m_paused = true;
	m_selectedPartyMemberObjectId = -1;
	m_participants.clear();
	ClearPartyTargets();

	if (g_combatCursor)
		g_Cursor = g_combatCursor;

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

	EnrollNearbyHostiles();

	if (!m_approachMessage.empty())
	{
		AddConsoleString(m_approachMessage, YELLOW);
		m_approachMessage.clear();
	}
	else
	{
		AddConsoleString("Combat! The game is paused.", YELLOW);
	}
	AddConsoleString("Click a party member, then click an enemy or the ground to assign orders.", WHITE);
	AddConsoleString("Press Space to begin. Press Space again during combat to pause and reissue orders.", WHITE);
	AddConsoleString("Press C or Escape to leave combat.", WHITE);

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
	m_approachMessage.clear();
	ClearPartyTargets();

	if (g_defaultCursor)
		g_Cursor = g_defaultCursor;

	// TODO: Clean up any temporary combat effects, restore normal AI schedules, etc.
}

static std::string PluralizeCreatureName(const std::string& name)
{
	if (name.empty())
		return "Enemies";

	const std::string lower = [&]() {
		std::string s = name;
		for (char& c : s)
			c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
		return s;
	}();

	const size_t n = lower.size();
	const bool endsEs =
		(n >= 1 && (lower[n - 1] == 's' || lower[n - 1] == 'x' || lower[n - 1] == 'z')) ||
		(n >= 2 && lower[n - 2] == 'c' && lower[n - 1] == 'h') ||
		(n >= 2 && lower[n - 2] == 's' && lower[n - 1] == 'h');

	if (endsEs)
		return name + "es"; // Headless → Headlesses
	return name + "s";
}

bool IsHostileCombatUnit(const U7Object* unit)
{
	if (!unit || unit->m_hp <= 0.0f)
		return false;
	if (unit->m_Team != 1)
		return false;
	return unit->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_MONSTER
		|| unit->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC;
}

U7Object* FindNearestHostileInAggroRange()
{
	if (!g_Player)
		return nullptr;
	U7Object* avatar = g_Player->GetAvatarObject();
	if (!avatar)
		return nullptr;

	U7Object* nearest = nullptr;
	float bestDistSqr = kHostileAggroRangeSqr;
	for (const auto& [id, obj] : g_objectList)
	{
		(void)id;
		if (!obj || !IsHostileCombatUnit(obj.get()))
			continue;
		const float distSqr = Vector2DistanceSqr(
			{ obj->m_Pos.x, obj->m_Pos.z },
			{ avatar->m_Pos.x, avatar->m_Pos.z });
		if (distSqr < bestDistSqr)
		{
			bestDistSqr = distSqr;
			nearest = obj.get();
		}
	}
	return nearest;
}

void CombatState::EnsureParticipant(int objectId)
{
	if (objectId <= 0)
		return;
	if (std::find(m_participants.begin(), m_participants.end(), objectId) == m_participants.end())
		m_participants.push_back(objectId);
}

void CombatState::EnrollNearbyHostiles()
{
	U7Object* avatar = g_Player ? g_Player->GetAvatarObject() : nullptr;
	if (!avatar)
		return;

	for (const auto& [id, obj] : g_objectList)
	{
		if (!obj || !IsHostileCombatUnit(obj.get()))
			continue;
		const float distSqr = Vector2DistanceSqr(
			{ obj->m_Pos.x, obj->m_Pos.z },
			{ avatar->m_Pos.x, avatar->m_Pos.z });
		if (distSqr > kHostileAggroRangeSqr)
			continue;
		EnsureParticipant(static_cast<int>(id));
	}
}

bool TryBeginCombatFromHostileAggro(U7Object* hintHostile)
{
	if (!kCombatStateEnabled)
		return false;

	if (!g_StateMachine)
		return false;

	if (g_isCombatMode || g_StateMachine->GetCurrentState() == STATE_COMBATSTATE)
		return false;

	// One scan per frame.
	static unsigned int s_lastAggroScanFrame = 0;
	if (s_lastAggroScanFrame == g_CurrentUpdate)
		return false;
	s_lastAggroScanFrame = g_CurrentUpdate;

	// Do not auto-enter combat. Warn once per encounter; player presses C to engage.
	static bool s_warnedThisEncounter = false;

	U7Object* nearest = FindNearestHostileInAggroRange();
	if (!nearest)
		nearest = hintHostile;
	if (!nearest || !IsHostileCombatUnit(nearest))
	{
		s_warnedThisEncounter = false;
		return false;
	}

	// Confirm the nearest is actually in range (hint alone is not enough).
	bool inRange = false;
	if (g_Player)
	{
		if (U7Object* avatar = g_Player->GetAvatarObject())
		{
			const float distSqr = Vector2DistanceSqr(
				{ nearest->m_Pos.x, nearest->m_Pos.z },
				{ avatar->m_Pos.x, avatar->m_Pos.z });
			inRange = (distSqr <= kHostileAggroRangeSqr);
		}
	}
	if (!inRange)
	{
		s_warnedThisEncounter = false;
		return false;
	}

	if (!s_warnedThisEncounter)
	{
		s_warnedThisEncounter = true;
		const std::string label = PluralizeCreatureName(nearest->m_name);
		AddConsoleString(label + " approach! Press C to enter combat.", YELLOW);
		if (g_CombatState)
			g_CombatState->m_approachMessage = label + " approach!";
	}

	return false;
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
	// Explicit ground order may need stairs/crates — Full climb-aware A*.
	member->PathfindToDest(moveDest, /*allowHierarchical=*/true, PathCallerTag::AvatarParty);

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

	// C / Escape end combat (MainState::Update does not run while we are on top,
	// so C must be handled here — previously only Escape worked and felt like a trap).
	if (IsKeyPressed(KEY_C) || IsKeyPressed(KEY_ESCAPE))
	{
		AddConsoleString("Leaving combat.", GREEN);
		g_StateMachine->PopState();
	}
}

void CombatState::Update()
{
	// MainState::Update does not run while we are on top of the stack. Keep
	// interest visibility + terrain lighting fresh or the stacked Draw shows
	// black voids where chunks were never re-stamped this frame.
	g_mouseOverUI = false;

	const double tCam0 = GetTime();
	if (g_mainState)
		g_mainState->ProcessCameraInput();
	CameraUpdate();
	g_perf.msCamera += (GetTime() - tCam0) * 1000.0;

	const double tInterest0 = GetTime();
	RebuildInterestCentersFromLocalPlayers();
	RebuildInterestChunkSet();

	const float heightCutoff = g_mainState ? g_mainState->m_heightCutoff : 16.0f;
	int interestVis = 0;
	for (int packed : g_interestChunkList)
	{
		const int cx = packed & 0xffff;
		const int cz = (packed >> 16) & 0xffff;
		if (cx < 0 || cx >= 192 || cz < 0 || cz >= 192)
			continue;
		for (U7Object* object : g_chunkObjectMap[cx][cz])
		{
			if (!object || object->m_isContained || object->GetIsDead())
				continue;
			ApplyObjectDrawVisibility(object, heightCutoff);
			++interestVis;
		}
	}
	g_interestObjectsUpdated = interestVis;
	g_perf.AddMs(g_perf.msInterest, g_perf.maxMsInterest, (GetTime() - tInterest0) * 1000.0);

	const double tTer0 = GetTime();
	if (g_Terrain)
		g_Terrain->Update();
	g_perf.AddMs(g_perf.msTerrainUp, g_perf.maxMsTerrainUp, (GetTime() - tTer0) * 1000.0);

	const double tPal0 = GetTime();
	UpdateRuntimePalette();
	g_perf.msPalette += (GetTime() - tPal0) * 1000.0;

	const double tSort0 = GetTime();
	UpdateSortedVisibleObjects();
	g_perf.AddMs(g_perf.msSort, g_perf.maxMsSort, (GetTime() - tSort0) * 1000.0);

	const double tOther0 = GetTime();
	// Keep enrolling hostiles that walk into range (or were nearer than the trigger).
	EnrollNearbyHostiles();

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
	g_perf.msCombatOther += (GetTime() - tOther0) * 1000.0;

	// Drive updates for participants while combat is running.
	if (!m_paused)
	{
		const double tCombat0 = GetTime();
		for (int pid : m_participants)
		{
			auto objIt = g_objectList.find(pid);
			if (objIt != g_objectList.end() && objIt->second)
			{
				U7Object* obj = objIt->second.get();
				if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_MONSTER ||
				    obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC)
				{
					if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_MONSTER)
						++g_perf.monsterUpdates;
					else
						++g_perf.npcUpdates;
					obj->Update();
				}
			}
		}
		g_perf.AddMs(g_perf.msCombatUpdate, g_perf.maxMsCombatUpdate, (GetTime() - tCombat0) * 1000.0);

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