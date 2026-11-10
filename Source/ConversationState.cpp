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
#include <sstream>

#include "InputSystem.h"

using namespace std;

namespace
{
	// Main dialogue panel in Draw(). Text starts 10px below the panel top.
	constexpr float kDialogueBoxX = 100.f;
	constexpr float kDialogueBoxY = 10.f;
	constexpr float kDialogueBoxW = 500.f;
	constexpr float kDialogueBoxH = 110.f;
	constexpr float kDialogueTextX = 115.f;
	constexpr float kDialogueTextY = 20.f;
	constexpr float kDialogueTextMaxWidth = 450.f;
	constexpr float kDialogueTextBottomPad = 10.f;
	// DrawParagraph steps y by fontSize * 1.2 and measures with spacing 1.
	constexpr float kDialogueLineScale = 1.2f;
	constexpr int kDialogueSpacing = 1;

	constexpr int kMaxAnswersPerColumn = 10;
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

	struct DialogueVisLine
	{
		std::string content;
		bool hardBreakBefore = false;
	};

	int DialogueLinesThatFit(float fontSize)
	{
		if (fontSize <= 0.f)
		{
			return 1;
		}

		const float limit = (kDialogueBoxY + kDialogueBoxH) - kDialogueTextBottomPad;
		const float lineAdvance = fontSize * kDialogueLineScale;
		int lines = 0;
		while (lines < 32)
		{
			const float top = kDialogueTextY + static_cast<float>(lines) * lineAdvance;
			// DrawTextEx uses y as the top. The outline extends one pixel lower.
			const float bottom = top + fontSize + 1.f;
			if (bottom > limit)
			{
				break;
			}
			++lines;
		}
		if (lines < 1)
		{
			return 1;
		}
		return lines;
	}

	// Same integer truncation as DrawParagraph's width test.
	int DialogueMeasureWidth(const std::string& text, float fontSize)
	{
		return static_cast<int>(MeasureTextEx(*g_ConversationFont, text.c_str(), fontSize, kDialogueSpacing).x);
	}

	void AppendUtf8(std::string& dest, const std::string& src, size_t& index)
	{
		if (index >= src.size())
		{
			return;
		}
		const unsigned char lead = static_cast<unsigned char>(src[index]);
		size_t len = 1;
		if ((lead & 0xE0) == 0xC0)
		{
			len = 2;
		}
		else if ((lead & 0xF0) == 0xE0)
		{
			len = 3;
		}
		else if ((lead & 0xF8) == 0xF0)
		{
			len = 4;
		}
		if (index + len > src.size())
		{
			len = 1;
		}
		dest.append(src, index, len);
		index += len;
	}

	// A token wider than the panel is broken on code points so it can wrap.
	std::vector<std::string> BreakDialogueToken(const std::string& word, float fontSize)
	{
		std::vector<std::string> parts;
		if (word.empty())
		{
			return parts;
		}
		const int maxWidth = static_cast<int>(kDialogueTextMaxWidth);
		if (DialogueMeasureWidth(word, fontSize) <= maxWidth)
		{
			parts.push_back(word);
			return parts;
		}

		std::string part;
		size_t index = 0;
		while (index < word.size())
		{
			const size_t start = index;
			std::string codepoint;
			AppendUtf8(codepoint, word, index);
			const std::string next = part + codepoint;
			if (DialogueMeasureWidth(next, fontSize) > maxWidth && !part.empty())
			{
				parts.push_back(part);
				part = word.substr(start, index - start);
			}
			else
			{
				part = next;
			}
		}
		if (!part.empty())
		{
			parts.push_back(part);
		}
		return parts;
	}

	std::vector<DialogueVisLine> WrapDialogueLines(const std::string& text, float fontSize, bool& brokeLongToken)
	{
		brokeLongToken = false;
		std::vector<DialogueVisLine> lines;
		std::istringstream paragraphs(text);
		std::string rawline;
		std::string line;
		bool firstParagraph = true;
		const int maxWidth = static_cast<int>(kDialogueTextMaxWidth);

		auto flushLine = [&](bool hardBefore)
		{
			std::string content = line;
			while (!content.empty() && content.back() == ' ')
			{
				content.pop_back();
			}
			DialogueVisLine vis;
			vis.content = std::move(content);
			vis.hardBreakBefore = hardBefore;
			lines.push_back(std::move(vis));
			line.clear();
		};

		while (std::getline(paragraphs, rawline))
		{
			if (!rawline.empty() && rawline.back() == '\r')
			{
				rawline.pop_back();
			}

			bool lineHard = !firstParagraph;
			firstParagraph = false;

			std::stringstream words(rawline);
			std::string word;
			while (words >> word)
			{
				const std::vector<std::string> parts = BreakDialogueToken(word, fontSize);
				if (parts.size() > 1)
				{
					brokeLongToken = true;
				}
				for (const std::string& part : parts)
				{
					if (!line.empty() && DialogueMeasureWidth(line + part, fontSize) > maxWidth)
					{
						flushLine(lineHard);
						lineHard = false;
					}
					line += part + " ";
				}
			}
			flushLine(lineHard);
		}
		return lines;
	}

