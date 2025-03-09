///////////////////////////////////////////////////////////////////////////
//
// Name:     GUIManager.H
// Author:   Anthony Salter
// Date:     2/24/25
// Purpose:  Simple GUI manager that can keep track of multiple GUIs.  Add
//           a GUI to the manager, and it will be updated and drawn.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _GUIMANAGER_H_
#define _GUIMANAGER_H_

#include <memory>

#include "Object.h"
#include "Config.h"

class Gui;

class GuiManager : public Object
{
public:
	GuiManager() {};

	virtual void Init() { Init(std::string("")); }
	virtual void Init(const std::string& configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	void AddGui(std::shared_ptr<Gui>& gui);

	Config                               m_GUIManagerConfig;
	std::string                          m_ConfigFileName;
	std::vector<std::shared_ptr<Gui>>    m_GuiList;
};

#endif
