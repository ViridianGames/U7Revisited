#ifndef _OptionsState_H_
#define _OptionsState_H_

#include <deque>
#include <list>
#include <math.h>
#include "Geist/State.h"

class OptionsState : public State {
 public:
    OptionsState() {};
    ~OptionsState();

    virtual void Init(const std::string& configfile);
    virtual void Shutdown();
    virtual void Update();
    virtual void Draw();

    virtual void OnEnter();
    virtual void OnExit();
};

#endif
