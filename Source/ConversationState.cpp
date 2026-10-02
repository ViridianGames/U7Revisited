#include "Geist/Globals.h"
#include "Geist/Logging.h"
#include "Geist/Gui.h"
#include "Geist/ParticleSystem.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/Engine.h"
#include "Geist/ScriptingSystem.h"
#include "../ThirdParty/raylib/include/rlgl.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "ConversationState.h"
#include <string>
#include <iomanip>
#include <cmath>
#include <fstream>
#include <algorithm>
#include <cctype>

#include "InputSystem.h"

using namespace std;

namespace
{
	constexpr int kMaxAnswersPerColumn = 8;
	constexpr float kAnswerTextX0 = 190.f;
	constexpr float kAnswerTextY0 = 135.f;
	constexpr float kAnswerBoxXPad = 6.f; // text at 190, box historically at 184
	constexpr float kAnswerBoxYPad = 5.f; // text at 135, box historically at 130
	constexpr float kColumnGap = 16.f;

	struct AnswerDrawInfo
	{
		std::string displayText;
		float x = 0.f;
		float y = 0.f;
		Rectangle hitRect{};
	};

	struct AnswerBackdrop
	{
		Rectangle box{};
		float roundness = 0.5f;
		bool valid = false;
	};

	std::string CapitalizeAnswer(const std::string& answer)
	{
		std::string capsAnswer = answer;
		if (!capsAnswer.empty() &&
		    std::isalpha(static_cast<unsigned char>(capsAnswer[0])) &&
		    std::islower(static_cast<unsigned char>(capsAnswer[0])))
		{
			capsAnswer[0] = static_cast<char>(std::toupper(static_cast<unsigned char>(capsAnswer[0])));
		}
		return capsAnswer;
	}

	// Shared by Draw and hit-testing so click boxes always match on-screen text.
	void BuildAnswerLayout(const std::vector<std::string>& answers,
	                       std::vector<AnswerDrawInfo>& outItems,
	                       AnswerBackdrop* outBackdrop = nullptr)
	{
		outItems.clear();
		if (outBackdrop != nullptr)
		{
			*outBackdrop = {};
		}

		Font* font = g_SmallFont.get();
		if (font == nullptr || answers.empty())
		{
			return;
		}

		const float fontSize = font->baseSize * 2.f;
		const float lineSpacing = font->baseSize * 2.f;
		const int count = static_cast<int>(answers.size());
		const int columnCount = (count + kMaxAnswersPerColumn - 1) / kMaxAnswersPerColumn;
		const int rowsInFirstColumn = std::min(count, kMaxAnswersPerColumn);

		outItems.resize(count);

		float columnX = kAnswerTextX0;
		float contentLeft = kAnswerTextX0;
		float contentRight = kAnswerTextX0;
		float contentBottom = kAnswerTextY0;

		for (int col = 0; col < columnCount; ++col)
		{
			const int startIdx = col * kMaxAnswersPerColumn;
			const int endIdx = std::min(startIdx + kMaxAnswersPerColumn, count);

			float maxWidth = 0.f;
			for (int i = startIdx; i < endIdx; ++i)
			{
				const std::string display = "* " + CapitalizeAnswer(answers[i]);
				const Vector2 size = MeasureTextEx(*font, display.c_str(), fontSize, 1);
				if (size.x > maxWidth)
				{
					maxWidth = size.x;
				}

				const float y = kAnswerTextY0 + static_cast<float>(i - startIdx) * lineSpacing;
				outItems[i].displayText = display;
				outItems[i].x = columnX;
				outItems[i].y = y;
				// Use full line spacing for height so rows neither gap nor overlap.
				outItems[i].hitRect = {columnX, y, size.x, lineSpacing};

				const float rowBottom = y + lineSpacing;
				if (rowBottom > contentBottom)
				{
					contentBottom = rowBottom;
				}
			}

			contentRight = columnX + maxWidth;
			columnX += maxWidth + kColumnGap;
		}

		if (outBackdrop != nullptr)
		{
			const float padX = kAnswerBoxXPad;
			const float padY = kAnswerBoxYPad;
			outBackdrop->box = {
				contentLeft - padX,
				kAnswerTextY0 - padY,
				(contentRight - contentLeft) + padX * 2.f,
				(contentBottom - kAnswerTextY0) + padY * 2.f
			};

			// Soften corners a bit as the panel gets taller / wider.
			float roundness = 0.55f - 0.03f * static_cast<float>(rowsInFirstColumn)
			                  - 0.04f * static_cast<float>(columnCount - 1);
			if (roundness < 0.12f)
			{
				roundness = 0.12f;
			}
			outBackdrop->roundness = roundness;
			outBackdrop->valid = true;
		}
	}
}

ConversationState::~ConversationState()
{
}

