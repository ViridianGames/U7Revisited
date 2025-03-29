#ifndef _GUMP_H_
#define _GUMP_H_

#include <list>
#include <vector>
#include <memory>
#include <map>

#include "Object.h"
#include "Primitives.h"
#include "Gui.h"
#include "GuiElements.h"

class Gump : public Gui
{
public:
	Gump();
	virtual ~Gump();

	virtual void Update() override;
	virtual void Draw() override;

	void LinkContainer(int containerId);

	int GetContainerId() { return m_containerId; }

	int m_containerType; // Defines the look of the gump we'll use to show this container's contents
	int m_containerId; //  The container this gump is linked to

	bool m_isSorted;

};

#endif