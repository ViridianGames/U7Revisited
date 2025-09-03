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

	Config		m_GumpManagerConfig;
	std::string	m_ConfigFileName;
	std::vector<std::shared_ptr<Gump>> m_GumpList;
	bool			m_draggingObject;
	Gump*			m_sourceGump;
	int			m_draggedObjectId;
	Vector2		m_dragOffset;
	bool			m_mouseOverGump;
};

#endif