void ConversationState::Init(const string& configfile)
{
	m_Gui = new Gui();
	m_Gui->Init(configfile);
	m_Gui->SetLayout(0, 0, g_Engine->m_RenderWidth, g_Engine->m_RenderHeight, g_DrawScale, Gui::GUIP_USE_XY);
	m_GumpNumberBar = make_unique<GumpNumberBar>();
	m_answers.clear();
	m_steps.clear();
	m_waitingForAnswer = false;
	m_scriptFinished = false;
	m_conversationActive = false;
}

void ConversationState::OnEnter()
{
	m_answerPending = false;
	m_waitingForAnswer = false;
	m_scriptFinished = false;
	m_conversationActive = true;
	// FP mouselook locks the cursor; free it for dialogue answers.
	SetFirstPersonMouseLook(false);
}

void ConversationState::OnExit()
{
	m_answers.clear();
	m_steps.clear();
	m_answerPending = false;
	m_waitingForAnswer = false;
	m_conversationActive = false;
	m_scriptFinished = false;
	m_currentDialogue.clear();

	if (!m_luaFunction.empty())
	{
		m_luaFunction.clear();
	}

	g_ScriptingSystem->SetAnswer("nil");
}

void ConversationState::Shutdown()
{
}

void ConversationState::SaveAnswers()
{
	m_savedAnswers.clear();
	m_savedAnswers = m_answers;
}

void ConversationState::RestoreAnswers()
{
	m_answers = m_savedAnswers;
	m_savedAnswers.clear();
	m_waitingForAnswer = true; // Just in case a previous step set it to false.
}

