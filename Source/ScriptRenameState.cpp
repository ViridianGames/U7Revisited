#include "ScriptRenameState.h"
#include "Geist/Logging.h"
#include "Geist/StateMachine.h"
#include "Geist/ResourceManager.h"
#include "Geist/Engine.h"
#include "Geist/Gui.h"
#include "Geist/GuiElements.h"
#include "U7ScriptUtils.h"
#include "U7Globals.h"
#include <fstream>
#include <algorithm>

extern std::unique_ptr<StateMachine> g_StateMachine;
extern std::unique_ptr<ResourceManager> g_ResourceManager;
extern std::unique_ptr<Engine> g_Engine;

ScriptRenameState::~ScriptRenameState()
{
}

void ScriptRenameState::Init(const std::string& configfile)
{
	Log("ScriptRenameState::Init");

	// Create the window - use render dimensions since it draws in the render target
	m_window = std::make_unique<GhostWindow>(
		"Gui/script_rename_any.ghost",
		"Data/engine.cfg",
		g_ResourceManager.get(),
		g_Engine->m_RenderWidth,
		g_Engine->m_RenderHeight,
		true,          // modal
		1.0f,          // scale
		g_DrawScale);  // inputScale - converts screen coords to render coords

	if (!m_window->GetGui())
	{
		Log("ERROR: Failed to load script rename dialog GUI");
	}
	else
	{
		Log("ScriptRenameState: Successfully loaded dialog GUI");
	}
}

void ScriptRenameState::Shutdown()
{
	Log("ScriptRenameState::Shutdown");
	m_window.reset();
}

void ScriptRenameState::OnEnter()
{
	Log("ScriptRenameState::OnEnter - START");
	m_accepted = false;
	m_oldName = "";
	m_newName = "";

	// Center the dialog in render space
	int windowWidth, windowHeight;
	m_window->GetSize(windowWidth, windowHeight);
	Log("ScriptRenameState::OnEnter - window size: " + std::to_string(windowWidth) + "x" + std::to_string(windowHeight));
	int x = (g_Engine->m_RenderWidth - windowWidth) / 2;
	int y = (g_Engine->m_RenderHeight - windowHeight) / 2;
	Log("ScriptRenameState::OnEnter - moving to position: " + std::to_string(x) + ", " + std::to_string(y));
	m_window->MoveTo(x, y);

	// Make the window visible
	Log("ScriptRenameState::OnEnter - calling Show()");
	m_window->Show();
	Log("ScriptRenameState::OnEnter - Show() called, IsVisible=" + std::to_string(m_window->IsVisible()));

	// Get script name from last clicked object (barkObject tracks this)
	std::string scriptName;
	if (g_mainState && g_mainState->m_barkObject)
	{
		U7Object* obj = g_mainState->m_barkObject;
		Log("ScriptRenameState::OnEnter - barkObject: isNPC=" + std::to_string(obj->m_isNPC) +
			", NPCID=" + std::to_string(obj->m_NPCID) +
			", shape=" + std::to_string(obj->m_shapeData->GetShape()));

		// Use GetObjectScriptName which handles both NPCs and regular objects
		scriptName = GetObjectScriptName(obj);
		Log("ScriptRenameState::OnEnter - Script name: '" + scriptName + "'");
	}
	else
	{
		Log("ScriptRenameState::OnEnter - No bark object available");
	}

	// Prepopulate both fields if it's an NPC script, otherwise clear them
	Gui* gui = m_window->GetGui();
	if (!gui) return;

	// Determine what to populate the fields with
	std::string initialValue = "";
	if (!scriptName.empty() && scriptName.substr(0, 4) == "npc_")
	{
		initialValue = scriptName;
		Log("ScriptRenameState::OnEnter - Prepopulating fields with '" + scriptName + "'");
	}

	// Set ORIG_NAME
	int origNameID = m_window->GetElementID("ORIG_NAME");
	if (origNameID != -1)
	{
		auto elem = gui->GetElement(origNameID);
		if (elem && elem->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(elem.get());
			textInput->m_String = initialValue;
		}
	}

	// Set SCRIPT_NAME to the same value
	int scriptNameID = m_window->GetElementID("SCRIPT_NAME");
	if (scriptNameID != -1)
	{
		auto elem = gui->GetElement(scriptNameID);
		if (elem && elem->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(elem.get());
			textInput->m_String = initialValue;
		}
	}
}

void ScriptRenameState::OnExit()
{
	Log("ScriptRenameState::OnExit");
}

