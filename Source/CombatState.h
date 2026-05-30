#ifndef _CombatState_H_
#define _CombatState_H_

#include "Geist/State.h"
#include <vector>
#include <memory>

class Gui;
class GuiElement;

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

	// Future: methods to control combat mode
	// void StartCombat(bool turnBased = false);
	// void EndCombat();
	// bool IsTurnBased() const;

	// Whether combat is currently in turn-based mode (vs real-time)
	bool m_isTurnBased = false;

	// List of participants (NPC IDs or object IDs) currently in this combat
	std::vector<int> m_participants;

	// GUI for combat-specific overlays (action bar, initiative order, etc.)
	Gui* m_Gui = nullptr;
};

#endif
