///////////////////////////////////////////////////////////////////////////
//
// Name:     COMBATSTATE.CPP
// Purpose:  Shared combat helpers. Combat session/mode lives on MainState.
//
///////////////////////////////////////////////////////////////////////////

#include "Geist/Globals.h"
#include "Geist/Logging.h"
#include "Geist/StateMachine.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "U7Player.h"
#include "CombatState.h"
#include "MainState.h"

#include <string>
#include <cctype>

using namespace std;

std::string PluralizeCreatureName(const std::string& name)
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
		return name + "es";
	return name + "s";
}

bool IsHostileCombatUnit(const U7Object* unit)
{
	if (!unit || unit->m_hp <= 0.0f || unit->IsDeathStatus())
		return false;
	if (const_cast<U7Object*>(unit)->GetIsDead())
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

	// Prefer interest chunks when available (avoids full-world scan every warn).
	auto consider = [&](U7Object* obj) {
		if (!obj || !IsHostileCombatUnit(obj))
			return;
		const float distSqr = Vector2DistanceSqr(
			{ obj->m_Pos.x, obj->m_Pos.z },
			{ avatar->m_Pos.x, avatar->m_Pos.z });
		if (distSqr < bestDistSqr)
		{
			bestDistSqr = distSqr;
			nearest = obj;
		}
	};

	if (!g_interestChunkList.empty())
	{
		for (int packed : g_interestChunkList)
		{
			const int cx = packed & 0xffff;
			const int cz = (packed >> 16) & 0xffff;
			if (cx < 0 || cx >= 192 || cz < 0 || cz >= 192)
				continue;
			for (U7Object* object : g_chunkObjectMap[cx][cz])
				consider(object);
		}
	}
	else
	{
		for (const auto& [id, obj] : g_objectList)
		{
			(void)id;
			consider(obj.get());
		}
	}
	return nearest;
}

bool TryBeginCombatFromHostileAggro(U7Object* hintHostile)
{
	if (!kCombatStateEnabled)
		return false;

	if (g_isCombatMode)
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
		if (g_mainState)
			g_mainState->m_combatApproachMessage = label + " approach!";
	}

	return false;
}
