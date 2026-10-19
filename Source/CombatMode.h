#ifndef _CombatMode_H_
#define _CombatMode_H_

#include <memory>
#include <vector>
#include <string>

class MainState;
class U7Object;

// Player preference / active encounter combat style.
enum class CombatStyle : int
{
	Original = 0,
	RealTimePause = 1,
	TurnBased = 2,
};

// Real-Time-with-Pause party order (mirrors ultima7-rtwp Auto/Hold/Target/Move).
enum class CombatOrderMode : unsigned char
{
	Automatic = 0,
	Hold = 1,
	Attack = 2,
	Move = 3
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
	// World-space overlays (call inside Mode3D, before EndMode3D).
	virtual void DrawWorld(MainState& main) { (void)main; }
	// Style-specific orders click. Return true if the click was consumed.
	virtual bool HandleOrdersClick(MainState& main) { (void)main; return false; }

	// TB orders cursor: None = leave MainState's current g_Cursor alone.
	enum class OrdersCursorKind
	{
		None,
		Default,
		DefaultGrey,
		Combat,
		CombatGrey
	};
	virtual OrdersCursorKind GetOrdersCursor() { return OrdersCursorKind::None; }

	// Gates for MainState / U7Object combat AI.
	virtual bool IsSimulationPaused() const { return !IsImplemented(); }
	virtual bool AllowsPlayerOrders() const { return false; }
	// Finer gate for TB Resolving: only the active unit should run combat AI.
	// Default matches IsSimulationPaused (everyone or nobody).
	virtual bool ShouldUnitSimulate(const U7Object* /*unit*/) const { return !IsSimulationPaused(); }
};

std::unique_ptr<CombatMode> CreateCombatMode(CombatStyle style);

// While RTwP combat freecam is active, hard-stop look-at so Avatar stays on-screen.
void ClampCombatCameraKeepAvatarOnScreen();

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
	bool IsImplemented() const override { return true; }

	void OnEnter(MainState& main) override;
	void OnLeave(MainState& main) override;
	void Update(MainState& main) override;
	void HandleInput(MainState& main) override;
	void DrawHud(MainState& main) override;

	bool IsSimulationPaused() const override;
	bool AllowsPlayerOrders() const override { return true; }

private:
	MainState* m_main = nullptr;
	bool m_wasCameraLocked = false;
};

class TurnBasedCombatMode : public CombatMode
{
public:
	enum class Phase
	{
		Planning,   // frozen; player issues orders for active party unit
		Resolving   // only active unit simulates until action completes
	};

	struct ReachTile
	{
		int x = 0;
		int z = 0;
		float cost = 0.0f;       // AP spent to arrive
		float apLeft = 0.0f;     // AP remaining after arriving
	};

	CombatStyle GetStyle() const override { return CombatStyle::TurnBased; }
	const char* GetDisplayName() const override { return CombatStyleDisplayName(CombatStyle::TurnBased); }
	bool IsImplemented() const override { return true; }

	void OnEnter(MainState& main) override;
	void OnLeave(MainState& main) override;
	void Update(MainState& main) override;
	void HandleInput(MainState& main) override;
	void DrawHud(MainState& main) override;
	void DrawWorld(MainState& main) override;
	bool HandleOrdersClick(MainState& main) override;
	OrdersCursorKind GetOrdersCursor() override;

	bool IsSimulationPaused() const override;
	bool AllowsPlayerOrders() const override;
	bool ShouldUnitSimulate(const U7Object* unit) const override;

	int GetActiveUnitId() const { return m_activeUnitId; }
	float GetApRemaining() const { return m_apRemaining; }
	float GetApBudget() const { return m_apBudget; }
	Phase GetPhase() const { return m_phase; }

	// Spend AP. Returns false if cost exceeds remaining.
	bool TrySpendAp(float cost);
	void EndActiveTurn(); // Space / AP exhausted — advance initiative

	// Melee 3 / missile & spells 4. Used by reach overlay and MainState spell orders.
	float GetAttackApCostForUnit(const U7Object* unit) const;
	float GetSpellApCost() const { return kSpellAp; }
	bool TrySpendSpellAp();
	bool CanAffordSpell() const;
	void RefreshReachableAfterApChange();

private:
	static constexpr float kMeleeAttackAp = 3.0f;
	static constexpr float kMissileAttackAp = 4.0f;
	static constexpr float kSpellAp = 4.0f;
	static constexpr float kApEpsilon = 0.001f;
	static constexpr float kEngageRangeSlack = 0.85f;

