///////////////////////////////////////////////////////////////////////////
//
// Name:     COMBATSTATE.CPP
// Purpose:  Shared combat helpers. Combat session/mode lives on MainState.
//
///////////////////////////////////////////////////////////////////////////

#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/Logging.h"
#include "Geist/StateMachine.h"
#include "Geist/ResourceManager.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "U7Player.h"
#include "CombatState.h"
#include "CombatMode.h"
#include "MainState.h"
#include "PathfindingSystem.h"
#include "raymath.h"
#include "rlgl.h"

#include "Geist/RNG.h"

#include <string>
#include <cctype>
#include <vector>
#include <algorithm>
#include <cmath>
#include <cstdlib>

using namespace std;

namespace
{
	struct FloatingCombatText
	{
		Vector3 worldPos;
		std::string text;
		Color color;
		float age = 0.0f;
		float lifetime = 1.1f;
	};

	std::vector<FloatingCombatText> g_floatingCombatTexts;
}

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

U7Object* GetEquippedWeapon(U7Object* unit)
{
	if (!unit)
		return nullptr;

	if (unit->m_NPCData)
	{
		// Paperdoll allows one-handed weapons in either hand; prefer RIGHT then LEFT.
		// Only accept WEAPONS.DAT shapes so a shield/torch in the other hand is ignored.
		auto trySlot = [&](EquipmentSlot slot) -> U7Object* {
			const int weaponId = unit->m_NPCData->GetEquippedItem(slot);
			if (weaponId < 0)
				return nullptr;
			U7Object* obj = GetObjectFromID(weaponId);
			if (!obj || !obj->m_shapeData)
				return nullptr;
			if (!GetWeaponData(obj->m_shapeData->m_shape))
				return nullptr;
			return obj;
		};

		if (U7Object* right = trySlot(EquipmentSlot::SLOT_RIGHT_HAND))
			return right;
		if (U7Object* left = trySlot(EquipmentSlot::SLOT_LEFT_HAND))
			return left;
		return nullptr;
	}

	// Monsters: EQUIP.DAT gear lives in inventory (no paperdoll). Prefer highest damage.
	if (unit->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_MONSTER)
		return nullptr;

	U7Object* best = nullptr;
	unsigned char bestDamage = 0;
	for (int itemId : unit->m_inventory)
	{
		U7Object* obj = GetObjectFromID(itemId);
		if (!obj || !obj->m_shapeData)
			continue;
		const WeaponData* w = GetWeaponData(obj->m_shapeData->m_shape);
		if (!w)
			continue;
		if (!best || w->damage > bestDamage)
		{
			best = obj;
			bestDamage = w->damage;
		}
	}
	return best;
}

std::string CombatWeaponDisplayName(int weaponShape)
{
	if (weaponShape < 0 || weaponShape >= 1024)
		return "fists";
	if (g_objectDataTable[weaponShape].m_name.empty())
		return "fists";
	// TEXT.FLX raw forms like "/dagger//s" → printable "dagger".
	std::string name = GetShapeFrameName(weaponShape, 0, 1);
	return name.empty() ? "fists" : name;
}

