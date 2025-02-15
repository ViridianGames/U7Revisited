///////////////////////////////////////////////////////////////////////////
//
// Name:     STATEMACHINE.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  Get on the scene (get on up!) a-like a state machine!  The state
//           machine is basically a state that creates and handles all the other
//           states.  Engine->Update() calls StateMachine->Update(),
//           which is turn calls the Update() of the current state through
//           a pointer.
//
///////////////////////////////////////////////////////////////////////////
#ifndef _STATEMACHINE_H_
#define _STATEMACHINE_H_

#include "Object.h"
#include "State.h"
#include <map>
#include <deque>

class StateMachine : public Object
{
	enum TransitionTypes
	{
		TT_STATE = 0, // A classic state transition
		TT_PUSH,      // Pushing a state
		TT_POP       // Popping a state
	};

	enum StateTypes
	{
		ST_STATE = 0,
		ST_PUSHSTATE
	};

public:
	StateMachine() {};

  virtual void Init(const std::string& configfile);
  virtual void Shutdown();
  virtual void Update();
  virtual void Draw();

  void RegisterState(int id, State* state, std::string name = "NO NAME");
  void MakeStateTransition(int newstate);
  void PushState(int newstate);
  void PopState();
  int GetCurrentState() { return m_CurrentState; }
  int GetPreviousState();// { return m_PreviousState; }
  State* GetState(int identifier);

  bool animFramesInitialized = false;
  int currentAnimFrame[32];
  int GetAnimFrame(int frameCount);

private:
	void MakeStateTransitionEX(int newstate);
	void PushStateEX(int newstate);
	void PopStateEX();

	std::map<int, State*> m_StateMap;
	std::map<int, std::string> m_StateNames;
	std::deque<std::tuple<int, int>> m_StateStack;  //  State ID, state type, state name
	std::deque<std::tuple<int, int>> m_TransitionStack; //  Transition type, new state

	int  m_CurrentState = -1;
	int  m_PreviousState = -1;
	int  m_TargetState = -1;

};

#endif