	struct DialogueWord
	{
		std::string text;
		int newlinesBefore = 0;
		bool startsSentence = false;
	};

	bool IsSentenceCloserChar(unsigned char c)
	{
		return c == '"' || c == '\'' || c == ')' || c == ']' || c == '*' || c == '}';
	}

	bool IsAbbreviationWord(const std::string& word)
	{
		int end = static_cast<int>(word.size()) - 1;
		while (end >= 0 && IsSentenceCloserChar(static_cast<unsigned char>(word[end])))
		{
			--end;
		}
		if (end < 0 || word[end] != '.')
		{
			return false;
		}
		int start = end - 1;
		while (start >= 0 && std::isalpha(static_cast<unsigned char>(word[start])))
		{
			--start;
		}
		const std::string core = word.substr(static_cast<size_t>(start + 1), static_cast<size_t>(end - start - 1));
		std::string lower = core;
		for (char& ch : lower)
		{
			ch = static_cast<char>(std::tolower(static_cast<unsigned char>(ch)));
		}
		return lower == "mr" || lower == "mrs" || lower == "ms" || lower == "dr"
			|| lower == "st" || lower == "sr" || lower == "jr" || lower == "prof"
			|| lower == "etc" || lower == "vs";
	}

	bool WordEndsSentence(const std::string& word)
	{
		int i = static_cast<int>(word.size()) - 1;
		while (i >= 0 && IsSentenceCloserChar(static_cast<unsigned char>(word[i])))
		{
			--i;
		}
		if (i < 0)
		{
			return false;
		}
		const char mark = word[i];
		if (mark != '.' && mark != '!' && mark != '?')
		{
			return false;
		}
		if (mark == '.' && IsAbbreviationWord(word))
		{
			return false;
		}
		return true;
	}

	std::vector<DialogueWord> TokenizeDialogue(const std::string& text, float fontSize, bool& brokeLongToken)
	{
		brokeLongToken = false;
		std::vector<DialogueWord> words;
		std::istringstream paragraphs(text);
		std::string rawline;
		int newlinesBeforeNext = 0;
		bool nextStartsSentence = true;
		bool seenParagraph = false;

		while (std::getline(paragraphs, rawline))
		{
			if (!rawline.empty() && rawline.back() == '\r')
			{
				rawline.pop_back();
			}
			if (seenParagraph)
			{
				++newlinesBeforeNext;
			}
			seenParagraph = true;

			std::stringstream stream(rawline);
			std::string word;
			while (stream >> word)
			{
				const std::vector<std::string> parts = BreakDialogueToken(word, fontSize);
				if (parts.size() > 1)
				{
					brokeLongToken = true;
				}
				const bool endsSentence = WordEndsSentence(word);
				for (size_t partIndex = 0; partIndex < parts.size(); ++partIndex)
				{
					DialogueWord token;
					token.text = parts[partIndex];
					token.newlinesBefore = (partIndex == 0) ? newlinesBeforeNext : 0;
					token.startsSentence = (partIndex == 0) && nextStartsSentence;
					words.push_back(std::move(token));
					newlinesBeforeNext = 0;
				}
				nextStartsSentence = endsSentence;
			}
		}
		return words;
	}

	struct DialogueSim
	{
		std::string text;
		int closed = 0;
		std::string line;
	};

	int DialogueLinesUsed(const DialogueSim& sim)
	{
		return sim.closed + (sim.line.empty() ? 0 : 1);
	}

