#ifndef _ASKEXITSTATE_H_
#define _ASKEXITSTATE_H_

#include "Geist/State.h"
#include "Geist/Gui.h"
#include "Ghost/GhostSerializer.h"
#include <memory>
#include <vector>

// Modal exit confirmation dialog state
// Displays "Art thou sure?" with YES and NO buttons
class AskExitState : public State
{
public:
	AskExitState();
	virtual ~AskExitState();

	virtual void Init(const std::string& data) override;
	virtual void Shutdown() override;
	virtual void OnEnter() override;
	virtual void OnExit() override;
	virtual void Update() override;
	virtual void Draw() override;

private:
	// GUI instance
	Gui m_gui;

	// Element IDs for UI elements
	int m_yesButtonId = -1;
	int m_noButtonId = -1;

	// Wait for mouse release before accepting input
	bool m_waitingForMouseRelease = true;
	int m_releaseFrameCount = 0;

	// Ghost serializer for loading the GUI
	std::unique_ptr<GhostSerializer> m_serializer;
	std::vector<std::shared_ptr<Font>> m_loadedFonts;
};

#endif
