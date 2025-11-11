#ifndef _GHOSTWINDOW_H_
#define _GHOSTWINDOW_H_

#include <string>
#include "raylib.h"

class Gui;
class GhostSerializer;
class ResourceManager;

class GhostWindow
{
public:
	GhostWindow(const std::string& ghostFilePath, const std::string& configPath,
	            ResourceManager* resourceManager, int screenWidth, int screenHeight, bool modal = true, float scale = 1.0f);
	~GhostWindow();

	void Update();
	void Draw();

	void Show();
	void Hide();
	void Toggle();
	bool IsVisible() const { return m_visible; }

	bool IsModal() const { return m_modal; }
	void SetModal(bool modal) { m_modal = modal; }

	void MoveTo(int x, int y);
	void GetSize(int& width, int& height) const;
	Rectangle GetBounds() const;

	int GetElementID(const std::string& elementName);
	Gui* GetGui() { return m_gui; }
	GhostSerializer* GetSerializer() { return m_serializer; }
	bool IsValid() const { return m_gui != nullptr && m_valid; }

private:
	Gui* m_gui;
	GhostSerializer* m_serializer;
	bool m_visible;
	bool m_modal;
	bool m_valid;
};

#endif