	// Place one word the way DrawParagraph wraps. Returns false when the word
	// would start a line past maxLines. `out` is only meaningful on success.
	bool PlaceDialogueWord(const DialogueSim& sim, const DialogueWord& word, int maxLines, float fontSize, DialogueSim& out)
	{
		out = sim;
		const int maxWidth = static_cast<int>(kDialogueTextMaxWidth);

		if (word.newlinesBefore > 0)
		{
			const bool hadOpenLine = !sim.line.empty();
			if (hadOpenLine)
			{
				out.closed += 1;
				out.line.clear();
			}
			int blanks = word.newlinesBefore;
			if (hadOpenLine && blanks > 0)
			{
				--blanks;
			}
			if (out.closed + blanks + 1 > maxLines)
			{
				return false;
			}
			for (int n = 0; n < word.newlinesBefore; ++n)
			{
				out.text.push_back('\n');
			}
			out.closed += blanks;
			out.line = word.text + " ";
			out.text += word.text;
			return true;
		}

		if (!out.line.empty() && DialogueMeasureWidth(out.line + word.text, fontSize) > maxWidth)
		{
			out.closed += 1;
			out.line.clear();
			if (out.closed + 1 > maxLines)
			{
				return false;
			}
			if (!out.text.empty() && out.text.back() != '\n')
			{
				out.text.push_back(' ');
			}
			out.text += word.text;
			out.line = word.text + " ";
			return true;
		}

		if (out.line.empty() && out.closed + 1 > maxLines)
		{
			return false;
		}

		if (!out.line.empty() && !out.text.empty() && out.text.back() != '\n')
		{
			out.text.push_back(' ');
		}
		out.text += word.text;
		out.line += word.text + " ";
		return true;
	}

	std::vector<std::string> PagesFromDialogueWords(const std::vector<DialogueWord>& words, int maxLines, float fontSize)
	{
		std::vector<std::string> pages;
		size_t index = 0;
		while (index < words.size())
		{
			const size_t pageStart = index;
			DialogueSim page;
			DialogueSim sentenceSnapshot;
			size_t sentenceStart = index;
			bool canRollBack = false;
			bool finishedPage = false;

			while (index < words.size())
			{
				const DialogueWord& word = words[index];
				if (word.startsSentence)
				{
					if (DialogueLinesUsed(page) > 0)
					{
						sentenceSnapshot = page;
						sentenceStart = index;
						canRollBack = true;
					}
					else
					{
						sentenceStart = index;
						canRollBack = false;
					}
				}

				DialogueSim next;
				if (!PlaceDialogueWord(page, word, maxLines, fontSize, next))
				{
					if (canRollBack && sentenceStart > pageStart)
					{
						page = sentenceSnapshot;
						index = sentenceStart;
					}
					else if (page.text.empty())
					{
						page.text = word.text;
						++index;
					}
					finishedPage = true;
					break;
				}

				page = std::move(next);
				++index;
			}

			if (!page.text.empty())
			{
				pages.push_back(page.text);
			}
			if (!finishedPage)
			{
				break;
			}
			if (index == pageStart)
			{
				break;
			}
		}
		return pages;
	}
}

std::vector<std::string> ConversationState::SplitDialogueToFit(const std::string& text)
{
	if (!g_ConversationFont || text.empty())
	{
		return { text };
	}

	const float fontSize = static_cast<float>(g_ConversationFont->baseSize);
	const int maxLines = DialogueLinesThatFit(fontSize);
	bool brokeLongToken = false;
	const std::vector<DialogueVisLine> lines = WrapDialogueLines(text, fontSize, brokeLongToken);
	if (!brokeLongToken && static_cast<int>(lines.size()) <= maxLines)
	{
		return { text };
	}

	brokeLongToken = false;
	const std::vector<DialogueWord> words = TokenizeDialogue(text, fontSize, brokeLongToken);
	std::vector<std::string> pages = PagesFromDialogueWords(words, maxLines, fontSize);
	if (pages.empty())
	{
		return { text };
	}
	return pages;
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
	DrawRectangleRounded({kDialogueBoxX, kDialogueBoxY, kDialogueBoxW, kDialogueBoxH}, .25, 100, {0, 0, 0, 224});

	m_Gui->Draw();

	DrawTextureEx(*g_ResourceManager->GetTexture("U7FACES" + to_string(m_npcId) + to_string(m_npcFrame)), {4, 10}, 0, 2,
	              WHITE);

	DrawParagraph(g_ConversationFont, m_currentDialogue, {kDialogueTextX, kDialogueTextY}, kDialogueTextMaxWidth,
	              g_ConversationFont.get()->baseSize, kDialogueSpacing, YELLOW);

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