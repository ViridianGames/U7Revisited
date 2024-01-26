///////////////////////////////////////////////////////////////////////////
//
// Name:     BASEUNITS.H
// Author:   Anthony Salter
// Date:     11/13/17
// Purpose:  A Unit is an Object that can move and has a lifespan.  It's
//           designed to be derived from to create the units in your game.
//
//           I debated long and hard about separating units out into 2D and
//           3D units (2D and 3D simply represents the space the units move
//           through, not whether the units are sprites or models).  In the
//           end, the needs of 2D units vs those of 3D units were different
//           enough that I didn't think it was a good idea to try to munge
//           them together into one class.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _BASEUNITS_H_
#define _BASEUNITS_H_

#include "Object.h"
#include "Config.h"
#include "Primitives.h"
#include <string>

class Unit2D : public Object
{
public:
	Unit2D() {};

	virtual void Init() { Init(std::string("")); }
	virtual void Init(char* data) { Init(std::string(data)); }
	virtual void Init(const std::string& configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	bool GetIsDead() { return m_IsDead; }
	void SetIsDead(bool dead) { m_IsDead = dead; }
	Point GetPos() { return m_Pos; }
	void SetPos(Point newpos) { m_Pos = newpos; }

	Point m_Pos;
	bool m_IsDead = false;

	Config m_UnitConfig;
};

class Unit3D : public Object
{
public:
	Unit3D() {};

	virtual void Init() { Init(std::string("")); }
	virtual void Init(char* data) { Init(std::string(data)); }
	virtual void Init(const std::string& configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	virtual bool GetIsDead() { return m_IsDead; }
	virtual void SetIsDead(bool dead) { m_IsDead = dead; }
	virtual glm::vec3 GetPos() { return m_Pos; }
	virtual void SetPos(glm::vec3 newpos) { m_Pos = newpos; }

	glm::vec3 m_Pos;
	bool m_IsDead = false;

	Config* m_UnitConfig;
};

#endif