std::string CombatWeaponDisplayNameForUnit(U7Object* unit)
{
	U7Object* weapon = GetEquippedWeapon(unit);
	if (!weapon || !weapon->m_shapeData)
		return "fists";
	const int shape = weapon->m_shapeData->m_shape;
	if (shape < 0 || shape >= 1024 || g_objectDataTable[shape].m_name.empty())
		return "fists";
	std::string name = GetShapeFrameName(shape, weapon->m_shapeData->GetFrame(), 1);
	return name.empty() ? "fists" : name;
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

bool IsUnitInDungeon(const U7Object* unit)
{
	if (!unit || !g_pathfindingSystem)
		return false;
	return g_pathfindingSystem->IsDungeonTile(
		static_cast<int>(unit->m_Pos.x),
		static_cast<int>(unit->m_Pos.z));
}

bool AreUnitsOnSameDungeonLayer(const U7Object* a, const U7Object* b)
{
	if (!a || !b)
		return false;
	// Without dungeon bake data, treat everything as the same layer.
	if (!g_pathfindingSystem)
		return true;
	return IsUnitInDungeon(a) == IsUnitInDungeon(b);
}

bool HasCombatLineOfSight(const U7Object* from, const U7Object* to)
{
	if (!from || !to || !g_pathfindingSystem)
		return false;
	return g_pathfindingSystem->IsStraightPathClear(from->m_Pos, to->m_Pos, from);
}

bool HasCombatWalkPathToParty(U7Object* hostile, float maxCrowFlyTiles, float maxWalkCost)
{
	if (!hostile || !g_pathfindingSystem || !g_Player)
		return false;
	if (maxCrowFlyTiles < 1.0f)
		maxCrowFlyTiles = 1.0f;
	if (maxWalkCost < 1.0f)
		maxWalkCost = 1.0f;
	const float maxCrowFlySqr = maxCrowFlyTiles * maxCrowFlyTiles;

	const int startX = static_cast<int>(std::floor(hostile->m_Pos.x));
	const int startZ = static_cast<int>(std::floor(hostile->m_Pos.z));
	if (startX < 0 || startX >= 3072 || startZ < 0 || startZ >= 3072)
		return false;

	// Must match what chase movement can actually do: FindFastPath / MonsterChase
	// plus ValidateMove on the first step. A flat IsPositionWalkable flood was
	// connecting Destard↔Lasher over mountain-top tiles that ValidateMove rejects,
	// so drakes enrolled then stood still forever.
	auto pathWalkCost = [](const std::vector<Vector3>& path) -> float {
		if (path.size() < 2)
			return 0.0f;
		float cost = 0.0f;
		for (size_t i = 1; i < path.size(); ++i)
		{
			const int x0 = static_cast<int>(std::floor(path[i - 1].x));
			const int z0 = static_cast<int>(std::floor(path[i - 1].z));
			const int x1 = static_cast<int>(std::floor(path[i].x));
			const int z1 = static_cast<int>(std::floor(path[i].z));
			const int dx = std::abs(x1 - x0);
			const int dz = std::abs(z1 - z0);
			// Octile between sparse waypoints (same metric as combat steps).
			const int diag = std::min(dx, dz);
			const int straight = std::max(dx, dz) - diag;
			cost += static_cast<float>(straight) + static_cast<float>(diag) * 1.5f;
		}
		return cost;
	};

	auto firstStepValid = [&](const std::vector<Vector3>& path) -> bool {
		if (path.empty())
			return false;
		// Find the first waypoint on a different tile from the hostile.
		Vector3 dest = path.back();
		for (const Vector3& wp : path)
		{
			const int wx = static_cast<int>(std::floor(wp.x));
			const int wz = static_cast<int>(std::floor(wp.z));
			if (wx != startX || wz != startZ)
			{
				dest = Vector3{ wx + 0.5f, hostile->m_Pos.y, wz + 0.5f };
				break;
			}
		}
		const int dx = static_cast<int>(std::floor(dest.x));
		const int dz = static_cast<int>(std::floor(dest.z));
		if (dx == startX && dz == startZ)
			return true; // already on goal tile
		// Step onto the neighbor toward dest (not a long crow-fly jump).
		const int sx = (dx > startX) ? 1 : ((dx < startX) ? -1 : 0);
		const int sz = (dz > startZ) ? 1 : ((dz < startZ) ? -1 : 0);
		Vector3 neighbor{
			startX + sx + 0.5f,
			hostile->m_Pos.y,
			startZ + sz + 0.5f
		};
		float outH = hostile->m_Pos.y;
		return PathfindingSystem::ValidateMove(hostile, neighbor, outH, nullptr);
	};

	for (int npcId : g_Player->GetPartyMemberIds())
	{
		auto npcIt = g_NPCData.find(npcId);
		if (npcIt == g_NPCData.end() || !npcIt->second)
			continue;
		U7Object* member = GetObjectFromID(npcIt->second->m_objectID);
		if (!member || member->GetIsDead() || member->IsDeathStatus() || member->m_hp <= 0.0f)
			continue;
		if (!AreUnitsOnSameDungeonLayer(hostile, member))
			continue;
		const float distSqr = Vector2DistanceSqr(
			{ hostile->m_Pos.x, hostile->m_Pos.z },
			{ member->m_Pos.x, member->m_Pos.z });
		if (distSqr > maxCrowFlySqr)
			continue;

		Vector3 goal = member->m_Pos;
		Vector3 stand{};
		if (g_pathfindingSystem->FindNearestWalkableStand(
				member->m_Pos, member->m_Pos.y, hostile, stand, 2))
			goal = stand;

		const int goalX = static_cast<int>(std::floor(goal.x));
		const int goalZ = static_cast<int>(std::floor(goal.z));
		if (goalX == startX && goalZ == startZ)
			return true;

		std::vector<Vector3> path = g_pathfindingSystem->FindFastPath(
			hostile->m_Pos, goal, hostile, PathCallerTag::Monster);
		if (path.empty())
			path = g_pathfindingSystem->FindMonsterChasePath(hostile->m_Pos, goal, hostile);
		if (path.empty())
			continue;
		if (pathWalkCost(path) > maxWalkCost + 1.5f)
			continue;
		if (!firstStepValid(path))
			continue;
		return true;
	}
	return false;
}

U7Object* FindNearestHostileInAggroRange()
{
	if (!g_Player)
		return nullptr;
	U7Object* avatar = g_Player->GetAvatarObject();
	if (!avatar)
		return nullptr;

	U7Object* nearest = nullptr;
	float bestDistSqr = kHostileCombatEnrollRangeSqr;

	// Prefer interest chunks when available (avoids full-world scan every warn).
	auto consider = [&](U7Object* obj) {
		if (!obj || !IsHostileCombatUnit(obj))
			return;
		if (!AreUnitsOnSameDungeonLayer(avatar, obj))
			return;
		const float distSqr = Vector2DistanceSqr(
			{ obj->m_Pos.x, obj->m_Pos.z },
			{ avatar->m_Pos.x, avatar->m_Pos.z });
		if (distSqr >= bestDistSqr)
			return;
		// Short enroll range + capped walk flood (no long Destard detours).
		if (!HasCombatWalkPathToParty(obj))
			return;
		bestDistSqr = distSqr;
		nearest = obj;
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
			if (!AreUnitsOnSameDungeonLayer(avatar, nearest)
				|| !HasCombatWalkPathToParty(nearest))
			{
				s_warnedThisEncounter = false;
				return false;
			}
			const float distSqr = Vector2DistanceSqr(
				{ nearest->m_Pos.x, nearest->m_Pos.z },
				{ avatar->m_Pos.x, avatar->m_Pos.z });
			inRange = (distSqr <= kHostileCombatEnrollRangeSqr);
		}
	}
	if (!inRange)
	{
		s_warnedThisEncounter = false;
		return false;
	}

	const std::string label = PluralizeCreatureName(nearest->m_name);

	if (GetCombatAutoStartOnAggro())
	{
		s_warnedThisEncounter = false;
		if (g_mainState)
		{
			g_mainState->m_combatApproachMessage = label + " approach!";
			g_mainState->EnterCombatMode();
			return true;
		}
		return false;
	}

	if (!s_warnedThisEncounter)
	{
		s_warnedThisEncounter = true;
		AddConsoleString(label + " approach! Press C to enter combat.", YELLOW);
		if (g_mainState)
			g_mainState->m_combatApproachMessage = label + " approach!";
	}

	return false;
}

