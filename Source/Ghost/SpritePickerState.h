#pragma once

#include "../Geist/State.h"
#include "GhostWindow.h"
#include <string>
#include <memory>

class SpritePickerState : public State
{
public:
	~SpritePickerState();

	void Init(const std::string& configfile) override;
	void Shutdown() override;
	void OnEnter() override;
	void OnExit() override;
	void Update() override;
	void Draw() override;

	// Set the sprite definition to edit
	void SetSprite(const std::string& filename, int x, int y, int width, int height);

	// Get the result after OK is clicked
	bool WasAccepted() const { return m_accepted; }
	std::string GetFilename() const { return m_filename; }
	int GetX() const { return m_x; }
	int GetY() const { return m_y; }
	int GetWidth() const { return m_width; }
	int GetHeight() const { return m_height; }

private:
	void ValidateAndApplyFallbacks();

	std::unique_ptr<GhostWindow> m_window;

	bool m_accepted = false;
	bool m_waitingForFileChooser = false;  // Track if we're waiting for FileChooserState

	// Sprite definition values
	std::string m_filename;
	int m_x = 0;
	int m_y = 0;
	int m_width = 0;
	int m_height = 0;
};
