#ifndef _COLORPICKERSTATE_H_
#define _COLORPICKERSTATE_H_

#include "../Geist/State.h"
#include "../Geist/GhostWindow.h"
#include <memory>
#include <raylib.h>

class ColorPickerState : public State
{
public:
	ColorPickerState() {};
	~ColorPickerState();

	void Init(const std::string& configfile) override;
	void Shutdown() override;
	void Update() override;
	void Draw() override;
	void OnEnter() override;
	void OnExit() override;

	// Set the initial color to edit
	void SetColor(Color color);

	// Get the selected color (call after dialog is closed)
	Color GetColor() const { return m_selectedColor; }

	// Check if OK was pressed (vs Cancel)
	bool WasAccepted() const { return m_accepted; }

private:
	std::unique_ptr<GhostWindow> m_window;

	Color m_selectedColor = { 255, 255, 255, 255 };
	bool m_accepted = false;
};

#endif
