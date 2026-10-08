#ifndef _CombatState_H_
#define _CombatState_H_

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

#endif