void ScriptRenameState::Update()
{
	m_window->Update();

	Gui* gui = m_window->GetGui();
	if (!gui) return;

	// Check for ENTER key (same as OK)
	bool okTriggered = IsKeyPressed(KEY_ENTER);

	// Check for ESC key (same as Cancel)
	if (IsKeyPressed(KEY_ESCAPE))
	{
		Log("ESC pressed - cancelling");
		m_accepted = false;
		g_StateMachine->PopState();
		return;
	}

	// Check for OK button click
	int okButtonID = m_window->GetElementID("OK_BUTTON");
	if (okButtonID != -1)
	{
		auto elem = gui->GetElement(okButtonID);
		if (elem && elem->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(elem.get());
			if (button->m_Clicked || okTriggered)
			{
				if (okTriggered)
					Log("ENTER pressed - accepting");
				else
					Log("OK button clicked!");

				// Read the text inputs
				int origNameID = m_window->GetElementID("ORIG_NAME");
				if (origNameID != -1)
				{
					auto elem = gui->GetElement(origNameID);
					if (elem && elem->m_Type == GUI_TEXTINPUT)
					{
						auto textInput = static_cast<GuiTextInput*>(elem.get());
						m_oldName = textInput->m_String;
					}
				}

				int scriptNameID = m_window->GetElementID("SCRIPT_NAME");
				if (scriptNameID != -1)
				{
					auto elem = gui->GetElement(scriptNameID);
					if (elem && elem->m_Type == GUI_TEXTINPUT)
					{
						auto textInput = static_cast<GuiTextInput*>(elem.get());
						m_newName = textInput->m_String;
					}
				}

				// Validate that both fields are filled
				if (m_oldName.empty() || m_newName.empty())
				{
					Log("ERROR: Both old name and new name must be provided");
					AddConsoleString("ERROR: Both old name and new name must be provided", RED);
					return;
				}

				// Check if names are identical (nothing to rename)
				if (m_oldName == m_newName)
				{
					Log("Names are identical, nothing to rename");
					g_StateMachine->PopState();
					return;
				}

				// Check if old script file exists on disk
				std::string oldPath = "Data/Scripts/" + m_oldName + ".lua";
				std::ifstream oldFile(oldPath);
				if (!oldFile.good())
				{
					Log("ERROR: Script file not found: " + oldPath);
					AddConsoleString("ERROR: Script file not found: " + m_oldName + ".lua", RED);
					return;
				}
				oldFile.close();

				// Extract number suffixes from both names
				auto extractSuffix = [](const std::string& name) -> std::string {
					size_t lastUnderscore = name.rfind('_');
					if (lastUnderscore != std::string::npos && lastUnderscore < name.length() - 1)
					{
						std::string suffix = name.substr(lastUnderscore + 1);
						// Check if suffix is all digits
						if (!suffix.empty() && std::all_of(suffix.begin(), suffix.end(), ::isdigit))
						{
							return suffix;
						}
					}
					return "";
				};

				std::string oldSuffix = extractSuffix(m_oldName);
				std::string newSuffix = extractSuffix(m_newName);

				// Both must have number suffixes and they must match
				if (oldSuffix.empty() || newSuffix.empty())
				{
					Log("ERROR: Both script names must end with _XXXX number suffix");
					AddConsoleString("ERROR: Both script names must end with _XXXX number suffix", RED);
					return;
				}

				if (oldSuffix != newSuffix)
				{
					Log("ERROR: Number suffixes don't match - old: _" + oldSuffix + ", new: _" + newSuffix);
					AddConsoleString("ERROR: Number suffixes must match! Old has _" + oldSuffix + " but new has _" + newSuffix, RED);
					return;
				}

				// Call the centralized rename function
				U7ScriptUtils::RenameScript(m_oldName, m_newName);

				m_accepted = true;
				g_StateMachine->PopState();
				return;
			}
		}
	}

	// Check for Cancel button click
	int cancelButtonID = m_window->GetElementID("CANCEL_BUTTON");
	if (cancelButtonID != -1)
	{
		auto elem = gui->GetElement(cancelButtonID);
		if (elem && elem->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(elem.get());
			if (button->m_Clicked)
			{
				Log("Cancel button clicked!");
				m_accepted = false;
				g_StateMachine->PopState();
				return;
			}
		}
	}
}

void ScriptRenameState::Draw()
{
	if (g_pixelated)
	{
		BeginTextureMode(g_renderTarget);
	}

	ClearBackground(Color{ 0, 0, 0, 255 });

	BeginDrawing();

	// Draw the 3D world using central function
	DrawWorld();

	// Handle pixelated mode render target
	if (g_pixelated)
	{
		EndTextureMode();
		DrawTexturePro(g_renderTarget.texture,
			{ 0, 0, float(g_renderTarget.texture.width), float(g_renderTarget.texture.height) },
			{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
			{ 0, 0 }, 0, WHITE);
	}

	// Draw the GUI with modal overlay
	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({ 0, 0, 0, 0 });

	// Draw semi-transparent overlay
	DrawRectangle(0, 0, g_Engine->m_RenderWidth, g_Engine->m_RenderHeight, Color{0, 0, 0, 128});

	// Draw the dialog GUI in render space
	m_window->Draw();

	// Draw console so error messages are visible
	DrawConsole();

	EndTextureMode();

	// Draw the GUI render target to screen
	DrawTexturePro(g_guiRenderTarget.texture,
		{ 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
		{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
		{ 0, 0 }, 0, WHITE);

	// Draw cursor on top of everything
	DrawTextureEx(*g_Cursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale, WHITE);

	EndDrawing();
}