float GetCombatMaxHP(const U7Object* unit)
{
	if (!unit)
		return 1.0f;
	float maxHp = unit->m_BaseMaxHP;
	if (maxHp < 1.0f)
		maxHp = unit->m_hp;
	if (maxHp < 1.0f)
		maxHp = 1.0f;
	return maxHp;
}

namespace
{
	// Exult Actor::get_effective_prop: cursed subtracts 3 from str/dex/int/combat.
	int ApplyCursedPenalty(const U7Object* unit, int val)
	{
		if (unit && (unit->m_flags & kObjFlagCursed) != 0)
			val -= 3;
		return val;
	}

	// Exult: paralyzed / asleep / knocked out → dexterity 0, combat 1 (before curse/might).
	bool IsCombatIncapacitated(const U7Object* unit)
	{
		if (!unit || unit->IsDeathStatus())
			return false;
		if ((unit->m_flags & kObjFlagParalyzed) != 0)
			return true;
		if ((unit->m_flags & kObjFlagAsleep) != 0)
			return true;
		return unit->IsKnockedOut();
	}
}

int GetCombatDexterity(const U7Object* unit)
{
	if (!unit)
		return 10;
	if (IsCombatIncapacitated(unit))
		return 0;
	int val = 10;
	if (unit->m_NPCData)
		val = static_cast<int>(unit->m_NPCData->dex);
	else if (g_Player && g_Player->GetAvatarObject() == unit)
		val = g_Player->GetDex();
	else if (unit->m_shapeData)
	{
		const int shape = unit->m_shapeData->m_shape;
		for (const MonsterData& md : g_monsterData)
		{
			if (static_cast<int>(md.m_shape) == shape)
			{
				val = static_cast<int>(md.m_dexterity);
				break;
			}
		}
	}
	return ApplyCursedPenalty(unit, val);
}

int GetCombatIntelligence(const U7Object* unit)
{
	if (!unit)
		return 10;
	int val = 10;
	if (unit->m_NPCData)
		val = static_cast<int>(unit->m_NPCData->iq);
	else if (g_Player && g_Player->GetAvatarObject() == unit)
		val = g_Player->GetInt();
	else if (unit->m_shapeData)
	{
		const int shape = unit->m_shapeData->m_shape;
		for (const MonsterData& md : g_monsterData)
		{
			if (static_cast<int>(md.m_shape) == shape)
			{
				val = static_cast<int>(md.m_intelligence);
				break;
			}
		}
	}
	return ApplyCursedPenalty(unit, val);
}

ContactFieldType GetContactFieldType(int shape)
{
	switch (shape)
	{
	case 756: // caltrops
		return ContactFieldType::Caltrops;
	default:
		return ContactFieldType::None;
	}
}

float GetCombatTurnApBudget(const U7Object* unit)
{
	const int dex = GetCombatDexterity(unit);
	const float ap = static_cast<float>(dex / 2);
	return ap >= 4.0f ? ap : 4.0f;
}