void ConversationState::Update()
{
	if (m_steps.empty() && m_answers.empty())
	{
		g_ScriptingSystem->ResumeCoroutine(m_luaFunction, {1}); // Lua arrays are 1-indexed
		DebugPrint("No steps and no answers; conversation over.");
		if (m_steps.empty() && m_answers.empty())
		{
			g_ScriptingSystem->ResumeCoroutine(m_luaFunction, {});
			g_StateMachine->PopState();
		}
		return;
	}

	if (!m_steps.empty())
	{
		switch (m_steps[0].type)
		{
		case ConversationStepType::STEP_ADD_DIALOGUE:
			if (!m_secondSpeakerActive)
			{
				m_currentDialogue = m_steps[0].dialog;
				if (m_steps.size() == 0 && m_answers.size() > 0)
				{
					m_waitingForAnswer = true;
				}
				else
				{
					m_waitingForAnswer = false; // Can't ask for an answer until dialogue is finished.
				}
				if (!m_waitingForAnswer && g_InputSystem->WasLButtonClicked())
				{
					EraseTopStep();
				}
			}
			break;
		case ConversationStepType::STEP_CHANGE_PORTRAIT:
			m_npcId = m_steps[0].npcId;
			m_npcFrame = m_steps[0].frame;
			EraseTopStep();
			break;
		case ConversationStepType::STEP_SECOND_SPEAKER:
			m_secondSpeakerId = m_steps[0].npcId;
			m_secondSpeakerFrame = m_steps[0].frame;
			m_secondSpeakerDialogue = m_steps[0].dialog;
			m_secondSpeakerActive = true;
			m_waitingForAnswer = false;
			break;
		case ConversationStepType::STEP_MULTIPLE_CHOICE:
		case ConversationStepType::STEP_GET_PURCHASE_OPTION:
			if (!m_waitingForAnswer)
			{
				// Only replace dialogue if the new dialog is not empty
				// This allows ask_yes_no() to preserve previous dialogue
				if (!m_steps[0].dialog.empty())
				{
					m_currentDialogue = m_steps[0].dialog;
				}
				SaveAnswers();
				ClearAnswers();
				AddAnswers(m_steps[0].answers);
				m_waitingForAnswer = true;
			}
			break;
		case ConversationStepType::STEP_GET_AMOUNT_FROM_NUMBER_BAR:
			if (!m_waitingForAnswer)
			{
				SaveAnswers();
				ClearAnswers();
				m_GumpNumberBar->Setup(m_steps[0].data[0], m_steps[0].data[1], m_steps[0].data[2]);
				m_currentDialogue = m_steps[0].dialog;
				m_waitingForAnswer = true;
				m_numberBarPending = true;
			}
			break;
		case ConversationStepType::STEP_END_CONVERSATION:
			if (g_ScriptingSystem->IsCoroutineYielded(m_luaFunction))
			{
				g_ScriptingSystem->ResumeCoroutine(m_luaFunction, {});
				g_StateMachine->PopState();
			}
			break;
		}
	}
	//  We don't have a new step to process but we still have answers
	else if (!m_answers.empty())
	{
		m_waitingForAnswer = true;
	}

	if (m_secondSpeakerActive)
	{
		if (g_InputSystem->WasLButtonClicked())
		{
			EraseTopStep();
			m_secondSpeakerActive = false;
			g_ScriptingSystem->ResumeCoroutine(m_luaFunction, {}); // Lua arrays are 1-indexed
		}
	}

	if (m_waitingForAnswer)
	{
		if (!m_answerPending)
		{
			if (m_numberBarPending)
			{
				m_GumpNumberBar->Update();
				if (m_GumpNumberBar->GetIsDead())
				{
					m_numberBarPending = false;
					ReturnAmountFromNumberBar(m_GumpNumberBar->m_currentAmount);
				}
			}
			else if (g_InputSystem->WasLButtonClicked())
			{
				std::vector<AnswerDrawInfo> answerItems;
				BuildAnswerLayout(m_answers, answerItems);

				const Vector2 mousePosition = GetMousePosition();
				for (int i = 0; i < static_cast<int>(answerItems.size()); i++)
				{
					const Rectangle& guiRect = answerItems[i].hitRect;
					const Rectangle screenRect = {
						guiRect.x * g_DrawScale,
						guiRect.y * g_DrawScale,
						guiRect.width * g_DrawScale,
						guiRect.height * g_DrawScale
					};

					if (!CheckCollisionPointRec(mousePosition, screenRect))
					{
						continue;
					}

					if (m_steps.size() == 0)
					{
						SetAnswer(m_luaFunction, m_answers[i]);
						m_answerPending = true;
						m_waitingForAnswer = false;
					}
					else if (m_steps[0].type == ConversationStepType::STEP_MULTIPLE_CHOICE)
					{
						if (m_answers[i] == "Yes" || m_answers[i] == "No")
						{
							bool yes = (m_answers[i] == "Yes");
							SelectYesNo(yes);
							return;
						}

						ReturnMultipleChoice(m_answers[i]);
					}
					// Instead of the string, GET_PURCHASE_OPTION returns the index of the selected option
					else if (m_steps[0].type == ConversationStepType::STEP_GET_PURCHASE_OPTION)
					{
						ReturnGetPurchaseOption(i);
					}
					else
					{
						SetAnswer(m_luaFunction, m_answers[i]);
						m_answerPending = true;
						m_waitingForAnswer = false;
						EraseTopStep();
					}
					break;
				}
			}
		}
	}
	else if (m_scriptFinished && g_InputSystem->WasLButtonClicked())
	{
		// if (m_steps.empty())
		// {
		// 	g_StateMachine->PopState();
		// }
	}

	if (m_answerPending && g_ScriptingSystem->IsCoroutineYielded(m_luaFunction))
	{
		m_answerPending = false;
		try
		{
			std::vector<ScriptingSystem::LuaArg> args = {m_npcId};
			std::string result = g_ScriptingSystem->ResumeCoroutine(m_luaFunction, args);
			if (!result.empty() && result != "" && result.find("SCRIPT_ABORTED") == std::string::npos)
			{
				Log("Lua Error: " + result, "debuglog.txt");
			}
			m_scriptFinished = true;

			// Auto-close conversation if script forgot to call end_conversation()
			// Check if coroutine is actually finished (not just yielded again)
			if (m_conversationActive && !g_ScriptingSystem->IsCoroutineActive(m_luaFunction))
			{
				DebugPrint("Script finished without calling end_conversation(), auto-closing conversation");
				m_conversationActive = false;
				g_StateMachine->PopState();
			}
		}
		catch (const std::exception&)
		{
			// Log error
		}
	}

	if (IsKeyReleased(KEY_ESCAPE))
	{
		g_StateMachine->PopState();
	}
}

