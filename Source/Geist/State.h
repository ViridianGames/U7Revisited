///////////////////////////////////////////////////////////////////////////
//
// Name:     STATE.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  A state for use with the state machine.
//
///////////////////////////////////////////////////////////////////////////
#ifndef _STATE_H_
#define _STATE_H_

#include "Object.h"

class State : public Object
{
private:
	bool m_IsDead = false;

public:
	State() {};

	virtual void Init() { Init(std::string("")); }
	virtual void Init(const std::string& configfile) = 0;
	virtual void Shutdown() = 0;
	virtual void Update() = 0;
	virtual void Draw() = 0;

	virtual void OnEnter() = 0;
	virtual void OnExit() = 0;
	bool GetIsDead() { return m_IsDead; }
	void SetIsDead(bool isDead) { m_IsDead = isDead; }
};

#endif