float CombatStepApCost(Vector3 from, Vector3 to)
{
	// Tile indices (floor), not rounded world deltas — centers at *.5 stay stable.
	const int dx = std::abs(static_cast<int>(std::floor(to.x)) - static_cast<int>(std::floor(from.x)));
	const int dz = std::abs(static_cast<int>(std::floor(to.z)) - static_cast<int>(std::floor(from.z)));
	if (dx == 0 && dz == 0)
		return 0.0f;
	if ((dx == 1 && dz == 0) || (dx == 0 && dz == 1))
		return 1.0f;
	if (dx == 1 && dz == 1)
		return 1.5f;
	// Non-adjacent (crow-fly / teleport): charge Chebyshev distance.
	return static_cast<float>(std::max(dx, dz));
}

namespace
{
	unsigned int CombatRoll(unsigned int n)
	{
		if (n == 0)
			return 0;
		if (g_VitalRNG)
			return g_VitalRNG->Random(n);
		return static_cast<unsigned int>(rand()) % n;
	}

	int GetCombatStrength(const U7Object* unit)
	{
		if (!unit)
			return 0;
		int val = static_cast<int>(std::max(1.0f, unit->m_BaseMaxHP));
		if (unit->m_NPCData)
			val = static_cast<int>(unit->m_NPCData->str);
		else if (unit->m_shapeData)
		{
			// Monsters: look up MONSTERS.DAT by shape (m_BaseMaxHP is also strength-derived).
			const int shape = unit->m_shapeData->m_shape;
			for (const MonsterData& md : g_monsterData)
			{
				if (static_cast<int>(md.m_shape) == shape)
				{
					val = static_cast<int>(md.m_strength);
					break;
				}
			}
		}
		return ApplyCursedPenalty(unit, val);
	}

	unsigned char CombinedWeaponPowers(int weaponShape, int ammoShape)
	{
		unsigned char powers = 0;
		if (const WeaponData* w = (weaponShape >= 0) ? GetWeaponData(weaponShape) : nullptr)
			powers = static_cast<unsigned char>(powers | w->powers);
		if (const AmmoData* a = (ammoShape >= 0) ? GetAmmoData(ammoShape) : nullptr)
			powers = static_cast<unsigned char>(powers | a->powers);
		return powers;
	}

	int GetEquippedArmorPoints(const U7Object* unit, unsigned char& outImmuneMask)
	{
		outImmuneMask = 0;
		if (!unit)
			return 0;

		if (unit->m_NPCData)
		{
			static const EquipmentSlot kArmorSlots[] = {
				EquipmentSlot::SLOT_HEAD,
				EquipmentSlot::SLOT_NECK,
				EquipmentSlot::SLOT_TORSO,
				EquipmentSlot::SLOT_LEGS,
				EquipmentSlot::SLOT_HANDS,
				EquipmentSlot::SLOT_FEET,
				EquipmentSlot::SLOT_LEFT_HAND,  // shield
				EquipmentSlot::SLOT_RIGHT_HAND, // weapon that also grants armor (Sword of Defense, etc.)
				EquipmentSlot::SLOT_LEFT_RING,
				EquipmentSlot::SLOT_RIGHT_RING,
				EquipmentSlot::SLOT_BELT,
			};

			int points = 0;
			for (EquipmentSlot slot : kArmorSlots)
			{
				const int id = unit->m_NPCData->GetEquippedItem(slot);
				if (id < 0)
					continue;
				U7Object* piece = GetObjectFromID(id);
				if (!piece || !piece->m_shapeData)
					continue;
				const ArmorData* armor = GetArmorData(piece->m_shapeData->m_shape);
				if (!armor)
					continue;
				points += static_cast<int>(armor->prot);
				outImmuneMask = static_cast<unsigned char>(outImmuneMask | armor->immune);
			}
			return points;
		}

		// Monsters: sum ARMOR.DAT pieces sitting in EQUIP.DAT inventory.
		if (unit->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_MONSTER)
			return 0;

		int points = 0;
		for (int itemId : unit->m_inventory)
		{
			U7Object* piece = GetObjectFromID(itemId);
			if (!piece || !piece->m_shapeData)
				continue;
			const ArmorData* armor = GetArmorData(piece->m_shapeData->m_shape);
			if (!armor)
				continue;
			points += static_cast<int>(armor->prot);
			outImmuneMask = static_cast<unsigned char>(outImmuneMask | armor->immune);
		}
		return points;
	}

	int GetNaturalArmorPoints(const U7Object* unit)
	{
		if (!unit)
			return 0;
		// Set from MONSTERS.DAT on spawn (m_BaseDefense).
		if (unit->m_BaseDefense > 0.0f)
			return static_cast<int>(unit->m_BaseDefense);
		if (unit->m_shapeData)
		{
			const int shape = unit->m_shapeData->m_shape;
			for (const MonsterData& md : g_monsterData)
			{
				if (static_cast<int>(md.m_shape) == shape)
					return static_cast<int>(md.m_armor);
			}
		}
		return 0;
	}
}

