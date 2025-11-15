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
#include "GameSerializer.h"
#include "MainState.h"
#include "AskState.h"

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

	// Set slot 0 as initially selected
	m_selectedSlot = 0;

	// Populate save slots from disk
	for (int i = 0; i < 10; i++)
	{
		if (m_slotIds[i] != -1)
		{
			auto element = m_gui.GetElement(m_slotIds[i]);
			if (element)
			{
				if (GameSerializer::DoesSaveExist(i))
				{
					std::string saveName = GameSerializer::GetSaveName(i);
					element->m_String = saveName;
					m_saveNames[i] = saveName;
				}
				else
				{
					element->m_String = "empty";
					m_saveNames[i] = "";
				}
			}
		}
	}

	// Highlight the initially selected slot
	UpdateSlotHighlighting();

	// Update button visibility based on selected slot
	UpdateButtonVisibility();
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
	m_gui.Update();

	// Close dialog if user presses ESC or clicks close button
	if (IsKeyPressed(KEY_ESCAPE))
	{
		Log("LoadSaveState::Update - ESC pressed, closing dialog");
		g_StateMachine->PopState();
		return;
	}
	
	if (m_gui.m_isDone)
	{
		Log("LoadSaveState::Update - m_isDone is true, closing dialog");
		g_StateMachine->PopState();
		return;
	}
	
// Detect which slot is selected (user clicked in a textinput)
	// Only update if user clicked on a slot - persist the selection otherwise
	int previousSlot = m_selectedSlot;
	for (int i = 0; i < 10; i++)
	{
		if (m_slotIds[i] != -1 && m_gui.m_ActiveElement == m_slotIds[i])
		{
			m_selectedSlot = i;
			break;
		}
	}

	// Update highlighting if slot changed
	if (m_selectedSlot != previousSlot)
	{
		UpdateSlotHighlighting();
		UpdateButtonVisibility();
	}

	// Check if text in selected slot changed (to update button visibility)
	if (m_selectedSlot != -1 && m_slotIds[m_selectedSlot] != -1)
	{
		auto element = m_gui.GetElement(m_slotIds[m_selectedSlot]);
		if (element)
		{
			// Clear slot text if it's exactly "empt"
			if (element->m_String == "empt")
			{
				element->m_String = "";
			}

			// Update button visibility if text changed
			if (element->m_String != m_saveNames[m_selectedSlot])
			{
				m_saveNames[m_selectedSlot] = element->m_String;
				UpdateButtonVisibility();
			}
		}
	}

	// Handle SAVE button click
	if (m_gui.m_ActiveElement == m_saveButtonId && m_selectedSlot != -1)
	{
		Log("LoadSaveState::Update - Save button clicked for slot " + std::to_string(m_selectedSlot));

		// Clear active element to prevent repeated processing
		m_gui.m_ActiveElement = -1;

		// Get save name from selected slot textinput
		auto element = m_gui.GetElement(m_slotIds[m_selectedSlot]);
		if (element)
		{
			std::string saveName = element->m_String;

			// Validate save name
			if (saveName.empty() || saveName == "empty")
			{
				Log("LoadSaveState::Update - ERROR: Save name is empty");
				AddConsoleString("Please enter a save name", RED);
				return;
			}

			// Sanitize the filename (replaces reserved characters with underscores)
			std::string sanitizedName = GameSerializer::SanitizeSaveName(saveName);

			// Update textinput if the name was changed during sanitization
			if (sanitizedName != saveName)
			{
				element->m_String = sanitizedName;
				m_saveNames[m_selectedSlot] = sanitizedName;
			}

			// Check if we're overwriting an existing save with a different name
			bool isOverwriting = false;
			if (GameSerializer::DoesSaveExist(m_selectedSlot))
			{
				std::string existingSaveName = GameSerializer::GetSaveName(m_selectedSlot);
				isOverwriting = (existingSaveName != sanitizedName);
			}

			// If overwriting, show confirmation dialog
			if (isOverwriting)
			{
				Log("LoadSaveState::Update - Requesting confirmation to overwrite existing save");

				// Get the AskSaveState and set callback to perform the save
				AskState* askSaveState = dynamic_cast<AskState*>(g_StateMachine->GetState(STATE_ASKSAVESTATE));
				if (askSaveState)
				{
					// Capture values for the callback
					int slotNumber = m_selectedSlot;
					std::string nameToSave = sanitizedName;

					askSaveState->SetYesCallback([this, slotNumber, nameToSave]() {
						PerformSave(slotNumber, nameToSave);
					});

					g_StateMachine->PushState(STATE_ASKSAVESTATE);
				}
			}
			else
			{
				// No conflict, save directly
				PerformSave(m_selectedSlot, sanitizedName);
			}
		}
	}

	// Handle LOAD button click
	if (m_gui.m_ActiveElement == m_loadButtonId && m_selectedSlot != -1)
	{
		Log("LoadSaveState::Update - Load button clicked for slot " + std::to_string(m_selectedSlot));

		// Clear active element to prevent repeated processing
		m_gui.m_ActiveElement = -1;

		// Verify save exists
		if (!GameSerializer::DoesSaveExist(m_selectedSlot))
		{
			Log("LoadSaveState::Update - ERROR: No save file in slot " + std::to_string(m_selectedSlot));
			AddConsoleString("No save file in this slot", RED);
			return;
		}

		// Close all gumps before loading to prevent stale data
		g_gumpManager->CloseAllGumps();

		// Attempt to load game
		if (GameSerializer::LoadGame(m_selectedSlot))
		{
			Log("LoadSaveState::Update - Game loaded successfully from slot " + std::to_string(m_selectedSlot));

			// Trigger rebuild of game world from loaded data
			MainState* mainState = dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE));
			if (mainState)
			{
				mainState->RebuildWorldFromLoadedData();
			}

			// Pop state first (MainState::OnEnter will clear console)
			g_StateMachine->PopState();

			// Show success message AFTER PopState (MainState::OnEnter clears console)
			std::string saveName = m_saveNames[m_selectedSlot];
			if (saveName.empty())
				saveName = "slot " + std::to_string(m_selectedSlot);
			AddConsoleString("Loaded '" + saveName + "'", GREEN);
		}
		else
		{
			std::string error = GameSerializer::GetLastError();
			Log("LoadSaveState::Update - ERROR: Failed to load game - " + error);
			AddConsoleString("Load failed: " + error, RED);
		}
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

