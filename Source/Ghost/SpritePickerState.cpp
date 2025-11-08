#include "SpritePickerState.h"
#include "../Geist/Logging.h"
#include "../Geist/StateMachine.h"
#include "../Geist/ResourceManager.h"
#include "../Geist/Config.h"
#include "../Geist/Gui.h"
#include "../Geist/GuiElements.h"
#include "GhostSerializer.h"
#include "SpriteUtils.h"
#include "FileChooserState.h"
#include <algorithm>

extern std::unique_ptr<StateMachine> g_StateMachine;
extern std::unique_ptr<ResourceManager> g_ResourceManager;

SpritePickerState::~SpritePickerState()
{
}

void SpritePickerState::Init(const std::string& configfile)
{
	Log("SpritePickerState::Init");

	// Create the window - it handles all config loading and GUI setup
	m_window = std::make_unique<GhostWindow>(
		"Gui/ghost_sprite_dialog.ghost",
		"Data/ghost.cfg",
		g_ResourceManager.get(),
		GetScreenWidth(),
		GetScreenHeight(),
		true);

	if (!m_window->GetGui())
	{
		Log("ERROR: Failed to load sprite picker dialog GUI");
	}
	else
	{
		Log("SpritePickerState: Successfully loaded dialog GUI");
	}
}

void SpritePickerState::Shutdown()
{
	Log("SpritePickerState::Shutdown");
	m_window.reset();
}