int GetTotalArmorPoints(const U7Object* unit)
{
	unsigned char immune = 0;
	return GetEquippedArmorPoints(unit, immune) + GetNaturalArmorPoints(unit);
}

int GetCombatSkill(const U7Object* unit)
{
	if (!unit)
		return 0;
	// Exult get_effective_prop(combat): incapacitated actors defend/attack as Combat 1.
	if (IsCombatIncapacitated(unit))
		return 1;
	int val = static_cast<int>(unit->m_combat);
	if (g_Player && g_Player->GetAvatarObject() == unit)
		val = g_Player->GetCombat();
	else if (unit->m_NPCData)
		val = static_cast<int>(unit->m_NPCData->combat);
	else if (unit->m_shapeData)
	{
		const int shape = unit->m_shapeData->m_shape;
		for (const MonsterData& md : g_monsterData)
		{
			if (static_cast<int>(md.m_shape) == shape)
			{
				val = static_cast<int>(md.m_combat);
				break;
			}
		}
	}
	return ApplyCursedPenalty(unit, val);
}

bool CombatRollToWin(int attackerPoints, int defenderPoints)
{
	// Exult Actor::roll_to_win: d30; 0 always lose, 29 always win.
	constexpr int kSides = 30;
	const int roll = static_cast<int>(CombatRoll(static_cast<unsigned int>(kSides)));
	if (roll == 0)
		return false;
	if (roll == kSides - 1)
		return true;
	return roll + attackerPoints - defenderPoints >= kSides / 2 - 1;
}

bool TryCombatHit(U7Object* attacker, U7Object* target, int weaponShape, int ammoShape)
{
	if (!target)
		return false;

	const WeaponData* winf = (weaponShape >= 0) ? GetWeaponData(weaponShape) : nullptr;
	const AmmoData* ainf = (ammoShape >= 0) ? GetAmmoData(ammoShape) : nullptr;
	if (winf && winf->autohit)
		return true;

	int attval = GetCombatSkill(attacker);
	if (winf && winf->lucky)
		attval += 3;
	if (ainf && ainf->lucky)
		attval += 3;
	// Exult Combat_schedule::attack_target: ranged weapons get +6 to attval.
	if (winf && winf->uses == WeaponUses::Ranged)
		attval += 6;

	int defval = GetCombatSkill(target);
	if ((target->m_flags & kObjFlagProtection) != 0)
		defval += 3;

	return CombatRollToWin(attval, defval);
}

void ApplyCombatWeaponPowers(U7Object* attacker, U7Object* target, int weaponShape,
	int ammoShape, int hitsDealt)
{
	if (!target || target->IsDeathStatus() || target->GetIsDead())
		return;

	// Exult: Protection prevents weapon powers entirely.
	if ((target->m_flags & kObjFlagProtection) != 0)
		return;

	const unsigned char powers = CombinedWeaponPowers(weaponShape, ammoShape);
	if (powers == 0)
		return;

	// Exult: powers only if damage landed, or the weapon is powers-only (no_damage / 0 wpoints).
	int wpoints = 0;
	if (const WeaponData* w = (weaponShape >= 0) ? GetWeaponData(weaponShape) : nullptr)
		wpoints = static_cast<int>(w->damage);
	if (const AmmoData* a = (ammoShape >= 0) ? GetAmmoData(ammoShape) : nullptr)
		wpoints += static_cast<int>(a->damage);
	const bool powersOnly = (wpoints == 0) || ((powers & WeaponPower::NoDamage) != 0);
	if (hitsDealt == 0 && !powersOnly)
		return;

	// Exult figure_hit_points: for damaging hits attint is fixed at 16.
	constexpr int kAttInt = 16;
	const int defstr = GetCombatStrength(target);
	const int defint = GetCombatIntelligence(target);

	if ((powers & WeaponPower::Poison) != 0 && CombatRollToWin(kAttInt, defstr))
	{
		target->m_flags |= kObjFlagPoisoned;
		target->StartPoisonTimer();
	}
	if ((powers & WeaponPower::Curse) != 0 && CombatRollToWin(kAttInt, defint))
		target->m_flags |= kObjFlagCursed;
	if ((powers & WeaponPower::Charm) != 0 && CombatRollToWin(kAttInt, defint))
		target->m_flags |= kObjFlagCharmed;
	if ((powers & WeaponPower::Sleep) != 0 && CombatRollToWin(kAttInt, defint))
		target->ForceSleep();
	if ((powers & WeaponPower::Paralyze) != 0 && CombatRollToWin(kAttInt, defstr))
		target->m_flags |= kObjFlagParalyzed;
	if ((powers & WeaponPower::Magebane) != 0)
		target->m_mana = 0;
	(void)attacker;
}