	/// Soft-center on the active unit without locking; Avatar must stay on-screen.
	void CenterCameraOnActiveUnit();
	void RebuildInitiative(MainState& main);
	// Mid-fight: EnrollNearby adds hostiles to participants but initiative was
	// only snapshotted on enter. Sync inserts/drops without resetting the
	// active turn (AP / phase / pending AI).
	void SyncInitiativeFromParticipants(MainState& main);
	void CollectInitiativeOrder(MainState& main, std::vector<int>& out) const;
	void StartUnitTurn(MainState& main);
	void AdvanceToNextLiving(MainState& main);
	void ComputeReachableTiles(U7Object* unit, float maxAp, std::vector<ReachTile>& out) const;
	void RebuildReachableTiles();
	void ClearReachableTiles();
	bool TryIssueMoveTo(MainState& main, int tileX, int tileZ);
	bool BeginMoveToTile(U7Object* unit, int tileX, int tileZ, float spent);
	void ResetResolveTracking(U7Object* unit);
	void ForceFinishResolvingMove(MainState& main, U7Object* unit, const char* reason);
	void OnMoveResolved(MainState& main);
	void RunEnemyTurnAi(MainState& main);
	bool TryIssueAttackOn(MainState& main, U7Object* target);
	bool BeginAttackOn(U7Object* attacker, U7Object* target);
	void OnAttackResolved(MainState& main);
	void UpdateResolvingAttack(MainState& main, U7Object* unit);
	bool TryMoveTowardTarget(U7Object* unit, U7Object* target, float reserveAp);
	bool IsInAttackRange(const U7Object* attacker, const U7Object* target) const;
	float GetUnitEngageRange(const U7Object* unit) const;
	void RefreshUnitAttackRange(U7Object* unit) const;
	bool CanAffordAttack() const;
	float GetActiveAttackApCost() const;
	U7Object* FindNearestPartyTarget(const U7Object* from) const;
	U7Object* FindNearestHostileTarget(const U7Object* from) const;
	bool IsLivingCombatant(const U7Object* obj) const;
	bool IsPartyUnit(const U7Object* obj) const;
	bool IsTileOccupiedByOther(int tileX, int tileZ, int selfId) const;
	U7Object* GetActiveUnit() const;
	std::string UnitLabel(const U7Object* obj) const;
	std::string FormatAp(float ap) const;
	const ReachTile* FindReachTile(int tileX, int tileZ) const;

	MainState* m_main = nullptr;
	bool m_wasCameraLocked = false;

	std::vector<int> m_initiative;
	int m_initiativeIndex = 0;
	int m_activeUnitId = -1;
	float m_apRemaining = 0.0f;
	float m_apBudget = 0.0f;
	Phase m_phase = Phase::Planning;

	std::vector<ReachTile> m_reachTiles;
	float m_reachDrawY = 0.05f;
	float m_pendingMoveApCost = 0.0f; // AP already spent when Resolving a move
	bool m_enemyAiPending = false;    // enemy turn: decide move/attack on next Update
	bool m_endTurnAfterMove = false;  // enemies auto-end after move when they cannot attack
	bool m_enemyAttackAfterMove = false; // after closing distance, try attack
	bool m_resolvingAttack = false;   // Resolving is an attack swing/shot
	bool m_attackSwingStarted = false;
	int m_attackTargetId = 0;
	float m_pendingAttackApCost = 0.0f; // AP spent on current attack (for refund)
	int m_resolveFrames = 0;          // failsafe while Phase::Resolving
	float m_resolveLastX = 0.0f;
	float m_resolveLastY = 0.0f;
	float m_resolveLastZ = 0.0f;
	int m_resolveNoProgressFrames = 0; // frames with no meaningful pos change
	static constexpr int kResolveStuckFrames = 180; // ~3s at 60fps
	static constexpr int kResolveNoProgressFrames = 45; // ~0.75s with no movement
};

#endif
