#ifndef _OBJECTEDITORSTATE_H_
#define _OBJECTEDITORSTATE_H_

#include "State.h"
#include "Gui.h"
#include <list>
#include <deque>
#include <math.h>

class ObjectEditorState : public State
{
public:
   ObjectEditorState(){};
   ~ObjectEditorState();


   virtual void Init(const std::string& configfile);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw();

   virtual void OnEnter();
   virtual void OnExit();
   
   unsigned int m_currentShape = 0;
   unsigned int m_currentFrame = 0;
   bool m_rotating = false;
   bool m_tileX = false;
   bool m_tileZ = false;
   bool m_shapeTableMade = false;
   float m_rotateAngle = 0.0;

   std::vector<std::vector<std::shared_ptr<U7Object>>> m_objectLibrary;

};

#endif