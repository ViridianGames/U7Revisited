#ifndef _LOADSAVESTATE_H_
#define _LOADSAVESTATE_H_

#include "Geist/State.h"
#include "Geist/Gui.h"
#include "Ghost/GhostSerializer.h"
#include <memory>
#include <vector>

// Modal Load/Save dialog state
// Displays 10 save slots with textinput fields
// Has SAVE, LOAD, QUIT, and CLOSE buttons
class LoadSaveState : public State
{
public:
	LoadSaveState();
	virtual ~LoadSaveState();

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
	int m_closeButtonId = -1;
	int m_saveButtonId = -1;
	int m_loadButtonId = -1;
	int m_quitButtonId = -1;
	int m_slotIds[10] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1};

	// Save slot data
	std::vector<std::string> m_saveNames;
	int m_selectedSlot = -1;

	// Ghost serializer for loading the GUI
	std::unique_ptr<GhostSerializer> m_serializer;
	std::vector<std::shared_ptr<Font>> m_loadedFonts;

	// Helper method to update slot highlighting
	void UpdateSlotHighlighting();
};

#endif
