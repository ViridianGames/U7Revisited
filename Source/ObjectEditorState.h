#ifndef _OBJECTEDITORSTATE_H_
#define _OBJECTEDITORSTATE_H_

#include <deque>
#include <list>
#include <math.h>
#include "Geist/Gui.h"
#include "Geist/State.h"

class ObjectEditorState : public State {
 public:
    ObjectEditorState() {};
    ~ObjectEditorState();

    virtual void Init(const std::string& configfile);
    virtual void Shutdown();
    virtual void Update();
    virtual void Draw();

    virtual void OnEnter();
    virtual void OnExit();
};

#endif
