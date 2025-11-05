#include "ColorPickerState.h"
#include "../Geist/Logging.h"
#include "../Geist/StateMachine.h"
#include "../Geist/ResourceManager.h"
#include "../Geist/Config.h"

extern std::unique_ptr<StateMachine> g_StateMachine;
extern std::unique_ptr<ResourceManager> g_ResourceManager;

ColorPickerState::~ColorPickerState()
{
}

void ColorPickerState::Init(const std::string& configfile)
{
	Log("ColorPickerState::Init");

	// Load config to get font path
	Config* config = g_ResourceManager->GetConfig("Data/ghost.cfg");
	std::string fontPath;
	if (!config)
	{
		Log("ColorPickerState: Failed to load config, using default font path");
		fontPath = "../Redist/Data/Fonts/";
	}
	else
	{
		fontPath = config->GetString("FontPath");
		if (fontPath.empty())
		{
			fontPath = "../Redist/Data/Fonts/";
			Log("ColorPickerState: FontPath not found in config, using default: " + fontPath);
		}
		else
		{
			// Ensure path ends with a separator
			if (!fontPath.empty() && fontPath.back() != '/' && fontPath.back() != '\\')
			{
				fontPath += "/";
			}
			Log("ColorPickerState: FontPath from config: " + fontPath);
		}
	}

	// Create GUI and serializer
	m_gui = std::make_unique<Gui>();
	m_gui->m_Pos = {0, 0};
	m_gui->m_AcceptingInput = true;

	m_serializer = std::make_unique<GuiSerializer>();
	m_serializer->SetBaseFontPath(fontPath);

	// Load the color picker dialog GUI
	Log("ColorPickerState: Attempting to load Gui/ghost_color_dialog.ghost");
	bool loadSuccess = m_serializer->LoadIntoPanel("Gui/ghost_color_dialog.ghost", m_gui.get(), 0, 0, -1);
	Log("ColorPickerState: LoadIntoPanel returned " + std::string(loadSuccess ? "TRUE" : "FALSE"));

	if (!loadSuccess)
	{
		Log("ERROR: Failed to load color picker dialog GUI");
	}
	else
	{
		Log("ColorPickerState: Successfully loaded dialog GUI");
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

void ColorPickerState::Shutdown()
{
	Log("ColorPickerState::Shutdown");
	m_gui.reset();
	m_serializer.reset();
}

void ColorPickerState::OnEnter()
{
	Log("ColorPickerState::OnEnter");
	m_accepted = false;

	// Set slider values based on current color
	int redSliderID = m_serializer->GetElementID("RED_SLIDER");
	int greenSliderID = m_serializer->GetElementID("GREEN_SLIDER");
	int blueSliderID = m_serializer->GetElementID("BLUE_SLIDER");
	int alphaSliderID = m_serializer->GetElementID("ALPHA_SLIDER");

	if (redSliderID != -1)
	{
		auto elem = m_gui->GetElement(redSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_selectedColor.r;
	}

	if (greenSliderID != -1)
	{
		auto elem = m_gui->GetElement(greenSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_selectedColor.g;
	}

	if (blueSliderID != -1)
	{
		auto elem = m_gui->GetElement(blueSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_selectedColor.b;
	}

	if (alphaSliderID != -1)
	{
		auto elem = m_gui->GetElement(alphaSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_selectedColor.a;
	}
}

void ColorPickerState::OnExit()
{
	Log("ColorPickerState::OnExit");
}

void ColorPickerState::Update()
{
	m_gui->Update();

	// Read slider values
	int redSliderID = m_serializer->GetElementID("RED_SLIDER");
	int greenSliderID = m_serializer->GetElementID("GREEN_SLIDER");
	int blueSliderID = m_serializer->GetElementID("BLUE_SLIDER");
	int alphaSliderID = m_serializer->GetElementID("ALPHA_SLIDER");

	if (redSliderID != -1)
	{
		auto elem = m_gui->GetElement(redSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_selectedColor.r = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	if (greenSliderID != -1)
	{
		auto elem = m_gui->GetElement(greenSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_selectedColor.g = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	if (blueSliderID != -1)
	{
		auto elem = m_gui->GetElement(blueSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_selectedColor.b = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	if (alphaSliderID != -1)
	{
		auto elem = m_gui->GetElement(alphaSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_selectedColor.a = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	// Update the color preview panel
	int previewPanelID = m_serializer->GetElementID("COLOR_PREVIEW");
	if (previewPanelID != -1)
	{
		auto elem = m_gui->GetElement(previewPanelID);
		if (elem && elem->m_Type == GUI_PANEL)
		{
			auto panel = static_cast<GuiPanel*>(elem.get());
			panel->m_Color = m_selectedColor;
		}
	}

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

void ColorPickerState::Draw()
{
	// Draw a semi-transparent overlay behind the dialog
	int screenWidth = GetScreenWidth();
	int screenHeight = GetScreenHeight();
	DrawRectangle(0, 0, screenWidth, screenHeight, Color{0, 0, 0, 128});

	// Draw the dialog GUI (includes color preview panel)
	m_gui->Draw();
}

void ColorPickerState::SetColor(Color color)
{
	m_selectedColor = color;
}
