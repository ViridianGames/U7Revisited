#ifndef _CombatMode_H_
#define _CombatMode_H_

#include <memory>

class MainState;

// Player preference / active encounter combat style.
enum class CombatStyle : int
{
	Original = 0,
	RealTimePause = 1,
	TurnBased = 2,
};

CombatStyle GetCombatStylePreference();
void SetCombatStylePreference(CombatStyle style);
const char* CombatStyleDisplayName(CombatStyle style);
const char* CombatStyleConfigToken(CombatStyle style);

// Strategy for one combat encounter while g_isCombatMode is set.
class CombatMode
{
public:
	virtual ~CombatMode() = default;

	virtual CombatStyle GetStyle() const = 0;
	virtual const char* GetDisplayName() const = 0;
	virtual bool IsImplemented() const { return false; }

	virtual void OnEnter(MainState& main);
	virtual void OnLeave(MainState& main);
	virtual void Update(MainState& main);
	virtual void HandleInput(MainState& main);
	virtual void DrawHud(MainState& main);

	// Gates for MainState / U7Object combat AI.
	virtual bool IsSimulationPaused() const { return !IsImplemented(); }
	virtual bool AllowsPlayerOrders() const { return false; }
};

std::unique_ptr<CombatMode> CreateCombatMode(CombatStyle style);

class OriginalCombatMode : public CombatMode
{
public:
	CombatStyle GetStyle() const override { return CombatStyle::Original; }
	const char* GetDisplayName() const override { return CombatStyleDisplayName(CombatStyle::Original); }
};

class RealTimePauseCombatMode : public CombatMode
{
public:
	CombatStyle GetStyle() const override { return CombatStyle::RealTimePause; }
	const char* GetDisplayName() const override { return CombatStyleDisplayName(CombatStyle::RealTimePause); }
	// Existing pause/orders helpers on MainState will be adopted here when implemented.
};

class TurnBasedCombatMode : public CombatMode
{
public:
	CombatStyle GetStyle() const override { return CombatStyle::TurnBased; }
	const char* GetDisplayName() const override { return CombatStyleDisplayName(CombatStyle::TurnBased); }
};

#endif
