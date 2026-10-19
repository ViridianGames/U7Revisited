#ifndef _CombatState_H_
#define _CombatState_H_

#include "raylib.h"
#include <string>

class U7Object;

// Combat mode lives inside MainState (g_isCombatMode). This header keeps the
// shared helpers and the kill-switch used by enter paths / aggro warn.
constexpr bool kCombatStateEnabled = true;

// True for Team-1 monsters/NPCs that should fight the party.
bool IsHostileCombatUnit(const U7Object* unit);

// True when the unit stands on an Exult mountain-ceiling dungeon tile.
bool IsUnitInDungeon(const U7Object* unit);

// Dungeon hostiles only sense the party underground, and outdoor hostiles
// only aboveground (XZ overlap alone must not cross the ceiling).
bool AreUnitsOnSameDungeonLayer(const U7Object* a, const U7Object* b);

// Straight-line walkability between units (walls block). Used to acquire aggro.
bool HasCombatLineOfSight(const U7Object* from, const U7Object* to);

// Find nearest hostile within aggro range of the Avatar (or null).
U7Object* FindNearestHostileInAggroRange();

// If any hostile is in aggro range and combat is not active, warn once.
// Does not enter combat — player presses C. Returns false always (no auto-enter).
bool TryBeginCombatFromHostileAggro(U7Object* hintHostile);

// "Headless" → "Headlesses" style label for approach messages.
std::string PluralizeCreatureName(const std::string& name);

// Max HP for bars (m_BaseMaxHP, else current HP floor).
float GetCombatMaxHP(const U7Object* unit);

// Dexterity for TB initiative / AP (NPC dex, Avatar player dex, monster MONSTERS.DAT).
int GetCombatDexterity(const U7Object* unit);
// Intelligence for contact-field checks (NPC iq, Avatar player int, monster MONSTERS.DAT).
int GetCombatIntelligence(const U7Object* unit);
// Turn budget: max(4, DEX/2).
float GetCombatTurnApBudget(const U7Object* unit);
// Path step cost: cardinal 1.0, diagonal 1.5.
float CombatStepApCost(Vector3 from, Vector3 to);

// Exult Field_types for TFA contact-effect shapes (ObjectData::m_isTrap).
enum class ContactFieldType : int
{
	None = -1,
	Caltrops = 0,
	// Fire / poison / sleep / campfire — later
};

ContactFieldType GetContactFieldType(int shape);

// Exult Field_object::field_effect for caltrops: INT < rand()%40 → 1–2 damage.
// Returns true if damage was applied. Does not remove the caltrop.
bool ApplyCaltropDamage(U7Object* victim);

// On tile enter: scan underfoot contact fields (caltrops for now) and apply effects.
void CheckContactFieldsAt(U7Object* unit);

// Ready-hand weapon for combat (RIGHT_HAND first, then LEFT_HAND).
// Prefers shapes present in WEAPONS.DAT so a shield in the off-hand is ignored.
U7Object* GetEquippedWeapon(U7Object* unit);
// Object-data name for a weapon shape, or "fists".
std::string CombatWeaponDisplayName(int weaponShape);
std::string CombatWeaponDisplayNameForUnit(U7Object* unit);

// Exult Actor::get_property(combat) for hit rolls (Avatar via g_Player).
int GetCombatSkill(const U7Object* unit);

// Sum of equipped ARMOR.DAT protection (+ natural for monsters). For party UI.
int GetTotalArmorPoints(const U7Object* unit);

// Exult Actor::roll_to_win (d30; 0 always lose, 29 always win).
bool CombatRollToWin(int attackerPoints, int defenderPoints);

// Exult Actor::try_to_hit. Protection adds +3 to defender combat.
// Autohit weapons skip the roll. Returns true if the swing connects.
bool TryCombatHit(U7Object* attacker, U7Object* target, int weaponShape = -1, int ammoShape = -1);

// Exult-style damage: strength/3 + weapon(+ammo) wpoints, minus armor.
// weaponShape < 0 → bare hands / monster natural weapon. ammoShape < 0 → no ammo bonus.
// Returns 0 when armor fully absorbs or the target is immune.
int FigureCombatHitPoints(U7Object* attacker, U7Object* target, int weaponShape, int ammoShape = -1);

// Exult figure_hit_points weapon powers (poison/curse/charm/sleep/paralyze).
// No-op when the target has Obj_flags::protection. When hitsDealt==0, powers apply
// only for NoDamage / zero-wpoint weapons. Magebane clears mana when set.
void ApplyCombatWeaponPowers(U7Object* attacker, U7Object* target, int weaponShape,
	int ammoShape = -1, int hitsDealt = 0);

// Subtract HP, spawn floating damage text, notify attacker.
// Exult thresholds: HP may go negative (floor -50); KO (asleep) at HP <= 0;
// true death when HP < -(strength/3). Returns true if the target was defeated
// (knocked out or killed) by this hit.
bool ApplyCombatDamage(U7Object* target, float amount, U7Object* attacker = nullptr);

void SpawnFloatingCombatText(Vector3 worldPos, const std::string& text, Color color);
/// Floating "MISS" above the target (replaces miss console spam).
void SpawnFloatingMissText(U7Object* target);
void UpdateFloatingCombatTexts();
void DrawFloatingCombatTexts(); // screen-space; call inside GUI render target
void DrawCombatHPBars();        // screen-space; combat mode only
void DrawCombatSelectionCircles(); // world-space ground rings; combat mode only

#endif
