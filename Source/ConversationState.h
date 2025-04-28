#ifndef _ConversationState_H_
#define _ConversationState_H_

#include "Geist/State.h"
#include <list>
#include <deque>
#include <array>
#include <math.h>
#include "lua.hpp"

class ParticleSystem;
class Gui;
class GuiElement;
class GuiManager;

class ConversationState : public State
{
public:
   ConversationState(){};
   ~ConversationState();

   virtual void Init(const std::string& configfile);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw();

   virtual void OnEnter();
   virtual void OnExit();

   void SetNPC(int npcId) { m_npcId = npcId; }
   void AddDialogue(const std::string& text) { m_dialogue.push_back(text); }
   void AddAnswer(std::string answer) { m_answers.push_back(answer); }

   void GetAnswers(const std::string& func_name);

   void SetAnswer(const std::string& func_name, const std::string& answer);

   void SetLuaFunction(const std::string& func_name)
   {
      m_luaFunction = func_name;
   }

   Gui* m_Gui;

   int m_npcId;

   bool m_answerPending = false;

   std::vector<std::string> m_dialogue;
   std::vector<std::string> m_answers;

   std::string m_luaFunction;
};

#endif