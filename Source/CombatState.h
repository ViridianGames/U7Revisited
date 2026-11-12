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

// Team-2 summons (Swarm insects). They fight for the party and are not player-controlled.
bool IsAlliedSummonUnit(const U7Object* unit);

// True when the unit stands on an Exult mountain-ceiling dungeon tile.
bool IsUnitInDungeon(const U7Object* unit);

// Dungeon hostiles only sense the party underground, and outdoor hostiles
// only aboveground (XZ overlap alone must not cross the ceiling).
bool AreUnitsOnSameDungeonLayer(const U7Object* a, const U7Object* b);

// Straight-line wall LOS between units (walls / closed doors block; windows do not).
// Used for aggro acquire, ranged fire, and attack orders.
bool HasCombatLineOfSight(const U7Object* from, const U7Object* to);

// True when the hostile has wall LOS to at least one living party member
// (same dungeon layer, within crow-fly). Required for new aggro / enroll.
// A member this hostile cannot see (invisibility, no see-invisible) does not count.
bool HasCombatLineOfSightToParty(const U7Object* hostile, float maxCrowFlyTiles = 16.0f);

// True when FindFastPath can walk the hostile to a living party member and every
// densified tile step passes ValidateMove. MonsterChase crow-fly / greedy stubs
// are not accepted — those false-connected Destard to Lasher's cave.
// Invisible members this hostile cannot see are skipped, same as the LOS check.
// maxCrowFlyTiles / maxWalkCost default to the short enroll budget; pruning
// mid-fight may pass the longer chase leash so valid fights are not dropped.
bool HasCombatWalkPathToParty(
	U7Object* hostile,
	float maxCrowFlyTiles = /* kHostileCombatEnrollRangeTiles */ 16.0f,
	float maxWalkCost = /* kHostileCombatEnrollRangeTiles */ 16.0f);

// Find nearest hostile within aggro range of the Avatar (or null).
U7Object* FindNearestHostileInAggroRange();

// If any hostile is in aggro range and combat is not active: either enter combat
// (when combat_auto_start_on_aggro is on) or warn once for manual C. Returns true
// if combat was entered this call.
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
	// Poison / sleep / campfire — later
};

// Shape 895. Spell fields are removed after 100 usecode ticks (20s at 200 ms).
// A map field with no timer still burns and is left in place.
constexpr int kFireFieldShape = 895;
constexpr int kPoisonFieldShape = 900;
constexpr int kSleepFieldShape = 902;
// Seventh Circle Energy Field. Impassable for 200 usecode ticks (40s). No damage.
constexpr int kEnergyFieldShape = 768;
constexpr float kFireFieldLifetimeSec = 20.0f;
// Exult Field_frame_animator: 10% chance each 100 ms frame. Mean gap is 1 second.
constexpr float kFireFieldPulseSec = 1.0f;
// 20 seconds at about one action every 3 seconds. A round is one pass through initiative.
constexpr int kFireFieldTurnRounds = 7;

ContactFieldType GetContactFieldType(int shape);

// Exult Field_object::field_effect for caltrops: INT < rand()%40 → 1–2 damage.
// Returns true if damage was applied. Does not remove the caltrop.
bool ApplyCaltropDamage(U7Object* victim);

// Exult fire field: flat 2–4 fire HP. Monster immunity zeros it, vulnerability
// doubles it. Armor does not soak. Sleepers wake unless they are knocked out.
// The field is not consumed. Party and the caster are included.
// A Flame Strike field also pulls team-1 victims and its caster into combat.
void ApplyFireFieldDamage(U7Object* victim, U7Object* field = nullptr);

// Team-1 NPCs and monsters join the current fight. Starts combat when none is
// running. Party members and other teams are left as they are.
void PullEnemyIntoCombat(U7Object* unit);

// Anyone standing on this field's tile takes one fire pulse.
void ApplyFireFieldPulse(U7Object* field);

// Poison (900) and sleep (902). A 50% roll applies the status when the
// creature does not already have it, and that success removes the field.
// A miss, or an already-affected creature, leaves the field in place.
// Step-in passes announceResist so a clean miss writes "Name resists sleep field!"
// Returns true when this victim consumed the field.
bool TryConsumeHazardField(U7Object* field, U7Object* victim, bool announceResist = false);
// One pass over creatures on the field's tile. True when the field is consumed.
// A cast passes announceResist so a creature already standing there rolls now.
bool PulseHazardField(U7Object* field, bool announceResist = false);

// Spell fields only. Turn-based combat counts rounds instead of the wall clock.
void NoteTimedFireField(int objectId);
void ForgetTimedFireField(int objectId);
void AdvanceFireFieldRounds();
void FreezeFireFieldsForTurns();
void ReleaseFireFieldsToRealTime();

// On tile enter: scan underfoot contact fields (caltrops, fire) and apply effects.
void CheckContactFieldsAt(U7Object* unit);

// Turn-based: one fire pulse for a creature who starts their turn on a field.
void ApplyStandingFireFieldDamage(U7Object* unit);

// Ready-hand weapon for combat (RIGHT_HAND first, then LEFT_HAND).
// Prefers shapes present in WEAPONS.DAT so a shield in the off-hand is ignored.
U7Object* GetEquippedWeapon(U7Object* unit);
// Object-data name for a weapon shape, or "fists".
std::string CombatWeaponDisplayName(int weaponShape);
std::string CombatWeaponDisplayNameForUnit(U7Object* unit);

// One combat-log sentence for a resolved swing.
// hits < 0 is a miss. Otherwise "and hits for N damage!"
// A monster or animal with no readied weapon omits the "with ..." clause.
std::string FormatCombatAttackSentence(const U7Object* attacker, const U7Object* target, int weaponShape, int hits);
// Misses are yellow. A party member's hit is white. An enemy's hit is red.
Color CombatAttackLogColor(const U7Object* attacker, int hits);

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
/// Floating "0" when a connecting hit is soaked to no HP (armor or immunity).
void SpawnFloatingZeroDamageText(U7Object* target);
void UpdateFloatingCombatTexts();
void DrawFloatingCombatTexts(); // screen-space; call inside GUI render target
void DrawCombatHPBars();        // screen-space; combat mode only
void DrawCombatSelectionCircles(); // world-space ground rings; combat mode only

#endif
