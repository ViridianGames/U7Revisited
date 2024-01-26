///////////////////////////////////////////////////////////////////////////
//
// Name:     MEMORYMANAGER.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  The MemoryManager subsystem.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _MEMORYMANAGER_H_
#define _MEMORYMANAGER_H_

#include "Object.h"

class MemoryManager : public Object
{
public:
	MemoryManager() {};

	virtual void Init(const std::string& configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw() {};
};

#endif