void LoadSaveState::UpdateSlotHighlighting()
{
	// Update background colors for all slots
	for (int i = 0; i < 10; i++)
	{
		if (m_slotIds[i] != -1)
		{
			auto element = m_gui.GetElement(m_slotIds[i]);
			if (element)
			{
				// Cast to GuiTextInput to access background color
				GuiTextInput* textInput = dynamic_cast<GuiTextInput*>(element.get());
				if (textInput)
				{
					// Highlighted slot gets dark brown, others get light brown
					if (i == m_selectedSlot)
					{
						textInput->m_BackgroundColor = Color{ 136, 92, 44, 255 };  // Dark brown (#885c2c)
					}
					else
					{
						textInput->m_BackgroundColor = Color{ 184, 152, 112, 255 };  // Light brown (#b89870)
					}
				}
			}
		}
	}
}

void LoadSaveState::UpdateButtonVisibility()
{
	// Get current text from selected slot
	std::string currentText = "";
	if (m_selectedSlot != -1 && m_slotIds[m_selectedSlot] != -1)
	{
		auto element = m_gui.GetElement(m_slotIds[m_selectedSlot]);
		if (element)
		{
			currentText = element->m_String;
		}
	}

	// Check if slot text is valid (not empty and not "empty")
	bool isValidText = !currentText.empty() && currentText != "empty";

	// SAVE button: visible only if text is valid
	if (m_saveButtonId != -1)
	{
		auto saveButton = m_gui.GetElement(m_saveButtonId);
		if (saveButton)
		{
			saveButton->m_Visible = isValidText;
		}
	}

	// LOAD button: visible only if save exists AND current text matches the saved filename
	if (m_loadButtonId != -1)
	{
		auto loadButton = m_gui.GetElement(m_loadButtonId);
		if (loadButton)
		{
			bool canLoad = false;
			if (isValidText && m_selectedSlot != -1 && GameSerializer::DoesSaveExist(m_selectedSlot))
			{
				// Check if current text matches the actual save name on disk
				std::string savedName = GameSerializer::GetSaveName(m_selectedSlot);
				canLoad = (currentText == savedName);
			}
			loadButton->m_Visible = canLoad;
		}
	}
}

void LoadSaveState::PerformSave(int slotNumber, const std::string& saveName)
{
	// Attempt to save game
	if (GameSerializer::SaveGame(slotNumber, saveName))
	{
		Log("LoadSaveState::PerformSave - Game saved successfully to slot " + std::to_string(slotNumber));
		AddConsoleString("Game saved as '" + saveName + "'", GREEN);
		g_StateMachine->PopState();
	}
	else
	{
		std::string error = GameSerializer::GetLastError();
		Log("LoadSaveState::PerformSave - ERROR: Failed to save game - " + error);
		AddConsoleString("Save failed: " + error, RED);
	}
}
