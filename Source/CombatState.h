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

// Find nearest hostile within aggro range of the Avatar (or null).
U7Object* FindNearestHostileInAggroRange();

// If any hostile is in aggro range and combat is not active, warn once.
// Does not enter combat — player presses C. Returns false always (no auto-enter).
bool TryBeginCombatFromHostileAggro(U7Object* hintHostile);

// "Headless" → "Headlesses" style label for approach messages.
std::string PluralizeCreatureName(const std::string& name);

// Max HP for bars (m_BaseMaxHP, else current HP floor).
float GetCombatMaxHP(const U7Object* unit);

// Exult-style hit roll: strength/3 + weapon(+ammo) wpoints, minus armor.
// weaponShape < 0 → bare hands / monster natural weapon. ammoShape < 0 → no ammo bonus.
// Returns 0 when armor fully absorbs or the target is immune.
int FigureCombatHitPoints(U7Object* attacker, U7Object* target, int weaponShape, int ammoShape = -1);

// Subtract HP, spawn floating damage text, notify attacker, ApplyDeath if needed.
// Returns true if the target died from this hit.
bool ApplyCombatDamage(U7Object* target, float amount, U7Object* attacker = nullptr);

void SpawnFloatingCombatText(Vector3 worldPos, const std::string& text, Color color);
void UpdateFloatingCombatTexts();
void DrawFloatingCombatTexts(); // screen-space; call inside GUI render target
void DrawCombatHPBars();        // screen-space; combat mode only
void DrawCombatSelectionCircles(); // world-space ground rings; combat mode only

#endif
