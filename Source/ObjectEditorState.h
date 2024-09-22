#ifndef _OBJECTEDITORSTATE_H_
#define _OBJECTEDITORSTATE_H_

#include "Geist/State.h"
#include "Geist/Gui.h"
#include <list>
#include <deque>
#include <math.h>

class ObjectEditorState : public State
{
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