int FigureCombatHitPoints(U7Object* attacker, U7Object* target, int weaponShape, int ammoShape)
{
	if (!target)
		return 0;

	// NoDamage weapons still connect for powers, but deal no HP.
	if ((CombinedWeaponPowers(weaponShape, ammoShape) & WeaponPower::NoDamage) != 0)
		return 0;

	int wpoints = 0;
	WeaponDamageType dtype = WeaponDamageType::Normal;

	const WeaponData* winf = (weaponShape >= 0) ? GetWeaponData(weaponShape) : nullptr;
	if (winf)
	{
		wpoints = static_cast<int>(winf->damage);
		dtype = winf->damageType;
	}
	else if (weaponShape < 0 && attacker)
	{
		// Bare hands / monster natural weapon (Exult: points = 1, or Monster_info::weapon).
		int natural = static_cast<int>(attacker->m_BaseAttack);
		if (natural <= 0 && attacker->m_shapeData)
		{
			const int shape = attacker->m_shapeData->m_shape;
			for (const MonsterData& md : g_monsterData)
			{
				if (static_cast<int>(md.m_shape) == shape)
				{
					natural = static_cast<int>(md.m_damage);
					break;
				}
			}
		}
		wpoints = (natural > 0) ? natural : 1;
	}
	else
	{
		wpoints = 1; // unknown weapon shape: still deal a minimal hit
	}

	const AmmoData* ainf = (ammoShape >= 0) ? GetAmmoData(ammoShape) : nullptr;
	if (ainf)
	{
		wpoints += static_cast<int>(ainf->damage);
		if (ainf->damageType != WeaponDamageType::Normal)
			dtype = ainf->damageType;
	}

	if (wpoints <= 0)
		return 0;

	const int str = GetCombatStrength(attacker);
	const int bias = 0; // combat difficulty not wired yet
	int damage = bias;

	// Exult Actor::apply_damage
	if (wpoints >= 127)
	{
		damage = 127;
	}
	else
	{
		int strContrib = str / 3;
		if (dtype != WeaponDamageType::Lightning && strContrib > 0)
			damage += 1 + static_cast<int>(CombatRoll(static_cast<unsigned int>(strContrib)));
		if (wpoints > 0)
			damage += 1 + static_cast<int>(CombatRoll(static_cast<unsigned int>(wpoints)));
	}

	unsigned char gearImmune = 0;
	int armor = -bias + GetNaturalArmorPoints(target) + GetEquippedArmorPoints(target, gearImmune);

	if ((gearImmune & (1u << static_cast<unsigned>(dtype))) != 0)
		return 0; // armor grants immunity to this damage type

	// Lightning / ethereal / sonic / instant-death ignore armor (Exult).
	if (wpoints >= 127
		|| dtype == WeaponDamageType::Lightning
		|| dtype == WeaponDamageType::Ethereal
		|| dtype == WeaponDamageType::Sonic
		|| armor < 0)
	{
		armor = 0;
	}

	if (armor > 0)
		damage -= 1 + static_cast<int>(CombatRoll(static_cast<unsigned int>(armor)));

	if (damage <= 0)
		return 0;
	return damage;
}

bool ApplyCombatDamage(U7Object* target, float amount, U7Object* attacker)
{
	if (!target || amount <= 0.0f)
		return false;
	if (target->IsDeathStatus() || target->GetIsDead())
		return false;

	target->m_hp -= amount;
	// Exult: floor health around -50 for safety.
	if (target->m_hp < -50.0f)
		target->m_hp = -50.0f;

	// Same head anchor as DrawCombatHPBars so the number starts just above the bar.
	Vector3 textPos = target->m_centerPoint;
	textPos.y += 1.35f;
	const bool partyTarget = g_Player
		&& target->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC
		&& g_Player->NPCIDInParty(target->m_NPCID);
	const Color damageColor = partyTarget ? RED : WHITE;
	SpawnFloatingCombatText(textPos, std::to_string(static_cast<int>(std::ceil(amount))), damageColor);

	if (attacker)
		target->NotifyAttackedBy(attacker);

	// Exult: normal weapon hits can start/grow blood (shape 912). Poison/caltrop
	// pass a null attacker, so they skip this path.
	if (attacker && target->CanBleed())
	{
		const int delta = static_cast<int>(std::ceil(amount));
		if (delta > 0 && (rand() % 10) < delta)
			target->Bleed();
	}

	// Exult reduce_health: die below -str/3; else KO (asleep) when crossing to HP <= 0.
	if (target->IsDying())
	{
		target->ApplyDeath();
		return true;
	}
	if (target->m_hp <= 0.0f && (target->m_flags & kObjFlagAsleep) == 0)
	{
		target->ApplyKnockOut();
		return true;
	}
	return false;
}

