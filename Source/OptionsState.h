#ifndef _OptionsState_H_
#define _OptionsState_H_

#include "Geist/State.h"
#include <list>
#include <deque>
#include <math.h>

class OptionsState : public State
{
public:
   OptionsState(){};
   ~OptionsState();


   virtual void Init(const std::string& configfile);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw();

   virtual void OnEnter();
   virtual void OnExit();

};

#endif