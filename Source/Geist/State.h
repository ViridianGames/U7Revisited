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
	// If true, this state will render all states below it in the stack
	// If false, only this state will be rendered (default behavior)
	bool m_RenderStack = false;

	// If true, StateMachine will draw the cursor after this state's Draw() call
	bool m_DrawCursor = true;

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