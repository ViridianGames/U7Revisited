///////////////////////////////////////////////////////////////////////////
//
// Name:     GumpManager.H
// Author:   Anthony Salter
// Date:     2/24/25
// Purpose:  Simple Gump manager that can keep track of multiple Gumps.  Add
//           a Gump to the manager, and it will be updated and drawn.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _GUMPMANAGER_H_
#define _GUMPMANAGER_H_

#include <memory>

#include "Object.h"
#include "Config.h"
#include "raylib.h"

class Gump;

class GumpManager : public Object
{
public:
	GumpManager() {};

	virtual void Init() { Init(std::string("")); }
	virtual void Init(char* data) { Init(std::string(data)); }
	virtual void Init(const std::string& configfile);

	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	void AddGump(std::shared_ptr<Gump> gump);
	void CloseGumpForObject(int objectId);  // Close any gump associated with the given object ID
	void CloseSpellbookForNpc(int npcId);   // Close spellbook gump for the given NPC ID
	void CloseAllGumps();                   // Close all gumps (used when loading save)

	bool IsMouseOverGump() { return m_isMouseOverGump; }
	Gump* GetGumpUnderMouse() { return m_gumpUnderMouse; }
	bool IsAnyGumpBeingDragged();

	Config		m_GumpManagerConfig;
	std::string	m_ConfigFileName;
	std::vector<std::shared_ptr<Gump>> m_GumpList;
	std::vector<std::shared_ptr<Gump>> m_PendingGumps;  // Gumps to add after current update completes
	bool			m_draggingObject;
	Gump*			m_sourceGump;
	int			m_draggedObjectId;
	int			m_sourceSlotIndex;  // Slot index item was dragged from (-1 if from container)
	Vector3		m_draggedObjectOriginalPos = { 0, 0, 0 };  // Original world position (for returning to world)
	Vector3		m_draggedObjectOriginalDest = { 0, 0, 0 };  // Original destination (for NPCs)
	Vector2		m_draggedObjectOffset = { 0, 0 };
	bool			m_isMouseOverGump;
	Gump*			m_gumpUnderMouse;
};

#endif