bool ApplyCaltropDamage(U7Object* victim)
{
	if (!victim || victim->IsDeathStatus() || victim->GetIsDead())
		return false;

	// Exult Field_object::field_effect (caltrops): intelligence < rand() % 40.
	const int intel = GetCombatIntelligence(victim);
	if (intel >= static_cast<int>(CombatRoll(40)))
		return false;

	const float amount = static_cast<float>(1 + CombatRoll(2)); // 1 or 2
	ApplyCombatDamage(victim, amount, nullptr);
	return true;
}

void CheckContactFieldsAt(U7Object* unit)
{
	if (!unit || unit->IsDeathStatus() || unit->GetIsDead())
		return;
	if (unit->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_NPC
		&& unit->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_MONSTER)
		return;

	const int tx = static_cast<int>(std::floor(unit->m_Pos.x));
	const int tz = static_cast<int>(std::floor(unit->m_Pos.z));
	if (tx < 0 || tz < 0 || tx >= 3072 || tz >= 3072)
		return;

	const int cx = tx / 16;
	const int cz = tz / 16;
	if (cx < 0 || cz < 0 || cx >= 192 || cz >= 192)
		return;

	for (U7Object* obj : g_chunkObjectMap[cx][cz])
	{
		if (!obj || obj == unit || !obj->m_objectData || !obj->m_shapeData)
			continue;
		if (obj->GetIsDead() || obj->m_isContained)
			continue;
		if (!obj->m_objectData->m_isTrap)
			continue;

		const int shape = obj->m_shapeData->m_shape;
		if (GetContactFieldType(shape) != ContactFieldType::Caltrops)
			continue;

		const int ox = static_cast<int>(std::floor(obj->m_Pos.x));
		const int oz = static_cast<int>(std::floor(obj->m_Pos.z));
		if (ox != tx || oz != tz)
			continue;

		// Exult hatch / field: same lift (tiny epsilon for surface snap).
		if (std::fabs(unit->m_Pos.y - obj->m_Pos.y) > 0.15f)
			continue;

		ApplyCaltropDamage(unit);
	}
}

void SpawnFloatingCombatText(Vector3 worldPos, const std::string& text, Color color)
{
	FloatingCombatText ft;
	ft.worldPos = worldPos;
	ft.text = text;
	ft.color = color;
	ft.age = 0.0f;
	ft.lifetime = 1.15f;
	g_floatingCombatTexts.push_back(ft);
}

void SpawnFloatingMissText(U7Object* target)
{
	if (!target)
		return;
	// Same head anchor as damage numbers.
	Vector3 textPos = target->m_centerPoint;
	textPos.y += 1.35f;
	SpawnFloatingCombatText(textPos, "MISS", WHITE);
}

void UpdateFloatingCombatTexts()
{
	if (!g_Engine)
		return;
	const float dt = g_Engine->LastFrameInSeconds();
	for (auto it = g_floatingCombatTexts.begin(); it != g_floatingCombatTexts.end(); )
	{
		it->age += dt;
		if (it->age >= it->lifetime)
			it = g_floatingCombatTexts.erase(it);
		else
			++it;
	}
}

void DrawFloatingCombatTexts()
{
	if (!g_SmallFont || g_floatingCombatTexts.empty())
		return;

	const float fontSize = static_cast<float>(g_SmallFont->baseSize);
	const float drawScale = (g_DrawScale > 0.0f) ? g_DrawScale : 1.0f;
	// Match DrawCombatHPBars: bar sits 6px above the head anchor, 2px tall.
	constexpr float kBarScreenOffsetY = 6.0f;
	constexpr float kBarH = 2.0f;
	constexpr float kTextAboveBar = 2.0f;
	constexpr float kRisePixels = 18.0f;

	for (const FloatingCombatText& ft : g_floatingCombatTexts)
	{
		Vector2 screen = GetWorldToScreen(ft.worldPos, g_camera);
		screen.x /= drawScale;
		screen.y /= drawScale;

		const float t = std::clamp(ft.age / ft.lifetime, 0.0f, 1.0f);
		Color c = ft.color;
		c.a = static_cast<unsigned char>(255.0f * (1.0f - t));

		const float textW = MeasureTextEx(*g_SmallFont, ft.text.c_str(), fontSize, 1).x;
		const float startY = screen.y - kBarScreenOffsetY - kBarH - kTextAboveBar - fontSize;
		const Vector2 pos{
			screen.x - textW * 0.5f,
			startY - kRisePixels * t
		};
		DrawOutlinedText(g_SmallFont, ft.text, pos, fontSize, 1, c);
	}
}