void ConversationState::Draw()
{
	// Same world path as MainState so conversation overlays match in-game look
	// (flats / deferred meshes / pixelated mode).
	DrawGameWorldFrame(true);

	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({0, 0, 0, 0});
	DrawRectangleRounded({100, 10, 500, 110}, .25, 100, {0, 0, 0, 224});

	m_Gui->Draw();

	DrawTextureEx(*g_ResourceManager->GetTexture("U7FACES" + to_string(m_npcId) + to_string(m_npcFrame)), {4, 10}, 0, 2,
	              WHITE);

	DrawParagraph(g_ConversationFont, m_currentDialogue, {115, 20}, 450,
	              g_ConversationFont.get()->baseSize, 1, YELLOW);

	if (m_secondSpeakerActive)
	{
		DrawRectangleRounded({100, 240, 500, 110}, .25, 100, {0, 0, 0, 224});
		DrawTextureEx(
			*g_ResourceManager->GetTexture("U7FACES" + to_string(m_secondSpeakerId) + to_string(m_secondSpeakerFrame)),
			{4, 240}, 0, 2, WHITE);

		DrawParagraph(g_ConversationFont, m_secondSpeakerDialogue, {115, 250}, 380,
		              g_ConversationFont.get()->baseSize, 1, YELLOW);
	}

	if (m_waitingForAnswer)
	{
		if (m_numberBarPending)
		{
			m_GumpNumberBar->Draw();
		}
		else if (!m_secondSpeakerActive)
		{
			Texture* thisTexture = nullptr;
			if (!g_Player->GetIsMale()) // Avatar is always a special case
			{
				//  I'm a pretty girl!
				thisTexture = g_ResourceManager->GetTexture("U7FACES" + to_string(0) + to_string(1));
			}
			else
			{
				thisTexture = g_ResourceManager->GetTexture("U7FACES" + to_string(0) + to_string(0));
			}

			DrawTextureEx(*thisTexture, {100, 135}, 0, 2, WHITE);

			std::vector<AnswerDrawInfo> answerItems;
			AnswerBackdrop answerBackdrop;
			BuildAnswerLayout(m_answers, answerItems, &answerBackdrop);

			if (answerBackdrop.valid)
			{
				DrawRectangleRounded(answerBackdrop.box, answerBackdrop.roundness, 100, {0, 0, 0, 224});
			}

			const float fontSize = g_SmallFont.get()->baseSize * 2.f;
			for (const AnswerDrawInfo& item : answerItems)
			{
				DrawOutlinedText(g_SmallFont, item.displayText, {item.x, item.y}, fontSize, 1, YELLOW);
			}
		}
	}

	DrawConsole();

	DrawOutlinedText(g_ConversationFont, g_version.c_str(), Vector2{600, 340}, g_ConversationFont->baseSize, 1, WHITE);

	EndTextureMode();
	DrawTexturePro(g_guiRenderTarget.texture,
	               {0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height)},
	               {
		               0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth),
		               -float(g_Engine->m_ScreenHeight)
	               },
	               {0, 0}, 0, WHITE);
}

void ConversationState::AddAnswers(std::vector<std::string> answers)
{
	for (auto& answer : answers)
	{
		if (std::find(m_answers.begin(), m_answers.end(), answer) == m_answers.end())
		{
			m_answers.push_back(answer);
		}
	}
}

void ConversationState::GetAnswers(const std::string& func_name)
{
	m_answers = g_ScriptingSystem->GetAnswers();
}

void ConversationState::RemoveAnswer(std::string answer)
{
	auto it = std::find(m_answers.begin(), m_answers.end(), answer);
	if (it == m_answers.end())
	{
		DebugPrint("Warning: Attempted to remove non-existent answer: " + answer);
		return;
	}
	auto remove_it = std::remove(m_answers.begin(), m_answers.end(), answer);
	m_answers.erase(remove_it, m_answers.end());
}

void ConversationState::SetAnswer(const std::string& func_name, const std::string& answer)
{
	g_ScriptingSystem->SetAnswer(answer);
	m_answerPending = true;
}

void ConversationState::EraseTopStep()
{
	if (!m_steps.empty())
	{
		m_steps.erase(m_steps.begin());
	}
}

void ConversationState::SelectYesNo(bool yes)
{
	if (!m_waitingForAnswer)
		return;

	m_answers = m_savedAnswers;
	m_savedAnswers.clear();
	m_waitingForAnswer = false;
	EraseTopStep();
	DebugPrint("SelectYesNo returned: " + (yes ? string("Yes") : string("No")));
	g_ScriptingSystem->ResumeCoroutine(m_luaFunction, {yes});
}

void ConversationState::ReturnMultipleChoice(std::string choice)
{
	if (!m_waitingForAnswer)
		return;

	m_answers = m_savedAnswers;
	m_savedAnswers.clear();
	m_waitingForAnswer = false;
	EraseTopStep();
	DebugPrint("ReturnMultipleChoice returned: " + choice);
	g_ScriptingSystem->ResumeCoroutine(m_luaFunction, {choice});
}

void ConversationState::ReturnGetPurchaseOption(int choice)
{
	if (!m_waitingForAnswer)
		return;

	m_answers = m_savedAnswers;
	m_savedAnswers.clear();
	m_waitingForAnswer = false;
	EraseTopStep();
	g_ScriptingSystem->ResumeCoroutine(m_luaFunction, {choice}); // Lua arrays are 1-indexed
}

void ConversationState::ReturnAmountFromNumberBar(int amount)
{
	if (!m_waitingForAnswer)
		return;

	m_answers = m_savedAnswers;
	m_savedAnswers.clear();
	m_waitingForAnswer = false;
	m_numberBarPending = false;
	EraseTopStep();
	DebugPrint("Number bar returned amount: " + to_string(amount));

	g_ScriptingSystem->ResumeCoroutine(m_luaFunction, {amount}); // Lua arrays are 1-indexed
}