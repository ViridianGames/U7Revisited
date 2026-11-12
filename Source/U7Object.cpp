//  There are three types of objects in Ultima 7:
//  1. Statics, which are drawn in the world and do not move or interact with the player
//  2. Dynamic objects, which are drawn in the world and can move or interact with the player
//  3. NPCs, which are drawn in the world, can move and fight, and have a conversation tree
//
//  OOP would suggest that we should have a base class for all objects, and then subclass
//  each type of object.  However, I'm eschewing that complexity.  There's a lot of overlap
//  between dynamic objects and NPCs, so I'm just going to have a single class for all objects
//  and control things with flags.

#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/Config.h"
#include "Geist/ScriptingSystem.h"
#include "Geist/SoundSystem.h"
#include "Geist/Logging.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "ShapeData.h"
#include "LoadingState.h"
#include "MainState.h"
#include "CombatState.h"
#include "CombatMode.h"
#include "PathfindingSystem.h"
#include "PerfTelemetry.h"
#include "WeatherSystem.h"
#include "U7GumpSpellbook.h"
#include "U7SpriteEffects.h"
#include "Terrain.h"
#include "raylib.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>
#include <algorithm>
#include <iterator>
#include <cmath>
#include <unordered_map>
#include <cctype>
#include <vector>
#include "raymath.h"
#include "rlgl.h"
#include <atomic>


using namespace std;

namespace
{
	constexpr const char* kMeshExtinguishAnim = "Extinguish-armatureAction";
	constexpr float kMeshAnimFps = 24.0f;
}

// Contiguous per-NPC batch index allocator.
// This is file-scoped so it's preserved while the program runs and used by NPCInit / LoadFromJson.
static std::atomic_int s_nextNpcBatchIndex{0};

U7Object::~U7Object()
{
	Shutdown();
}

void U7Object::Init(const string& configfile, int unitType, int frame)
{
	m_Pos = Vector3{ 0, 0, 0 };
	m_Dest = Vector3{ 0, 0, 0 };
	m_Direction = Vector3{ 0, 0, 0 };
	m_Scaling = Vector3{ 1, 1, 1 };
	m_ExternalForce = Vector3{ 0, 0, 0 };
	m_GravityFlag = true;
	m_ExternalForceFlag = true;
	m_Angle = 0;
	m_Selected = false;
	m_Visible = true;
	m_Mesh = NULL;
	m_ObjectType = unitType;
	SetIsDead(false);
	m_UnitConfig = g_ResourceManager->GetConfig(configfile);
	// g_shapeTable is [1024][32] — out-of-range frames (e.g. usecode "any" sentinel
	// 359 treated as a literal) walk into neighboring shapes (641+11 → cart 652).
	if (frame < 0 || frame >= 32)
		frame = 0;
	m_Frame = frame;
	m_shapeData = &g_shapeTable[m_ObjectType][m_Frame];
	m_objectData = &g_objectDataTable[m_ObjectType];
	m_drawType = m_shapeData->GetDrawType();
	// Desync looping FX so every instance does not pop on the same frame.
	// Surf tiles stay locked to frame 0 so shoreline strips stay continuous.
	m_animFrameOffset = 0;
	// TFA ambient props / lit lights loop; craft tools, casino wheels, doors stay
	// Frozen until a usecode script drives frames.
	ApplyDefaultAnimMode();
	if (m_objectData && m_objectData->m_isAnimated)
	{
		const int animFrames = g_shapeTable[m_ObjectType][0].m_numFrames;
		// Exact TEXT.FLX name "surf" (shoreline strips must stay in phase).
		const std::string& animName = m_objectData->m_name;
		const bool isSurf = (animName.size() == 4 &&
			std::tolower(static_cast<unsigned char>(animName[0])) == 's' &&
			std::tolower(static_cast<unsigned char>(animName[1])) == 'u' &&
			std::tolower(static_cast<unsigned char>(animName[2])) == 'r' &&
			std::tolower(static_cast<unsigned char>(animName[3])) == 'f');
		if (animFrames > 1 && !isSurf)
		{
			m_animFrameOffset = g_NonVitalRNG
				? (int)g_NonVitalRNG->RandomRange(0, (unsigned)animFrames - 1)
				: (rand() % animFrames);
		}
	}
	m_isContainer = false;
	m_isContained = false;
	m_virtueMarked = false;
	m_virtueX = 0.0f;
	m_virtueY = 0.0f;
	m_virtueZ = 0.0f;
	m_hasGump = false;
	m_inventory.clear();
	m_hasConversationTree = false;
	m_InventoryPos = Vector2{ 0, 0 };
	m_isCustomMesh = false;
	m_customMeshName = "Models/3dmodels/zzwrongcube.obj";
	m_customMesh = nullptr;
	m_meshOutline = true;
	m_isMoving = false;
	m_isActivated = false;
	m_activationTimer = 0.0f;
	m_actCooldown = 0.125f;
	m_distanceFromCamera = 999999;
	m_target = 0;

	// TFA shape class 6 = container (Exult). Do not use WGTVOL volume: tables,
	// large props, and other scenery also have high volume and are not chests.
	if (IsTfaContainerShape(m_objectData))
		m_isContainer = true;

	// STATIC = permanent scenery only: immovable, unusable, and not otherwise special.
	// g_isObjectMoveable means "can pick up / drag" — doors and other fixtures are
	// not moveable but ARE usable, so they must be UNIT_TYPE_OBJECT (saved, frame
	// state, scripts). Otherwise open doors revert on load.
	const bool canPickUp = (unitType >= 0 && unitType < 1024 && g_isObjectMoveable[unitType] != 0);
	const bool isDoor = (m_objectData != nullptr && m_objectData->m_isDoor);
	const bool hasUseScript = (m_shapeData != nullptr
		&& !m_shapeData->m_luaScript.empty()
		&& m_shapeData->m_luaScript != "default");

	if (!canPickUp && !isDoor && !hasUseScript && !m_isContainer)
	{
		m_UnitType = U7Object::UnitTypes::UNIT_TYPE_STATIC;
	}
	else
	{
		m_UnitType = U7Object::UnitTypes::UNIT_TYPE_OBJECT;
	}
}

void U7Object::Draw()
{
	// Common early-out checks. Eggs still reach EggDraw when visible so g_showEggs can gate art.
	if (!m_Visible || m_isContained || !m_ShouldDraw || m_drawSuppressedByEmptyFrame)
	{
		return;
	}

	// Invisible strangers are omitted from the visible list; this is a backstop.
	if (IsHiddenByInvisibility())
	{
		return;
	}

	// Dispatch to type-specific drawing.
	switch (m_UnitType)
	{
		case UnitTypes::UNIT_TYPE_STATIC:
			StaticDraw();
			break;

		case UnitTypes::UNIT_TYPE_OBJECT:
			InteractiveDraw();
			break;

		case UnitTypes::UNIT_TYPE_NPC:
			NPCDraw();
			break;

		case UnitTypes::UNIT_TYPE_EGG:
			EggDraw();
			break;

		case UnitTypes::UNIT_TYPE_MONSTER:
			MonsterDraw();
			break;

		default:
			break;
	}

	// Shared debug drawing (applies to all types)
	if (g_Engine->m_debugDrawing)
	{
		DrawBoundingBox(m_boundingBox, MAGENTA);
	}

	if (g_Engine->m_debugDrawing)
	{
		DrawSphere(m_centerPoint, .15f, RED);
	}
}

///////////////////////////////////////////////////////////////////////////
//  TYPE-SPECIFIC UPDATE FUNCTIONS
//  Called from U7Object::Update() via switch on m_UnitType
///////////////////////////////////////////////////////////////////////////

void U7Object::StaticUpdate()
{
	// Statics do nothing on update.
}

namespace
{
	bool InTurnBasedCombat();
}

void U7Object::ArmFireField(float seconds)
{
	if (seconds < 0.0f)
		seconds = 0.0f;
	m_Quality = 100;
	// Immovable scenery is UNIT_TYPE_STATIC and never Update()s, so the
	// removal clock would never run. Spell fields have to be interactive.
	m_UnitType = UnitTypes::UNIT_TYPE_OBJECT;
	m_fireFieldPlayStartup = true;
	m_fireFieldAnimStart = GetTime();
	SetFrame(0);
	// 20 seconds is 7 rounds. Shorter fields (Fire Ring, Flame Strike) scale
	// by the same seconds-per-round so a 7-second field is about 2 rounds.
	const float secPerRound = kFireFieldLifetimeSec / static_cast<float>(kFireFieldTurnRounds);
	int rounds = static_cast<int>(std::lround(seconds / secPerRound));
	if (rounds < 1)
		rounds = 1;
	if (InTurnBasedCombat())
	{
		m_fireFieldTurnsRemaining = rounds;
		m_fireFieldEndsAt = 0.0f;
	}
	else
	{
		m_fireFieldTurnsRemaining = 0;
		m_fireFieldEndsAt = GetTime() + seconds;
	}
	NoteTimedFireField(static_cast<int>(m_ID));
	// Anyone already on the tile burns now. The next pulse waits a second
	// so this frame's UpdateFireField does not hit them again.
	m_fireFieldNextPulse = GetTime() + kFireFieldPulseSec;
	ApplyFireFieldPulse(this);
}

void U7Object::ArmEnergyField()
{
	// Usecode quality and the removal delay are both 200 ticks (40 seconds).
	m_Quality = 200;
	m_UnitType = UnitTypes::UNIT_TYPE_OBJECT;
	m_fireFieldPlayStartup = false;
	const float seconds = 40.0f; // 200 usecode ticks at 0.20s
	const float secPerRound = kFireFieldLifetimeSec / static_cast<float>(kFireFieldTurnRounds);
	int rounds = static_cast<int>(std::lround(seconds / secPerRound));
	if (rounds < 1)
		rounds = 1;
	if (InTurnBasedCombat())
	{
		m_fireFieldTurnsRemaining = rounds;
		m_fireFieldEndsAt = 0.0f;
	}
	else
	{
		m_fireFieldTurnsRemaining = 0;
		m_fireFieldEndsAt = GetTime() + seconds;
	}
	NoteTimedFireField(static_cast<int>(m_ID));
}

void U7Object::ExpireFireField()
{
	if (GetIsDead())
		return;
	m_fireFieldEndsAt = 0.0f;
	m_fireFieldTurnsRemaining = 0;
	ForgetTimedFireField(static_cast<int>(m_ID));
	if (m_objectData && m_objectData->m_isNotWalkable)
		NotifyPathfindingGridUpdate(static_cast<int>(m_Pos.x), static_cast<int>(m_Pos.z));
	if (g_mainState && g_mainState->m_barkObject == this)
		g_mainState->ClearBarks();
	if (g_SoundSystem)
		g_SoundSystem->StopLoopingSoundEffect(static_cast<int>(m_ID));
	m_ShouldDraw = false;
	m_Visible = false;
	SetIsDead(true);
	// Poison and sleep fields have no burn timer. The same removal drops them
	// once they catch someone, and Dispel Field uses this path too.
}

void U7Object::UpdateFireField()
{
	const int shape = m_shapeData ? m_shapeData->m_shape : m_ObjectType;
	const bool fire = (shape == kFireFieldShape);
	const bool energy = (shape == kEnergyFieldShape);
	if (!fire && !energy)
		return;
	if (GetIsDead() || m_isContained || !m_Visible)
		return;

	const float now = GetTime();
	const bool turnBased = InTurnBasedCombat();

	// Left turn-based combat with rounds still banked. Finish on the real-time clock.
	if (!turnBased && m_fireFieldTurnsRemaining > 0)
	{
		const float sec = (static_cast<float>(m_fireFieldTurnsRemaining) / static_cast<float>(kFireFieldTurnRounds))
			* kFireFieldLifetimeSec;
		m_fireFieldTurnsRemaining = 0;
		m_fireFieldEndsAt = now + sec;
	}

	// Entered turn-based combat with a live clock. Rounds take over.
	if (turnBased && m_fireFieldTurnsRemaining <= 0 && m_fireFieldEndsAt > 0.0f)
	{
		const float remaining = m_fireFieldEndsAt - now;
		const float rounds = (remaining / kFireFieldLifetimeSec) * static_cast<float>(kFireFieldTurnRounds);
		m_fireFieldTurnsRemaining = std::max(1, static_cast<int>(std::lround(rounds)));
		m_fireFieldEndsAt = 0.0f;
		NoteTimedFireField(static_cast<int>(m_ID));
	}

	if (m_fireFieldTurnsRemaining > 0)
		return;

	if (m_fireFieldEndsAt > 0.0f && now >= m_fireFieldEndsAt)
	{
		ExpireFireField();
		return;
	}

	// Energy fields block the tile. They do not burn.
	if (!fire)
		return;

	if (now < m_fireFieldNextPulse)
		return;
	m_fireFieldNextPulse = now + kFireFieldPulseSec;
	ApplyFireFieldPulse(this);
}

void U7Object::InteractiveUpdate()
{
	// Most interactive objects have very little per-frame logic here.
	// Container behavior, scripts, etc. are usually event-driven via Interact().
	UpdateUsecodeScript();
	UpdateFireField();
	UpdateHazardField();
	if (!m_usecodeObjectSchedule)
		return;
	UpdateUsecodeObjectSchedule();
	UpdateMovement();
	UpdateNpcAnim(g_Engine ? g_Engine->LastFrameInSeconds() : 0.0f);
}

void U7Object::EggUpdate()
{
	// Reset hasTriggered for proximity-style criteria when outside their area
	// (if autoReset or for CachedIn). This allows re-triggering on re-entry.
	// For CachedIn this simulates "caching out" (>64 tiles) and back in.
	if (g_Player)
	{
		U7Object* avatar = g_Player->GetAvatarObject();
		if (avatar)
		{
			float dist = Vector2Distance({ m_Pos.x, m_Pos.z }, { avatar->m_Pos.x, avatar->m_Pos.z });
			if (m_eggData.m_criteria == EggCriteria::CachedIn)
			{
				if (dist > CACHED_IN_RADIUS && m_eggData.m_shouldReset)
				{
					m_eggData.m_hasTriggered = false;
					m_eggData.m_shouldReset = false;
					m_eggData.m_rolledThisVisit = false;
				}
				else if (dist > CACHED_IN_RADIUS)
				{
					m_eggData.m_rolledThisVisit = false;
				}
			}
			else if (m_eggData.m_criteria == EggCriteria::AvatarNear ||
					 m_eggData.m_criteria == EggCriteria::PartyNear)
			{
				if (dist > (float)m_eggData.m_distance)
				{
					m_eggData.m_rolledThisVisit = false;
					if (m_eggData.m_autoReset)
					{
						m_eggData.m_hasTriggered = false;
					}
				}
			}
			else if (m_eggData.m_criteria == EggCriteria::AvatarFootpad ||
					 m_eggData.m_criteria == EggCriteria::PartyFootpad)
			{
				if (dist > 1.5f)
				{
					m_eggData.m_rolledThisVisit = false;
					if (m_eggData.m_autoReset)
					{
						m_eggData.m_hasTriggered = false;
					}
				}
			}
		}
	}

	switch (m_eggData.m_type)
	{
		case EggType::MonsterSpawner:
			HandleMonsterSpawnerEgg();
			break;

		case EggType::Jukebox:
			HandleJukeboxEgg();
			break;

		case EggType::ProximitySound:
			HandleProximitySoundEgg();
			break;

		case EggType::Voice:
			HandleVoiceEgg();
			break;

		case EggType::Weather:
			HandleWeatherEgg();
			break;

		case EggType::Teleporter:
			HandleTeleporterEgg();
			break;

		case EggType::Path:
			HandlePathEgg();
			break;

		case EggType::Usecode:
			HandleUsecodeEgg();
			break;
	}

	// Usecode eggs queue delayed arrays on themselves. Those arrays only
	// reach the next function if the egg advances them each frame.
	UpdateUsecodeScript();
}

static bool IsHostileCombatant(const U7Object* unit)
{
	return IsHostileCombatUnit(unit);
}

static bool IsPartyCombatant(const U7Object* unit)
{
	return unit
		&& unit->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC
		&& g_Player
		&& g_Player->NPCIDInParty(unit->m_NPCID);
}

namespace
{
	constexpr int kShapeBow = 597;
	constexpr int kShapeCrossbow = 598;
	constexpr int kShapeSling = 474;
	constexpr int kShapeMagicBow = 606;
	constexpr int kShapeTripleCrossbow = 647;
	constexpr int kShapeArrow = 722;
	constexpr int kShapeBolts = 723;
	constexpr int kShapeMagicBolts = 417;
	constexpr int kShapeBurstArrow = 554;
	constexpr int kShapeMagicArrow = 556;
	constexpr int kShapeLuckyArrow = 558;
	constexpr int kShapeLoveArrow = 560;
	constexpr int kShapeTseramedArrow = 568;
	constexpr int kShapeDeathBolt = 527;
	constexpr int kShapeBoltAlt = 948;

	bool WeaponUsesBolts(int weaponShape)
	{
		return weaponShape == kShapeCrossbow || weaponShape == kShapeTripleCrossbow;
	}

	bool WeaponUsesArrows(int weaponShape)
	{
		return weaponShape == kShapeBow || weaponShape == kShapeMagicBow;
	}

	bool IsCompatibleAmmoShape(int weaponShape, int ammoShape)
	{
		if (WeaponUsesBolts(weaponShape))
		{
			return ammoShape == kShapeBolts
				|| ammoShape == kShapeMagicBolts
				|| ammoShape == kShapeDeathBolt
				|| ammoShape == kShapeBoltAlt;
		}
		if (WeaponUsesArrows(weaponShape))
		{
			return ammoShape == kShapeArrow
				|| ammoShape == kShapeBurstArrow
				|| ammoShape == kShapeMagicArrow
				|| ammoShape == kShapeLuckyArrow
				|| ammoShape == kShapeLoveArrow
				|| ammoShape == kShapeTseramedArrow;
		}
		return false; // sling / unknown — no ammo item required
	}

	int PreferredMissileShape(int weaponShape, int ammoShape)
	{
		if (ammoShape > 0)
			return ammoShape;
		if (WeaponUsesBolts(weaponShape))
			return kShapeBolts;
		if (WeaponUsesArrows(weaponShape))
			return kShapeArrow;
		// Sling (474) and other no-ammo ranged weapons: WEAPONS.DAT projectile
		// (sling → 581 "ammunition").
		if (const WeaponData* w = GetWeaponData(weaponShape))
		{
			if (w->uses == WeaponUses::Ranged && w->projectile > 0 && w->projectile < 1024)
				return w->projectile;
		}
		return 0;
	}

	void LogResolvedAttack(U7Object* attacker, U7Object* target, int weaponShape, int hits)
	{
		const Color color = CombatAttackLogColor(attacker, hits);
		AddCombatLogString(
			FinishCombatLogSentence(FormatCombatAttackSentence(attacker, target, weaponShape, hits)),
			color);
	}

	// Original GetNpcWeapon: a readied weapon wins. An empty hand uses the
	// creature's own shape when that shape is a WEAPONS.DAT row (insects 0,
	// rat 3 poison, snake 4 poison). Otherwise -1, and the hit uses the
	// MONSTERS.DAT damage nibble.
	int CombatStrikeWeaponShape(U7Object* unit)
	{
		if (!unit)
			return -1;
		if (U7Object* weapon = GetEquippedWeapon(unit))
		{
			if (weapon->m_shapeData && weapon->m_shapeData->m_shape > 0)
				return weapon->m_shapeData->m_shape;
		}
		if (unit->m_shapeData && GetWeaponData(unit->m_shapeData->m_shape))
			return unit->m_shapeData->m_shape;
		return -1;
	}

	void ResolveMeleeHit(U7Object* attacker, U7Object* target, int weaponShape)
	{
		if (!attacker || !target)
			return;
		BeginCombatLogSentence();
		if (!TryCombatHit(attacker, target, weaponShape, -1))
		{
			SpawnFloatingMissText(target);
			target->NotifyAttackedBy(attacker);
			LogResolvedAttack(attacker, target, weaponShape, -1);
			return;
		}
		const int hits = FigureCombatHitPoints(attacker, target, weaponShape, -1);
		if (hits > 0)
		{
			ApplyCombatDamage(target, static_cast<float>(hits), attacker);
		}
		else
		{
			// A 0-damage weapon (insects) connects without a floating "0".
			// Armor soaking a real bite still shows 0.
			const WeaponData* w = (weaponShape >= 0) ? GetWeaponData(weaponShape) : nullptr;
			if (!w || w->damage != 0)
				SpawnFloatingZeroDamageText(target);
			// Team-2 bites still pull when the swing connects for no HP.
			if (attacker->m_Team == 2)
				target->NotifyAttackedBy(attacker);
		}
		ApplyCombatWeaponPowers(attacker, target, weaponShape, -1, hits);
		LogResolvedAttack(attacker, target, weaponShape, hits);
	}

	void RefreshPartyAttackRangeFromWeapon(U7Object* unit)
	{
		if (!unit)
			return;
		unit->m_attackRange = MELEE_RANGE_TILES;
		U7Object* weapon = GetEquippedWeapon(unit);
		if (!weapon || !weapon->m_shapeData)
			return;
		unit->m_attackRange = GetWeaponAttackRangeTiles(weapon->m_shapeData->m_shape);
	}

	// Returns ammo object to consume, or null if this weapon needs none.
	// Sets outNeedsAmmo=true when a ranged weapon requires ammo that is missing.
	U7Object* FindCombatAmmo(U7Object* unit, int weaponShape, bool& outNeedsAmmo)
	{
		outNeedsAmmo = false;
		if (!unit)
			return nullptr;

		if (weaponShape == kShapeSling)
			return nullptr; // sling needs no ammo item

		if (!WeaponUsesBolts(weaponShape) && !WeaponUsesArrows(weaponShape))
			return nullptr;

		outNeedsAmmo = true;

		auto usable = [&](U7Object* obj) -> bool {
			return obj && obj->m_shapeData && IsCompatibleAmmoShape(weaponShape, obj->m_shapeData->m_shape);
		};

		if (unit->m_NPCData)
		{
			const int ammoId = unit->m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_AMMO);
			if (ammoId >= 0)
			{
				U7Object* ammo = GetObjectFromID(ammoId);
				if (usable(ammo))
					return ammo;
			}
		}

		for (int id : unit->m_inventory)
		{
			U7Object* obj = GetObjectFromID(id);
			if (usable(obj))
				return obj;
		}
		return nullptr;
	}

	bool ConsumeOneAmmo(U7Object* unit, U7Object* ammo)
	{
		if (!unit || !ammo || !ammo->m_shapeData)
			return false;

		const int shape = ammo->m_shapeData->m_shape;
		const char shapeType = (shape >= 0 && shape < 1024) ? g_objectDataTable[shape].m_shapeType : 0;
		if (shapeType == 3)
		{
			int qty = ammo->m_Quality & 0x7f;
			if (qty <= 0)
				qty = 1;
			if (qty > 1)
			{
				ammo->m_Quality = (ammo->m_Quality & ~0x7f) | ((qty - 1) & 0x7f);
				return true;
			}
		}

		// Last unit in the stack (or non-stackable): remove from inventory/equipment.
		if (unit->m_NPCData && unit->m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_AMMO) == ammo->m_ID)
			unit->m_NPCData->m_equipment[EquipmentSlot::SLOT_AMMO] = -1;
		unit->RemoveObjectFromInventory(ammo->m_ID);
		ammo->m_isContained = false;
		ammo->SetIsDead(true);
		ammo->m_Visible = false;
		return true;
	}
}

void U7Object::NotifyAttackedBy(U7Object* attacker)
{
	if (!attacker || attacker->m_ID == m_ID || attacker->m_hp <= 0.0f || attacker->IsDeathStatus())
		return;
	if (IsDeathStatus() || GetIsDead())
		return;

	// Party and Team 2 summons (Swarm) can pull hostile aggro.
	const bool allyAttacker = IsPartyCombatant(attacker) || attacker->m_Team == 2;
	if (!IsHostileCombatant(this) || !allyAttacker)
		return;

	// A hit still counts, but an unseen attacker is not a legal target.
	if (attacker->IsInvisible() && !CanSeeInvisible())
	{
		if (m_target == static_cast<int>(attacker->m_ID))
		{
			m_target = 0;
			m_combatPathTargetId = 0;
		}
		if (g_isCombatMode && g_mainState)
			g_mainState->EnsureCombatParticipant(static_cast<int>(m_ID), false);
		return;
	}

	// Swarm harass is frequent and deals no damage. A hit has a chance to pull
	// this unit off its current target. Do not clear paths (that repaths every insect).
	if (attacker->m_Team == 2)
	{
		const int attackerId = static_cast<int>(attacker->m_ID);
		bool pullAggro = (m_target == 0 || m_target == attackerId);
		if (!pullAggro)
		{
			const unsigned int roll = g_NonVitalRNG
				? g_NonVitalRNG->Random(2u)
				: static_cast<unsigned int>(rand() % 2);
			pullAggro = (roll == 0);
		}
		if (pullAggro)
		{
			m_target = attackerId;
			m_combatMoveOrder = false;
		}
		if (g_isCombatMode && g_mainState)
			g_mainState->EnsureCombatParticipant(static_cast<int>(m_ID), false);
		return;
	}

	// Switch to whoever just hit us.
	m_target = attacker->m_ID;
	m_combatMoveOrder = false;

	m_pathWaypoints.clear();
	m_currentWaypointIndex = 0;
	m_pathfindingPending = false;
	m_isSchedulePath = false;

	// Hit by the party — force enroll even if walk path is currently blocked.
	if (g_isCombatMode && g_mainState)
		g_mainState->EnsureCombatParticipant(static_cast<int>(m_ID), false);

	if (g_isCombatMode)
		EngageCombatTarget();
}

bool U7Object::EngageCombatTarget()
{
	if (m_target == 0)
		return false;

	// Asleep / paralyzed / knocked-out combatants cannot swing or chase.
	if ((m_flags & kObjFlagAsleep) != 0 || (m_flags & kObjFlagParalyzed) != 0 || IsKnockedOut())
		return false;

	auto targetIt = g_objectList.find(m_target);
	// Invisible targets drop out unless this unit can see them (monster flag bit 7).
	if (targetIt == g_objectList.end() || !targetIt->second ||
	    targetIt->second->GetIsDead() || targetIt->second->IsDeathStatus() ||
	    (targetIt->second->IsInvisible() && !CanSeeInvisible()))
	{
		const bool wasParty = IsPartyCombatant(this);
		m_target = 0;
		m_combatPathTargetId = 0;
		if (wasParty)
		{
			m_combatMoveOrder = false;
			// Ranged: keep Attack mode with no target and finish cooldown / shot anim
			// before auto-pausing, so a newly issued target can fire immediately.
			U7Object* weapon = GetEquippedWeapon(this);
			const int weaponShape = (weapon && weapon->m_shapeData) ? weapon->m_shapeData->m_shape : -1;
			if (IsRangedWeaponShape(weaponShape)
			    && (m_cooldownTimer > 0.0f || m_npcAnimPlaying))
			{
				return false;
			}
			m_combatOrderMode = CombatOrderMode::Hold;
			if (g_mainState && g_isCombatMode && !g_mainState->IsCombatOrdersPaused())
				g_mainState->NotifyCombatantCannotContinue(this, "has no target!");
		}
		return false;
	}

	U7Object* target = targetIt->second.get();
	m_combatMoveOrder = false;

	// Cast / usecode script: stand still and do not swing or path until it ends.
	if (IsInUsecodeScript())
	{
		m_pathWaypoints.clear();
		m_currentWaypointIndex = 0;
		m_pathfindingPending = false;
		m_isMoving = false;
		SetDest(m_Pos);
		++g_perf.engageCombatCalls;
		return true;
	}

	if (IsPartyCombatant(this))
		RefreshPartyAttackRangeFromWeapon(this);

	const int weaponShape = CombatStrikeWeaponShape(this);
	const bool isRanged = IsRangedWeaponShape(weaponShape);

	// Tile A* goals land on tile centers, so a bare attackRange check often leaves
	// melee attackers forever one step short of swinging. Engage with slack; path
	// to a standoff inside that bubble.
	constexpr float kEngageRangeSlack = 0.85f;
	constexpr float kStandoffInset = 0.55f;
	const float engageRange = m_attackRange + kEngageRangeSlack;
	const float standOffRange = std::max(0.6f, m_attackRange - kStandoffInset);

	float distSqr = Vector2DistanceSqr({ m_Pos.x, m_Pos.z }, { target->m_Pos.x, target->m_Pos.z });
	float combatRangeSqr = engageRange * engageRange;

	// In weapon range but a wall blocks the shot — reposition instead of firing through.
	if (distSqr <= combatRangeSqr && !HasCombatLineOfSight(this, target))
	{
		const Vector3 standoff = GetStandoffPosition(m_Pos, target->m_Pos, standOffRange);
		const bool hasPath = !m_pathWaypoints.empty() && m_currentWaypointIndex < (int)m_pathWaypoints.size();
		if (!hasPath && g_pathfindingSystem && !m_pathfindingPending)
		{
			const bool isParty = (m_UnitType == UnitTypes::UNIT_TYPE_NPC && g_Player &&
				g_Player->NPCIDInParty(m_NPCID));
			const bool isMonsterChase = (m_UnitType == UnitTypes::UNIT_TYPE_MONSTER) ||
				(m_Team == 1 && !isParty);
			if (isMonsterChase)
			{
				ApplyPathWaypoints(g_pathfindingSystem->FindMonsterChasePath(m_Pos, standoff, this));
				if (m_pathWaypoints.empty())
					SetDest(standoff);
			}
			else
			{
				ApplyPathWaypoints(g_pathfindingSystem->FindFastPath(
					m_Pos, standoff, this, PathCallerTag::AvatarParty));
				if (m_pathWaypoints.empty())
					SetDest(standoff);
			}
			m_combatPathGoal = standoff;
			m_combatPathTargetId = static_cast<int>(target->m_ID);
		}
		++g_perf.engageCombatCalls;
		return true;
	}

	if (distSqr <= combatRangeSqr)
	{
		// Hold position while in attack range so we don't keep walking toward a stale destination.
		m_pathWaypoints.clear();
		m_currentWaypointIndex = 0;
		m_pathfindingPending = false;
		m_isMoving = false;
		SetDest(m_Pos);

		// Face the target so the attack billboard reads correctly.
		Vector3 toTarget = Vector3Subtract(target->m_Pos, m_Pos);
		toTarget.y = 0.0f;
		if (Vector3LengthSqr(toTarget) > 1e-6f)
			m_Direction = Vector3Normalize(toTarget);

		// TB / RTwP: first hostile swing pulls the party into paused combat.
		// Original style: fight in the open without forcing combat mode.
		auto enterPausedCombatFromHostileAttack = [&]() {
			if (g_isCombatMode || !g_mainState || m_Team != 1)
				return;
			const CombatStyle style = GetCombatStylePreference();
			if (style != CombatStyle::RealTimePause && style != CombatStyle::TurnBased)
				return;
			g_mainState->EnterCombatMode();
			g_mainState->EnsureCombatParticipant(static_cast<int>(m_ID));
		};

		// Cooldown always ticks; anim length must not stall the next swing.
		if (m_cooldownTimer > 0.0f && g_Engine)
			m_cooldownTimer -= g_Engine->LastFrameInSeconds();

		auto applyMeleeHit = [&]() {
			ResolveMeleeHit(this, target, weaponShape);
		};

		// Start a one-shot attack/shoot clip when off cooldown.
		if (m_cooldownTimer <= 0.0f && !m_npcAnimPlaying)
		{
			if (isRanged)
			{
				bool needsAmmo = false;
				U7Object* ammo = FindCombatAmmo(this, weaponShape, needsAmmo);
				if (needsAmmo && !ammo)
				{
					const char* ammoName = WeaponUsesBolts(weaponShape) ? "bolts" : "arrows";
					if (g_mainState)
					{
						g_mainState->NotifyCombatantCannotContinue(
							this,
							std::string("is out of ") + ammoName + "!");
					}
					++g_perf.engageCombatCalls;
					return true;
				}
				// Stash ammo id on target... we'll consume on hit phase via re-find.
				(void)ammo;
			}
			StartNpcAttackAnim();
			m_cooldownTimer = m_attackCooldown > 0.1f ? m_attackCooldown : 1.5f;
			enterPausedCombatFromHostileAttack();
			// No strike frames (common for simple monster shapes): land melee now.
			if (!isRanged && m_npcAnimHitPhase < 0)
				applyMeleeHit();
		}

		// Apply the hit when the strike/release frame is reached.
		if (ConsumeNpcAnimHitEvent())
		{
			if (isRanged)
			{
				bool needsAmmo = false;
				U7Object* ammo = FindCombatAmmo(this, weaponShape, needsAmmo);
				const int ammoShape = (ammo && ammo->m_shapeData) ? ammo->m_shapeData->m_shape : -1;
				const int missileShape = PreferredMissileShape(weaponShape, ammoShape > 0 ? ammoShape : 0);
				constexpr float kBoltSpeed = 22.0f;
				if (missileShape > 0)
				{
					if (ammo)
						ConsumeOneAmmo(this, ammo);
					// Damage + console line are figured at impact (weapon/ammo/armor).
					SpawnFlyingProjectile(missileShape, m_ID, target->m_ID, kBoltSpeed, 0, 0,
						weaponShape, ammoShape);
				}
				else
				{
					BeginCombatLogSentence();
					if (!TryCombatHit(this, target, weaponShape, ammoShape))
					{
						SpawnFloatingMissText(target);
						target->NotifyAttackedBy(this);
						LogResolvedAttack(this, target, weaponShape, -1);
					}
					else
					{
						const int hits = FigureCombatHitPoints(this, target, weaponShape, ammoShape);
						if (hits > 0)
							ApplyCombatDamage(target, static_cast<float>(hits), this);
						else
							SpawnFloatingZeroDamageText(target);
						ApplyCombatWeaponPowers(this, target, weaponShape, ammoShape, hits);
						LogResolvedAttack(this, target, weaponShape, hits);
					}
				}
			}
			else
			{
				applyMeleeHit();
			}
		}
	}
	else
	{
		const Vector3 standoff = GetStandoffPosition(m_Pos, target->m_Pos, standOffRange);
		const float now = GetTime();
		const float goalDx = standoff.x - m_combatPathGoal.x;
		const float goalDz = standoff.z - m_combatPathGoal.z;
		const float goalMoved = sqrtf(goalDx * goalDx + goalDz * goalDz);
		const bool hasPath = !m_pathWaypoints.empty() && m_currentWaypointIndex < (int)m_pathWaypoints.size();
		const bool stuck = m_moveStuckFrames >= 10;
		const bool targetChanged = (m_combatPathTargetId != m_target);
		const bool goalDrifted = goalMoved >= kCombatRepathGoalSlopTiles;
		const bool cooldownReady = (now >= m_combatRepathAt);

		const bool needRepath = !hasPath || stuck || targetChanged || goalDrifted ||
			(!hasPath && cooldownReady) || (hasPath && goalDrifted && cooldownReady);

		// Keep following an existing path while the target hasn't moved far.
		if (!needRepath)
			return true;

		// Only repath on cooldown once we already have a path (avoid per-frame A*).
		if (hasPath && !stuck && !targetChanged && !cooldownReady)
			return true;

		if (!g_pathfindingSystem)
			return true;

		const bool isParty = (m_UnitType == UnitTypes::UNIT_TYPE_NPC && g_Player &&
			g_Player->NPCIDInParty(m_NPCID));
		const bool isMonsterChase = (m_UnitType == UnitTypes::UNIT_TYPE_MONSTER) ||
			(m_Team == 1 && !isParty);

		std::vector<Vector3> path;
		if (isMonsterChase)
		{
			// Absolute simplest: straight / greedy / tiny Fast — never Full A*.
			path = g_pathfindingSystem->FindMonsterChasePath(m_Pos, standoff, this);
		}
		else
		{
			// Party chase: Exult Fast budget (explicit ground orders use Full via IssueMoveOrder).
			path = g_pathfindingSystem->FindFastPath(m_Pos, standoff, this, PathCallerTag::AvatarParty);
		}

		if (path.empty())
		{
			// Last mile: crow-fly toward standoff when A* has nothing left
			// (crowding, already near goal tile, or chase path failed).
			m_pathWaypoints.clear();
			m_currentWaypointIndex = 0;
			m_pathfindingPending = false;
			SetDest(standoff);
			m_isMoving = true;
		}
		else
		{
			ApplyPathWaypoints(std::move(path));
		}
		m_combatPathGoal = standoff;
		m_combatPathTargetId = m_target;
		m_combatRepathAt = now + kCombatRepathCooldownSec;
		m_moveStuckFrames = 0;
		++g_perf.combatRepaths;
	}

	++g_perf.engageCombatCalls;
	return true;
}

void U7Object::HostileCombatUpdate()
{
	if (IsDeathStatus() || GetIsDead())
		return;

	// Exult Obj_flags: asleep=1, paralyzed=7 — skip chase/attack while incapacitated.
	if ((m_flags & (1u << 1)) != 0 || (m_flags & (1u << 7)) != 0)
		return;

	// Vas Por Ylem. The stumble script owns the pose until it finishes.
	if (IsTrembling())
	{
		m_pathWaypoints.clear();
		m_currentWaypointIndex = 0;
		m_pathfindingPending = false;
		m_isMoving = false;
		m_combatMoveOrder = false;
		SetDest(m_Pos);
		return;
	}

	// Orders pause only applies once combat has started.
	if (g_isCombatMode && g_mainState && g_mainState->IsCombatOrdersPaused())
	{
		// Turn-Based Resolving: active hostile may finish a Move order.
		if (g_mainState->CanCombatUnitAct(this)
		    && (m_combatOrderMode == CombatOrderMode::Move || m_combatMoveOrder))
		{
			UpdateMovement();
		}
		return;
	}

	// Quas Wis. Turn-based flees on that unit's own turn. Real time runs here.
	if (IsFleeing())
	{
		const bool turnBased = g_isCombatMode && g_mainState && g_mainState->m_combatMode
			&& g_mainState->m_combatMode->GetStyle() == CombatStyle::TurnBased;
		if (!turnBased)
			UpdateFearFlee();
		return;
	}

	// Outside formal combat: still select a party target, close in, and swing.
	// TB/RTwP auto-enter paused combat on the first hostile attack.
	if (!g_Player)
		return;

	auto inAggroRange = [&](U7Object* candidate) -> bool {
		if (!candidate)
			return false;
		if (!AreUnitsOnSameDungeonLayer(this, candidate))
			return false;
		const float distSqr = Vector2DistanceSqr(
			{ m_Pos.x, m_Pos.z },
			{ candidate->m_Pos.x, candidate->m_Pos.z });
		return distSqr <= kHostileAggroRangeSqr;
	};

	auto isValidPartyTarget = [&](U7Object* candidate) -> bool {
		if (!candidate || candidate->GetIsDead() || candidate->IsDeathStatus())
			return false;
		if (candidate->IsInvisible() && !CanSeeInvisible())
			return false;
		if (candidate->m_UnitType != UnitTypes::UNIT_TYPE_NPC)
			return false;
		if (!g_Player->NPCIDInParty(candidate->m_NPCID))
			return false;
		if (!inAggroRange(candidate))
			return false;
		// Walls block acquiring a new target; keep chasing one already acquired.
		if (m_target != static_cast<int>(candidate->m_ID)
			&& !HasCombatLineOfSight(this, candidate))
			return false;
		return true;
	};

	// Swarm insects (Team 2): preferred distraction targets over the party.
	auto isValidSwarmTarget = [&](U7Object* candidate) -> bool {
		if (!candidate || candidate->GetIsDead() || candidate->IsDeathStatus())
			return false;
		if (candidate->IsInvisible() && !CanSeeInvisible())
			return false;
		if (candidate->m_Team != 2)
			return false;
		if (candidate->m_UnitType != UnitTypes::UNIT_TYPE_MONSTER)
			return false;
		return inAggroRange(candidate);
	};

	auto isValidHostileTarget = [&](U7Object* candidate) -> bool {
		return isValidSwarmTarget(candidate) || isValidPartyTarget(candidate);
	};

	auto selectNearestPartyTarget = [&]() -> int {
		int bestId = 0;
		float bestDistSqr = kHostileAggroRangeSqr;
		for (int npcId : g_Player->GetPartyMemberIds())
		{
			auto itNpc = g_NPCData.find(npcId);
			if (itNpc == g_NPCData.end() || !itNpc->second)
				continue;
			U7Object* member = GetObjectFromID(itNpc->second->m_objectID);
			if (!isValidPartyTarget(member))
				continue;
			const float distSqr = Vector2DistanceSqr(
				{ m_Pos.x, m_Pos.z },
				{ member->m_Pos.x, member->m_Pos.z });
			if (distSqr < bestDistSqr)
			{
				bestDistSqr = distSqr;
				bestId = member->m_ID;
			}
		}
		return bestId;
	};

	auto selectPreferredTarget = [&]() -> int {
		// New targets stay on the party. An insect pulls aggro only when its
		// harass roll in NotifyAttackedBy succeeds; that target stays valid above.
		return selectNearestPartyTarget();
	};

	// Drop a target that died or left aggro range, then prefer Swarm over party.
	U7Object* current = (m_target > 0) ? GetObjectFromID(m_target) : nullptr;
	if (!isValidHostileTarget(current))
		m_target = 0;

	if (m_target == 0)
		m_target = selectPreferredTarget();

	if (m_target == 0)
	{
		UpdateMovement();
		return;
	}

	if (!EngageCombatTarget())
	{
		// Target may have died during engage validation — retarget once this frame.
		m_target = selectPreferredTarget();
		if (m_target != 0)
			EngageCombatTarget();
	}
	UpdateMovement();
}

bool U7Object::IsHiddenByInvisibility() const
{
	if ((m_flags & kObjFlagInvisible) == 0)
		return false;
	// Exult Actor::paint skips invisible NPCs who are not the Avatar or in the
	// party. Ordinary objects stay on screen and use the invisibility xform.
	if (m_UnitType != UnitTypes::UNIT_TYPE_NPC
		&& m_UnitType != UnitTypes::UNIT_TYPE_MONSTER)
		return false;
	if (m_UnitType == UnitTypes::UNIT_TYPE_NPC)
	{
		if (m_NPCID == 0)
			return false;
		if (g_Player && g_Player->NPCIDInParty(m_NPCID))
			return false;
	}
	return true;
}

bool U7Object::WearsInvisibilityRing() const
{
	if (!m_NPCData)
		return false;

	auto slotIsRing = [this](EquipmentSlot slot) -> bool
	{
		const int itemId = m_NPCData->GetEquippedItem(slot);
		if (itemId < 0)
			return false;
		U7Object* item = GetObjectFromID(itemId);
		// Exult Wearing_ring(actor, 296, 0): shape 296, frame 0, either finger.
		return item && item->m_ObjectType == 296 && item->m_Frame == 0;
	};

	return slotIsRing(EquipmentSlot::SLOT_LEFT_RING)
		|| slotIsRing(EquipmentSlot::SLOT_RIGHT_RING);
}

void U7Object::ApplyInvisibilityGhostTint(Color& color) const
{
	if ((m_flags & kObjFlagInvisible) == 0)
		return;
	// alphaDiscard keys off the texture, so a low tint alpha still ghosts the body.
	color.r = static_cast<unsigned char>((static_cast<int>(color.r) * 3) / 4);
	color.g = static_cast<unsigned char>((static_cast<int>(color.g) * 3) / 4);
	const int boostedBlue = static_cast<int>(color.b) + 48;
	color.b = static_cast<unsigned char>(boostedBlue > 255 ? 255 : boostedBlue);
	color.a = static_cast<unsigned char>((static_cast<int>(color.a) * 110) / 255);
}

void U7Object::StartInvisibilityTimer()
{
	// Exult: Game::get_ticks() + 60000 + rand()%20000.
	const float now = GetTime();
	m_invisibilityEndsAt = now + 60.0f + static_cast<float>(rand() % 20);
}

void U7Object::StopInvisibilityTimer()
{
	m_invisibilityEndsAt = 0.0f;
}

void U7Object::UpdateInvisibilityTimer()
{
	if ((m_flags & kObjFlagInvisible) == 0)
	{
		StopInvisibilityTimer();
		return;
	}
	if (IsDeathStatus() || GetIsDead())
	{
		m_flags &= ~kObjFlagInvisible;
		StopInvisibilityTimer();
		return;
	}
	// Worn ring: stay invisible and do not keep a spell timer underneath it.
	if (WearsInvisibilityRing())
	{
		StopInvisibilityTimer();
		return;
	}
	if (m_invisibilityEndsAt <= 0.0f)
	{
		// Flag restored without a duration (older save). Give the spell a fresh span.
		StartInvisibilityTimer();
		return;
	}
	if (GetTime() >= m_invisibilityEndsAt)
	{
		m_flags &= ~kObjFlagInvisible;
		StopInvisibilityTimer();
	}
}

void U7Object::StopAttacksOnInvisible()
{
	if ((m_flags & kObjFlagInvisible) == 0)
		return;

	const int myId = static_cast<int>(m_ID);
	for (auto& entry : g_objectList)
	{
		U7Object* attacker = entry.second.get();
		if (!attacker || attacker == this || attacker->CanSeeInvisible())
			continue;
		if (attacker->m_target == myId)
		{
			attacker->m_target = 0;
			attacker->m_combatPathTargetId = 0;
		}
		if (attacker->m_combatSpellTargetId == myId)
		{
			attacker->m_combatSpellId = -1;
			attacker->m_combatSpellTargetId = 0;
			attacker->m_combatSpellHasTile = false;
		}
	}
}

void U7Object::StartPoisonTimer()
{
	// Exult Npc_poison_timer: lasts 1-3 minutes; first check after 5s.
	const float now = GetTime();
	m_poisonEndsAt = now + 60.0f + static_cast<float>(rand() % 120);
	m_poisonNextTickAt = now + 5.0f;
}

void U7Object::StopPoisonTimer()
{
	m_poisonEndsAt = 0.0f;
	m_poisonNextTickAt = 0.0f;
}

void U7Object::UpdatePoisonTimer()
{
	if (m_poisonEndsAt <= 0.0f)
		return;
	if (IsDeathStatus() || GetIsDead())
	{
		m_flags &= ~kObjFlagPoisoned;
		StopPoisonTimer();
		return;
	}
	if ((m_flags & kObjFlagPoisoned) == 0)
	{
		StopPoisonTimer();
		return;
	}

	const float now = GetTime();
	if (now >= m_poisonEndsAt)
	{
		m_flags &= ~kObjFlagPoisoned;
		StopPoisonTimer();
		AnnounceStatusFlag(kObjFlagPoisoned, false);
		return;
	}
	if (now < m_poisonNextTickAt)
		return;

	// Exult: reduce_health(rand()%3, poison_damage); next tick in 10-20s.
	const int penalty = rand() % 3;
	if (penalty > 0)
		ApplyCombatDamage(this, static_cast<float>(penalty), nullptr);
	m_poisonNextTickAt = now + 10.0f + static_cast<float>(rand() % 10);
}

bool U7Object::IsCharmImmune() const
{
	// MONSTERS.DAT byte 2 bit 1 = charm_safe, byte 6 bit 2 = power_safe.
	// Exult set_flag(charmed) returns without applying either. Gear frame
	// powers are not loaded. No monster row means the creature can be charmed.
	int shape = m_ObjectType;
	if (m_shapeData)
		shape = m_shapeData->m_shape;
	for (const MonsterData& md : g_monsterData)
	{
		if (static_cast<int>(md.m_shape) != shape)
			continue;
		if ((md.m_raw[2] & 2) != 0 || (md.m_raw[6] & 4) != 0)
			return true;
		return false;
	}
	return false;
}

void U7Object::StartCharmTimer()
{
	// Exult Npc_flag_timer: 60000 + rand()%60000 ms, about 60–120 seconds.
	const float now = GetTime();
	m_charmEndsAt = now + 60.0f + static_cast<float>(rand() % 61);
}

void U7Object::StopCharmTimer()
{
	m_charmEndsAt = 0.0f;
}

void U7Object::EndCharm(bool announce)
{
	const bool had = (m_flags & kObjFlagCharmed) != 0;
	m_flags &= ~kObjFlagCharmed;
	StopCharmTimer();
	if (m_charmHomeTeam >= 0)
	{
		m_Team = m_charmHomeTeam;
		m_charmHomeTeam = -1;
		m_target = 0;
		m_combatPathTargetId = 0;
		m_pathWaypoints.clear();
		m_currentWaypointIndex = 0;
		m_pathfindingPending = false;
		m_isMoving = false;
		SetDest(m_Pos);
	}
	if (announce && had)
		AnnounceStatusFlag(kObjFlagCharmed, false);
}

void U7Object::UpdateCharmTimer()
{
	const bool flagged = (m_flags & kObjFlagCharmed) != 0;
	if (!flagged && m_charmEndsAt <= 0.0f && m_charmHomeTeam < 0)
		return;

	if (IsDeathStatus() || GetIsDead() || !flagged)
	{
		EndCharm(false);
		return;
	}
	if (m_charmEndsAt <= 0.0f)
	{
		EndCharm(false);
		return;
	}
	if (GetTime() >= m_charmEndsAt)
		EndCharm(true);
}

namespace
{
	bool IsAvatarUnit(const U7Object* unit)
	{
		if (!unit)
			return false;
		if (unit->m_NPCID == 0)
			return true;
		return g_Player && g_Player->GetAvatarObject() == unit;
	}

	void ReadMightStats(U7Object* unit, int& str, int& dex, int& iq, int& combat)
	{
		str = 1;
		dex = 0;
		iq = 0;
		combat = 0;
		if (!unit)
			return;
		if (IsAvatarUnit(unit) && g_Player)
		{
			str = g_Player->GetStr();
			dex = g_Player->GetDex();
			iq = g_Player->GetInt();
			combat = g_Player->GetCombat();
			return;
		}
		if (unit->m_NPCData)
		{
			str = static_cast<int>(unit->m_NPCData->str);
			dex = static_cast<int>(unit->m_NPCData->dex);
			iq = static_cast<int>(unit->m_NPCData->iq);
			combat = static_cast<int>(unit->m_NPCData->combat);
		}
	}

	int ClampMightStat(int value, int lo)
	{
		if (value < lo)
			return lo;
		if (value > 255)
			return 255;
		return value;
	}

	void WriteMightStats(U7Object* unit, int str, int dex, int iq, int combat)
	{
		if (!unit)
			return;
		str = ClampMightStat(str, 1);
		dex = ClampMightStat(dex, 0);
		iq = ClampMightStat(iq, 0);
		combat = ClampMightStat(combat, 0);
		if (unit->m_NPCData)
		{
			unit->m_NPCData->str = static_cast<unsigned char>(str);
			unit->m_NPCData->dex = static_cast<unsigned char>(dex);
			unit->m_NPCData->iq = static_cast<unsigned char>(iq);
			unit->m_NPCData->combat = static_cast<unsigned char>(combat);
		}
		unit->m_combat = static_cast<float>(combat);
		if (IsAvatarUnit(unit) && g_Player)
		{
			g_Player->SetStr(str);
			g_Player->SetDex(dex);
			g_Player->SetInt(iq);
			g_Player->SetCombat(combat);
		}
	}

	int MightBonusFor(int stat)
	{
		return stat < 15 ? stat : 15;
	}
}

bool U7Object::IsDeathSafe() const
{
	// Exult Monster_info byte 6 bit 3. A named NPC with no monster row is not safe.
	int shape = m_ObjectType;
	if (m_shapeData)
		shape = m_shapeData->m_shape;
	for (const MonsterData& md : g_monsterData)
	{
		if (static_cast<int>(md.m_shape) != shape)
			continue;
		return (md.m_raw[6] & 8) != 0;
	}
	return false;
}

void U7Object::ApplyMight()
{
	if (m_UnitType != UnitTypes::UNIT_TYPE_NPC
		&& m_UnitType != UnitTypes::UNIT_TYPE_MONSTER)
		return;
	if (IsDeathStatus() || GetIsDead())
		return;

	const float now = GetTime();
	const bool already = m_mightEndsAt > now
		&& (m_mightStrBonus != 0 || m_mightDexBonus != 0
			|| m_mightIntBonus != 0 || m_mightCombatBonus != 0);
	if (already)
	{
		m_mightEndsAt = now + 60.0f + static_cast<float>(rand() % 61);
		m_flags |= kObjFlagMight;
		return;
	}

	int str = 1;
	int dex = 0;
	int iq = 0;
	int combat = 0;
	ReadMightStats(this, str, dex, iq, combat);
	m_mightBaseStr = str;
	m_mightBaseDex = dex;
	m_mightBaseInt = iq;
	m_mightBaseCombat = combat;
	m_mightStrBonus = MightBonusFor(str);
	m_mightDexBonus = MightBonusFor(dex);
	m_mightIntBonus = MightBonusFor(iq);
	m_mightCombatBonus = MightBonusFor(combat);
	WriteMightStats(this,
		str + m_mightStrBonus,
		dex + m_mightDexBonus,
		iq + m_mightIntBonus,
		combat + m_mightCombatBonus);
	m_flags |= kObjFlagMight;
	m_mightEndsAt = now + 60.0f + static_cast<float>(rand() % 61);
	AnnounceStatusFlag(kObjFlagMight, true);
}

void U7Object::EndMight(bool announce)
{
	const bool had = (m_flags & kObjFlagMight) != 0;
	if (m_mightStrBonus != 0 || m_mightDexBonus != 0
		|| m_mightIntBonus != 0 || m_mightCombatBonus != 0)
	{
		int str = 1;
		int dex = 0;
		int iq = 0;
		int combat = 0;
		ReadMightStats(this, str, dex, iq, combat);
		WriteMightStats(this,
			str - m_mightStrBonus,
			dex - m_mightDexBonus,
			iq - m_mightIntBonus,
			combat - m_mightCombatBonus);
	}
	m_mightStrBonus = 0;
	m_mightDexBonus = 0;
	m_mightIntBonus = 0;
	m_mightCombatBonus = 0;
	m_mightBaseStr = 0;
	m_mightBaseDex = 0;
	m_mightBaseInt = 0;
	m_mightBaseCombat = 0;
	m_mightEndsAt = 0.0f;
	m_flags &= ~kObjFlagMight;
	if (announce && had)
		AnnounceStatusFlag(kObjFlagMight, false);
}

void U7Object::UpdateMightTimer()
{
	if (m_mightEndsAt <= 0.0f && (m_flags & kObjFlagMight) == 0)
		return;
	if (IsDeathStatus() || GetIsDead() || (m_flags & kObjFlagMight) == 0)
	{
		EndMight(false);
		return;
	}
	if (GetTime() >= m_mightEndsAt)
		EndMight(true);
}

void U7Object::RestoreMightStats()
{
	if (m_mightEndsAt <= 0.0f)
		return;
	if (GetTime() >= m_mightEndsAt)
	{
		EndMight(false);
		return;
	}
	WriteMightStats(this,
		m_mightBaseStr + m_mightStrBonus,
		m_mightBaseDex + m_mightDexBonus,
		m_mightBaseInt + m_mightIntBonus,
		m_mightBaseCombat + m_mightCombatBonus);
	m_flags |= kObjFlagMight;
}

void U7Object::ApplyCharm(U7Object* caster)
{
	if (m_UnitType != UnitTypes::UNIT_TYPE_NPC
		&& m_UnitType != UnitTypes::UNIT_TYPE_MONSTER)
		return;
	if (IsDeathStatus() || GetIsDead() || m_hp <= 0.0f)
		return;
	if (IsCharmImmune())
		return;

	const bool was = (m_flags & kObjFlagCharmed) != 0;
	m_flags |= kObjFlagCharmed;
	StartCharmTimer();

	// Exult's normal charm difficulty does not turn the Avatar, and it does
	// not force charmed party members to attack. Switching their team would
	// also make the combat prune treat them as hostiles.
	const bool avatar = (g_Player && g_Player->GetAvatarObject() == this);
	const bool partyMember = avatar
		|| (m_UnitType == UnitTypes::UNIT_TYPE_NPC && g_Player
			&& g_Player->NPCIDInParty(m_NPCID));
	if (!partyMember)
	{
		if (m_charmHomeTeam < 0)
			m_charmHomeTeam = m_Team;

		bool casterHostile = false;
		if (caster)
		{
			const bool casterParty = caster->m_UnitType == UnitTypes::UNIT_TYPE_NPC
				&& g_Player && g_Player->NPCIDInParty(caster->m_NPCID);
			casterHostile = !casterParty && caster->m_Team == 1;
		}
		// Party / neutral / summon caster: fight hostiles (team 2).
		// Hostile caster: fight the party (team 1). A recast keeps the home team.
		m_Team = casterHostile ? 1 : 2;
		m_target = 0;
		m_combatPathTargetId = 0;
		m_combatSpellId = -1;
		m_combatSpellTargetId = 0;
		m_combatSpellHasTile = false;
		m_combatMoveOrder = false;
		m_pathWaypoints.clear();
		m_currentWaypointIndex = 0;
		m_pathfindingPending = false;
		m_isMoving = false;
		SetDest(m_Pos);

		// Exult Combat_schedule::stop_attacking_npc: drop anyone aiming at them.
		const int myId = static_cast<int>(m_ID);
		for (auto& entry : g_objectList)
		{
			U7Object* other = entry.second.get();
			if (!other || other == this)
				continue;
			if (other->m_target == myId)
			{
				other->m_target = 0;
				other->m_combatPathTargetId = 0;
			}
		}

		if (g_isCombatMode && g_mainState)
			g_mainState->EnsureCombatParticipant(myId, false);
	}

	if (!was)
		AnnounceStatusFlag(kObjFlagCharmed, true);
}

namespace
{
	// Exult sleeps a living actor for 5-10 seconds. Attack cooldown is about
	// 3 seconds, so that is two or three missed actions. Turn-based combat
	// counts those as this unit's own turns.
	int RollTurnBasedSleepTurns()
	{
		return 2 + (rand() % 2);
	}

	bool InTurnBasedCombat()
	{
		return g_isCombatMode && g_mainState && g_mainState->m_combatMode
			&& g_mainState->m_combatMode->GetStyle() == CombatStyle::TurnBased;
	}
}

void U7Object::StartSleepTimer()
{
	const float now = GetTime();
	m_sleepNextMendCheckAt = now + g_secsPerMinute * 0.5f;

	// Knockout stays on the real-time timer. Combat already refuses to mend,
	// so HP <= 0 does not stand back up mid-fight.
	if (m_hp <= 0.0f || !InTurnBasedCombat())
	{
		m_sleepTurnsRemaining = 0;
		m_sleepEndsAt = now + 5.0f + static_cast<float>(rand() % 5);
		return;
	}

	// Living spell sleep. Other units' turns must not run out this clock.
	m_sleepTurnsRemaining = RollTurnBasedSleepTurns();
	m_sleepEndsAt = 0.0f;
}

void U7Object::StopSleepTimer()
{
	m_sleepEndsAt = 0.0f;
	m_sleepNextMendCheckAt = 0.0f;
	m_sleepTurnsRemaining = 0;
}

void U7Object::MendWounds(bool mendMana)
{
	if (IsDeathStatus() || GetIsDead())
		return;
	// Exult: poisoned blocks mend; starving blocks mend only while HP > 0.
	if ((m_flags & kObjFlagPoisoned) != 0)
		return;
	if (m_NPCData && m_NPCData->food <= 9 && m_hp > 0.0f
	    && g_Player && g_Player->NPCIDInParty(m_NPCID))
		return;

	float maxHp = m_BaseMaxHP;
	if (m_NPCData && m_NPCData->str > 0)
		maxHp = static_cast<float>(m_NPCData->str);
	if (maxHp < 1.0f)
		maxHp = 1.0f;

	if (m_hp < maxHp)
	{
		m_hp += 1.0f;
		if (m_hp > maxHp)
			m_hp = maxHp;
	}

	if (mendMana)
	{
		float maxMana = m_NPCData ? static_cast<float>(m_NPCData->magic) : 0.0f;
		if (maxMana > 0.0f && m_mana < maxMana)
		{
			m_mana += 1.0f;
			if (m_mana > maxMana)
				m_mana = maxMana;
		}
	}
}

void U7Object::UpdateSleepTimer()
{
	if (m_sleepEndsAt <= 0.0f && m_sleepTurnsRemaining <= 0 && (m_flags & kObjFlagAsleep) == 0)
		return;
	if (IsDeathStatus() || GetIsDead())
	{
		StopSleepTimer();
		return;
	}

	const float now = GetTime();
	const bool inParty = g_Player && g_Player->NPCIDInParty(m_NPCID);

	// While health <= 0, mend toward wake. Do not regenerate during combat —
	// otherwise KO'd enemies stand up mid-fight (especially noticeable in TB).
	if (m_hp <= 0.0f && !g_isCombatMode)
	{
		if (now >= m_sleepNextMendCheckAt)
		{
			m_sleepNextMendCheckAt = now + g_secsPerMinute * 0.5f;
			if (inParty || m_Visible)
			{
				if ((rand() % 6) == 0)
					MendWounds(false);
			}
			else if (m_UnitType == UnitTypes::UNIT_TYPE_NPC && m_NPCData)
			{
				// Exult: off-screen non-party fully restore.
				m_hp = static_cast<float>(std::max(1, static_cast<int>(m_NPCData->str)));
			}
		}
	}

	// Awaken (and any other clear) drops a leftover turn count or clock.
	if ((m_flags & kObjFlagAsleep) == 0)
	{
		if (m_hp >= 1.0f)
			StopSleepTimer();
		return;
	}

	// Living sleeper in turn-based combat waits for their own turn.
	if (m_hp >= 1.0f && InTurnBasedCombat())
	{
		if (m_sleepTurnsRemaining <= 0)
			m_sleepTurnsRemaining = RollTurnBasedSleepTurns();
		m_sleepEndsAt = 0.0f;
		return;
	}

	// Left turn-based combat with turns still banked. Finish on the real-time timer.
	if (m_sleepTurnsRemaining > 0)
	{
		m_sleepTurnsRemaining = 0;
		if (m_sleepEndsAt <= now)
			m_sleepEndsAt = now + 5.0f + static_cast<float>(rand() % 5);
		return;
	}

	// Don't wake someone beaten into unconsciousness until HP >= 1.
	if (m_hp >= 1.0f && (m_sleepEndsAt <= 0.0f || now >= m_sleepEndsAt))
	{
		ClearSleep();
		StopSleepTimer();
		// Knockouts also wake on this timer once they have HP. They do not
		// stand up during a fight, so only the combat case is a sleep spell ending.
		if (g_isCombatMode)
			AnnounceStatusFlag(kObjFlagAsleep, false);
	}
}

U7Object::TurnBasedSleepTick U7Object::TickTurnBasedSleep()
{
	if ((m_flags & kObjFlagAsleep) == 0 || m_hp < 1.0f || IsDeathStatus() || GetIsDead())
		return TurnBasedSleepTick::NotAsleep;

	if (m_sleepTurnsRemaining <= 0)
		m_sleepTurnsRemaining = RollTurnBasedSleepTurns();

	--m_sleepTurnsRemaining;
	if (m_sleepTurnsRemaining > 0)
		return TurnBasedSleepTick::StillAsleep;

	ClearSleep();
	StopSleepTimer();
	return TurnBasedSleepTick::Woke;
}

namespace
{
	bool IsPartyActor(const U7Object* unit)
	{
		if (!unit || unit->m_NPCID < 0)
			return false;
		if (unit->m_NPCID == 0)
			return true;
		return g_Player && g_Player->NPCIDInParty(unit->m_NPCID);
	}

	bool CanBeDanced(U7Object* unit)
	{
		if (!unit || unit->GetIsDead() || unit->IsDeathStatus() || unit->IsKnockedOut())
			return false;
		if (unit->m_isContained)
			return false;
		if (unit->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_NPC
			&& unit->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_MONSTER)
			return false;
		if ((unit->m_flags & kObjFlagAsleep) != 0 || (unit->m_flags & kObjFlagParalyzed) != 0)
			return false;
		const int intelligence = GetCombatIntelligence(unit);
		return intelligence > 5 && intelligence < 25;
	}

	void AssignScheduleActivity(U7Object* npc, int activity)
	{
		if (!npc || npc->m_NPCID < 0)
			return;
		auto it = g_NPCData.find(npc->m_NPCID);
		if (it == g_NPCData.end() || !it->second)
			return;
		it->second->m_currentActivity = activity;
		it->second->m_lastActivity = -1;
		npc->m_currentActivity = static_cast<unsigned int>(activity);
		npc->m_followingSchedule = true;
		npc->m_pathWaypoints.clear();
		npc->m_currentWaypointIndex = 0;
		npc->m_pathfindingPending = false;
		npc->m_isSchedulePath = false;
		npc->m_isMoving = false;
	}

	U7Object* ObjectFromNpcId(int npcId)
	{
		if (npcId == 0)
			return g_Player ? g_Player->GetAvatarObject() : nullptr;
		auto it = g_NPCData.find(npcId);
		if (it == g_NPCData.end() || !it->second)
			return nullptr;
		return GetObjectFromID(it->second->m_objectID);
	}

	constexpr int kDanceSchedule = 4;
	constexpr int kWanderSchedule = 12;
	constexpr int kAttunedSpiritualityFlag = 0x39;
	constexpr float kDanceStepSeconds = 0.4f;

	const char* kDanceBarks[] = {
		"Dance!", "Yeah!", "Huh!", "Oh, yeah!", "I'm bad!", "Boogie!", "Yow!"
	};
}

void U7Object::ApplyDancePose()
{
	static const Vector3 kDirs[8] = {
		{ 0, 0, -1 }, { 1, 0, -1 }, { 1, 0, 0 }, { 1, 0, 1 },
		{ 0, 0, 1 }, { -1, 0, 1 }, { -1, 0, 0 }, { -1, 0, -1 }
	};
	static const NpcAnimAction kPoses[4] = {
		NpcAnimAction::Stand,
		NpcAnimAction::Up,
		NpcAnimAction::Out,
		NpcAnimAction::Stand
	};

	const int dir = m_danceStep & 7;
	m_Angle = static_cast<float>(dir) * 45.0f;
	m_Direction = Vector3Normalize(kDirs[dir]);
	m_npcAnimAction = kPoses[m_danceStep & 3];
	m_npcAnimPlaying = false;
	m_npcAnimLooping = true;
	m_npcAnimPhase = 0;
	m_npcAnimHitFired = true;
}

void U7Object::StartDance()
{
	const float now = GetTime();
	const int ticks = 50 + (rand() % 26);
	const float seconds = static_cast<float>(ticks) * 0.2f;

	m_flags |= kObjFlagInAction;
	m_danceStep = 0;
	m_danceNextStepAt = now + kDanceStepSeconds;
	m_pathWaypoints.clear();
	m_currentWaypointIndex = 0;
	m_pathfindingPending = false;
	m_isSchedulePath = false;
	m_isMoving = false;
	m_combatMoveOrder = false;
	SetDest(m_Pos);
	ApplyDancePose();

	if (InTurnBasedCombat())
	{
		m_danceTurnsRemaining = std::max(1, static_cast<int>(std::lround(seconds / 3.0f)));
		m_danceEndsAt = 0.0f;
	}
	else
	{
		m_danceTurnsRemaining = 0;
		m_danceEndsAt = now + seconds;
	}

	if (GetCombatIntelligence(this) >= 10)
	{
		const int barkTicks = 10 + (rand() % 31);
		m_danceBarkAt = now + static_cast<float>(barkTicks) * 0.2f;
	}
	else
	{
		m_danceBarkAt = 0.0f;
	}

	if (g_SpriteEffectSystem)
		g_SpriteEffectSystem->SpawnOnObject(static_cast<int>(m_ID), 16, 0.0f);

	if (!IsPartyActor(this))
		AssignScheduleActivity(this, kDanceSchedule);
}

void U7Object::StopDance()
{
	if (!IsDancing() && m_danceTurnsRemaining <= 0 && m_danceEndsAt <= 0.0f)
		return;

	const bool wasDancing = IsDancing();
	m_flags &= ~kObjFlagInAction;
	m_danceEndsAt = 0.0f;
	m_danceTurnsRemaining = 0;
	m_danceBarkAt = 0.0f;
	m_danceNextStepAt = 0.0f;
	m_npcAnimAction = NpcAnimAction::Stand;
	m_npcAnimPlaying = false;
	m_npcAnimPhase = 0;

	if (wasDancing && !IsPartyActor(this))
		AssignScheduleActivity(this, kWanderSchedule);
}

void U7Object::UpdateDance()
{
	if (!IsDancing() && m_danceTurnsRemaining <= 0 && m_danceEndsAt <= 0.0f)
		return;

	if (GetIsDead() || IsDeathStatus())
	{
		StopDance();
		return;
	}

	const float now = GetTime();
	if (m_danceBarkAt > 0.0f && now >= m_danceBarkAt)
	{
		m_danceBarkAt = 0.0f;
		if (g_mainState)
		{
			const int which = rand() % 7;
			g_mainState->Bark(this, kDanceBarks[which], 2.5f);
		}
	}

	if (now >= m_danceNextStepAt)
	{
		m_danceStep = (m_danceStep + 1) & 7;
		m_danceNextStepAt = now + kDanceStepSeconds;
	}

	if (InTurnBasedCombat())
	{
		if (m_danceTurnsRemaining <= 0)
		{
			float remaining = m_danceEndsAt - now;
			if (remaining < 0.2f)
				remaining = 0.2f;
			m_danceTurnsRemaining = std::max(1, static_cast<int>(std::lround(remaining / 3.0f)));
			m_danceEndsAt = 0.0f;
		}
		return;
	}

	if (m_danceTurnsRemaining > 0)
	{
		m_danceEndsAt = now + static_cast<float>(m_danceTurnsRemaining) * 3.0f;
		m_danceTurnsRemaining = 0;
	}

	if (m_danceEndsAt <= 0.0f || now >= m_danceEndsAt)
		StopDance();
}

U7Object::TurnBasedDanceTick U7Object::TickTurnBasedDance()
{
	if (!IsDancing())
		return TurnBasedDanceTick::NotDancing;

	if (m_danceTurnsRemaining <= 0)
		m_danceTurnsRemaining = 4;

	--m_danceTurnsRemaining;
	if (m_danceTurnsRemaining > 0)
		return TurnBasedDanceTick::StillDancing;

	StopDance();
	return TurnBasedDanceTick::Stopped;
}

void U7Object::CauseDancing()
{
	const bool partyCaster = IsPartyActor(this);
	const bool attuned = g_ScriptingSystem && g_ScriptingSystem->GetFlag(kAttunedSpiritualityFlag);

	auto tryDance = [](U7Object* unit)
	{
		if (!CanBeDanced(unit))
			return;
		unit->StartDance();
	};

	if (!partyCaster)
	{
		if (attuned || !g_Player)
			return;
		for (int npcId : g_Player->GetPartyMemberIds())
		{
			U7Object* member = ObjectFromNpcId(npcId);
			if (member && member != this)
				tryDance(member);
		}
		return;
	}

	const int tx = static_cast<int>(std::floor(m_Pos.x));
	const int tz = static_cast<int>(std::floor(m_Pos.z));
	const int cx = tx / 16;
	const int cz = tz / 16;
	for (int oz = cz - 2; oz <= cz + 2; ++oz)
	{
		for (int ox = cx - 2; ox <= cx + 2; ++ox)
		{
			if (ox < 0 || oz < 0 || ox >= 192 || oz >= 192)
				continue;
			const std::vector<U7Object*> units = g_chunkObjectMap[ox][oz];
			for (U7Object* unit : units)
			{
				if (!unit || unit == this || IsPartyActor(unit))
					continue;
				const int ux = static_cast<int>(std::floor(unit->m_Pos.x));
				const int uz = static_cast<int>(std::floor(unit->m_Pos.z));
				if (std::max(std::abs(ux - tx), std::abs(uz - tz)) > 25)
					continue;
				tryDance(unit);
			}
		}
	}
}

void U7Object::SetAttackMode(int mode)
{
	if (mode < 0)
		mode = 0;
	m_attackMode = mode;
	if (mode != 7)
		m_fearOppressorId = 0;
}

U7Object* U7Object::FearOppressor() const
{
	if (U7Object* from = GetObjectFromID(m_fearOppressorId))
		return from;
	if (g_Player)
		return g_Player->GetAvatarObject();
	return nullptr;
}

void U7Object::StartFear(int oppressorId)
{
	m_target = 0;
	m_combatPathTargetId = 0;
	m_combatMoveOrder = false;
	m_pathWaypoints.clear();
	m_currentWaypointIndex = 0;
	m_pathfindingPending = false;
	m_isSchedulePath = false;
	m_isMoving = false;
	SetDest(m_Pos);
	SetAttackMode(7);
	m_fearOppressorId = oppressorId;
	if (!IsPartyActor(this))
		AssignScheduleActivity(this, 0);
	NoteCombatLogClause((m_name.empty() ? "Someone" : m_name) + " flees!", YELLOW);
}

void U7Object::UpdateFearFlee()
{
	if (IsDeathStatus() || GetIsDead())
		return;

	U7Object* from = FearOppressor();
	if (!from)
		return;

	m_target = 0;
	m_combatMoveOrder = false;
	m_combatPathTargetId = 0;

	const float dx = m_Pos.x - from->m_Pos.x;
	const float dz = m_Pos.z - from->m_Pos.z;
	const float dist = std::sqrt(dx * dx + dz * dz);
	if (dist >= 16.0f)
	{
		m_pathWaypoints.clear();
		m_currentWaypointIndex = 0;
		m_pathfindingPending = false;
		m_isMoving = false;
		SetDest(m_Pos);
		UpdateMovement();
		return;
	}

	const bool hasPath = !m_pathWaypoints.empty()
		&& m_currentWaypointIndex < static_cast<int>(m_pathWaypoints.size());
	if (hasPath || m_pathfindingPending)
	{
		UpdateMovement();
		return;
	}

	float ax = dx;
	float az = dz;
	if (dist < 0.5f)
	{
		ax = 1.0f;
		az = 0.0f;
	}
	else
	{
		ax /= dist;
		az /= dist;
	}

	float destX = m_Pos.x + ax * 8.0f;
	float destZ = m_Pos.z + az * 8.0f;
	if (destX < 1.0f)
		destX = 1.0f;
	if (destZ < 1.0f)
		destZ = 1.0f;
	if (destX > 3070.0f)
		destX = 3070.0f;
	if (destZ > 3070.0f)
		destZ = 3070.0f;

	const Vector3 dest{ destX, m_Pos.y, destZ };
	if (g_pathfindingSystem)
		ApplyPathWaypoints(g_pathfindingSystem->FindMonsterChasePath(m_Pos, dest, this));
	if (m_pathWaypoints.empty())
		SetDest(dest);
	UpdateMovement();
}

void U7Object::CauseFear()
{
	U7Object* avatar = g_Player ? g_Player->GetAvatarObject() : nullptr;
	if (!avatar)
		return;
	const int oppressorId = static_cast<int>(avatar->m_ID);

	auto tryFear = [&](U7Object* unit)
	{
		if (!unit || unit == this || unit->m_isContained)
			return;
		if (unit->GetIsDead() || unit->IsDeathStatus())
			return;
		if (unit->m_UnitType != UnitTypes::UNIT_TYPE_NPC
			&& unit->m_UnitType != UnitTypes::UNIT_TYPE_MONSTER)
			return;
		if ((unit->m_flags & kObjFlagInvisible) != 0)
			return;
		if (IsPartyActor(unit))
			return;
		if (GetCombatIntelligence(unit) <= 5)
			return;
		unit->StartFear(oppressorId);
	};

	const int tx = static_cast<int>(std::floor(m_Pos.x));
	const int tz = static_cast<int>(std::floor(m_Pos.z));
	const int cx = tx / 16;
	const int cz = tz / 16;
	for (int oz = cz - 2; oz <= cz + 2; ++oz)
	{
		for (int ox = cx - 2; ox <= cx + 2; ++ox)
		{
			if (ox < 0 || oz < 0 || ox >= 192 || oz >= 192)
				continue;
			const std::vector<U7Object*> units = g_chunkObjectMap[ox][oz];
			for (U7Object* unit : units)
			{
				if (!unit)
					continue;
				const int ux = static_cast<int>(std::floor(unit->m_Pos.x));
				const int uz = static_cast<int>(std::floor(unit->m_Pos.z));
				if (std::max(std::abs(ux - tx), std::abs(uz - tz)) > 25)
					continue;
				tryFear(unit);
			}
		}
	}
}

// Sixth Circle timers. delayed_execute_usecode_array scales ticks by 0.05s.
// These durations use the real usecode step, 0.20s.
namespace
{
	constexpr float kUsecodeStepSec = 0.2f;
	constexpr int kMagicStormFlag = 0x2ED;

	struct PendingClone
	{
		int targetId = 0;
		float at = 0.0f;
	};

	struct PendingRing
	{
		int x = 0;
		int z = 0;
		float y = 0.0f;
		float at = 0.0f;
	};

	std::vector<PendingClone> g_pendingClones;
	std::vector<PendingRing> g_pendingRings;
	int g_stormCasterId = 0;
	float g_stormEndsAt = 0.0f;
	float g_stormNextStrike = 0.0f;

	int InclusiveRoll(int lo, int hi)
	{
		if (hi < lo)
			std::swap(lo, hi);
		if (g_NonVitalRNG)
			return g_NonVitalRNG->RandomRange(static_cast<unsigned int>(lo), static_cast<unsigned int>(hi));
		const int span = (hi - lo) + 1;
		return lo + (span > 0 ? (rand() % span) : 0);
	}

	bool IsLivingCreature(U7Object* unit)
	{
		if (!unit || unit->m_isContained || unit->GetIsDead() || unit->IsDeathStatus())
			return false;
		return unit->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC
			|| unit->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_MONSTER;
	}

	bool SurfaceNear(int tx, int tz, float prefer, float maxDelta, float& outY)
	{
		if (!g_pathfindingSystem)
			return false;
		if (tx < 0 || tz < 0 || tx >= 3072 || tz >= 3072)
			return false;
		const std::vector<float> heights = g_pathfindingSystem->GetWalkableSurfaceHeights(tx, tz);
		if (heights.empty())
			return false;
		float best = heights[0];
		float bestDelta = std::fabs(best - prefer);
		for (float h : heights)
		{
			const float delta = std::fabs(h - prefer);
			if (delta < bestDelta)
			{
				bestDelta = delta;
				best = h;
			}
		}
		if (bestDelta > maxDelta)
			return false;
		outY = best;
		return true;
	}

	U7Object* MakeSpellField(int shape, int tx, int tz, float y)
	{
		if (tx < 0 || tz < 0 || tx >= 3072 || tz >= 3072)
			return nullptr;
		const int id = static_cast<int>(GetNextID());
		U7Object* obj = AddObject(shape, 0, id, tx + 0.5f, y, tz + 0.5f);
		if (!obj)
			return nullptr;
		obj->m_UnitType = U7Object::UnitTypes::UNIT_TYPE_OBJECT;
		obj->m_Visible = true;
		obj->m_ShouldDraw = true;
		return obj;
	}

	bool AlreadyListed(const std::vector<U7Object*>& list, const U7Object* unit)
	{
		return std::find(list.begin(), list.end(), unit) != list.end();
	}

	// Func0934. A party caster hits non-party creatures within dist.
	// Anyone else hits the whole party, with no distance check.
	void CollectOffensiveTargets(U7Object* caster, int dist, std::vector<U7Object*>& out)
	{
		if (!caster)
			return;

		if (!IsPartyActor(caster))
		{
			if (!g_Player)
				return;
			for (int npcId : g_Player->GetPartyMemberIds())
			{
				U7Object* member = ObjectFromNpcId(npcId);
				if (!IsLivingCreature(member) || member == caster)
					continue;
				if (AlreadyListed(out, member))
					continue;
				out.push_back(member);
			}
			return;
		}

		const int tx = static_cast<int>(std::floor(caster->m_Pos.x));
		const int tz = static_cast<int>(std::floor(caster->m_Pos.z));
		const int radius = (dist / 16) + 1;
		const int cx = tx / 16;
		const int cz = tz / 16;
		for (int oz = cz - radius; oz <= cz + radius; ++oz)
		{
			for (int ox = cx - radius; ox <= cx + radius; ++ox)
			{
				if (ox < 0 || oz < 0 || ox >= 192 || oz >= 192)
					continue;
				const std::vector<U7Object*> units = g_chunkObjectMap[ox][oz];
				for (U7Object* unit : units)
				{
					if (!IsLivingCreature(unit) || unit == caster || IsPartyActor(unit))
						continue;
					if ((unit->m_flags & kObjFlagInvisible) != 0)
						continue;
					if (AlreadyListed(out, unit))
						continue;
					const int ux = static_cast<int>(std::floor(unit->m_Pos.x));
					const int uz = static_cast<int>(std::floor(unit->m_Pos.z));
					if (std::max(std::abs(ux - tx), std::abs(uz - tz)) > dist)
						continue;
					out.push_back(unit);
				}
			}
		}
	}

	struct CloneSpot
	{
		int x = 0;
		int z = 0;
		float y = 0.0f;
	};

	bool FindCloneSpot(const U7Object* src, CloneSpot& out)
	{
		if (!src)
			return false;
		const int sx = static_cast<int>(std::floor(src->m_Pos.x));
		const int sz = static_cast<int>(std::floor(src->m_Pos.z));
		std::vector<CloneSpot> spots;
		for (int r = 1; r <= 3; ++r)
		{
			for (int dz = -r; dz <= r; ++dz)
			{
				for (int dx = -r; dx <= r; ++dx)
				{
					if (std::max(std::abs(dx), std::abs(dz)) != r)
						continue;
					const int tx = sx + dx;
					const int tz = sz + dz;
					float y = 0.0f;
					if (!SurfaceNear(tx, tz, src->m_Pos.y, 2.0f, y))
						continue;
					spots.push_back(CloneSpot{ tx, tz, y });
				}
			}
		}
		if (spots.empty())
			return false;
		out = spots[InclusiveRoll(0, static_cast<int>(spots.size()) - 1)];
		return true;
	}

	void EnrollAlly(U7Object* spawned)
	{
		if (!spawned)
			return;
		spawned->m_Team = 2;
		spawned->m_currentActivity = 0;
		spawned->m_target = 0;
		spawned->m_combatPathTargetId = 0;
		if (g_isCombatMode && g_mainState)
			g_mainState->EnsureCombatParticipant(static_cast<int>(spawned->m_ID), false);
	}

	void SpawnCloneNow(int targetId)
	{
		U7Object* src = GetObjectFromID(targetId);
		if (!IsLivingCreature(src) || !g_mainState)
			return;

		CloneSpot spot;
		if (!FindCloneSpot(src, spot))
			return;

		const int shape = src->m_shapeData ? src->m_shapeData->m_shape : src->m_ObjectType;
		int monsterType = -1;
		for (int i = 0; i < static_cast<int>(g_monsterData.size()); ++i)
		{
			if (static_cast<int>(g_monsterData[i].m_shape) == shape)
			{
				monsterType = i;
				break;
			}
		}

		U7Object* clone = nullptr;
		if (monsterType >= 0)
		{
			const int id = g_mainState->SpawnMonster(monsterType, spot.x, static_cast<int>(std::lround(spot.y)), spot.z);
			clone = GetObjectFromID(id);
			if (!clone)
				return;
			clone->SetPos(Vector3{ spot.x + 0.5f, spot.y, spot.z + 0.5f });
		}
		else
		{
			float hp = src->m_BaseMaxHP;
			if (src->m_NPCData && src->m_NPCData->str > 0)
				hp = static_cast<float>(src->m_NPCData->str);
			else if (g_Player && g_Player->GetAvatarObject() == src)
				hp = static_cast<float>(g_Player->GetStr());
			if (hp < 1.0f)
				hp = 1.0f;

			const int id = static_cast<int>(GetNextID());
			clone = AddObject(shape, 0, id, spot.x + 0.5f, spot.y, spot.z + 0.5f);
			if (!clone)
				return;
			clone->m_UnitType = U7Object::UnitTypes::UNIT_TYPE_MONSTER;
			clone->m_NPCID = -1;
			clone->m_NPCData = nullptr;
			clone->m_hp = hp;
			clone->m_BaseMaxHP = hp;
			clone->m_BaseAttack = src->m_BaseAttack;
			if (src->m_NPCData)
				clone->m_combat = src->m_NPCData->combat;
			else
				clone->m_combat = src->m_combat;
			clone->MonsterInit();
			clone->m_NPCID = -1;
			clone->m_NPCData = nullptr;
			clone->m_UnitType = U7Object::UnitTypes::UNIT_TYPE_MONSTER;
			clone->m_hp = hp;
			clone->m_BaseMaxHP = hp;
			clone->SetPos(Vector3{ spot.x + 0.5f, spot.y, spot.z + 0.5f });
		}

		clone->m_Direction = src->m_Direction;
		clone->m_Angle = src->m_Angle;
		EnrollAlly(clone);
	}

	void DrainPendingClones(float now)
	{
		size_t i = 0;
		while (i < g_pendingClones.size())
		{
			if (now < g_pendingClones[i].at)
			{
				++i;
				continue;
			}
			const int targetId = g_pendingClones[i].targetId;
			g_pendingClones.erase(g_pendingClones.begin() + static_cast<std::ptrdiff_t>(i));
			SpawnCloneNow(targetId);
		}
	}

	void DrainPendingRings(float now)
	{
		size_t i = 0;
		while (i < g_pendingRings.size())
		{
			if (now < g_pendingRings[i].at)
			{
				++i;
				continue;
			}
			const PendingRing ring = g_pendingRings[i];
			g_pendingRings.erase(g_pendingRings.begin() + static_cast<std::ptrdiff_t>(i));
			U7Object* field = MakeSpellField(kFireFieldShape, ring.x, ring.z, ring.y);
			if (!field)
				continue;
			// 30 + roll(1, 5) usecode ticks. Rolled when the segment appears.
			const float life = (30.0f + static_cast<float>(InclusiveRoll(1, 5))) * kUsecodeStepSec;
			field->ArmFireField(life);
		}
	}

	void StopMagicStorm()
	{
		g_stormCasterId = 0;
		g_stormEndsAt = 0.0f;
		g_stormNextStrike = 0.0f;
		if (g_ScriptingSystem)
			g_ScriptingSystem->SetFlag(kMagicStormFlag, false);
		if (g_WeatherSystem)
			g_WeatherSystem->SetWeather(0, 0, false, Vector3{ 0, 0, 0 }, -1, -1);
	}

	void StrikeMagicStorm()
	{
		U7Object* caster = GetObjectFromID(g_stormCasterId);
		if (!caster)
		{
			StopMagicStorm();
			return;
		}

		std::vector<U7Object*> targets;
		CollectOffensiveTargets(caster, 45, targets);
		if (targets.empty())
			return;

		U7Object* victim = targets[InclusiveRoll(0, static_cast<int>(targets.size()) - 1)];
		if (!IsLivingCreature(victim))
			return;

		if (g_SpriteEffectSystem)
			g_SpriteEffectSystem->Spawn(17, victim->m_Pos);
		if (g_SoundSystem)
			g_SoundSystem->PlaySound(BuildU7SfxPath(62));
		if (g_WeatherSystem)
			g_WeatherSystem->PulseLightningFlash();

		// Join before the log. EnterCombatMode clears the console.
		PullEnemyIntoCombat(caster);
		PullEnemyIntoCombat(victim);

		// Exult lightning: 1 + rand()%12. Armor is not applied. No miss roll.
		const int hits = InclusiveRoll(1, 12);
		const std::string name = victim->m_name.empty() ? "Someone" : victim->m_name;
		const bool partyVictim = victim->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC
			&& g_Player
			&& g_Player->NPCIDInParty(victim->m_NPCID);
		AddCombatLogString(
			name + " takes " + std::to_string(hits) + " damage from lightning!",
			partyVictim ? RED : WHITE);
		ApplyCombatDamage(victim, static_cast<float>(hits), nullptr);
	}

	void PushStumble(std::vector<U7Object::UsecodeScriptElem>& code, int roll)
	{
		auto three = [&](int a, int b, int c)
		{
			code.push_back(a);
			code.push_back(b);
			code.push_back(c);
		};
		auto faced = [&](int pose)
		{
			// (byte)0x30 + roll(0, 3) * 2, then masked to a facing. N E S W.
			const int dir = InclusiveRoll(0, 3) * 2;
			code.push_back(0x59);
			code.push_back(dir);
			code.push_back(pose);
			code.push_back(0x61);
		};

		switch (roll)
		{
		case 0: three(0x6D, 0x6C, 0x61); break; // kneel, bow, stand
		case 1: three(0x6D, 0x61, 0x61); break; // kneel, stand, stand
		case 2: three(0x6C, 0x6E, 0x61); break; // bow, sleep, stand
		case 3: three(0x61, 0x61, 0x61); break; // stand, stand, stand
		case 4: three(0x6D, 0x64, 0x61); break; // kneel, ready, stand
		case 5: three(0x64, 0x6D, 0x61); break; // ready, kneel, stand
		case 6: faced(0x6C); break;             // face, bow, stand
		case 7: faced(0x6D); break;             // face, kneel, stand
		case 8: faced(0x64); break;             // face, ready, stand
		default: break;
		}
	}

	void ArmHazardShape(U7Object* obj, int wantShape)
	{
		if (!obj)
			return;
		const int shape = obj->m_shapeData ? obj->m_shapeData->m_shape : obj->m_ObjectType;
		if (shape != wantShape)
			return;
		obj->m_UnitType = U7Object::UnitTypes::UNIT_TYPE_OBJECT;
		obj->m_Visible = true;
		obj->m_ShouldDraw = true;
		obj->m_fireFieldNextPulse = 0.0f;
	}

	struct PendingGold
	{
		int leadId = 0;
		float at = 0.0f;
	};

	struct PendingBlast
	{
		int casterId = 0;
		int markerId = 0;
		float attackAt = 0.0f;
		float removeAt = 0.0f;
		bool attacked = false;
	};

	struct PendingCharm
	{
		int casterId = 0;
		int targetId = 0;
		float at = 0.0f;
	};

	struct PendingMight
	{
		int targetId = 0;
		float at = 0.0f;
	};

	struct EnergyMist
	{
		int casterId = 0;
		int targetId = 0;
		float x = 0.0f;
		float y = 0.0f;
		float z = 0.0f;
		float endsAt = 0.0f;
		float nextDamage = 0.0f;
		float nextStep = 0.0f;
		float nextPuff = 0.0f;
		int radius = 2;
		// 0 follows the wall clock. Above 0, one strike per combatant turn.
		int turnsRemaining = 0;
		// Turn-based: the cloud has reached its enemy and copies their position.
		bool seated = false;
		// Energy Mist is 399 / sprite 13 / sfx 65. Death Vortex is 639 / 8 / 63.
		int weaponShape = 399;
		int sprite = 13;
		int sfx = 65;
		const char* hitNoun = "the mist";
	};

	// Real-time pulses once a second for 20 seconds. Turn-based gets the same count.
	constexpr int kEnergyMistTurnBudget = 20;

	std::vector<PendingGold> g_pendingGold;
	std::vector<PendingBlast> g_pendingBlasts;
	std::vector<PendingCharm> g_pendingCharms;
	struct PendingDeath
	{
		int casterId = 0;
		int targetId = 0;
		float at = 0.0f;
	};

	std::vector<PendingMight> g_pendingMights;
	std::vector<PendingDeath> g_pendingDeaths;
	std::vector<EnergyMist> g_energyMists;
	// Armageddon's kill waits out the gesture. 0 means none is scheduled.
	int g_armageddonCasterId = 0;
	float g_armageddonAt = 0.0f;
	// Time Stop outside turn-based combat. Exult stores an absolute tick. 0 means running.
	float g_timeStopUntil = 0.0f;
	// Turn-based Time Stop. Object id -> enemy turns still skipped. Empty means running.
	std::unordered_map<int, int> g_timeStopTurns;

	int ChebyshevXZ(const U7Object* a, const U7Object* b)
	{
		if (!a || !b)
			return 0;
		const int dx = std::abs(static_cast<int>(std::floor(a->m_Pos.x)) - static_cast<int>(std::floor(b->m_Pos.x)));
		const int dz = std::abs(static_cast<int>(std::floor(a->m_Pos.z)) - static_cast<int>(std::floor(b->m_Pos.z)));
		return std::max(dx, dz);
	}

	int AvatarAlignment()
	{
		auto it = g_NPCData.find(0);
		if (it == g_NPCData.end() || !it->second)
			return 0;
		return (static_cast<int>(it->second->status) >> 2) & 3;
	}

	void ApplySpellShape(U7Object* object, int shape)
	{
		if (!object || shape < 0 || shape >= 1024)
			return;
		if (g_mainState && g_mainState->m_barkObject == object)
			g_mainState->ClearBarks();
		int currentFrame = object->m_Frame;
		if (currentFrame < 0 || currentFrame >= 32)
			currentFrame = 0;
		object->m_ObjectType = shape;
		object->m_Frame = currentFrame;
		object->m_shapeData = &g_shapeTable[shape][currentFrame];
		object->m_objectData = &g_objectDataTable[shape];
		if (object->m_shapeData)
			object->m_drawType = object->m_shapeData->GetDrawType();
		if (object->GetAnimMode() != ObjectAnimMode::Scripted)
			object->ApplyDefaultAnimMode();
		object->SetPos(object->GetPos());
		NotifyPathfindingGridUpdate(static_cast<int>(object->m_Pos.x), static_cast<int>(object->m_Pos.z), 4);
	}

	void TransmuteLeadNow(int leadId)
	{
		U7Object* obj = GetObjectFromID(leadId);
		if (!obj || obj->GetIsDead())
			return;
		const int shape = obj->m_shapeData ? obj->m_shapeData->m_shape : obj->m_ObjectType;
		if (shape != 915)
			return;

		// Quantity shapes store the count in quality. Lead (915) and gold
		// nuggets (645) are breakable shapes, so the original set_item_quantity
		// refuses them. The *10 is still clamped here if a stack ever qualifies.
		int qty = 1;
		if (shape >= 0 && shape < 1024 && g_objectDataTable[shape].m_shapeType == 3)
		{
			qty = obj->m_Quality & 0x7f;
			if (qty <= 0)
				qty = 1;
			qty *= 10;
			if (qty > 127)
				qty = 127;
		}
		ApplySpellShape(obj, 645);
		const int gold = obj->m_shapeData ? obj->m_shapeData->m_shape : obj->m_ObjectType;
		if (gold >= 0 && gold < 1024 && g_objectDataTable[gold].m_shapeType == 3)
			obj->m_Quality = (qty & 0x7f) | (obj->m_Quality & 0x80);
	}

	void RemoveBlastMarker(int markerId)
	{
		U7Object* marker = GetObjectFromID(markerId);
		if (!marker || marker->GetIsDead())
			return;
		marker->m_ShouldDraw = false;
		marker->m_Visible = false;
		marker->SetIsDead(true);
	}

	void FireDelayedBlastNow(const PendingBlast& blast)
	{
		U7Object* marker = GetObjectFromID(blast.markerId);
		U7Object* caster = GetObjectFromID(blast.casterId);
		if (!marker || marker->GetIsDead())
			return;
		bool launched = false;
		if (caster && !caster->GetIsDead() && !caster->IsDeathStatus())
		{
			caster->SetUsecodeAttackTarget(static_cast<int>(marker->m_ID), 621);
			launched = caster->FireUsecodeAttack();
		}
		if (!launched)
			DetonateDelayedBlast(caster, marker);
	}

	void MassCharmOne(U7Object* caster, U7Object* target)
	{
		if (!IsLivingCreature(target))
			return;
		const int npc = target->m_NPCID;
		// Usecode skips Anmanivas (-217), Foranamo (-218), and the Avatar (-356).
		if (npc == 0 || npc == 217 || npc == 218)
			return;
		if (AvatarAlignment() != 0)
			target->ApplyCharm(caster);
		else
			target->EndCharm(true);
	}

	int MistRadiusTiles(int sprite)
	{
		if (sprite >= 0 && sprite < static_cast<int>(g_spriteTable.size()))
		{
			const auto& frames = g_spriteTable[static_cast<size_t>(sprite)];
			if (!frames.empty())
			{
				const int fr = static_cast<int>(frames.size()) / 4;
				const int idx = std::min(fr, static_cast<int>(frames.size()) - 1);
				const int radius = frames[static_cast<size_t>(idx)].width / 16;
				if (radius > 0)
					return radius;
			}
		}
		return 2;
	}

	bool IsMistEnemy(U7Object* unit)
	{
		return IsLivingCreature(unit)
			&& !IsPartyActor(unit)
			&& unit->m_Team == 1
			&& !unit->IsInvisible();
	}

	U7Object* RetargetMist(EnergyMist& mist, bool skipInvisible = false)
	{
		U7Object* best = nullptr;
		int bestDist = 31;
		for (const auto& entry : g_objectList)
		{
			U7Object* unit = entry.second.get();
			if (!IsLivingCreature(unit) || IsPartyActor(unit) || unit->m_Team != 1)
				continue;
			if (skipInvisible && unit->IsInvisible())
				continue;
			const int dx = std::abs(static_cast<int>(std::floor(unit->m_Pos.x)) - static_cast<int>(std::floor(mist.x)));
			const int dz = std::abs(static_cast<int>(std::floor(unit->m_Pos.z)) - static_cast<int>(std::floor(mist.z)));
			const int dist = std::max(dx, dz);
			if (dist > 30 || dist >= bestDist)
				continue;
			bestDist = dist;
			best = unit;
		}
		mist.targetId = best ? static_cast<int>(best->m_ID) : 0;
		return best;
	}

	void StepMistToward(EnergyMist& mist, float destX, float destY, float destZ)
	{
		auto stepAxis = [](float& pos, float dest)
		{
			const float delta = dest - pos;
			if (std::fabs(delta) >= 1.0f)
				pos += (delta > 0.0f) ? 1.0f : -1.0f;
		};
		stepAxis(mist.x, destX);
		stepAxis(mist.y, destY);
		stepAxis(mist.z, destZ);
	}

	void StepEnergyMist(EnergyMist& mist)
	{
		U7Object* target = GetObjectFromID(mist.targetId);
		if (!IsLivingCreature(target))
			target = RetargetMist(mist);
		if (!target)
			return;
		StepMistToward(mist, target->m_Pos.x, target->m_Pos.y, target->m_Pos.z);
	}

	bool MistHasReached(const EnergyMist& mist, const U7Object* target)
	{
		if (!target)
			return false;
		const float dx = std::fabs(mist.x - target->m_Pos.x);
		const float dy = std::fabs(mist.y - target->m_Pos.y);
		const float dz = std::fabs(mist.z - target->m_Pos.z);
		return dx < 1.0f && dy < 1.0f && dz < 1.0f;
	}

	// Walk toward the locked enemy. Once there, copy their position so a move
	// carries the cloud. A dead enemy waits for the next turn to choose another.
	void RideEnergyMist(EnergyMist& mist, float now)
	{
		U7Object* target = GetObjectFromID(mist.targetId);
		if (!IsMistEnemy(target))
		{
			mist.seated = false;
			return;
		}
		if (mist.seated || MistHasReached(mist, target))
		{
			mist.seated = true;
			mist.x = target->m_Pos.x;
			mist.y = target->m_Pos.y;
			mist.z = target->m_Pos.z;
			return;
		}
		if (now < mist.nextStep)
			return;
		StepMistToward(mist, target->m_Pos.x, target->m_Pos.y, target->m_Pos.z);
		mist.nextStep = now + 0.1f;
		if (MistHasReached(mist, target))
		{
			mist.seated = true;
			mist.x = target->m_Pos.x;
			mist.y = target->m_Pos.y;
			mist.z = target->m_Pos.z;
		}
	}

	void DamageMistVictim(EnergyMist& mist, U7Object* victim)
	{
		if (!IsLivingCreature(victim))
			return;
		U7Object* caster = GetObjectFromID(mist.casterId);
		if (caster && (caster->GetIsDead() || caster->IsDeathStatus()))
			caster = nullptr;

		const int hits = FigureCombatHitPoints(caster, victim, mist.weaponShape, -1);
		if (hits > 0)
		{
			const std::string name = victim->m_name.empty() ? "Someone" : victim->m_name;
			const char* noun = mist.hitNoun ? mist.hitNoun : "the mist";
			AddCombatLogString(
				name + " takes " + std::to_string(hits) + " damage from " + noun + "!",
				WHITE);
			ApplyCombatDamage(victim, static_cast<float>(hits), caster);
		}
		else if (caster)
		{
			victim->NotifyAttackedBy(caster);
		}
	}

	void DamageEnergyMist(EnergyMist& mist)
	{
		std::vector<U7Object*> victims;
		for (const auto& entry : g_objectList)
		{
			U7Object* unit = entry.second.get();
			if (!IsLivingCreature(unit) || IsPartyActor(unit) || unit->IsInvisible())
				continue;
			const int dx = std::abs(static_cast<int>(std::floor(unit->m_Pos.x)) - static_cast<int>(std::floor(mist.x)));
			const int dz = std::abs(static_cast<int>(std::floor(unit->m_Pos.z)) - static_cast<int>(std::floor(mist.z)));
			const int dy = std::abs(static_cast<int>(std::floor(unit->m_Pos.y)) - static_cast<int>(std::floor(mist.y)));
			if (std::max(dx, std::max(dz, dy)) > mist.radius)
				continue;
			victims.push_back(unit);
		}

		for (U7Object* victim : victims)
			DamageMistVictim(mist, victim);
	}

	// One enemy, one hit. The cloud keeps its place and walks to a new enemy.
	void StrikeEnergyMistTurn(EnergyMist& mist)
	{
		U7Object* victim = GetObjectFromID(mist.targetId);
		if (!IsMistEnemy(victim))
			victim = RetargetMist(mist, true);
		if (!victim)
		{
			mist.seated = false;
			return;
		}

		const int victimId = static_cast<int>(victim->m_ID);
		if (mist.targetId != victimId)
			mist.seated = false;
		mist.targetId = victimId;
		const float now = GetTime();
		if (g_SpriteEffectSystem)
			g_SpriteEffectSystem->Spawn(mist.sprite, Vector3{ mist.x, mist.y, mist.z });
		mist.nextPuff = now + 0.2f;
		if (mist.nextStep <= 0.0f)
			mist.nextStep = now;
		if (g_SoundSystem && mist.sfx >= 0)
			g_SoundSystem->PlaySound(BuildU7SfxPath(mist.sfx));
		DamageMistVictim(mist, victim);
	}

	void DrainPendingGold(float now)
	{
		size_t i = 0;
		while (i < g_pendingGold.size())
		{
			if (now < g_pendingGold[i].at)
			{
				++i;
				continue;
			}
			const int leadId = g_pendingGold[i].leadId;
			g_pendingGold.erase(g_pendingGold.begin() + static_cast<std::ptrdiff_t>(i));
			TransmuteLeadNow(leadId);
		}
	}

	void DrainPendingBlasts(float now)
	{
		size_t i = 0;
		while (i < g_pendingBlasts.size())
		{
			PendingBlast& blast = g_pendingBlasts[i];
			if (!blast.attacked && now >= blast.attackAt)
			{
				blast.attacked = true;
				FireDelayedBlastNow(blast);
			}
			if (now >= blast.removeAt)
			{
				const int markerId = blast.markerId;
				g_pendingBlasts.erase(g_pendingBlasts.begin() + static_cast<std::ptrdiff_t>(i));
				RemoveBlastMarker(markerId);
				continue;
			}
			++i;
		}
	}

	void DrainPendingCharms(float now)
	{
		size_t i = 0;
		while (i < g_pendingCharms.size())
		{
			if (now < g_pendingCharms[i].at)
			{
				++i;
				continue;
			}
			const PendingCharm pending = g_pendingCharms[i];
			g_pendingCharms.erase(g_pendingCharms.begin() + static_cast<std::ptrdiff_t>(i));
			MassCharmOne(GetObjectFromID(pending.casterId), GetObjectFromID(pending.targetId));
		}
	}

	void DrainPendingMights(float now)
	{
		size_t i = 0;
		while (i < g_pendingMights.size())
		{
			if (now < g_pendingMights[i].at)
			{
				++i;
				continue;
			}
			const int targetId = g_pendingMights[i].targetId;
			g_pendingMights.erase(g_pendingMights.begin() + static_cast<std::ptrdiff_t>(i));
			if (U7Object* target = GetObjectFromID(targetId))
				target->ApplyMight();
		}
	}

	void UpdateEnergyMists(float now)
	{
		size_t i = 0;
		while (i < g_energyMists.size())
		{
			EnergyMist& mist = g_energyMists[i];
			// Turn-based life is turnsRemaining. endsAt is 0. The clock may walk
			// the cloud, and it must not strike or delete it between turns.
			if (mist.turnsRemaining > 0)
			{
				RideEnergyMist(mist, now);
				if (g_SpriteEffectSystem && now >= mist.nextPuff)
				{
					g_SpriteEffectSystem->Spawn(mist.sprite, Vector3{ mist.x, mist.y, mist.z });
					mist.nextPuff = now + 0.2f;
				}
				++i;
				continue;
			}
			if (now >= mist.endsAt)
			{
				g_energyMists.erase(g_energyMists.begin() + static_cast<std::ptrdiff_t>(i));
				continue;
			}
			if (now >= mist.nextStep)
			{
				StepEnergyMist(mist);
				mist.nextStep = now + 0.1f;
			}
			if (g_SpriteEffectSystem && now >= mist.nextPuff)
			{
				g_SpriteEffectSystem->Spawn(mist.sprite, Vector3{ mist.x, mist.y, mist.z });
				mist.nextPuff = now + 0.2f;
			}
			if (now >= mist.nextDamage)
			{
				if (g_SoundSystem && mist.sfx >= 0)
					g_SoundSystem->PlaySound(BuildU7SfxPath(mist.sfx));
				DamageEnergyMist(mist);
				mist.nextDamage = now + 1.0f;
			}
			++i;
		}
	}

	void ResolveMassDeath(int casterId, int targetId)
	{
		U7Object* victim = GetObjectFromID(targetId);
		if (!IsLivingCreature(victim))
			return;
		if (victim->IsDeathSafe())
			return;

		U7Object* caster = GetObjectFromID(casterId);
		if (caster && (caster->GetIsDead() || caster->IsDeathStatus()))
			caster = nullptr;

		const int hp = static_cast<int>(victim->m_hp);
		if (hp > 2)
			ApplyCombatDamage(victim, static_cast<float>(hp - 2), caster);
		if (!IsLivingCreature(victim))
			return;
		ApplyCombatDamage(victim, 50.0f, caster);
		if (!victim->GetIsDead() && !victim->IsDeathStatus())
			victim->ApplyDeath();
	}

	void DrainPendingDeaths(float now)
	{
		size_t i = 0;
		while (i < g_pendingDeaths.size())
		{
			if (now < g_pendingDeaths[i].at)
			{
				++i;
				continue;
			}
			const PendingDeath pending = g_pendingDeaths[i];
			g_pendingDeaths.erase(g_pendingDeaths.begin() + static_cast<std::ptrdiff_t>(i));
			ResolveMassDeath(pending.casterId, pending.targetId);
		}
	}

	int ObjectShape(const U7Object* unit)
	{
		if (!unit)
			return -1;
		if (unit->m_shapeData)
			return unit->m_shapeData->m_shape;
		return unit->m_ObjectType;
	}

	// shape_info actor flag armageddon_safe: Lord British 466, Batlin 403 and 482.
	// The Avatar is npc 0 and is outside the original loop.
	bool SurvivesArmageddon(const U7Object* unit)
	{
		if (!unit)
			return true;
		if (unit->m_NPCID == 0)
			return true;
		const int shape = ObjectShape(unit);
		return shape == 466 || shape == 403 || shape == 482;
	}

	bool UnitOnScreen(const U7Object* unit)
	{
		if (!unit)
			return false;
		const Vector2 screen = GetWorldToScreen(unit->m_Pos, g_camera);
		const float w = static_cast<float>(GetScreenWidth());
		const float h = static_cast<float>(GetScreenHeight());
		return screen.x >= 0.0f && screen.y >= 0.0f && screen.x < w && screen.y < h;
	}

	void RunArmageddonNow()
	{
		U7Object* caster = GetObjectFromID(g_armageddonCasterId);
		if (caster && g_mainState && !caster->GetIsDead() && !caster->IsDeathStatus())
			g_mainState->Bark(caster, "In Corp Hur Tym", 2.5f);
		StartEarthquake(40);

		static const char* kScreams[] = { "Aiiiieee!", "Noooo!", "#!?*#%!" };
		std::vector<U7Object*> npcs;
		for (const auto& entry : g_NPCData)
		{
			if (entry.first == 0)
				continue;
			U7Object* npc = ObjectFromNpcId(entry.first);
			if (!IsLivingCreature(npc) || SurvivesArmageddon(npc))
				continue;
			npcs.push_back(npc);
		}
		for (U7Object* npc : npcs)
		{
			const bool onScreen = UnitOnScreen(npc);
			const int scream = InclusiveRoll(0, 2);
			npc->ApplyDeath(true);
			if (onScreen && g_mainState)
				g_mainState->Bark(npc, kScreams[scream], 2.0f);
		}

		U7Object* center = (g_Player && g_Player->GetAvatarObject())
			? g_Player->GetAvatarObject() : caster;
		if (center)
		{
			const int tx = static_cast<int>(std::floor(center->m_Pos.x));
			const int tz = static_cast<int>(std::floor(center->m_Pos.z));
			const int cx = tx / 16;
			const int cz = tz / 16;
			std::vector<U7Object*> monsters;
			for (int oz = cz - 3; oz <= cz + 3; ++oz)
			{
				for (int ox = cx - 3; ox <= cx + 3; ++ox)
				{
					if (ox < 0 || oz < 0 || ox >= 192 || oz >= 192)
						continue;
					const std::vector<U7Object*> units = g_chunkObjectMap[ox][oz];
					for (U7Object* unit : units)
					{
						if (!unit || unit->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_MONSTER)
							continue;
						if (!IsLivingCreature(unit) || SurvivesArmageddon(unit))
							continue;
						if (AlreadyListed(monsters, unit))
							continue;
						const int ux = static_cast<int>(std::floor(unit->m_Pos.x));
						const int uz = static_cast<int>(std::floor(unit->m_Pos.z));
						if (std::max(std::abs(ux - tx), std::abs(uz - tz)) > 40)
							continue;
						monsters.push_back(unit);
					}
				}
			}
			for (U7Object* monster : monsters)
				monster->ApplyDeath(true);
		}

		if (g_ScriptingSystem)
			g_ScriptingSystem->SetFlag(0x1E, true);
	}

	void DrainArmageddon(float now)
	{
		if (g_armageddonAt <= 0.0f || now < g_armageddonAt)
			return;
		g_armageddonAt = 0.0f;
		RunArmageddonNow();
	}
}

bool TimeIsStopped()
{
	if (g_timeStopUntil <= 0.0f)
		return false;
	if (GetTime() >= g_timeStopUntil)
	{
		g_timeStopUntil = 0.0f;
		AddCombatLogString("Time resumes.", SKYBLUE);
		return false;
	}
	return true;
}

static void StartTurnBasedEnemyFreeze()
{
	const int turns = InclusiveRoll(3, 5);
	const bool fresh = g_timeStopTurns.empty();
	bool raised = false;
	if (g_mainState)
	{
		for (int id : g_mainState->m_combatParticipants)
		{
			U7Object* unit = GetObjectFromID(id);
			if (!IsHostileCombatUnit(unit))
				continue;
			int& left = g_timeStopTurns[id];
			if (turns > left)
			{
				left = turns;
				raised = true;
			}
		}
	}
	// The turn count is the whole effect. A wall-clock stop must not also run.
	g_timeStopUntil = 0.0f;
	if (!raised)
		return;
	if (fresh)
		AddCombatLogString("Time stops.", SKYBLUE);
	AddCombatLogString(
		"Enemies are frozen for " + std::to_string(turns) + " turns.",
		SKYBLUE);
}

void StartTimeStop(int length)
{
	if (InTurnBasedCombat())
	{
		StartTurnBasedEnemyFreeze();
		return;
	}
	if (length <= 0)
		return;
	const float now = GetTime();
	const float until = now + static_cast<float>(length) * 0.25f;
	const bool fresh = g_timeStopUntil <= now;
	if (until > g_timeStopUntil)
		g_timeStopUntil = until;
	if (fresh)
		AddCombatLogString("Time stops.", SKYBLUE);
}

bool SpendEnemyTimeStopTurn(U7Object* unit)
{
	if (!unit || !IsHostileCombatUnit(unit))
		return false;
	const auto it = g_timeStopTurns.find(static_cast<int>(unit->m_ID));
	if (it == g_timeStopTurns.end() || it->second <= 0)
		return false;
	--(it->second);
	if (it->second <= 0)
		g_timeStopTurns.erase(it);
	return true;
}

bool EnemyTimeStopActive()
{
	return !g_timeStopTurns.empty();
}

bool ExpireDeadEnemyTimeStops()
{
	if (g_timeStopTurns.empty())
		return false;
	for (auto it = g_timeStopTurns.begin(); it != g_timeStopTurns.end(); )
	{
		U7Object* unit = GetObjectFromID(it->first);
		if (!IsHostileCombatUnit(unit))
			it = g_timeStopTurns.erase(it);
		else
			++it;
	}
	return g_timeStopTurns.empty();
}

void UpdateSixthCircleEffects()
{
	const float now = GetTime();
	DrainPendingClones(now);
	DrainPendingRings(now);
	DrainPendingGold(now);
	DrainPendingBlasts(now);
	DrainPendingCharms(now);
	DrainPendingMights(now);
	DrainPendingDeaths(now);
	DrainArmageddon(now);
	UpdateEnergyMists(now);
	// Expire a finished Time Stop even when nothing else asks.
	TimeIsStopped();

	if (g_stormEndsAt > 0.0f)
	{
		if (now >= g_stormEndsAt)
			StopMagicStorm();
		else if (now >= g_stormNextStrike)
		{
			StrikeMagicStorm();
			if (g_stormEndsAt > 0.0f)
				g_stormNextStrike = now + static_cast<float>(InclusiveRoll(3, 8)) * kUsecodeStepSec;
		}
	}
	else if (g_ScriptingSystem && g_ScriptingSystem->GetFlag(kMagicStormFlag))
	{
		// A save cannot resume the strike chain. Clear the leftover flag and rain.
		StopMagicStorm();
	}
}

void ScheduleClone(int targetId)
{
	if (targetId <= 0)
		return;
	const float at = static_cast<float>(GetTime()) + 4.0f * kUsecodeStepSec;
	g_pendingClones.push_back(PendingClone{ targetId, at });
}

void PlaceFireRing(int tileX, int tileZ, float lift)
{
	// Func0672 indexes from 1. These are the twelve offsets in that order.
	// The second list is U7 y, which is this engine's z.
	static const int kOx[12] = { -1, 0, 1, 2, 2, 2, 1, 0, -1, -2, -2, -2 };
	static const int kOz[12] = { -2, -2, -2, -1, 0, 1, 2, 2, 2, 1, 0, -1 };
	const float now = GetTime();
	for (int i = 0; i < 12; ++i)
	{
		const int tx = tileX + kOx[i];
		const int tz = tileZ + kOz[i];
		float y = 0.0f;
		if (!SurfaceNear(tx, tz, lift, 2.0f, y))
			continue;
		// Delay is the 1-based index: 1 through 12 usecode ticks.
		g_pendingRings.push_back(PendingRing{ tx, tz, y, now + static_cast<float>(i + 1) * kUsecodeStepSec });
	}
}

void CastFlameStrike(U7Object* caster)
{
	if (!caster)
		return;
	// Before the fields arm. The arm pulse logs, and starting combat
	// there would erase that line.
	PullEnemyIntoCombat(caster);
	std::vector<U7Object*> targets;
	CollectOffensiveTargets(caster, 25, targets);
	for (U7Object* target : targets)
	{
		if (!IsLivingCreature(target))
			continue;
		PullEnemyIntoCombat(target);
		const int tx = static_cast<int>(std::floor(target->m_Pos.x));
		const int tz = static_cast<int>(std::floor(target->m_Pos.z));
		U7Object* field = MakeSpellField(kFireFieldShape, tx, tz, target->m_Pos.y);
		if (!field)
			continue;
		field->m_flameStrikeField = true;
		field->m_flameStrikeCasterId = static_cast<int>(caster->m_ID);
		// 30 + roll(1, 15) ticks. Quality is not the duration; ArmFireField stores it.
		const float life = (30.0f + static_cast<float>(InclusiveRoll(1, 15))) * kUsecodeStepSec;
		field->ArmFireField(life);
	}
}

void StartMagicStorm(U7Object* caster)
{
	if (!caster)
		return;
	const float now = GetTime();
	const bool already = g_stormEndsAt > now;
	g_stormCasterId = static_cast<int>(caster->m_ID);
	g_stormEndsAt = now + 70.0f * kUsecodeStepSec;
	if (!already)
		g_stormNextStrike = now + 8.0f * kUsecodeStepSec;
	if (g_ScriptingSystem)
		g_ScriptingSystem->SetFlag(kMagicStormFlag, true);
	if (g_WeatherSystem)
		g_WeatherSystem->SetWeather(2, 0, false, Vector3{ 0, 0, 0 }, -1, -1);
}

void CastTremor(U7Object* caster)
{
	if (!caster)
		return;

	const bool partyCaster = IsPartyActor(caster);
	const int tx = static_cast<int>(std::floor(caster->m_Pos.x));
	const int tz = static_cast<int>(std::floor(caster->m_Pos.z));
	const int cx = tx / 16;
	const int cz = tz / 16;
	std::vector<U7Object*> victims;

	for (int oz = cz - 3; oz <= cz + 3; ++oz)
	{
		for (int ox = cx - 3; ox <= cx + 3; ++ox)
		{
			if (ox < 0 || oz < 0 || ox >= 192 || oz >= 192)
				continue;
			const std::vector<U7Object*> units = g_chunkObjectMap[ox][oz];
			for (U7Object* unit : units)
			{
				if (!IsLivingCreature(unit) || unit == caster)
					continue;
				if ((unit->m_flags & kObjFlagInvisible) != 0)
					continue;
				if (AlreadyListed(victims, unit))
					continue;
				const int ux = static_cast<int>(std::floor(unit->m_Pos.x));
				const int uz = static_cast<int>(std::floor(unit->m_Pos.z));
				if (std::max(std::abs(ux - tx), std::abs(uz - tz)) > 40)
					continue;
				// Process when the caster is outside the party, or the target is.
				// Skip only a party caster hitting a party member.
				if (partyCaster && IsPartyActor(unit))
					continue;
				victims.push_back(unit);
			}
		}
	}

	const float until = GetTime() + 8.0f;
	for (U7Object* victim : victims)
	{
		std::vector<U7Object::UsecodeScriptElem> code;
		code.reserve(12 * 4);
		for (int n = 0; n < 12; ++n)
			PushStumble(code, InclusiveRoll(0, 8));
		if (code.empty())
			continue;
		victim->m_pathWaypoints.clear();
		victim->m_currentWaypointIndex = 0;
		victim->m_pathfindingPending = false;
		victim->m_isMoving = false;
		victim->m_combatMoveOrder = false;
		victim->SetDest(victim->m_Pos);
		victim->HaltUsecodeScript(true);
		victim->StartUsecodeScript(std::move(code));
		victim->m_tremorUntil = until;
	}

	StartEarthquake(36);
}

void ClearSeventhCirclePending()
{
	g_pendingGold.clear();
	g_pendingBlasts.clear();
	g_pendingCharms.clear();
	g_pendingMights.clear();
	g_pendingDeaths.clear();
	g_energyMists.clear();
	g_armageddonAt = 0.0f;
	g_armageddonCasterId = 0;
	g_timeStopUntil = 0.0f;
	g_timeStopTurns.clear();
}

void ScheduleCreateGold(int leadId)
{
	if (leadId <= 0)
		return;
	const float now = GetTime();
	// Five usecode ticks. The lead may be inside a bag; Update() does not run there.
	g_pendingGold.push_back(PendingGold{ leadId, now + 5.0f * kUsecodeStepSec });
}

bool SpellSurfaceOpen(int tileX, int tileZ, float lift)
{
	float y = 0.0f;
	return SurfaceNear(tileX, tileZ, lift, 2.0f, y);
}

int PlaceEnergyField(int tileX, int tileZ, float lift)
{
	float y = 0.0f;
	if (!SurfaceNear(tileX, tileZ, lift, 2.0f, y))
		return 0;
	U7Object* field = MakeSpellField(kEnergyFieldShape, tileX, tileZ, y);
	if (!field)
		return 0;
	field->ArmEnergyField();
	return static_cast<int>(field->m_ID);
}

void ScheduleDelayedBlast(int casterId, int markerId)
{
	if (markerId <= 0)
		return;
	const float now = GetTime();
	PendingBlast blast;
	blast.casterId = casterId;
	blast.markerId = markerId;
	// Attack at 12 ticks, remove the marker at 14. The bolt may still be in the air.
	blast.attackAt = now + 12.0f * kUsecodeStepSec;
	blast.removeAt = now + 14.0f * kUsecodeStepSec;
	blast.attacked = false;
	g_pendingBlasts.push_back(blast);
}

void StartHomingCloud(U7Object* caster, U7Object* target,
	int weaponShape, int sprite, int sfx, const char* hitNoun)
{
	if (!caster)
		return;

	const float now = GetTime();
	EnergyMist mist;
	mist.casterId = static_cast<int>(caster->m_ID);
	mist.targetId = (target && !target->GetIsDead() && !target->IsDeathStatus())
		? static_cast<int>(target->m_ID) : 0;
	mist.x = caster->m_Pos.x;
	mist.y = caster->m_Pos.y;
	mist.z = caster->m_Pos.z;
	mist.weaponShape = weaponShape;
	mist.sprite = sprite;
	mist.sfx = sfx;
	mist.hitNoun = hitNoun ? hitNoun : "the mist";
	mist.radius = MistRadiusTiles(sprite);
	if (mist.radius < 1)
		mist.radius = 1;

	if (InTurnBasedCombat())
	{
		// The clicked creature is the first enemy at any distance. Otherwise the
		// strike searches within 30 tiles of the caster.
		mist.targetId = IsMistEnemy(target) ? static_cast<int>(target->m_ID) : 0;
		StrikeEnergyMistTurn(mist);
		mist.turnsRemaining = kEnergyMistTurnBudget - 1;
		mist.endsAt = 0.0f;
		if (mist.targetId == 0)
		{
			if (g_SpriteEffectSystem)
				g_SpriteEffectSystem->Spawn(mist.sprite, Vector3{ mist.x, mist.y, mist.z });
			mist.nextPuff = now + 0.2f;
		}
		g_energyMists.push_back(mist);
		return;
	}

	mist.endsAt = now + 20.0f;
	// Exult damages on the first frame. The pump plays the cloud's sfx with that hit.
	mist.nextDamage = now;
	mist.nextStep = now + 0.1f;
	mist.nextPuff = now;
	g_energyMists.push_back(mist);
}

void StartEnergyMist(U7Object* caster, U7Object* target)
{
	StartHomingCloud(caster, target, 399, 13, 65, "the mist");
}

void StartDeathVortex(U7Object* caster, U7Object* target)
{
	// Weapon 639. Sprite 8, sfx 63, 12 lightning. Same homing cloud as the mist.
	StartHomingCloud(caster, target, 639, 8, 63, "the vortex");
}

void AdvanceEnergyMistTurns()
{
	size_t i = 0;
	while (i < g_energyMists.size())
	{
		EnergyMist& mist = g_energyMists[i];
		if (mist.turnsRemaining <= 0)
		{
			++i;
			continue;
		}
		StrikeEnergyMistTurn(mist);
		mist.turnsRemaining -= 1;
		if (mist.turnsRemaining <= 0)
		{
			g_energyMists.erase(g_energyMists.begin() + static_cast<std::ptrdiff_t>(i));
			continue;
		}
		++i;
	}
}

void FreezeEnergyMistsForTurns()
{
	const float now = GetTime();
	for (EnergyMist& mist : g_energyMists)
	{
		if (mist.turnsRemaining > 0)
			continue;
		const float remaining = mist.endsAt - now;
		if (remaining <= 0.0f)
			continue;
		mist.turnsRemaining = std::max(1, static_cast<int>(std::lround(remaining)));
		mist.endsAt = 0.0f;
	}
}

void ReleaseEnergyMistsToRealTime()
{
	const float now = GetTime();
	for (EnergyMist& mist : g_energyMists)
	{
		if (mist.turnsRemaining <= 0)
			continue;
		mist.endsAt = now + static_cast<float>(mist.turnsRemaining);
		mist.turnsRemaining = 0;
		// The turn that just happened already struck. The next pulse waits a second.
		mist.nextDamage = now + 1.0f;
		mist.nextStep = now + 0.1f;
	}
}

void CastMassCharm(U7Object* caster)
{
	if (!caster)
		return;

	if (g_SpriteEffectSystem)
	{
		g_SpriteEffectSystem->Spawn(7, Vector3{
			caster->m_Pos.x - 2.0f,
			caster->m_Pos.y,
			caster->m_Pos.z - 2.0f });
	}

	// The gesture's call would re-enter on the caster. That roll is not the 1-in-3.
	MassCharmOne(caster, caster);

	std::vector<U7Object*> targets;
	CollectOffensiveTargets(caster, 25, targets);
	const float now = GetTime();
	for (U7Object* target : targets)
	{
		if (!IsLivingCreature(target))
			continue;
		// die_roll(1, 3) == 1 skips. Two of three are charmed.
		if (InclusiveRoll(1, 3) == 1)
			continue;
		const int dist = ChebyshevXZ(caster, target);
		const float delay = (static_cast<float>(dist / 4) + 4.0f) * kUsecodeStepSec;
		g_pendingCharms.push_back(PendingCharm{
			static_cast<int>(caster->m_ID),
			static_cast<int>(target->m_ID),
			now + delay });
	}
}

void CastMassMight(U7Object* caster)
{
	if (!caster)
		return;

	if (g_SpriteEffectSystem)
	{
		g_SpriteEffectSystem->Spawn(7, Vector3{
			caster->m_Pos.x - 2.0f,
			caster->m_Pos.y,
			caster->m_Pos.z - 2.0f });
	}

	// Event 2 on the caster runs when the gesture finishes. Apply it now.
	// A party caster is also in the list below; that later call only refreshes.
	caster->ApplyMight();

	if (!g_Player)
		return;

	const float now = GetTime();
	const std::vector<int> party = g_Player->GetPartyMemberIds();
	for (int npcId : party)
	{
		U7Object* member = ObjectFromNpcId(npcId);
		if (!IsLivingCreature(member))
			continue;
		const int dist = ChebyshevXZ(caster, member);
		const float delay = (static_cast<float>(dist / 3) + 5.0f) * kUsecodeStepSec;
		g_pendingMights.push_back(PendingMight{
			static_cast<int>(member->m_ID),
			now + delay });
	}
}

void CastRestoration(U7Object* caster)
{
	// A caster outside the party still heals the player's party, not themselves.
	(void)caster;
	if (!g_Player)
		return;

	const std::vector<int> party = g_Player->GetPartyMemberIds();
	for (int npcId : party)
	{
		U7Object* member = ObjectFromNpcId(npcId);
		if (!member || member->GetIsDead() || member->IsDeathStatus())
			continue;
		if (member->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_NPC)
			continue;

		if ((member->m_flags & kObjFlagParalyzed) != 0)
		{
			member->m_flags &= ~kObjFlagParalyzed;
			member->AnnounceStatusFlag(kObjFlagParalyzed, false);
		}
		if ((member->m_flags & kObjFlagPoisoned) != 0)
		{
			member->m_flags &= ~kObjFlagPoisoned;
			member->StopPoisonTimer();
			member->AnnounceStatusFlag(kObjFlagPoisoned, false);
		}

		int str = 1;
		if (IsAvatarUnit(member))
			str = g_Player->GetStr();
		else if (member->m_NPCData)
			str = static_cast<int>(member->m_NPCData->str);
		if (str < 1)
			str = 1;

		// Knockout is the sleep pose with no hit points. A real sleeper stays asleep.
		const bool knockedOut = member->IsKnockedOut();
		const int before = static_cast<int>(member->m_hp);
		if (before < str)
			member->m_hp = static_cast<float>(str);
		if (knockedOut)
			member->TryWakeFromHealing();

		if (g_SpriteEffectSystem)
			g_SpriteEffectSystem->SpawnOnObject(static_cast<int>(member->m_ID), 13, 0.0f);

		if (before < str)
		{
			Vector3 textPos = member->m_centerPoint;
			textPos.y += 1.35f;
			SpawnFloatingCombatText(textPos,
				"+" + std::to_string(str - before), GREEN);
		}
	}
}

void CastMassDeath(U7Object* caster)
{
	if (!caster)
		return;

	if (g_SpriteEffectSystem)
	{
		g_SpriteEffectSystem->Spawn(7, Vector3{
			caster->m_Pos.x - 2.0f,
			caster->m_Pos.y,
			caster->m_Pos.z - 2.0f });
	}

	// Mask 4 is Exult is_npc(): people and monsters, alive or dead.
	// Dead creatures in the original are body shapes. This engine's corpses
	// stay the same object, so only the living are scheduled. Invisible
	// creatures are excluded.
	const int tx = static_cast<int>(std::floor(caster->m_Pos.x));
	const int tz = static_cast<int>(std::floor(caster->m_Pos.z));
	const int radius = (25 / 16) + 1;
	const int cx = tx / 16;
	const int cz = tz / 16;
	std::vector<U7Object*> victims;
	for (int oz = cz - radius; oz <= cz + radius; ++oz)
	{
		for (int ox = cx - radius; ox <= cx + radius; ++ox)
		{
			if (ox < 0 || oz < 0 || ox >= 192 || oz >= 192)
				continue;
			const std::vector<U7Object*> units = g_chunkObjectMap[ox][oz];
			for (U7Object* unit : units)
			{
				if (!IsLivingCreature(unit) || AlreadyListed(victims, unit))
					continue;
				if (unit->IsInvisible())
					continue;
				if (IsPartyActor(unit) || unit->m_NPCID == 23 || unit->m_NPCID == 26)
					continue;
				const int ux = static_cast<int>(std::floor(unit->m_Pos.x));
				const int uz = static_cast<int>(std::floor(unit->m_Pos.z));
				if (std::max(std::abs(ux - tx), std::abs(uz - tz)) > 25)
					continue;
				victims.push_back(unit);
			}
		}
	}

	const float now = GetTime();
	for (U7Object* victim : victims)
	{
		victim->HaltUsecodeScript(true);
		const int dist = ChebyshevXZ(caster, victim);
		const float delay = (static_cast<float>(dist / 3) + 5.0f) * kUsecodeStepSec;
		g_pendingDeaths.push_back(PendingDeath{
			static_cast<int>(caster->m_ID),
			static_cast<int>(victim->m_ID),
			now + delay });
	}

	if (victims.empty() || !g_Player)
		return;

	// Anyone queued, including a death-safe NPC, taxes the party down to 2 HP.
	const std::vector<int> party = g_Player->GetPartyMemberIds();
	for (int npcId : party)
	{
		U7Object* member = ObjectFromNpcId(npcId);
		if (!IsLivingCreature(member))
			continue;
		const int hp = static_cast<int>(member->m_hp);
		if (hp > 2)
			ApplyCombatDamage(member, static_cast<float>(hp - 2), nullptr);
	}
}

void CastArmageddon(U7Object* caster)
{
	if (!caster)
		return;

	if (g_SpriteEffectSystem)
	{
		g_SpriteEffectSystem->Spawn(7, Vector3{
			caster->m_Pos.x - 2.0f,
			caster->m_Pos.y,
			caster->m_Pos.z - 2.0f });
	}
	if (g_WeatherSystem)
		g_WeatherSystem->SetWeather(2, 0, false, Vector3{ 0, 0, 0 }, -1, -1);

	g_armageddonCasterId = static_cast<int>(caster->m_ID);
	// The gesture is twelve steps. The quake and the deaths follow it.
	const float now = GetTime();
	g_armageddonAt = now + 12.0f * kUsecodeStepSec;
}

bool CastResurrect(U7Object* target)
{
	if (!target)
		return false;

	U7Object* npc = nullptr;
	const int shape = ObjectShape(target);
	if (shape == 400 || shape == 414 || shape == 778)
	{
		int quantity = 0;
		if (shape >= 0 && shape < 1024 && g_objectDataTable[shape].m_shapeType == 3)
			quantity = target->m_Quality & 0x7f;
		if (target->m_Quality == 0 && quantity == 0)
			return false;
		if (target->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC && target->IsDeathStatus())
			npc = target;
		else if (target->m_Quality > 0)
			npc = ObjectFromNpcId(target->m_Quality);
	}
	else if (target->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC
		&& target->m_NPCData && target->IsDeathStatus())
	{
		// This engine keeps the dead NPC. The original would only accept a body.
		npc = target;
	}

	if (!npc || npc->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_NPC || !npc->IsDeathStatus())
		return false;

	if (npc != target)
		npc->SetPos(target->m_Pos);

	npc->ResurrectFromDeath();
	if (npc->IsDeathStatus())
		return false;

	if (g_SpriteEffectSystem)
	{
		g_SpriteEffectSystem->Spawn(17, Vector3{ npc->m_Pos.x, npc->m_Pos.y, npc->m_Pos.z });
		g_SpriteEffectSystem->Spawn(13, Vector3{
			npc->m_Pos.x - 2.0f, npc->m_Pos.y, npc->m_Pos.z - 2.0f });
	}
	if (g_SoundSystem)
		g_SoundSystem->PlayMusic(BuildU7MusicPath(15));
	return true;
}

void ApplyDeathBoltIntellect(U7Object* attacker, U7Object* target)
{
	if (!attacker || !target)
		return;
	// The bolt's own hit already landed. A corpse does not take the second blow.
	if (target->GetIsDead() || target->IsDeathStatus())
		return;
	// Monsters are not NPCs. Usecode forces attacker 0 and defender 1, so no kill.
	if (target->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_NPC || !target->m_NPCData)
		return;
	// Func0679 skips the Avatar (item != 0xFE9C). The 20 damage still landed.
	if (target->m_NPCID == 0)
		return;
	if (target->IsDeathSafe())
		return;

	// The decompile reads the Avatar's intelligence. This uses the bolt's caster.
	const int atk = GetCombatIntelligence(attacker);
	const int def = GetCombatIntelligence(target);
	if (atk <= def)
		return;

	ApplyCombatDamage(target, 127.0f, attacker);
	if (!target->GetIsDead() && !target->IsDeathStatus())
		target->ApplyDeath();
}

bool U7Object::IsTrembling() const
{
	return m_tremorUntil > 0.0f && GetTime() < m_tremorUntil;
}

void U7Object::ArmPoisonField()
{
	ArmHazardShape(this, kPoisonFieldShape);
	const int shape = m_shapeData ? m_shapeData->m_shape : m_ObjectType;
	if (shape != kPoisonFieldShape)
		return;
	// Spell cast plays 0-11 once, then loops 6-11. Map fields leave this clear
	// and stay on the loop.
	m_fireFieldPlayStartup = true;
	m_fireFieldAnimStart = GetTime();
	SetFrame(0);
	// Anyone already on the tile rolls now. The next standing pulse waits a second.
	m_fireFieldNextPulse = GetTime() + kFireFieldPulseSec;
	if (PulseHazardField(this, true))
		ExpireFireField();
}

void U7Object::ArmSleepField()
{
	ArmHazardShape(this, kSleepFieldShape);
	const int shape = m_shapeData ? m_shapeData->m_shape : m_ObjectType;
	if (shape != kSleepFieldShape)
		return;
	// Spell cast plays 0-13 once, then loops 7-13. Map fields leave this clear
	// and stay on the loop.
	m_fireFieldPlayStartup = true;
	m_fireFieldAnimStart = GetTime();
	SetFrame(0);
	// Anyone already on the tile rolls now. The next standing pulse waits a second.
	m_fireFieldNextPulse = GetTime() + kFireFieldPulseSec;
	if (PulseHazardField(this, true))
		ExpireFireField();
}

void U7Object::UpdateHazardField()
{
	const int shape = m_shapeData ? m_shapeData->m_shape : m_ObjectType;
	if (shape != kPoisonFieldShape && shape != kSleepFieldShape)
		return;
	if (GetIsDead() || m_isContained || !m_Visible)
		return;
	// Turn-based contact is the step-in check and the start of that unit's turn.
	if (InTurnBasedCombat())
		return;

	const float now = GetTime();
	if (m_fireFieldNextPulse > 0.0f && now < m_fireFieldNextPulse)
		return;
	m_fireFieldNextPulse = now + kFireFieldPulseSec;
	if (PulseHazardField(this))
		ExpireFireField();
}

void U7Object::MonsterUpdate()
{
	UpdateInvisibilityTimer();
	UpdateCharmTimer();
	UpdateMightTimer();

	// Corpses: keep death pose, no chase/attack AI.
	if (IsDeathStatus() || GetIsDead())
	{
		if (IsDeathStatus() && !m_isFrameOverridden)
			SetOverrideFrame(GetDeathFrameForFacing());
		UpdateNpcAnim(g_Engine ? g_Engine->LastFrameInSeconds() : 0.0f);
		return;
	}

	// An Tym. Non-party creatures hold still. The party is not on this path.
	if (TimeIsStopped())
	{
		m_pathWaypoints.clear();
		m_currentWaypointIndex = 0;
		m_pathfindingPending = false;
		m_isSchedulePath = false;
		m_isMoving = false;
		m_combatMoveOrder = false;
		SetDest(m_Pos);
		UpdateNpcAnim(g_Engine ? g_Engine->LastFrameInSeconds() : 0.0f);
		return;
	}

	UpdatePoisonTimer();
	UpdateSleepTimer();
	UpdateDance();
	if (IsDancing() || IsTrembling())
	{
		m_pathWaypoints.clear();
		m_currentWaypointIndex = 0;
		m_pathfindingPending = false;
		m_isSchedulePath = false;
		m_isMoving = false;
		m_combatMoveOrder = false;
		SetDest(m_Pos);
	}
	// Stumble poses are a usecode script. Monsters do not otherwise tick one.
	UpdateUsecodeScript();
	UpdateNpcAnim(g_Engine ? g_Engine->LastFrameInSeconds() : 0.0f);

	// Exult: asleep / KO skips chase and attack.
	if ((m_flags & kObjFlagAsleep) != 0 || IsKnockedOut())
		return;

	if (IsTrembling())
		return;

	if (IsDancing())
	{
		ApplyDancePose();
		return;
	}

	// Hostiles are Team 1 (combat eggs). Team 2 = party summons (Swarm). Team 0 = fauna.
	if (m_Team == 2)
	{
		// Turn-based: each insect waits for its initiative turn. Free roaming
		// would move and harass on everyone else's turn.
		if (g_isCombatMode && g_mainState && g_mainState->m_combatMode
			&& g_mainState->m_combatMode->GetStyle() == CombatStyle::TurnBased)
		{
			return;
		}
		AlliedMonsterUpdate();
		return;
	}

	if (m_Team == 1 && g_Player)
	{
		U7Object* avatar = g_Player->GetAvatarObject();
		if (avatar)
		{
			const float distSqr = Vector2DistanceSqr({ m_Pos.x, m_Pos.z }, { avatar->m_Pos.x, avatar->m_Pos.z });
			const bool sameLayer = AreUnitsOnSameDungeonLayer(this, avatar);
			// New aggro / enroll uses the short range; chase leash stays at 32.
			const bool inEnrollRange = sameLayer && distSqr <= kHostileCombatEnrollRangeSqr;
			const bool inChaseRange = sameLayer && distSqr <= kHostileAggroRangeSqr;
			// Already chasing: keep approaching even if path flickers briefly.
			const bool alreadyAggroed = (m_target != 0);

			if (!g_isCombatMode && (inEnrollRange || (alreadyAggroed && inChaseRange)))
			{
				// New aggro needs wall LOS + a real ValidateMove path (no crow-fly stubs).
				// Already-aggroed keep closing without re-flooding every frame.
				const bool canEngage = alreadyAggroed
					|| (HasCombatLineOfSightToParty(this) && HasCombatWalkPathToParty(this));
				if (canEngage)
				{
					if (!alreadyAggroed)
						TryBeginCombatFromHostileAggro(this);
					// Close on the party before the player presses C (no swings yet).
					HostileCombatUpdate();
					return;
				}
			}
			else if (!g_isCombatMode && !inChaseRange && m_target != 0)
			{
				// Drop pre-combat chase when the party leaves the chase leash.
				m_target = 0;
				m_combatPathTargetId = 0;
				m_pathWaypoints.clear();
				m_isMoving = false;
				SetDest(m_Pos);
			}
			// In combat, EnrollNearbyCombatHostiles path-gates new joiners.

			// Skip chase/attack AI while combat is paused for orders.
			// Turn-Based Resolving: active monster may finish a Move order.
			if (g_mainState && g_mainState->IsCombatOrdersPaused())
			{
				if (g_mainState->CanCombatUnitAct(this)
				    && (m_combatOrderMode == CombatOrderMode::Move || m_combatMoveOrder))
				{
					UpdateMovement();
				}
				return;
			}

			if (g_isCombatMode)
			{
				HostileCombatUpdate();
				return;
			}
		}
	}

	UpdateMovement();
}

void U7Object::AlliedMonsterUpdate()
{
	if (IsDeathStatus() || GetIsDead())
		return;
	if ((m_flags & (1u << 1)) != 0 || (m_flags & (1u << 7)) != 0)
		return;
	// Swarm keeps acting while combat orders are paused — autonomous distraction.

	// Summons despawn outside the loaded terrain window. A charmed creature
	// keeps their body until the charm wears off.
	if ((m_flags & kObjFlagCharmed) == 0)
	{
		int cellx = 0, celly = 0;
		if (!WorldToTerrainCell(static_cast<int>(m_Pos.x), static_cast<int>(m_Pos.z), cellx, celly))
		{
			if (g_SoundSystem)
				g_SoundSystem->StopLoopingSoundEffect(static_cast<int>(m_ID));
			UnassignObjectChunk(this);
			SetIsDead(true);
			m_Visible = false;
			m_ShouldDraw = false;
			m_hp = 0.0f;
			return;
		}
	}

	constexpr float kHarassCooldownSec = 0.5f;
	if (m_attackCooldown < kHarassCooldownSec)
		m_attackCooldown = kHarassCooldownSec;
	if (m_cooldownTimer > 0.0f && g_Engine)
		m_cooldownTimer -= g_Engine->LastFrameInSeconds();

	auto isLivingHostile = [&](U7Object* obj) -> bool {
		if (!obj || !IsHostileCombatUnit(obj))
			return false;
		if (obj->IsInvisible() && !CanSeeInvisible())
			return false;
		return Vector2DistanceSqr({ m_Pos.x, m_Pos.z }, { obj->m_Pos.x, obj->m_Pos.z })
			<= kHostileAggroRangeSqr;
	};

	// Cheap local scan: only this chunk + neighbors (not the whole interest set /
	// g_objectList). Previous load-balance walked every world object per insect.
	auto collectNearbyHostiles = [&]() {
		std::vector<U7Object*> out;
		const int chunkX = static_cast<int>(m_Pos.x) / 16;
		const int chunkZ = static_cast<int>(m_Pos.z) / 16;
		for (int dz = -2; dz <= 2; ++dz)
		{
			for (int dx = -2; dx <= 2; ++dx)
			{
				const int cx = chunkX + dx;
				const int cz = chunkZ + dz;
				if (cx < 0 || cz < 0 || cx >= 192 || cz >= 192)
					continue;
				for (U7Object* obj : g_chunkObjectMap[cx][cz])
				{
					if (isLivingHostile(obj))
						out.push_back(obj);
				}
			}
		}
		return out;
	};

	// Stick to current target when still valid; otherwise stable id partition
	// across nearby hostiles (no O(world) load counts).
	auto pickHostile = [&]() -> U7Object* {
		if (U7Object* cur = (m_target > 0) ? GetObjectFromID(m_target) : nullptr)
		{
			if (isLivingHostile(cur))
				return cur;
		}
		std::vector<U7Object*> hostiles = collectNearbyHostiles();
		if (hostiles.empty())
			return nullptr;
		std::sort(hostiles.begin(), hostiles.end(),
			[](const U7Object* a, const U7Object* b) { return a->m_ID < b->m_ID; });
		return hostiles[static_cast<size_t>(m_ID) % hostiles.size()];
	};

	auto buzzSlotAround = [&](U7Object* hostile) -> Vector3 {
		constexpr float kGoldenAngle = 2.399963229728653f;
		const float angle = static_cast<float>(m_ID) * kGoldenAngle;
		// Insects keep a loose cloud. Other summons stand inside melee range.
		const float radius = (m_ObjectType == 517)
			? 1.6f + static_cast<float>(m_ID % 5) * 0.45f
			: 1.15f;
		Vector3 slot{
			hostile->m_Pos.x + cosf(angle) * radius,
			hostile->m_Pos.y,
			hostile->m_Pos.z + sinf(angle) * radius
		};
		slot.x = floorf(slot.x) + 0.5f;
		slot.z = floorf(slot.z) + 0.5f;
		return slot;
	};

	auto pathTo = [&](const Vector3& dest) {
		const float now = GetTime();
		const bool pathDone = m_pathWaypoints.empty()
			|| m_currentWaypointIndex >= (int)m_pathWaypoints.size();
		const float goalDx = dest.x - m_combatPathGoal.x;
		const float goalDz = dest.z - m_combatPathGoal.z;
		const bool goalDrifted = (goalDx * goalDx + goalDz * goalDz) >= 2.25f;
		// Repath at most ~1.2s; crow-fly SetDest when A* would be wasteful spam.
		if (!pathDone && !goalDrifted && now < m_combatRepathAt)
			return;

		m_pathWaypoints.clear();
		m_currentWaypointIndex = 0;
		m_pathfindingPending = false;
		SetDest(dest);
		m_isMoving = true;
		m_combatPathGoal = dest;
		m_combatRepathAt = now + 1.2f;
	};

	auto wanderRandomly = [&]() {
		m_target = 0;
		m_combatPathTargetId = 0;
		const float now = GetTime();
		const bool pathDone = m_pathWaypoints.empty()
			|| m_currentWaypointIndex >= (int)m_pathWaypoints.size();
		const bool arrived = !m_isMoving
			|| Vector2DistanceSqr({ m_Pos.x, m_Pos.z }, { m_Dest.x, m_Dest.z }) < 0.35f;
		if (!arrived && !pathDone && now < m_combatRepathAt)
		{
			UpdateMovement();
			return;
		}

		float angle = 0.0f;
		float dist = 5.0f;
		if (g_NonVitalRNG)
		{
			angle = g_NonVitalRNG->RandomRangeFloat(0.0f, 6.2831853f);
			dist = g_NonVitalRNG->RandomRangeFloat(4.0f, 10.0f);
		}
		Vector3 dest{
			m_Pos.x + cosf(angle) * dist,
			m_Pos.y,
			m_Pos.z + sinf(angle) * dist
		};
		dest.x = floorf(dest.x) + 0.5f;
		dest.z = floorf(dest.z) + 0.5f;
		pathTo(dest);
		UpdateMovement();
	};

	U7Object* hostile = pickHostile();
	if (!hostile)
	{
		wanderRandomly();
		return;
	}

	// Enroll once when acquiring a new target — not every frame.
	if (m_target != static_cast<int>(hostile->m_ID))
	{
		if (!g_isCombatMode)
			TryBeginCombatFromHostileAggro(hostile);
		else if (g_mainState)
			g_mainState->EnsureCombatParticipant(static_cast<int>(m_ID));
	}

	m_target = static_cast<int>(hostile->m_ID);
	m_combatPathTargetId = m_target;

	constexpr float kHarassRange = MELEE_RANGE_TILES + 0.85f;
	const float distToHostile = Vector2Distance(
		{ m_Pos.x, m_Pos.z }, { hostile->m_Pos.x, hostile->m_Pos.z });
	const Vector3 slot = buzzSlotAround(hostile);
	const float distToSlot = Vector2Distance({ m_Pos.x, m_Pos.z }, { slot.x, slot.z });

	if (distToHostile <= kHarassRange)
	{
		m_pathWaypoints.clear();
		m_currentWaypointIndex = 0;
		m_pathfindingPending = false;
		m_isMoving = false;
		SetDest(m_Pos);

		Vector3 toTarget = Vector3Subtract(hostile->m_Pos, m_Pos);
		toTarget.y = 0.0f;
		if (Vector3LengthSqr(toTarget) > 1e-6f)
			m_Direction = Vector3Normalize(toTarget);

		// Insects bite on a short cooldown and deal 0 (their weapon row).
		// Other summons use their own cooldown and a real strike.
		if (m_cooldownTimer <= 0.0f)
		{
			const int strikeShape = CombatStrikeWeaponShape(this);
			const WeaponData* strikeWeapon = (strikeShape >= 0) ? GetWeaponData(strikeShape) : nullptr;
			if (strikeWeapon && strikeWeapon->damage == 0)
				hostile->NotifyAttackedBy(this);
			else
				ResolveMeleeHit(this, hostile, strikeShape);
			m_cooldownTimer = m_attackCooldown > 0.1f ? m_attackCooldown : kHarassCooldownSec;
		}
	}
	else if (distToSlot > 0.45f)
	{
		pathTo(slot);
	}

	UpdateMovement();
}

///////////////////////////////////////////////////////////////////////////
//  TYPE-SPECIFIC DRAW FUNCTIONS
//  Called from U7Object::Draw() via switch on m_UnitType
///////////////////////////////////////////////////////////////////////////

// Original U7 IsBoxBlockedAt: SE corner (x, z), footprint extends west/north
// by w-1 and h-1, vertical volume [lift, lift+height). Solid TFA bit only.
// Doors are stored on the other collision bit and do not count.
static bool MirrorBoxBlocked(int seX, int seZ, int lift, int w, int h, int height)
{
	const int minX = seX - (w - 1);
	const int maxX = seX;
	const int minZ = seZ - (h - 1);
	const int maxZ = seZ;
	const float boxMinY = static_cast<float>(lift);
	const float boxMaxY = static_cast<float>(lift + height);

	int chunkMinX = minX / 16 - 1;
	int chunkMaxX = maxX / 16 + 1;
	int chunkMinZ = minZ / 16 - 1;
	int chunkMaxZ = maxZ / 16 + 1;
	if (chunkMinX < 0) chunkMinX = 0;
	if (chunkMinZ < 0) chunkMinZ = 0;
	if (chunkMaxX > 191) chunkMaxX = 191;
	if (chunkMaxZ > 191) chunkMaxZ = 191;

	for (int cz = chunkMinZ; cz <= chunkMaxZ; ++cz)
	{
		for (int cx = chunkMinX; cx <= chunkMaxX; ++cx)
		{
			for (U7Object* obj : g_chunkObjectMap[cx][cz])
			{
				if (!obj || !obj->m_objectData || obj->GetIsDead() || obj->m_isContained)
					continue;
				if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_EGG)
					continue;
				if (obj->m_objectData->m_isDoor || !obj->m_objectData->m_isNotWalkable)
					continue;
				if (obj->m_objectData->m_height <= 0.0f)
					continue;

				const int width = std::max(1, static_cast<int>(obj->m_objectData->m_width));
				const int depth = std::max(1, static_cast<int>(obj->m_objectData->m_depth));
				const int objMaxX = static_cast<int>(std::floor(obj->m_Pos.x));
				const int objMaxZ = static_cast<int>(std::floor(obj->m_Pos.z));
				const int objMinX = objMaxX - width + 1;
				const int objMinZ = objMaxZ - depth + 1;
				if (objMaxX < minX || objMinX > maxX || objMaxZ < minZ || objMinZ > maxZ)
					continue;

				const float baseY = obj->m_Pos.y;
				const float topY = baseY + obj->m_objectData->m_height;
				if (baseY < boxMaxY && topY > boxMinY)
					return true;
			}
		}
	}
	return false;
}

// First half appears, second half loops. A new field plays every frame once,
// then stays on the loop. A field already in the world stays on the loop.
// Same 8 fps as other TFA FX. Fire is 0-7 then 8-15. Poison is 0-5 then 6-11.
// Sleep is 0-6 then 7-13.
static int SplitFieldDisplayFrame(bool playStartup, float animStart, int animFrames, int loopStart)
{
	constexpr float kTimePerFrame = 1.0f / 8.0f;
	if (animFrames <= 1)
		return 0;
	if (loopStart <= 0 || loopStart >= animFrames)
	{
		const int step = static_cast<int>(GetTime() / kTimePerFrame);
		const int wrapped = step % animFrames;
		return wrapped < 0 ? wrapped + animFrames : wrapped;
	}

	const int loopFrames = animFrames - loopStart;
	if (!playStartup)
	{
		const int step = static_cast<int>(GetTime() / kTimePerFrame);
		const int wrapped = step % loopFrames;
		return loopStart + (wrapped < 0 ? wrapped + loopFrames : wrapped);
	}

	int step = static_cast<int>((GetTime() - animStart) / kTimePerFrame);
	if (step < 0)
		step = 0;
	if (step < animFrames)
		return step;
	return loopStart + ((step - animFrames) % loopFrames);
}

void U7Object::StaticDraw()
{
	// Statics are drawn through the normal shapeData path below in InteractiveDraw
	// for now. We can specialize later (e.g. instanced terrain).
	InteractiveDraw();
}

void U7Object::InteractiveDraw()
{
	// 087D overlay is a find_nearby token. Drawing it as a second body
	// offsets from the Avatar walksheet and billboards independently.
	if (IsUsecodeAvatarOverlay())
		return;

	// Usecode-armed actors (Erethian mage body): walk billboard like monsters.
	// Skip while a pose list owns the frame (0407 SetAbsoluteFrame).
	if (m_usecodeObjectSchedule && m_walkTextures.size() >= 8 && !IsInUsecodeScript())
	{
		DrawWalkBillboard(m_walkTextures, m_walkTexturesUpright);
		return;
	}

	int cellx = 0, celly = 0;
	if (!WorldToTerrainCell(static_cast<int>(m_Pos.x), static_cast<int>(m_Pos.z), cellx, celly))
	{
		return; // Outside the active terrain / draw patch.
	}

	// Multi-frame shapes: pick the right frame before drawing.
	// NPCs/monsters drive frames themselves; doors use scripted SetFrame.
	// Auto mode only: Scripted/Frozen leave m_Frame alone (usecode / rest pose).
	if (m_objectData
		&& m_UnitType != UnitTypes::UNIT_TYPE_NPC
		&& m_UnitType != UnitTypes::UNIT_TYPE_MONSTER
		&& !m_isCustomMesh
		&& !(m_objectData->m_isDoor))
	{
		const int animFrames = g_shapeTable[m_ObjectType][0].m_numFrames;
		int currentFrame = m_Frame;

		if (m_ObjectType == 268 || m_ObjectType == 848)
		{
			// Original UpdateMirrorFrame: frames >= 2 stay (broken / Arcadion).
			// 268 probes east of the SE corner; 848 probes south. Lift 1 is absolute.
			if (m_Frame < 2)
			{
				const int x = static_cast<int>(std::floor(m_Pos.x));
				const int z = static_cast<int>(std::floor(m_Pos.z));
				const bool blocked = (m_ObjectType == 268)
					? MirrorBoxBlocked(x + 2, z, 1, 2, 2, 2)
					: MirrorBoxBlocked(x, z + 2, 1, 2, 2, 2);
				currentFrame = blocked ? 1 : 0;
			}
		}
		else if (m_ObjectType == 284 && animFrames > 1)
		{
			// Sundial: 24 frames, one per game hour (not a looping FX cycle).
			currentFrame = static_cast<int>(g_hour) % animFrames;
		}
		else if (m_ObjectType == kFireFieldShape)
		{
			// 16 frames: play 0-15, then loop 8-15.
			const int frames = std::min(animFrames, 16);
			currentFrame = SplitFieldDisplayFrame(
				m_fireFieldPlayStartup, m_fireFieldAnimStart, frames, 8);
		}
		else if (m_ObjectType == kPoisonFieldShape)
		{
			// 12 frames: play 0-11, then loop 6-11.
			const int frames = std::min(animFrames, 12);
			currentFrame = SplitFieldDisplayFrame(
				m_fireFieldPlayStartup, m_fireFieldAnimStart, frames, 6);
		}
		else if (m_ObjectType == kSleepFieldShape)
		{
			// 14 frames: play 0-13, then loop 7-13.
			const int frames = std::min(animFrames, 14);
			currentFrame = SplitFieldDisplayFrame(
				m_fireFieldPlayStartup, m_fireFieldAnimStart, frames, frames / 2);
		}
		else if (m_animMode == ObjectAnimMode::Auto
			&& m_objectData->m_isAnimated && animFrames > 1
			// Flag cloth: flutter is the shared glTF idle, scaled by wind — do not
			// cycle TFA frames (all frames share one mesh; cycling looked like the
			// original VGA flutter and ignored Wind Off).
			&& m_ObjectType != 222 && m_ObjectType != 232 && m_ObjectType != 248)
		{
			// TFA "animated" shapes: cycle native SHAPES.VGA frames (no sprite strips).
			// m_animFrameOffset (set in Init) keeps neighboring instances out of lockstep.
			const float timePerFrame = 1.0f / 8.0f;
			currentFrame = (static_cast<unsigned int>(float(GetTime()) / timePerFrame)
				+ (unsigned)m_animFrameOffset) % (unsigned)animFrames;
		}

		if (currentFrame != m_Frame)
		{
			SetFrame(currentFrame);
		}
	}

	// Roofs → ambient; wall cuboids → per-face lights; other walls → camera-side.
	Color renderColor = g_Terrain
		? g_Terrain->GetLightingForObject(this, g_camera.position)
		: Color{ 255, 255, 255, 255 };

	Color cuboidFaces[6];
	const bool useCuboidFaces = g_Terrain && m_shapeData
		&& m_shapeData->GetDrawType() == ShapeDrawType::OBJECT_DRAW_CUBOID;
	if (useCuboidFaces)
		g_Terrain->FillCuboidFaceLighting(this, cuboidFaces);

	auto applyDebugTint = [&](Color& c)
	{
		if (g_showScriptedObjects &&
		    ((m_shapeData->m_luaScript != "" && m_shapeData->m_luaScript != "default") || m_hasConversationTree))
		{
			c.r = (c.r + 0) / 2;
			c.g = (c.g + 255) / 2;
			c.b = (c.b + 0) / 2;
		}
		else if (g_showScriptedObjects && m_objectData && !m_objectData->m_isNotWalkable)
		{
			c.r = (c.r + 0) / 2;
			c.g = (c.g + 0) / 2;
			c.b = (c.b + 255) / 2;
		}
	};
	applyDebugTint(renderColor);
	if (useCuboidFaces)
	{
		for (Color& fc : cuboidFaces)
			applyDebugTint(fc);
	}

	// First-person: soft alpha fade over the outer quarter of draw range so
	// props never hard-pop at g_firstPersonDrawRange.
	{
		const float fade = GetFirstPersonViewFade(m_centerPoint);
		if (fade <= 0.02f)
			return;
		ApplyFirstPersonViewFade(renderColor, m_centerPoint);
		if (useCuboidFaces)
		{
			for (Color& fc : cuboidFaces)
				ApplyFirstPersonViewFade(fc, m_centerPoint);
		}
	}
	ApplyInvisibilityGhostTint(renderColor);
	if (useCuboidFaces)
	{
		for (Color& fc : cuboidFaces)
			ApplyInvisibilityGhostTint(fc);
	}

	if (m_isCustomMesh) {
		CustomMeshDraw(renderColor);
	} else {
		// Skeletal custom meshes: play while Auto/Scripted, rest pose while Frozen.
		// Extinguish one-shot / rest uses m_meshPoseAnim + m_meshPoseFrame.
		bool playMeshAnim = (m_animMode != ObjectAnimMode::Frozen);
		int freezeFrame = 0;
		const char* skeletalClip = nullptr;

		if (!m_meshPoseAnim.empty())
		{
			skeletalClip = m_meshPoseAnim.c_str();
			playMeshAnim = false;

			if (m_meshOneShotPlaying && m_shapeData && m_shapeData->m_customMesh)
			{
				const int n = m_shapeData->m_customMesh->GetAnimationFrameCount(m_meshPoseAnim);
				if (n <= 1)
				{
					m_meshPoseFrame = std::max(0, n - 1);
					m_meshOneShotPlaying = false;
				}
				else
				{
					m_meshOneShotFrameTimer += GetFrameTime();
					const float frameDur = 1.0f / kMeshAnimFps;
					while (m_meshOneShotPlaying && m_meshOneShotFrameTimer >= frameDur)
					{
						m_meshOneShotFrameTimer -= frameDur;
						if (m_meshPoseFrame + 1 >= n)
						{
							m_meshPoseFrame = n - 1;
							m_meshOneShotPlaying = false;
						}
						else
						{
							++m_meshPoseFrame;
						}
					}
				}
			}

			freezeFrame = m_meshPoseFrame;
		}

		m_shapeData->Draw(m_Pos, m_Angle, renderColor, Vector3{ 1, 1, 1 },
			playMeshAnim, freezeFrame, useCuboidFaces ? cuboidFaces : nullptr, skeletalClip);
	}
}

void U7Object::EggDraw()
{
	// Eggs are invisible unless g_showEggs is enabled (handled in main Draw early-out).
	// When visible for debug, we still want to draw their shape.
	if (g_showEggs)
	{
		InteractiveDraw();
	}
}

void U7Object::MonsterDraw()
{
	if (ShouldLieFlat())
	{
		DrawCorpseFlat();
		return;
	}

	// Sit and other upright poses: the shape's own frame, even with no walk sheet.
	const bool poseReady = !m_isMoving && m_isFrameOverridden
		&& m_ObjectType >= 0 && m_ObjectType < static_cast<int>(g_shapeTable.size())
		&& m_overrideFrame >= 0 && m_overrideFrame < 32
		&& g_shapeTable[m_ObjectType][m_overrideFrame].m_texture != nullptr;

	// Same 8-way walk billboards as NPCs when walk frames exist for this shape.
	if (poseReady || m_walkTextures.size() >= 8)
	{
		DrawWalkBillboard(m_walkTextures, m_walkTexturesUpright);
		return;
	}

	// Shapes without SW/NE walk frames fall back to ordinary shape drawing.
	// Temporarily lift m_Pos so InteractiveDraw / shape Draw see flying height.
	const float savedY = m_Pos.y;
	m_Pos.y += m_drawHeightOffset;
	InteractiveDraw();
	m_Pos.y = savedY;
}

void U7Object::CheckLighting()
{
	// Legacy no-op. Object draw samples g_Terrain->m_cellLighting; the old
	// O(visible × lights) m_isLit scan was not used for rendering.
	m_isLit = true;
}

void U7Object::Update()
{
	// Interest snapshot can list the same pointer twice when a stale chunk-map
	// ghost still overlaps the interest radius. One sim tick per frame.
	if (m_lastInterestUpdateFrame == g_CurrentUpdate)
		return;
	m_lastInterestUpdateFrame = g_CurrentUpdate;

	// Dispatch to the appropriate type-specific update function.
	// m_UnitType should be the source of truth.
	switch (m_UnitType)
	{
		case UnitTypes::UNIT_TYPE_STATIC:
			StaticUpdate();
			break;

		case UnitTypes::UNIT_TYPE_OBJECT:
			InteractiveUpdate();
			break;

		case UnitTypes::UNIT_TYPE_NPC:
			NPCUpdate();
			break;

		case UnitTypes::UNIT_TYPE_EGG:
			EggUpdate();
			break;

		case UnitTypes::UNIT_TYPE_MONSTER:   // New type for creatures spawned from eggs
			MonsterUpdate();
			break;

		default:
			break;
	}
}



void U7Object::HandleMonsterSpawnerEgg()
{
	EggData& egg = m_eggData;

	// Once-only eggs that have already hatched do nothing
	if (egg.m_onceOnly && egg.m_hasTriggered)
	{
		return;
	}

	// While the egg considers itself satisfied (hasTriggered), bail early.
	// Re-arming happens in EggUpdate when the player leaves the activation radius.
	// This prevents repeated work (and was part of the previous per-frame spawn issue).
	if (egg.m_hasTriggered)
	{
		return;
	}

	// Nocturnal eggs only trigger at night (rough heuristic: hour 20-6)
	if (egg.m_nocturnal)
	{
		if (g_hour < 20 && g_hour > 6)
			return;
	}

	U7Object* avatar = nullptr;
	if (g_Player)
		avatar = g_Player->GetAvatarObject();

	if (!avatar)
		return;

	float dist = Vector2Distance({ m_Pos.x, m_Pos.z }, { avatar->m_Pos.x, avatar->m_Pos.z });

	// Check activation criteria
	bool shouldActivate = false;
	switch (egg.m_criteria)
	{
		case EggCriteria::AvatarNear:
		case EggCriteria::PartyNear:
			if (dist <= (float)egg.m_distance && !egg.m_hasTriggered)
				shouldActivate = true;
			break;

		case EggCriteria::AvatarFootpad:
		case EggCriteria::PartyFootpad:
			// Very close / standing on it
			if (dist <= 1.5f && !egg.m_hasTriggered)
				shouldActivate = true;
			break;

		case EggCriteria::CachedIn:
			// Simulate original "chunk cached in" behavior: large radius around the egg.
			// Original U7 only kept a few chunks (~6x 16x16) in memory, so this triggered on load-in.
			// Here we treat it as AvatarNear with a fixed large radius.
			// Activation only on entry ( ! hasTriggered ); re-armed on cache-out in EggUpdate.
			if (dist <= CACHED_IN_RADIUS && !egg.m_hasTriggered)
			{
				shouldActivate = true;
				m_eggData.m_shouldReset = true;
			}
			break;

		default:
			// Other types (e.g. External) or unknown: use the egg's own distance (or 2x as fallback).
			if (dist <= (float)egg.m_distance * 2.0f)
				shouldActivate = true;
			break;
	}

	if (!shouldActivate)
		return;

	// Probability roll (0-100)
	if (egg.m_probability < 100)
	{
		int roll = g_NonVitalRNG ? (int)g_NonVitalRNG->RandomRange(0, 99) : (rand() % 100);
		if (roll >= egg.m_probability)
			return; // Didn't trigger this time
	}

	// Resolve the intended spawn shape early (this block used to live later).
	// We need the shape before the liveness check.
	int shapeToSpawn = egg.m_monsterShape;
	int datIndex = egg.m_monsterTypeIndex;

	// If for some reason we only had an index, resolve shape (legacy safety).
	if (datIndex >= 0 && datIndex < (int)g_monsterData.size() &&
	    (shapeToSpawn == 0 || shapeToSpawn == datIndex))
	{
		shapeToSpawn = g_monsterData[datIndex].m_shape;
	}
	if (shapeToSpawn <= 0 || shapeToSpawn > 1000)
	{
		shapeToSpawn = 529; // Rat-like default
	}

	// Find the matching MonsterData record (by datIndex if valid, else by shape) for real stats.
	const MonsterData* monData = nullptr;
	if (datIndex >= 0 && datIndex < (int)g_monsterData.size() &&
	    g_monsterData[datIndex].m_shape == shapeToSpawn)
	{
		monData = &g_monsterData[datIndex];
	}
	else
	{
		for (const auto& md : g_monsterData)
		{
			if (md.m_shape == shapeToSpawn)
			{
				monData = &md;
				break;
			}
		}
	}

	// Spatial "area occupied" check (simple anti-stacking for monster eggs).
	// Count live UNIT_TYPE_MONSTER objects of exactly this shape within a small radius
	// of the egg. If the count is already at or above the egg's intended spawn count,
	// skip spawning. The radius is kept small on purpose so we don't accidentally
	// count monsters that came from a different egg nearby.
	// If some of "our" previous spawns have died (or wandered outside this small radius),
	// we will only spawn the missing number (delta).
	int desiredCount = std::max(1, egg.m_spawnCount);
	int existingCount = 0;

	for (const auto& [id, objPtr] : g_objectList)
	{
		if (!objPtr)
			continue;

		U7Object* obj = objPtr.get();
		if (obj->GetIsDead() ||
		    obj->m_UnitType != UnitTypes::UNIT_TYPE_MONSTER ||
		    obj->m_ObjectType != shapeToSpawn)
			continue;

		float dist = Vector2Distance({ m_Pos.x, m_Pos.z }, { obj->m_Pos.x, obj->m_Pos.z });
		if (dist <= MONSTER_SPAWN_CHECK_RADIUS)
			++existingCount;
	}

	if (existingCount >= desiredCount)
	{
		// Camp still has enough live monsters from previous spawns. Mark satisfied
		// (so we don't re-evaluate every frame) and bail without spawning duplicates.
		egg.m_hasTriggered = true;
		return;
	}

	int toSpawn = std::max(0, desiredCount - existingCount);
	if (toSpawn <= 0)
	{
		egg.m_hasTriggered = true;
		return;
	}

	// We've decided to hatch. Spawn the (possibly reduced) number of monsters.

	for (int i = 0; i < toSpawn; ++i)
	{
		unsigned int newId = GetNextID();

		// Spawn slightly offset around the egg so they don't stack perfectly
		float offsetX = (i % 3 - 1) * 0.8f + (g_NonVitalRNG ? g_NonVitalRNG->RandomRangeFloat(-0.6f, 0.6f) : 0.0f);
		float offsetZ = (i / 3 - 1) * 0.8f + (g_NonVitalRNG ? g_NonVitalRNG->RandomRangeFloat(-0.6f, 0.6f) : 0.0f);

		U7Object* spawned = AddObject(shapeToSpawn, 0, newId,
			m_Pos.x + offsetX, m_Pos.y + 0.1f, m_Pos.z + offsetZ);

		if (spawned)
		{
			spawned->m_UnitType = UnitTypes::UNIT_TYPE_MONSTER;

			// Pull real stats from MONSTERS.DAT record when available (hp ~ strength, etc.)
			if (monData)
			{
				spawned->m_hp = (monData->m_hitPoints > 0 ? monData->m_hitPoints : monData->m_strength);
				spawned->m_BaseMaxHP = spawned->m_hp;
				spawned->m_BaseAttack = (monData->m_damage > 0 ? monData->m_damage : 5.0f);
				spawned->m_BaseDefense = monData->m_armor;
				spawned->m_combat = (monData->m_combat > 0 ? monData->m_combat : 10.0f);
			}
			else
			{
				spawned->m_hp = 20 + (g_NonVitalRNG ? (int)g_NonVitalRNG->RandomRange(0, 15) : 5);
				spawned->m_BaseMaxHP = spawned->m_hp;
				spawned->m_BaseAttack = 5.0f;
				spawned->m_BaseDefense = 0.0f;
				spawned->m_combat = 10.0f;
			}

			// Set the activity from the egg's workType (0 = combat). Non-combat monsters
			// (e.g. foxes, deer from non-combat eggs) are not hostile.
			spawned->m_currentActivity = egg.m_monsterWorkType;

			// Hostile if combat schedule OR evil/chaotic egg alignment (2/3).
			const bool hostile =
				egg.m_monsterWorkType == 0 ||
				egg.m_monsterAlignment == 2 ||
				egg.m_monsterAlignment == 3;
			if (hostile)
			{
				spawned->m_Team = 1; // 0 = neutral/player, 1 = hostile

				if (g_isCombatMode && g_mainState)
					g_mainState->EnsureCombatParticipant(static_cast<int>(newId));
			}

			spawned->MonsterInit();

			// Optional: give them a simple "attack player" activity later
			// For now they exist in the world and can be clicked / pathfound to.

			// Always give feedback in console when a monster actually appears
			//std::string hatchedMsg = "Monster egg hatched! (shape " + std::to_string(shapeToSpawn) + ")";
			//if (monData && !monData->m_name.empty())
			//	hatchedMsg += " " + monData->m_name;
			//AddConsoleString(hatchedMsg, YELLOW);

			if (g_LuaDebug || g_showEggs)
			{
				DebugPrint("MonsterSpawnerEgg hatched @ (" + std::to_string(m_Pos.x) + "," + std::to_string(m_Pos.z) +
					") -> spawned shape " + std::to_string(shapeToSpawn) + " id=" + std::to_string(newId));
			}
		}
	}

	egg.m_hasTriggered = true;

	// If not auto-resetting and once-only, it stays triggered
	if (!egg.m_autoReset && egg.m_onceOnly)
	{
		// It will stay dormant forever (or until save/load resets it)
	}
}

void U7Object::HandleProximitySoundEgg()
{

}

void U7Object::HandleJukeboxEgg()
{

}

static std::string CapitalizeMonsterName(const std::string& name)
{
	std::string out = name;
	bool capNext = true;
	for (char& ch : out)
	{
		const unsigned char c = static_cast<unsigned char>(ch);
		if (std::isspace(c) || c == '-')
		{
			capNext = true;
			continue;
		}
		if (capNext && std::isalpha(c))
		{
			ch = static_cast<char>(std::toupper(c));
		}
		capNext = false;
	}
	return out;
}

void U7Object::MonsterInit()
{
	m_speed = 5.0f;
	m_attackRange = MELEE_RANGE_TILES;
	m_attackCooldown = 3.0f;
	m_cooldownTimer = 0.0;
	m_name = CapitalizeMonsterName(g_objectDataTable[m_shapeData->m_shape].m_name);

	m_isFlying = false;
	m_canSeeInvisible = false;
	m_drawHeightOffset = 0.0f;
	for (const MonsterData& md : g_monsterData)
	{
		if (md.m_shape == m_ObjectType)
		{
			m_isFlying = md.m_flies;
			// Exult Monster_info::see_invisible is bit 7 of the flags byte.
			m_canSeeInvisible = (md.m_flagsByte & 0x80) != 0;
			// A 0 nibble stays 0. Weapon-shapes (insects, rat, snake) strike
			// with their WEAPONS.DAT row instead of this value.
			if (m_BaseAttack <= 0.0f && md.m_damage > 0)
				m_BaseAttack = static_cast<float>(md.m_damage);
			break;
		}
	}
	// Flying monsters (insects, etc.): draw/pick around waist height, feet path on ground.
	if (m_isFlying)
	{
		m_drawHeightOffset = 0.9f;
		// Insects (shape 517): harass at most ~twice per second.
		if (m_ObjectType == 517)
			m_attackCooldown = 0.5f;
	}

	// Build full action texture set + legacy walk table from this shape.
	m_walkTexturesUpright = false;
	if (FillNpcActionTextures(m_actionTextures, m_ObjectType))
	{
		CopyWalkTexturesFromActions(m_actionTextures, m_walkTextures);
	}
	else if (!FillWalkTextures(m_walkTextures, m_ObjectType))
	{
		m_walkTextures.clear();
		if (g_LuaDebug || g_showEggs)
		{
			DebugPrint("MonsterInit: shape " + std::to_string(m_ObjectType) +
				" missing walk frames; falling back to InteractiveDraw");
		}
	}

	// DrawWalkBillboard draws at m_Pos with no +0.5 offset (same as NPCs). Spawn
	// paths often pass integer tile coords; snap to tile center for a clean start.
	// Pick/drag bbox is centered on m_Pos and follows mid-tile movement.
	m_Pos.x = floorf(m_Pos.x) + 0.5f;
	m_Pos.z = floorf(m_Pos.z) + 0.5f;

	// Same as NPCInit: refresh pick box now that UnitType is MONSTER.
	SetPos(m_Pos);

	// EQUIP.DAT loot/weapons (pirates, guards, …). Inventory stays until death loot.
	ApplyMonsterEquipment(this);
}

void U7Object::InitUsecodeObjectSchedule()
{
	// Do not convert this to UNIT_TYPE_NPC or spawn an npc.dat slot.
	if (m_UnitType == UnitTypes::UNIT_TYPE_NPC)
		return;

	m_usecodeObjectSchedule = true;
	if (m_speed <= 0.0f)
		m_speed = 5.0f;
	if (m_walkTextures.empty())
	{
		m_walkTexturesUpright = false;
		if (FillNpcActionTextures(m_actionTextures, m_ObjectType))
			CopyWalkTexturesFromActions(m_actionTextures, m_walkTextures);
		else if (!FillWalkTextures(m_walkTextures, m_ObjectType))
			m_walkTextures.clear();
	}
	// Default combat (0) is for npc.dat. Wait until usecode picks loiter/sit/patrol.
	if (m_currentActivity == 0)
		m_currentActivity = 15;
	if (m_usecodeObjectProximityAt <= 0.0f)
	{
		const float delay = g_NonVitalRNG
			? g_NonVitalRNG->RandomRangeFloat(8.0f, 12.0f)
			: 8.0f + static_cast<float>(rand() % 5);
		m_usecodeObjectProximityAt = GetTime() + delay;
	}
}

void U7Object::HandleVoiceEgg()
{
	bool playing = false;
	switch (m_eggData.m_criteria)
	{
		case EggCriteria::CachedIn:
			// Large radius (simulating chunk load-in)
			if (!m_eggData.m_hasTriggered && Vector2Distance({m_Pos.x, m_Pos.z}, {g_Player->GetAvatarObject()->m_Pos.x, g_Player->GetAvatarObject()->m_Pos.z}) <= CACHED_IN_RADIUS)
			{
				playing = true;
				m_eggData.m_hasTriggered = true;
			}
			break;
		case EggCriteria::AvatarNear:
		case EggCriteria::PartyNear:
			if (!m_eggData.m_hasTriggered && Vector2Distance({m_Pos.x, m_Pos.z}, {g_Player->GetAvatarObject()->m_Pos.x, g_Player->GetAvatarObject()->m_Pos.z}) <= m_eggData.m_distance)
			{
				playing = true;
				m_eggData.m_hasTriggered = true;
			}
			break;
	}

	if (playing)
	{
		g_SoundSystem->PlaySound(m_eggData.m_audioFile);
	}
}

void U7Object::HandleWeatherEgg()
{
	if (!g_WeatherSystem || !g_Player)
	{
		return;
	}

	// Debug picker / Lua Clear or SetWeather: don't let eggs stomp until avatar walks away.
	if (g_WeatherSystem->IsManualOverride())
	{
		return;
	}

	U7Object* avatar = g_Player->GetAvatarObject();
	if (!avatar)
	{
		return;
	}

	EggData& egg = m_eggData;

	if (egg.m_hasTriggered && !egg.m_autoReset)
	{
		return;
	}
	if (egg.m_hasTriggered)
	{
		return; // auto-reset clears hasTriggered in EggUpdate when player leaves
	}

	if (egg.m_nocturnal && g_hour < 20 && g_hour > 6)
	{
		return;
	}

	const float distXZ = Vector2Distance(
		Vector2{ m_Pos.x, m_Pos.z },
		Vector2{ avatar->m_Pos.x, avatar->m_Pos.z });

	bool justTriggered = false;
	switch (egg.m_criteria)
	{
	case EggCriteria::CachedIn:
		if (distXZ <= CACHED_IN_RADIUS)
		{
			justTriggered = true;
			egg.m_shouldReset = true;
		}
		break;
	case EggCriteria::AvatarFootpad:
	case EggCriteria::PartyFootpad:
		if (distXZ <= 1.5f)
		{
			justTriggered = true;
		}
		break;
	case EggCriteria::AvatarNear:
	case EggCriteria::PartyNear:
	default:
		{
			const float radius = (egg.m_distance > 0)
				? static_cast<float>(egg.m_distance)
				: 2.0f;
			if (distXZ <= radius)
			{
				justTriggered = true;
			}
		}
		break;
	}

	if (!justTriggered)
	{
		return;
	}

	// One probability roll per visit; fail does not consume the egg (no hasTriggered).
	if (egg.m_rolledThisVisit)
	{
		return;
	}

	if (egg.m_probability < 100)
	{
		egg.m_rolledThisVisit = true;
		int roll = g_NonVitalRNG ? static_cast<int>(g_NonVitalRNG->RandomRange(0, 99)) : (rand() % 100);
		if (roll >= egg.m_probability)
		{
			return;
		}
	}
	else
	{
		egg.m_rolledThisVisit = true;
	}

	egg.m_hasTriggered = true;
	g_WeatherSystem->SetWeather(
		static_cast<int>(egg.m_specificValue),
		static_cast<int>(egg.m_durationMinutes),
		true,
		m_Pos,
		static_cast<int>(m_ID));
}

void U7Object::HandleTeleporterEgg()
{
	if (!g_Player)
	{
		return;
	}
	U7Object* avatar = g_Player->GetAvatarObject();
	if (!avatar)
	{
		return;
	}

	// Once-only / already hatched (unless auto-reset re-arms after leaving radius).
	if (m_eggData.m_hasTriggered && !m_eggData.m_autoReset)
	{
		return;
	}
	if (m_eggData.m_hasTriggered)
	{
		return; // auto-reset clears hasTriggered in EggUpdate when player leaves
	}

	// Nocturnal eggs only trigger at night (same heuristic as monster eggs).
	if (m_eggData.m_nocturnal)
	{
		if (g_hour < 20 && g_hour > 6)
		{
			return;
		}
	}

	const float distXZ = Vector2Distance(
		Vector2{ m_Pos.x, m_Pos.z },
		Vector2{ avatar->m_Pos.x, avatar->m_Pos.z });
	// Exult: hatch requires deltaz == 0 (same lift). A 1.0 allowance was wrongly
	// letting ground (Y=0) trigger eggs at lift 1 (e.g. Trinsic crate-teleport egg
	// at 1049,1,2267). Keep a tiny epsilon for surface-snap float noise only.
	const float deltaY = fabsf(avatar->m_Pos.y - m_Pos.y);
	const bool sameLift = deltaY <= 0.15f;

	bool justTriggered = false;
	switch (m_eggData.m_criteria)
	{
	case EggCriteria::CachedIn:
		if (sameLift && distXZ <= CACHED_IN_RADIUS)
		{
			justTriggered = true;
			m_eggData.m_shouldReset = true;
		}
		break;

	case EggCriteria::AvatarFootpad:
	case EggCriteria::PartyFootpad:
		// On the egg tile (footpad).
		if (sameLift && distXZ <= 1.5f)
		{
			justTriggered = true;
		}
		break;

	case EggCriteria::AvatarNear:
	case EggCriteria::PartyNear:
	default:
		// Default: proximity radius (Exult: any tile in area, exact lift).
		{
			const float radius = (m_eggData.m_distance > 0)
				? static_cast<float>(m_eggData.m_distance)
				: 2.0f;
			if (sameLift && distXZ <= radius)
			{
				justTriggered = true;
			}
		}
		break;
	}

	if (!justTriggered)
	{
		return;
	}

	// Probability 1-100 (100 = always).
	if (m_eggData.m_probability < 100)
	{
		const int roll = 1 + (rand() % 100);
		if (roll > static_cast<int>(m_eggData.m_probability))
		{
			// Still mark hatched so we don't re-roll every frame until reset.
			m_eggData.m_hasTriggered = true;
			return;
		}
	}

	m_eggData.m_hasTriggered = true;

	// Resolve destination (Exult Teleport_egg::hatch_now).
	// quality 255 → absolute coords in m_teleportDest.
	// otherwise → path egg (frame/type Path) with matching quality.
	Vector3 dest = m_eggData.m_teleportDest;
	const int eggnum = m_Quality & 0xff;
	bool haveDest = false;

	if (eggnum == 255)
	{
		haveDest = true;
	}
	else
	{
		// Prefer path egg with this quality id.
		for (const auto& [id, objPtr] : g_objectList)
		{
			U7Object* obj = objPtr.get();
			if (!obj || obj->m_UnitType != UnitTypes::UNIT_TYPE_EGG)
			{
				continue;
			}
			if (obj->m_ObjectType != 275)
			{
				continue;
			}
			if (obj->m_eggData.m_type != EggType::Path)
			{
				continue;
			}
			if ((obj->m_Quality & 0xff) != eggnum)
			{
				continue;
			}
			dest = obj->m_Pos;
			haveDest = true;
			break;
		}
		// Fallback to packed coords if no path egg found.
		if (!haveDest && (dest.x != 0.0f || dest.z != 0.0f))
		{
			haveDest = true;
		}
	}

	if (!haveDest)
	{
		AddConsoleString("Teleporter egg: no destination (path id " + std::to_string(eggnum) + ")");
		return;
	}

	// Snap party to destination (avatar + party members).
	auto teleportObject = [&](U7Object* who, float ox, float oz) {
		if (!who)
		{
			return;
		}
		Vector3 p = dest;
		p.x += ox;
		p.z += oz;
		who->m_pathWaypoints.clear();
		who->m_currentWaypointIndex = 0;
		who->m_pathfindingPending = false;
		who->m_isMoving = false;
		who->SetPos(p);
		who->SetDest(p);
	};

	teleportObject(avatar, 0.0f, 0.0f);

	const auto& partyIds = g_Player->GetPartyMemberIds();
	float offset = 0.5f;
	for (int npcId : partyIds)
	{
		if (npcId <= 0 || npcId == avatar->m_NPCID)
		{
			continue;
		}
		auto itNpc = g_NPCData.find(npcId);
		if (itNpc == g_NPCData.end() || !itNpc->second)
		{
			continue;
		}
		const int objId = itNpc->second->m_objectID;
		auto itObj = g_objectList.find(objId);
		if (itObj == g_objectList.end() || !itObj->second)
		{
			continue;
		}
		teleportObject(itObj->second.get(), offset, 0.0f);
		offset += 0.5f;
	}

	// Snap camera to avatar (RecalculateCamera is declared but not defined).
	g_camera.target = Vector3{ dest.x, 0.0f, dest.z };
	g_camera.position = Vector3Add(g_camera.target, Vector3{ 0.0f, g_cameraDistance, g_cameraDistance });
	// Refresh interest immediately so destination NPCs start scheduling this frame
	// (object Update pass already started against the old region).
	RebuildInterestCentersFromLocalPlayers();
	RebuildInterestChunkSet();
	AddConsoleString("Teleported to (" + std::to_string(static_cast<int>(dest.x))
		+ ", " + std::to_string(static_cast<int>(dest.z)) + ")");
}

void U7Object::HandlePathEgg()
{

}

void U7Object::HandleUsecodeEgg()
{
	U7Object* _avatar = g_Player->GetAvatarObject();

	if (m_eggData.m_hasTriggered && !m_eggData.m_autoReset)
	{
		return;
	}

	bool justTriggered = false;

	switch (m_eggData.m_criteria)
	{
		case EggCriteria::CachedIn:
			// Large radius (simulating chunk load-in)
			if (Vector2Distance({m_Pos.x, m_Pos.z}, {_avatar->m_Pos.x, _avatar->m_Pos.z}) <= CACHED_IN_RADIUS && !m_eggData.m_hasTriggered)
			{
				m_eggData.m_hasTriggered = true;
				justTriggered = true;
			}
			break;

		case EggCriteria::AvatarFootpad:
		{
			if (Vector3Equals(m_Pos, _avatar->m_Pos) && !m_eggData.m_hasTriggered)
			{
				m_eggData.m_hasTriggered = true;
				justTriggered = true;
			}
			break;
		}

		case EggCriteria::AvatarNear:
		case EggCriteria::PartyNear:
			if (Vector2Distance({m_Pos.x, m_Pos.z}, {_avatar->m_Pos.x, _avatar->m_Pos.z}) <= m_eggData.m_distance && !m_eggData.m_hasTriggered)
			{
				m_eggData.m_hasTriggered = true;
				justTriggered = true;
			}
			break;
	}

	if (justTriggered)
	{
		// Egg usecode funcs are stored as 0x500+N (1280+N). Scripts are named
		// utility_forge_0NNN.lua, utility_unknown_0NNN.lua, or utility_event_0NNN.lua.
		int scriptnumber = m_eggData.m_usecodeFunc;
		if (scriptnumber >= 1280)
			scriptnumber -= 1280;

		char numBuf[16];
		snprintf(numBuf, sizeof(numBuf), "%04d", scriptnumber);
		// The decompiler split egg scripts across several prefixes. Prefer the
		// specific Forge name so a generic utility_event fallback cannot shadow it.
		const std::string candidates[] = {
			std::string("utility_forge_") + numBuf,
			std::string("utility_unknown_") + numBuf,
			std::string("utility_event_") + numBuf,
			std::string("utility_clock_") + numBuf,
			std::string("utility_ship_") + numBuf,
		};

		auto scriptLoaded = [](const std::string& name) -> bool {
			if (!g_ScriptingSystem) return false;
			for (const auto& script : g_ScriptingSystem->m_scriptFiles)
			{
				if (script.first == name)
					return true;
			}
			return false;
		};

		std::string scriptname = candidates[0];
		for (const auto& name : candidates)
		{
			if (scriptLoaded(name))
			{
				scriptname = name;
				break;
			}
		}

		// Exult hatches usecode eggs with event 3 (egg) and the egg as itemref.
		NPCDebugPrint("Usecode egg @" + std::to_string((int)m_Pos.x) + "," +
			std::to_string((int)m_Pos.z) + " → " + scriptname +
			" (func=" + std::to_string(m_eggData.m_usecodeFunc) + ")");
		std::string result = g_ScriptingSystem->CallScript(scriptname, { 3, m_ID });
		if (!result.empty())
			NPCDebugPrint("Usecode egg script error: " + result);
	}
}

void U7Object::DebugPrintEggInfo() const
{
	const EggData& egg = m_eggData;

	// Header line
	int t = static_cast<int>(egg.m_type);
	const char* typeName = (t >= 0 && t < (int)(sizeof(g_eggTypeStrings)/sizeof(g_eggTypeStrings[0])))
		? g_eggTypeStrings[t] : "Unknown";

	AddConsoleString("EGG clicked @ (" + std::to_string((int)m_Pos.x) + ", " + std::to_string((int)m_Pos.y) + ", " + std::to_string((int)m_Pos.z) + ") - Type: " + typeName);

	// Activation requirements - one per line
	int c = static_cast<int>(egg.m_criteria);
	const char* critName = (c >= 0 && c < (int)(sizeof(g_eggCriteriaStrings)/sizeof(g_eggCriteriaStrings[0])))
		? g_eggCriteriaStrings[c] : "Unknown";

	AddConsoleString("  Criteria: " + std::string(critName) + "   (distance: " + std::to_string((int)egg.m_distance) + ")");
	AddConsoleString("  Probability: " + std::to_string((int)egg.m_probability) + "%");

	// Flags
	std::string flags;
	if (egg.m_onceOnly)     flags += "OnceOnly ";
	if (egg.m_nocturnal)    flags += "Nocturnal ";
	if (egg.m_autoReset)    flags += "AutoReset ";
	if (egg.m_hasTriggered) flags += "Triggered ";
	AddConsoleString("  Flags: " + (flags.empty() ? std::string("none") : flags));

	// Context-sensitive details - one field per line
	switch (egg.m_type)
	{
		case EggType::MonsterSpawner:
		{
			int shape = egg.m_monsterShape ? egg.m_monsterShape : 0;
			int datIdx = (egg.m_monsterTypeIndex >= 0 ? egg.m_monsterTypeIndex : -1);

			if (datIdx >= 0)
				AddConsoleString("  MonsterDatIndex (file record): " + std::to_string(datIdx));

			std::string monsterName;
			int resolvedShape = shape;
			if (datIdx >= 0 && datIdx < (int)g_monsterData.size())
			{
				const auto& md = g_monsterData[datIdx];
				if (md.m_shape) resolvedShape = md.m_shape;
				monsterName = md.m_name;
			}
			// Fallback: try match by shape in g_monsterData or object table
			if (resolvedShape && monsterName.empty())
			{
				for (const auto& md : g_monsterData)
				{
					if (md.m_shape == resolvedShape && !md.m_name.empty())
					{
						monsterName = md.m_name;
						break;
					}
				}
			}
			if (resolvedShape && monsterName.empty() && resolvedShape < 1024)
			{
				monsterName = g_objectDataTable[resolvedShape].m_name;
			}

			AddConsoleString("  Shape: " + std::to_string(resolvedShape ? resolvedShape : shape));
			if (!monsterName.empty())
				AddConsoleString("  Monster: " + monsterName);

			AddConsoleString("  SpawnCount: " + std::to_string(egg.m_spawnCount));

			// Alignment and schedule/workType info
			std::string alignStr = "unknown";
			switch (egg.m_monsterAlignment)
			{
				case 0: alignStr = "neutral"; break;
				case 1: alignStr = "good"; break;
				case 2: alignStr = "evil"; break;
				case 3: alignStr = "chaotic"; break;
			}
			AddConsoleString("  Alignment: " + alignStr);

			std::string schedStr = std::to_string((int)egg.m_monsterWorkType);
			if (egg.m_monsterWorkType == 0) schedStr += " (combat)";
			AddConsoleString("  WorkType/Schedule: " + schedStr);
			break;
		}

		case EggType::Usecode:
			AddConsoleString("  UsecodeFunc: " + std::to_string(egg.m_usecodeFunc));
			if (egg.m_usecodeFunc != 0)
			{
				int scriptNum = egg.m_usecodeFunc >= 1280 ? egg.m_usecodeFunc - 1280 : egg.m_usecodeFunc;
				std::stringstream scriptSS;
				scriptSS << "utility_event_" << std::setfill('0') << std::setw(4) << scriptNum
					<< " / utility_forge_" << std::setfill('0') << std::setw(4) << scriptNum
					<< " / utility_unknown_" << std::setfill('0') << std::setw(4) << scriptNum;
				AddConsoleString("  Script: " + scriptSS.str());
			}
			break;

		case EggType::Jukebox:
			AddConsoleString("  Track: " + std::to_string((int)egg.m_specificValue));
			break;

		case EggType::Voice:
			AddConsoleString("  SpecificValue: " + std::to_string((int)egg.m_specificValue));
			if (!egg.m_audioFile.empty())
				AddConsoleString("  AudioFile: " + egg.m_audioFile);
			break;

		case EggType::ProximitySound:
			AddConsoleString("  SoundID: " + std::to_string((int)egg.m_specificValue));
			break;

		case EggType::Teleporter:
			AddConsoleString("  Destination: (" + std::to_string((int)egg.m_teleportDest.x) + ", " + std::to_string((int)egg.m_teleportDest.z) + ")");
			if (egg.m_destMap != 0)
				AddConsoleString("  DestMap: " + std::to_string(egg.m_destMap));
			break;

		case EggType::Weather:
			AddConsoleString("  WeatherType: " + std::to_string((int)egg.m_specificValue) +
				" DurationMinutes: " + std::to_string((int)egg.m_durationMinutes));
			break;

		case EggType::Path:
			AddConsoleString("  PathID: " + std::to_string((int)egg.m_specificValue));
			break;

		default:
			AddConsoleString("  SpecificValue: " + std::to_string((int)egg.m_specificValue));
			break;
	}
}



void U7Object::DebugPrintMonsterInfo() const
{
	return;
	int shape = m_ObjectType;

	// Header
	AddConsoleString("MONSTER clicked @ (" + std::to_string((int)m_Pos.x) + ", " + std::to_string((int)m_Pos.z) + ") - Shape: " + std::to_string(shape));

	// Name: prefer monster dat, fallback to object table
	std::string name;
	for (const auto& md : g_monsterData)
	{
		if (md.m_shape == shape)
		{
			name = md.m_name;
			break;
		}
	}
	if (name.empty() && shape >= 0 && shape < 1024)
	{
		name = g_objectDataTable[shape].m_name;
	}
	if (name.empty())
		name = "Unknown";
	AddConsoleString("  Name: " + name);

	// Activity (using global names list)
	std::string actStr = (m_currentActivity >= 0 && m_currentActivity < (int)(sizeof(g_activityNames)/sizeof(g_activityNames[0])))
		? g_activityNames[m_currentActivity]
		: std::to_string(m_currentActivity);
	AddConsoleString("  Activity: " + actStr);

	// Alignment and base stats from monster data
	int alignment = -1;
	int str = 0, dex = 0, iq = 0, baseHP = 0;
	for (const auto& md : g_monsterData)
	{
		if (md.m_shape == shape)
		{
			alignment = md.m_alignmentFlags;
			str = md.m_strength;
			dex = md.m_dexterity;
			iq = md.m_intelligence;
			baseHP = md.m_hitPoints;
			break;
		}
	}

	std::string alignStr = "unknown";
	switch (alignment & 3)
	{
		case 0: alignStr = "neutral"; break;
		case 1: alignStr = "good"; break;
		case 2: alignStr = "evil"; break;
		case 3: alignStr = "chaotic"; break;
	}
	AddConsoleString("  Alignment: " + alignStr);

	AddConsoleString("  Strength: " + std::to_string(str));
	AddConsoleString("  Dexterity: " + std::to_string(dex));
	AddConsoleString("  Intelligence: " + std::to_string(iq));
	AddConsoleString("  Health: " + std::to_string((int)m_hp) + " (base " + std::to_string(baseHP) + ")");
}

void U7Object::Attack(int _UnitID)
{

}

void U7Object::Shutdown()
{

}

void U7Object::NPCDraw()
{
	if (ShouldLieFlat())
	{
		DrawCorpseFlat();
		return;
	}

	if (m_NPCData == nullptr)
	{
		return;
	}

	if (m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
	{
		return; // Xorinia the wisp is the only flat type, we'll handle her later.
	}

	DrawWalkBillboard(m_NPCData->m_walkTextures, m_NPCData->m_walkTexturesUpright);
}

namespace
{
	// Black Gate bodies.c: creature shape, remains shape, remains frame.
	// A downed creature keeps its own sleep frame. Death draws one of these.
	struct BodyRemains
	{
		int type;
		int shape;
		int frame;
	};

	const BodyRemains kBodyRemains[] = {
		{ 721, 400, 1 }, { 989, 400, 2 }, { 445, 400, 3 }, { 446, 400, 4 },
		{ 318, 400, 5 }, { 448, 400, 6 }, { 449, 400, 7 }, { 450, 400, 8 },
		{ 319, 400, 9 }, { 452, 400, 10 }, { 455, 400, 11 }, { 454, 400, 12 },
		{ 451, 400, 13 }, { 456, 400, 14 }, { 457, 400, 15 }, { 458, 400, 16 },
		{ 459, 400, 17 }, { 460, 400, 18 }, { 461, 400, 19 }, { 462, 400, 20 },
		{ 463, 400, 21 }, { 464, 400, 22 }, { 720, 400, 23 }, { 467, 400, 24 },
		{ 468, 400, 25 }, { 469, 400, 26 }, { 265, 400, 27 }, { 304, 400, 28 },
		{ 864, 400, 29 }, { 471, 400, 30 }, { 472, 400, 31 }, { 473, 414, 1 },
		{ 274, 414, 2 }, { 475, 414, 3 }, { 299, 414, 4 }, { 317, 414, 5 },
		{ 477, 414, 6 }, { 382, 414, 7 }, { 952, 414, 8 }, { 957, 414, 9 },
		{ 478, 414, 10 }, { 479, 414, 11 }, { 519, 414, 12 }, { 466, 414, 13 },
		{ 480, 414, 14 }, { 482, 414, 16 }, { 485, 414, 17 }, { 465, 414, 18 },
		{ 487, 414, 19 }, { 488, 414, 20 }, { 489, 414, 21 }, { 490, 414, 22 },
		{ 617, 414, 23 }, { 229, 414, 27 }, { 228, 414, 28 }, { 476, 778, 1 },
		{ 375, 778, 2 }, { 381, 778, 3 }, { 380, 778, 4 }, { 861, 778, 5 },
		{ 501, 778, 6 }, { 504, 778, 7 }, { 505, 778, 8 }, { 727, 778, 9 },
		{ 533, 778, 10 }, { 500, 778, 11 }, { 502, 778, 12 }, { 882, 892, 1 },
		{ 881, 892, 2 }, { 227, 892, 3 }, { 805, 892, 4 }, { 884, 892, 5 },
		{ 929, 892, 6 }, { 946, 892, 7 }, { 806, 892, 8 }, { 534, 892, 9 },
		{ 394, 892, 10 }, { 447, 892, 11 }, { 491, 892, 12 }, { 492, 892, 13 },
		{ 493, 892, 14 }, { 494, 892, 15 }, { 716, 892, 16 }, { 811, 892, 17 },
		{ 495, 892, 18 }, { 506, 892, 19 }, { 498, 892, 20 }, { 499, 892, 21 },
		{ 496, 892, 24 }, { 784, 892, 25 }, { 509, 377, 12 }, { 510, 892, 27 },
		{ 230, 892, 28 }, { 226, 892, 29 }, { 883, 762, 1 }, { 511, 762, 2 },
		{ 337, 762, 3 }, { 513, 762, 4 }, { 532, 762, 5 }, { 514, 762, 6 },
		{ 517, 762, 7 }, { 354, 762, 8 }, { 661, 762, 9 }, { 521, 762, 10 },
		{ 523, 762, 11 }, { 524, 762, 12 }, { 525, 762, 13 }, { 970, 762, 14 },
		{ 528, 762, 16 }, { 529, 762, 17 }, { 530, 762, 18 }, { 865, 762, 19 },
		{ 753, 762, 20 }, { 537, 762, 21 }, { 154, 762, 22 }, { 247, 762, 23 },
		{ 259, 762, 24 }, { 401, 762, 25 }, { 706, 762, 26 }, { 965, 400, 30 },
	};

	bool FlatFrameDrawable(int shape, int frame)
	{
		if (shape < 0 || shape >= static_cast<int>(g_shapeTable.size()))
			return false;
		if (frame < 0 || frame >= 32)
			return false;
		ShapeData& sd = g_shapeTable[shape][frame];
		return sd.IsValid() && sd.m_texture != nullptr && sd.m_texture->m_Texture.id > 0;
	}

	// KO and sleep: the creature's lie frame. Death: the remains sprite, when one exists.
	void ResolveLieFlatArt(const U7Object& obj, int& shape, int& frame)
	{
		shape = obj.m_ObjectType;
		frame = obj.m_isFrameOverridden ? obj.m_overrideFrame : obj.GetDeathFrameForFacing();
		if (!obj.IsDeathStatus())
			return;

		for (const BodyRemains& entry : kBodyRemains)
		{
			if (entry.type != obj.m_ObjectType)
				continue;
			if (FlatFrameDrawable(entry.shape, entry.frame))
			{
				shape = entry.shape;
				frame = entry.frame;
			}
			return;
		}
	}
}

void U7Object::DrawCorpseFlat()
{
	int shape = 0;
	int frame = 0;
	ResolveLieFlatArt(*this, shape, frame);
	if (!FlatFrameDrawable(shape, frame))
		return;

	ShapeData& sd = g_shapeTable[shape][frame];

	// Lie the creature's own frame flat and centered. Remains sprites are
	// authored flats and keep their hotspot placement. The billboard's 315°
	// facing is not applied here.
	const bool centerOnPos = (sd.GetDrawType() == ShapeDrawType::OBJECT_DRAW_BILLBOARD);

	int cellx = 0, celly = 0;
	if (!WorldToTerrainCell(static_cast<int>(m_Pos.x), static_cast<int>(m_Pos.z), cellx, celly))
		return;

	Color renderColor = g_Terrain
		? g_Terrain->m_cellLighting[cellx][celly]
		: Color{ 255, 255, 255, 255 };
	if (GetFirstPersonViewFade(m_Pos) <= 0.02f)
		return;
	ApplyFirstPersonViewFade(renderColor, m_Pos);
	ApplyInvisibilityGhostTint(renderColor);
	sd.DrawAsFlat(m_Pos, renderColor, Vector3{ 1, 1, 1 }, centerOnPos);
}

void U7Object::DrawWalkBillboard(const std::vector<std::vector<Texture*>>& walkTextures, bool uprightSheet)
{
	// Upright poses (sit, and a lie frame that is not drawn as a ground flat).
	const bool poseOverride = !m_isMoving && m_isFrameOverridden
		&& m_ObjectType >= 0 && m_ObjectType < static_cast<int>(g_shapeTable.size())
		&& m_overrideFrame >= 0 && m_overrideFrame < 32
		&& g_shapeTable[m_ObjectType][m_overrideFrame].m_texture != nullptr;

	// Verify all 8 directional animation vectors are properly sized (N frames OK).
	if (!poseOverride)
	{
		if (walkTextures.size() < 8)
		{
			return;
		}
		for (int i = 0; i < 8; i++)
		{
			if (walkTextures[i].empty() || walkTextures[i][0] == nullptr)
			{
				return;
			}
		}
	}

	// Draw at m_Pos (feet/world position). NPCs/monsters are stored at tile centers so
	// logical position matches what you see — no +0.5 draw hack.
	{
		const float refX = g_firstPersonEnabled ? g_camera.position.x : g_camera.target.x;
		const float refZ = g_firstPersonEnabled ? g_camera.position.z : g_camera.target.z;
		const float maxDist = g_firstPersonEnabled
			? (std::max(16.0f, g_firstPersonDrawRange) + 8.0f)
			: 64.0f;
		if (fabsf(m_Pos.x - refX) > maxDist || fabsf(m_Pos.z - refZ) > maxDist)
			return; // Outside draw range.
	}

	// Billboard tilt per direction: SW/W/NE/E use -45; NW/N/SE/S (flipped art) use +45.
	static const float kBillboardAngle[8] = {
		-45.0f, -45.0f, // SW, W
		45.0f, 45.0f,   // NW, N
		-45.0f, -45.0f, // NE, E
		45.0f, 45.0f    // SE, S
	};

	Texture* finalTexture = nullptr;
	float billboardAngle = -45.0f;
	bool drawingUprightSheet = false;

	Vector3 cameraAngle = Vector3Subtract(g_camera.position, g_camera.target);
	Vector3 cameraVector = Vector3{ cameraAngle.x, 0, cameraAngle.z };
	cameraVector = Vector3Normalize(cameraVector);
	float cameraAtan2 = atan2(cameraVector.x, cameraVector.z);

	float unitAtan2 = atan2(m_Direction.x, m_Direction.z);

	float angle = cameraAtan2 - unitAtan2;

	// Half of an 8-way sector so sector boundaries sit between compass points.
	angle += ((1.0 / 16.0) * (2 * PI));

	while (angle < 0) { angle += (2 * PI); }
	while (angle > (2 * PI)) { angle -= (2 * PI); }

	angle /= ((1.0 / 8.0) * (2 * PI));
	// One-sector correction: without this, away-from-camera showed NE instead of N
	// (and toward-camera SE instead of S).
	int finalAngle = (int(angle) + 7) % 8;

	const NpcActionTextures* actions = GetNpcActionTextures();
	const bool useActionTable = actions && actions->valid &&
		!(uprightSheet && (m_npcAnimAction == NpcAnimAction::Walk ||
		                   m_npcAnimAction == NpcAnimAction::Stand));

	// Pose override (sleeping, sitting, knocked out) — the shape's own frame.
	if (poseOverride)
	{
		finalTexture = &g_shapeTable[m_ObjectType][m_overrideFrame].m_texture->m_Texture;
		billboardAngle = m_overrideFrame % 2 ? 45.0f : 0.0f;
	}
	else if (useActionTable)
	{
		Texture* actionTex = GetNpcActionTexture(*actions, m_npcAnimAction, finalAngle, m_npcAnimPhase);
		if (actionTex)
			finalTexture = actionTex;
		else
			finalTexture = walkTextures[finalAngle][0];

		if (uprightSheet && m_npcAnimAction == NpcAnimAction::Walk)
		{
			billboardAngle = 0.0f;
			drawingUprightSheet = true;
		}
		else
		{
			billboardAngle = kBillboardAngle[finalAngle];
			if ((m_name == "Greg" || m_name == "Poutchouli" || m_name == "Mister Fisp") && billboardAngle < 0.0f)
				billboardAngle = -75.0f;
		}
	}
	else
	{
		// Legacy walk-table path (WalkSheets for walk/stand, or missing action bake).
		const int framerate = 200;
		const int frameCount = int(walkTextures[finalAngle].size());
		int thisTime = (int(GetTime() * 1000) / framerate) % frameCount;
		if (!m_isMoving || (g_mainState && g_mainState->m_paused)) thisTime = 0;

		finalTexture = walkTextures[finalAngle][thisTime];
		if (uprightSheet)
		{
			billboardAngle = 0.0f;
			drawingUprightSheet = true;
		}
		else
		{
			billboardAngle = kBillboardAngle[finalAngle];
			if ((m_name == "Greg" || m_name == "Poutchouli" || m_name == "Mister Fisp") && billboardAngle < 0.0f)
				billboardAngle = -75.0f;
		}
	}

	// U7 shape frames: 8 pixels = 1 tile. Replacement sheets are upright art at
	// arbitrary resolution — scale to a fixed 4-tile character height instead.
	Vector3 dims;
	Vector3 finalPos = m_Pos;
	if (drawingUprightSheet)
	{
		constexpr float kUprightWorldHeight = 4.5f;
		constexpr float kUprightWidthScale = 1.5f; // WalkSheet art reads thin; fatten width only.
		const float aspect = float(finalTexture->width) / float(finalTexture->height);
		dims = { kUprightWorldHeight * aspect * kUprightWidthScale, kUprightWorldHeight, 1.0f };
		// DrawBillboardPro origin {0,0} is the billboard center; lift by half height
		// so the bottom of the sprite sits on the ground at m_Pos.
		finalPos.y += dims.y * 0.6f;
		dims.x = dims.x * .70f;
		dims.y = dims.y * 1.2f;
	}
	else if (poseOverride && IsSleepingPose())
	{
		// Lie-frame cels are short. Origin {0,0} is the quad center, so half the
		// cel height puts the lowest pixel on the feet instead of at chest height.
		dims = { float(finalTexture->width) / 8.0f, float(finalTexture->height) / 8.0f, 1 };
		finalPos.y += dims.y * 0.5f;
	}
	else
	{
		dims = { float(finalTexture->width) / 8.0f, float(finalTexture->height) / 8.0f, 1 };
		finalPos.y += m_shapeData->m_Dims.y * .62f;
	}
	// Flying creatures (Swarm insects, etc.): hover near waist height; shadow stays on ground.
	// A knocked-out or sleeping flyer is on the ground (original FallToGround).
	if (!(poseOverride && IsSleepingPose()))
		finalPos.y += m_drawHeightOffset;

	const float viewFade = GetFirstPersonViewFade(m_Pos);
	if (viewFade <= 0.02f)
		return;

	constexpr float kDropShadowScale = 1.5f;
	const Vector3 shadowPos = FlatUnderFeetOrigin(m_Pos, kDropShadowScale, 0.02f);
	SetMaterialTexture(&g_ResourceManager->GetModel("Models/3dmodels/flat.obj")->GetModel().materials[0], MATERIAL_MAP_DIFFUSE, *g_ResourceManager->GetTexture("Images/dropshadow.png"));
	Color shadowTint = BLACK;
	shadowTint.a = static_cast<unsigned char>(std::clamp(
		static_cast<int>(std::lround(255.0f * viewFade)), 0, 255));
	if (IsInvisible())
	{
		shadowTint.a = static_cast<unsigned char>((static_cast<int>(shadowTint.a) * 70) / 255);
	}
	rlDisableDepthMask();
	DrawModel(g_ResourceManager->GetModel("Models/3dmodels/flat.obj")->GetModel(), shadowPos, kDropShadowScale, shadowTint);
	rlEnableDepthMask();

	// Locked first-person: draw the ground shadow only — the walk billboard would
	// fill the view (blonde Avatar hair band when looking up).
	if (g_firstPersonEnabled && IsCameraLocked() && m_ID == g_cameraLockObjectId)
		return;

	BeginShaderMode(g_alphaDiscard);

	int cellx = 0, celly = 0;
	Color lighting = g_Terrain
		? (WorldToTerrainCell(static_cast<int>(m_Pos.x), static_cast<int>(m_Pos.z), cellx, celly)
			? g_Terrain->m_cellLighting[cellx][celly]
			: g_Terrain->GetAmbientLightingColor())
		: Color{ 255, 255, 255, 255 };

	// Apply green tint if F11 script debug is enabled and unit has a non-default script
	// Also check for conversation trees (NPCs with dialogue scripts)
	if (g_showScriptedObjects &&
	    ((m_shapeData->m_luaScript != "" && m_shapeData->m_luaScript != "default") || m_hasConversationTree))
	{
		lighting.r = (lighting.r + 0) / 2;
		lighting.g = (lighting.g + 255) / 2;
		lighting.b = (lighting.b + 0) / 2;
	}
	else if (g_showScriptedObjects && m_objectData && !m_objectData->m_isNotWalkable)
	{
		lighting.r = (lighting.r + 0) / 2;
		lighting.g = (lighting.g + 0) / 2;
		lighting.b = (lighting.b + 255) / 2;
	}

	ApplyFirstPersonViewFade(lighting, m_Pos);
	ApplyInvisibilityGhostTint(lighting);

	DrawBillboardPro(g_camera, *finalTexture, Rectangle{ 0, 0, float(finalTexture->width), float(finalTexture->height) }, finalPos, Vector3{ 0, 1, 0 },
		Vector2{ dims.x, dims.y }, Vector2{ 0, 0 }, billboardAngle, lighting);
	EndShaderMode();

	// Casting glow outside alphaDiscard: 859 frames are tiny; linear filter + 0.5
	// alpha cutoff was discarding almost every stretched sample.
	DrawCastingFramesOverlay(finalPos, Vector2{ dims.x, dims.y }, billboardAngle, lighting);
}

void U7Object::CustomMeshDraw(Color color)
{
	float m_rotation = 0.0f;
	if (!m_Visible)
	{
		return;
	}
	Vector3 finalPos = Vector3Add(m_Pos, m_anchorPos);
	m_customMesh->UpdateAnim("idle");
	DrawModelEx(m_customMesh->GetModel(), finalPos, { 0, 1, 0 }, m_rotation, m_Scaling, color);
}

void U7Object::DrawMeshId()
{
	if (!m_Visible || m_isContained || !m_ShouldDraw || !m_shapeData)
		return;
	if (IsUsecodeAvatarOverlay())
		return; // Same skip as InteractiveDraw: no outline/pick on the token.
	if (!ObjectWantsScreenSpaceOutline(this))
		return;
	const float fade = GetFirstPersonViewFade(m_centerPoint);
	if (fade <= 0.02f)
		return;
	Color idColor = MakeMeshOutlineIdColor(m_ID);
	idColor.a = static_cast<unsigned char>(std::clamp(
		static_cast<int>(std::lround(255.0f * fade)), 0, 255));
	// Match InteractiveDraw → ShapeData::Draw (shape scale, not object m_Scaling).
	m_shapeData->DrawMeshId(m_Pos, m_Angle, idColor);
}

// Helper function to convert activity ID to script name
static std::string GetActivityScriptName(int activityId)
{
	// Map activity IDs to descriptive script names
	static const char* ACTIVITY_SCRIPT_NAMES[] = {
		"combat",          // 0
		"pace_horz",       // 1  (horizontal pace)
		"pace_vert",       // 2  (vertical pace)
		"talk",            // 3
		"dance",           // 4
		"eat",             // 5
		"farm",            // 6
		"tend_shop",       // 7
		"miner",           // 8
		"hound",           // 9
		"stand",           // 10
		"loiter",          // 11
		"wander",          // 12
		"blacksmith",      // 13
		"sleep",           // 14
		"wait",            // 15
		"sit",             // 16  (major sit)
		"graze",           // 17
		"bake",            // 18
		"sew",             // 19
		"shy",             // 20
		"lab",             // 21
		"thief",           // 22
		"waiter",          // 23
		"special",         // 24
		"kid_games",       // 25
		"eat_at_inn",      // 26
		"duel",            // 27
		"preach",          // 28
		"patrol",          // 29
		"desk_work",       // 30
		"follow_avatar"    // 31
	};

	if (activityId >= 0 && activityId <= 31)
	{
		return std::string("activity_") + ACTIVITY_SCRIPT_NAMES[activityId];
	}

	// Fallback for invalid activity IDs
	return "activity_" + std::to_string(activityId);
}

void U7Object::UpdateUsecodeObjectSchedule()
{
	if (!g_ScriptingSystem)
		return;

	const int currentActivity = static_cast<int>(m_currentActivity);
	const bool runActivity = (currentActivity >= 0 && currentActivity <= 31);

	if (runActivity && currentActivity != m_usecodeObjectLastActivity)
	{
		if (m_usecodeObjectLastActivity >= 0)
		{
			std::string old_script = GetActivityScriptName(m_usecodeObjectLastActivity) +
				"_" + std::to_string(m_ID);
			if (g_ScriptingSystem->IsCoroutineActive(old_script))
				g_ScriptingSystem->CleanupCoroutine(old_script);
		}

		if (!m_pathfindingPending && g_ScriptingSystem->TryConsumeScriptStart())
		{
			std::string new_script = GetActivityScriptName(currentActivity) +
				"_" + std::to_string(m_ID);
			std::vector<ScriptingSystem::LuaArg> args = { m_ID };
			const std::string callResult = g_ScriptingSystem->CallScript(new_script, args);
			if (callResult.empty())
				m_usecodeObjectLastActivity = currentActivity;
		}
	}
	else if (runActivity && !m_pathfindingPending)
	{
		std::string script_name = GetActivityScriptName(currentActivity) +
			"_" + std::to_string(m_ID);
		if (g_ScriptingSystem->IsCoroutineYielded(script_name) &&
			g_ScriptingSystem->TryConsumeScriptResume())
		{
			std::vector<ScriptingSystem::LuaArg> args = { m_ID };
			g_ScriptingSystem->ResumeCoroutine(script_name, args);
		}
	}

	if (IsInUsecodeScript())
		return;
	if (!m_Visible || m_isContained)
		return;
	if (g_ConversationState && g_StateMachine &&
		g_StateMachine->GetCurrentState() == STATE_CONVERSATIONSTATE)
		return;
	if (!g_Player)
		return;
	U7Object* avatar = g_Player->GetAvatarObject();
	if (!avatar)
		return;
	if (Vector2Distance({ m_Pos.x, m_Pos.z }, { avatar->m_Pos.x, avatar->m_Pos.z }) > 16.0f)
		return;

	const float now = GetTime();
	if (now >= m_usecodeObjectProximityAt)
	{
		const float delay = g_NonVitalRNG
			? g_NonVitalRNG->RandomRangeFloat(8.0f, 12.0f)
			: 8.0f + static_cast<float>(rand() % 5);
		m_usecodeObjectProximityAt = now + delay;
		Interact(0);
	}
}

void U7Object::NPCUpdate()
{
	UpdateInvisibilityTimer();
	UpdateCharmTimer();
	UpdateMightTimer();

	// An Tym. The Avatar and the party keep acting. Everyone else holds.
	if (TimeIsStopped() && !IsPartyActor(this))
	{
		if (IsDeathStatus())
		{
			if (!m_isFrameOverridden)
				SetOverrideFrame(GetDeathFrameForFacing());
			UpdateNpcAnim(g_Engine ? g_Engine->LastFrameInSeconds() : 0.0f);
			return;
		}
		m_pathWaypoints.clear();
		m_currentWaypointIndex = 0;
		m_pathfindingPending = false;
		m_isSchedulePath = false;
		m_isMoving = false;
		m_combatMoveOrder = false;
		SetDest(m_Pos);
		UpdateNpcAnim(g_Engine ? g_Engine->LastFrameInSeconds() : 0.0f);
		return;
	}

	// Corpses: no schedules, combat AI, conversation scripts, or movement.
	if (IsDeathStatus())
	{
		if (!m_isFrameOverridden)
			SetOverrideFrame(GetDeathFrameForFacing());
		UpdateNpcAnim(g_Engine ? g_Engine->LastFrameInSeconds() : 0.0f);
		return;
	}

	UpdatePoisonTimer();
	UpdateSleepTimer();
	UpdateDance();

	// Cast / craft scripts must tick even while combat is paused or on Hold —
	// those paths return early below and would otherwise freeze the cast anim.
	if (IsDancing() || IsTrembling())
	{
		m_pathWaypoints.clear();
		m_currentWaypointIndex = 0;
		m_pathfindingPending = false;
		m_isSchedulePath = false;
		m_isMoving = false;
		m_combatMoveOrder = false;
		SetDest(m_Pos);
	}
	UpdateUsecodeScript();
	UpdateNpcAnim(g_Engine ? g_Engine->LastFrameInSeconds() : 0.0f);

	// Exult: asleep / knocked-out — lie still; sleep timer above still mends.
	if ((m_flags & kObjFlagAsleep) != 0 || IsKnockedOut())
		return;

	if (IsTrembling())
		return;

	if (IsDancing())
	{
		ApplyDancePose();
		return;
	}

	// Don't run schedule activity scripts while in the party (including the Avatar).
	// Avatar was previously excluded from this skip (m_NPCID != 0), so Talk/Combat
	// activities could run on NPC 0 — self-Interact / npc_frame flicker at game start.
	// Movement for party members still runs below.
	bool isCompanionInParty = (g_Player && g_Player->NPCIDInParty(m_NPCID) && m_NPCID != 0);
	bool isPartyMember = (m_NPCID == 0) || (g_Player && g_Player->NPCIDInParty(m_NPCID));
	bool skipScheduleActivities = isPartyMember; // Avatar + companions

	// Entering the Avatar interest bubble after being out of range (or first tick):
	// force a fresh "most recent schedule slot" apply on the next activity batch.
	constexpr unsigned int kDormantUpdateGap = 90; // ~1.5s at 60fps
	const bool wakingIntoInterest =
		(m_lastNpcUpdateFrame == 0) ||
		(g_CurrentUpdate > m_lastNpcUpdateFrame + kDormantUpdateGap);
	if (wakingIntoInterest)
	{
		// Only arm wake-snap when actually schedule-following. Otherwise a later
		// start_npc_schedule (e.g. Petre/Finnigan after the intro) inherits a stale
		// snap flag and teleports across town instead of pathfinding.
		if (m_followingSchedule && !skipScheduleActivities)
			m_scheduleWakeSnapPending = true;
		// Re-resolve schedule even if the clock slot hasn't changed since we last ran.
		m_lastSchedule = -1;
		// Restart activity scripts when coming back online (stale coroutines from
		// before we left range shouldn't keep us stuck with "No Schedule").
		if (!skipScheduleActivities &&
		    g_NPCData.find(m_NPCID) != g_NPCData.end() && g_NPCData[m_NPCID])
		{
			NPCData* wakeData = g_NPCData[m_NPCID].get();
			if (wakeData->m_lastActivity >= 0)
			{
				std::string old_script =
					GetActivityScriptName(wakeData->m_lastActivity) + "_" + std::to_string(m_NPCID);
				if (g_ScriptingSystem && g_ScriptingSystem->IsCoroutineActive(old_script))
					g_ScriptingSystem->CleanupCoroutine(old_script);
				wakeData->m_lastActivity = -1;
			}
		}
	}
	m_lastNpcUpdateFrame = g_CurrentUpdate;

	if (!isPartyMember && m_Team == 1 && g_isCombatMode)
	{
		HostileCombatUpdate();
		return;
	}

	// Charmed onto the party's side. Same fight loop as a summon, without the
	// off-map despawn. Turn-based waits for this unit's own turn.
	if (!isPartyMember && m_Team == 2 && (m_flags & kObjFlagCharmed) != 0)
	{
		if (g_isCombatMode && g_mainState && g_mainState->m_combatMode
			&& g_mainState->m_combatMode->GetStyle() == CombatStyle::TurnBased)
		{
			return;
		}
		AlliedMonsterUpdate();
		return;
	}

	if (isPartyMember && g_isCombatMode)
	{
		RefreshPartyAttackRangeFromWeapon(this);

		if (g_mainState && g_mainState->IsCombatOrdersPaused())
		{
			// Turn-Based Resolving: only the active unit may finish a Move order.
			if (g_mainState->CanCombatUnitAct(this)
			    && (m_combatOrderMode == CombatOrderMode::Move || m_combatMoveOrder))
			{
				UpdateMovement();
				return;
			}
			return;
		}

		if (m_combatOrderMode == CombatOrderMode::Hold
		    || m_combatOrderMode == CombatOrderMode::Automatic)
		{
			// Hold: stand. Automatic in combat: no auto-acquire (tactics later).
			m_target = 0;
			m_combatMoveOrder = false;
			m_pathWaypoints.clear();
			m_currentWaypointIndex = 0;
			m_pathfindingPending = false;
			m_isMoving = false;
			SetDest(m_Pos);
			return;
		}

		if (m_combatOrderMode == CombatOrderMode::Move || m_combatMoveOrder)
		{
			UpdateMovement();

			// Arrived, or path failed / idle with nothing left to walk — become Hold.
			if (!m_isMoving && m_pathWaypoints.empty() && !m_pathfindingPending)
			{
				m_combatMoveOrder = false;
				m_combatOrderMode = CombatOrderMode::Hold;
				SetDest(m_Pos);
			}

			return;
		}

		// Attack: only fight an assigned target. Losing it → Hold + auto-pause
		// via NotifyCombatantCannotContinue (ranged may drain cooldown first).
		if (m_target == 0)
		{
			U7Object* weapon = GetEquippedWeapon(this);
			const int weaponShape = (weapon && weapon->m_shapeData) ? weapon->m_shapeData->m_shape : -1;
			if (IsRangedWeaponShape(weaponShape)
			    && (m_cooldownTimer > 0.0f || m_npcAnimPlaying))
			{
				m_pathWaypoints.clear();
				m_currentWaypointIndex = 0;
				m_pathfindingPending = false;
				m_isMoving = false;
				SetDest(m_Pos);
				if (m_cooldownTimer > 0.0f && !m_npcAnimPlaying)
					m_cooldownTimer -= g_Engine->LastFrameInSeconds();
				return;
			}
			if (g_mainState && !g_mainState->IsCombatOrdersPaused())
				g_mainState->NotifyCombatantCannotContinue(this, "has no target!");
			return;
		}

		EngageCombatTarget();

		UpdateMovement();
		return;
	}

	// Increase batch size so fewer NPCs are checked per frame for starting/resuming activity scripts.
	// This reduces the number of script starts/resumes per frame for background NPCs.
	int batchSize = 48; // tune between 32..128 depending on performance vs responsiveness

	// totalAssigned is the number of NPC batch indices assigned so far (compact)
	int totalAssigned = s_nextNpcBatchIndex.load();
	if (totalAssigned <= 0) totalAssigned = 1;
	int numBatches = (totalAssigned + batchSize - 1) / batchSize;
	if (numBatches <= 0) numBatches = 1;

	// Use the global update counter so batch rotation is tied to the main update loop
	// (this mirrors the previous behavior before the per-call s_frameCounter change)
	int batchIndex = static_cast<int>(g_CurrentUpdate % numBatches);

	// Ensure this NPC has a batch index; if not, assign one lazily.
	if (m_npcBatchIndex < 0)
	{
		m_npcBatchIndex = s_nextNpcBatchIndex.fetch_add(1);
		// update totalAssigned/numBatches for this frame's decision if needed (safe skip, will run next cycle)
		totalAssigned = s_nextNpcBatchIndex.load();
		numBatches = (totalAssigned + batchSize - 1) / batchSize;
		if (numBatches <= 0) numBatches = 1;
		// recompute batchIndex in case numBatches changed (keep consistency for this frame)
		batchIndex = static_cast<int>(g_CurrentUpdate % numBatches);
	}

	bool shouldUpdateActivity = ((m_npcBatchIndex % numBatches) == batchIndex);

	// Optional targeted debug: only emit verbose per-NPC diagnostics when g_LuaDebug is enabled.
	//if (m_NPCID == 75 && g_LuaDebug)
	//{
	//	std::stringstream ss;
	//	ss << "NPCUpdate Debug id=" << m_NPCID
	//	   << " batchIndexAssigned=" << m_npcBatchIndex
	//	   << " totalAssigned=" << totalAssigned
	//	   << " numBatches=" << numBatches
	//	   << " frameBatchIndex=" << batchIndex
	//	   << " shouldUpdateActivity=" << (shouldUpdateActivity ? 1 : 0)
	//	   << " followingSchedule=" << (m_followingSchedule ? 1 : 0)
	//	   << " pathfindingPending=" << (m_pathfindingPending ? 1 : 0)
	//	   << " isSchedulePath=" << (m_isSchedulePath ? 1 : 0)
	//	   << " isMoving=" << (m_isMoving ? 1 : 0)
	//	   << " currentDest=(" << m_Dest.x << "," << m_Dest.y << "," << m_Dest.z << ")";
	//	NPCDebugPrint(ss.str());
	//}

	// Kill leftover Avatar/party activity coroutines (e.g. activity_talk_0 from before this fix).
	if (skipScheduleActivities && g_NPCData.find(m_NPCID) != g_NPCData.end() && g_NPCData[m_NPCID])
	{
		int lastActivity = g_NPCData[m_NPCID]->m_lastActivity;
		if (lastActivity >= 0)
		{
			std::string old_script = GetActivityScriptName(lastActivity) + "_" + std::to_string(m_NPCID);
			if (g_ScriptingSystem->IsCoroutineActive(old_script))
			{
				NPCDebugPrint("Stopping party/Avatar activity coroutine: " + old_script);
				g_ScriptingSystem->CleanupCoroutine(old_script);
			}
			g_NPCData[m_NPCID]->m_lastActivity = -1;
		}
	}

	// Schedule slot apply runs every in-range frame (not activity-batched) so NPCs
	// that just entered the Avatar bubble pick up their active activity immediately.
	// Activity *script* start/resume stays batched below.
	if (m_followingSchedule && g_NPCData.find(m_NPCID) != g_NPCData.end() && !skipScheduleActivities)
	{
		NPCData* npcData = g_NPCData[m_NPCID].get();

		// Time changed, first apply, or wake-into-range (m_lastSchedule forced to -1).
		if (m_lastSchedule != (int)g_scheduleTime)
		{
			if (!npcData->m_schedule.empty())
			{
				// Exact slot if listed; else continue the most recent earlier slot
				// (Paul/Meryl/Dustin only define times 0 and 2).
				const NPCSchedule* activeSchedule =
					FindActiveScheduleEntry(npcData->m_schedule, (int)g_scheduleTime);

				if (activeSchedule)
				{
					npcData->m_currentActivity = (int)activeSchedule->m_activity;

					// Build destination at tile center (matches NPC standing/draw position).
					Vector3 dest = {
						float(activeSchedule->m_destX) + 0.5f,
						0.0f,
						float(activeSchedule->m_destY) + 0.5f
					};

					// Schedule coords often land on tables/chairs — snap to nearest ground-walkable.
					if (g_pathfindingSystem)
					{
						const int gx = (int)floorf(dest.x);
						const int gz = (int)floorf(dest.z);
						if (!g_pathfindingSystem->GetCachedGroundWalkable(gx, gz))
						{
							bool found = false;
							for (int r = 1; r <= 8 && !found; ++r)
							{
								for (int dz = -r; dz <= r && !found; ++dz)
								{
									for (int dx = -r; dx <= r && !found; ++dx)
									{
										if (abs(dx) != r && abs(dz) != r)
											continue;
										const int tx = gx + dx;
										const int tz = gz + dz;
										if (g_pathfindingSystem->GetCachedGroundWalkable(tx, tz))
										{
											dest = { tx + 0.5f, 0.0f, tz + 0.5f };
											found = true;
										}
									}
								}
							}
						}
					}

					const float distToSched = Vector2Distance({ m_Pos.x, m_Pos.z }, { dest.x, dest.z });

					// Already at (or next to) schedule destination — commit slot, allow activity.
					if (distToSched <= 2.5f)
					{
						m_lastSchedule = (int)g_scheduleTime;
						m_pendingScheduleTime = -1;
						m_isSchedulePath = false;
						m_pathfindingPending = false;
						m_scheduleWakeSnapPending = false;
					}
					else if (g_mainState->IsNpcSchedulesEnabled() && g_mainState->m_npcPathfindingEnabled)
					{
						// Snap on wake into the Avatar bubble (or teleport-in). Continuously
						// simulated NPCs pathfind — don't teleport Spark to lunch mid-walk.
						constexpr float kScheduleSnapTiles = 16.0f;
						if (m_scheduleWakeSnapPending && distToSched > kScheduleSnapTiles)
						{
							if (IsSittingPose() || IsSleepingPose() || m_furnitureObjectId >= 0)
								ClearOverrideFrame(&dest);
							SetPos(dest);
							SetDest(dest);
							m_lastSchedule = (int)g_scheduleTime;
							m_pendingScheduleTime = -1;
							m_isSchedulePath = false;
							m_pathfindingPending = false;
							m_pathWaypoints.clear();
							m_currentWaypointIndex = 0;
							m_isMoving = false;
							m_scheduleWakeSnapPending = false;
						}
						// Don't commit m_lastSchedule until a path succeeds — otherwise a single
						// failure (Spark→inn) never retries and eat_at_inn paths to a house chair.
						else
						{
							m_scheduleWakeSnapPending = false;
							const float now = GetTime();
							if (!m_pathfindingPending && !m_isSchedulePath && now >= m_schedulePathRetryAt)
							{
								// Stand up immediately toward the new schedule dest — don't wait for
								// the background path result (that delay looked like stand-up lag).
								if (IsSittingPose() || IsSleepingPose() || m_furnitureObjectId >= 0)
									ClearOverrideFrame(&dest);

								m_pathfindingPending = true;
								m_pendingScheduleTime = (int)g_scheduleTime;
								m_schedulePathRetryAt = now + 2.0f;
								g_mainState->EnqueueSchedulePathRequest(m_NPCID, GetPos(), dest);
							}
						}
					}
					else
					{
						// Pathfinding disabled: teleport and commit.
						SetPos(dest);
						SetDest(dest);
						m_lastSchedule = (int)g_scheduleTime;
						m_pendingScheduleTime = -1;
						m_isSchedulePath = false;
						NPCDebugPrint("Schedule: NPC " + std::to_string(m_NPCID) + " teleported to (" +
							std::to_string((int)dest.x) + "," + std::to_string((int)dest.z) + ") (pathfinding or schedules disabled)");
					}
				}
				else
				{
					// Empty/unusable schedule list — don't retry every frame.
					m_lastSchedule = (int)g_scheduleTime;
					m_scheduleWakeSnapPending = false;
				}
			}
			else
			{
				m_lastSchedule = (int)g_scheduleTime;
				m_scheduleWakeSnapPending = false;
			}
		}
	}

	// Activity coroutine management - check if activity has changed
	// Only run activity scripts if schedules are enabled for this NPC
	// IMPORTANT: skip activity/coroutines for Avatar + party, but continue with movement below
	if (shouldUpdateActivity && m_followingSchedule && g_NPCData.find(m_NPCID) != g_NPCData.end() && !skipScheduleActivities)
	{
		NPCData* npcData = g_NPCData[m_NPCID].get();

		int currentActivity = g_NPCData[m_NPCID]->m_currentActivity;
		int lastActivity = g_NPCData[m_NPCID]->m_lastActivity;

		// Debug: log activity values for the NPC being checked (only when verbose debug enabled)
		if (m_NPCID == 75 && g_LuaDebug)
		{
			std::stringstream ss;
			ss << "NPCActivity Debug id=" << m_NPCID
			   << " currentActivity=" << currentActivity
			   << " lastActivity=" << lastActivity;
			NPCDebugPrint(ss.str());
		}

		// Has activity changed?
		if (currentActivity != lastActivity)
		{
			// Cleanup old coroutine if it exists
			if (lastActivity >= 0)
			{
				std::string old_script = GetActivityScriptName(lastActivity) + "_" + std::to_string(m_NPCID);
				if (g_ScriptingSystem->IsCoroutineActive(old_script))
				{
					g_ScriptingSystem->CleanupCoroutine(old_script);
				}
			}

			// Only start activity once near the schedule destination. Otherwise
			// eat_at_inn finds a chair in the NPC's house (west of Spark) instead of the inn.
			bool nearScheduleDest = true;
			if (const NPCSchedule* active =
					FindActiveScheduleEntry(npcData->m_schedule, (int)g_scheduleTime))
			{
				Vector3 schedDest = {
					float(active->m_destX) + 0.5f, 0.0f, float(active->m_destY) + 0.5f
				};
				nearScheduleDest =
					Vector2Distance({ m_Pos.x, m_Pos.z }, { schedDest.x, schedDest.z }) <= 10.0f;
			}

			if (!m_pathfindingPending && !m_isSchedulePath && nearScheduleDest)
			{
				// Start new activity script
				std::string new_script = GetActivityScriptName(currentActivity) + "_" + std::to_string(m_NPCID);
				std::vector<ScriptingSystem::LuaArg> args = { m_NPCID };

				// Log attempt only when verbose debug is enabled
				if (g_LuaDebug)
					NPCDebugPrint("Attempting to start activity script: " + new_script);

				// Try to start this frame (throttle)
				if (g_ScriptingSystem->TryConsumeScriptStart())
				{
				    std::string callResult = g_ScriptingSystem->CallScript(new_script, args);

				    if (!callResult.empty())
				    {
				        if (g_LuaDebug)
				            NPCDebugPrint("CallScript error for " + new_script + ": " + callResult);
				    }
				    else
				    {
				        if (g_LuaDebug)
				            NPCDebugPrint("Started activity coroutine: " + new_script);
				        g_NPCData[m_NPCID]->m_lastActivity = currentActivity;
				    }
				}
				else
				{
				    // Throttled - try again next frame
				    if (m_NPCID == 75 && g_LuaDebug) NPCDebugPrint("Throttled start for " + new_script + " (deferred)");
				}
			}
			else
			{
				// Debug: activity start blocked by movement/pathfinding flags (only when verbose)
				if (m_NPCID == 75 && g_LuaDebug)
				{
					std::stringstream ss;
					ss << "NPCActivity Blocked id=" << m_NPCID
					   << " pathfindingPending=" << (m_pathfindingPending ? 1 : 0)
					   << " isSchedulePath=" << (m_isSchedulePath ? 1 : 0);
					NPCDebugPrint(ss.str());
				}
			}
		}

		// Activity hasn't changed - resume if not on schedule path and near dest
		else if (currentActivity >= 0 && !m_pathfindingPending && !m_isSchedulePath)
		{
			bool nearForResume = true;
			if (const NPCSchedule* active =
					FindActiveScheduleEntry(npcData->m_schedule, (int)g_scheduleTime))
			{
				Vector3 schedDest = {
					float(active->m_destX) + 0.5f, 0.0f, float(active->m_destY) + 0.5f
				};
				nearForResume =
					Vector2Distance({ m_Pos.x, m_Pos.z }, { schedDest.x, schedDest.z }) <= 10.0f;
			}
			if (nearForResume)
			{
				std::string script_name = GetActivityScriptName(currentActivity) + "_" + std::to_string(m_NPCID);
				bool yielded = g_ScriptingSystem->IsCoroutineYielded(script_name);

				// --- when resuming a yielded activity coroutine ---
				if (yielded)
				{
					if (g_ScriptingSystem->TryConsumeScriptResume())
					{
						std::vector<ScriptingSystem::LuaArg> args = { m_NPCID };
						g_ScriptingSystem->ResumeCoroutine(script_name, args);

						if (m_NPCID == 75 && g_LuaDebug)
						{
							NPCDebugPrint("NPCResume Debug: called ResumeCoroutine for " + script_name);
						}
					}
					else
					{
						if (m_NPCID == 75 && g_LuaDebug) NPCDebugPrint("Throttled resume for " + script_name + " (deferred)");
					}
				}
			}
		}
	}
	// If schedules are disabled, cleanup any running activity scripts
	else if (!m_followingSchedule && g_NPCData.find(m_NPCID) != g_NPCData.end())
	{
		int lastActivity = g_NPCData[m_NPCID]->m_lastActivity;
		if (lastActivity >= 0)
		{
			std::string old_script = GetActivityScriptName(lastActivity) + "_" + std::to_string(m_NPCID);
			if (g_ScriptingSystem->IsCoroutineActive(old_script))
			{
				g_ScriptingSystem->CleanupCoroutine(old_script);
			}
			g_NPCData[m_NPCID]->m_lastActivity = -1;

			if (m_NPCID == 75 && g_LuaDebug)
			{
				NPCDebugPrint("NPCActivity Cleanup: cleared lastActivity for id=75");
			}
		}
	}

	// Schedule checking is now handled by MainState::Update() queue system
	// This function only handles waypoint following and movement via shared UpdateMovement()

	UpdateMovement();
}

void U7Object::UpdateMovement()
{
	// Shared movement for NPCs, monsters, and avatar path-follow.
	// Arrival is XZ-based; climb/drop snaps to waypoint Y.
	// All units wall-slide when blocked so they don't stop cold on corners.

	// After standing up, drop the furniture collision-ignore once clear of the seat.
	ReleaseFurnitureIfClear();

	// Walk-to-use: close enough to operate → cancel pathfinding and fire.
	// (Stand tiles between furniture are often unreachable; don't wait for exact arrival.)
	if (m_hasPendingUsecode && TryCompletePendingUsecodeByProximity(kPathRunUseRange))
		return;

	auto advanceWaypoint = [this]() {
		const bool isLast = (m_currentWaypointIndex >= static_cast<int>(m_pathWaypoints.size()) - 1);
		if (isLast)
		{
			m_pathWaypoints.clear();
			m_currentWaypointIndex = 0;
			m_isMoving = false;
			m_isSchedulePath = false;
			m_moveStuckFrames = 0;
			SetDest(m_Pos);
			// Exult path_run_usecode: run target usecode when the walk finishes.
			FirePendingUsecodeIfAny();
		}
		else
		{
			m_currentWaypointIndex++;
			SetDest(m_pathWaypoints[m_currentWaypointIndex]);
			m_isMoving = true;
			m_moveStuckFrames = 0;
		}
	};

	if (m_isMoving && !m_pathfindingPending && !m_pathWaypoints.empty() &&
	    m_currentWaypointIndex < static_cast<int>(m_pathWaypoints.size()))
	{
		const Vector3& wp = m_pathWaypoints[m_currentWaypointIndex];
		const float distXZ = Vector2Distance({ m_Pos.x, m_Pos.z }, { wp.x, wp.z });
		const bool isLastWaypoint = (m_currentWaypointIndex == static_cast<int>(m_pathWaypoints.size()) - 1);
		// Pending usecode walks: slightly looser final snap (furniture often blocks the exact tile).
		const float threshold = isLastWaypoint
			? (m_hasPendingUsecode ? 0.55f : 0.15f)
			: 0.45f;

		if (distXZ < threshold)
		{
			SetPos(wp);
			SetDest(wp);
			advanceWaypoint();
		}
	}

	// NPCs/monsters must follow A* waypoints — never crow-fly toward a bare m_Dest
	// (that walked Spark into his house wall when schedule pathfinding failed and
	// Dest was still pointed at the inn / a leftover goal).
	// Exceptions: Avatar (WASD / mouse steer), party followers (formation SetDest),
	// and hostiles mid-combat chase when A* failed (EngageCombatTarget sets Dest).
	const bool isAvatar = (g_Player && g_Player->GetAvatarObject() == this);
	const bool isPartyFollower = (!isAvatar && g_Player && m_NPCID >= 0 &&
	                              g_Player->NPCIDInParty(m_NPCID));
	// Hostiles with a target may crow-fly when chase A* fails (pre-combat
	// approach and in-combat). Swarm summons set a bare Dest on purpose
	// (they are flying pests and skip per-insect A*). Party/NPC schedule
	// walks still require waypoints.
	const bool combatHostileChase = m_target != 0 && IsHostileCombatUnit(this);
	const bool alliedSummonMove = IsAlliedSummonUnit(this);
	if (!isAvatar && !isPartyFollower && !combatHostileChase && !alliedSummonMove &&
	    (m_UnitType == UnitTypes::UNIT_TYPE_NPC || m_UnitType == UnitTypes::UNIT_TYPE_MONSTER) &&
	    m_pathWaypoints.empty())
	{
		if (m_Dest.x != m_Pos.x || m_Dest.y != m_Pos.y || m_Dest.z != m_Pos.z)
			SetDest(m_Pos);
		m_isMoving = false;
		return;
	}

	// Speed budget is along the 3D path (XZ + climb/drop), not XZ alone —
	// otherwise stairs/crates feel like a teleport because Y is free.
	float speedScale = 1.0f;
	if (g_isCombatMode)
	{
		const bool partyUnit = isAvatar || isPartyFollower;
		const bool hostileUnit = IsHostileCombatUnit(this);
		if (partyUnit || hostileUnit || alliedSummonMove)
			speedScale = 0.5f;
	}
	float deltav = m_speed * speedScale * g_Engine->LastFrameInSeconds();
	if (deltav < 1e-6f)
		deltav = 0.001f;

	const float dyToDest = m_Dest.y - m_Pos.y;
	Vector3 toDestXZ = Vector3Subtract(m_Dest, m_Pos);
	toDestXZ.y = 0.0f;
	const float distXZ = Vector3Length(toDestXZ);
	const float dist3D = sqrtf(distXZ * distXZ + dyToDest * dyToDest);

	// Residue snap (scaled by this frame's step so high-FPS WASD Dest —
	// roughly one deltav ahead — is never cancelled as "already there").
	// Exact float Pos==Dest previously left units micro-stepping (stuck walk
	// cycle) and flipped facing 180° after a slight overshoot.
	const float arriveXZ = std::max(0.001f, std::min(0.05f, deltav * 0.35f));
	const float arriveY = arriveXZ;
	constexpr float kFaceMinXZ = 0.05f;

	if (distXZ <= arriveXZ && fabsf(dyToDest) <= arriveY)
	{
		m_moveStuckFrames = 0;
		if (m_pathWaypoints.empty() && !m_pathfindingPending)
		{
			if (distXZ > 1e-6f || fabsf(dyToDest) > 1e-6f)
			{
				Vector3 landed = m_Dest;
				float landH = m_Dest.y;
				if (!g_pathfindingSystem || PathfindingSystem::ValidateMove(this, landed, landH))
				{
					landed.y = landH;
					SetPos(landed);
				}
				SetDest(m_Pos);
			}
			m_isMoving = false;
		}
		else if (!m_pathWaypoints.empty())
		{
			advanceWaypoint();
		}
		return;
	}

	if (distXZ > arriveXZ || fabsf(dyToDest) > arriveY)
	{
		// Pure vertical adjust (same tile XZ): spend budget on Y only.
		if (distXZ < 1e-5f)
		{
			if (fabsf(dyToDest) <= deltav)
			{
				float destH = m_Dest.y;
				if (!g_pathfindingSystem || PathfindingSystem::ValidateMove(this, m_Dest, destH))
				{
					Vector3 landed = m_Dest;
					landed.y = destH;
					SetPos(landed);
					SetDest(landed);
					m_moveStuckFrames = 0;
					if (!m_pathWaypoints.empty())
						advanceWaypoint();
					else
						m_isMoving = false;
				}
			}
			else
			{
				Vector3 mid = m_Pos;
				mid.y += (dyToDest > 0.0f ? deltav : -deltav);
				float midH = mid.y;
				if (!g_pathfindingSystem || PathfindingSystem::ValidateMove(this, mid, midH))
				{
					mid.y = midH;
					SetPos(mid);
					m_isMoving = true;
					m_moveStuckFrames = 0;
				}
			}
			return;
		}

		// Horizontal step length along the slope (shorter when |dy| is large).
		const float stepXZBudget = deltav * (distXZ / std::max(dist3D, 1e-5f));

		// Prefer climbing toward a validated landing when near a height change
		// (crates/stairs): move along 3D toward the tile center, never instant snap.
		const float climbDelta = m_Dest.y - m_Pos.y;
		if (fabsf(climbDelta) > 0.05f && fabsf(climbDelta) <= MAX_CLIMBABLE_HEIGHT + 0.05f &&
		    distXZ < 1.15f && g_pathfindingSystem)
		{
			const int tx = (int)floorf(m_Dest.x);
			const int tz = (int)floorf(m_Dest.z);
			Vector3 landed = { tx + 0.5f, m_Dest.y, tz + 0.5f };
			float landH = m_Dest.y;
			if (PathfindingSystem::ValidateMove(this, landed, landH))
			{
				landed.y = landH;
				Vector3 delta = Vector3Subtract(landed, m_Pos);
				const float dist = Vector3Length(delta);
				const Vector3 landDir = Vector3{ landed.x - m_Pos.x, 0.0f, landed.z - m_Pos.z };
				if (Vector3LengthSqr(landDir) > 1e-8f)
					m_Direction = Vector3Normalize(landDir);

				if (dist <= deltav)
				{
					SetPos(landed);
					m_moveStuckFrames = 0;
					m_isMoving = true;
					if (!m_pathWaypoints.empty())
						advanceWaypoint();
					else
					{
						SetDest(landed);
						m_isMoving = false;
					}
				}
				else
				{
					Vector3 step = Vector3Scale(Vector3Normalize(delta), deltav);
					Vector3 mid = Vector3Add(m_Pos, step);
					float midH = mid.y;
					// Keep feet on a valid surface under the mid-step XZ when possible.
					if (PathfindingSystem::ValidateMove(this, mid, midH))
						mid.y = midH;
					SetPos(mid);
					m_isMoving = true;
					m_moveStuckFrames = 0;
				}
				return;
			}
		}

		Vector3 flatDir = Vector3Scale(toDestXZ, 1.0f / distXZ);
		// Skip facing updates on tiny remaining deltas — those often point
		// backward after an overshoot and pop the sprite 180°.
		if (distXZ >= kFaceMinXZ)
			m_Direction = flatDir;

		// Wall-slide helper used at full step and micro-steps.
		// Prefer the axis that still approaches dest; any free axis is better than stop.
		// stepLen is the XZ step (already slope-scaled by caller).
		auto trySlide = [&](float stepLen, Vector3& outPos, float& outSurfaceH) -> bool {
			if (!g_pathfindingSystem)
			{
				outPos = Vector3Add(m_Pos, Vector3Scale(flatDir, stepLen));
				// Progress Y proportionally along the path to dest.
				const float t = distXZ > 1e-5f ? std::min(1.0f, stepLen / distXZ) : 1.0f;
				outPos.y = m_Pos.y + dyToDest * t;
				outSurfaceH = outPos.y;
				return true;
			}

			const float eps = 1e-5f;
			const Vector3 step = Vector3Scale(flatDir, stepLen);

			// Probe at dest height so ValidateMove can resolve the surface, then
			// we ease Y toward that surface below (not snap in one frame).
			Vector3 full = Vector3Add(m_Pos, step);
			full.y = m_Dest.y;
			float hFull = m_Pos.y;
			if (PathfindingSystem::ValidateMove(this, full, hFull))
			{
				outPos = full;
				outSurfaceH = hFull;
				return true;
			}

			Vector3 slideX = { m_Pos.x + step.x, m_Dest.y, m_Pos.z };
			Vector3 slideZ = { m_Pos.x, m_Dest.y, m_Pos.z + step.z };
			float hX = m_Pos.y;
			float hZ = m_Pos.y;
			const bool wantX = fabsf(step.x) > eps;
			const bool wantZ = fabsf(step.z) > eps;
			const bool okX = wantX && PathfindingSystem::ValidateMove(this, slideX, hX);
			const bool okZ = wantZ && PathfindingSystem::ValidateMove(this, slideZ, hZ);

			auto distToDest2 = [&](float x, float z) {
				const float dx = x - m_Dest.x;
				const float dz = z - m_Dest.z;
				return dx * dx + dz * dz;
			};
			const float curD2 = distToDest2(m_Pos.x, m_Pos.z);

			if (okX && okZ)
			{
				if (distToDest2(slideX.x, slideX.z) <= distToDest2(slideZ.x, slideZ.z))
				{
					outPos = slideX;
					outSurfaceH = hX;
				}
				else
				{
					outPos = slideZ;
					outSurfaceH = hZ;
				}
				return true;
			}
			if (okX && distToDest2(slideX.x, slideX.z) <= curD2 + 0.01f)
			{
				outPos = slideX;
				outSurfaceH = hX;
				return true;
			}
			if (okZ && distToDest2(slideZ.x, slideZ.z) <= curD2 + 0.01f)
			{
				outPos = slideZ;
				outSurfaceH = hZ;
				return true;
			}
			if (okX)
			{
				outPos = slideX;
				outSurfaceH = hX;
				return true;
			}
			if (okZ)
			{
				outPos = slideZ;
				outSurfaceH = hZ;
				return true;
			}
			return false;
		};

		// Ease feet Y toward a surface without exceeding remaining 3D budget after XZ step.
		auto applySmoothedY = [&](Vector3& pos, float surfaceH, float appliedStepXZ) {
			const float dy = surfaceH - m_Pos.y;
			if (fabsf(dy) < 0.001f)
			{
				pos.y = surfaceH;
				return;
			}
			// Remaining budget for vertical after horizontal travel this frame.
			float maxYStep = 0.0f;
			if (appliedStepXZ < deltav)
			{
				const float rem = deltav * deltav - appliedStepXZ * appliedStepXZ;
				maxYStep = rem > 0.0f ? sqrtf(rem) : 0.0f;
			}
			// Also cap by proportional progress along the slope to dest (avoids Y racing ahead).
			if (dist3D > 1e-5f)
			{
				const float propCap = deltav * (fabsf(dyToDest) / dist3D);
				maxYStep = std::min(maxYStep, propCap + 0.001f);
			}
			if (fabsf(dy) <= maxYStep)
				pos.y = surfaceH;
			else
				pos.y = m_Pos.y + (dy > 0.0f ? maxYStep : -maxYStep);
		};

		Vector3 newPos = m_Pos;
		float surfaceH = m_Pos.y;
		// Try full slope-scaled step, then half, then quarter.
		bool moved = trySlide(stepXZBudget, newPos, surfaceH);
		if (!moved && stepXZBudget > 0.02f)
			moved = trySlide(stepXZBudget * 0.5f, newPos, surfaceH);
		if (!moved && stepXZBudget > 0.04f)
			moved = trySlide(stepXZBudget * 0.25f, newPos, surfaceH);

		if (!moved)
		{
			// Fully blocked this frame.
			m_moveStuckFrames++;

			// Ease onto dest if close in XZ (climb ledge) — still 3D-budget limited.
			const float nearXZ = Vector2Distance({ m_Pos.x, m_Pos.z }, { m_Dest.x, m_Dest.z });
			if (nearXZ < 0.55f && g_pathfindingSystem)
			{
				float snapH = m_Dest.y;
				if (PathfindingSystem::ValidateMove(this, m_Dest, snapH))
				{
					Vector3 landed = m_Dest;
					landed.y = snapH;
					Vector3 delta = Vector3Subtract(landed, m_Pos);
					const float dist = Vector3Length(delta);
					if (dist <= deltav)
					{
						SetPos(landed);
						m_moveStuckFrames = 0;
						if (!m_pathWaypoints.empty())
							advanceWaypoint();
					}
					else
					{
						SetPos(Vector3Add(m_Pos, Vector3Scale(Vector3Normalize(delta), deltav)));
						m_isMoving = true;
						m_moveStuckFrames = 0;
					}
					return;
				}
			}

			// Path-follow: skip ahead after a short stuck period so NPCs peel around corners.
			if (!m_pathWaypoints.empty() && m_moveStuckFrames >= 10)
			{
				if (m_currentWaypointIndex < static_cast<int>(m_pathWaypoints.size()) - 1)
				{
					m_currentWaypointIndex++;
					SetDest(m_pathWaypoints[m_currentWaypointIndex]);
					m_moveStuckFrames = 0;
					m_isMoving = true;
					return;
				}
			}

			// Pinned on a 1×1 solid (tree / lamp / stalactite): Dest slides only try
			// toward the goal, so crow-fly followers stay pressed forever. Nudge off
			// sideways early (ValidateMove also allows non-deeper escape slides).
			if (m_moveStuckFrames == 8 || m_moveStuckFrames == 20 ||
			    m_moveStuckFrames == 40 || m_moveStuckFrames == 55)
			{
				const Vector3 nudgeGoal = !m_pathWaypoints.empty() ? m_pathWaypoints.back() : m_Dest;
				if (TryNudgeOffSolidBlocker(&nudgeGoal))
				{
					m_moveStuckFrames = 0;
					if (g_pathfindingSystem && !m_pathfindingPending)
					{
						const bool isParty = (m_UnitType == UnitTypes::UNIT_TYPE_NPC && g_Player &&
							g_Player->NPCIDInParty(m_NPCID));
						const bool isMonster = (m_UnitType == UnitTypes::UNIT_TYPE_MONSTER) ||
							(m_Team == 1 && !isParty);
						if (m_isSchedulePath)
						{
							ApplyPathWaypoints(g_pathfindingSystem->FindFastPath(
								m_Pos, nudgeGoal, this, PathCallerTag::ScheduleFast));
							m_isSchedulePath = true;
						}
						else if (isMonster)
						{
							ApplyPathWaypoints(g_pathfindingSystem->FindMonsterChasePath(
								m_Pos, nudgeGoal, this));
						}
						else if (!m_pathWaypoints.empty() || isParty)
						{
							// Formation follow: clear leftover A* so MaybeUpdatePartyFollowing
							// resumes slot steering from the freed tile (nudge-only path).
							if (isParty && m_pathWaypoints.empty())
							{
								SetDest(nudgeGoal);
							}
							else
							{
								PathfindToDest(nudgeGoal, /*allowHierarchical=*/true, PathCallerTag::StuckRepath);
							}
						}
						else
						{
							SetDest(nudgeGoal);
						}
					}
					m_isMoving = true;
					return;
				}
			}

			// After longer stuck with a path remaining, repath to the final goal
			// instead of freezing in place (handles dynamic blockers / bad corners).
			if (!m_pathWaypoints.empty() && m_moveStuckFrames >= 28 &&
			    g_pathfindingSystem && !m_pathfindingPending)
			{
				const Vector3 finalGoal = m_pathWaypoints.back();
				const bool wasSchedule = m_isSchedulePath;
				m_moveStuckFrames = 0;

				const bool isParty = (m_UnitType == UnitTypes::UNIT_TYPE_NPC && g_Player &&
					g_Player->NPCIDInParty(m_NPCID));
				const bool isMonster = (m_UnitType == UnitTypes::UNIT_TYPE_MONSTER) ||
					(m_Team == 1 && !isParty);

				if (wasSchedule)
				{
					ApplyPathWaypoints(g_pathfindingSystem->FindFastPath(
						m_Pos, finalGoal, this, PathCallerTag::ScheduleFast));
					m_isSchedulePath = true;
				}
				else if (isMonster)
				{
					ApplyPathWaypoints(g_pathfindingSystem->FindMonsterChasePath(
						m_Pos, finalGoal, this));
				}
				else
				{
					PathfindToDest(finalGoal, /*allowHierarchical=*/true, PathCallerTag::StuckRepath);
				}
				return;
			}

			// Walk-to-use stuck against furniture: if in use range, fire instead of shuffling.
			if (m_hasPendingUsecode && m_moveStuckFrames >= 12 &&
			    TryCompletePendingUsecodeByProximity(kPathRunUseRange))
				return;

			// Give up after longer stuck (avoids infinite shuffle). Still try one nudge
			// so party members are not left permanently pinned on a prop.
			if (m_moveStuckFrames >= 60)
			{
				const Vector3 lastGoal = !m_pathWaypoints.empty() ? m_pathWaypoints.back() : m_Dest;
				TryNudgeOffSolidBlocker(&lastGoal);
				m_pathWaypoints.clear();
				m_currentWaypointIndex = 0;
				m_isMoving = false;
				m_isSchedulePath = false;
				m_moveStuckFrames = 0;
				SetDest(m_Pos);
				// Last chance: still near enough to use?
				if (!TryCompletePendingUsecodeByProximity(kPathRunUseRange))
					ClearPendingUsecode();
			}
			return;
		}

		m_moveStuckFrames = 0;
		const float appliedStepXZ = Vector2Distance({ m_Pos.x, m_Pos.z }, { newPos.x, newPos.z });
		applySmoothedY(newPos, surfaceH, appliedStepXZ);

		// Don't overshoot dest in XZ
		const float newDistXZ = Vector2Distance({ newPos.x, newPos.z }, { m_Dest.x, m_Dest.z });
		if (newDistXZ > distXZ)
		{
			float destSnapH = m_Dest.y;
			if (!g_pathfindingSystem || PathfindingSystem::ValidateMove(this, m_Dest, destSnapH))
			{
				Vector3 landed = m_Dest;
				// Still ease Y if a large climb remains.
				const float remainY = destSnapH - m_Pos.y;
				if (fabsf(remainY) <= deltav)
					landed.y = destSnapH;
				else
				{
					landed.x = m_Dest.x;
					landed.z = m_Dest.z;
					landed.y = m_Pos.y + (remainY > 0.0f ? deltav : -deltav);
				}
				SetPos(landed);
				if (m_pathWaypoints.empty() && fabsf(landed.y - destSnapH) < 0.05f)
					m_isMoving = false;
			}
			else
			{
				m_isMoving = true;
				SetPos(newPos);
			}
		}
		else
		{
			m_isMoving = true;
			SetPos(newPos);
			TryOpenDoorAtCurrentPosition();
		}
	}
	else
	{
		// Already at Dest with no remaining delta — stop the walk cycle.
		m_moveStuckFrames = 0;
		if (m_pathWaypoints.empty() && !m_pathfindingPending)
			m_isMoving = false;
	}
}

void U7Object::SetInitialPos(Vector3 pos)
{
	m_Pos = pos;

	SetPos(pos);
	SetDest(pos);
}

void U7Object::SetPos(Vector3 pos)
{
	Vector3 fromPos = m_Pos;

	m_Pos = pos;

	Vector3 dims = Vector3{ 0, 0, 0 };
	Vector3 boundingBoxAnchorPoint = Vector3{ 0, 0, 0 };

	// Safety check for null shape data
	if (m_shapeData == nullptr)
	{
		m_boundingBox = { m_Pos, m_Pos };
		m_centerPoint = pos;
		return;
	}

	ObjectData* objectData = &g_objectDataTable[m_shapeData->GetShape()];

	// Living upright NPCs/monsters: pick/drag volume centered on actual XZ so
	// mid-tile movement still matches the visible sprite (and F9 debug boxes).
	// Dead, KO, and asleep stay ground flats. Props keep SE-origin tile footprints.
	const bool lyingFlatCharacter =
		ShouldLieFlat()
		&& (m_UnitType == UnitTypes::UNIT_TYPE_NPC || m_UnitType == UnitTypes::UNIT_TYPE_MONSTER);
	const bool characterCentered =
		!lyingFlatCharacter
		&& (m_UnitType == UnitTypes::UNIT_TYPE_NPC || m_UnitType == UnitTypes::UNIT_TYPE_MONSTER);

	if (lyingFlatCharacter)
	{
		// Match DrawCorpseFlat. Sleep/KO billboards are centered; remains stay hotspot-placed.
		int shape = 0;
		int frame = 0;
		ResolveLieFlatArt(*this, shape, frame);
		if (FlatFrameDrawable(shape, frame))
		{
			ShapeData& lieArt = g_shapeTable[shape][frame];
			const bool centerOnPos = (lieArt.GetDrawType() == ShapeDrawType::OBJECT_DRAW_BILLBOARD);
			m_boundingBox = lieArt.GetAsFlatBoundingBox(m_Pos, 0.15f, Vector3{ 1, 1, 1 }, centerOnPos);
			dims = Vector3Subtract(m_boundingBox.max, m_boundingBox.min);
			boundingBoxAnchorPoint = m_boundingBox.min;
		}
		else
		{
			dims = Vector3{ 1.0f, 0.15f, 1.0f };
			boundingBoxAnchorPoint = Vector3Add(m_Pos, Vector3{ -dims.x + 1.0f, 0.0f, -dims.z + 1.0f });
		}
	}
	else if (characterCentered)
	{
		dims = Vector3{ objectData->m_width, objectData->m_height, objectData->m_depth };
		if (dims.x < 0.5f) dims.x = 1.0f;
		if (dims.y < 0.5f) dims.y = 1.0f;
		if (dims.z < 0.5f) dims.z = 1.0f;
		// Center XZ on m_Pos (not floor-snapped). Flying: lift with draw height.
		boundingBoxAnchorPoint = Vector3{
			m_Pos.x - dims.x * 0.5f,
			m_Pos.y + m_drawHeightOffset,
			m_Pos.z - dims.z * 0.5f
		};
	}
	else if (m_drawType == ShapeDrawType::OBJECT_DRAW_BILLBOARD)
	{
		dims = Vector3{ objectData->m_width, objectData->m_height, objectData->m_depth };
		// Match ShapeData::Draw billboard offset so picks follow the visible sprite.
		boundingBoxAnchorPoint = Vector3Add(m_Pos, Vector3{ 0.5f, 0, 0.5f });
		if (m_shapeData)
			boundingBoxAnchorPoint = Vector3Add(boundingBoxAnchorPoint, m_shapeData->m_TweakPos);
	}
	else if (m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
	{
		// Safety check for null texture
		if (m_shapeData->m_texture == nullptr)
		{
			dims = Vector3{ 1.0f, 0, 1.0f }; // Default size
		}
		else
		{
			dims = Vector3{ float(m_shapeData->m_texture->width) / 8.0f, 0, float(m_shapeData->m_texture->height) / 8.0f };
		}
		boundingBoxAnchorPoint = Vector3Add(m_Pos, Vector3{ -dims.x + 1, 0, -dims.z + 1 });
	}
	else
	{
		dims = Vector3{ objectData->m_width, objectData->m_height, objectData->m_depth };
		boundingBoxAnchorPoint = Vector3Add(m_Pos, Vector3{ -dims.x + 1, 0, -dims.z + 1 });
	}

	m_boundingBox = { boundingBoxAnchorPoint, Vector3Add(boundingBoxAnchorPoint, dims) };

	if (characterCentered)
	{
		// Keep sort/lighting center on the visible character (actual XZ).
		// Flying: raise center with draw height so depth sort matches the sprite.
		m_centerPoint = Vector3{ m_Pos.x, m_Pos.y + m_drawHeightOffset + dims.y * 0.5f, m_Pos.z };
	}
	else if (lyingFlatCharacter)
	{
		// Flat body may be hotspot-offset from m_Pos; center on the drawn AABB.
		m_centerPoint = Vector3{
			(m_boundingBox.min.x + m_boundingBox.max.x) * 0.5f,
			(m_boundingBox.min.y + m_boundingBox.max.y) * 0.5f,
			(m_boundingBox.min.z + m_boundingBox.max.z) * 0.5f
		};
	}
	else
	{
		m_centerPoint = Vector3Subtract(pos, {dims.x / 2, dims.y / 2, dims.z / 2});
	}
	//m_centerPoint = Vector3Add(m_centerPoint, m_shapeData->m_TweakPos);
	m_terrainCenterPoint = m_centerPoint;
	m_terrainCenterPoint.y = m_Pos.y;

	UpdateObjectChunk(this, fromPos);

	// Notify pathfinding grid if this is a non-walkable STATIC object.
	// NPCs and monsters use dynamic AreUnitsHostile checks instead — baking
	// them into the grid (e.g. Swarm insects) permanently blocks tiles.
	// Spell missiles skip the grid entirely (they also skip ValidateMove scans).
	if (m_objectData && m_objectData->m_isNotWalkable &&
	    m_UnitType != UnitTypes::UNIT_TYPE_NPC &&
	    m_UnitType != UnitTypes::UNIT_TYPE_MONSTER &&
	    !m_isProjectile)
	{
		// Update both old and new positions (object moved)
		NotifyPathfindingGridUpdate((int)fromPos.x, (int)fromPos.z);
		NotifyPathfindingGridUpdate((int)pos.x, (int)pos.z);
	}

	// Contact fields (caltrops): Exult footpad damage on tile enter only.
	if ((m_UnitType == UnitTypes::UNIT_TYPE_NPC || m_UnitType == UnitTypes::UNIT_TYPE_MONSTER)
		&& !IsDeathStatus() && !GetIsDead())
	{
		const int tx = static_cast<int>(std::floor(m_Pos.x));
		const int tz = static_cast<int>(std::floor(m_Pos.z));
		if (tx != m_contactFieldLastTx || tz != m_contactFieldLastTz)
		{
			m_contactFieldLastTx = tx;
			m_contactFieldLastTz = tz;
			CheckContactFieldsAt(this);
		}
	}
}

void U7Object::SetOverrideFrame(int overrideFrame)
{
	m_overrideFrame = overrideFrame;
	m_isFrameOverridden = true;
	// Pose frames are only drawn when not walking — halt pathing immediately.
	m_isMoving = false;
	m_pathWaypoints.clear();
	m_currentWaypointIndex = 0;
	m_pathfindingPending = false;
	SetDest(m_Pos);
}

void U7Object::ClearOverrideFrame(const Vector3* toward)
{
	const bool wasPosed = m_isFrameOverridden;
	m_isFrameOverridden = false;
	m_overrideFrame = 0;
	if (wasPosed || m_furnitureObjectId >= 0)
		UnstickFromFurniture(toward);
}

const NpcActionTextures* U7Object::GetNpcActionTextures() const
{
	if (m_NPCData && m_NPCData->m_actionTextures.valid)
		return &m_NPCData->m_actionTextures;
	if (m_actionTextures.valid)
		return &m_actionTextures;
	return nullptr;
}

void U7Object::SetNpcAnimAction(NpcAnimAction action, bool looping, float frameMs)
{
	m_npcAnimAction = action;
	m_npcAnimPhase = 0;
	m_npcAnimTimer = frameMs * 0.001f;
	m_npcAnimLooping = looping;
	m_npcAnimPlaying = !looping;
	m_npcAnimHitFired = false;

	const NpcActionTextures* actions = GetNpcActionTextures();
	if (!actions)
	{
		// No baked clips: one-shots must not stick in "playing" forever
		// (UpdateNpcAnim returns early without textures, which blocked later TB swings).
		m_npcAnimPlaying = false;
		m_npcAnimHitPhase = -1;
		return;
	}

	// Strike / release is the last phase of attack/shoot clips.
	if (action == NpcAnimAction::Attack1H || action == NpcAnimAction::Attack2H ||
	    action == NpcAnimAction::Shoot)
	{
		const int count = GetNpcActionPhaseCount(*actions, action, 0);
		m_npcAnimHitPhase = (count > 0) ? (count - 1) : -1;
		// Empty attack clip: treat as instantaneous (hit via hitPhase < 0 path).
		if (count <= 0)
			m_npcAnimPlaying = false;
	}
	else
	{
		m_npcAnimHitPhase = -1;
	}
}

void U7Object::StartNpcAttackAnim()
{
	NpcAnimAction action = NpcAnimAction::Attack1H;
	// Party paperdoll or monster EQUIP.DAT inventory (GetEquippedWeapon).
	U7Object* weapon = GetEquippedWeapon(this);

	if (weapon && weapon->m_shapeData)
	{
		const int shape = weapon->m_shapeData->m_shape;
		// Ranged (WEAPONS.DAT uses==3) → Shoot; two-handed melee shapes → Attack2H.
		if (IsRangedWeaponShape(shape))
			action = NpcAnimAction::Shoot;
		else if (shape == 600 || shape == 601 || shape == 602 || shape == 603 || // 2H hammer/axe/sword/halberd
		         shape == 618 || shape == 553) // scythe / firedoom staff
			action = NpcAnimAction::Attack2H;
		else
			action = NpcAnimAction::Attack1H;
	}

	SetNpcAnimAction(action, false, 110.0f);
}

void U7Object::ApplyNpcPoseFromUsecode(int poseNibble)
{
	poseNibble &= 15;

	// Keep m_Frame low nibble in sync for any code that still reads it.
	// A pose is not set_object_frame: show the walksheet again.
	const int facingBase = m_Frame & ~0x0f;
	SetFrame(facingBase | poseNibble);
	m_drawSuppressedByEmptyFrame = false;

	NpcAnimAction action = NpcAnimAction::Stand;
	int phase = 0;
	switch (poseNibble)
	{
	case 0: action = NpcAnimAction::Stand; break;
	case 1: action = NpcAnimAction::Walk; phase = 1; break;
	case 2: action = NpcAnimAction::Walk; phase = 3; break;
	case 3: action = NpcAnimAction::Ready; break;
	case 4: action = NpcAnimAction::Attack1H; phase = 1; break; // raise1
	case 5: action = NpcAnimAction::Attack1H; phase = 2; break; // reach1
	case 6: action = NpcAnimAction::Attack1H; phase = 3; break; // strike1
	case 7: action = NpcAnimAction::Attack2H; phase = 1; break; // raise2
	case 8: action = NpcAnimAction::Attack2H; phase = 2; break; // reach2
	case 9: action = NpcAnimAction::Attack2H; phase = 3; break; // strike2
	case 10: action = NpcAnimAction::Sit; break;
	case 11: action = NpcAnimAction::Cast; break;               // bow
	case 12: action = NpcAnimAction::Kneel; break;
	case 13: action = NpcAnimAction::Sleep; break;
	case 14: action = NpcAnimAction::Up; break;
	case 15: action = NpcAnimAction::Out; break;
	default: break;
	}

	m_npcAnimAction = action;
	m_npcAnimPhase = phase;
	m_npcAnimPlaying = false; // hold; usecode advances poses on its tick
	m_npcAnimLooping = true;
	m_npcAnimHitPhase = -1;
	m_npcAnimHitFired = true; // never treat cast poses as combat hits
}

void U7Object::UpdateNpcAnim(float dt)
{
	if (dt <= 0.0f)
		return;

	// Usecode cast/craft scripts own the pose until they finish.
	if (IsInUsecodeScript())
		return;

	// 087D item flag 16: Avatar stays put (HandleAvatarMovement). Do not
	// advance walk/idle clips; the overlay token is invisible so this body
	// is the freeze the player sees.
	if ((m_flags & (1u << 16)) != 0)
	{
		if (!m_isFrameOverridden)
		{
			m_npcAnimAction = NpcAnimAction::Stand;
			m_npcAnimPhase = 0;
		}
		m_npcAnimPlaying = false;
		return;
	}

	const NpcActionTextures* actions = GetNpcActionTextures();
	if (!actions)
	{
		m_npcAnimPlaying = false;
		return;
	}

	// Pose overrides (sit/sleep/death) win until cleared.
	if (m_isFrameOverridden)
	{
		if (IsSittingPose())
			m_npcAnimAction = NpcAnimAction::Sit;
		else if (IsSleepingPose() || IsDeathStatus())
			m_npcAnimAction = NpcAnimAction::Sleep;
		m_npcAnimPhase = 0;
		m_npcAnimPlaying = false;
		m_npcAnimLooping = true;
		return;
	}

	// One-shot attack/shoot clips advance on their own timer.
	if (m_npcAnimPlaying)
	{
		m_npcAnimTimer -= dt;
		if (m_npcAnimTimer > 0.0f)
			return;

		const int count = GetNpcActionPhaseCount(*actions, m_npcAnimAction, 0);
		if (count <= 0)
		{
			m_npcAnimPlaying = false;
			return;
		}

		++m_npcAnimPhase;
		if (m_npcAnimPhase >= count)
		{
			m_npcAnimPlaying = false;
			m_npcAnimPhase = count - 1;
			// Return to ready/stand after the swing.
			if (g_isCombatMode)
				SetNpcAnimAction(NpcAnimAction::Ready, true, 180.0f);
			else
				SetNpcAnimAction(NpcAnimAction::Stand, true, 180.0f);
			return;
		}
		m_npcAnimTimer = 0.110f;
		return;
	}

	// Looping locomotion / idle selection when not in a one-shot.
	if (m_isMoving)
	{
		if (m_npcAnimAction != NpcAnimAction::Walk || !m_npcAnimLooping)
			SetNpcAnimAction(NpcAnimAction::Walk, true, 200.0f);
	}
	else if (g_isCombatMode && m_target != 0)
	{
		if (m_npcAnimAction != NpcAnimAction::Ready || !m_npcAnimLooping)
			SetNpcAnimAction(NpcAnimAction::Ready, true, 180.0f);
	}
	else
	{
		if (m_npcAnimAction != NpcAnimAction::Stand || !m_npcAnimLooping)
			SetNpcAnimAction(NpcAnimAction::Stand, true, 180.0f);
	}

	if (!m_npcAnimLooping)
		return;

	const int count = GetNpcActionPhaseCount(*actions, m_npcAnimAction, 0);
	if (count <= 1)
	{
		m_npcAnimPhase = 0;
		return;
	}

	m_npcAnimTimer -= dt;
	if (m_npcAnimTimer > 0.0f)
		return;

	m_npcAnimPhase = (m_npcAnimPhase + 1) % count;
	m_npcAnimTimer = (m_npcAnimAction == NpcAnimAction::Walk) ? 0.200f : 0.180f;
}

bool U7Object::ConsumeNpcAnimHitEvent()
{
	if (m_npcAnimHitPhase < 0 || m_npcAnimHitFired)
		return false;
	if (m_npcAnimPhase < m_npcAnimHitPhase)
		return false;
	m_npcAnimHitFired = true;
	return true;
}

bool U7Object::IsSittingPose() const
{
	// Exult sit_frame = 10; +16 = 26 for opposite facing.
	return m_isFrameOverridden && (m_overrideFrame == 10 || m_overrideFrame == 26);
}

bool U7Object::IsSleepingPose() const
{
	// Exult sleep_frame = 13; +16 = 29 for opposite facing.
	return m_isFrameOverridden && (m_overrideFrame == 13 || m_overrideFrame == 29);
}

bool U7Object::IsDeathStatus() const
{
	// Runtime Obj_flags bit is used for both NPC and monster corpses.
	if ((m_flags & kObjFlagDead) != 0)
		return true;
	// Loaded npc.dat bit 15 for pre-placed dead NPCs.
	if (m_UnitType == UnitTypes::UNIT_TYPE_NPC && m_NPCData)
		return (m_NPCData->status & kNpcDatStatusDead) != 0;
	return false;
}

bool U7Object::IsKnockedOut() const
{
	// Exult is_knocked_out: health <= 0 (still alive until IsDying → die).
	return m_hp <= 0.0f && !IsDeathStatus();
}

bool U7Object::ShouldLieFlat() const
{
	// Knocked-out and asleep creatures are on the ground, drawn as their own
	// sleep frame. A true corpse is also flat, but uses the remains sprite.
	return IsDeathStatus() || IsKnockedOut() || (m_flags & kObjFlagAsleep) != 0;
}

bool U7Object::IsDying() const
{
	// Exult is_dying: health < -(strength / 3).
	int str = 1;
	if (m_NPCData && m_NPCData->str > 0)
		str = static_cast<int>(m_NPCData->str);
	else if (m_BaseMaxHP > 0.0f)
		str = static_cast<int>(m_BaseMaxHP);
	return m_hp < -static_cast<float>(str / 3);
}

void U7Object::AnnounceStatusFlag(unsigned int flag, bool applied)
{
	if (m_UnitType != UnitTypes::UNIT_TYPE_NPC
		&& m_UnitType != UnitTypes::UNIT_TYPE_MONSTER)
		return;
	if (IsDeathStatus() || GetIsDead())
		return;

	const char* word = nullptr;
	Color color = YELLOW;
	switch (flag)
	{
	case kObjFlagAsleep:
		word = "asleep";
		break;
	case kObjFlagCharmed:
		word = "charmed";
		break;
	case kObjFlagCursed:
		word = "cursed";
		break;
	case kObjFlagParalyzed:
		word = "paralyzed";
		break;
	case kObjFlagPoisoned:
		word = "poisoned";
		break;
	case kObjFlagProtection:
		word = "protected";
		color = GREEN;
		break;
	case kObjFlagMight:
		word = "mighty";
		color = GREEN;
		break;
	default:
		return;
	}

	const std::string name = m_name.empty() ? "Someone" : m_name;
	if (applied)
		NoteCombatLogClause(name + " is " + word + "!", color);
	else
		NoteCombatLogClause(name + " is no longer " + word + ".", SKYBLUE);
}

void U7Object::ForceSleep()
{
	if (IsDeathStatus() || GetIsDead())
		return;
	m_flags |= kObjFlagAsleep;
	StartSleepTimer();
	m_target = 0;
	m_combatSpellId = -1;
	m_combatSpellTargetId = 0;
	m_combatSpellHasTile = false;
	m_combatMoveOrder = false;
	m_combatPathTargetId = 0;
	SetOverrideFrame(GetSleepFrameForFacing());
	SetPos(m_Pos); // refresh pick box for flat sleep / KO pose
}

void U7Object::ApplyKnockOut()
{
	if (IsDeathStatus() || GetIsDead())
		return;
	if ((m_flags & kObjFlagAsleep) != 0 && IsSleepingPose())
		return;

	ForceSleep();

	const std::string label = m_name.empty() ? "Someone" : m_name;
	NoteCombatLogClause(label + " is down!", ORANGE);
}

void U7Object::ClearSleep()
{
	m_flags &= ~kObjFlagAsleep;
	if (IsSleepingPose())
		ClearOverrideFrame();
	SetPos(m_Pos); // restore upright pick box after waking
}

void U7Object::TryWakeFromHealing()
{
	if (IsDeathStatus() || GetIsDead())
		return;
	if (m_hp < 1.0f)
		return;
	if ((m_flags & kObjFlagAsleep) == 0 && !IsSleepingPose())
		return;
	ClearSleep();
	StopSleepTimer();
}

bool U7Object::CanBleed() const
{
	// Exult Monster_info::cant_bleed (MONSTERS.DAT byte 12 bit 6). NPCs with no
	// monster record bleed by default (get_monster_info_safe default).
	if (!m_shapeData)
		return true;
	const int shape = m_shapeData->m_shape;
	for (const MonsterData& md : g_monsterData)
	{
		if (static_cast<int>(md.m_shape) == shape)
			return !md.m_cantBleed;
	}
	return true;
}

void U7Object::Bleed()
{
	// Exult Actor::bleed — shape 912 frames 0-3; grow an existing pool on this tile.
	if (!CanBleed())
		return;

	constexpr int kBloodShape = 912;
	constexpr int kFirstFrame = 0;
	constexpr int kLastFrame = 3;

	const int tileX = static_cast<int>(std::floor(m_Pos.x));
	const int tileZ = static_cast<int>(std::floor(m_Pos.z));
	const int chunkX = tileX / 16;
	const int chunkZ = tileZ / 16;
	if (chunkX < 0 || chunkX >= 192 || chunkZ < 0 || chunkZ >= 192)
		return;

	// Same-tile blood: grow frame instead of stacking another splat.
	for (U7Object* obj : g_chunkObjectMap[chunkX][chunkZ])
	{
		if (!obj || obj->m_ObjectType != kBloodShape || obj->m_isContained)
			continue;
		if (obj->GetIsDead())
			continue;
		if (static_cast<int>(std::floor(obj->m_Pos.x)) != tileX
		    || static_cast<int>(std::floor(obj->m_Pos.z)) != tileZ)
			continue;
		// Keep pools on the same lift band as the corpse.
		if (std::fabs(obj->m_Pos.y - m_Pos.y) > 2.5f)
			continue;

		int frame = obj->m_Frame;
		if (frame < kFirstFrame || frame > kLastFrame)
			continue;
		if (frame < kLastFrame)
		{
			obj->SetFrame(frame + 1);
		}
		return;
	}

	// New pool: Exult starts with frames 0-1 when the range is wider than 2.
	int numFrames = kLastFrame - kFirstFrame + 1;
	if (numFrames > 2)
		numFrames = 2;
	const int bloodFrame = kFirstFrame + (rand() % numFrames);

	const unsigned int id = GetNextID();
	const float x = static_cast<float>(tileX) + 0.5f;
	const float z = static_cast<float>(tileZ) + 0.5f;
	U7Object* blood = AddObject(kBloodShape, bloodFrame, static_cast<int>(id), x, m_Pos.y, z);
	if (!blood)
		return;
	blood->m_Visible = true;
	blood->m_ShouldDraw = true;
	blood->m_isContained = false;
}

void U7Object::ApplyDeath(bool quiet)
{
	if (GetIsDead())
		return;

	// Already a corpse — keep the pose, do not re-run side effects.
	if (IsDeathStatus())
	{
		m_hp = 0.0f;
		return;
	}

	StopSleepTimer();
	m_flags &= ~kObjFlagAsleep;
	m_flags &= ~kObjFlagInvisible;
	StopInvisibilityTimer();
	m_hp = 0.0f;
	m_pathWaypoints.clear();
	m_currentWaypointIndex = 0;
	m_pathfindingPending = false;
	m_isMoving = false;
	m_isSchedulePath = false;
	m_combatMoveOrder = false;
	m_combatOrderMode = CombatOrderMode::Automatic;
	m_target = 0;
	m_combatPathTargetId = 0;
	m_combatSpellId = -1;
	m_combatSpellTargetId = 0;
	m_combatSpellHasTile = false;
	m_followingSchedule = false;
	SetDest(m_Pos);
	ReleaseFurnitureClaim();
	m_furnitureObjectId = -1;

	// Exult leaves combat blood pools (shape 912) under the body; ensure at least
	// one splat on true death so corpses are visibly bloody.
	Bleed();

	if (m_UnitType == UnitTypes::UNIT_TYPE_MONSTER)
	{
		// Same lootable-corpse path as NPCs: stay in the world, death pose, open as container.
		m_flags |= kObjFlagDead;
		m_isContainer = true;
		SetOverrideFrame(GetDeathFrameForFacing());
		m_Visible = true;
		m_ShouldDraw = true;
		SetPos(m_Pos); // refresh pick box for flat corpse

		if (!quiet)
			NoteCombatLogClause(m_name.empty() ? "Creature is dead!" : (m_name + " is dead!"), RED);
		if (g_SoundSystem)
			g_SoundSystem->StopLoopingSoundEffect(static_cast<int>(m_ID));
		if (g_mainState && g_mainState->m_barkObject == this)
			g_mainState->ClearBarks();
		return;
	}

	if (m_UnitType != UnitTypes::UNIT_TYPE_NPC || !m_NPCData)
		return;

	m_NPCData->status |= kNpcDatStatusDead;
	m_flags |= kObjFlagDead;
	m_isContainer = true;

	// Halt schedule / conversation coroutines for this NPC.
	if (g_ScriptingSystem)
	{
		if (m_NPCData->m_lastActivity >= 0)
		{
			const std::string activityScript =
				GetActivityScriptName(m_NPCData->m_lastActivity) + "_" + std::to_string(m_NPCID);
			if (g_ScriptingSystem->IsCoroutineActive(activityScript))
				g_ScriptingSystem->CleanupCoroutine(activityScript);
			m_NPCData->m_lastActivity = -1;
		}
		const std::string npcScript = FindNPCScriptByID(m_NPCID);
		if (!npcScript.empty() && g_ScriptingSystem->IsCoroutineActive(npcScript))
			g_ScriptingSystem->CleanupCoroutine(npcScript);
	}

	// Drop from the party (Avatar stays listed as party leader even when dead).
	// The flag is how Resurrect knows to put a companion back.
	if (g_Player && m_NPCID != 0 && g_Player->NPCIDInParty(m_NPCID))
	{
		m_flags |= kObjFlagInParty;
		g_Player->RemovePartyMember(m_NPCID);
	}

	SetOverrideFrame(GetDeathFrameForFacing());
	SetPos(m_Pos); // refresh pick box for flat corpse

	const std::string label = m_name.empty() ? "NPC" : m_name;
	if (!quiet)
		NoteCombatLogClause(label + " is dead!", RED);
}

void U7Object::ResurrectFromDeath()
{
	if (m_UnitType != UnitTypes::UNIT_TYPE_NPC || !m_NPCData)
		return;
	if (!IsDeathStatus())
		return;

	m_NPCData->status &= ~kNpcDatStatusDead;
	m_flags &= ~kObjFlagDead;
	m_hp = m_BaseMaxHP > 0.0f ? m_BaseMaxHP : static_cast<float>(m_NPCData->str);
	if (m_hp < 1.0f)
		m_hp = static_cast<float>(std::max(1, static_cast<int>(m_NPCData->str)));
	m_NPCData->health = static_cast<unsigned short>(m_hp);

	ClearOverrideFrame();
	m_isContainer = true;
	m_Visible = true;
	m_ShouldDraw = true;

	const std::string label = m_name.empty() ? "NPC" : m_name;
	AddCombatLogString(label + " has been resurrected!", GREEN);

	const bool rejoin = (m_flags & kObjFlagInParty) != 0;
	m_flags &= ~kObjFlagInParty;
	if (rejoin && g_Player && m_NPCID > 0)
		g_Player->AddPartyMember(m_NPCID);
}

int U7Object::GetSitFrameForFacing() const
{
	// Exult: frames 0–15 one facing set, 16–31 the other. SW/SE → 26, NE/NW → 10.
	if (m_Direction.z >= 0.0f) // facing southish
		return 26;
	return 10;
}

int U7Object::GetSleepFrameForFacing() const
{
	if (m_Direction.z >= 0.0f)
		return 29;
	return 13;
}

bool U7Object::IsFurnitureClaimedByOther(int furnitureObjectId, int selfObjectId)
{
	if (furnitureObjectId < 0)
		return false;
	// Only NPCs claim furniture — never scan g_objectList (tens of thousands of props).
	for (const auto& pair : g_NPCData)
	{
		if (!pair.second)
			continue;
		auto it = g_objectList.find(pair.second->m_objectID);
		if (it == g_objectList.end() || !it->second)
			continue;
		U7Object* other = it->second.get();
		if (other->m_ID == selfObjectId)
			continue;
		if (other->m_furnitureObjectId == furnitureObjectId ||
			other->m_claimedFurnitureId == furnitureObjectId)
			return true;
	}
	return false;
}

void U7Object::ClaimFurniture(int objectId)
{
	if (objectId < 0)
		return;
	// Drop any previous soft claim.
	if (m_claimedFurnitureId >= 0 && m_claimedFurnitureId != objectId)
		m_claimedFurnitureId = -1;
	m_claimedFurnitureId = objectId;
}

void U7Object::ReleaseFurnitureClaim()
{
	m_claimedFurnitureId = -1;
}

void U7Object::SitOnObject(U7Object* chair)
{
	if (!chair)
		return;
	if (IsFurnitureClaimedByOther(chair->m_ID, m_ID))
	{
		// Lost the race — don't keep a soft-claim that blocks everyone else.
		if (m_claimedFurnitureId == chair->m_ID)
			ReleaseFurnitureClaim();
		return;
	}
	ClearPendingUsecode();
	m_claimedFurnitureId = chair->m_ID;
	m_furnitureObjectId = chair->m_ID;
	// Snap to chair tile center (same convention as path destinations).
	Vector3 sitPos = chair->GetPos();
	sitPos.x = floorf(sitPos.x) + 0.5f;
	sitPos.z = floorf(sitPos.z) + 0.5f;
	// Keep NPC feet Y; chairs are ground furniture.
	sitPos.y = m_Pos.y;
	SetPos(sitPos);
	SetOverrideFrame(GetSitFrameForFacing());
}

void U7Object::LieOnObject(U7Object* bed)
{
	if (!bed)
		return;
	if (IsFurnitureClaimedByOther(bed->m_ID, m_ID))
	{
		if (m_claimedFurnitureId == bed->m_ID)
			ReleaseFurnitureClaim();
		return;
	}
	ClearPendingUsecode();
	m_claimedFurnitureId = bed->m_ID;
	m_furnitureObjectId = bed->m_ID;
	Vector3 liePos = bed->GetPos();
	liePos.x = floorf(liePos.x) + 0.5f;
	liePos.z = floorf(liePos.z) + 0.5f;
	liePos.y = m_Pos.y;
	SetPos(liePos);
	SetOverrideFrame(GetSleepFrameForFacing());
}

bool U7Object::TryNudgeOffSolidBlocker(const Vector3* toward)
{
	if (!g_pathfindingSystem)
		return false;

	const int curX = static_cast<int>(std::floor(m_Pos.x));
	const int curZ = static_cast<int>(std::floor(m_Pos.z));
	const Vector3 startPos = m_Pos;

	auto makeStand = [&](int tx, int tz) -> Vector3 {
		Vector3 stand{ tx + 0.5f, m_Pos.y, tz + 0.5f };
		auto heights = g_pathfindingSystem->GetWalkableSurfaceHeights(tx, tz);
		if (!heights.empty())
		{
			float best = heights[0];
			float bestD = fabsf(best - m_Pos.y);
			for (float h : heights)
			{
				const float d = fabsf(h - m_Pos.y);
				if (d < bestD) { bestD = d; best = h; }
			}
			stand.y = best;
		}
		return stand;
	};

	auto scoreToward = [&](int tx, int tz) -> float {
		// Lower is better. Prefer adjacent clear tiles; light bias toward the goal
		// so a formation slot through a tree does not beat a free sideways stand.
		float score = static_cast<float>(std::max(std::abs(tx - curX), std::abs(tz - curZ)));
		if (toward)
		{
			const int gx = static_cast<int>(std::floor(toward->x));
			const int gz = static_cast<int>(std::floor(toward->z));
			const float before = static_cast<float>(std::max(std::abs(curX - gx), std::abs(curZ - gz)));
			const float after = static_cast<float>(std::max(std::abs(tx - gx), std::abs(tz - gz)));
			score += (after - before) * 1.5f;
		}
		return score;
	};

	// 1) ValidateMove onto a neighbor tile center (same gate as real walking).
	float bestScore = 1e30f;
	Vector3 bestStand{};
	bool found = false;
	static const int kDx[8] = { 1, -1, 0, 0, 1, 1, -1, -1 };
	static const int kDz[8] = { 0, 0, 1, -1, 1, -1, 1, -1 };
	for (int i = 0; i < 8; ++i)
	{
		const int tx = curX + kDx[i];
		const int tz = curZ + kDz[i];
		if (tx < 0 || tx >= 3072 || tz < 0 || tz >= 3072)
			continue;
		Vector3 dest = makeStand(tx, tz);
		float outH = dest.y;
		if (!PathfindingSystem::ValidateMove(this, dest, outH))
			continue;
		dest.y = outH;
		const float s = scoreToward(tx, tz);
		if (s < bestScore)
		{
			bestScore = s;
			bestStand = dest;
			found = true;
		}
	}

	if (found)
	{
		SetPos(bestStand);
		return Vector2Distance({ startPos.x, startPos.z }, { m_Pos.x, m_Pos.z }) > 0.01f;
	}

	// 2) Force snap to nearest walkable stand in a small radius (already overlapping
	// a solid so every ValidateMove from here fails — e.g. standing on a stamped 1×1).
	for (int r = 1; r <= 3; ++r)
	{
		bestScore = 1e30f;
		found = false;
		int bestX = curX, bestZ = curZ;
		for (int dz = -r; dz <= r; ++dz)
		{
			for (int dx = -r; dx <= r; ++dx)
			{
				if (std::max(std::abs(dx), std::abs(dz)) != r)
					continue;
				const int tx = curX + dx;
				const int tz = curZ + dz;
				if (tx < 0 || tx >= 3072 || tz < 0 || tz >= 3072)
					continue;
				if (!g_pathfindingSystem->IsPositionWalkable(tx, tz, m_Pos.y, this))
					continue;
				const float s = scoreToward(tx, tz);
				if (s < bestScore)
				{
					bestScore = s;
					bestX = tx;
					bestZ = tz;
					found = true;
				}
			}
		}
		if (found)
		{
			SetPos(makeStand(bestX, bestZ));
			return Vector2Distance({ startPos.x, startPos.z }, { m_Pos.x, m_Pos.z }) > 0.01f;
		}
	}

	Vector3 stand{};
	if (g_pathfindingSystem->FindNearestWalkableStand(m_Pos, m_Pos.y, this, stand, 3))
	{
		const int sx = static_cast<int>(std::floor(stand.x));
		const int sz = static_cast<int>(std::floor(stand.z));
		if (sx != curX || sz != curZ)
		{
			SetPos(stand);
			return true;
		}
	}
	return false;
}

void U7Object::UnstickFromFurniture(const Vector3* toward)
{
	// Soft claim can drop immediately — the seat is free for others once we stand.
	// Keep m_furnitureObjectId until we've stepped clear so ValidateMove still
	// ignores the chair/bed AABB (otherwise the first path step fights the seat).
	m_claimedFurnitureId = -1;

	if (!g_pathfindingSystem)
	{
		m_furnitureObjectId = -1;
		return;
	}

	const int curX = (int)floorf(m_Pos.x);
	const int curZ = (int)floorf(m_Pos.z);

	auto scoreTile = [&](int tx, int tz) -> float {
		if (!g_pathfindingSystem->IsPositionWalkable(tx, tz, m_Pos.y, this))
			return 1e30f;
		float score = (float)(std::abs(tx - curX) + std::abs(tz - curZ));
		if (toward)
		{
			const int gx = (int)floorf(toward->x);
			const int gz = (int)floorf(toward->z);
			// Prefer tiles that reduce Chebyshev distance to the next destination.
			const float before = (float)std::max(std::abs(curX - gx), std::abs(curZ - gz));
			const float after = (float)std::max(std::abs(tx - gx), std::abs(tz - gz));
			score += (after - before) * 10.0f; // strong bias toward goal
		}
		return score;
	};

	auto makeStand = [&](int tx, int tz) -> Vector3 {
		Vector3 stand{ tx + 0.5f, m_Pos.y, tz + 0.5f };
		auto heights = g_pathfindingSystem->GetWalkableSurfaceHeights(tx, tz);
		if (!heights.empty())
		{
			float best = heights[0];
			float bestD = fabsf(best - m_Pos.y);
			for (float h : heights)
			{
				const float d = fabsf(h - m_Pos.y);
				if (d < bestD) { bestD = d; best = h; }
			}
			stand.y = best;
		}
		return stand;
	};

	// Always try to step off the seat tile onto the best neighbor (toward goal if any).
	float bestScore = 1e30f;
	int bestX = curX, bestZ = curZ;
	bool foundNeighbor = false;
	for (int r = 1; r <= 2; ++r)
	{
		for (int dz = -r; dz <= r; ++dz)
		{
			for (int dx = -r; dx <= r; ++dx)
			{
				if (std::max(std::abs(dx), std::abs(dz)) != r)
					continue;
				const int tx = curX + dx;
				const int tz = curZ + dz;
				const float s = scoreTile(tx, tz);
				if (s < bestScore)
				{
					bestScore = s;
					bestX = tx;
					bestZ = tz;
					foundNeighbor = true;
				}
			}
		}
		if (foundNeighbor)
			break; // Prefer immediate adjacency when available.
	}

	if (foundNeighbor)
		SetPos(makeStand(bestX, bestZ));
	else
	{
		Vector3 stand{};
		if (g_pathfindingSystem->FindNearestWalkableStand(m_Pos, m_Pos.y, this, stand, 2))
		{
			if ((int)floorf(stand.x) != curX || (int)floorf(stand.z) != curZ)
				SetPos(stand);
		}
	}

	SetDest(m_Pos);
	// m_furnitureObjectId retained until ReleaseFurnitureIfClear() — see UpdateMovement.
}

void U7Object::ReleaseFurnitureIfClear()
{
	if (m_furnitureObjectId < 0 || m_isFrameOverridden)
		return; // Still posed, or nothing to release.

	auto it = g_objectList.find(m_furnitureObjectId);
	if (it == g_objectList.end() || !it->second)
	{
		m_furnitureObjectId = -1;
		return;
	}

	const Vector3 furnPos = it->second->GetPos();
	const int dx = std::abs((int)floorf(m_Pos.x) - (int)floorf(furnPos.x));
	const int dz = std::abs((int)floorf(m_Pos.z) - (int)floorf(furnPos.z));
	// One tile away is enough — seat is free and collision ignore can drop.
	if (std::max(dx, dz) > 1)
		m_furnitureObjectId = -1;
}

int U7Object::GetShapeAnimFrameCount() const
{
	if (m_ObjectType < 0 || m_ObjectType >= 1024)
		return 1;

	int declared = g_shapeTable[m_ObjectType][0].m_numFrames;
	if (declared < 1)
		declared = 1;
	if (declared > 32)
		declared = 32;

	// Prefer declared length when textures exist; otherwise walk back from
	// declared-1 to the last frame with a usable texture (skips empty high slots).
	int lastGood = 0;
	for (int i = 0; i < declared; ++i)
	{
		if (g_shapeTable[m_ObjectType][i].m_texture != nullptr
			|| g_shapeTable[m_ObjectType][i].IsValid())
		{
			lastGood = i;
		}
	}
	const int count = lastGood + 1;
	return count > 0 ? count : 1;
}

void U7Object::ClearMeshOneShot()
{
	m_meshOneShotPlaying = false;
	m_meshOneShotFrameTimer = 0.0f;
	m_meshPoseAnim.clear();
	m_meshPoseFrame = 0;
}

void U7Object::ApplyDefaultAnimMode()
{
	// TFA isAnimated: VGA ambient FX (bubbles, etc.) cycle frames in InteractiveDraw.
	// TFA isLightSource: lit sconces/torches/lamps (435/701/526/…) keep fire mesh
	// idle playing. Their TFA anim bit is clear (Exult also skips Frame_animator),
	// so Auto here only unlocks playMeshAnim — VGA SetFrame still needs isAnimated.
	if (m_objectData && (m_objectData->m_isAnimated || m_objectData->m_isLightSource))
	{
		ClearMeshOneShot();
		m_animMode = ObjectAnimMode::Auto;
		return;
	}

	m_animMode = ObjectAnimMode::Frozen;
	m_meshOneShotPlaying = false;
	m_meshOneShotFrameTimer = 0.0f;

	// Unlit torch (595) / spent sconce (535): rest on the last extinguish frame.
	RaylibModel* mesh = (m_shapeData && m_shapeData->m_customMesh)
		? m_shapeData->m_customMesh
		: nullptr;
	if (mesh)
	{
		const int n = mesh->GetAnimationFrameCount(kMeshExtinguishAnim);
		if (n > 0)
		{
			m_meshPoseAnim = kMeshExtinguishAnim;
			m_meshPoseFrame = n - 1;
			return;
		}
	}

	m_meshPoseAnim.clear();
	m_meshPoseFrame = 0;
}

void U7Object::BeginMeshExtinguishOneShot()
{
	RaylibModel* mesh = (m_shapeData && m_shapeData->m_customMesh)
		? m_shapeData->m_customMesh
		: nullptr;
	const int n = mesh ? mesh->GetAnimationFrameCount(kMeshExtinguishAnim) : 0;
	if (n <= 0)
	{
		ApplyDefaultAnimMode();
		return;
	}

	// Drive frames manually in InteractiveDraw; hold last when done.
	m_animMode = ObjectAnimMode::Frozen;
	m_meshPoseAnim = kMeshExtinguishAnim;
	m_meshPoseFrame = 0;
	m_meshOneShotFrameTimer = 0.0f;
	m_meshOneShotPlaying = (n > 1);
	if (!m_meshOneShotPlaying)
		m_meshPoseFrame = n - 1;
}

void U7Object::RestoreAnimModeAfterScript()
{
	if (IsInUsecodeScript())
		return;

	// Exult: when the cast script finishes, drop casting frames.
	if (m_castingMode == CastingMode::ShowCastingFrames
	    || m_castingMode == CastingMode::InitCasting)
		HideCastingFrames();

	ApplyDefaultAnimMode();
}

void U7Object::BeginCasting(int shape)
{
	m_castingShape = (shape > 0 && shape < 1024) ? shape : 859;
	// Exult: init only — overlay appears when the cast usecode script starts.
	m_castingMode = CastingMode::InitCasting;
}

void U7Object::DisplayCastingFrames()
{
	if (m_castingMode == CastingMode::InitCasting
	    || m_castingMode == CastingMode::ShowCastingFrames)
		m_castingMode = CastingMode::ShowCastingFrames;
}

void U7Object::HideCastingFrames()
{
	m_castingMode = CastingMode::NotCasting;
}

void U7Object::DrawCastingFramesOverlay(Vector3 finalPos, Vector2 bodyDims, float billboardAngle, Color lighting)
{
	// InitCasting = armed but not yet animating (e.g. waiting on click_on_item).
	if (m_castingMode != CastingMode::ShowCastingFrames)
		return;
	const int shape = m_castingShape;
	if (shape <= 0 || shape >= 1024)
		return;

	// Prefer usecode pose from action state when set; else m_Frame nibble.
	int pose = m_Frame & 0x0f;
	switch (m_npcAnimAction)
	{
	case NpcAnimAction::Attack1H:
		pose = (m_npcAnimPhase <= 1) ? 4 : (m_npcAnimPhase == 2 ? 5 : 6);
		break;
	case NpcAnimAction::Attack2H:
		pose = (m_npcAnimPhase <= 1) ? 7 : (m_npcAnimPhase == 2 ? 8 : 9);
		break;
	case NpcAnimAction::Up:  pose = 14; break;
	case NpcAnimAction::Out: pose = 15; break;
	case NpcAnimAction::Kneel: pose = 12; break;
	default: break;
	}

	// Exult Actor::figure_weapon_pos — NPC pose → casting-frame index (shape 859).
	int weaponFrame = 1;
	switch (pose)
	{
	case 4: case 7: weaponFrame = 4; break; // raise1 / raise2
	case 5: case 8: weaponFrame = 3; break; // reach1 / reach2
	case 6: case 9: weaponFrame = 2; break; // strike1 / strike2
	case 14:        weaponFrame = 5; break; // up
	case 15:        weaponFrame = 6; break; // out
	default:        weaponFrame = 1; break; // standing / kneel / etc.
	}

	auto pickCastTex = [&](int frame) -> Texture* {
		if (frame < 0 || frame >= 32)
			return nullptr;
		ShapeData& sd = g_shapeTable[shape][frame];
		if (!sd.m_texture)
			return nullptr;
		Texture& tex = sd.m_texture->m_Texture;
		if (tex.id == 0 || tex.width <= 1 || tex.height <= 1)
			return nullptr;
		return &tex;
	};

	Texture* tex = pickCastTex(weaponFrame);
	if (!tex)
		tex = pickCastTex(1);
	if (!tex)
		return;

	// Native SHAPES.VGA scale (8 px = 1 tile). Tiny hand sparks need a boost
	// to read in 3D; large "out" glows stay near native size.
	const bool tiny = (tex->width <= 12 && tex->height <= 12);
	float scale = tiny ? 3.5f : 1.0f;
	Vector2 dims = {
		float(tex->width) / 8.0f * scale,
		float(tex->height) / 8.0f * scale
	};
	const float bodyH = (bodyDims.y > 0.1f) ? bodyDims.y : 2.0f;
	// Hand sparks: at least ~22% of body height. Full-body out glow: cap at body.
	const float minDim = tiny ? (bodyH * 0.22f) : 0.0f;
	const float maxDim = tiny ? (bodyH * 0.40f) : (bodyH * 0.95f);
	if (minDim > 0.0f && dims.y < minDim)
	{
		const float m = minDim / std::max(dims.y, 0.01f);
		dims.x *= m;
		dims.y *= m;
	}
	if (dims.x > maxDim || dims.y > maxDim)
	{
		const float m = maxDim / std::max(dims.x, dims.y);
		dims.x *= m;
		dims.y *= m;
	}

	// Approximate Exult weapon-in-hand placement relative to the body billboard.
	Vector3 overlayPos = finalPos;
	switch (pose)
	{
	case 4: case 7: // raise — hands up
		overlayPos.y += bodyH * 0.18f;
		break;
	case 5: case 8: // reach
		overlayPos.y += bodyH * 0.08f;
		break;
	case 6: case 9: // strike — toward facing
		overlayPos = Vector3Add(overlayPos, Vector3Scale(m_Direction, bodyH * 0.12f));
		overlayPos.y += bodyH * 0.05f;
		break;
	case 14: // up — above head
		overlayPos.y += bodyH * 0.42f;
		break;
	case 15: // out — wide arm glow, slightly up
		overlayPos.y += bodyH * 0.12f;
		break;
	default:
		overlayPos.y += bodyH * 0.05f;
		break;
	}

	Vector3 toCam = Vector3Subtract(g_camera.position, overlayPos);
	const float lenSq = toCam.x * toCam.x + toCam.y * toCam.y + toCam.z * toCam.z;
	if (lenSq > 1e-6f)
		overlayPos = Vector3Add(overlayPos, Vector3Scale(Vector3Normalize(toCam), 0.10f));

	(void)lighting;
	Color glow = WHITE;
	SetTextureFilter(*tex, TEXTURE_FILTER_POINT);

	rlDisableDepthTest();
	rlDisableDepthMask();
	BeginBlendMode(BLEND_ALPHA);
	DrawBillboardPro(g_camera, *tex,
		Rectangle{ 0, 0, float(tex->width), float(tex->height) },
		overlayPos, Vector3{ 0, 1, 0 },
		dims, Vector2{ 0, 0 }, billboardAngle, glow);
	EndBlendMode();
	rlEnableDepthMask();
	rlEnableDepthTest();
}

void U7Object::SetFrame(int frame)
{
	if (frame < 0 || frame >= 32)
	{
		return;
	}

	if (m_ObjectType < 0 || m_ObjectType >= 1024)
	{
		return;
	}

	const bool isDoor = (m_objectData && m_objectData->m_isDoor);

	// Animated props: prefer declared anim length. Doors use frame%4 lock/open
	// states across the full 0–31 range and must not be clipped by anim length.
	if (!isDoor)
	{
		const int animFrames = g_shapeTable[m_ObjectType][0].m_numFrames;
		if (animFrames > 1 && frame >= animFrames)
		{
			return;
		}
		// Non-door shapes still require a usable texture frame.
		if (g_shapeTable[m_ObjectType][frame].m_texture == nullptr)
		{
			return;
		}
	}

	// Store old frame to check if it actually changed
	int oldFrame = m_Frame;

	// Update frame and shapeData pointer
	m_Frame = frame;
	m_shapeData = &g_shapeTable[m_ObjectType][m_Frame];

	// Notify pathfinding grid if this is a door (frame change affects walkability)
	// Doors: frame%4 == 0/2/3 closed-ish, == 1 open (scripts drive the exact swap).
	if (isDoor && oldFrame != frame)
	{
		NotifyPathfindingGridUpdate((int)m_Pos.x, (int)m_Pos.z);
	}
}

void U7Object::SetAbsoluteFrame(int frame)
{
	if (frame < 0 || frame >= 32)
	{
		return;
	}

	if (m_ObjectType < 0 || m_ObjectType >= 1024)
	{
		return;
	}

	const bool isDoor = (m_objectData && m_objectData->m_isDoor);

	// Same anim-length limit as SetFrame. A null texture is still stored:
	// set_object_frame(4) on the mage must stick so the walksheet can hide.
	if (!isDoor)
	{
		const int animFrames = g_shapeTable[m_ObjectType][0].m_numFrames;
		if (animFrames > 1 && frame >= animFrames)
		{
			return;
		}
	}

	const int oldFrame = m_Frame;
	m_Frame = frame;
	m_shapeData = &g_shapeTable[m_ObjectType][m_Frame];

	// Doors opened by script still update the walk grid.
	if (isDoor && oldFrame != frame)
	{
		NotifyPathfindingGridUpdate((int)m_Pos.x, (int)m_Pos.z);
	}

	// Doors draw their own frames. This only stands in for an empty walksheet cel.
	if (isDoor)
	{
		m_drawSuppressedByEmptyFrame = false;
		return;
	}

	// A 1-pixel texture is the unloaded default: that cel has no pixels.
	auto* frameTexture = g_shapeTable[m_ObjectType][m_Frame].m_texture.get();
	const bool pictured = frameTexture && frameTexture->width > 1 && frameTexture->height > 1;
	m_drawSuppressedByEmptyFrame = !pictured;
}

float U7Object::Pick()
{
	if (g_objectDataTable[m_shapeData->m_shape].m_name == "rug")
		return -1;

	Ray ray = GetMouseRay(GetMousePosition(), g_camera);

	RayCollision collision = GetRayCollisionBox(ray, m_boundingBox);

	if (collision.hit)
	{
		return collision.distance;
	}
	else
	{
		return -1;
	}
}

float U7Object::PickXYZ(Vector3& pos)
{
	if (g_objectDataTable[m_shapeData->m_shape].m_name == "rug")
		return -1;

	Ray ray = GetMouseRay(GetMousePosition(), g_camera);

	RayCollision collision = GetRayCollisionBox(ray, m_boundingBox);

	if (collision.hit)
	{
		pos = collision.point;
		return collision.distance;
	}
	else
	{
		return -1;
	}
}

void U7Object::SetDest(Vector3 dest)
{
	m_Dest = dest;

	Vector3 delta = Vector3Subtract(m_Dest, m_Pos);
	delta.y = 0.0f;
	const float distXZ = Vector3Length(delta);
	// Ignore tiny/zero XZ deltas — they jitter facing (often a 180° flip when
	// Dest ends up slightly behind after an overshoot or key-release stop).
	if (distXZ < 0.05f)
		return;

	m_Direction = Vector3Normalize(delta);
}

void U7Object::TryOpenDoorAtCurrentPosition()
{
	int worldX = (int)floorf(m_Pos.x);
	int worldZ = (int)floorf(m_Pos.z);

	// Cache to avoid checking the same position multiple times per tile
	static std::unordered_map<int, std::pair<int, int>> lastCheckedPos;  // npcID -> (x, z)

	auto it = lastCheckedPos.find(m_NPCID);
	if (it != lastCheckedPos.end() && it->second.first == worldX && it->second.second == worldZ)
	{
		return;  // Already checked this position recently
	}
	lastCheckedPos[m_NPCID] = {worldX, worldZ};

	if (!g_pathfindingSystem)
		return;

	// Standing on a door tile, or adjacent (approach). Closed doors block the
	// opening; pathfinding plans through them and we open on contact.
	for (int dz = -1; dz <= 1; ++dz)
	{
		for (int dx = -1; dx <= 1; ++dx)
		{
			auto overlappingObjects =
				g_pathfindingSystem->GetOverlappingObjects(worldX + dx, worldZ + dz);
			for (const auto& ovObj : overlappingObjects)
			{
				U7Object* obj = ovObj.obj;
				if (!obj || !obj->m_objectData || !obj->m_objectData->m_isDoor)
					continue;
				obj->Interact(1);  // Event 1 = double-click / open
				return;
			}
		}
	}
}

// Exult Ucscript opcodes (ucscriptop.h). Lua decompiler stores them as
// 0x1Exx / 0x1Fxx / 0x44xx with the real opcode in the low byte.
namespace {
	enum UsecodeScriptOp : int {
		UC_CONT = 0x01,
		UC_NOP1 = 0x02,
		UC_RESET = 0x0a,
		UC_REPEAT = 0x0b,
		UC_REPEAT2 = 0x0c,
		UC_NOP2 = 0x21,
		UC_DONT_HALT = 0x23,
		UC_WAIT_NEAR = 0x24,
		UC_DELAY_TICKS = 0x27,
		UC_DELAY_MINUTES = 0x28,
		UC_DELAY_HOURS = 0x29,
		UC_WAIT_FAR = 0x2b,
		UC_FINISH = 0x2c,
		UC_REMOVE = 0x2d,
		UC_FRAME = 0x46,
		UC_NEXT_FRAME_MAX = 0x4d,
		UC_NEXT_FRAME = 0x4e,
		UC_PREV_FRAME_MIN = 0x4f,
		UC_PREV_FRAME = 0x50,
		UC_SAY = 0x52,
		UC_STEP = 0x53,
		UC_MUSIC = 0x54,
		UC_USECODE = 0x55,
		UC_SPEECH = 0x56,
		UC_SFX = 0x58,
		UC_FACE_DIR = 0x59,
		UC_WEATHER = 0x5A,
		UC_NPC_FRAME_BASE = 0x61, // 0x61-0x70
		UC_ATTACK = 0x7A,         // Exult: attack using set_to_attack values
	};

	// Exult c_std_delay is 200 ms per usecode script step (cast poses, etc.).
	constexpr float kUsecodeTickSec = 0.20f;

	int DecodeScriptOpcode(int raw)
	{
		if (raw >= 0 && raw <= 0x81)
			return raw;
		// Lua-encoded: opcode in low byte (0x1E46, 0x440B, …)
		if (raw > 255 || raw < -255)
			return raw & 0xff;
		return raw;
	}

	bool ScriptElemIsInt(const U7Object::UsecodeScriptElem& e)
	{
		return std::holds_alternative<int>(e);
	}

	int ScriptElemInt(const U7Object::UsecodeScriptElem& e, int fallback = 0)
	{
		return std::holds_alternative<int>(e) ? std::get<int>(e) : fallback;
	}

	// Function 1786 and function 506 both name a script ending in _0506.
	// 1786 is the high function (id - 1280): utility_event_0506, the tremor.
	// 506 is the low function: object_unknown_0506, Batlin after Hook dies.
	// Alphabetical order would run Batlin. Pick by which id was requested.
	std::string FindUsecodeScriptByFunction(int fun)
	{
		if (!g_ScriptingSystem)
			return {};

		const int scriptNum = fun >= 1280 ? fun - 1280 : fun;
		char numBuf[8];
		snprintf(numBuf, sizeof(numBuf), "%04d", scriptNum);
		const std::string suffix = std::string("_") + numBuf;

		std::vector<std::string> matches;
		for (const auto& script : g_ScriptingSystem->m_scriptFiles)
		{
			const std::string& name = script.first;
			if (name.size() < suffix.size())
				continue;
			if (name.compare(name.size() - suffix.size(), suffix.size(), suffix) != 0)
				continue;
			if (name.rfind("spell_", 0) == 0)
				continue;
			matches.push_back(name);
		}
		if (matches.empty())
			return {};
		if (matches.size() == 1)
			return matches[0];

		const char* highFirst[] = {
			"utility_forge_", "utility_unknown_", "utility_event_",
			"utility_clock_", "utility_ship_", "utility_", "npc_"
		};
		const char* lowFirst[] = { "object_", "npc_", "func_" };
		const char** prefixes = fun >= 1280 ? highFirst : lowFirst;
		const int prefixCount = fun >= 1280 ? 7 : 3;
		for (int i = 0; i < prefixCount; ++i)
		{
			const char* prefix = prefixes[i];
			const size_t prefixLen = std::char_traits<char>::length(prefix);
			for (const auto& name : matches)
			{
				if (name.compare(0, prefixLen, prefix) == 0)
					return name;
			}
		}
		return matches[0];
	}
}

bool U7Object::IsInUsecodeScript() const
{
	for (const auto& s : m_usecodeScripts)
	{
		if (s.active)
			return true;
	}
	return false;
}

void U7Object::SetUsecodeAttackTarget(int targetId, int weaponShape)
{
	m_usecodeAttackTargetId = targetId;
	m_usecodeAttackWeaponShape = weaponShape;
}

bool U7Object::FireUsecodeAttack()
{
	const int weaponShape = m_usecodeAttackWeaponShape;
	const int targetId = m_usecodeAttackTargetId;
	m_usecodeAttackWeaponShape = -1;
	m_usecodeAttackTargetId = -1;

	if (weaponShape <= 0 || weaponShape >= 1024 || targetId <= 0)
	{
		NPCDebugPrint("usecode_attack: missing target/weapon on object " + std::to_string(m_ID) +
			" weapon=" + std::to_string(weaponShape) + " target=" + std::to_string(targetId));
		return false;
	}

	U7Object* target = GetObjectFromID(targetId);

	// Energy Mist (399) and Death Vortex (639). WEAPONS.DAT explodes and the
	// ammo row is homing, so Exult never fires a bolt. The cloud starts on the caster.
	if (weaponShape == 399 || weaponShape == 639)
	{
		if (weaponShape == 639)
			StartDeathVortex(this, target);
		else
			StartEnergyMist(this, target);
		if (m_pauseOrdersOnNextSpellProjectile)
		{
			m_pauseOrdersOnNextSpellProjectile = false;
			if (g_mainState && g_isCombatMode)
				g_mainState->NotifyCombatantCannotContinue(this, "needs a new order!");
		}
		return true;
	}

	if (!target || target->GetIsDead() || target->IsDeathStatus())
	{
		NPCDebugPrint("usecode_attack: bad target " + std::to_string(targetId) +
			" on object " + std::to_string(m_ID));
		return false;
	}

	// Spell bolts: fly with fixed spell damage (or 0 for utility bolts like Douse 540).
	// Other shapes still spawn a missile; damage 0 lets impact path use weapon tables when present.
	int damage = 0;
	int damageType = 0;
	float speed = 18.0f;
	if (weaponShape == 856)
	{
		damage = 10;
		damageType = 1; // fire
	}
	else if (weaponShape == 540)
	{
		// Douse (An Flam) — extinguish on impact via spell event 4; no HP damage.
		damage = 0;
		damageType = 0;
		speed = 16.0f;
	}
	else if (weaponShape == 280)
	{
		// Ignite (In Flam) — light on impact via spell event 4; no HP damage.
		damage = 0;
		damageType = 0;
		speed = 16.0f;
	}
	else if (weaponShape == 443)
	{
		// Telekinesis (Ort Por Ylem) — remote-use on impact via spell event 4.
		damage = 0;
		damageType = 0;
		speed = 16.0f;
	}
	else if (weaponShape == 424)
	{
		// In Nox poison bolt — apply poisoned flag on impact (no HP from the bolt itself).
		damage = 0;
		damageType = 0;
		speed = 16.0f;
	}
	else if (weaponShape == 72 || weaponShape == 281 || weaponShape == 408)
	{
		// Sleep (72) / Curse (281) / Paralyze (408) — status on impact via spell event 4.
		damage = 0;
		damageType = 0;
		speed = 16.0f;
	}
	else if (weaponShape == 527)
	{
		// Death Bolt (Corp Por). Table damage is 0, so this 20 is the whole hit.
		// The explodes bit stays single-target. Intellect kill is on impact.
		damage = 20;
		damageType = 2; // magic
		speed = 18.0f;
	}
	else if (weaponShape == 78)
	{
		// Explosion (shape 78). WEAPONS.DAT: fire damage 16, ranged, reach 16.
		// The flying art is projectile 856. Impact detonates; damage stays 0 here
		// so the hit path uses the weapon row inside the blast.
		const int ax = static_cast<int>(std::floor(m_Pos.x));
		const int az = static_cast<int>(std::floor(m_Pos.z));
		const int ay = static_cast<int>(std::floor(m_Pos.y));
		const int bx = static_cast<int>(std::floor(target->m_Pos.x));
		const int bz = static_cast<int>(std::floor(target->m_Pos.z));
		const int by = static_cast<int>(std::floor(target->m_Pos.y));
		const int dx = std::abs(ax - bx);
		const int dz = std::abs(az - bz);
		const int dy = std::abs(ay - by);
		const int tileDist = std::max(dx, std::max(dz, dy));
		if (tileDist > 16)
		{
			if (g_Player && g_Player->NPCIDInParty(m_NPCID))
			{
				AddConsoleString("Out of range", RED);
			}
			return false;
		}
		damage = 0;
		damageType = 1; // fire
		speed = 18.0f;
	}
	else if (weaponShape == 80)
	{
		// Charm (shape 80). WEAPONS.DAT: damage 0, autohit, charm power,
		// projectile 540. Damage stays 0 so impact uses the weapon row.
		// weaponShape stays 80 so the bolt is not treated as Douse.
		damage = 0;
		damageType = 0;
		speed = 16.0f;
	}
	else if (weaponShape == 287)
	{
		// Swordstrike. Damage 35, lucky, range 30, very fast. The blast on
		// impact applies the weapon row once. Damage stays 0 on the bolt.
		const int ax = static_cast<int>(std::floor(m_Pos.x));
		const int az = static_cast<int>(std::floor(m_Pos.z));
		const int ay = static_cast<int>(std::floor(m_Pos.y));
		const int bx = static_cast<int>(std::floor(target->m_Pos.x));
		const int bz = static_cast<int>(std::floor(target->m_Pos.z));
		const int by = static_cast<int>(std::floor(target->m_Pos.y));
		const int tileDist = std::max(std::abs(ax - bx), std::max(std::abs(az - bz), std::abs(ay - by)));
		if (tileDist > 30)
		{
			if (g_Player && g_Player->NPCIDInParty(m_NPCID))
				AddConsoleString("Out of range", RED);
			return false;
		}
		damage = 0;
		damageType = 0;
		speed = 28.0f;
	}

	int visualShape = weaponShape;
	if (weaponShape == 78)
	{
		visualShape = 856;
	}
	else if (weaponShape == 80)
	{
		visualShape = 540;
		if (const WeaponData* w = GetWeaponData(80))
		{
			if (w->projectile > 0 && w->projectile < 1024)
				visualShape = w->projectile;
		}
	}

	const bool ok = SpawnFlyingProjectile(visualShape, static_cast<int>(m_ID), targetId, speed,
		damage, damageType, weaponShape, -1);
	if (!ok)
	{
		// Status-spell fallback when the bolt shape has no drawable frames.
		if (g_ScriptingSystem &&
		    (weaponShape == 72 || weaponShape == 281 || weaponShape == 408 ||
		     weaponShape == 424 || weaponShape == 540 || weaponShape == 280 ||
		     weaponShape == 443))
		{
			const char* script = nullptr;
			if (weaponShape == 72) script = "spell_sleep_in_zu_0351";
			else if (weaponShape == 281) script = "spell_untrap_des_sanct_0344";
			else if (weaponShape == 408) script = "spell_paralyze_an_por_0348";
			else if (weaponShape == 424) script = "spell_poison_in_nox_0350";
			else if (weaponShape == 540) script = "spell_dispel_fire_an_flam_0322";
			else if (weaponShape == 280) script = "spell_fireball_in_flam_0326";
			else if (weaponShape == 443) script = "spell_telekinesis_ort_por_ylem_0342";
			if (script)
			{
				g_ScriptingSystem->CallScript(script,
					{ static_cast<lua_Integer>(4), static_cast<lua_Integer>(targetId) });
				if (m_pauseOrdersOnNextSpellProjectile)
				{
					m_pauseOrdersOnNextSpellProjectile = false;
					if (g_mainState && g_isCombatMode)
						g_mainState->NotifyCombatantCannotContinue(this, "needs a new order!");
				}
				return true;
			}
		}
		NPCDebugPrint("usecode_attack: SpawnFlyingProjectile failed shape=" +
			std::to_string(weaponShape) + " from=" + std::to_string(m_ID) +
			" to=" + std::to_string(targetId));
		return false;
	}
	if (m_pauseOrdersOnNextSpellProjectile)
	{
		MarkNewestFlyingProjectilePauseCasterOnHit(static_cast<int>(m_ID));
		m_pauseOrdersOnNextSpellProjectile = false;
	}
	return true;
}

void U7Object::StartUsecodeScript(std::vector<UsecodeScriptElem> code, float initialDelaySec)
{
	if (code.empty())
		return;

	// Peek leading dont_halt / finish flags (Exult start()), and whether any
	// opcode will change frames (enter Scripted mode for the spin/craft).
	bool noHalt = false;
	bool touchesFrames = false;
	bool stillInLeadingFlags = true;
	for (const auto& elem : code)
	{
		if (!ScriptElemIsInt(elem))
		{
			stillInLeadingFlags = false;
			continue;
		}
		const int op = DecodeScriptOpcode(ScriptElemInt(elem));
		if (stillInLeadingFlags)
		{
			if (op == UC_DONT_HALT)
			{
				noHalt = true;
				continue;
			}
			if (op == UC_FINISH)
				continue;
			stillInLeadingFlags = false;
		}
		if (op == UC_FRAME || op == UC_NEXT_FRAME || op == UC_NEXT_FRAME_MAX
			|| op == UC_PREV_FRAME || op == UC_PREV_FRAME_MIN
			|| (op >= UC_NPC_FRAME_BASE && op <= UC_NPC_FRAME_BASE + 15))
		{
			touchesFrames = true;
		}
	}

	// Exult: starting a new script terminates existing halt-able scripts on this object.
	// dont_halt scripts are left alone so delayed sequential barks can coexist.
	// Mark inactive instead of erasing. UpdateUsecodeScript may be inside one of these
	// lists (the usecode opcode that started this one); erasing it would free that step.
	for (auto& existing : m_usecodeScripts)
	{
		if (existing.active && !existing.noHalt)
			existing.active = false;
	}
	for (auto& existing : m_pendingUsecodeScripts)
	{
		if (existing.active && !existing.noHalt)
			existing.active = false;
	}

	if (touchesFrames)
		m_animMode = ObjectAnimMode::Scripted;

	// Exult Usecode_script::handle_event: init_casting → show_casting_frames.
	if (m_castingMode == CastingMode::InitCasting)
		DisplayCastingFrames();

	UsecodeScriptState script;
	script.code = std::move(code);
	script.ip = 0;
	script.delayRemaining = initialDelaySec;
	script.noHalt = noHalt;
	script.active = true;

	// While a list is stepping, keep the new one aside. Appending here would reallocate
	// the vector the stepper is walking.
	if (m_updatingUsecodeScript)
	{
		m_pendingUsecodeScripts.erase(
			std::remove_if(m_pendingUsecodeScripts.begin(), m_pendingUsecodeScripts.end(),
				[](const UsecodeScriptState& s) { return !s.active; }),
			m_pendingUsecodeScripts.end());
		m_pendingUsecodeScripts.push_back(std::move(script));
	}
	else
	{
		m_usecodeScripts.erase(
			std::remove_if(m_usecodeScripts.begin(), m_usecodeScripts.end(),
				[](const UsecodeScriptState& s) { return !s.active; }),
			m_usecodeScripts.end());
		m_usecodeScripts.push_back(std::move(script));
	}

	NPCDebugPrint("usecode_script: start on object " + std::to_string(m_ID) +
		" len=" + std::to_string(m_updatingUsecodeScript
			? m_pendingUsecodeScripts.back().code.size()
			: m_usecodeScripts.back().code.size()) +
		" delay=" + std::to_string(initialDelaySec) +
		" pending=" + std::to_string(m_usecodeScripts.size() + m_pendingUsecodeScripts.size()));
}

void U7Object::HaltUsecodeScript(bool force)
{
	if (m_usecodeScripts.empty())
		return;

	for (auto it = m_usecodeScripts.begin(); it != m_usecodeScripts.end(); )
	{
		if (!it->active)
		{
			it = m_usecodeScripts.erase(it);
			continue;
		}
		if (!force && it->noHalt)
		{
			++it;
			continue;
		}
		it = m_usecodeScripts.erase(it);
	}

	RestoreAnimModeAfterScript();
}

void U7Object::UpdateUsecodeScript()
{
	if (m_usecodeScripts.empty() && m_pendingUsecodeScripts.empty())
		return;

	m_updatingUsecodeScript = true;
	const float dt = g_Engine->LastFrameInSeconds();

	for (size_t si = 0; si < m_usecodeScripts.size(); ++si)
	{
		UsecodeScriptState& script = m_usecodeScripts[si];
		if (!script.active)
			continue;

		float& delay = script.delayRemaining;
		if (delay > 0.0f)
		{
			delay -= dt;
			if (delay > 0.0f)
				continue;
			delay = 0.0f;
		}

		auto& code = script.code;
		int& ip = script.ip;
		const int cnt = (int)code.size();

		// Process one instruction (or keep going on cont / finish flags).
		bool doAnother = true;
		float nextDelay = kUsecodeTickSec;

		while (ip < cnt && doAnother)
		{
			doAnother = false;
			const UsecodeScriptElem& cur = code[ip];

			// String with no preceding say — treat as bark (decompiler quirk).
			if (std::holds_alternative<std::string>(cur))
			{
				std::string text = std::get<std::string>(cur);
				while (!text.empty() && text.front() == '@') text.erase(text.begin());
				while (!text.empty() && text.back() == '@') text.pop_back();
				if (g_StateMachine && g_StateMachine->GetCurrentState() == STATE_MAINSTATE)
				{
					auto* main = dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE));
					if (main) main->Bark(this, text);
				}
				++ip;
				break;
			}

			const int raw = ScriptElemInt(cur);
			const int opcode = DecodeScriptOpcode(raw);
			++ip;

			switch (opcode)
			{
			case UC_CONT:
				doAnother = true;
				break;
			case UC_NOP1:
			case UC_NOP2:
				doAnother = true;
				break;
			case UC_DONT_HALT:
				script.noHalt = true;
				doAnother = true;
				break;
			case UC_FINISH:
				doAnother = true;
				break;
			case UC_RESET:
				ip = 0;
				doAnother = true;
				break;
			case UC_DELAY_TICKS:
			{
				int ticks = 1;
				if (ip < cnt && ScriptElemIsInt(code[ip]))
					ticks = ScriptElemInt(code[ip++]);
				if (ticks < 1) ticks = 1;
				nextDelay = kUsecodeTickSec * (float)ticks;
				break;
			}
			case UC_DELAY_MINUTES:
			{
				int mins = 1;
				if (ip < cnt && ScriptElemIsInt(code[ip]))
					mins = ScriptElemInt(code[ip++]);
				nextDelay = (float)mins * 60.0f * kUsecodeTickSec; // coarse stand-in
				break;
			}
			case UC_DELAY_HOURS:
			{
				int hours = 1;
				if (ip < cnt && ScriptElemIsInt(code[ip]))
					hours = ScriptElemInt(code[ip++]);
				nextDelay = (float)hours * 3600.0f * kUsecodeTickSec;
				break;
			}
			case UC_FRAME:
			{
				int fr = 0;
				if (ip < cnt && ScriptElemIsInt(code[ip]))
					fr = ScriptElemInt(code[ip++]);
				SetAbsoluteFrame(fr);
				break;
			}
			case UC_NEXT_FRAME:
			case UC_NEXT_FRAME_MAX:
			{
				const int nframes = GetShapeAnimFrameCount();
				int fr = m_Frame + 1;
				if (opcode == UC_NEXT_FRAME)
					fr = (nframes > 0) ? (fr % nframes) : 0;
				else if (fr >= nframes)
					fr = nframes - 1;
				if (fr < 0) fr = 0;
				SetFrame(fr);
				break;
			}
			case UC_PREV_FRAME:
			case UC_PREV_FRAME_MIN:
			{
				const int nframes = GetShapeAnimFrameCount();
				int fr = m_Frame - 1;
				if (opcode == UC_PREV_FRAME_MIN)
				{
					if (fr < 0) fr = 0;
				}
				else
				{
					if (fr < 0)
						fr = (nframes > 0) ? (nframes - 1) : 0;
				}
				SetFrame(fr);
				break;
			}
			case UC_FACE_DIR:
			{
				int dir = 0;
				if (ip < cnt && ScriptElemIsInt(code[ip]))
					dir = ScriptElemInt(code[ip++]) & 7;
				// 0=N … map to engine yaw roughly (45° steps). NPCs use m_Angle.
				m_Angle = (float)dir * 45.0f;
				// Also set facing direction vector (0=north → -Z in our XZ).
				static const Vector3 kDirs[8] = {
					{ 0, 0, -1 }, { 1, 0, -1 }, { 1, 0, 0 }, { 1, 0, 1 },
					{ 0, 0, 1 }, { -1, 0, 1 }, { -1, 0, 0 }, { -1, 0, -1 }
				};
				m_Direction = Vector3Normalize(kDirs[dir]);
				break;
			}
			case UC_SFX:
			{
				int sfx = 0;
				if (ip < cnt && ScriptElemIsInt(code[ip]))
					sfx = ScriptElemInt(code[ip++]);
				if (g_SoundSystem && sfx >= 0)
					g_SoundSystem->PlaySoundAtObject(BuildU7SfxPath(sfx), m_ID);
				break;
			}
			case UC_ATTACK:
				FireUsecodeAttack();
				break;
			case UC_SAY:
			{
				std::string text;
				if (ip < cnt && std::holds_alternative<std::string>(code[ip]))
					text = std::get<std::string>(code[ip++]);
				else if (ip < cnt && ScriptElemIsInt(code[ip]))
					++ip; // skip non-string param
				while (!text.empty() && text.front() == '@') text.erase(text.begin());
				while (!text.empty() && text.back() == '@') text.pop_back();
				if (!text.empty() && g_StateMachine && g_StateMachine->GetCurrentState() == STATE_MAINSTATE)
				{
					auto* main = dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE));
					if (main) main->Bark(this, text);
				}
				break;
			}
			case UC_USECODE:
			{
				int fun = 0;
				if (ip < cnt && ScriptElemIsInt(code[ip]))
					fun = ScriptElemInt(code[ip++]);
				// The number after opcode 0x55 is the requested function, not the next
				// opcode. It is consumed above so the rest of the array stays aligned.
				// Spell functions 0x640–0x68F keep their spellbook lookup.
				// Every other ID names its own script (1786 -> utility_event_0506).
				// Interact(2) would run the current object's script instead.
				if (fun >= 0x640 && fun < 0x640 + 80 && g_ScriptingSystem)
				{
					const int scriptId = 320 + (fun - 0x640);
					const std::string spellScript = GumpSpellbook::FindSpellScriptName(scriptId);
					if (!spellScript.empty())
					{
						g_ScriptingSystem->CallScript(
							spellScript,
							{ static_cast<lua_Integer>(2),
							  static_cast<lua_Integer>(m_ID) });
						break;
					}
				}
				if (g_ScriptingSystem)
				{
					const std::string scriptName = FindUsecodeScriptByFunction(fun);
					if (!scriptName.empty())
					{
						g_ScriptingSystem->CallScript(
							scriptName,
							{ static_cast<lua_Integer>(2),
							  static_cast<lua_Integer>(m_ID) });
						break;
					}
				}
				Interact(2);
				break;
			}
			case UC_REMOVE:
				// Soft-remove: hide / mark dead if available
				m_ShouldDraw = false;
				m_Visible = false;
				ip = cnt;
				break;
			case UC_REPEAT:
			case UC_REPEAT2:
			{
				// After opcode: offset, count [, reset]. ip already past opcode.
				if (ip + 1 >= cnt)
					break;
				const int opcodeIndex = ip - 1;
				const int offset = ScriptElemInt(code[ip]);
				const int countIdx = ip + 1;
				int repeats = ScriptElemInt(code[countIdx]);
				if (repeats <= 0)
				{
					if (opcode == UC_REPEAT2 && ip + 2 < cnt)
					{
						code[countIdx] = ScriptElemInt(code[ip + 2]); // restore
						ip += 3;
					}
					else
						ip += 2;
					doAnother = true;
				}
				else
				{
					if (repeats != 255)
						code[countIdx] = repeats - 1;
					// Exult: landing = opcodeIndex + offset
					ip = opcodeIndex + offset;
					if (ip < 0) ip = 0;
					doAnother = true;
				}
				break;
			}
			case UC_WAIT_NEAR:
			case UC_WAIT_FAR:
			{
				int dist = 5;
				if (ip < cnt && ScriptElemIsInt(code[ip]))
					dist = ScriptElemInt(code[ip++]);
				U7Object* av = g_Player ? g_Player->GetAvatarObject() : nullptr;
				if (av)
				{
					const float dx = fabsf(m_Pos.x - av->m_Pos.x);
					const float dz = fabsf(m_Pos.z - av->m_Pos.z);
					const float d = (dx > dz) ? dx : dz;
					const bool near = d <= (float)dist;
					if ((opcode == UC_WAIT_NEAR && near) || (opcode == UC_WAIT_FAR && !near))
					{
						ip -= 2; // stay on this opcode
						if (ip < 0) ip = 0;
					}
				}
				break;
			}
			default:
				if (opcode >= UC_NPC_FRAME_BASE && opcode <= UC_NPC_FRAME_BASE + 15)
				{
					// NPC frame-by-type: drive billboard action table + m_Frame nibble.
					ApplyNpcPoseFromUsecode(opcode - UC_NPC_FRAME_BASE);
				}
				else if (opcode >= 0x30 && opcode <= 0x37)
				{
					// Step N/NE/... — skip movement for now (path_run covers most walks)
				}
				else
				{
					// Unknown / param-looking value that was treated as opcode — ignore
				}
				break;
			}
		}

		if (ip >= cnt)
		{
			// This script finished — deactivate only this entry (others keep running).
			script.active = false;
			continue;
		}

		script.delayRemaining = nextDelay;
	}

	m_updatingUsecodeScript = false;
	if (!m_pendingUsecodeScripts.empty())
	{
		m_usecodeScripts.insert(m_usecodeScripts.end(),
			std::make_move_iterator(m_pendingUsecodeScripts.begin()),
			std::make_move_iterator(m_pendingUsecodeScripts.end()));
		m_pendingUsecodeScripts.clear();
	}

	// Compact finished scripts. Lists halted by a nested start were only marked inactive above.
	m_usecodeScripts.erase(
		std::remove_if(m_usecodeScripts.begin(), m_usecodeScripts.end(),
			[](const UsecodeScriptState& s) { return !s.active; }),
		m_usecodeScripts.end());

	// Craft tools / Triples: leave Frozen (or restore Auto for TFA ambient).
	RestoreAnimModeAfterScript();

	// Combat spell with no deferred projectile (Heal / In Nox): pause orders once
	// the cast script finishes. Projectile spells clear this flag in FireUsecodeAttack.
	if (!IsInUsecodeScript() && m_pauseOrdersOnNextSpellProjectile)
	{
		m_pauseOrdersOnNextSpellProjectile = false;
		if (g_mainState && g_isCombatMode)
			g_mainState->NotifyCombatantCannotContinue(this, "needs a new order!");
	}
}

void U7Object::ClearPendingUsecode()
{
	m_hasPendingUsecode = false;
	m_pendingUsecodeObjectId = -1;
	m_pendingUsecodeEvent = 7;
	m_pendingUsecodeHasProx = false;
	m_pendingUsecodeProxX = 0.0f;
	m_pendingUsecodeProxZ = 0.0f;
}

void U7Object::SetPendingUsecode(int objectId, int eventId)
{
	m_hasPendingUsecode = true;
	m_pendingUsecodeObjectId = objectId;
	m_pendingUsecodeEvent = eventId;
	m_pendingUsecodeHasProx = false;
}

void U7Object::SetPendingUsecode(int objectId, int eventId, float proxX, float proxZ)
{
	m_hasPendingUsecode = true;
	m_pendingUsecodeObjectId = objectId;
	m_pendingUsecodeEvent = eventId;
	m_pendingUsecodeProxX = proxX;
	m_pendingUsecodeProxZ = proxZ;
	m_pendingUsecodeHasProx = true;
}

void U7Object::FirePendingUsecodeIfAny()
{
	if (!m_hasPendingUsecode)
		return;

	const int objectId = m_pendingUsecodeObjectId;
	const int eventId = m_pendingUsecodeEvent;
	ClearPendingUsecode();

	// Stop any remaining path so we don't keep walking after the use.
	m_pathWaypoints.clear();
	m_currentWaypointIndex = 0;
	m_isMoving = false;
	m_moveStuckFrames = 0;
	SetDest(m_Pos);

	U7Object* target = GetObjectFromID(objectId);
	if (target)
	{
		NPCDebugPrint("path_run_usecode: arrived, Interact(" + std::to_string(eventId) +
			") on object " + std::to_string(objectId));
		target->Interact(eventId);
	}
	else
	{
		NPCDebugPrint("path_run_usecode: arrived but target object " +
			std::to_string(objectId) + " is gone");
	}
}

bool U7Object::TryCompletePendingUsecodeByProximity(float maxDistXZ)
{
	if (!m_hasPendingUsecode)
		return false;

	U7Object* target = GetObjectFromID(m_pendingUsecodeObjectId);
	if (!target)
	{
		ClearPendingUsecode();
		return false;
	}

	auto chebyshevXZ = [](float ax, float az, float bx, float bz) {
		const float dx = fabsf(ax - bx);
		const float dz = fabsf(az - bz);
		return (dx > dz) ? dx : dz;
	};

	// Prefer stand-point proximity when set (carried tools: bucket in backpack is at 0,0,0).
	float chebyshev = 1.0e9f;
	const char* nearWhat = "target";
	if (m_pendingUsecodeHasProx)
	{
		chebyshev = chebyshevXZ(m_Pos.x, m_Pos.z, m_pendingUsecodeProxX, m_pendingUsecodeProxZ);
		nearWhat = "stand";
	}
	// World items (not contained): also allow proximity to the item itself.
	if (!target->m_isContained)
	{
		const float toItem = chebyshevXZ(m_Pos.x, m_Pos.z, target->m_Pos.x, target->m_Pos.z);
		if (toItem < chebyshev)
		{
			chebyshev = toItem;
			nearWhat = "target";
		}
	}

	if (chebyshev > maxDistXZ)
		return false;

	NPCDebugPrint(std::string("path_run_usecode: within chebyshev ") + std::to_string(chebyshev) +
		" of " + nearWhat + " (usecode obj " + std::to_string(m_pendingUsecodeObjectId) +
		") — cancelling path and firing");
	FirePendingUsecodeIfAny();
	return true;
}

void U7Object::ApplyPathWaypoints(std::vector<Vector3> waypoints)
{
	m_pathWaypoints = std::move(waypoints);
	m_currentWaypointIndex = 0;
	m_pathfindingPending = false;

	if (m_pathWaypoints.empty())
	{
		m_isMoving = false;
		return;
	}

	if (g_pathfindingSystem && g_pathfindingSystem->GetFrozenSearchObjectId() == m_ID)
		g_pathfindingSystem->ClearFrozenSearchGraph();

	if (m_pathWaypoints.size() > 1)
		m_currentWaypointIndex = 1;
	else
		m_currentWaypointIndex = 0;

	while (m_currentWaypointIndex < static_cast<int>(m_pathWaypoints.size()) &&
		   (int)m_pathWaypoints[m_currentWaypointIndex].x == (int)m_Pos.x &&
		   (int)m_pathWaypoints[m_currentWaypointIndex].z == (int)m_Pos.z)
	{
		m_currentWaypointIndex++;
	}

	if (m_currentWaypointIndex >= static_cast<int>(m_pathWaypoints.size()))
	{
		m_pathWaypoints.clear();
		m_currentWaypointIndex = 0;
		m_isMoving = false;
		m_isSchedulePath = false;
	}
	else
	{
		SetDest(m_pathWaypoints[m_currentWaypointIndex]);
		m_isMoving = true;
	}
}

void U7Object::PathfindToDest(Vector3 dest, bool allowHierarchical, PathCallerTag tag)
{
	if (m_NPCID == 19)
	{
		int stopper = 0;
	}

	// Note: do NOT clear m_hasPendingUsecode here — stuck-repath must keep the
	// path_run_usecode callback. Callers that mean "cancel walk-to-use"
	// (click-to-walk, halt_scheduled) should ClearPendingUsecode() themselves.

	// Clear previous path and mark as pending
	m_pathWaypoints.clear();
	m_currentWaypointIndex = 0;
	m_moveStuckFrames = 0;
	m_pathfindingPending = true;

	if (!g_pathfindingSystem)
	{
		m_pathfindingPending = false;
		return;
	}

	// Leaving a sit/sleep pose: step off furniture toward the new destination
	// immediately so the first path step isn't trapped in the chair AABB.
	if (m_isFrameOverridden || m_furnitureObjectId >= 0)
		ClearOverrideFrame(&dest);
	else if (m_claimedFurnitureId >= 0)
	{
		// Soft-claimed a chair/bed but pathing elsewhere (schedule change, wander) —
		// drop the reservation so another NPC can take it.
		auto it = g_objectList.find(m_claimedFurnitureId);
		bool goingToClaim = false;
		if (it != g_objectList.end() && it->second)
		{
			const Vector3 fp = it->second->GetPos();
			const int dx = std::abs((int)floorf(dest.x) - (int)floorf(fp.x));
			const int dz = std::abs((int)floorf(dest.z) - (int)floorf(fp.z));
			goingToClaim = (std::max(dx, dz) <= 2);
		}
		if (!goingToClaim)
			ReleaseFurnitureClaim();
	}

	// Infer Avatar/party tag when caller left default Other.
	if (tag == PathCallerTag::Other && g_Player &&
		m_UnitType == UnitTypes::UNIT_TYPE_NPC && g_Player->NPCIDInParty(m_NPCID))
	{
		tag = PathCallerTag::AvatarParty;
	}

	auto path = g_pathfindingSystem->FindPath(m_Pos, dest, this, allowHierarchical, tag);
	ApplyPathWaypoints(std::move(path));

	if (m_pathWaypoints.empty())
	{
		// F10: freeze the A* visited graph only for the sticky-selected unit.
		if (g_mainState && g_mainState->m_showPathfindingDebug &&
			g_mainState->m_pathDebugNpcObjectId == m_ID)
		{
			g_pathfindingSystem->FreezeFailedSearchGraph(m_ID);
		}
	}
}

bool U7Object::AddObjectToInventory(int objectid)
{
	if (m_isContainer)
	{
		auto childIt = g_objectList.find(objectid);
		if (childIt == g_objectList.end() || !childIt->second)
			return false;

		U7Object* child = childIt->second.get();

		// Original U7: lit torches (701) will not go into bags/chests/backpacks.
		// NPC inventory still accepts them so they can be held in hand.
		if (child->m_ObjectType == 701 && IsTfaContainerShape(m_objectData))
		{
			AddConsoleString("Cannot put lit torch in a container.", RED);
			return false;
		}

		m_inventory.push_back(objectid);

		// Set the child's containing object ID to point back to this container
		child->m_containingObjectId = m_ID;
		child->m_isContained = true;  // Mark as contained
		// Do NOT SetPos(0,0,0) — that registers the item into chunk (0,0) via
		// UpdateObjectChunk. Pull it out of the world map and park in the void.
		UnassignObjectChunk(child);
		child->m_Pos = Vector3{ -1000.0f, 0.0f, -1000.0f };
		child->m_Visible = false;

		InvalidateWeightCache();
		return true;
	}

	return false;
}

bool U7Object::RemoveObjectFromInventory(int objectid)
{
	if (m_isContainer)
	{
		for (int i = 0; i < m_inventory.size(); i++)
		{
			if (m_inventory[i] == objectid)
			{
				U7Object* child = GetObjectFromID(objectid);
				if (child)
				{
					// Don't change m_isContained here - let the code that places the object set it
					// (e.g., equip sets true, drop to ground sets false, add to container sets true)
					child->m_containingObjectId = -1; // Clear parent reference
				}
				m_inventory.erase(m_inventory.begin() + i);
				// Clear equipment slots that still pointed at this item (loot from corpses).
				if (m_NPCData)
				{
					for (int s = 0; s < static_cast<int>(EquipmentSlot::SLOT_COUNT); ++s)
					{
						const auto slot = static_cast<EquipmentSlot>(s);
						if (m_NPCData->GetEquippedItem(slot) == objectid)
							m_NPCData->m_equipment[slot] = -1;
					}
				}
				InvalidateWeightCache();
				return true;
			}
		}
	}

	return false;
}

void U7Object::Interact(int event)
{
	// Dead NPCs are lootable containers — no conversation or usecode.
	if (IsDeathStatus())
		return;

	if (m_hasConversationTree)
	{
		g_ConversationState->SetNPC(m_NPCID);

		// Find NPC script using new naming: npc_*_XXXX where XXXX = NPC ID in decimal (4 digits)
		// NPC IDs start at 0 and increment, independent of shape ID
		string scriptName = FindNPCScriptByID(m_NPCID);

		if (scriptName.empty())
		{
			NPCDebugPrint("No script found for NPC ID: " + to_string(m_NPCID));
			return;
		}

		NPCDebugPrint("Calling Lua function: " + scriptName + " event: " + to_string(event) + " NPCID: " + to_string(m_NPCID));
		std::string response = g_ScriptingSystem->CallScript(scriptName, { event, m_NPCID });
		NPCDebugPrint(response);
	}
	else
	{
		// Original U7 usecode is per-shape; our shapetable is per-frame. Many key
		// frames (e.g. 641/6 Garritt's key) still say "default" while frame 0 has
		// the real script — fall back to frame 0 when needed.
		std::string scriptName;
		if (m_shapeData && !m_shapeData->m_luaScript.empty() &&
		    m_shapeData->m_luaScript != "default")
		{
			scriptName = m_shapeData->m_luaScript;
		}
		else if (m_ObjectType >= 0 && m_ObjectType < (int)g_shapeTable.size())
		{
			const std::string& frame0 = g_shapeTable[m_ObjectType][0].m_luaScript;
			if (!frame0.empty() && frame0 != "default")
				scriptName = frame0;
		}

		if (!scriptName.empty())
		{
			NPCDebugPrint("Calling Lua function: " + scriptName + " event: " + to_string(event) +
				" ID: " + to_string(m_ID) + " (Shape: " + to_string(m_ObjectType) +
				", Frame: " + to_string(m_Frame) + ")");
			NPCDebugPrint(g_ScriptingSystem->CallScript(scriptName, { event, m_ID }));
		}
	}
}

bool U7Object::IsInInventoryById(int objectid)
{
	for (int i = 0; i < m_inventory.size(); i++)
	{
		if (m_inventory[i] == objectid)
		{
			return true;
		}
	}

	return false;
}

bool U7Object::IsInInventory(int shape, int frame, int quality)
{
	for (int i = 0; i < m_inventory.size(); i++)
	{
		U7Object* obj = GetObjectFromID(m_inventory[i]);
		if (obj != nullptr && obj->m_ObjectType == shape &&
			(frame == -1 || obj->m_Frame == frame) &&
			(quality == -1 || obj->m_Quality == quality || quality == -1))
		{
			return true;
		}
	}

	return false;
}

float U7Object::GetWeight()
{
	if (m_totalWeight > 0.0f)
		return m_totalWeight;

	float baseWeight = g_objectDataTable[m_shapeData->m_shape].m_weight;
	float inventoryWeight = 0.0f;

	for (int childId : m_inventory)
	{
		U7Object* child = g_objectList[childId].get();
		if (child != nullptr)
		{
			inventoryWeight += child->GetWeight();
		}
	}

	m_totalWeight = baseWeight + inventoryWeight;
	return m_totalWeight;
}

void U7Object::InvalidateWeightCache()
{
	m_totalWeight = 0.0f;

	if (m_containingObjectId != -1)
	{
		U7Object* parent = g_objectList[m_containingObjectId].get();
		if (parent != nullptr)
		{
			parent->InvalidateWeightCache();
		}
	}
}

float U7Object::GetRemainingCarryCapacity()
{
	// Only NPCs have carry capacity
	if (m_UnitType != UnitTypes::UNIT_TYPE_NPC || m_NPCData == nullptr)
		return 0.0f;

	float maxWeight = GetMaxWeightFromStrength(m_NPCData->str);
	float currentWeight = GetWeight();

	return maxWeight - currentWeight;
}

bool U7Object::IsLocked()
{
	if (!m_shapeData)
		return false;

	// Locked chest shape
	if (m_shapeData->m_shape == 522)
		return true;

	// Door pieces: frame % 4 == 2 is locked (3 = magically locked).
	if (m_objectData && m_objectData->m_isDoor)
	{
		const int state = m_Frame % 4;
		if (state == 2 || state == 3)
			return true;
	}

	return false;
}

void U7Object::NPCInit(NPCData* npcData)
{
	m_NPCData = npcData;
	m_UnitType = UnitTypes::UNIT_TYPE_NPC;
	m_isContainer = true;
	m_isContained = false;
	m_name = npcData->name;
	if (std::string(m_NPCData->name) == "Avatar")
	{
		m_speed = 7.5f;
	}
	else
	{
		m_speed = 5.0f;
	}
	m_NPCID = npcData->id;
	m_attackRange = MELEE_RANGE_TILES;
	m_anchorPos = m_Pos;
	m_hp = npcData->health;
	m_BaseMaxHP = npcData->health;
	// Max mana equals Magic; start fully topped up.
	m_mana = float(npcData->magic);

	// Saved/scripted dead bit: restore corpse pose and silence AI.
	if (IsDeathStatus())
	{
		m_hp = 0.0f;
		m_followingSchedule = false;
		SetOverrideFrame(GetDeathFrameForFacing());
	}

	// Assign contiguous batch index if not already set (preserve any value restored from save)
	if (m_npcBatchIndex < 0)
	{
		// post-increment gives each NPC a unique contiguous index
		m_npcBatchIndex = s_nextNpcBatchIndex.fetch_add(1);
	}
	else
	{
		// Ensure allocator is ahead of any loaded index (LoadFromJson may have set m_npcBatchIndex)
		int desired = m_npcBatchIndex + 1;
		int cur = s_nextNpcBatchIndex.load();
		while (cur < desired && !s_nextNpcBatchIndex.compare_exchange_weak(cur, desired))
		{
			// loop until swapped or cur updated
		}
	}

	// AddObject/SetPos ran before UnitType was NPC, so rebuild the centered pick box now.
	SetPos(m_Pos);
}

// ============================================================================
// Serialization
// ============================================================================

namespace
{
	bool IsCombatParticipant(int objectId)
	{
		if (!g_isCombatMode || !g_mainState)
		{
			return false;
		}
		const std::vector<int>& parts = g_mainState->m_combatParticipants;
		return std::find(parts.begin(), parts.end(), objectId) != parts.end();
	}

	json Vec3ToJson(const Vector3& v)
	{
		return json::array({ v.x, v.y, v.z });
	}

	bool JsonToVec3(const json& j, Vector3& out)
	{
		if (!j.is_array() || j.size() != 3)
		{
			return false;
		}
		out.x = j[0].get<float>();
		out.y = j[1].get<float>();
		out.z = j[2].get<float>();
		return true;
	}
}

void U7Object::WriteCombatFields(json& j) const
{
	const bool creature = (m_UnitType == UnitTypes::UNIT_TYPE_NPC || m_UnitType == UnitTypes::UNIT_TYPE_MONSTER);
	if (!creature)
	{
		return;
	}

	const bool combatNoteworthy =
		m_target != 0
		|| m_combatOrderMode != CombatOrderMode::Automatic
		|| m_combatSpellId >= 0
		|| m_combatMoveOrder
		|| m_combatPathTargetId != 0
		|| m_npcAnimPlaying
		|| m_pauseOrdersOnNextSpellProjectile;
	const bool participant = IsCombatParticipant(static_cast<int>(m_ID));
	if (!participant && !combatNoteworthy)
	{
		return;
	}

	json combat;
	combat["order"] = static_cast<int>(m_combatOrderMode);
	combat["target"] = m_target;
	combat["spellId"] = m_combatSpellId;
	combat["spellTarget"] = m_combatSpellTargetId;
	if (m_combatSpellHasTile)
	{
		combat["spellTile"] = true;
		combat["spellTileX"] = m_combatSpellTileX;
		combat["spellTileZ"] = m_combatSpellTileZ;
		combat["spellTileY"] = m_combatSpellTileY;
	}
	combat["moveOrder"] = m_combatMoveOrder;
	combat["pathTarget"] = m_combatPathTargetId;
	combat["pathGoal"] = Vec3ToJson(m_combatPathGoal);
	combat["cooldown"] = m_cooldownTimer;
	combat["attackRange"] = m_attackRange;
	combat["pauseOnSpellHit"] = m_pauseOrdersOnNextSpellProjectile;
	combat["frameX"] = m_currentFrameX;
	combat["frameY"] = m_currentFrameY;
	combat["direction"] = Vec3ToJson(m_Direction);

	if (m_npcAnimPlaying || m_npcAnimAction != NpcAnimAction::Stand)
	{
		json anim;
		anim["action"] = static_cast<int>(m_npcAnimAction);
		anim["phase"] = m_npcAnimPhase;
		anim["timer"] = m_npcAnimTimer;
		anim["looping"] = m_npcAnimLooping;
		anim["playing"] = m_npcAnimPlaying;
		anim["hitPhase"] = m_npcAnimHitPhase;
		anim["hitFired"] = m_npcAnimHitFired;
		combat["anim"] = anim;
	}

	// Paths are saved only for a live fight. Peace-time schedule walks stay at the saved tile.
	if (g_isCombatMode && (participant || combatNoteworthy)
		&& (m_isMoving || m_pathfindingPending || !m_pathWaypoints.empty()))
	{
		json motion;
		motion["moving"] = m_isMoving;
		motion["pending"] = m_pathfindingPending;
		motion["schedulePath"] = m_isSchedulePath;
		motion["waypointIndex"] = m_currentWaypointIndex;
		motion["dest"] = Vec3ToJson(m_Dest);
		json points = json::array();
		for (const Vector3& point : m_pathWaypoints)
		{
			points.push_back(Vec3ToJson(point));
		}
		motion["waypoints"] = points;
		combat["motion"] = motion;
	}

	// "combat" is the skill rating. The encounter snapshot uses its own key.
	j["combatState"] = combat;
}

void U7Object::ReadCombatFields(const json& j)
{
	m_preserveLoadedMotion = false;
	if (!j.contains("combatState") || !j["combatState"].is_object())
	{
		return;
	}

	const json& combat = j["combatState"];
	if (combat.contains("order"))
	{
		int order = combat["order"].get<int>();
		if (order < 0 || order > static_cast<int>(CombatOrderMode::Move))
		{
			order = static_cast<int>(CombatOrderMode::Automatic);
		}
		m_combatOrderMode = static_cast<CombatOrderMode>(order);
	}
	m_target = combat.value("target", m_target);
	m_combatSpellId = combat.value("spellId", m_combatSpellId);
	m_combatSpellTargetId = combat.value("spellTarget", m_combatSpellTargetId);
	m_combatSpellHasTile = combat.value("spellTile", false);
	if (m_combatSpellHasTile)
	{
		m_combatSpellTileX = combat.value("spellTileX", 0);
		m_combatSpellTileZ = combat.value("spellTileZ", 0);
		m_combatSpellTileY = combat.value("spellTileY", 0.0f);
	}
	m_combatMoveOrder = combat.value("moveOrder", m_combatMoveOrder);
	m_combatPathTargetId = combat.value("pathTarget", m_combatPathTargetId);
	m_cooldownTimer = combat.value("cooldown", m_cooldownTimer);
	m_attackRange = combat.value("attackRange", m_attackRange);
	m_pauseOrdersOnNextSpellProjectile = combat.value("pauseOnSpellHit", m_pauseOrdersOnNextSpellProjectile);
	m_currentFrameX = combat.value("frameX", m_currentFrameX);
	m_currentFrameY = combat.value("frameY", m_currentFrameY);

	Vector3 direction = m_Direction;
	if (combat.contains("direction") && JsonToVec3(combat["direction"], direction))
	{
		m_Direction = direction;
	}
	Vector3 goal = m_combatPathGoal;
	if (combat.contains("pathGoal") && JsonToVec3(combat["pathGoal"], goal))
	{
		m_combatPathGoal = goal;
	}

	if (combat.contains("anim") && combat["anim"].is_object())
	{
		const json& anim = combat["anim"];
		int action = anim.value("action", static_cast<int>(NpcAnimAction::Stand));
		if (action < 0 || action >= static_cast<int>(NpcAnimAction::COUNT))
		{
			action = static_cast<int>(NpcAnimAction::Stand);
		}
		m_npcAnimAction = static_cast<NpcAnimAction>(action);
		m_npcAnimPhase = anim.value("phase", 0);
		m_npcAnimTimer = anim.value("timer", 0.0f);
		m_npcAnimLooping = anim.value("looping", true);
		m_npcAnimPlaying = anim.value("playing", false);
		m_npcAnimHitPhase = anim.value("hitPhase", -1);
		m_npcAnimHitFired = anim.value("hitFired", false);
	}

	if (combat.contains("motion") && combat["motion"].is_object())
	{
		const json& motion = combat["motion"];
		m_isMoving = motion.value("moving", false);
		m_pathfindingPending = motion.value("pending", false);
		m_isSchedulePath = motion.value("schedulePath", false);
		m_currentWaypointIndex = motion.value("waypointIndex", 0);
		Vector3 dest = m_Pos;
		if (motion.contains("dest") && JsonToVec3(motion["dest"], dest))
		{
			SetDest(dest);
		}
		m_pathWaypoints.clear();
		if (motion.contains("waypoints") && motion["waypoints"].is_array())
		{
			for (const json& point : motion["waypoints"])
			{
				Vector3 waypoint = { 0, 0, 0 };
				if (JsonToVec3(point, waypoint))
				{
					m_pathWaypoints.push_back(waypoint);
				}
			}
		}
		if (m_currentWaypointIndex < 0)
		{
			m_currentWaypointIndex = 0;
		}
		if (!m_pathWaypoints.empty() && m_currentWaypointIndex >= static_cast<int>(m_pathWaypoints.size()))
		{
			m_currentWaypointIndex = static_cast<int>(m_pathWaypoints.size()) - 1;
		}
		m_preserveLoadedMotion = m_isMoving || m_pathfindingPending || !m_pathWaypoints.empty();
	}
}

json U7Object::SaveToJson() const
{
	// note: this will never be called for STATIC objects
	json j;

	// Core identity
	j["id"] = m_ID;

	// Only save unitType if not UNIT_TYPE_OBJECT (the default)
	if (m_UnitType != UnitTypes::UNIT_TYPE_OBJECT)
		j["unitType"] = static_cast<int>(m_UnitType);

	j["shape"] = m_ObjectType;

	// Only save non-default values
	if (m_Frame != 0)
		j["frame"] = m_Frame;
	if (m_Quality != 0)
		j["quality"] = m_Quality;
	if (m_virtueMarked)
	{
		j["virtueMarked"] = true;
		j["virtueX"] = m_virtueX;
		j["virtueY"] = m_virtueY;
		j["virtueZ"] = m_virtueZ;
	}

	// Transform (only save position if not contained)
	if (!m_isContained)
	{
		j["position"] = { m_Pos.x, m_Pos.y, m_Pos.z };
	}

	// State (only save if non-zero)
	if (m_flags != 0)
		j["flags"] = m_flags;
	if (m_sleepTurnsRemaining > 0)
		j["sleepTurnsRemaining"] = m_sleepTurnsRemaining;
	if (m_sleepEndsAt > GetTime())
		j["sleepRemaining"] = m_sleepEndsAt - GetTime();
	if (m_danceTurnsRemaining > 0)
		j["danceTurnsRemaining"] = m_danceTurnsRemaining;
	else if (m_danceEndsAt > GetTime())
		j["danceRemaining"] = m_danceEndsAt - GetTime();
	if (m_attackMode == 7)
	{
		j["attackMode"] = m_attackMode;
		j["fearOppressorId"] = m_fearOppressorId;
	}
	if (m_invisibilityEndsAt > 0.0f)
	{
		const float remaining = m_invisibilityEndsAt - GetTime();
		if (remaining > 0.0f)
			j["invisibilityRemaining"] = remaining;
	}
	if (m_charmEndsAt > GetTime())
	{
		j["charmRemaining"] = m_charmEndsAt - GetTime();
		if (m_charmHomeTeam >= 0)
			j["charmHomeTeam"] = m_charmHomeTeam;
	}
	if (m_mightEndsAt > GetTime())
	{
		j["mightRemaining"] = m_mightEndsAt - GetTime();
		j["mightStrBonus"] = m_mightStrBonus;
		j["mightDexBonus"] = m_mightDexBonus;
		j["mightIntBonus"] = m_mightIntBonus;
		j["mightCombatBonus"] = m_mightCombatBonus;
		j["mightBaseStr"] = m_mightBaseStr;
		j["mightBaseDex"] = m_mightBaseDex;
		j["mightBaseInt"] = m_mightBaseInt;
		j["mightBaseCombat"] = m_mightBaseCombat;
	}
	if (m_fireFieldTurnsRemaining > 0)
		j["fireFieldTurnsRemaining"] = m_fireFieldTurnsRemaining;
	else if (m_fireFieldEndsAt > 0.0f)
	{
		const float remaining = m_fireFieldEndsAt - GetTime();
		j["fireFieldRemaining"] = remaining > 0.0f ? remaining : 0.0f;
	}
	if (m_flameStrikeField)
	{
		j["flameStrikeField"] = true;
		if (m_flameStrikeCasterId > 0)
			j["flameStrikeCasterId"] = m_flameStrikeCasterId;
	}

	// Container hierarchy
	if (m_isContained)
	{
		j["containingObjectId"] = m_containingObjectId;
		j["containerPos"] = { m_InventoryPos.x, m_InventoryPos.y };
	}

	// Only save inventory if it has items
	if (!m_inventory.empty())
		j["inventoryIds"] = m_inventory;

	// Save container state
	if (m_isContainer)
	{
		j["isContainer"] = true;
		if (!m_shouldBeSorted)
			j["shouldBeSorted"] = m_shouldBeSorted;
	}

	// Creature combat stats (shared by NPCs and Monsters)
	if (m_UnitType == UnitTypes::UNIT_TYPE_NPC || m_UnitType == UnitTypes::UNIT_TYPE_MONSTER)
	{
		j["hp"] = m_hp;
		j["mana"] = m_mana;
		j["combat"] = m_combat;
		j["magic"] = m_magic;
		j["team"] = m_Team;
	}

	// Full NPC-specific fields
	if (m_UnitType == UnitTypes::UNIT_TYPE_NPC && m_NPCData != nullptr)
	{
		j["npcID"] = m_NPCID;
		j["currentFrameX"] = m_currentFrameX;
		j["currentFrameY"] = m_currentFrameY;

		// Save conversation tree flag if true
		if (m_hasConversationTree)
			j["hasConversationTree"] = m_hasConversationTree;

		// Save movement state if true (default is false)
		if (m_isMoving)
			j["isMoving"] = m_isMoving;

		// Save schedule state
		if (m_followingSchedule)
			j["followingSchedule"] = m_followingSchedule;
		if (m_lastSchedule != -1)
			j["lastSchedule"] = m_lastSchedule;

		// Don't save destination - we want NPCs to stay at their saved position
		// The schedule system will set new destinations as needed after load

		// Persist batch index so distribution is stable across loads
		if (m_npcBatchIndex >= 0)
			j["npcBatchIndex"] = m_npcBatchIndex;

		// Equipment slots
		json equipment;
		equipment["HEAD"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_HEAD);
		equipment["NECK"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_NECK);
		equipment["TORSO"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_TORSO);
		equipment["LEGS"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_LEGS);
		equipment["HANDS"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_HANDS);
		equipment["FEET"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_FEET);
		equipment["LEFT_HAND"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_LEFT_HAND);
		equipment["RIGHT_HAND"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_RIGHT_HAND);
		equipment["AMMO"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_AMMO);
		equipment["LEFT_RING"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_LEFT_RING);
		equipment["RIGHT_RING"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_RIGHT_RING);
		equipment["BELT"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_BELT);
		equipment["BACKPACK"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_BACKPACK);
		j["equipment"] = equipment;
	}

	// Full egg config + runtime state. Eggs are wiped and recreated on load (not re-parsed
	// from FIXED.DAT), so monster shape / criteria / etc. must live in the save.
	if (m_UnitType == UnitTypes::UNIT_TYPE_EGG)
	{
		const EggData& e = m_eggData;
		j["m_eggType"] = static_cast<int>(e.m_type);
		j["m_eggCriteria"] = static_cast<int>(e.m_criteria);
		j["m_eggDistance"] = e.m_distance;
		j["m_eggProbability"] = e.m_probability;
		j["m_hasTriggered"] = e.m_hasTriggered;
		j["m_onceOnly"] = e.m_onceOnly;
		j["m_nocturnal"] = e.m_nocturnal;
		j["m_autoReset"] = e.m_autoReset;
		j["m_shouldReset"] = e.m_shouldReset;
		j["m_rolledThisVisit"] = e.m_rolledThisVisit;
		j["m_specificValue"] = e.m_specificValue;
		j["m_durationMinutes"] = e.m_durationMinutes;
		if (!e.m_audioFile.empty())
			j["m_audioFile"] = e.m_audioFile;
		if (e.m_usecodeFunc != 0)
			j["m_usecodeFunc"] = e.m_usecodeFunc;
		j["m_monsterShape"] = e.m_monsterShape;
		j["m_monsterFrame"] = e.m_monsterFrame;
		j["m_spawnCount"] = e.m_spawnCount;
		j["m_spawnChance"] = e.m_spawnChance;
		j["m_monsterAlignment"] = e.m_monsterAlignment;
		j["m_monsterWorkType"] = e.m_monsterWorkType;
		j["m_monsterTypeIndex"] = e.m_monsterTypeIndex;
		if (e.m_teleportDest.x != 0.0f || e.m_teleportDest.y != 0.0f || e.m_teleportDest.z != 0.0f)
			j["m_teleportDest"] = { e.m_teleportDest.x, e.m_teleportDest.y, e.m_teleportDest.z };
		if (e.m_destMap != 0)
			j["m_destMap"] = e.m_destMap;
	}

	WriteCombatFields(j);

	if (m_isProjectile)
	{
		j["isProjectile"] = true;
		j["speed"] = m_speed;
		j["dest"] = { m_Dest.x, m_Dest.y, m_Dest.z };
	}

	return j;
}

U7Object* U7Object::LoadFromJson(const json& j)
{
	// Create new object
	U7Object* obj = new U7Object();

	// Set minimal properties needed for Init()
	// IMPORTANT: unitType defaults to 1 (UNIT_TYPE_OBJECT) if not present in JSON
	// We only save unitType if it's NOT 1 to reduce file size (see SaveToJson line 778)
	obj->m_UnitType = static_cast<UnitTypes>(j.value("unitType", 1));
	obj->m_ObjectType = j.value("shape", 0);
	obj->m_Frame = j.value("frame", 0);

	UnitTypes savedType = obj->m_UnitType;

	// Initialize object FIRST (loads texture, shape data, etc.)
	// This must happen before setting ANY other properties, since Init() resets many flags to defaults
	// IMPORTANT: Init's 2nd parameter is the SHAPE number (confusingly named "unitType" in Init's signature)
	obj->Init("", obj->m_ObjectType, obj->m_Frame);
	obj->m_UnitType = savedType;

	// Check if this is an egg object (same logic as LoadingState.cpp line 826)
	if (obj->m_objectData->m_name == "Egg" || obj->m_objectData->m_name == "path")
	{
		obj->m_isContainer = false;
	}

	// Now restore all other properties (which will overwrite Init's defaults)
	obj->m_ID = j.value("id", 0);
	obj->m_Quality = j.value("quality", 0);
	obj->m_virtueMarked = j.value("virtueMarked", false);
	if (obj->m_virtueMarked)
	{
		obj->m_virtueX = j.value("virtueX", 0.0f);
		obj->m_virtueY = j.value("virtueY", 0.0f);
		obj->m_virtueZ = j.value("virtueZ", 0.0f);
	}

	// Restore transform
	if (j.contains("position") && j["position"].is_array() && j["position"].size() == 3)
	{
		Vector3 loadedPos = {
			j["position"][0].get<float>(),
			j["position"][1].get<float>(),
			j["position"][2].get<float>()
		};
		// Use SetPos to properly calculate centerPoint, boundingBox, etc.
		obj->SetPos(loadedPos);
	}

	// Restore state
	obj->m_flags = j.value("flags", 0u);
	obj->m_sleepTurnsRemaining = j.value("sleepTurnsRemaining", 0);
	if (j.contains("sleepRemaining") && j["sleepRemaining"].is_number())
	{
		const float remaining = j["sleepRemaining"].get<float>();
		if (remaining > 0.0f)
			obj->m_sleepEndsAt = GetTime() + remaining;
	}
	obj->m_danceTurnsRemaining = j.value("danceTurnsRemaining", 0);
	if (obj->m_danceTurnsRemaining < 0)
		obj->m_danceTurnsRemaining = 0;
	if (obj->m_danceTurnsRemaining <= 0
		&& j.contains("danceRemaining") && j["danceRemaining"].is_number())
	{
		const float remaining = j["danceRemaining"].get<float>();
		if (remaining > 0.0f)
			obj->m_danceEndsAt = GetTime() + remaining;
	}
	if (obj->m_danceTurnsRemaining > 0 || obj->m_danceEndsAt > 0.0f)
		obj->m_flags |= kObjFlagInAction;
	else
		obj->m_flags &= ~kObjFlagInAction;
	obj->m_attackMode = j.value("attackMode", 0);
	if (obj->m_attackMode != 7)
		obj->m_attackMode = 0;
	obj->m_fearOppressorId = j.value("fearOppressorId", 0);
	if (j.contains("invisibilityRemaining") && j["invisibilityRemaining"].is_number())
	{
		const float remaining = j["invisibilityRemaining"].get<float>();
		if (remaining > 0.0f)
			obj->m_invisibilityEndsAt = GetTime() + remaining;
	}
	if (j.contains("charmRemaining") && j["charmRemaining"].is_number())
	{
		const float remaining = j["charmRemaining"].get<float>();
		if (remaining > 0.0f)
		{
			obj->m_charmEndsAt = GetTime() + remaining;
			if (j.contains("charmHomeTeam") && j["charmHomeTeam"].is_number())
				obj->m_charmHomeTeam = j["charmHomeTeam"].get<int>();
		}
	}
	if ((obj->m_flags & kObjFlagCharmed) != 0 && obj->m_charmEndsAt <= 0.0f)
		obj->m_flags &= ~kObjFlagCharmed;
	if (j.contains("fireFieldTurnsRemaining") && j["fireFieldTurnsRemaining"].is_number())
	{
		obj->m_fireFieldTurnsRemaining = j["fireFieldTurnsRemaining"].get<int>();
		if (obj->m_fireFieldTurnsRemaining < 0)
			obj->m_fireFieldTurnsRemaining = 0;
	}
	if (obj->m_fireFieldTurnsRemaining <= 0
		&& j.contains("fireFieldRemaining") && j["fireFieldRemaining"].is_number())
	{
		const float remaining = j["fireFieldRemaining"].get<float>();
		obj->m_fireFieldEndsAt = GetTime() + (remaining > 0.0f ? remaining : 0.0f);
	}
	if (obj->m_fireFieldTurnsRemaining > 0 || obj->m_fireFieldEndsAt > 0.0f)
	{
		obj->m_UnitType = UnitTypes::UNIT_TYPE_OBJECT;
		NoteTimedFireField(static_cast<int>(obj->m_ID));
	}
	obj->m_flameStrikeField = j.value("flameStrikeField", false);
	obj->m_flameStrikeCasterId = j.value("flameStrikeCasterId", 0);

	// Container hierarchy (restored in second pass by GameSerializer)
	int containingId = j.value("containingObjectId", -1);
	obj->m_isContained = (containingId != -1);
	obj->m_containingObjectId = containingId;

	if (j.contains("containerPos") && j["containerPos"].is_array() && j["containerPos"].size() == 2)
	{
		obj->m_InventoryPos.x = j["containerPos"][0];
		obj->m_InventoryPos.y = j["containerPos"][1];
	}

	// Inventory IDs will be restored in second pass by GameSerializer

	// Restore container state
	if (j.contains("isContainer"))
		obj->m_isContainer = j["isContainer"];
	if (j.contains("shouldBeSorted"))
		obj->m_shouldBeSorted = j["shouldBeSorted"];

	// Full NPC-specific fields: NPCInit first (sets defaults from NPCData), then apply
	// saved runtime stats so HP/combat/magic survive load.
	if (obj->m_UnitType == UnitTypes::UNIT_TYPE_NPC)
	{
		obj->m_NPCID = j.value("npcID", 0);
		obj->m_currentFrameX = j.value("currentFrameX", 0);
		obj->m_currentFrameY = j.value("currentFrameY", 0);

		obj->m_hasConversationTree = j.value("hasConversationTree", false);
		obj->m_isMoving = j.value("isMoving", false);
		obj->m_followingSchedule = j.value("followingSchedule", false);
		obj->m_lastSchedule = j.value("lastSchedule", -1);
		obj->m_npcBatchIndex = j.value("npcBatchIndex", -1);

		auto npcIt = g_NPCData.find(obj->m_NPCID);
		if (npcIt != g_NPCData.end() && npcIt->second)
		{
			obj->m_NPCData = npcIt->second.get();
			obj->m_isContainer = true;
			obj->NPCInit(obj->m_NPCData);
		}
		else
		{
			Log("LoadFromJson: WARNING - no NPCData for npcID " + std::to_string(obj->m_NPCID));
		}

		// Apply saved combat stats AFTER NPCInit (which sets template HP/mana).
		// "combat" is the skill rating. An object here is not a number.
		obj->m_hp = j.value("hp", obj->m_hp);
		obj->m_mana = j.value("mana", obj->m_mana);
		if (j.contains("combat") && j["combat"].is_number())
		{
			obj->m_combat = j["combat"].get<float>();
		}
		obj->m_magic = j.value("magic", obj->m_magic);
		obj->m_Team = j.value("team", obj->m_Team);
		// Equipment restored in second pass by GameSerializer
	}
	else if (obj->m_UnitType == UnitTypes::UNIT_TYPE_MONSTER)
	{
		// Rebuild walk textures / combat defaults, then apply saved stats.
		obj->MonsterInit();
		obj->m_hp = j.value("hp", 25.0f);
		obj->m_mana = j.value("mana", 0.0f);
		obj->m_combat = 10.0f;
		if (j.contains("combat") && j["combat"].is_number())
		{
			obj->m_combat = j["combat"].get<float>();
		}
		obj->m_magic = j.value("magic", 0.0f);
		obj->m_Team = j.value("team", 0);
	}

	// After NPCInit / MonsterInit, which reload the unbuffed stats.
	// base+bonus is absolute, so a second pass after the player json is safe.
	if (j.contains("mightRemaining") && j["mightRemaining"].is_number())
	{
		const float remaining = j["mightRemaining"].get<float>();
		if (remaining > 0.0f)
		{
			obj->m_mightEndsAt = GetTime() + remaining;
			obj->m_mightStrBonus = j.value("mightStrBonus", 0);
			obj->m_mightDexBonus = j.value("mightDexBonus", 0);
			obj->m_mightIntBonus = j.value("mightIntBonus", 0);
			obj->m_mightCombatBonus = j.value("mightCombatBonus", 0);
			obj->m_mightBaseStr = j.value("mightBaseStr", 0);
			obj->m_mightBaseDex = j.value("mightBaseDex", 0);
			obj->m_mightBaseInt = j.value("mightBaseInt", 0);
			obj->m_mightBaseCombat = j.value("mightBaseCombat", 0);
			obj->RestoreMightStats();
		}
	}
	if ((obj->m_flags & kObjFlagMight) != 0 && obj->m_mightEndsAt <= 0.0f)
		obj->m_flags &= ~kObjFlagMight;

	if (obj->m_UnitType == UnitTypes::UNIT_TYPE_EGG ||
	    (obj->m_shapeData && obj->m_shapeData->m_shape == 275))
	{
		obj->m_UnitType = UnitTypes::UNIT_TYPE_EGG;
		obj->m_Visible = true;  // TEMP: make eggs visible for debugging
	}

	// Restore full egg config + runtime state (see SaveToJson).
	if (obj->m_UnitType == UnitTypes::UNIT_TYPE_EGG)
	{
		EggData& e = obj->m_eggData;

		// Prefer explicit saved config. Fall back to frame-as-type for older saves
		// that only stored hasTriggered/shouldReset (those loads still lose monster shape).
		if (j.contains("m_eggType"))
			e.m_type = static_cast<EggType>(j["m_eggType"].get<int>());
		else
			e.m_type = static_cast<EggType>(obj->m_Frame);

		if (j.contains("m_eggCriteria"))
			e.m_criteria = static_cast<EggCriteria>(j["m_eggCriteria"].get<int>());
		if (j.contains("m_eggDistance"))
			e.m_distance = static_cast<uint8_t>(j["m_eggDistance"].get<int>());
		if (j.contains("m_eggProbability"))
			e.m_probability = static_cast<uint8_t>(j["m_eggProbability"].get<int>());

		if (j.contains("m_hasTriggered"))
			e.m_hasTriggered = j["m_hasTriggered"].get<bool>();
		if (j.contains("m_shouldReset"))
			e.m_shouldReset = j["m_shouldReset"].get<bool>();
		if (j.contains("m_rolledThisVisit"))
			e.m_rolledThisVisit = j["m_rolledThisVisit"].get<bool>();
		if (j.contains("m_onceOnly"))
			e.m_onceOnly = j["m_onceOnly"].get<bool>();
		if (j.contains("m_nocturnal"))
			e.m_nocturnal = j["m_nocturnal"].get<bool>();
		if (j.contains("m_autoReset"))
			e.m_autoReset = j["m_autoReset"].get<bool>();

		if (j.contains("m_specificValue"))
			e.m_specificValue = static_cast<uint8_t>(j["m_specificValue"].get<int>());
		if (j.contains("m_durationMinutes"))
			e.m_durationMinutes = static_cast<uint8_t>(j["m_durationMinutes"].get<int>());
		if (j.contains("m_audioFile") && j["m_audioFile"].is_string())
			e.m_audioFile = j["m_audioFile"].get<std::string>();
		if (j.contains("m_usecodeFunc"))
			e.m_usecodeFunc = j["m_usecodeFunc"].get<int>();

		if (j.contains("m_monsterShape"))
			e.m_monsterShape = j["m_monsterShape"].get<int>();
		if (j.contains("m_monsterFrame"))
			e.m_monsterFrame = j["m_monsterFrame"].get<int>();
		if (j.contains("m_spawnCount"))
			e.m_spawnCount = j["m_spawnCount"].get<int>();
		if (j.contains("m_spawnChance"))
			e.m_spawnChance = j["m_spawnChance"].get<float>();
		if (j.contains("m_monsterAlignment"))
			e.m_monsterAlignment = static_cast<uint8_t>(j["m_monsterAlignment"].get<int>());
		if (j.contains("m_monsterWorkType"))
			e.m_monsterWorkType = static_cast<uint8_t>(j["m_monsterWorkType"].get<int>());
		if (j.contains("m_monsterTypeIndex"))
			e.m_monsterTypeIndex = j["m_monsterTypeIndex"].get<int>();

		if (j.contains("m_teleportDest") && j["m_teleportDest"].is_array() && j["m_teleportDest"].size() == 3)
		{
			e.m_teleportDest = {
				j["m_teleportDest"][0].get<float>(),
				j["m_teleportDest"][1].get<float>(),
				j["m_teleportDest"][2].get<float>()
			};
		}
		if (j.contains("m_destMap"))
			e.m_destMap = j["m_destMap"].get<int>();
	}

	obj->ReadCombatFields(j);
	if ((obj->m_UnitType == UnitTypes::UNIT_TYPE_NPC || obj->m_UnitType == UnitTypes::UNIT_TYPE_MONSTER)
		&& !obj->m_preserveLoadedMotion)
	{
		// Peace-time loads stay on the saved tile. Schedule walks are not resumed.
		obj->m_pathWaypoints.clear();
		obj->m_currentWaypointIndex = 0;
		obj->m_pathfindingPending = false;
		obj->m_isMoving = false;
		obj->SetDest(obj->m_Pos);
	}

	if (j.value("isProjectile", false))
	{
		obj->m_isProjectile = true;
		obj->m_Visible = true;
		obj->m_ShouldDraw = true;
		if (j.contains("speed"))
		{
			obj->m_speed = j["speed"].get<float>();
		}
		if (j.contains("dest") && j["dest"].is_array() && j["dest"].size() == 3)
		{
			obj->SetDest(Vector3{ j["dest"][0].get<float>(), j["dest"][1].get<float>(), j["dest"][2].get<float>() });
		}
	}

	return obj;
}

void U7Object::Morph(ShapeDrawType drawType)
{
	Morph(nullptr, drawType);
}


void U7Object::Morph(const char* imagePath, ShapeDrawType drawType)
{
	//AddConsoleString("Roof: Morph Init", WHITE);
	m_isCustomMesh = true;
	m_customMesh = g_ResourceManager->GetModel(m_customMeshName);
	//AddConsoleString("Roof: Morph GetModel " + m_customMeshName, WHITE);
	Model* customMeshModel = &m_customMesh->GetModel();
	customMeshModel->materials[0].shader = g_alphaDiscard;

	// if by some chance m_Texture is already loaded, we can skip this part.
	if (m_Texture == nullptr)
	{
		//Image image = LoadImage("Images/GUI/gumps.png");
		if (imagePath != nullptr)
		{
			if (FileExists(imagePath))
			{
				Image morphImage = LoadImage(imagePath);
				//Image morphImage = GenImageColor(8, 8, Color{ 128, 128, 128, 128 });
				m_Texture = new Texture(LoadTextureFromImage(morphImage));
				//AddConsoleString("Roof: Morph IMG", WHITE);
				UnloadImage(morphImage);
			}
			else {
				Log("Roof: failed to load " + std::string(imagePath));
				//m_Texture = new Texture(GenTextureCubemap(8, 8, 1, Color{ 128, 128, 128, 128 }));
				//CreateDefaultTexture();
			}
		}
	}
	//AddConsoleString("Roof: Morph A", WHITE);
	//CreateDefaultTexture();
	if (m_Texture != nullptr)
	{
		g_ResourceManager->UpdateModelTexture(m_customMeshName, *m_Texture);
	}

	//AddConsoleString("Roof: Morph B", WHITE);
	//SetMaterialTexture(&customMeshModel->materials[0], MATERIAL_MAP_DIFFUSE, *m_Texture);
	m_drawType = drawType;
}

void U7Object::Activate(float timeNow, int maxFrames, int probability)
{
	// fixme, needs cleaned up and possibly a good chunk needs rewritten
	int currentFrame = 0;
	float dilationParam = 1.0f / g_secsPerMinute;
	double timePerFrame = (1.0 / 8.0) * dilationParam;
	if (m_isActivated == false)
	{
		// Not activated, check if cooldown has passed}
		/*
		if (m_activationTimer == 0.0)
		{
			m_activationTimer = timeNow - (m_actCooldown + float(timePerFrame) * float(maxFrames));
		}
		*/
	}
	float m_activeElapsed = timeNow - m_activationTimer;
	float fullTime = float(timePerFrame) * float(maxFrames);
	if (m_isActivated == false)
	{
		if (m_activeElapsed >= ((m_actCooldown * dilationParam) + fullTime))
		{
			// tweak probability
			float m_probElapsed = m_activeElapsed - ((m_actCooldown * dilationParam) + fullTime);
			m_probElapsed /= 1.0; // 10 seconds to reach 100% probability
			probability += (int)m_probElapsed;
			// elapsed is greater than cooldown + fullTime
			if (probability < 100)
			{
				int roll = g_NonVitalRNG ? (int)g_NonVitalRNG->RandomRange(0, 99) : (rand() % 100);
				if (roll >= probability) {
					//Log("Activate: probability check failed. roll: " + std::to_string(roll) + " probability: " + std::to_string(probability), "anims.log");
					//return; // Didn't trigger this time
				}
				else
				{
					//Log("Activate[" + std::to_string(timeNow) + "]: probability check passed. roll: " + std::to_string(roll) + " probability: " + std::to_string(probability), "anims.log");
					//if (m_isActivated == false) {
						m_isActivated = true;
						m_activationTimer = float(timeNow);
						m_activeElapsed = float(timeNow) - m_activationTimer;
					//}
				}
			}
			else {
				//Log("Activate[" + std::to_string(timeNow) + "]: probability check passed (100%). m_activeElapsed: " + std::to_string(m_activeElapsed) + " m_actCooldown: " + std::to_string(m_actCooldown) + " fullTime: " + std::to_string(fullTime), "anims.log");
				//if (m_isActivated == false)
				//{
					m_isActivated = true;
					m_activationTimer = float(timeNow);
					m_activeElapsed = float(timeNow) - m_activationTimer;
				//}
			}
		}
		else
		{
			//Log("Activate: cooldown not met. m_activeElapsed: " + std::to_string(m_activeElapsed) + " m_actCooldown: " + std::to_string(m_actCooldown) + " fullTime: " + std::to_string(fullTime), "anims.log");
		}
	}

	if (m_isActivated == true)
	{
		currentFrame = static_cast<unsigned int>(m_activeElapsed / timePerFrame);
		//Log("Activate[" + std::to_string(timeNow) + "|" + std::to_string(m_activationTimer) + "]: m_activeElapsed: " + std::to_string(m_activeElapsed) + " timePerFrame: " + std::to_string(timePerFrame) + " currentFrame: " + std::to_string(currentFrame) + " maxFrames: " + std::to_string(maxFrames), "anims.log");
		if (currentFrame >= maxFrames)
		{
			//Log("Activate[" + std::to_string(timeNow) + "]: animation finished. Resetting m_isActivated and currentFrame.", "anims.log");
			m_isActivated = false;
			m_activationTimer = 0.0f;
			currentFrame = 0;
		}
		//Log("Activate[" + std::to_string(timeNow) + "|" + std::to_string(m_activationTimer) + "]: " + std::to_string(m_isActivated) + " currentFrame: " + std::to_string(currentFrame) + " m_activeElapsed: " + std::to_string(m_activeElapsed) + " timePerFrame: " + std::to_string(timePerFrame) + " maxFrames: " + std::to_string(maxFrames), "anims.log");
		SetFrame(currentFrame);
	}
	else
	{
		SetFrame(0);
	}
}

void U7Object::Hide()
{
	m_drawType = ShapeDrawType::OBJECT_DRAW_DONT_DRAW;
	/*
	//m_Visible = false;
	if (m_Visible != false) {
		m_Visible = false;
	}*/
}

void U7Object::Show()
{
	//m_Visible = true;
	/*
	if (m_Visible != true) {
		m_Visible = true;
	}
	*/
}