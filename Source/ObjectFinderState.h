#ifndef _OBJECTFINDERSTATE_H_
#define _OBJECTFINDERSTATE_H_

#include "Geist/State.h"
#include "Geist/Gui.h"
#include <string>
#include <vector>

class U7Object;

//  Sandbox debug screen (Ctrl+F): fuzzy search the world's objects and NPCs by name, see every
//  instance on the world map, and jump the camera to one.  F3 / Shift+F3 then step through the rest.
class ObjectFinderState : public State
{
public:
	ObjectFinderState() { m_RenderStack = true; }

	void Init(const std::string& configfile) override;
	void Shutdown() override {}
	void Update() override;
	void Draw() override;
	void OnEnter() override;
	void OnExit() override {}

private:
	struct Entry
	{
		std::string label;           // "blood moss (842)" or "Iolo (NPC 1)"
		std::vector<int> objectIds;  // Nearest to the camera first once shown
	};

	enum GuiElements
	{
		GE_PANEL = 0,
		GE_TITLE,
		GE_SEARCH,
		GE_MATCHES,
		GE_INSTANCES,
		GE_JUMP,
		GE_TELEPORT,
		GE_LEGENDWORLD,
		GE_LEGENDCONTAINER,
		GE_KEYSHELP,
		GE_GAMEHELP,
		GE_MAPHELP,
		GE_MAPBORDER
	};

	void BuildEntries();
	void UpdateMatches();
	void ShowInstances(int entry);
	void Jump(int instance, bool teleport);
	U7Object* GetPlacedInstance(int instance);
	int GetInstanceUnderMouse();
	Rectangle GetMapRect();

	Gui m_gui;
	std::vector<Entry> m_entries;
	std::vector<int> m_matches;     // m_entries index for each row of the matches list
	int m_shownEntry = -1;          // m_entries index whose instances are listed and on the map
	int m_hoveredInstance = -1;     // Instance under the mouse on the map
	std::string m_lastSearch;
	Texture* m_map = nullptr;
	Camera2D m_mapCamera = {};
};

#endif
