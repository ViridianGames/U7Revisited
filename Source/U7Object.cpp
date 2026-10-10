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
#include "PathfindingSystem.h"
#include "PerfTelemetry.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>
#include <algorithm>
#include "raymath.h"
#include "rlgl.h"
#include <atomic>


using namespace std;

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
	// TFA ambient props loop; everything else starts Frozen (craft tools, casino
	// wheels, doors) until a usecode script drives frames.
	m_animMode = ObjectAnimMode::Frozen;
	if (m_objectData && m_objectData->m_isAnimated)
	{
		m_animMode = ObjectAnimMode::Auto;
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

	// WGTVOL capacity: chests/crates/bags/etc. Double-click opens a gump when
	// unlocked (MainState). Threshold skips tiny volumes (coins, food, garbage).
	if (m_objectData && m_objectData->m_volume >= 50.0f)
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
	if (!m_Visible || m_isContained || !m_ShouldDraw)
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

void U7Object::InteractiveUpdate()
{
	// Most interactive objects have very little per-frame logic here.
	// Container behavior, scripts, etc. are usually event-driven via Interact().
	UpdateUsecodeScript();
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
				}
			}
			else if (m_eggData.m_criteria == EggCriteria::AvatarNear ||
					 m_eggData.m_criteria == EggCriteria::PartyNear)
			{
				if (dist > (float)m_eggData.m_distance && m_eggData.m_autoReset)
				{
					m_eggData.m_hasTriggered = false;
				}
			}
			else if (m_eggData.m_criteria == EggCriteria::AvatarFootpad ||
					 m_eggData.m_criteria == EggCriteria::PartyFootpad)
			{
				if (dist > 1.5f && m_eggData.m_autoReset)
				{
					m_eggData.m_hasTriggered = false;
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

	std::string FormatCombatAttackConsole(const U7Object* attacker, const U7Object* target,
		int weaponShape, int hits)
	{
		const std::string attackerName = (attacker && !attacker->m_name.empty()) ? attacker->m_name : "Someone";
		const std::string targetName = (target && !target->m_name.empty()) ? target->m_name : "enemy";
		return attackerName + " attacks " + targetName + " with " + CombatWeaponDisplayName(weaponShape)
			+ " for " + std::to_string(hits) + " damage";
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
		if (!unit || !unit->m_NPCData)
			return nullptr;

		if (weaponShape == kShapeSling)
			return nullptr; // sling needs no ammo item

		if (!WeaponUsesBolts(weaponShape) && !WeaponUsesArrows(weaponShape))
			return nullptr;

		outNeedsAmmo = true;

		auto usable = [&](U7Object* obj) -> bool {
			return obj && obj->m_shapeData && IsCompatibleAmmoShape(weaponShape, obj->m_shapeData->m_shape);
		};

		const int ammoId = unit->m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_AMMO);
		if (ammoId >= 0)
		{
			U7Object* ammo = GetObjectFromID(ammoId);
			if (usable(ammo))
				return ammo;
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

	if (!IsHostileCombatant(this) || !IsPartyCombatant(attacker))
		return;

	// Switch to whoever just hit us and drop any movement toward a previous target.
	m_target = attacker->m_ID;
	m_combatMoveOrder = false;
	m_pathWaypoints.clear();
	m_currentWaypointIndex = 0;
	m_pathfindingPending = false;
	m_isSchedulePath = false;

	if (g_isCombatMode && g_mainState)
		g_mainState->EnsureCombatParticipant(static_cast<int>(m_ID));

	if (g_isCombatMode)
		EngageCombatTarget();
}

bool U7Object::EngageCombatTarget()
{
	if (m_target == 0)
		return false;

	auto targetIt = g_objectList.find(m_target);
	if (targetIt == g_objectList.end() || !targetIt->second ||
	    targetIt->second->GetIsDead() || targetIt->second->IsDeathStatus())
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

	U7Object* weapon = GetEquippedWeapon(this);
	const int weaponShape = (weapon && weapon->m_shapeData) ? weapon->m_shapeData->m_shape : -1;
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
			m_cooldownTimer = m_attackCooldown;
		}
		else if (m_cooldownTimer > 0.0f && !m_npcAnimPlaying)
		{
			m_cooldownTimer -= g_Engine->LastFrameInSeconds();
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
					const int hits = FigureCombatHitPoints(this, target, weaponShape, ammoShape);
					if (hits > 0)
						ApplyCombatDamage(target, static_cast<float>(hits), this);
					AddConsoleString(FormatCombatAttackConsole(this, target, weaponShape, hits), RED);
				}
			}
			else
			{
				const int hits = FigureCombatHitPoints(this, target, weaponShape, -1);
				if (hits > 0)
					ApplyCombatDamage(target, static_cast<float>(hits), this);
				AddConsoleString(FormatCombatAttackConsole(this, target, weaponShape, hits), RED);
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

		if (path.empty() && isParty)
		{
			// Last mile: Avatar/party may crow-fly when A* has nothing left to do
			// (already on/near the goal tile but still outside engage range).
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

	if (g_mainState && g_mainState->IsCombatOrdersPaused())
		return;

	if (!g_isCombatMode || !g_Player)
		return;

	auto isValidPartyTarget = [&](U7Object* candidate) -> bool {
		if (!candidate || candidate->GetIsDead() || candidate->IsDeathStatus())
			return false;
		if (candidate->m_UnitType != UnitTypes::UNIT_TYPE_NPC)
			return false;
		if (!g_Player->NPCIDInParty(candidate->m_NPCID))
			return false;
		const float distSqr = Vector2DistanceSqr(
			{ m_Pos.x, m_Pos.z },
			{ candidate->m_Pos.x, candidate->m_Pos.z });
		return distSqr <= kHostileAggroRangeSqr;
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

	// Drop a target that died or left aggro range, then pick the nearest party member.
	U7Object* current = (m_target > 0) ? GetObjectFromID(m_target) : nullptr;
	if (!isValidPartyTarget(current))
		m_target = 0;

	if (m_target == 0)
		m_target = selectNearestPartyTarget();

	if (m_target == 0)
	{
		UpdateMovement();
		return;
	}

	if (!EngageCombatTarget())
	{
		// Target may have died during engage validation — retarget once this frame.
		m_target = selectNearestPartyTarget();
		if (m_target != 0)
			EngageCombatTarget();
	}
	UpdateMovement();
}

void U7Object::MonsterUpdate()
{
	UpdateNpcAnim(g_Engine ? g_Engine->LastFrameInSeconds() : 0.0f);

	// Hostiles are Team 1 (combat eggs). Non-combat fauna stay Team 0.
	if (m_Team == 1 && g_Player)
	{
		U7Object* avatar = g_Player->GetAvatarObject();
		if (avatar)
		{
			const float distSqr = Vector2DistanceSqr({ m_Pos.x, m_Pos.z }, { avatar->m_Pos.x, avatar->m_Pos.z });

			if (distSqr < kHostileAggroRangeSqr)
			{
				if (!g_isCombatMode)
				{
					// Starts combat using the *nearest* hostile for the approach message.
					TryBeginCombatFromHostileAggro(this);
				}
				else if (g_mainState)
				{
					// Enroll even while paused — otherwise nearer Headlesses never join
					// if a farther Dragon triggered combat first.
					g_mainState->EnsureCombatParticipant(static_cast<int>(m_ID));
				}
			}

			// Only skip chase/attack AI while combat is paused for orders.
			if (g_mainState && g_mainState->IsCombatOrdersPaused())
				return;

			if (g_isCombatMode)
			{
				HostileCombatUpdate();
				return;
			}
		}
	}

	UpdateMovement();
}

///////////////////////////////////////////////////////////////////////////
//  TYPE-SPECIFIC DRAW FUNCTIONS
//  Called from U7Object::Draw() via switch on m_UnitType
///////////////////////////////////////////////////////////////////////////

void U7Object::StaticDraw()
{
	// Statics are drawn through the normal shapeData path below in InteractiveDraw
	// for now. We can specialize later (e.g. instanced terrain).
	InteractiveDraw();
}

void U7Object::InteractiveDraw()
{
	int cellx = (TILEWIDTH / 2) + m_Pos.x - int(g_camera.target.x);
	int celly = (TILEHEIGHT / 2) + m_Pos.z - int(g_camera.target.z);

	if (cellx < 0 || cellx >= TILEWIDTH || celly < 0 || celly >= TILEHEIGHT)
	{
		return; // Not on the screen.
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

		if (m_ObjectType == 284 && animFrames > 1)
		{
			// Sundial: 24 frames, one per game hour (not a looping FX cycle).
			currentFrame = static_cast<int>(g_hour) % animFrames;
		}
		else if (m_animMode == ObjectAnimMode::Auto
			&& m_objectData->m_isAnimated && animFrames > 1)
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

	Color renderColor = g_Terrain->m_cellLighting[cellx][celly];

	// Apply green tint if F11 script debug is enabled and object has a non-default script
	// Also check for conversation trees (NPCs with dialogue scripts)
	if (g_showScriptedObjects &&
	    ((m_shapeData->m_luaScript != "" && m_shapeData->m_luaScript != "default") || m_hasConversationTree))
	{
		// Blend with green to highlight scripted objects
		renderColor.r = (renderColor.r + 0) / 2;
		renderColor.g = (renderColor.g + 255) / 2;
		renderColor.b = (renderColor.b + 0) / 2;
	}
	// Apply blue tint if F11 debug is enabled and object is walkable (isNotWalkable = false)
	else if (g_showScriptedObjects && m_objectData && !m_objectData->m_isNotWalkable)
	{
		// Blend with blue to highlight walkable objects
		renderColor.r = (renderColor.r + 0) / 2;
		renderColor.g = (renderColor.g + 0) / 2;
		renderColor.b = (renderColor.b + 255) / 2;
	}

	if (m_isCustomMesh) {
		CustomMeshDraw(renderColor);
	} else {
		// Skeletal custom meshes: play while Auto/Scripted, rest pose while Frozen.
		const bool playMeshAnim = (m_animMode != ObjectAnimMode::Frozen);
		m_shapeData->Draw(m_Pos, m_Angle, renderColor, Vector3{ 1, 1, 1 },
			playMeshAnim, 0);
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
	// Same 8-way walk billboards as NPCs when walk frames exist for this shape.
	if (m_walkTextures.size() >= 8)
	{
		DrawWalkBillboard(m_walkTextures, m_walkTexturesUpright);
		return;
	}

	// Shapes without SW/NE walk frames fall back to ordinary shape drawing.
	InteractiveDraw();
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

void U7Object::MonsterInit()
{
	m_speed = 7.5f;
	m_attackRange = MELEE_RANGE_TILES;
	m_attackCooldown = 3.0f;
	m_cooldownTimer = 0.0;
	m_name = g_objectDataTable[m_shapeData->m_shape].m_name;

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
	// paths often pass integer tile coords, which put the sprite in the UL corner
	// of the pick box — snap to tile center so visuals and targeting match.
	m_Pos.x = floorf(m_Pos.x) + 0.5f;
	m_Pos.z = floorf(m_Pos.z) + 0.5f;

	// Same as NPCInit: refresh pick box now that UnitType is MONSTER.
	SetPos(m_Pos);
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
		// utility_event_0NNN.lua or utility_unknown_0NNN.lua (decompiler split).
		int scriptnumber = m_eggData.m_usecodeFunc;
		if (scriptnumber >= 1280)
			scriptnumber -= 1280;

		char numBuf[16];
		snprintf(numBuf, sizeof(numBuf), "%04d", scriptnumber);
		// Decompiler split egg scripts across several prefixes.
		const std::string candidates[] = {
			std::string("utility_event_") + numBuf,
			std::string("utility_unknown_") + numBuf,
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
			AddConsoleString("  WeatherType: " + std::to_string((int)egg.m_specificValue));
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

void U7Object::DrawWalkBillboard(const std::vector<std::vector<Texture*>>& walkTextures, bool uprightSheet)
{
	// Verify all 8 directional animation vectors are properly sized (N frames OK).
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

	// Draw at m_Pos (feet/world position). NPCs/monsters are stored at tile centers so
	// logical position matches what you see — no +0.5 draw hack.
	if (abs(m_Pos.x - g_camera.target.x) > 64 || abs(m_Pos.z - g_camera.target.z) > 64)
	{
		return; // Not on the screen.
	}

	// Billboard tilt per direction: SW/W/NE/E use -45; NW/N/SE/S (flipped art) use +45.
	static const float kBillboardAngle[8] = {
		-45.0f, -45.0f, // SW, W
		45.0f, 45.0f,   // NW, N
		-45.0f, -45.0f, // NE, E
		45.0f, 45.0f    // SE, S
	};

	Texture* finalTexture = walkTextures[0][0];
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

	// Pose override (sleeping, sitting, etc.) when standing still — raw shape frame.
	if (!m_isMoving && m_isFrameOverridden)
	{
		if (g_shapeTable[m_ObjectType][m_overrideFrame].m_texture != nullptr)
		{
			finalTexture = &g_shapeTable[m_ObjectType][m_overrideFrame].m_texture->m_Texture;
			billboardAngle = m_overrideFrame % 2 ? 45.0f : 0.0f;
		}
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
	else
	{
		dims = { float(finalTexture->width) / 8.0f, float(finalTexture->height) / 8.0f, 1 };
		finalPos.y += m_shapeData->m_Dims.y * .62f;
	}

	Vector3 shadowPos = Vector3{ m_Pos.x - .5f, 0.02f, m_Pos.z + 1 };
	SetMaterialTexture(&g_ResourceManager->GetModel("Models/3dmodels/flat.obj")->GetModel().materials[0], MATERIAL_MAP_DIFFUSE, *g_ResourceManager->GetTexture("Images/dropshadow.png"));
	rlDisableDepthMask();
	DrawModel(g_ResourceManager->GetModel("Models/3dmodels/flat.obj")->GetModel(), shadowPos, 1.5f, BLACK);
	rlEnableDepthMask();

	BeginShaderMode(g_alphaDiscard);

	Vector3 offset = Vector3Subtract(m_Pos, g_camera.target);
	offset = Vector3Add(offset, Vector3{ 50, 0, 50 });

	if (offset.x < 0 || offset.z < 0 || offset.x > 100 || offset.z > 100)
	{
		return; // Off screen
	}

	Color lighting = g_Terrain->m_cellLighting[int(offset.x)][int(offset.z)];

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
	if (!ObjectWantsScreenSpaceOutline(this))
		return;
	// Match InteractiveDraw → ShapeData::Draw (shape scale, not object m_Scaling).
	m_shapeData->DrawMeshId(m_Pos, m_Angle, MakeMeshOutlineIdColor(m_ID));
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

void U7Object::NPCUpdate()
{
	// Corpses: no schedules, combat AI, conversation scripts, or movement.
	if (IsDeathStatus())
	{
		if (!m_isFrameOverridden)
			SetOverrideFrame(GetDeathFrameForFacing());
		UpdateNpcAnim(g_Engine ? g_Engine->LastFrameInSeconds() : 0.0f);
		return;
	}

	// Cast / craft scripts must tick even while combat is paused or on Hold —
	// those paths return early below and would otherwise freeze the cast anim.
	UpdateUsecodeScript();
	UpdateNpcAnim(g_Engine ? g_Engine->LastFrameInSeconds() : 0.0f);

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

	if (isPartyMember && g_isCombatMode)
	{
		RefreshPartyAttackRangeFromWeapon(this);

		if (g_mainState && g_mainState->IsCombatOrdersPaused())
			return;

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
	// Exceptions: Avatar (WASD / mouse steer) and party followers (continuous
	// formation steering via SetDest).
	const bool isAvatar = (g_Player && g_Player->GetAvatarObject() == this);
	const bool isPartyFollower = (!isAvatar && g_Player && m_NPCID >= 0 &&
	                              g_Player->NPCIDInParty(m_NPCID));
	if (!isAvatar && !isPartyFollower &&
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
		if (partyUnit || hostileUnit)
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

			// Give up after longer stuck (avoids infinite shuffle).
			if (m_moveStuckFrames >= 60)
			{
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

	// NPCs/monsters are stored at tile centers (draw matches m_Pos). Their pick box
	// must still use the tile's upper-left as min — otherwise the clickable volume
	// sits SE of the visible sprite and feels "off."
	const bool characterAtTileCenter =
		(m_UnitType == UnitTypes::UNIT_TYPE_NPC || m_UnitType == UnitTypes::UNIT_TYPE_MONSTER);

	if (characterAtTileCenter)
	{
		dims = Vector3{ objectData->m_width, objectData->m_height, objectData->m_depth };
		if (dims.x < 0.5f) dims.x = 1.0f;
		if (dims.y < 0.5f) dims.y = 1.0f;
		if (dims.z < 0.5f) dims.z = 1.0f;
		// Tile UL is one unit NW of the center tile's SE-style indexing used elsewhere.
		boundingBoxAnchorPoint = Vector3{ floorf(m_Pos.x), m_Pos.y, floorf(m_Pos.z) };
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

	if (characterAtTileCenter)
	{
		// Keep sort/lighting center on the visible character (tile center).
		m_centerPoint = Vector3{ m_Pos.x, m_Pos.y + dims.y * 0.5f, m_Pos.z };
	}
	else
	{
		m_centerPoint = Vector3Subtract(pos, {dims.x / 2, dims.y / 2, dims.z / 2});
	}
	//m_centerPoint = Vector3Add(m_centerPoint, m_shapeData->m_TweakPos);
	m_terrainCenterPoint = m_centerPoint;
	m_terrainCenterPoint.y = m_Pos.y;

	UpdateObjectChunk(this, fromPos);

	// Notify pathfinding grid if this is a non-walkable STATIC object (not NPCs!)
	// NPCs don't block pathfinding grid, so no need to update when they move.
	// Spell missiles skip the grid entirely (they also skip ValidateMove scans).
	if (m_objectData && m_objectData->m_isNotWalkable &&
	    m_UnitType != UnitTypes::UNIT_TYPE_NPC && !m_isProjectile)
	{
		// Update both old and new positions (object moved)
		NotifyPathfindingGridUpdate((int)fromPos.x, (int)fromPos.z);
		NotifyPathfindingGridUpdate((int)pos.x, (int)pos.z);
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
		m_npcAnimHitPhase = -1;
		return;
	}

	// Strike / release is the last phase of attack/shoot clips.
	if (action == NpcAnimAction::Attack1H || action == NpcAnimAction::Attack2H ||
	    action == NpcAnimAction::Shoot)
	{
		const int count = GetNpcActionPhaseCount(*actions, action, 0);
		m_npcAnimHitPhase = (count > 0) ? (count - 1) : -1;
	}
	else
	{
		m_npcAnimHitPhase = -1;
	}
}

void U7Object::StartNpcAttackAnim()
{
	NpcAnimAction action = NpcAnimAction::Attack1H;
	U7Object* weapon = nullptr;
	if (m_NPCData)
	{
		const int weaponId = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_RIGHT_HAND);
		if (weaponId >= 0)
			weapon = GetObjectFromID(weaponId);
	}

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
	const int facingBase = m_Frame & ~0x0f;
	SetFrame(facingBase | poseNibble);

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

	const NpcActionTextures* actions = GetNpcActionTextures();
	if (!actions)
		return;

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
	if (m_UnitType != UnitTypes::UNIT_TYPE_NPC || !m_NPCData)
		return false;
	// Prefer runtime Obj_flags; also honor npc.dat bit 15 for loaded corpses.
	if ((m_flags & kObjFlagDead) != 0)
		return true;
	return (m_NPCData->status & kNpcDatStatusDead) != 0;
}

void U7Object::ApplyDeath()
{
	if (GetIsDead())
		return;

	// Already a corpse — keep the pose, do not re-run side effects.
	if (IsDeathStatus())
	{
		m_hp = 0.0f;
		return;
	}

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
	m_followingSchedule = false;
	SetDest(m_Pos);
	ReleaseFurnitureClaim();
	m_furnitureObjectId = -1;

	if (m_UnitType == UnitTypes::UNIT_TYPE_MONSTER)
	{
		AddConsoleString(m_name.empty() ? "Creature is dead!" : (m_name + " is dead!"), RED);
		if (g_SoundSystem)
			g_SoundSystem->StopLoopingSoundEffect(static_cast<int>(m_ID));
		if (g_mainState && g_mainState->m_barkObject == this)
			g_mainState->ClearBarks();
		UnassignObjectChunk(this);
		SetIsDead(true);
		m_Visible = false;
		m_ShouldDraw = false;
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
	if (g_Player && m_NPCID != 0 && g_Player->NPCIDInParty(m_NPCID))
		g_Player->RemovePartyMember(m_NPCID);

	SetOverrideFrame(GetDeathFrameForFacing());

	const std::string label = m_name.empty() ? "NPC" : m_name;
	AddConsoleString(label + " is dead!", RED);
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
	AddConsoleString(label + " has been resurrected!", GREEN);
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

void U7Object::RestoreAnimModeAfterScript()
{
	if (IsInUsecodeScript())
		return;

	// Exult: when the cast script finishes, drop casting frames.
	if (m_castingMode == CastingMode::ShowCastingFrames
	    || m_castingMode == CastingMode::InitCasting)
		HideCastingFrames();

	if (m_objectData && m_objectData->m_isAnimated)
		m_animMode = ObjectAnimMode::Auto;
	else
		m_animMode = ObjectAnimMode::Frozen;
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

	// Exult Actor::figure_weapon_pos — map NPC pose nibble to casting-frame index.
	const int pose = m_Frame & 0x0f;
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

	// Same world scale as other SHAPES.VGA billboards (8 px = 1 tile).
	// Tiny hand frames (3×10) get a small boost so they read in 3D; never
	// stretch the large "out" glow frames (40×24) up to body size.
	float scale = 1.0f;
	if (tex->width <= 12 && tex->height <= 12)
		scale = 2.5f;
	Vector2 dims = {
		float(tex->width) / 8.0f * scale,
		float(tex->height) / 8.0f * scale
	};
	// Cap so a mis-mapped large frame cannot fill the view.
	const float maxDim = (bodyDims.y > 0.1f) ? (bodyDims.y * 0.45f) : 2.0f;
	if (dims.x > maxDim || dims.y > maxDim)
	{
		const float m = maxDim / std::max(dims.x, dims.y);
		dims.x *= m;
		dims.y *= m;
	}

	Vector3 toCam = Vector3Subtract(g_camera.position, finalPos);
	const float lenSq = toCam.x * toCam.x + toCam.y * toCam.y + toCam.z * toCam.z;
	Vector3 overlayPos = finalPos;
	if (lenSq > 1e-6f)
		overlayPos = Vector3Add(finalPos, Vector3Scale(Vector3Normalize(toCam), 0.08f));

	(void)lighting;
	Color glow = WHITE;
	SetTextureFilter(*tex, TEXTURE_FILTER_POINT);

	rlDisableDepthTest();
	BeginBlendMode(BLEND_ALPHA);
	DrawBillboardPro(g_camera, *tex,
		Rectangle{ 0, 0, float(tex->width), float(tex->height) },
		overlayPos, Vector3{ 0, 1, 0 },
		dims, Vector2{ 0, 0 }, billboardAngle, glow);
	EndBlendMode();
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

float U7Object::Pick()
{
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
	else if (weaponShape == 424)
	{
		// In Nox poison bolt — apply poisoned flag on impact (no HP from the bolt itself).
		damage = 0;
		damageType = 0;
		speed = 16.0f;
	}
	else if (weaponShape == 527)
	{
		// Death Bolt (Corp Por) — directional frames 8–23; damage applied on hit.
		damage = 20;
		damageType = 2; // magic
		speed = 18.0f;
	}

	const bool ok = SpawnFlyingProjectile(weaponShape, static_cast<int>(m_ID), targetId, speed,
		damage, damageType, weaponShape, -1);
	if (!ok)
	{
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
	for (auto it = m_usecodeScripts.begin(); it != m_usecodeScripts.end(); )
	{
		if (!it->active)
		{
			it = m_usecodeScripts.erase(it);
			continue;
		}
		if (!it->noHalt)
			it = m_usecodeScripts.erase(it);
		else
			++it;
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
	m_usecodeScripts.push_back(std::move(script));

	NPCDebugPrint("usecode_script: start on object " + std::to_string(m_ID) +
		" len=" + std::to_string(m_usecodeScripts.back().code.size()) +
		" delay=" + std::to_string(initialDelaySec) +
		" pending=" + std::to_string(m_usecodeScripts.size()));
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
	if (m_usecodeScripts.empty())
		return;

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
				SetFrame(fr);
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
				// Event 2 is Exult's internal_exec for scripted usecode calls.
				(void)fun;
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

	// Compact finished scripts.
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

		m_inventory.push_back(objectid);

		// Set the child's containing object ID to point back to this container
		U7Object* child = childIt->second.get();
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
		m_speed = 10.0f;
	}
	else
	{
		m_speed = 7.5f;
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

	// AddObject/SetPos ran before UnitType was NPC, so rebuild the tile-center pick box now.
	SetPos(m_Pos);
}

// ============================================================================
// Serialization
// ============================================================================

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

	// Transform (only save position if not contained)
	if (!m_isContained)
	{
		j["position"] = { m_Pos.x, m_Pos.y, m_Pos.z };
	}

	// State (only save if non-zero)
	if (m_flags != 0)
		j["flags"] = m_flags;

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
		j["m_specificValue"] = e.m_specificValue;
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

		// Clear any mid-path state; stay at saved position until schedule system runs.
		obj->m_pathWaypoints.clear();
		obj->m_currentWaypointIndex = 0;
		obj->m_pathfindingPending = false;
		obj->SetDest(obj->m_Pos);

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
		obj->m_hp = j.value("hp", obj->m_hp);
		obj->m_mana = j.value("mana", obj->m_mana);
		obj->m_combat = j.value("combat", obj->m_combat);
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
		obj->m_combat = j.value("combat", 10.0f);
		obj->m_magic = j.value("magic", 0.0f);
		obj->m_Team = j.value("team", 0);
	}

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
		if (j.contains("m_onceOnly"))
			e.m_onceOnly = j["m_onceOnly"].get<bool>();
		if (j.contains("m_nocturnal"))
			e.m_nocturnal = j["m_nocturnal"].get<bool>();
		if (j.contains("m_autoReset"))
			e.m_autoReset = j["m_autoReset"].get<bool>();

		if (j.contains("m_specificValue"))
			e.m_specificValue = static_cast<uint8_t>(j["m_specificValue"].get<int>());
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