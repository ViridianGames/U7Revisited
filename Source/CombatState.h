#ifndef _CombatState_H_
#define _CombatState_H_

#include "Geist/State.h"
#include <vector>
#include <memory>
#include <string>

class Gui;
class GuiElement;
class U7Object;

// CombatState handles both real-time and turn-based combat modes in Ultima VII.
// It is entered either manually (via the combat toggle on the character sheet)
// or automatically when hostile creatures come within range of the party.
class CombatState : public State
{
public:
	CombatState();
	virtual ~CombatState();

	virtual void Init(const std::string& configfile) override;
	virtual void Shutdown() override;
	virtual void Update() override;
	virtual void Draw() override;

	virtual void OnEnter() override;
	virtual void OnExit() override;

	// Whether combat is currently in turn-based mode (vs real-time)
	bool m_isTurnBased = false;

	// List of participants (NPC IDs or object IDs) currently in this combat
	std::vector<int> m_participants;

	// GUI for combat-specific overlays (action bar, initiative order, etc.)
	Gui* m_gui = nullptr;

	// Planning phase: paused until the player presses Space
	bool m_paused = true;

	// Party member currently receiving a target assignment (object ID)
	int m_selectedPartyMemberObjectId = -1;

	// Set before PushState when auto-entering from hostile aggro (e.g. "Headlesses approach!").
	std::string m_approachMessage;

	// Add object id to participants if missing.
	void EnsureParticipant(int objectId);
	// Enroll every Team-1 monster/NPC within aggro range of the Avatar.
	void EnrollNearbyHostiles();

private:
	void HandleCombatInput();
	void HandleCombatClick();
	bool IsPartyMemberObject(const U7Object* obj) const;
	bool IsEnemyObject(const U7Object* obj) const;
	void ClearPartyTargets();
	void BeginCombat();
	void PauseForOrders();
	void IssueMoveOrder(U7Object* member, const Vector3& dest);
};

// True for Team-1 monsters/NPCs that should fight the party.
bool IsHostileCombatUnit(const U7Object* unit);

// Find nearest hostile within aggro range of the Avatar (or null).
U7Object* FindNearestHostileInAggroRange();

// If any hostile is in aggro range and combat is not active, start combat using the nearest.
// Returns true when combat was newly started.
bool TryBeginCombatFromHostileAggro(U7Object* hintHostile);

#endif