#ifndef _ASKSTATE_H_
#define _ASKSTATE_H_

#include "Geist/State.h"
#include "Geist/Gui.h"
#include "Ghost/GhostSerializer.h"
#include <memory>
#include <vector>
#include <functional>

// Generic modal yes/no question dialog state
// Pass ghost file path in Init() to load any question dialog
// Set callback to handle YES button response
class AskState : public State
{
public:
	AskState();
	virtual ~AskState();

	virtual void Init(const std::string& data) override;
	virtual void Shutdown() override;
	virtual void OnEnter() override;
	virtual void OnExit() override;
	virtual void Update() override;
	virtual void Draw() override;

	// Set the ghost file to load for the question dialog
	void SetGhostFile(const std::string& ghostFilePath) { m_ghostFilePath = ghostFilePath; }

	// Set callback to be called when YES button is clicked
	// If no callback is set, dialog just closes
	void SetYesCallback(std::function<void()> callback) { m_yesCallback = callback; }

private:
	// GUI instance
	Gui m_gui;

	// Element IDs for UI elements
	int m_yesButtonId = -1;
	int m_noButtonId = -1;

	// Wait for mouse release before accepting input
	bool m_waitingForMouseRelease = true;
	int m_releaseFrameCount = 0;

	// Ghost file path to load
	std::string m_ghostFilePath;

	// Callback for YES button
	std::function<void()> m_yesCallback;

	// Ghost serializer for loading the GUI
	std::unique_ptr<GhostSerializer> m_serializer;
	std::vector<std::shared_ptr<Font>> m_loadedFonts;
};

#endif
