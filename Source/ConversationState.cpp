#include "Geist/Globals.h"
#include "Geist/Logging.h"
#include "Geist/Gui.h"
#include "Geist/ParticleSystem.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/Engine.h"
#include "Geist/ScriptingSystem.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "ConversationState.h"
#include <string>
#include <iomanip>
#include <cmath>
#include <fstream>
#include <algorithm>

using namespace std;

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
        g_ScriptingSystem->CleanupCoroutine(m_luaFunction);
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
        g_StateMachine->PopState();
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
                if (m_steps.size() == 1 && m_answers.size() > 0)
                {
                    m_waitingForAnswer = true;
                }
                if (!m_waitingForAnswer && IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
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
            if (!m_waitingForAnswer && IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
            {
                EraseTopStep();
            }
            break;
        case ConversationStepType::STEP_MULTIPLE_CHOICE:
        case ConversationStepType::STEP_GET_PURCHASE_OPTION:
            if (!m_waitingForAnswer)
            {
                m_currentDialogue = m_steps[0].dialog;
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
        }
    }
    //  We don't have a new step to process but we still have answers
    else if (!m_answers.empty())
    {
        m_waitingForAnswer = true;
    }

    if (m_secondSpeakerActive)
    {
        if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
        {
            m_secondSpeakerActive = false;
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
            else
            {
                for (int i = 0; i < m_answers.size(); i++)
                {
                    std::string adjustedAnswer = std::string("* ") + m_answers[i];
                    Vector2 dims = MeasureTextEx(*g_SmallFont.get(), adjustedAnswer.c_str(), g_SmallFont.get()->baseSize, 1);

                    Vector2 mousePosition = GetMousePosition();
                    if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON) &&
                        CheckCollisionPointRec(mousePosition, {190 * g_DrawScale,
                                                              float((140 + (i * g_SmallFont.get()->baseSize * 1.3)) * g_DrawScale),
                                                              dims.x * g_DrawScale,
                                                              float((g_SmallFont.get()->baseSize * 1.3) * g_DrawScale)}))
                    {
                        if (m_steps.size() == 0)
                        {
                            SetAnswer(m_luaFunction, m_answers[i]);
                            m_answerPending = true;
                            m_waitingForAnswer = false;

                        }
                        else
                        {
                            if (m_steps[0].type == ConversationStepType::STEP_MULTIPLE_CHOICE)
                            {
                                if (m_answers[i] == "Yes" || m_answers[i] == "No")
                                {
                                    bool yes = (m_answers[i] == "Yes");
                                    SelectYesNo(yes);
                                    return;
                                }
                                else
                                {
                                    ReturnMultipleChoice(m_answers[i]);
                                }

                            }
                            //  Instead of the string, GET_PURCHASE_OPTION returns the index of the selected option
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
                        }
                    }
                }
            }
        }
    }
    else if (m_scriptFinished && IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
    {
        if (m_steps.empty())
        {
            g_StateMachine->PopState();
        }
    }

    if (m_answerPending && g_ScriptingSystem->IsCoroutineYielded(m_luaFunction))
    {
        m_answerPending = false;
        try
        {
            std::vector<ScriptingSystem::LuaArg> args = {m_npcId};
            std::string result = g_ScriptingSystem->ResumeCoroutine(m_luaFunction, args);
            if (!result.empty() && result != "")
            {
                Log("Lua Error: " + result, "debuglog.txt");
            }
            m_scriptFinished = true;
        }
        catch (const std::exception& e)
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
    // (Unchanged, as it’s unrelated to coroutines)
    ClearBackground(Color{0, 0, 0, 255});

    BeginDrawing();

    BeginMode3D(g_camera);
    g_Terrain->Draw();
    for (auto& unit : g_sortedVisibleObjects)
    {
        unit->Draw();
    }
    EndMode3D();

    float ratio = float(g_Engine->m_ScreenWidth) / float(g_Engine->m_RenderWidth);

    BeginTextureMode(g_guiRenderTarget);
    ClearBackground({0, 0, 0, 0});
    DrawRectangleRounded({100, 10, 500, 110}, .25, 100, {0, 0, 0, 224});

    m_Gui->Draw();

    DrawTextureEx(*g_ResourceManager->GetTexture("U7FACES" + to_string(m_npcId) + to_string(m_npcFrame)), {4, 10}, 0, 2, WHITE);

    DrawParagraph(g_ConversationFont, m_currentDialogue, {115, 20}, 450,
                  g_ConversationFont.get()->baseSize, 1, YELLOW);

    if (m_secondSpeakerActive)
    {
        DrawRectangleRounded({100, 240, 500, 110}, .25, 100, {0, 0, 0, 224});
        DrawTextureEx(*g_ResourceManager->GetTexture("U7FACES" + to_string(m_secondSpeakerId) + to_string(m_secondSpeakerFrame)), {4, 240}, 0, 2, WHITE);

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
            Texture * thisTexture = nullptr;
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
            for (int i = 0; i < m_answers.size(); i++)
            {

                DrawOutlinedText(g_SmallFont, "* " + m_answers[i], { 190, float(140 + (i * g_SmallFont.get()->baseSize * 1.3)) }, g_SmallFont.get()->baseSize, 1, YELLOW);
            }
        }
    }

    DrawConsole();

    DrawOutlinedText(g_SmallFont, g_version.c_str(), Vector2{600, 340}, g_SmallFont->baseSize, 1, WHITE);

    EndTextureMode();
    DrawTexturePro(g_guiRenderTarget.texture,
                   {0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height)},
                   {0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight)},
                   {0, 0}, 0, WHITE);

    DrawTextureEx(*g_Cursor, {float(GetMouseX()), float(GetMouseY())}, 0, g_DrawScale, WHITE);

    EndDrawing();
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
    auto it = std::remove(m_answers.begin(), m_answers.end(), answer);
    m_answers.erase(it, m_answers.end());
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

    g_ScriptingSystem->ResumeCoroutine(m_luaFunction, {amount}); // Lua arrays are 1-indexed
}
