#ifndef _ConversationState_H_
#define _ConversationState_H_

#include "Geist/State.h"
#include <list>
#include <deque>
#include <array>
#include <math.h>
#include <functional>  // For std::function

class ParticleSystem;
class Gui;
class GuiElement;
class GuiManager;

class ConversationState : public State
{
public:

   enum class ConversationStepType
   {
      STEP_ADD_DIALOGUE = 0,
      STEP_CHANGE_PORTRAIT,
      STEP_ASK_YES_NO,
   };

   struct ConversationStep
   {
      ConversationStepType type;
      std::string str;
      int npcId;
      int frame;
      std::function<void(bool)> yesNoCallback;  // Callback for STEP_ASK_YES_NO result
   };

   ConversationState(){};
   ~ConversationState();

   virtual void Init(const std::string& configfile);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw();

   virtual void OnEnter();
   virtual void OnExit();

   void SetNPC(int npcId, int frame = 0) { m_npcId = npcId; m_npcFrame = frame; }
   void AddStep(ConversationStep step) { m_steps.push_back(step); }
   void AddAnswer(std::string answer) { m_answers.push_back(answer); }
   void RemoveAnswer(std::string answer);
   void ClearAnswers() { m_answers.clear(); }
   void GetAnswers(const std::string& func_name);
   void SetAnswer(const std::string& func_name, const std::string& answer);
   void SaveAnswers() { m_savedAnswers = m_answers; }
   void RestoreAnswers() { m_answers = m_savedAnswers; m_savedAnswers.clear(); }
   void SetLuaFunction(const std::string& func_name)
   {
      m_luaFunction = func_name;
   }

   // New method to handle yes/no selection
   void SelectYesNo(bool yes);

   Gui* m_Gui;

   int m_npcId;
   int m_npcFrame;

   bool m_answerPending = false;
   bool m_waitingForAnswer = false;  // Track if waiting for yes/no response

   std::vector<std::string> m_answers;
   std::vector<std::string> m_savedAnswers;
   std::string m_currentDialogue;

   std::string m_luaFunction;

   std::vector<ConversationStep> m_steps;
   std::function<void(bool)> m_yesNoCallback;  // Callback to notify Lua

   bool m_scriptFinished = false;
   bool m_conversationActive = false;
};

#endif