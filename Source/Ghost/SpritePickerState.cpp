#include "SpritePickerState.h"
#include "../Geist/Logging.h"
#include "../Geist/StateMachine.h"
#include "../Geist/ResourceManager.h"
#include "../Geist/Config.h"
#include "SpriteUtils.h"

extern std::unique_ptr<StateMachine> g_StateMachine;
extern std::unique_ptr<ResourceManager> g_ResourceManager;

SpritePickerState::~SpritePickerState()
{
}

void SpritePickerState::Init(const std::string& configfile)
{
	Log("SpritePickerState::Init");

	// Load config to get font path
	Config* config = g_ResourceManager->GetConfig("Data/ghost.cfg");
	std::string fontPath;
	if (!config)
	{
		Log("SpritePickerState: Failed to load config, using default font path");
		fontPath = "../Redist/Data/Fonts/";
	}
	else
	{
		fontPath = config->GetString("FontPath");
		if (fontPath.empty())
		{
			fontPath = "../Redist/Data/Fonts/";
			Log("SpritePickerState: FontPath not found in config, using default: " + fontPath);
		}
		else
		{
			// Ensure path ends with a separator
			if (!fontPath.empty() && fontPath.back() != '/' && fontPath.back() != '\\')
			{
				fontPath += "/";
			}
			Log("SpritePickerState: FontPath from config: " + fontPath);
		}
	}

	// Create GUI and serializer
	m_gui = std::make_unique<Gui>();
	m_gui->m_Pos = {0, 0};
	m_gui->m_AcceptingInput = true;

	m_serializer = std::make_unique<GhostSerializer>();
	m_serializer->SetBaseFontPath(fontPath);

	// Load the sprite picker dialog GUI
	Log("SpritePickerState: Attempting to load Gui/ghost_sprite_dialog.ghost");
	bool loadSuccess = m_serializer->LoadIntoPanel("Gui/ghost_sprite_dialog.ghost", m_gui.get(), 0, 0, -1);
	Log("SpritePickerState: LoadIntoPanel returned " + std::string(loadSuccess ? "TRUE" : "FALSE"));

	if (!loadSuccess)
	{
		Log("ERROR: Failed to load sprite picker dialog GUI");
	}
	else
	{
		Log("SpritePickerState: Successfully loaded dialog GUI");
		// Log all elements to see what was loaded
		int elementCount = 0;
		for (const auto& pair : m_gui->m_GuiElementList)
		{
			const auto& elem = pair.second;
			Log("  Element ID " + std::to_string(elem->m_ID) +
				": Type=" + std::to_string(elem->m_Type) +
				", Pos=(" + std::to_string(elem->m_Pos.x) + "," + std::to_string(elem->m_Pos.y) + ")" +
				", Size=(" + std::to_string(elem->m_Width) + "x" + std::to_string(elem->m_Height) + ")" +
				", Visible=" + std::to_string(elem->m_Visible));
			elementCount++;
		}
		Log("Total elements loaded: " + std::to_string(elementCount));
	}
}

void SpritePickerState::Shutdown()
{
	Log("SpritePickerState::Shutdown");
	m_gui.reset();
	m_serializer.reset();
}

void SpritePickerState::OnEnter()
{
	Log("SpritePickerState::OnEnter");
	m_accepted = false;

	// Set textinput value for filename
	int filenameInputID = m_serializer->GetElementID("SPRITE_FILENAME");
	if (filenameInputID != -1)
	{
		auto elem = m_gui->GetElement(filenameInputID);
		if (elem && elem->m_Type == GUI_TEXTINPUT)
			static_cast<GuiTextInput*>(elem.get())->m_String = m_filename;
	}

	// Set scrollbar values for x, y, width, height
	int xScrollbarID = m_serializer->GetElementID("SPRITE_X");
	if (xScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(xScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_x;
	}

	int yScrollbarID = m_serializer->GetElementID("SPRITE_Y");
	if (yScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(yScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_y;
	}

	int widthScrollbarID = m_serializer->GetElementID("SPRITE_WIDTH");
	if (widthScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(widthScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_width;
	}

	int heightScrollbarID = m_serializer->GetElementID("SPRITE_HEIGHT");
	if (heightScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(heightScrollbarID);
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
	m_gui->Update();

	// Read filename from textinput
	int filenameInputID = m_serializer->GetElementID("SPRITE_FILENAME");
	if (filenameInputID != -1)
	{
		auto elem = m_gui->GetElement(filenameInputID);
		if (elem && elem->m_Type == GUI_TEXTINPUT)
			m_filename = static_cast<GuiTextInput*>(elem.get())->m_String;
	}

	// Read scrollbar values for x, y, width, height
	int xScrollbarID = m_serializer->GetElementID("SPRITE_X");
	if (xScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(xScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_x = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int yScrollbarID = m_serializer->GetElementID("SPRITE_Y");
	if (yScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(yScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_y = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int widthScrollbarID = m_serializer->GetElementID("SPRITE_WIDTH");
	if (widthScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(widthScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_width = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int heightScrollbarID = m_serializer->GetElementID("SPRITE_HEIGHT");
	if (heightScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(heightScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_height = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	// Validate and apply fallbacks in real-time
	ValidateAndApplyFallbacks();

	// Check for OK button click
	int okButtonID = m_serializer->GetElementID("OK_BUTTON");
	if (okButtonID != -1)
	{
		auto elem = m_gui->GetElement(okButtonID);
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
	int cancelButtonID = m_serializer->GetElementID("CANCEL_BUTTON");
	if (cancelButtonID != -1)
	{
		auto elem = m_gui->GetElement(cancelButtonID);
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
	m_gui->Draw();

	// Draw red value text over scrollbars
	std::vector<std::string> scrollbarNames = {
		"SPRITE_X", "SPRITE_Y", "SPRITE_WIDTH", "SPRITE_HEIGHT"
	};

	for (const auto& scrollbarName : scrollbarNames)
	{
		int scrollbarID = m_serializer->GetElementID(scrollbarName);
		if (scrollbarID != -1)
		{
			auto scrollbarElement = m_gui->GetElement(scrollbarID);
			if (scrollbarElement && scrollbarElement->m_Type == GUI_SCROLLBAR)
			{
				auto scrollbar = static_cast<GuiScrollBar*>(scrollbarElement.get());

				// Calculate center position for text
				int textX = static_cast<int>(m_gui->m_Pos.x + scrollbar->m_Pos.x + scrollbar->m_Width / 2);
				int textY = static_cast<int>(m_gui->m_Pos.y + scrollbar->m_Pos.y + scrollbar->m_Height / 2 - 8);

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
