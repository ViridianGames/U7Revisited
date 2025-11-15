#include <fstream>
#include <string>

#include "LoadSaveState.h"
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

LoadSaveState::LoadSaveState()
	: m_selectedSlot(-1)
{
	// Initialize save names vector with 10 empty slots
	m_saveNames.resize(10, "");

	// This is a modal dialog - render the game world beneath it
	m_RenderStack = true;
}

LoadSaveState::~LoadSaveState()
{
}

void LoadSaveState::OnEnter()
{
	Log("LoadSaveState::OnEnter()");

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

void LoadSaveState::OnExit()
{
	Log("LoadSaveState::OnExit()");
}

void LoadSaveState::Init(const std::string& data)
{
	// Load load/save GUI from load_save.ghost file
	m_serializer = std::make_unique<GhostSerializer>();

	if (m_serializer->LoadFromFile("GUI/load_save.ghost", &m_gui))
	{
		Log("LoadSaveState::Init - Successfully loaded load_save.ghost");

		// Keep loaded fonts alive
		m_loadedFonts = m_serializer->GetLoadedFonts();

		// Center the GUI on screen
		m_serializer->CenterLoadedGUI(&m_gui, g_DrawScale);

		// Store element IDs for buttons
		m_closeButtonId = m_serializer->GetElementID("CLOSE");
		m_saveButtonId = m_serializer->GetElementID("SAVE");
		m_loadButtonId = m_serializer->GetElementID("LOAD");
		m_quitButtonId = m_serializer->GetElementID("QUIT");

		if (m_closeButtonId == -1 || m_saveButtonId == -1 || m_loadButtonId == -1 || m_quitButtonId == -1)
		{
			Log("LoadSaveState::Init - WARNING: Could not find button elements");
		}

		// Set CLOSE button as done button
		if (m_closeButtonId != -1)
		{
			m_gui.SetDoneButtonId(m_closeButtonId);
		}

		// Store element IDs for save slots
		m_slotIds[0] = m_serializer->GetElementID("SLOT1");
		m_slotIds[1] = m_serializer->GetElementID("SLOT2");
		m_slotIds[2] = m_serializer->GetElementID("SLOT3");
		m_slotIds[3] = m_serializer->GetElementID("SLOT4");
		m_slotIds[4] = m_serializer->GetElementID("SLOT5");
		m_slotIds[5] = m_serializer->GetElementID("SLOT6");
		m_slotIds[6] = m_serializer->GetElementID("SLOT7");
		m_slotIds[7] = m_serializer->GetElementID("SLOT8");
		m_slotIds[8] = m_serializer->GetElementID("SLOT9");
		m_slotIds[9] = m_serializer->GetElementID("SLOT10");

		// Check if all slots were found
		for (int i = 0; i < 10; i++)
		{
			if (m_slotIds[i] == -1)
			{
				Log("LoadSaveState::Init - WARNING: Could not find slot " + std::to_string(i));
			}
		}

		// Populate slots with test strings
		for (int i = 0; i < 10; i++)
		{
			if (m_slotIds[i] != -1)
			{
				auto element = m_gui.GetElement(m_slotIds[i]);
				if (element)
				{
					element->m_String = "Test Save " + std::to_string(i + 1);
				}
			}
		}
	}
	else
	{
		Log("LoadSaveState::Init - ERROR: Failed to load load_save.ghost");
	}

	Log("LoadSaveState::Init - Load/Save dialog initialized");
}

void LoadSaveState::Shutdown()
{
	Log("LoadSaveState::Shutdown()");
}

void LoadSaveState::Update()
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
				Log("LoadSaveState::Update - Mouse released, now accepting input");
			}
		}
		// Do NOT call Update() while waiting - skip all input processing
		return;
	}

	m_gui.Update();

	// Close dialog if user presses ESC or clicks close button
	if (IsKeyPressed(KEY_ESCAPE) || m_gui.m_isDone)
	{
		g_StateMachine->PopState();
		return;
	}

	// Detect which slot is selected (user clicked in a textinput)
	m_selectedSlot = -1;
	for (int i = 0; i < 10; i++)
	{
		if (m_slotIds[i] != -1 && m_gui.m_ActiveElement == m_slotIds[i])
		{
			m_selectedSlot = i;
			break;
		}
	}

	// Handle SAVE button click
	if (m_gui.m_ActiveElement == m_saveButtonId && m_selectedSlot != -1)
	{
		Log("LoadSaveState::Update - Save button clicked for slot " + std::to_string(m_selectedSlot));

		// TODO: Get text from selected slot textinput
		// TODO: Save game to disk with that name
		// TODO: Close dialog

		g_StateMachine->PopState();
	}

	// Handle LOAD button click
	if (m_gui.m_ActiveElement == m_loadButtonId && m_selectedSlot != -1)
	{
		Log("LoadSaveState::Update - Load button clicked for slot " + std::to_string(m_selectedSlot));

		// TODO: Load game from selected slot
		// TODO: Close dialog

		g_StateMachine->PopState();
	}

	// Handle QUIT button click
	if (m_gui.m_ActiveElement == m_quitButtonId)
	{
		Log("LoadSaveState::Update - Quit button clicked - opening exit confirmation");
		g_StateMachine->PushState(STATE_ASKEXITSTATE);
	}
}

void LoadSaveState::Draw()
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
