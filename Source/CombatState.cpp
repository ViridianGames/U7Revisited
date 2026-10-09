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
#include "MainState.h"
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
		if (unit->m_NPCData)
			return static_cast<int>(unit->m_NPCData->str);

		// Monsters: look up MONSTERS.DAT by shape (m_BaseMaxHP is also strength-derived).
		if (unit->m_shapeData)
		{
			const int shape = unit->m_shapeData->m_shape;
			for (const MonsterData& md : g_monsterData)
			{
				if (static_cast<int>(md.m_shape) == shape)
					return static_cast<int>(md.m_strength);
			}
		}
		return static_cast<int>(std::max(1.0f, unit->m_BaseMaxHP));
	}

	int GetEquippedArmorPoints(const U7Object* unit, unsigned char& outImmuneMask)
	{
		outImmuneMask = 0;
		if (!unit || !unit->m_NPCData)
			return 0;

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

int FigureCombatHitPoints(U7Object* attacker, U7Object* target, int weaponShape, int ammoShape)
{
	if (!target)
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
	if (target->m_hp < 0.0f)
		target->m_hp = 0.0f;

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

	if (target->m_hp <= 0.0f)
	{
		target->ApplyDeath();
		return true;
	}
	return false;
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
	constexpr float kBarWMin = 8.0f;
	constexpr float kBarWMax = 22.0f;

	auto drawBarFor = [&](U7Object* obj, bool party) {
		if (!obj || obj->GetIsDead() || obj->IsDeathStatus())
			return;

		// Approximate on-screen body width from the bounding box X extents.
		Vector3 left = obj->m_centerPoint;
		Vector3 right = obj->m_centerPoint;
		left.x = obj->m_boundingBox.min.x;
		right.x = obj->m_boundingBox.max.x;
		left.y = right.y = obj->m_centerPoint.y;

		Vector2 screenL = GetWorldToScreen(left, g_camera);
		Vector2 screenR = GetWorldToScreen(right, g_camera);
		screenL.x /= drawScale;
		screenR.x /= drawScale;

		float barW = fabsf(screenR.x - screenL.x);
		if (barW < 1.0f)
		{
			// Fallback when the box projects very thin (edge-on / tiny).
			barW = 12.0f;
		}
		barW = std::clamp(barW, kBarWMin, kBarWMax);

		Vector3 head = obj->m_centerPoint;
		head.y += 1.35f;
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
