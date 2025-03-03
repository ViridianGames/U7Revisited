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
#include <list>

#include "Config.h"
#include "Object.h"

class Gui;

class GuiManager : public Object {
 public:
    GuiManager() {};

    virtual void Init() { Init(std::string("")); }
    virtual void Init(const std::string& configfile);
    virtual void Shutdown();
    virtual void Update();
    virtual void Draw();

    void AddGui(std::unique_ptr<Gui> gui) {
        m_GuiList.push_back(std::move(gui));
    }
    // void RemoveGui(int ID) { m_GUIs.erase(std::remove_if(m_GUIs.begin(),
    // m_GUIs.end(), [ID](const std::unique_ptr<Gui>& gui) { return gui->
    // ->GetID() == ID; }), m_GUIs.end()); }

    Config m_GUIManagerConfig;
    std::string m_ConfigFileName;
    std::list<std::unique_ptr<Gui>> m_GuiList;
};

#endif
