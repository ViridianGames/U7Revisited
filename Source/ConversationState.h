#ifndef _ConversationState_H_
#define _ConversationState_H_

#include "Geist/State.h"
#include <list>
#include <deque>
#include <array>
#include <math.h>

#include "U7Gump.h"
#include "U7GumpNumberBar.h"

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
		STEP_SECOND_SPEAKER,
		STEP_MULTIPLE_CHOICE,
		STEP_GET_PURCHASE_OPTION,
		STEP_GET_AMOUNT_FROM_NUMBER_BAR,
	};

	struct ConversationStep
	{
		ConversationStepType type;
		std::string dialog;
		std::vector<std::string> answers;
		std::vector<int> data;
		int npcId;
		int frame;
	};

	ConversationState()
		: m_Gui(nullptr)
		, m_npcId(-1)
		, m_npcFrame(0)
		, m_secondSpeakerId(-1)
		, m_secondSpeakerFrame(0)
	{
	}

	~ConversationState();

	virtual void Init(const std::string& configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	virtual void OnEnter();
	virtual void OnExit();

	void SetNPC(int npcId, int frame = 0)
	{
		m_npcId = npcId;
		m_npcFrame = frame;
	}

	void AddStep(ConversationStep step) { m_steps.push_back(step); }
	void AddAnswers(std::vector<std::string> answers);
	void RemoveAnswer(std::string answer);
	void ClearAnswers() { m_answers.clear(); }
	void GetAnswers(const std::string& func_name);
	void SetAnswer(const std::string& func_name, const std::string& answer);
	void SaveAnswers();
	void RestoreAnswers();
	void SetLuaFunction(const std::string& func_name) { m_luaFunction = func_name; }

	void SelectYesNo(bool yes);
	void ReturnMultipleChoice(std::string choice);
	void ReturnGetPurchaseOption(int option);
	void ReturnAmountFromNumberBar(int amount);

	void EraseTopStep();

	Gui* m_Gui;

	std::unique_ptr<GumpNumberBar> m_GumpNumberBar;

	int m_npcId;
	int m_npcFrame;
	int m_secondSpeakerId;
	int m_secondSpeakerFrame;

	bool m_answerPending = false;
	bool m_waitingForAnswer = false;
	bool m_numberBarPending = false;

	std::vector<std::string> m_answers;
	std::vector<std::string> m_savedAnswers;
	std::string m_currentDialogue;
	std::string m_secondSpeakerDialogue;

	std::string m_luaFunction;

	std::vector<ConversationStep> m_steps;

	bool m_scriptFinished = false;
	bool m_conversationActive = false;
	bool m_secondSpeakerActive = false;
};

#endif