void SpritePickerState::OnEnter()
{
	Log("SpritePickerState::OnEnter");
	m_accepted = false;
	// DON'T reset m_waitingForFileChooser here - it needs to persist when returning from FileChooserState

	// Reload the current spritesheet from disk (in case it was edited externally)
	if (!m_filename.empty())
	{
		std::string spritePath = GhostSerializer::GetBaseSpritePath() + m_filename;
		g_ResourceManager->ReloadTexture(spritePath);
		Log("Reloaded spritesheet: " + spritePath);
	}

	// Make the window visible
	m_window->Show();

	Gui* gui = m_window->GetGui();
	if (!gui) return;

	// Set textinput value for filename
	int filenameInputID = m_window->GetElementID("SPRITE_FILENAME");
	if (filenameInputID != -1)
	{
		auto elem = gui->GetElement(filenameInputID);
		if (elem && elem->m_Type == GUI_TEXTINPUT)
			static_cast<GuiTextInput*>(elem.get())->m_String = m_filename;
	}

	// Set scrollbar values for x, y, width, height
	int xScrollbarID = m_window->GetElementID("SPRITE_X");
	if (xScrollbarID != -1)
	{
		auto elem = gui->GetElement(xScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_x;
	}

	int yScrollbarID = m_window->GetElementID("SPRITE_Y");
	if (yScrollbarID != -1)
	{
		auto elem = gui->GetElement(yScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_y;
	}

	int widthScrollbarID = m_window->GetElementID("SPRITE_WIDTH");
	if (widthScrollbarID != -1)
	{
		auto elem = gui->GetElement(widthScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_width;
	}

	int heightScrollbarID = m_window->GetElementID("SPRITE_HEIGHT");
	if (heightScrollbarID != -1)
	{
		auto elem = gui->GetElement(heightScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_height;
	}
}

void SpritePickerState::OnExit()
{
	Log("SpritePickerState::OnExit");
}

void SpritePickerState::Update()
{
	m_window->Update();

	Gui* gui = m_window->GetGui();
	if (!gui) return;

	// Check for "Open Image" button click
	int filenameButtonID = m_window->GetElementID("SPRITE_FILENAME");
	if (filenameButtonID != -1)
	{
		auto elem = gui->GetElement(filenameButtonID);
		if (elem && elem->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(elem.get());
			if (button->m_Clicked)
			{
				Log("Opening file chooser for sprite image selection");

				// Get the base sprite path for the initial directory
				std::string basePath = GhostSerializer::GetBaseSpritePath();

				// Open FileChooserState for image selection, pre-selecting current filename if we have one
				auto fileChooserState = static_cast<FileChooserState*>(g_StateMachine->GetState(3));
				fileChooserState->SetMode(false, ".png|.jpg|.jpeg|.bmp", basePath, "Select Sprite Image", m_filename);
				g_StateMachine->PushState(3);

				// Set flag so we know to check for results when we resume
				m_waitingForFileChooser = true;
				return;
			}
		}
	}

	// Check if we just returned from FileChooserState
	if (m_waitingForFileChooser)
	{
		Log("SpritePickerState: Checking file chooser results");
		m_waitingForFileChooser = false;  // Clear flag regardless of outcome

		auto fileChooserState = static_cast<FileChooserState*>(g_StateMachine->GetState(3));
		bool wasAccepted = fileChooserState->WasAccepted();
		Log("FileChooser WasAccepted: " + std::string(wasAccepted ? "true" : "false"));

		if (wasAccepted)
		{
			std::string selectedPath = fileChooserState->GetSelectedPath();
			Log("FileChooser selected path: " + selectedPath);

			if (!selectedPath.empty())
				{
					// Convert absolute path to relative path
					std::string basePath = GhostSerializer::GetBaseSpritePath();

					// Normalize paths for comparison (convert backslashes to forward slashes)
					std::string normalizedSelected = selectedPath;
					std::string normalizedBase = basePath;
					std::replace(normalizedSelected.begin(), normalizedSelected.end(), '\\', '/');
					std::replace(normalizedBase.begin(), normalizedBase.end(), '\\', '/');

					// Find the base path in the selected path
					size_t pos = normalizedSelected.find(normalizedBase);
					if (pos != std::string::npos)
					{
						// Extract relative path (everything after basePath)
						m_filename = normalizedSelected.substr(pos + normalizedBase.length());

						// Remove leading slashes
						while (!m_filename.empty() && m_filename[0] == '/')
							m_filename = m_filename.substr(1);

						Log("Selected sprite file: " + m_filename);
					}
					else
					{
						// If not in base path, just use the filename
						size_t lastSlash = normalizedSelected.find_last_of('/');
						if (lastSlash != std::string::npos)
							m_filename = normalizedSelected.substr(lastSlash + 1);
						else
							m_filename = normalizedSelected;

						Log("Selected sprite file (not in base path): " + m_filename);
				}

				// Reload the texture from disk (in case it was edited) and get its dimensions
				std::string spritePath = GhostSerializer::GetBaseSpritePath() + m_filename;
				g_ResourceManager->ReloadTexture(spritePath);
				Texture* texture = g_ResourceManager->GetTexture(spritePath);

				if (texture)
				{
					// Reset coordinates to (0,0) and size to full texture
					m_x = 0;
					m_y = 0;
					m_width = texture->width;
					m_height = texture->height;

					Log("Reset sprite coordinates to full texture: " + std::to_string(texture->width) + "x" + std::to_string(texture->height));

					// Update the SPRITE_FILENAME textinput to show the new filename
					int filenameInputID = m_window->GetElementID("SPRITE_FILENAME");
					if (filenameInputID != -1)
					{
						auto filenameElem = gui->GetElement(filenameInputID);
						if (filenameElem && filenameElem->m_Type == GUI_TEXTINPUT)
							static_cast<GuiTextInput*>(filenameElem.get())->m_String = m_filename;
					}

					// Update scrollbar values to reflect new coordinates
					int xScrollbarID = m_window->GetElementID("SPRITE_X");
					if (xScrollbarID != -1)
					{
						auto xElem = gui->GetElement(xScrollbarID);
						if (xElem && xElem->m_Type == GUI_SCROLLBAR)
							static_cast<GuiScrollBar*>(xElem.get())->m_Value = m_x;
					}

					int yScrollbarID = m_window->GetElementID("SPRITE_Y");
					if (yScrollbarID != -1)
					{
						auto yElem = gui->GetElement(yScrollbarID);
						if (yElem && yElem->m_Type == GUI_SCROLLBAR)
							static_cast<GuiScrollBar*>(yElem.get())->m_Value = m_y;
					}

					int widthScrollbarID = m_window->GetElementID("SPRITE_WIDTH");
					if (widthScrollbarID != -1)
					{
						auto wElem = gui->GetElement(widthScrollbarID);
						if (wElem && wElem->m_Type == GUI_SCROLLBAR)
							static_cast<GuiScrollBar*>(wElem.get())->m_Value = m_width;
					}

					int heightScrollbarID = m_window->GetElementID("SPRITE_HEIGHT");
					if (heightScrollbarID != -1)
					{
						auto hElem = gui->GetElement(heightScrollbarID);
						if (hElem && hElem->m_Type == GUI_SCROLLBAR)
							static_cast<GuiScrollBar*>(hElem.get())->m_Value = m_height;
					}
				}
				else
				{
					Log("ERROR: Failed to load texture for new sprite file: " + spritePath);
				}
			}
		}
	}

	// Read scrollbar values for x, y, width, height
	int xScrollbarID = m_window->GetElementID("SPRITE_X");
	if (xScrollbarID != -1)
	{
		auto elem = gui->GetElement(xScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_x = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int yScrollbarID = m_window->GetElementID("SPRITE_Y");
	if (yScrollbarID != -1)
	{
		auto elem = gui->GetElement(yScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_y = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int widthScrollbarID = m_window->GetElementID("SPRITE_WIDTH");
	if (widthScrollbarID != -1)
	{
		auto elem = gui->GetElement(widthScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_width = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int heightScrollbarID = m_window->GetElementID("SPRITE_HEIGHT");
	if (heightScrollbarID != -1)
	{
		auto elem = gui->GetElement(heightScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_height = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	// DON'T validate in real-time - let users temporarily set invalid values while adjusting sliders
	// Validation only happens when OK is clicked (line 365)

	// Update the SPRITE_PREVIEW with current values
	int previewID = m_window->GetElementID("SPRITE_PREVIEW");
	if (previewID != -1)
	{
		Log("Found SPRITE_PREVIEW element, filename: " + m_filename);

		if (!m_filename.empty())
		{
			auto previewElem = gui->GetElement(previewID);
			if (previewElem && previewElem->m_Type == GUI_SPRITE)
			{
				auto previewSprite = static_cast<GuiSprite*>(previewElem.get());

				// Load the sprite texture if not already loaded
				std::string spritePath = GhostSerializer::GetBaseSpritePath() + m_filename;
				Texture* texture = g_ResourceManager->GetTexture(spritePath);

				if (texture)
				{
					// Create a new sprite with the current rectangle
					auto sprite = std::make_shared<Sprite>(texture, m_x, m_y, m_width, m_height);

					// Update the preview sprite
					previewSprite->m_Sprite = sprite;

					// Update the GuiSprite element's size to match the sprite rectangle
					// This prevents scaling - we want to see the actual sprite at 1:1 scale
					previewSprite->m_Width = static_cast<float>(m_width);
					previewSprite->m_Height = static_cast<float>(m_height);

					// Reflow the root panel to adjust layout after size change
					// The window's serializer tracks the root element
					GhostSerializer* serializer = m_window->GetSerializer();
					if (serializer)
					{
						int rootID = serializer->GetRootElementID();
						if (rootID != -1)
						{
							serializer->ReflowPanel(rootID, gui);
						}
					}

					Log("Updated SPRITE_PREVIEW with rect: " + std::to_string(m_x) + "," + std::to_string(m_y) + "," + std::to_string(m_width) + "," + std::to_string(m_height));
				}
				else
				{
					Log("ERROR: Failed to load texture: " + spritePath);
				}
			}
			else
			{
				Log("ERROR: SPRITE_PREVIEW element not found or wrong type");
			}
		}
	}
	else
	{
		Log("ERROR: SPRITE_PREVIEW element ID not found");
	}

	// Check for OK button click
	int okButtonID = m_window->GetElementID("OK_BUTTON");
	if (okButtonID != -1)
	{
		auto elem = gui->GetElement(okButtonID);
		if (elem && elem->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(elem.get());
			if (button->m_Clicked)
			{
				Log("OK button clicked!");
				ValidateAndApplyFallbacks();
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

void SpritePickerState::Draw()
{
	// Draw a semi-transparent overlay behind the dialog
	int screenWidth = GetScreenWidth();
	int screenHeight = GetScreenHeight();
	DrawRectangle(0, 0, screenWidth, screenHeight, Color{0, 0, 0, 128});

	// Draw the dialog GUI
	m_window->Draw();

	Gui* gui = m_window->GetGui();
	if (!gui) return;

	// Draw red value text over scrollbars
	std::vector<std::string> scrollbarNames = {
		"SPRITE_X", "SPRITE_Y", "SPRITE_WIDTH", "SPRITE_HEIGHT"
	};

	for (const auto& scrollbarName : scrollbarNames)
	{
		int scrollbarID = m_window->GetElementID(scrollbarName);
		if (scrollbarID != -1)
		{
			auto scrollbarElement = gui->GetElement(scrollbarID);
			if (scrollbarElement && scrollbarElement->m_Type == GUI_SCROLLBAR)
			{
				auto scrollbar = static_cast<GuiScrollBar*>(scrollbarElement.get());

				// Calculate center position for text
				int textX = static_cast<int>(gui->m_Pos.x + scrollbar->m_Pos.x + scrollbar->m_Width / 2);
				int textY = static_cast<int>(gui->m_Pos.y + scrollbar->m_Pos.y + scrollbar->m_Height / 2 - 8);

				// Draw the value in red
				std::string valueText = std::to_string(scrollbar->m_Value);
				DrawText(valueText.c_str(), textX - MeasureText(valueText.c_str(), 16) / 2, textY, 16, RED);
			}
		}
	}
}

void SpritePickerState::SetSprite(const std::string& filename, int x, int y, int width, int height)
{
	m_filename = filename;
	m_x = x;
	m_y = y;
	m_width = width;
	m_height = height;
}

void SpritePickerState::ValidateAndApplyFallbacks()
{
	// Use the shared sprite validation utility
	SpriteUtils::ValidateAndApplyFallbacks(
		m_filename,
		m_x,
		m_y,
		m_width,
		m_height,
		GhostSerializer::GetBaseSpritePath(),
		g_ResourceManager.get()
	);
}
