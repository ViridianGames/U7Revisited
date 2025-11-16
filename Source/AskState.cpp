#include <fstream>
#include <string>

#include "AskState.h"
#include "Geist/Config.h"
#include "Geist/Globals.h"
#include "Geist/ResourceManager.h"
#include "Geist/Logging.h"
#include "Geist/StateMachine.h"
#include "Geist/Engine.h"
#include "U7Globals.h"

#include "raylib.h"

using namespace std;

extern std::unique_ptr<Engine> g_Engine;

AskState::AskState()
{
	// This is a modal dialog - render the game world beneath it
	m_RenderStack = true;
}

AskState::~AskState()
{
}

void AskState::OnEnter()
{
	Log("AskState::OnEnter()");

	// Disable dragging - modal system dialog should stay centered
	m_gui.m_Draggable = false;

	// Reset GUI state
	m_gui.m_isDone = false;

	// Reset mouse release tracking
	m_waitingForMouseRelease = true;
	m_releaseFrameCount = 0;

	// Disable input until mouse is released (prevents instant close from triggering click)
	m_gui.SetAcceptingInput(false);
}

void AskState::OnExit()
{
	Log("AskState::OnExit()");

	// Reset the asked to exit flag so the dialog can be shown again
	g_Engine->m_askedToExit = false;
}

void AskState::Init(const std::string& data)
{
	// Use the ghost file path if set, otherwise default to ask_exit.ghost for backward compatibility
	if (m_ghostFilePath.empty())
	{
		m_ghostFilePath = "GUI/ask_exit.ghost";
	}

	// Load question dialog GUI from ghost file
	m_serializer = std::make_unique<GhostSerializer>();

	if (m_serializer->LoadFromFile(m_ghostFilePath, &m_gui))
	{
		Log("AskState::Init - Successfully loaded " + m_ghostFilePath);

		// Keep loaded fonts alive
		m_loadedFonts = m_serializer->GetLoadedFonts();

		// Center the GUI on screen
		m_serializer->CenterLoadedGUI(&m_gui, g_DrawScale);

		// Store element IDs for buttons
		m_yesButtonId = m_serializer->GetElementID("YES");
		m_noButtonId = m_serializer->GetElementID("NO");

		if (m_yesButtonId == -1 || m_noButtonId == -1)
		{
			Log("AskState::Init - WARNING: Could not find YES/NO button elements");
		}

		// Set NO button as done button (close on NO)
		if (m_noButtonId != -1)
		{
			m_gui.SetDoneButtonId(m_noButtonId);
		}
	}
	else
	{
		Log("AskState::Init - ERROR: Failed to load " + m_ghostFilePath);
	}

	Log("AskState::Init - Question dialog initialized");
}

void AskState::Shutdown()
{
	Log("AskState::Shutdown()");
}

void AskState::Update()
{
	// Wait for mouse button to be released before accepting any input
	// We wait until we see the button is NOT down (meaning it was released)
	if (m_waitingForMouseRelease)
	{
		// Check if button is released (IsMouseButtonReleased is more reliable than checking IsMouseButtonDown)
		// Also accept if the button is simply not down anymore
		if (IsMouseButtonReleased(MOUSE_LEFT_BUTTON) || !IsMouseButtonDown(MOUSE_LEFT_BUTTON))
		{
			// Wait one more frame to be sure
			m_releaseFrameCount++;
			if (m_releaseFrameCount > 1)
			{
				m_waitingForMouseRelease = false;
				m_gui.SetAcceptingInput(true);
				Log("AskState::Update - Mouse released, now accepting input");
			}
		}
		// Do NOT call Update() while waiting - skip all input processing
		return;
	}

	m_gui.Update();

	// Close dialog if user presses ESC or clicks NO button
	if (IsKeyPressed(KEY_ESCAPE) || m_gui.m_isDone)
	{
		g_StateMachine->PopState();
		return;
	}

	// Handle YES button click
	if (m_gui.m_ActiveElement == m_yesButtonId)
	{
		Log("AskState::Update - YES button clicked");

		// Call the callback if one is set
		if (m_yesCallback)
		{
			m_yesCallback();
		}

		// Pop the state to close the dialog
		g_StateMachine->PopState();
	}
}

void AskState::Draw()
{
	// Draw the GUI with modal overlay
	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({ 0, 0, 0, 0 });

	// Draw semi-transparent overlay
	DrawRectangle(0, 0, g_Engine->m_RenderWidth, g_Engine->m_RenderHeight, Color{0, 0, 0, 128});

	// Draw the dialog GUI in render space
	m_gui.Draw();

	EndTextureMode();

	// Draw the GUI render target to screen
	DrawTexturePro(g_guiRenderTarget.texture,
		{ 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
		{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
		{ 0, 0 }, 0, WHITE);
}