void DrawCombatHPBars()
{
	if (!g_isCombatMode || !g_mainState)
		return;

	const float drawScale = (g_DrawScale > 0.0f) ? g_DrawScale : 1.0f;
	constexpr float kBarH = 2.0f;
	// Fixed world width (tiles/cells) so every combatant gets the same bar size.
	constexpr float kBarWorldWidth = 1.5f;

	// Camera-right on XZ so the bar stays 1.5 cells wide under rotation.
	Vector3 camForward = Vector3Subtract(g_camera.target, g_camera.position);
	camForward.y = 0.0f;
	if (Vector3LengthSqr(camForward) < 1e-6f)
		camForward = Vector3{ -1.0f, 0.0f, -1.0f };
	camForward = Vector3Normalize(camForward);
	Vector3 camRight = Vector3Normalize(Vector3CrossProduct(Vector3{ 0.0f, 1.0f, 0.0f }, camForward));
	const float halfW = kBarWorldWidth * 0.5f;

	auto drawBarFor = [&](U7Object* obj, bool party) {
		if (!obj || obj->GetIsDead() || obj->IsDeathStatus())
			return;

		Vector3 head = obj->m_centerPoint;
		head.y += 1.35f;

		Vector3 left = Vector3Add(head, Vector3Scale(camRight, -halfW));
		Vector3 right = Vector3Add(head, Vector3Scale(camRight, halfW));
		Vector2 screenL = GetWorldToScreen(left, g_camera);
		Vector2 screenR = GetWorldToScreen(right, g_camera);
		screenL.x /= drawScale;
		screenR.x /= drawScale;

		float barW = fabsf(screenR.x - screenL.x);
		if (barW < 1.0f)
			barW = 1.0f;

		Vector2 screen = GetWorldToScreen(head, g_camera);
		screen.x /= drawScale;
		screen.y /= drawScale;

		const float maxHp = GetCombatMaxHP(obj);
		const float ratio = std::clamp(obj->m_hp / maxHp, 0.0f, 1.0f);
		const float x = screen.x - barW * 0.5f;
		const float y = screen.y - 6.0f;

		DrawRectangle(static_cast<int>(x) - 1, static_cast<int>(y) - 1,
		              static_cast<int>(barW) + 2, static_cast<int>(kBarH) + 2,
		              Color{ 0, 0, 0, 200 });
		DrawRectangle(static_cast<int>(x), static_cast<int>(y),
		              static_cast<int>(barW), static_cast<int>(kBarH),
		              Color{ 40, 40, 40, 220 });

		Color fill = party ? Color{ 60, 200, 80, 255 } : Color{ 210, 55, 55, 255 };
		if (ratio <= 0.35f)
			fill = party ? Color{ 220, 180, 40, 255 } : Color{ 255, 120, 40, 255 };
		if (ratio <= 0.15f)
			fill = Color{ 255, 40, 40, 255 };

		const int fillW = static_cast<int>(barW * ratio);
		if (fillW > 0)
			DrawRectangle(static_cast<int>(x), static_cast<int>(y), fillW, static_cast<int>(kBarH), fill);
	};

	for (int pid : g_mainState->m_combatParticipants)
	{
		auto it = g_objectList.find(pid);
		if (it == g_objectList.end() || !it->second)
			continue;
		U7Object* obj = it->second.get();
		const bool party = g_Player && obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC
			&& g_Player->NPCIDInParty(obj->m_NPCID);
		const bool hostile = IsHostileCombatUnit(obj);
		if (party || hostile)
			drawBarFor(obj, party);
	}
}

void DrawCombatSelectionCircles()
{
	if (!g_isCombatMode || !g_mainState || !g_ResourceManager)
		return;

	Texture* circleTex = g_ResourceManager->GetTexture("Images/selection_circle.png");
	auto* flatModel = g_ResourceManager->GetModel("Models/3dmodels/flat.obj");
	if (!circleTex || !flatModel)
		return;

	SetMaterialTexture(&flatModel->GetModel().materials[0], MATERIAL_MAP_DIFFUSE, *circleTex);

	auto drawGroundRing = [&](U7Object* obj, Color tint, float scale) {
		if (!obj || obj->GetIsDead() || obj->IsDeathStatus())
			return;
		// Same flat-under-feet offset convention as drop shadows.
		Vector3 pos = Vector3{ obj->m_Pos.x - 0.5f, 0.03f, obj->m_Pos.z + 1.0f };
		rlDisableDepthMask();
		DrawModel(flatModel->GetModel(), pos, scale, tint);
		rlEnableDepthMask();
	};

	const int selectedId = g_mainState->m_combatSelectedPartyMemberObjectId;
	if (selectedId >= 0)
	{
		auto selIt = g_objectList.find(selectedId);
		if (selIt != g_objectList.end() && selIt->second)
		{
			U7Object* member = selIt->second.get();
			drawGroundRing(member, Color{ 40, 220, 80, 230 }, 1.35f);

			if (member->m_target > 0)
			{
				auto tgtIt = g_objectList.find(member->m_target);
				if (tgtIt != g_objectList.end() && tgtIt->second)
					drawGroundRing(tgtIt->second.get(), Color{ 230, 50, 50, 230 }, 1.45f);
			}
		}
	}
}
