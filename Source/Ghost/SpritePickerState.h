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

	// Zoom and pan state
	float m_zoom = 1.0f;
	float m_panX = 0.0f;
	float m_panY = 0.0f;

	// Drag selection state
	bool m_isDragging = false;
	int m_dragStartX = 0;
	int m_dragStartY = 0;
	int m_dragEndX = 0;
	int m_dragEndY = 0;

	// Pan state
	bool m_isPanning = false;
	float m_panStartMouseX = 0.0f;
	float m_panStartMouseY = 0.0f;
	float m_panStartX = 0.0f;
	float m_panStartY = 0.0f;

	// Double-click detection
	double m_lastClickTime = 0.0;
	int m_lastClickX = 0;
	int m_lastClickY = 0;
	const double m_doubleClickDelay = 0.3; // seconds
	const int m_doubleClickRadius = 5; // pixels

	// Fixed browser area bounds (relative to main panel position)
	const Rectangle m_browserBounds = {500.0f, 10.0f, 103.0f, 408.0f};
};
