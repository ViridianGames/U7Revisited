#include "ColorPickerState.h"
#include "../Geist/Logging.h"
#include "../Geist/StateMachine.h"
#include "../Geist/ResourceManager.h"
#include "../Geist/Config.h"
#include "../Geist/Gui.h"
#include "../Geist/GuiElements.h"

extern std::unique_ptr<StateMachine> g_StateMachine;
extern std::unique_ptr<ResourceManager> g_ResourceManager;

ColorPickerState::~ColorPickerState()
{
}

void ColorPickerState::Init(const std::string& configfile)
{
	Log("ColorPickerState::Init");

	// Create the window - it handles all config loading and GUI setup
	m_window = std::make_unique<GhostWindow>(
		"Gui/ghost_color_dialog.ghost",
		"Data/ghost.cfg",
		g_ResourceManager.get(),
		GetScreenWidth(),
		GetScreenHeight(),
		true);

	if (!m_window->GetGui())
	{
		Log("ERROR: Failed to load color picker dialog GUI");
	}
	else
	{
		Log("ColorPickerState: Successfully loaded dialog GUI");
	}
}

void ColorPickerState::Shutdown()
{
	Log("ColorPickerState::Shutdown");
	m_window.reset();
}

void ColorPickerState::OnEnter()
{
	Log("ColorPickerState::OnEnter");
	m_accepted = false;

	// Make the window visible
	m_window->Show();

	// Set slider values based on current color
	int redSliderID = m_window->GetElementID("RED_SLIDER");
	int greenSliderID = m_window->GetElementID("GREEN_SLIDER");
	int blueSliderID = m_window->GetElementID("BLUE_SLIDER");
	int alphaSliderID = m_window->GetElementID("ALPHA_SLIDER");

	Gui* gui = m_window->GetGui();
	if (!gui) return;

	if (redSliderID != -1)
	{
		auto elem = gui->GetElement(redSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_selectedColor.r;
	}

	if (greenSliderID != -1)
	{
		auto elem = gui->GetElement(greenSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_selectedColor.g;
	}

	if (blueSliderID != -1)
	{
		auto elem = gui->GetElement(blueSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			static_cast<GuiScrollBar*>(elem.get())->m_Value = m_selectedColor.b;
	}

	if (alphaSliderID != -1)
	{
		auto elem = gui->GetElement(alphaSliderID);
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
	m_window->Update();

	Gui* gui = m_window->GetGui();
	if (!gui) return;

	// Read slider values
	int redSliderID = m_window->GetElementID("RED_SLIDER");
	int greenSliderID = m_window->GetElementID("GREEN_SLIDER");
	int blueSliderID = m_window->GetElementID("BLUE_SLIDER");
	int alphaSliderID = m_window->GetElementID("ALPHA_SLIDER");

	if (redSliderID != -1)
	{
		auto elem = gui->GetElement(redSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_selectedColor.r = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	if (greenSliderID != -1)
	{
		auto elem = gui->GetElement(greenSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_selectedColor.g = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	if (blueSliderID != -1)
	{
		auto elem = gui->GetElement(blueSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_selectedColor.b = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	if (alphaSliderID != -1)
	{
		auto elem = gui->GetElement(alphaSliderID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_selectedColor.a = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	// Update the color preview panel
	int previewPanelID = m_window->GetElementID("COLOR_PREVIEW");
	if (previewPanelID != -1)
	{
		auto elem = gui->GetElement(previewPanelID);
		if (elem && elem->m_Type == GUI_PANEL)
		{
			auto panel = static_cast<GuiPanel*>(elem.get());
			panel->m_Color = m_selectedColor;
		}
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

void ColorPickerState::Draw()
{
	// Draw a semi-transparent overlay behind the dialog
	int screenWidth = GetScreenWidth();
	int screenHeight = GetScreenHeight();
	DrawRectangle(0, 0, screenWidth, screenHeight, Color{0, 0, 0, 128});

	// Draw the dialog GUI (includes color preview panel)
	m_window->Draw();

	// Draw value overlays on the color sliders
	Gui* gui = m_window->GetGui();
	if (gui)
	{
		std::vector<std::string> sliderNames = { "RED_SLIDER", "GREEN_SLIDER", "BLUE_SLIDER", "ALPHA_SLIDER" };

		for (const auto& sliderName : sliderNames)
		{
			int sliderID = m_window->GetElementID(sliderName);
			if (sliderID != -1)
			{
				auto sliderElement = gui->GetElement(sliderID);
				if (sliderElement && sliderElement->m_Type == GUI_SCROLLBAR)
				{
					auto scrollbar = static_cast<GuiScrollBar*>(sliderElement.get());

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
}

void ColorPickerState::SetColor(Color color)
{
	m_selectedColor = color;
}
