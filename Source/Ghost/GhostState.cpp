#include "GhostState.h"
#include "../Geist/Globals.h"
#include "../Geist/Engine.h"
#include "../Geist/StateMachine.h"
#include "../Geist/Logging.h"
#include "../Geist/ResourceManager.h"
#include "../Geist/Config.h"
#include "ColorPickerState.h"
#include "SpritePickerState.h"
#include "FileChooserState.h"
#include "SpriteUtils.h"
#include "raylib.h"
#include <fstream>

using namespace std;

extern std::unique_ptr<StateMachine> g_StateMachine;

// Static scrollbar tracking variables (shared between Update() and FinalizeInsert())
static int lastColumnsScrollbarValue = -1;
static int lastHorzPaddingScrollbarValue = -1;
static int lastVertPaddingScrollbarValue = -1;
static int lastFontSizeScrollbarValue = -1;
static int lastWidthScrollbarValue = -1;
static int lastHeightScrollbarValue = -1;
static int lastValueRangeScrollbarValue = -1;
static int lastGroupScrollbarValue = -1;
static int lastScaleScrollbarValue = -1;
static int lastIndentScrollbarValue = -1;
static int lastTextInputWidthScrollbarValue = -1;
static int lastTextInputHeightScrollbarValue = -1;
static int lastTextInputFontSizeScrollbarValue = -1;
static bool lastVerticalCheckboxValue = false;
static bool lastCanBeHeldCheckboxValue = false;
static bool lastShadowedCheckboxValue = false;

GhostState::~GhostState()
{
}

void GhostState::Init(const std::string& configfile)
{
	Log("GhostState::Init() called");

	// Initialize state
	m_selectedElementID = -1;
	m_lastPropertyElementType = -1;
	m_hasClipboard = false;
	m_editingColorProperty = "";
	m_editingSpriteProperty = "";

	// Load config to get resource paths
	Log("Loading config from: Data/ghost.cfg");
	Config* config = g_ResourceManager->GetConfig("Data/ghost.cfg");
	if (!config)
	{
		Log("ERROR: Failed to load config!");
		m_fontPath = "Data/";
		m_spritePath = "Data/";
		GhostSerializer::SetBaseFontPath(m_fontPath);
		return;
	}

	// Try to get paths - if empty, use defaults
	m_fontPath = config->GetString("FontPath");
	m_spritePath = config->GetString("SpritePath");

	// If paths are empty, fall back to defaults
	if (m_fontPath.empty())
	{
		m_fontPath = "Data/";
		Log("FontPath not found in config, using default: " + m_fontPath);
	}
	else
	{
		// Ensure path ends with a separator
		if (!m_fontPath.empty() && m_fontPath.back() != '/' && m_fontPath.back() != '\\')
		{
			m_fontPath += "/";
		}
		Log("FontPath from config: " + m_fontPath);
	}

	if (m_spritePath.empty())
	{
		m_spritePath = "Data/";
		Log("SpritePath not found in config, using default: " + m_spritePath);
	}
	else
	{
		// Ensure path ends with a separator
		if (!m_spritePath.empty() && m_spritePath.back() != '/' && m_spritePath.back() != '\\')
		{
			m_spritePath += "/";
		}
		Log("SpritePath from config: " + m_spritePath);
	}

	// Set the resource paths in GhostSerializer so they can be used for loading
	GhostSerializer::SetBaseFontPath(m_fontPath);
	GhostSerializer::SetBaseSpritePath(m_spritePath);

	// Create the main GUI
	m_gui = make_unique<Gui>();
	m_gui->m_Pos = {0, 0};

	// Create serializer (keep it alive to preserve loaded fonts)
	m_serializer = make_unique<GhostSerializer>();

	// Load GUI from JSON file
	if (!m_serializer->LoadFromFile("Gui/ghost_app.ghost", m_gui.get()))
	{
		Log("Failed to load ghost_app.ghost");
	}

	// Initialize with empty content (creates root container)
	EnsureContentRoot();

	// Initialize property panel serializer
	// ID 3000 is the property panel container itself (defined in ghost_app.ghost)
	// Property content elements start at 3001+
	m_propertySerializer = make_unique<GhostSerializer>();
	m_propertySerializer->SetAutoIDStart(3001);
}

void GhostState::Shutdown()
{
	m_gui.reset();
}

// Helper to track initial property value when input is activated
bool GhostState::TrackPropertyValue(int activeID, const std::string& propertyName, std::string& lastValue)
{
	int inputID = m_propertySerializer->GetElementID(propertyName);
	if (activeID == inputID && inputID != -1)
	{
		auto input = m_gui->GetElement(inputID);
		if (input && input->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(input.get());
			lastValue = textInput->m_String;
			return true;
		}
	}
	return false;
}

// Helper to check if property value changed and trigger update
bool GhostState::CheckPropertyChanged(int activeID, const std::string& propertyName, std::string& lastValue)
{
	int inputID = m_propertySerializer->GetElementID(propertyName);
	if (activeID == inputID && inputID != -1)
	{
		auto input = m_gui->GetElement(inputID);
		if (input && input->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(input.get());
			if (textInput->m_String != lastValue)
			{
				lastValue = textInput->m_String;
				UpdateElementFromPropertyPanel();
				return true;
			}
		}
	}
	return false;
}

// Generic helper to check if a scrollbar property value changed
bool GhostState::CheckScrollbarChanged(const std::string& propertyName, int& lastValue)
{
	if (m_selectedElementID == -1) return false;

	int scrollbarID = m_propertySerializer->GetElementID(propertyName);
	if (scrollbarID != -1)
	{
		auto scrollbarElement = m_gui->GetElement(scrollbarID);
		if (scrollbarElement && scrollbarElement->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(scrollbarElement.get());
			if (scrollbar->m_Value != lastValue)
			{
				lastValue = scrollbar->m_Value;
				Log(propertyName + " scrollbar value changed to " + to_string(scrollbar->m_Value) + ", triggering update");
				UpdateElementFromPropertyPanel();
				return true;
			}
		}
	}
	return false;
}

// Generic helper to check if a checkbox property value changed
bool GhostState::CheckCheckboxChanged(const std::string& propertyName, bool& lastValue)
{
	if (m_selectedElementID == -1) return false;

	int checkboxID = m_propertySerializer->GetElementID(propertyName);
	if (checkboxID != -1)
	{
		auto checkboxElement = m_gui->GetElement(checkboxID);
		if (checkboxElement && checkboxElement->m_Type == GUI_CHECKBOX)
		{
			auto checkbox = static_cast<GuiCheckBox*>(checkboxElement.get());
			if (checkbox->m_Selected != lastValue)
			{
				lastValue = checkbox->m_Selected;
				Log(propertyName + " checkbox value changed to " + to_string(checkbox->m_Selected) + ", triggering update");
				UpdateElementFromPropertyPanel();
				return true;
			}
		}
	}
	return false;
}

// Generic helper to get color from any element based on property name
Color GhostState::GetElementColor(GuiElement* element, const std::string& propertyName)
{
	if (!element) return Color{0, 0, 0, 255};

	if (propertyName == "PROPERTY_TEXTCOLOR")
	{
		if (element->m_Type == GUI_TEXTAREA) return static_cast<GuiTextArea*>(element)->m_Color;
		if (element->m_Type == GUI_TEXTINPUT) return static_cast<GuiTextInput*>(element)->m_TextColor;
		if (element->m_Type == GUI_TEXTBUTTON) return static_cast<GuiTextButton*>(element)->m_TextColor;
		if (element->m_Type == GUI_ICONBUTTON) return static_cast<GuiIconButton*>(element)->m_FontColor;
		if (element->m_Type == GUI_LIST) return static_cast<GuiList*>(element)->m_TextColor;
		if (element->m_Type == GUI_LISTBOX) return static_cast<GuiListBox*>(element)->m_TextColor;
	}
	else if (propertyName == "PROPERTY_BORDERCOLOR")
	{
		if (element->m_Type == GUI_TEXTINPUT) return static_cast<GuiTextInput*>(element)->m_BoxColor;
		if (element->m_Type == GUI_TEXTBUTTON) return static_cast<GuiTextButton*>(element)->m_BorderColor;
		if (element->m_Type == GUI_LIST) return static_cast<GuiList*>(element)->m_BorderColor;
		if (element->m_Type == GUI_LISTBOX) return static_cast<GuiListBox*>(element)->m_BorderColor;
	}
	else if (propertyName == "PROPERTY_BACKGROUNDCOLOR")
	{
		if (element->m_Type == GUI_TEXTINPUT) return static_cast<GuiTextInput*>(element)->m_BackgroundColor;
		if (element->m_Type == GUI_TEXTBUTTON) return static_cast<GuiTextButton*>(element)->m_BackgroundColor;
		if (element->m_Type == GUI_SCROLLBAR) return static_cast<GuiScrollBar*>(element)->m_BackgroundColor;
		if (element->m_Type == GUI_LIST) return static_cast<GuiList*>(element)->m_BackgroundColor;
		if (element->m_Type == GUI_LISTBOX) return static_cast<GuiListBox*>(element)->m_BackgroundColor;
	}
	else if (propertyName == "PROPERTY_BACKGROUND")
	{
		if (element->m_Type == GUI_PANEL) return static_cast<GuiPanel*>(element)->m_Color;
	}
	else if (propertyName == "PROPERTY_SPURCOLOR")
	{
		if (element->m_Type == GUI_SCROLLBAR) return static_cast<GuiScrollBar*>(element)->m_SpurColor;
	}
	else if (propertyName == "PROPERTY_COLOR")
	{
		if (element->m_Type == GUI_OCTAGONBOX) return static_cast<GuiOctagonBox*>(element)->m_Color;
		if (element->m_Type == GUI_STRETCHBUTTON) return static_cast<GuiStretchButton*>(element)->m_Color;
	}

	return Color{0, 0, 0, 255};
}

// Generic helper to set color on any element based on property name
void GhostState::SetElementColor(GuiElement* element, const std::string& propertyName, Color color)
{
	if (!element) return;

	if (propertyName == "PROPERTY_TEXTCOLOR")
	{
		if (element->m_Type == GUI_TEXTAREA) static_cast<GuiTextArea*>(element)->m_Color = color;
		else if (element->m_Type == GUI_TEXTINPUT) static_cast<GuiTextInput*>(element)->m_TextColor = color;
		else if (element->m_Type == GUI_TEXTBUTTON) static_cast<GuiTextButton*>(element)->m_TextColor = color;
		else if (element->m_Type == GUI_ICONBUTTON) static_cast<GuiIconButton*>(element)->m_FontColor = color;
		else if (element->m_Type == GUI_LIST) static_cast<GuiList*>(element)->m_TextColor = color;
		else if (element->m_Type == GUI_LISTBOX) static_cast<GuiListBox*>(element)->m_TextColor = color;
	}
	else if (propertyName == "PROPERTY_BORDERCOLOR")
	{
		if (element->m_Type == GUI_TEXTINPUT) static_cast<GuiTextInput*>(element)->m_BoxColor = color;
		else if (element->m_Type == GUI_TEXTBUTTON) static_cast<GuiTextButton*>(element)->m_BorderColor = color;
		else if (element->m_Type == GUI_LIST) static_cast<GuiList*>(element)->m_BorderColor = color;
		else if (element->m_Type == GUI_LISTBOX) static_cast<GuiListBox*>(element)->m_BorderColor = color;
	}
	else if (propertyName == "PROPERTY_BACKGROUNDCOLOR")
	{
		if (element->m_Type == GUI_TEXTINPUT) static_cast<GuiTextInput*>(element)->m_BackgroundColor = color;
		else if (element->m_Type == GUI_TEXTBUTTON) static_cast<GuiTextButton*>(element)->m_BackgroundColor = color;
		else if (element->m_Type == GUI_SCROLLBAR) static_cast<GuiScrollBar*>(element)->m_BackgroundColor = color;
		else if (element->m_Type == GUI_LIST) static_cast<GuiList*>(element)->m_BackgroundColor = color;
		else if (element->m_Type == GUI_LISTBOX) static_cast<GuiListBox*>(element)->m_BackgroundColor = color;
	}
	else if (propertyName == "PROPERTY_BACKGROUND")
	{
		if (element->m_Type == GUI_PANEL) static_cast<GuiPanel*>(element)->m_Color = color;
	}
	else if (propertyName == "PROPERTY_SPURCOLOR")
	{
		if (element->m_Type == GUI_SCROLLBAR) static_cast<GuiScrollBar*>(element)->m_SpurColor = color;
	}
	else if (propertyName == "PROPERTY_COLOR")
	{
		if (element->m_Type == GUI_OCTAGONBOX) static_cast<GuiOctagonBox*>(element)->m_Color = color;
		else if (element->m_Type == GUI_STRETCHBUTTON) static_cast<GuiStretchButton*>(element)->m_Color = color;
	}
}

// Generic helper to update a color button's text color to show the current color
void GhostState::UpdateColorButton(const std::string& buttonPropertyName, Color color)
{
	int colorButtonID = m_propertySerializer->GetElementID(buttonPropertyName);
	if (colorButtonID != -1)
	{
		auto colorButton = m_gui->GetElement(colorButtonID);
		if (colorButton && colorButton->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(colorButton.get());
			button->m_TextColor = color;
			Log("Updated " + buttonPropertyName + " button text color to match element color");
		}
	}
}

// Generic helper to get group from any element
int GhostState::GetElementGroup(GuiElement* element)
{
	if (!element) return 0;

	switch (element->m_Type)
	{
	case GUI_CHECKBOX: return static_cast<GuiCheckBox*>(element)->m_Group;
	case GUI_RADIOBUTTON: return static_cast<GuiRadioButton*>(element)->m_Group;
	case GUI_ICONBUTTON: return static_cast<GuiIconButton*>(element)->m_Group;
	case GUI_OCTAGONBOX: return static_cast<GuiOctagonBox*>(element)->m_Group;
	case GUI_STRETCHBUTTON: return static_cast<GuiStretchButton*>(element)->m_Group;
	case GUI_LIST: return static_cast<GuiList*>(element)->m_Group;
	default: return 0;
	}
}

// Generic helper to set group on any element
void GhostState::SetElementGroup(GuiElement* element, int group)
{
	if (!element) return;

	switch (element->m_Type)
	{
	case GUI_CHECKBOX: static_cast<GuiCheckBox*>(element)->m_Group = group; break;
	case GUI_RADIOBUTTON: static_cast<GuiRadioButton*>(element)->m_Group = group; break;
	case GUI_ICONBUTTON: static_cast<GuiIconButton*>(element)->m_Group = group; break;
	case GUI_OCTAGONBOX: static_cast<GuiOctagonBox*>(element)->m_Group = group; break;
	case GUI_STRETCHBUTTON: static_cast<GuiStretchButton*>(element)->m_Group = group; break;
	case GUI_LIST: static_cast<GuiList*>(element)->m_Group = group; break;
	}
}

// Helper to populate group property in property panel
void GhostState::PopulateGroupProperty(GuiElement* selectedElement)
{
	if (!selectedElement) return;

	int groupInputID = m_propertySerializer->GetElementID("PROPERTY_GROUP");
	if (groupInputID != -1)
	{
		auto groupInput = m_gui->GetElement(groupInputID);
		if (groupInput && groupInput->m_Type == GUI_SCROLLBAR)
		{
			auto groupScrollbar = static_cast<GuiScrollBar*>(groupInput.get());
			int groupValue = GetElementGroup(selectedElement);
			groupScrollbar->m_Value = groupValue;
			Log("Populated PROPERTY_GROUP scrollbar with: " + to_string(groupValue));
		}
	}
}

// Helper to update group property from property panel
// Returns true if the property was updated
bool GhostState::UpdateGroupProperty(GuiElement* selectedElement)
{
	if (!selectedElement) return false;

	int groupInputID = m_propertySerializer->GetElementID("PROPERTY_GROUP");
	if (groupInputID != -1)
	{
		auto groupInput = m_gui->GetElement(groupInputID);
		if (groupInput && groupInput->m_Type == GUI_SCROLLBAR)
		{
			auto groupScrollbar = static_cast<GuiScrollBar*>(groupInput.get());
			int newGroup = groupScrollbar->m_Value;
			int currentGroup = GetElementGroup(selectedElement);
			if (newGroup != currentGroup)
			{
				SetElementGroup(selectedElement, newGroup);
				Log("Updated element " + to_string(m_selectedElementID) + " group to " + to_string(newGroup));
				return true;
			}
		}
	}
	return false;
}

// Helper to populate a scrollbar property in property panel
void GhostState::PopulateScrollbarProperty(const std::string& propertyName, int value)
{
	int propertyID = m_propertySerializer->GetElementID(propertyName);
	if (propertyID != -1)
	{
		auto propertyInput = m_gui->GetElement(propertyID);
		if (propertyInput && propertyInput->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(propertyInput.get());
			scrollbar->m_Value = value;
			Log("Populated " + propertyName + " scrollbar with: " + to_string(value));
		}
	}
}

// Helper to update a scrollbar property from property panel
// Returns true if the property was updated
bool GhostState::UpdateScrollbarProperty(const std::string& propertyName, int& outValue)
{
	int propertyID = m_propertySerializer->GetElementID(propertyName);
	if (propertyID != -1)
	{
		auto propertyInput = m_gui->GetElement(propertyID);
		if (propertyInput && propertyInput->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(propertyInput.get());
			int newValue = scrollbar->m_Value;
			if (newValue != outValue)
			{
				outValue = newValue;
				Log("Updated " + propertyName + " to: " + to_string(newValue));
				return true;
			}
		}
	}
	return false;
}

// Helper to populate a text input property in property panel
void GhostState::PopulateTextInputProperty(const std::string& propertyName, const std::string& value)
{
	int propertyID = m_propertySerializer->GetElementID(propertyName);
	if (propertyID != -1)
	{
		auto propertyInput = m_gui->GetElement(propertyID);
		if (propertyInput && propertyInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(propertyInput.get());
			textInput->m_String = value;
			Log("Populated " + propertyName + " text input with: " + value);
		}
	}
}

// Helper to update a text input property from property panel
// Returns true if the property was updated
bool GhostState::UpdateTextInputProperty(const std::string& propertyName, std::string& outValue)
{
	int propertyID = m_propertySerializer->GetElementID(propertyName);
	if (propertyID != -1)
	{
		auto propertyInput = m_gui->GetElement(propertyID);
		if (propertyInput && propertyInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(propertyInput.get());
			if (textInput->m_String != outValue)
			{
				outValue = textInput->m_String;
				Log("Updated " + propertyName + " to: " + outValue);
				return true;
			}
		}
	}
	return false;
}

// Helper to populate a checkbox property in property panel
void GhostState::PopulateCheckboxProperty(const std::string& propertyName, bool value)
{
	int propertyID = m_propertySerializer->GetElementID(propertyName);
	if (propertyID != -1)
	{
		auto propertyInput = m_gui->GetElement(propertyID);
		if (propertyInput && propertyInput->m_Type == GUI_CHECKBOX)
		{
			auto checkbox = static_cast<GuiCheckBox*>(propertyInput.get());
			checkbox->m_Selected = value;
			Log("Populated " + propertyName + " checkbox with: " + to_string(value));
		}
	}
}

// Helper to update a checkbox property from property panel
// Returns true if the property was updated
bool GhostState::UpdateCheckboxProperty(const std::string& propertyName, bool& outValue)
{
	int propertyID = m_propertySerializer->GetElementID(propertyName);
	if (propertyID != -1)
	{
		auto propertyInput = m_gui->GetElement(propertyID);
		if (propertyInput && propertyInput->m_Type == GUI_CHECKBOX)
		{
			auto checkbox = static_cast<GuiCheckBox*>(propertyInput.get());
			if (checkbox->m_Selected != outValue)
			{
				outValue = checkbox->m_Selected;
				Log("Updated " + propertyName + " to: " + to_string(outValue));
				return true;
			}
		}
	}
	return false;
}

// Helper to update name property from property panel
// Returns true if the property was updated
bool GhostState::UpdateNameProperty()
{
	int nameInputID = m_propertySerializer->GetElementID("PROPERTY_NAME");
	if (nameInputID != -1 && m_selectedElementID != -1)
	{
		auto nameInput = m_gui->GetElement(nameInputID);
		if (nameInput && nameInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(nameInput.get());
			std::string newName = textInput->m_String;
			std::string oldName = GetElementName(m_selectedElementID);

			// Only update if name actually changed
			if (newName != oldName)
			{
				Log("UpdateNameProperty: element " + to_string(m_selectedElementID) + " changing name from '" + oldName + "' to '" + newName + "'");

				// Remove old name mapping if it exists
				if (!oldName.empty())
				{
					m_contentSerializer->RemoveElementName(oldName);
				}

				// Set new name mapping if not empty
				if (!newName.empty())
				{
					m_contentSerializer->SetElementName(newName, m_selectedElementID);
				}

				return true;
			}
		}
	}
	return false;
}

// Helper to populate font property in property panel
void GhostState::PopulateFontProperty()
{
	int fontInputID = m_propertySerializer->GetElementID("PROPERTY_FONT");
	if (fontInputID != -1)
	{
		auto fontInput = m_gui->GetElement(fontInputID);
		if (fontInput && fontInput->m_Type == GUI_TEXTINPUT)
		{
			std::string font = m_contentSerializer->GetElementFont(m_selectedElementID);
			auto textInput = static_cast<GuiTextInput*>(fontInput.get());
			textInput->m_String = font;
			Log("Populated PROPERTY_FONT with: " + font);
		}
	}
}

// Helper to populate font size property in property panel
void GhostState::PopulateFontSizeProperty()
{
	int fontSizeInputID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
	if (fontSizeInputID != -1)
	{
		auto fontSizeInput = m_gui->GetElement(fontSizeInputID);
		int fontSize = m_contentSerializer->GetElementFontSize(m_selectedElementID);

		if (fontSizeInput && fontSizeInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(fontSizeInput.get());
			if (fontSize != 0)
			{
				textInput->m_String = to_string(fontSize);
			}
			else
			{
				textInput->m_String = "";
			}
			Log("Populated PROPERTY_FONT_SIZE with: " + to_string(fontSize));
		}
		else if (fontSizeInput && fontSizeInput->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(fontSizeInput.get());
			if (fontSize != 0)
			{
				scrollbar->m_Value = fontSize;
			}
			else
			{
				scrollbar->m_Value = 0;
			}
			Log("Populated PROPERTY_FONT_SIZE scrollbar with: " + to_string(fontSize));
		}
	}
}

// Helper to update font property from property panel
// Returns true if the property was updated
bool GhostState::UpdateFontProperty()
{
	int fontInputID = m_propertySerializer->GetElementID("PROPERTY_FONT");
	if (fontInputID != -1 && m_selectedElementID != -1)
	{
		auto fontInput = m_gui->GetElement(fontInputID);
		if (fontInput && fontInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(fontInput.get());
			std::string newFont = textInput->m_String;
			std::string oldFont = m_contentSerializer->GetElementFont(m_selectedElementID);

			if (newFont != oldFont)
			{
				auto selectedElement = m_gui->GetElement(m_selectedElementID);
				if (selectedElement)
				{
					int oldFontSize = m_contentSerializer->GetElementFontSize(m_selectedElementID);
					if (oldFontSize == 0) oldFontSize = 16;

					std::string fontPath = m_fontPath + newFont;
					auto newFontPtr = std::make_shared<Font>(LoadFontEx(fontPath.c_str(), oldFontSize, 0, 0));

					// Update font based on element type
					Font* fontPtr = newFontPtr.get();
					switch (selectedElement->m_Type)
					{
					case GUI_TEXTBUTTON:
					{
						auto textbutton = static_cast<GuiTextButton*>(selectedElement.get());
						textbutton->m_Font = fontPtr;
						// Recalculate textbutton dimensions with new font
						Vector2 textDims = MeasureTextEx(*textbutton->m_Font, textbutton->m_String.c_str(), textbutton->m_Font->baseSize, 1);
						textbutton->m_Width = textDims.x;
						textbutton->m_Height = textDims.y;
						break;
					}
					case GUI_ICONBUTTON:
						static_cast<GuiIconButton*>(selectedElement.get())->m_Font = fontPtr;
						break;
					case GUI_TEXTINPUT:
					{
						auto textinput = static_cast<GuiTextInput*>(selectedElement.get());
						textinput->m_Font = fontPtr;
						// Recalculate textinput height to accommodate new font size
						// Height should be at least the font baseSize plus some padding
						float minHeight = static_cast<float>(textinput->m_Font->baseSize) + 4.0f;  // Add small padding
						if (textinput->m_Height < minHeight)
						{
							textinput->m_Height = minHeight;

							// Update the PROPERTY_HEIGHT scrollbar to reflect the new height
							int heightScrollbarID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
							if (heightScrollbarID != -1)
							{
								auto heightElem = m_gui->GetElement(heightScrollbarID);
								if (heightElem && heightElem->m_Type == GUI_SCROLLBAR)
								{
									static_cast<GuiScrollBar*>(heightElem.get())->m_Value = static_cast<int>(minHeight);
								}
							}
						}
						break;
					}
					case GUI_PANEL:
						static_cast<GuiPanel*>(selectedElement.get())->m_Font = fontPtr;
						break;
					case GUI_TEXTAREA:
					{
						auto textarea = static_cast<GuiTextArea*>(selectedElement.get());
						textarea->m_Font = fontPtr;
						// Recalculate textarea dimensions with new font
						Vector2 textDims = MeasureTextEx(*textarea->m_Font, textarea->m_String.c_str(), textarea->m_Font->baseSize, 1);
						textarea->m_Width = textDims.x;
						textarea->m_Height = textDims.y;

						// Update the PROPERTY_WIDTH and PROPERTY_HEIGHT scrollbars to reflect the new dimensions
						int widthScrollbarID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
						if (widthScrollbarID != -1)
						{
							auto widthElem = m_gui->GetElement(widthScrollbarID);
							if (widthElem && widthElem->m_Type == GUI_SCROLLBAR)
							{
								static_cast<GuiScrollBar*>(widthElem.get())->m_Value = static_cast<int>(textarea->m_Width);
							}
						}

						int heightScrollbarID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
						if (heightScrollbarID != -1)
						{
							auto heightElem = m_gui->GetElement(heightScrollbarID);
							if (heightElem && heightElem->m_Type == GUI_SCROLLBAR)
							{
								static_cast<GuiScrollBar*>(heightElem.get())->m_Value = static_cast<int>(textarea->m_Height);
							}
						}
						break;
					}
					case GUI_LIST:
						static_cast<GuiList*>(selectedElement.get())->m_Font = fontPtr;
						break;
					case GUI_LISTBOX:
					{
						auto listbox = static_cast<GuiListBox*>(selectedElement.get());
						listbox->m_Font = fontPtr;
						// Recalculate item height and visible item count based on new font
						listbox->m_ItemHeight = fontPtr->baseSize + 4;  // Add padding
						listbox->m_VisibleItemCount = static_cast<int>(listbox->m_Height / listbox->m_ItemHeight);
						break;
					}
					default:
						return false; // Element type doesn't support fonts
					}

					m_preservedFonts.push_back(newFontPtr);
					m_contentSerializer->SetElementFont(m_selectedElementID, newFont);

					Log("Updated element " + to_string(m_selectedElementID) + " font to: " + newFont);
					return true;
				}
			}
		}
	}
	return false;
}

// Helper to update font size property from property panel
// Returns true if the property was updated
bool GhostState::UpdateFontSizeProperty()
{
	int fontSizeInputID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
	if (fontSizeInputID != -1 && m_selectedElementID != -1)
	{
		auto fontSizeInput = m_gui->GetElement(fontSizeInputID);
		int newFontSize = 0;

		if (fontSizeInput && fontSizeInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(fontSizeInput.get());
			try
			{
				newFontSize = std::stoi(textInput->m_String);
			}
			catch (...)
			{
				return false;
			}
		}
		else if (fontSizeInput && fontSizeInput->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(fontSizeInput.get());
			newFontSize = scrollbar->m_Value;
		}

		if (newFontSize > 0)
		{
			int oldFontSize = m_contentSerializer->GetElementFontSize(m_selectedElementID);
			if (newFontSize != oldFontSize)
			{
				auto selectedElement = m_gui->GetElement(m_selectedElementID);
				if (selectedElement)
				{
					std::string fontName = m_contentSerializer->GetElementFont(m_selectedElementID);
					if (fontName.empty()) fontName = "babyblocks.ttf";

					std::string fontPath = m_fontPath + fontName;
					auto newFontPtr = std::make_shared<Font>(LoadFontEx(fontPath.c_str(), newFontSize, 0, 0));

					// Update font based on element type
					Font* fontPtr = newFontPtr.get();
					switch (selectedElement->m_Type)
					{
					case GUI_TEXTBUTTON:
					{
						auto textbutton = static_cast<GuiTextButton*>(selectedElement.get());
						textbutton->m_Font = fontPtr;
						// Recalculate textbutton dimensions with new font
						Vector2 textDims = MeasureTextEx(*textbutton->m_Font, textbutton->m_String.c_str(), textbutton->m_Font->baseSize, 1);
						textbutton->m_Width = textDims.x;
						textbutton->m_Height = textDims.y;
						break;
					}
					case GUI_ICONBUTTON:
						static_cast<GuiIconButton*>(selectedElement.get())->m_Font = fontPtr;
						break;
					case GUI_TEXTINPUT:
					{
						auto textinput = static_cast<GuiTextInput*>(selectedElement.get());
						textinput->m_Font = fontPtr;
						// Recalculate textinput height to accommodate new font size
						// Height should be at least the font baseSize plus some padding
						float minHeight = static_cast<float>(textinput->m_Font->baseSize) + 4.0f;  // Add small padding
						if (textinput->m_Height < minHeight)
						{
							textinput->m_Height = minHeight;

							// Update the PROPERTY_HEIGHT scrollbar to reflect the new height
							int heightScrollbarID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
							if (heightScrollbarID != -1)
							{
								auto heightElem = m_gui->GetElement(heightScrollbarID);
								if (heightElem && heightElem->m_Type == GUI_SCROLLBAR)
								{
									static_cast<GuiScrollBar*>(heightElem.get())->m_Value = static_cast<int>(minHeight);
								}
							}
						}
						break;
					}
					case GUI_PANEL:
						static_cast<GuiPanel*>(selectedElement.get())->m_Font = fontPtr;
						break;
					case GUI_TEXTAREA:
					{
						auto textarea = static_cast<GuiTextArea*>(selectedElement.get());
						textarea->m_Font = fontPtr;
						// Recalculate textarea dimensions with new font size
						Vector2 textDims = MeasureTextEx(*textarea->m_Font, textarea->m_String.c_str(), textarea->m_Font->baseSize, 1);
						textarea->m_Width = textDims.x;
						textarea->m_Height = textDims.y;

						// Update the PROPERTY_WIDTH and PROPERTY_HEIGHT scrollbars to reflect the new dimensions
						int widthScrollbarID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
						if (widthScrollbarID != -1)
						{
							auto widthElem = m_gui->GetElement(widthScrollbarID);
							if (widthElem && widthElem->m_Type == GUI_SCROLLBAR)
							{
								static_cast<GuiScrollBar*>(widthElem.get())->m_Value = static_cast<int>(textarea->m_Width);
							}
						}

						int heightScrollbarID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
						if (heightScrollbarID != -1)
						{
							auto heightElem = m_gui->GetElement(heightScrollbarID);
							if (heightElem && heightElem->m_Type == GUI_SCROLLBAR)
							{
								static_cast<GuiScrollBar*>(heightElem.get())->m_Value = static_cast<int>(textarea->m_Height);
							}
						}
						break;
					}
					case GUI_LIST:
						static_cast<GuiList*>(selectedElement.get())->m_Font = fontPtr;
						break;
					case GUI_LISTBOX:
					{
						auto listbox = static_cast<GuiListBox*>(selectedElement.get());
						listbox->m_Font = fontPtr;
						// Recalculate item height and visible item count based on new font
						listbox->m_ItemHeight = fontPtr->baseSize + 4;  // Add padding
						listbox->m_VisibleItemCount = static_cast<int>(listbox->m_Height / listbox->m_ItemHeight);
						break;
					}
					default:
						return false; // Element type doesn't support fonts
					}

					m_preservedFonts.push_back(newFontPtr);
					m_contentSerializer->SetElementFontSize(m_selectedElementID, newFontSize);

					Log("Updated element " + to_string(m_selectedElementID) + " font size to: " + to_string(newFontSize));
					return true;
				}
			}
		}
	}
	return false;
}

// Generic helper to update element width from PROPERTY_WIDTH scrollbar
bool GhostState::UpdateWidthProperty(GuiElement* element)
{
	if (!element) return false;

	int widthInputID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
	if (widthInputID != -1)
	{
		auto widthInput = m_gui->GetElement(widthInputID);
		if (widthInput && widthInput->m_Type == GUI_SCROLLBAR)
		{
			auto widthScrollbar = static_cast<GuiScrollBar*>(widthInput.get());
			int newWidth = widthScrollbar->m_Value;
			if (newWidth > 0 && newWidth != static_cast<int>(element->m_Width))
			{
				element->m_Width = static_cast<float>(newWidth);
				Log("Updated element " + to_string(m_selectedElementID) + " width to " + to_string(newWidth));
				return true;
			}
		}
	}
	return false;
}

// Generic helper to update element height from PROPERTY_HEIGHT scrollbar
bool GhostState::UpdateHeightProperty(GuiElement* element)
{
	if (!element) return false;

	int heightInputID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
	if (heightInputID != -1)
	{
		auto heightInput = m_gui->GetElement(heightInputID);
		if (heightInput && heightInput->m_Type == GUI_SCROLLBAR)
		{
			auto heightScrollbar = static_cast<GuiScrollBar*>(heightInput.get());
			int newHeight = heightScrollbar->m_Value;
			if (newHeight > 0 && newHeight != static_cast<int>(element->m_Height))
			{
				element->m_Height = static_cast<float>(newHeight);
				Log("Updated element " + to_string(m_selectedElementID) + " height to " + to_string(newHeight));
				return true;
			}
		}
	}
	return false;
}

// Generic helper to read an int value from either a textinput or scrollbar property
bool GhostState::ReadIntProperty(const std::string& propertyName, int& outValue)
{
	int propertyID = m_propertySerializer->GetElementID(propertyName);
	if (propertyID != -1)
	{
		auto propertyInput = m_gui->GetElement(propertyID);
		if (propertyInput && propertyInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(propertyInput.get());
			try
			{
				if (!textInput->m_String.empty())
				{
					outValue = std::stoi(textInput->m_String);
					return true;
				}
			}
			catch (...)
			{
				outValue = 0;
				return false;
			}
		}
		else if (propertyInput && propertyInput->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(propertyInput.get());
			outValue = scrollbar->m_Value;
			return true;
		}
	}
	return false;
}

// Generic helper to populate an int value to either a textinput or scrollbar property
void GhostState::PopulateIntProperty(const std::string& propertyName, int value)
{
	int propertyID = m_propertySerializer->GetElementID(propertyName);
	if (propertyID != -1)
	{
		auto propertyInput = m_gui->GetElement(propertyID);
		if (propertyInput && propertyInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(propertyInput.get());
			textInput->m_String = to_string(value);
			Log("Populated " + propertyName + " with: " + to_string(value));
		}
		else if (propertyInput && propertyInput->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(propertyInput.get());
			scrollbar->m_Value = value;
			Log("Populated " + propertyName + " scrollbar with: " + to_string(value));
		}
	}
}

void GhostState::Update()
{
	m_gui->Update();

	int activeID = m_gui->GetActiveElementID();

	// Update element properties when property panel inputs change
	// Only update if a property panel element just became active (was clicked/interacted with)
	static int lastActiveID = -1;
	static std::string lastNameValue = "";
	static std::string lastColumnsValue = "";
	static std::string lastSpriteValue = "";
	static std::string lastTextValue = "";
	static std::string lastHorzPaddingValue = "";
	static std::string lastVertPaddingValue = "";
	static std::string lastFontValue = "";
	static std::string lastFontSizeValue = "";

	// Check if a property panel radio button was clicked and update element
	// This MUST be checked BEFORE the early return below
	static int lastRadioActiveID = -1;
	if (activeID >= 3000)
	{
		auto element = m_gui->GetElement(activeID);
		if (element && element->m_Type == GUI_RADIOBUTTON)
		{
			if (activeID != lastRadioActiveID)
			{
				lastRadioActiveID = activeID;
				UpdateElementFromPropertyPanel();
			}
		}
		else
		{
			// Reset when clicking non-radio property panel elements
			lastRadioActiveID = -1;
		}
	}
	else if (activeID < 3000)
	{
		lastRadioActiveID = -1;
	}

	// Handle scrollbar updates (they update continuously while being dragged)
	// Note: Scrollbars don't set themselves as active elements, so we just check for value changes
	// (Static variables are declared at file scope)

	// Check property scrollbars for changes
	CheckScrollbarChanged("PROPERTY_COLUMNS", lastColumnsScrollbarValue);
	CheckScrollbarChanged("PROPERTY_HORZ_PADDING", lastHorzPaddingScrollbarValue);
	CheckScrollbarChanged("PROPERTY_VERT_PADDING", lastVertPaddingScrollbarValue);
	CheckScrollbarChanged("PROPERTY_FONT_SIZE", lastFontSizeScrollbarValue);
	CheckScrollbarChanged("PROPERTY_WIDTH", lastWidthScrollbarValue);
	CheckScrollbarChanged("PROPERTY_HEIGHT", lastHeightScrollbarValue);
	CheckScrollbarChanged("PROPERTY_VALUE_RANGE", lastValueRangeScrollbarValue);
	CheckScrollbarChanged("PROPERTY_GROUP", lastGroupScrollbarValue);
	CheckScrollbarChanged("PROPERTY_SCALE", lastScaleScrollbarValue);
	CheckScrollbarChanged("PROPERTY_INDENT", lastIndentScrollbarValue);

	// Check property checkboxes for changes
	CheckCheckboxChanged("PROPERTY_VERTICAL", lastVerticalCheckboxValue);
	CheckCheckboxChanged("PROPERTY_CANBEHELD", lastCanBeHeldCheckboxValue);
	CheckCheckboxChanged("PROPERTY_SHADOWED", lastShadowedCheckboxValue);

	// Check PROPERTY_FONT_SIZE scrollbar for textinput elements
	// Note: Font size for other elements (textbutton, panel) uses lastFontSizeScrollbarValue tracked elsewhere
	if (m_selectedElementID != -1)
	{
		auto selectedElement = m_gui->GetElement(m_selectedElementID);
		if (selectedElement && selectedElement->m_Type == GUI_TEXTINPUT)
		{
			int fontSizeScrollbarID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
			if (fontSizeScrollbarID != -1)
			{
				auto fontSizeElement = m_gui->GetElement(fontSizeScrollbarID);
				if (fontSizeElement && fontSizeElement->m_Type == GUI_SCROLLBAR)
				{
					auto scrollbar = static_cast<GuiScrollBar*>(fontSizeElement.get());
					if (scrollbar->m_Value != lastTextInputFontSizeScrollbarValue)
					{
						lastTextInputFontSizeScrollbarValue = scrollbar->m_Value;
						Log("TextInput font size scrollbar value changed to " + to_string(scrollbar->m_Value) + ", triggering update");
						UpdateElementFromPropertyPanel();
					}
				}
			}
		}
	}

	// Generic color button click handler - checks all color property buttons
	if (m_selectedElementID != -1)
	{
		auto selectedElement = m_gui->GetElement(m_selectedElementID);
		if (selectedElement)
		{
			// List of all possible color property button names
			vector<string> colorProperties = {
				"PROPERTY_TEXTCOLOR", "PROPERTY_BORDERCOLOR", "PROPERTY_BACKGROUNDCOLOR",
				"PROPERTY_BACKGROUND", "PROPERTY_SPURCOLOR", "PROPERTY_COLOR"
			};

			for (const auto& propName : colorProperties)
			{
				int buttonID = m_propertySerializer->GetElementID(propName);
				if (buttonID != -1)
				{
					auto button = m_gui->GetElement(buttonID);
					if (button && button->m_Type == GUI_TEXTBUTTON)
					{
						auto textButton = static_cast<GuiTextButton*>(button.get());
						if (textButton->m_Clicked)
						{
							// Get current color from element using generic helper
							Color currentColor = GetElementColor(selectedElement.get(), propName);

							// Track which property we're editing
							m_editingColorProperty = propName;

							// Open color picker with current color
							auto colorPickerState = static_cast<ColorPickerState*>(g_StateMachine->GetState(1));
							colorPickerState->SetColor(currentColor);
							g_StateMachine->PushState(1);

							Log("Opening color picker for " + propName);
							break; // Only handle one button click per frame
						}
					}
				}
			}
		}
	}

	// Sprite picker button click handler - checks all sprite property buttons for stretchbutton
	if (m_selectedElementID != -1)
	{
		auto selectedElement = m_gui->GetElement(m_selectedElementID);
		if (selectedElement && (selectedElement->m_Type == GUI_STRETCHBUTTON || selectedElement->m_Type == GUI_SPRITE || selectedElement->m_Type == GUI_ICONBUTTON))
		{
			// List of all sprite property button names
			vector<string> spriteProperties = {
				"PROPERTY_SPRITE_LEFT", "PROPERTY_SPRITE_CENTER", "PROPERTY_SPRITE_RIGHT", "PROPERTY_SPRITE"
			};

			for (const auto& propName : spriteProperties)
			{
				int buttonID = m_propertySerializer->GetElementID(propName);
				if (buttonID != -1)
				{
					auto button = m_gui->GetElement(buttonID);
					if (button && button->m_Type == GUI_TEXTBUTTON)
					{
						auto textButton = static_cast<GuiTextButton*>(button.get());
						if (textButton->m_Clicked)
						{
							// Get current sprite definition from serializer
							GhostSerializer::SpriteDefinition sprite;

							if (propName == "PROPERTY_SPRITE_LEFT")
							{
								sprite = m_contentSerializer->GetStretchButtonLeftSprite(m_selectedElementID);
							}
							else if (propName == "PROPERTY_SPRITE_CENTER")
							{
								sprite = m_contentSerializer->GetStretchButtonCenterSprite(m_selectedElementID);
							}
							else if (propName == "PROPERTY_SPRITE_RIGHT")
							{
								sprite = m_contentSerializer->GetStretchButtonRightSprite(m_selectedElementID);
							}
							else if (propName == "PROPERTY_SPRITE")
							{
								// For sprite elements, get the sprite metadata
								sprite.spritesheet = m_contentSerializer->GetSpriteName(m_selectedElementID);

								// Get sprite source rect from the actual sprite element
								auto selectedElement = m_gui->GetElement(m_selectedElementID);
								if (selectedElement && selectedElement->m_Type == GUI_SPRITE)
								{
									auto spriteElem = static_cast<GuiSprite*>(selectedElement.get());
									if (spriteElem->m_Sprite)
									{
										sprite.x = static_cast<int>(spriteElem->m_Sprite->m_sourceRect.x);
										sprite.y = static_cast<int>(spriteElem->m_Sprite->m_sourceRect.y);
										sprite.w = static_cast<int>(spriteElem->m_Sprite->m_sourceRect.width);
										sprite.h = static_cast<int>(spriteElem->m_Sprite->m_sourceRect.height);
									}
								}
							}
							else if (selectedElement && selectedElement->m_Type == GUI_ICONBUTTON)
							{
								auto iconElem = static_cast<GuiIconButton*>(selectedElement.get());
								if (iconElem->m_UpTexture)
								{
									sprite.x = static_cast<int>(iconElem->m_UpTexture->m_sourceRect.x);
									sprite.y = static_cast<int>(iconElem->m_UpTexture->m_sourceRect.y);
									sprite.w = static_cast<int>(iconElem->m_UpTexture->m_sourceRect.width);
									sprite.h = static_cast<int>(iconElem->m_UpTexture->m_sourceRect.height);
								}
							}

							// Track which property we're editing
							m_editingSpriteProperty = propName;

							// Open sprite picker with current sprite definition
							auto spritePickerState = static_cast<SpritePickerState*>(g_StateMachine->GetState(2));
							spritePickerState->SetSprite(sprite.spritesheet, sprite.x, sprite.y, sprite.w, sprite.h);
							g_StateMachine->PushState(2);

							Log("Opening sprite picker for " + propName);
							break; // Only handle one button click per frame
						}
					}
				}
			}
		}
	}

	if (activeID >= 3000 && activeID != lastActiveID)
	{
		lastActiveID = activeID;

		// Track initial values when property inputs are activated
		// This ensures we have the correct baseline before checking for changes
		TrackPropertyValue(activeID, "PROPERTY_NAME", lastNameValue);
		TrackPropertyValue(activeID, "PROPERTY_COLUMNS", lastColumnsValue);
		TrackPropertyValue(activeID, "PROPERTY_SPRITE", lastSpriteValue);
		TrackPropertyValue(activeID, "PROPERTY_TEXT", lastTextValue);
		TrackPropertyValue(activeID, "PROPERTY_HORZ_PADDING", lastHorzPaddingValue);
		TrackPropertyValue(activeID, "PROPERTY_VERT_PADDING", lastVertPaddingValue);
		TrackPropertyValue(activeID, "PROPERTY_FONT", lastFontValue);
		TrackPropertyValue(activeID, "PROPERTY_FONT_SIZE", lastFontSizeValue);

		// Don't check for changes on the same frame we just tracked the initial value
		// This prevents false "changes" when clicking into an already-populated input
		return;
	}
	else if (activeID < 3000)
	{
		lastActiveID = -1;
		lastNameValue = "";
		lastColumnsValue = "";
		lastSpriteValue = "";
		lastTextValue = "";
		lastHorzPaddingValue = "";
		lastVertPaddingValue = "";
		lastFontValue = "";
		lastFontSizeValue = "";
	}

	// Check for property value changes while typing (for live updates)
	CheckPropertyChanged(activeID, "PROPERTY_NAME", lastNameValue);
	CheckPropertyChanged(activeID, "PROPERTY_COLUMNS", lastColumnsValue);
	CheckPropertyChanged(activeID, "PROPERTY_SPRITE", lastSpriteValue);
	CheckPropertyChanged(activeID, "PROPERTY_TEXT", lastTextValue);
	CheckPropertyChanged(activeID, "PROPERTY_HORZ_PADDING", lastHorzPaddingValue);
	CheckPropertyChanged(activeID, "PROPERTY_VERT_PADDING", lastVertPaddingValue);
	CheckPropertyChanged(activeID, "PROPERTY_FONT", lastFontValue);
	CheckPropertyChanged(activeID, "PROPERTY_FONT_SIZE", lastFontSizeValue);

	// Check if a content element was clicked (IDs 2000-2999, not property panel 3000+)
	if (activeID >= 2000 && activeID < 3000)
	{
		m_selectedElementID = activeID;
		Log("Selected element ID: " + to_string(activeID));
		UpdatePropertyPanel();  // Update property panel when selection changes
		UpdateStatusFooter();  // Update status footer with selected element info

		// Sync scrollbar tracking variables after populating property panel
		// This prevents false "change" detections on first frame after selection
		int columnsScrollbarID = m_propertySerializer->GetElementID("PROPERTY_COLUMNS");
		if (columnsScrollbarID != -1)
		{
			auto elem = m_gui->GetElement(columnsScrollbarID);
			if (elem && elem->m_Type == GUI_SCROLLBAR)
				lastColumnsScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
		}

		int horzPaddingScrollbarID = m_propertySerializer->GetElementID("PROPERTY_HORZ_PADDING");
		if (horzPaddingScrollbarID != -1)
		{
			auto elem = m_gui->GetElement(horzPaddingScrollbarID);
			if (elem && elem->m_Type == GUI_SCROLLBAR)
				lastHorzPaddingScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
		}

		int vertPaddingScrollbarID = m_propertySerializer->GetElementID("PROPERTY_VERT_PADDING");
		if (vertPaddingScrollbarID != -1)
		{
			auto elem = m_gui->GetElement(vertPaddingScrollbarID);
			if (elem && elem->m_Type == GUI_SCROLLBAR)
				lastVertPaddingScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
		}

		int fontSizeScrollbarID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
		if (fontSizeScrollbarID != -1)
		{
			auto elem = m_gui->GetElement(fontSizeScrollbarID);
			if (elem && elem->m_Type == GUI_SCROLLBAR)
				lastFontSizeScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
		}

		int widthScrollbarID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
		if (widthScrollbarID != -1)
		{
			auto elem = m_gui->GetElement(widthScrollbarID);
			if (elem && elem->m_Type == GUI_SCROLLBAR)
				lastWidthScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
		}

		int heightScrollbarID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
		if (heightScrollbarID != -1)
		{
			auto elem = m_gui->GetElement(heightScrollbarID);
			if (elem && elem->m_Type == GUI_SCROLLBAR)
				lastHeightScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
		}

		int valueRangeScrollbarID = m_propertySerializer->GetElementID("PROPERTY_VALUE_RANGE");
		if (valueRangeScrollbarID != -1)
		{
			auto elem = m_gui->GetElement(valueRangeScrollbarID);
			if (elem && elem->m_Type == GUI_SCROLLBAR)
				lastValueRangeScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
		}

		int groupScrollbarID = m_propertySerializer->GetElementID("PROPERTY_GROUP");
		if (groupScrollbarID != -1)
		{
			auto elem = m_gui->GetElement(groupScrollbarID);
			if (elem && elem->m_Type == GUI_SCROLLBAR)
				lastGroupScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
		}

		int scaleScrollbarID = m_propertySerializer->GetElementID("PROPERTY_SCALE");
		if (scaleScrollbarID != -1)
		{
			auto elem = m_gui->GetElement(scaleScrollbarID);
			if (elem && elem->m_Type == GUI_SCROLLBAR)
				lastScaleScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
		}

		int indentScrollbarID = m_propertySerializer->GetElementID("PROPERTY_INDENT");
		if (indentScrollbarID != -1)
		{
			auto elem = m_gui->GetElement(indentScrollbarID);
			if (elem && elem->m_Type == GUI_SCROLLBAR)
				lastIndentScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
		}

		int verticalCheckboxID = m_propertySerializer->GetElementID("PROPERTY_VERTICAL");
		if (verticalCheckboxID != -1)
		{
			auto elem = m_gui->GetElement(verticalCheckboxID);
			if (elem && elem->m_Type == GUI_CHECKBOX)
				lastVerticalCheckboxValue = static_cast<GuiCheckBox*>(elem.get())->m_Selected;
		}

		int canBeHeldCheckboxID = m_propertySerializer->GetElementID("PROPERTY_CANBEHELD");
		if (canBeHeldCheckboxID != -1)
		{
			auto elem = m_gui->GetElement(canBeHeldCheckboxID);
			if (elem && elem->m_Type == GUI_CHECKBOX)
				lastCanBeHeldCheckboxValue = static_cast<GuiCheckBox*>(elem.get())->m_Selected;
		}

		int shadowedCheckboxID = m_propertySerializer->GetElementID("PROPERTY_SHADOWED");
		if (shadowedCheckboxID != -1)
		{
			auto elem = m_gui->GetElement(shadowedCheckboxID);
			if (elem && elem->m_Type == GUI_CHECKBOX)
				lastShadowedCheckboxValue = static_cast<GuiCheckBox*>(elem.get())->m_Selected;
		}

		int textInputFontSizeScrollbarID2 = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
		if (textInputFontSizeScrollbarID2 != -1)
		{
			auto elem = m_gui->GetElement(textInputFontSizeScrollbarID2);
			if (elem && elem->m_Type == GUI_SCROLLBAR)
				lastTextInputFontSizeScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
		}
	}
	// For non-interactive elements (panels, textareas), manually detect clicks
	else if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
	{
		Vector2 mousePos = GetMousePosition();
		float scaledX = mousePos.x / m_gui->m_InputScale;
		float scaledY = mousePos.y / m_gui->m_InputScale;

		// Find all content elements under the cursor (2000-2999, not property panel 3000+)
		// Include inactive elements too so disabled text inputs can still be selected
		std::vector<int> clickedElements;
		for (const auto& pair : m_gui->m_GuiElementList)
		{
			const auto& element = pair.second;
			if (element->m_ID >= 2000 && element->m_ID < 3000 && element->m_Visible)
			{
				float elemX = m_gui->m_Pos.x + element->m_Pos.x;
				float elemY = m_gui->m_Pos.y + element->m_Pos.y;

				if (scaledX >= elemX && scaledX <= elemX + element->m_Width &&
					scaledY >= elemY && scaledY <= elemY + element->m_Height)
				{
					clickedElements.push_back(element->m_ID);
				}
			}
		}

		// Find the deepest element in the tree (the one with the most ancestors)
		int bestID = -1;
		int maxDepth = -1;
		bool clickedInvisibleRoot = false;
		for (int id : clickedElements)
		{
			if (id == 2000)
			{
				clickedInvisibleRoot = true;
				continue;  // Skip invisible root in depth calculation
			}

			// Count depth by walking up the parent chain
			int depth = 0;
			int currentID = id;
			while (currentID != -1)
			{
				currentID = m_contentSerializer->GetParentID(currentID);
				depth++;
			}

			if (depth > maxDepth)
			{
				maxDepth = depth;
				bestID = id;
			}
		}

		// If we clicked the invisible root (2000) and nothing else, select the normal root (2001)
		if (bestID == -1 && clickedInvisibleRoot)
		{
			bestID = 2001;
		}

		if (bestID != -1)
		{
			m_selectedElementID = bestID;
			Log("Selected element ID: " + to_string(bestID));
			UpdatePropertyPanel();  // Update property panel when selection changes
			UpdateStatusFooter();  // Update status footer with selected element info

			// Sync scrollbar tracking variables after populating property panel
			// This prevents false "change" detections on first frame after selection
			int columnsScrollbarID = m_propertySerializer->GetElementID("PROPERTY_COLUMNS");
			if (columnsScrollbarID != -1)
			{
				auto elem = m_gui->GetElement(columnsScrollbarID);
				if (elem && elem->m_Type == GUI_SCROLLBAR)
					lastColumnsScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
			}

			int horzPaddingScrollbarID = m_propertySerializer->GetElementID("PROPERTY_HORZ_PADDING");
			if (horzPaddingScrollbarID != -1)
			{
				auto elem = m_gui->GetElement(horzPaddingScrollbarID);
				if (elem && elem->m_Type == GUI_SCROLLBAR)
					lastHorzPaddingScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
			}

			int vertPaddingScrollbarID = m_propertySerializer->GetElementID("PROPERTY_VERT_PADDING");
			if (vertPaddingScrollbarID != -1)
			{
				auto elem = m_gui->GetElement(vertPaddingScrollbarID);
				if (elem && elem->m_Type == GUI_SCROLLBAR)
					lastVertPaddingScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
			}

			int fontSizeScrollbarID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
			if (fontSizeScrollbarID != -1)
			{
				auto elem = m_gui->GetElement(fontSizeScrollbarID);
				if (elem && elem->m_Type == GUI_SCROLLBAR)
					lastFontSizeScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
			}

			int widthScrollbarID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
			if (widthScrollbarID != -1)
			{
				auto elem = m_gui->GetElement(widthScrollbarID);
				if (elem && elem->m_Type == GUI_SCROLLBAR)
					lastWidthScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
			}

			int heightScrollbarID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
			if (heightScrollbarID != -1)
			{
				auto elem = m_gui->GetElement(heightScrollbarID);
				if (elem && elem->m_Type == GUI_SCROLLBAR)
					lastHeightScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
			}

			int valueRangeScrollbarID = m_propertySerializer->GetElementID("PROPERTY_VALUE_RANGE");
			if (valueRangeScrollbarID != -1)
			{
				auto elem = m_gui->GetElement(valueRangeScrollbarID);
				if (elem && elem->m_Type == GUI_SCROLLBAR)
					lastValueRangeScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
			}

			int textInputFontSizeScrollbarID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
			if (textInputFontSizeScrollbarID != -1)
			{
				auto elem = m_gui->GetElement(textInputFontSizeScrollbarID);
				if (elem && elem->m_Type == GUI_SCROLLBAR)
					lastTextInputFontSizeScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
			}
		}
	}

	// Handle keyboard shortcuts
	bool ctrlPressed = IsKeyDown(KEY_LEFT_CONTROL) || IsKeyDown(KEY_RIGHT_CONTROL);

	// Ctrl+Z: Undo (check first so it's not blocked by selection requirement)
	if (ctrlPressed && IsKeyPressed(KEY_Z))
	{
		Undo();
	}
	// Ctrl+Y: Redo
	else if (ctrlPressed && IsKeyPressed(KEY_Y))
	{
		Redo();
	}
	// Delete: Remove selected element
	else if (IsKeyPressed(KEY_DELETE) && m_selectedElementID >= 2002 && m_selectedElementID < 3000)
	{
		Log("Delete key pressed - removing element ID: " + to_string(m_selectedElementID));

		// Save undo state before making changes
		PushUndoState();

		// Get parent ID before deleting (for reflow)
		int parentID = m_contentSerializer->GetParentID(m_selectedElementID);

		// Remove from GUI
		m_gui->m_GuiElementList.erase(m_selectedElementID);

		// Remove from content serializer's tree
		m_contentSerializer->UnregisterChild(m_selectedElementID);

		// Reflow the parent panel if it exists
		if (parentID != -1)
		{
			m_contentSerializer->ReflowPanel(parentID, m_gui.get());
		}

		// Clear selection and property panel
		m_selectedElementID = -1;
		ClearPropertyPanel();
		UpdateStatusFooter();

		// Mark as dirty
		m_contentSerializer->SetDirty(true);
	}
	// Ctrl+X: Cut (copy to clipboard then delete)
	else if (ctrlPressed && IsKeyPressed(KEY_X) && m_selectedElementID >= 2002 && m_selectedElementID < 3000)
	{
		Log("Ctrl+X pressed - cutting element ID: " + to_string(m_selectedElementID));

		// Save undo state before making changes
		PushUndoState();

		// Get parent position for relative coordinates
		int parentID = m_contentSerializer->GetParentID(m_selectedElementID);
		int parentX = 0, parentY = 0;
		if (parentID != -1)
		{
			auto parentElement = m_gui->GetElement(parentID);
			if (parentElement)
			{
				parentX = static_cast<int>(parentElement->m_Pos.x);
				parentY = static_cast<int>(parentElement->m_Pos.y);
			}
		}

		// Serialize element to clipboard
		m_clipboard = m_contentSerializer->SerializeElement(m_selectedElementID, m_gui.get(), parentX, parentY);
		m_hasClipboard = !m_clipboard.is_null();

		if (m_hasClipboard)
		{
			Log("Element copied to clipboard");
		}

		// Remove from GUI
		m_gui->m_GuiElementList.erase(m_selectedElementID);

		// Remove from content serializer's tree
		m_contentSerializer->UnregisterChild(m_selectedElementID);

		// Reflow the parent panel if it exists
		if (parentID != -1)
		{
			m_contentSerializer->ReflowPanel(parentID, m_gui.get());
		}

		// Clear selection and property panel
		m_selectedElementID = -1;
		ClearPropertyPanel();
		UpdateStatusFooter();

		// Mark as dirty
		m_contentSerializer->SetDirty(true);
	}
	// Ctrl+C: Copy to clipboard
	else if (ctrlPressed && IsKeyPressed(KEY_C) && m_selectedElementID >= 2002 && m_selectedElementID < 3000)
	{
		Log("Ctrl+C pressed - copying element ID: " + to_string(m_selectedElementID));

		// Get parent position for relative coordinates
		int parentID = m_contentSerializer->GetParentID(m_selectedElementID);
		int parentX = 0, parentY = 0;
		if (parentID != -1)
		{
			auto parentElement = m_gui->GetElement(parentID);
			if (parentElement)
			{
				parentX = static_cast<int>(parentElement->m_Pos.x);
				parentY = static_cast<int>(parentElement->m_Pos.y);
			}
		}

		// Serialize element to clipboard
		m_clipboard = m_contentSerializer->SerializeElement(m_selectedElementID, m_gui.get(), parentX, parentY);
		m_hasClipboard = !m_clipboard.is_null();

		if (m_hasClipboard)
		{
			Log("Element copied to clipboard (type: " + m_clipboard["type"].get<string>() + ")");
			Log("Clipboard JSON: " + m_clipboard.dump());
		}
		else
		{
			Log("Failed to copy element to clipboard");
		}
	}
	// Ctrl+V: Paste from clipboard
	else if (ctrlPressed && IsKeyPressed(KEY_V) && m_hasClipboard && m_contentSerializer)
	{
		Log("Ctrl+V pressed - pasting from clipboard");

		// Save undo state before making changes
		PushUndoState();

		// Determine where to paste based on currently selected element (same logic as InsertButton)
		int parentID = -1;

		if (m_selectedElementID == -1)
		{
			// No selection - paste as child of root
			parentID = m_contentSerializer->GetRootElementID();
			Log("Pasting as child of root ID: " + to_string(parentID));
		}
		else
		{
			// Check if selected element is a panel
			auto selectedElement = m_gui->GetElement(m_selectedElementID);
			if (selectedElement && selectedElement->m_Type == GUI_PANEL)
			{
				// Selected element is a panel - paste as its child
				parentID = m_selectedElementID;
				Log("Pasting as child of selected panel ID: " + to_string(parentID));
			}
			else
			{
				// Selected element is not a panel - paste as sibling (same parent)
				parentID = m_contentSerializer->GetParentID(m_selectedElementID);
				if (parentID == -1)
				{
					Log("ERROR: Cannot paste as sibling - selected element has no valid parent");
					return;
				}
				Log("Pasting as sibling of selected element ID: " + to_string(m_selectedElementID));
			}
		}

		// Get parent position for relative positioning
		int parentX = 0, parentY = 0;
		auto parentElement = m_gui->GetElement(parentID);
		if (parentElement)
		{
			parentX = static_cast<int>(parentElement->m_Pos.x);
			parentY = static_cast<int>(parentElement->m_Pos.y);
		}

		// Get next auto ID for the pasted element
		int newElementID = m_contentSerializer->GetNextAutoID();

		// Create a temporary .ghost file structure in memory with proper format
		ghost_json tempFileJson;
		tempFileJson["gui"]["elements"] = ghost_json::array();
		tempFileJson["gui"]["elements"].push_back(m_clipboard);

		// Write to a temporary file
		string tempFilename = "temp_paste_" + to_string(newElementID) + ".ghost";
		ofstream tempFile(tempFilename);
		if (tempFile.is_open())
		{
			tempFile << tempFileJson.dump(2);
			tempFile.close();

			Log("Pasting element with parent offset (" + to_string(parentX) + ", " + to_string(parentY) + ")");

			// Load using LoadIntoPanel which handles parent offset correctly
			if (m_contentSerializer->LoadIntoPanel(tempFilename, m_gui.get(), parentX, parentY, parentID))
			{
				// Transfer fonts from content serializer to preserved fonts
				auto& fonts = m_contentSerializer->GetLoadedFonts();
				if (!fonts.empty())
				{
					m_preservedFonts.push_back(fonts.back());
				}

				// Disable ALL elements in the content area (IDs 2001-2999)
				for (auto& [id, element] : m_gui->m_GuiElementList)
				{
					if (id >= 2001 && id < 3000 && element)
					{
						element->m_Active = false;
					}
				}

				// Reflow the parent panel
				m_contentSerializer->ReflowPanel(parentID, m_gui.get());

				// Select the newly pasted element
				m_selectedElementID = newElementID;
				UpdatePropertyPanel();
				UpdateStatusFooter();

				// Mark as dirty
				m_contentSerializer->SetDirty(true);

				Log("Pasted element with ID: " + to_string(newElementID) + " as child of parent ID: " + to_string(parentID));
			}
			else
			{
				Log("Failed to paste element from clipboard");
			}

			// Clean up temp file
			remove(tempFilename.c_str());
		}
		else
		{
			Log("Failed to create temporary paste file");
		}
	}

	// Check for button clicks using name-based lookup
	if (activeID == m_serializer->GetElementID("NEW"))
	{
		Log("New button clicked!");
		ClearLoadedContent();
		EnsureContentRoot();  // Recreate empty root after clearing
	}
	else if (activeID == m_serializer->GetElementID("CLOSE"))
	{
		Log("Close button clicked!");
		g_Engine->m_Done = true;
	}
	else if (activeID == m_serializer->GetElementID("OPEN"))
	{
		Log("Open button clicked!");

		// Push FileChooserState in open mode
		auto fileChooserState = static_cast<FileChooserState*>(g_StateMachine->GetState(3));
		fileChooserState->SetMode(false, ".ghost", "");  // Empty string uses default (./)
		g_StateMachine->PushState(3);
	}
	else if (activeID == m_serializer->GetElementID("SAVE"))
	{
		Log("Save button clicked!");

		// If no file is loaded, prompt for a filename
		if (m_loadedGhostFile.empty())
		{
			Log("No file loaded, showing save dialog");

			// Push FileChooserState in save mode
			auto fileChooserState = static_cast<FileChooserState*>(g_StateMachine->GetState(3));
			fileChooserState->SetMode(true, ".ghost", "Gui/");
			g_StateMachine->PushState(3);
			return;
		}

		SaveGhostFile();
	}
	else if (activeID == m_serializer->GetElementID("SAVE AS"))
	{
		Log("Save As button clicked!");

		// Always prompt for a new filename
		// Push FileChooserState in save mode
		auto fileChooserState = static_cast<FileChooserState*>(g_StateMachine->GetState(3));
		fileChooserState->SetMode(true, ".ghost", "Gui/");
		g_StateMachine->PushState(3);
	}
	else if (activeID == m_serializer->GetElementID("PANEL"))
	{
		Log("Panel button clicked!");
		InsertPanel();
	}
	else if (activeID == m_serializer->GetElementID("TEXT"))
	{
		Log("Text button clicked!");
		InsertLabel();
	}
	else if (activeID == m_serializer->GetElementID("BUTTON"))
	{
		Log("Button button clicked!");
		InsertButton();
	}
	else if (activeID != -1 && activeID == m_serializer->GetElementID("ICONBUTTON"))
	{
		Log("Icon button button clicked!");
		InsertIconButton();
	}
	else if (activeID == m_serializer->GetElementID("SPRITE"))
	{
		Log("Sprite button clicked!");
		InsertSprite();
	}
	else if (activeID == m_serializer->GetElementID("INPUT"))
	{
		Log("Input button clicked!");
		InsertTextInput();
	}
	else if (activeID == m_serializer->GetElementID("CHECK"))
	{
		Log("Check button clicked!");
		InsertCheckbox();
	}
	else if (activeID == m_serializer->GetElementID("RADIO"))
	{
		Log("Radio button clicked!");
		InsertRadioButton();
	}
	else if (activeID != -1 && activeID == m_serializer->GetElementID("SCROLLBAR"))
	{
		Log("Scroll bar button clicked!");
		InsertScrollBar();
	}
	else if (activeID != -1 && activeID == m_serializer->GetElementID("OCTAGONBOX"))
	{
		Log("Octagon box button clicked!");
		InsertOctagonBox();
	}
	else if (activeID != -1 && activeID == m_serializer->GetElementID("STRETCHBUTTON"))
	{
		Log("Stretch button button clicked!");
		InsertStretchButton();
	}
	else if (activeID != -1 && activeID == m_serializer->GetElementID("LIST"))
	{
		Log("List button clicked!");
		InsertList();
	}
	else if (activeID != -1 && activeID == m_serializer->GetElementID("LISTBOX"))
	{
		Log("ListBox button clicked!");
		InsertListBox();
	}
}

void GhostState::Draw()
{
	// Draw the GUI
	m_gui->Draw();

	// Draw selection highlight around the selected element
	if (m_selectedElementID != -1)
	{
		auto selectedElement = m_gui->GetElement(m_selectedElementID);
		if (selectedElement)
		{
			// Draw a yellow outline around the selected element
			DrawRectangleLines(
				static_cast<int>(m_gui->m_Pos.x + selectedElement->m_Pos.x - 2),
				static_cast<int>(m_gui->m_Pos.y + selectedElement->m_Pos.y - 2),
				static_cast<int>(selectedElement->m_Width + 4),
				static_cast<int>(selectedElement->m_Height + 4),
				YELLOW
			);
		}
	}

	// Draw value overlays on property panel scrollbars
	if (m_propertySerializer && m_selectedElementID != -1)
	{
		// List of property scrollbars to overlay values on
		vector<string> scrollbarProperties = {
			"PROPERTY_WIDTH", "PROPERTY_HEIGHT", "PROPERTY_VALUE_RANGE",
			"PROPERTY_COLUMNS", "PROPERTY_HORZ_PADDING", "PROPERTY_VERT_PADDING",
			"PROPERTY_FONT_SIZE", "PROPERTY_GROUP"
		};

		for (const auto& propName : scrollbarProperties)
		{
			int scrollbarID = m_propertySerializer->GetElementID(propName);
			if (scrollbarID != -1 && scrollbarID >= 3000)  // Only property panel elements
			{
				auto scrollbarElement = m_gui->GetElement(scrollbarID);
				if (scrollbarElement && scrollbarElement->m_Type == GUI_SCROLLBAR)
				{
					auto scrollbar = static_cast<GuiScrollBar*>(scrollbarElement.get());

					// Calculate center position for text
					int textX = static_cast<int>(m_gui->m_Pos.x + scrollbar->m_Pos.x + scrollbar->m_Width / 2);
					int textY = static_cast<int>(m_gui->m_Pos.y + scrollbar->m_Pos.y + scrollbar->m_Height / 2 - 8);

					// Draw the value in red
					string valueText = to_string(scrollbar->m_Value);
					DrawText(valueText.c_str(), textX - MeasureText(valueText.c_str(), 16) / 2, textY, 16, RED);
				}
			}
		}
	}
}

void GhostState::OnEnter()
{
	// Called when state becomes active
	Log("GhostState::OnEnter - Previous state: " + std::to_string(g_StateMachine->GetPreviousState()));

	// Check if we're returning from ColorPickerState
	if (g_StateMachine->GetPreviousState() == 1)  // ColorPickerState is state ID 1
	{
		Log("GhostState: Returning from ColorPickerState");
		auto colorPickerState = static_cast<ColorPickerState*>(g_StateMachine->GetState(1));

		// Only apply color if user clicked OK (not Cancel)
		Log("GhostState: WasAccepted = " + std::string(colorPickerState->WasAccepted() ? "true" : "false"));
		if (colorPickerState->WasAccepted())
		{
			Log("GhostState: Applying color, selectedElementID = " + std::to_string(m_selectedElementID));
			Color selectedColor = colorPickerState->GetColor();

			// Apply color based on which property was being edited
			if (m_selectedElementID != -1 && !m_editingColorProperty.empty())
			{
				auto selectedElement = m_gui->GetElement(m_selectedElementID);

				if (selectedElement)
				{
					// Use generic helper to set color on element
					SetElementColor(selectedElement.get(), m_editingColorProperty, selectedColor);
					Log("Applied " + m_editingColorProperty + " from color picker");

					// Update the property button text color to match
					int buttonID = m_propertySerializer->GetElementID(m_editingColorProperty);
					if (buttonID != -1)
					{
						auto button = m_gui->GetElement(buttonID);
						if (button && button->m_Type == GUI_TEXTBUTTON)
						{
							auto textButton = static_cast<GuiTextButton*>(button.get());
							textButton->m_TextColor = selectedColor;
						}
					}

					Log("Applied color: R=" + std::to_string(selectedColor.r) +
						", G=" + std::to_string(selectedColor.g) +
						", B=" + std::to_string(selectedColor.b) +
						", A=" + std::to_string(selectedColor.a));
				}
			}

			// Reset the tracking variable
			m_editingColorProperty.clear();
		}
	}

	// Check if we're returning from SpritePickerState
	if (g_StateMachine->GetPreviousState() == 2)  // SpritePickerState is state ID 2
	{
		Log("GhostState: Returning from SpritePickerState");
		auto spritePickerState = static_cast<SpritePickerState*>(g_StateMachine->GetState(2));

		// Only apply sprite if user clicked OK (not Cancel)
		Log("GhostState: WasAccepted = " + std::string(spritePickerState->WasAccepted() ? "true" : "false"));
		if (spritePickerState->WasAccepted())
		{
			Log("GhostState: Applying sprite, selectedElementID = " + std::to_string(m_selectedElementID));

			// Get sprite definition from picker
			GhostSerializer::SpriteDefinition sprite;
			sprite.spritesheet = spritePickerState->GetFilename();
			sprite.x = spritePickerState->GetX();
			sprite.y = spritePickerState->GetY();
			sprite.w = spritePickerState->GetWidth();
			sprite.h = spritePickerState->GetHeight();

			// Apply sprite based on which property was being edited
			if (m_selectedElementID != -1 && !m_editingSpriteProperty.empty())
			{
				auto selectedElement = m_gui->GetElement(m_selectedElementID);

				if (selectedElement && selectedElement->m_Type == GUI_STRETCHBUTTON)
				{
					auto stretchButton = static_cast<GuiStretchButton*>(selectedElement.get());

					// Load the new sprite texture
					string spritePath = m_spritePath + sprite.spritesheet;
					Texture* texture = g_ResourceManager->GetTexture(spritePath);

					if (texture)
					{
						// Create new sprite with the specified source rectangle
						shared_ptr<Sprite> newSprite = make_shared<Sprite>();
						newSprite->m_texture = texture;
						newSprite->m_sourceRect = Rectangle{
							static_cast<float>(sprite.x),
							static_cast<float>(sprite.y),
							static_cast<float>(sprite.w),
							static_cast<float>(sprite.h)
						};

						// Store sprite definition in serializer AND update the button's sprite
						if (m_editingSpriteProperty == "PROPERTY_SPRITE_LEFT")
						{
							m_contentSerializer->SetStretchButtonLeftSprite(m_selectedElementID, sprite);
							stretchButton->m_ActiveLeft = newSprite;
							stretchButton->m_InactiveLeft = newSprite;  // Use same sprite for both states
							Log("Set left sprite: " + sprite.spritesheet);
						}
						else if (m_editingSpriteProperty == "PROPERTY_SPRITE_CENTER")
						{
							m_contentSerializer->SetStretchButtonCenterSprite(m_selectedElementID, sprite);
							stretchButton->m_ActiveCenter = newSprite;
							stretchButton->m_InactiveCenter = newSprite;  // Use same sprite for both states
							Log("Set center sprite: " + sprite.spritesheet);
						}
						else if (m_editingSpriteProperty == "PROPERTY_SPRITE_RIGHT")
						{
							m_contentSerializer->SetStretchButtonRightSprite(m_selectedElementID, sprite);
							stretchButton->m_ActiveRight = newSprite;
							stretchButton->m_InactiveRight = newSprite;  // Use same sprite for both states
							Log("Set right sprite: " + sprite.spritesheet);
						}

						Log("Applied sprite: " + sprite.spritesheet + " at (" + std::to_string(sprite.x) + "," + std::to_string(sprite.y) +
							") size (" + std::to_string(sprite.w) + "x" + std::to_string(sprite.h) + ")");
					}
					else
					{
						Log("ERROR: Failed to load texture for stretch button: " + spritePath);
					}
				}
				else if (selectedElement && selectedElement->m_Type == GUI_SPRITE && m_editingSpriteProperty == "PROPERTY_SPRITE")
				{
					// Update sprite element with new sprite data
					auto spriteElem = static_cast<GuiSprite*>(selectedElement.get());

					// Load the new sprite texture
					string spritePath = m_spritePath + sprite.spritesheet;
					Texture* texture = g_ResourceManager->GetTexture(spritePath);

					if (texture)
					{
						// Create new sprite with the specified source rectangle
						shared_ptr<Sprite> newSprite = make_shared<Sprite>();
						newSprite->m_texture = texture;
						newSprite->m_sourceRect = Rectangle{
							static_cast<float>(sprite.x),
							static_cast<float>(sprite.y),
							static_cast<float>(sprite.w),
							static_cast<float>(sprite.h)
						};

						// Update the sprite element
						spriteElem->m_Sprite = newSprite;
						spriteElem->m_Width = sprite.w;
						spriteElem->m_Height = sprite.h;

						// Store sprite filename in serializer
						m_contentSerializer->SetSpriteName(m_selectedElementID, sprite.spritesheet);

						Log("Updated sprite: " + sprite.spritesheet + " at (" + std::to_string(sprite.x) + "," + std::to_string(sprite.y) +
							") size (" + std::to_string(sprite.w) + "x" + std::to_string(sprite.h) + ")");
					}
					else
					{
						Log("ERROR: Failed to load texture: " + spritePath);
					}
				}
			else if (selectedElement && selectedElement->m_Type == GUI_ICONBUTTON && m_editingSpriteProperty == "PROPERTY_SPRITE")
			{
				// Update icon button with new sprite data
				auto iconElem = static_cast<GuiIconButton*>(selectedElement.get());

				// Load the new sprite texture
				string spritePath = m_spritePath + sprite.spritesheet;
				Texture* texture = g_ResourceManager->GetTexture(spritePath);

				if (texture)
				{
					// Create new sprite with the specified source rectangle
					shared_ptr<Sprite> newSprite = make_shared<Sprite>();
					newSprite->m_texture = texture;
					newSprite->m_sourceRect = Rectangle{
						static_cast<float>(sprite.x),
						static_cast<float>(sprite.y),
						static_cast<float>(sprite.w),
						static_cast<float>(sprite.h)
					};

					// Update the icon button's up texture
					iconElem->m_UpTexture = newSprite;
					iconElem->m_Width = sprite.w;
					iconElem->m_Height = sprite.h;

					// Store sprite filename in serializer
					m_contentSerializer->SetSpriteName(m_selectedElementID, sprite.spritesheet);

					Log("Updated iconbutton sprite: " + sprite.spritesheet + " at (" + std::to_string(sprite.x) + "," + std::to_string(sprite.y) +
						") size (" + std::to_string(sprite.w) + "x" + std::to_string(sprite.h) + ")");
				}
				else
				{
					Log("ERROR: Failed to load texture: " + spritePath);
				}
			}
			}

			// Reset the tracking variable
			m_editingSpriteProperty.clear();
		}
	}

	// Check if we're returning from FileChooserState
	if (g_StateMachine->GetPreviousState() == 3)  // FileChooserState is state ID 3
	{
		Log("GhostState: Returning from FileChooserState");
		auto fileChooserState = static_cast<FileChooserState*>(g_StateMachine->GetState(3));

		// Only process file selection if user clicked OK (not Cancel)
		Log("GhostState: WasAccepted = " + std::string(fileChooserState->WasAccepted() ? "true" : "false"));
		if (fileChooserState->WasAccepted())
		{
			string filepath = fileChooserState->GetSelectedPath();
			Log("Selected file: " + filepath);

			// Determine if this was an open or save operation
			// If m_loadedGhostFile is empty and we have a valid file, it's either open or first save
			// If m_loadedGhostFile has a value, it's a "Save As" operation

			// For now, check if the file exists to determine open vs save
			// This is a simple heuristic - you may want to store the mode explicitly
			std::ifstream testFile(filepath);
			bool fileExists = testFile.good();
			testFile.close();

			if (fileExists || !m_loadedGhostFile.empty())
			{
				// Either file exists (open) or we're doing save as
				// Try to load it if it exists
				if (fileExists)
				{
					LoadGhostFile(filepath);
				}
				else
				{
					// Ensure .ghost extension
					if (filepath.find(".ghost") == string::npos)
					{
						filepath += ".ghost";
					}

					m_loadedGhostFile = filepath;
					SaveGhostFile();
				}
			}
			else
			{
				// New file being saved
				// Ensure .ghost extension
				if (filepath.find(".ghost") == string::npos)
				{
					filepath += ".ghost";
				}

				m_loadedGhostFile = filepath;
				SaveGhostFile();
			}
		}
	}
}

void GhostState::OnExit()
{
	// Called when transitioning away from this state
}

void GhostState::LoadGhostFile(const std::string& filepath)
{
	Log("Loading Ghost file: " + filepath);

	// Clear any existing loaded content first (this also clears the property panel)
	ClearLoadedContent();

	// Store the loaded file path
	m_loadedGhostFile = filepath;

	// Before creating a new serializer, preserve the loaded fonts from the old one
	// The fonts need to stay alive as long as the GUI elements using them exist
	if (m_contentSerializer)
	{
		auto& oldFonts = m_contentSerializer->GetLoadedFonts();
		m_preservedFonts.insert(m_preservedFonts.end(), oldFonts.begin(), oldFonts.end());
	}

	// Find the content panel container (ID 2000) to get its position
	auto contentContainer = m_gui->GetElement(2000);
	if (!contentContainer)
	{
		Log("ERROR: Content panel container (ID 2000) not found!");
		return;
	}

	// Create a new content serializer to avoid name/ID conflicts with the main app layout
	// This keeps the loaded content's element names separate from the app's menu buttons
	// ID 2000 is the content container itself, content elements start at 2001+
	m_contentSerializer = make_unique<GhostSerializer>();
	m_contentSerializer->SetAutoIDStart(2001);

	// Use the content container (ID 2000) as the root for loaded content
	m_contentSerializer->SetRootElementID(2000);

	// Load the file into the content panel container
	int containerX = static_cast<int>(contentContainer->m_Pos.x);
	int containerY = static_cast<int>(contentContainer->m_Pos.y);

	if (m_contentSerializer->LoadIntoPanel(filepath, m_gui.get(), containerX, containerY, 2000))
	{
		Log("Successfully loaded " + filepath + " into content panel");

		// Disable all interactive elements in the content panel (2001-2999) so they don't interfere with selection
		// Content panel is for display only, not interaction. Property panel inputs (3000+) remain active.
		for (auto& [id, element] : m_gui->m_GuiElementList)
		{
			if (id >= 2001 && id < 3000 && element)
			{
				// Disable ALL elements in content area - no type check needed
				element->m_Active = false;
				Log("Disabled element in content panel: ID " + to_string(id) + ", type " + to_string(element->m_Type));
			}
		}

		// Mark content as clean after loading (not dirty until edited)
		m_contentSerializer->SetDirty(false);
	}
	else
	{
		Log("Failed to load " + filepath + " into content panel");
	}
}

void GhostState::SaveGhostFile()
{
	Log("Saving Ghost file: " + m_loadedGhostFile);

	// The content serializer knows which elements it created, so just call SaveToFile
	if (m_contentSerializer->SaveToFile(m_loadedGhostFile, m_gui.get()))
	{
		Log("Successfully saved " + m_loadedGhostFile);
		m_contentSerializer->SetDirty(false);
	}
	else
	{
		Log("Failed to save " + m_loadedGhostFile);
	}
}

void GhostState::ClearLoadedContent()
{
	Log("Clearing loaded content");

	// Remove all content elements from the GUI (but keep the container ID 2000)
	if (m_contentSerializer)
	{
		std::vector<int> allIDs = m_contentSerializer->GetAllElementIDs();
		for (int id : allIDs)
		{
			if (id > 2000)  // Only remove content, not the container itself
			{
				auto element = m_gui->GetElement(id);
				if (element)
				{
					m_gui->m_GuiElementList.erase(id);
				}
			}
		}
	}

	// Clear tracking data
	m_loadedGhostFile.clear();
	m_selectedElementID = -1;

	// Clear property panel since there's no selected element anymore
	ClearPropertyPanel();
	UpdateStatusFooter();

	// Reset the content serializer
	m_contentSerializer.reset();

	// Note: Don't call EnsureContentRoot() here - let the caller decide if they want a default root
	// The "New" button will call EnsureContentRoot() to create an empty container
	// But LoadGhostFile() will load elements directly without needing a default container

	Log("Content cleared successfully");
}

void GhostState::EnsureContentRoot()
{
	// Find the content panel container (ID 2000)
	auto contentContainer = m_gui->GetElement(2000);
	if (!contentContainer)
	{
		Log("ERROR: Content panel container (ID 2000) not found in EnsureContentRoot!");
		return;
	}

	// Create content serializer if it doesn't exist
	if (!m_contentSerializer)
	{
		m_contentSerializer = make_unique<GhostSerializer>();
		m_contentSerializer->SetAutoIDStart(2001);  // Content starts at 2001
	}

	// Set the content container (ID 2000) as the root
	if (m_contentSerializer->GetRootElementID() == -1)
	{
		m_contentSerializer->SetRootElementID(2000);
	}

	// Check if we need to create a default container (only if content area is empty)
	std::vector<int> allContentIDs = m_contentSerializer->GetAllElementIDs();
	bool hasContent = false;
	for (int id : allContentIDs)
	{
		if (id > 2000)  // Check if any content exists beyond the container
		{
			hasContent = true;
			break;
		}
	}

	// Create a default visible container panel if content area is empty
	// This prevents users from accidentally creating multiple root children
	if (!hasContent)
	{
		Log("Creating default container panel for new content");

		int containerID = m_contentSerializer->GetNextAutoID();
		m_contentSerializer->SetAutoIDStart(containerID + 1);

		// Position it inside the content panel container
		int containerX = static_cast<int>(contentContainer->m_Pos.x) + 10;
		int containerY = static_cast<int>(contentContainer->m_Pos.y) + 10;

		m_gui->AddPanel(containerID, containerX, containerY, 620, 700, Color{60, 60, 60, 255}, true, 0, true);
		m_contentSerializer->SetPanelLayout(containerID, "horz");
		m_contentSerializer->SetPanelHorzPadding(containerID, 5);
		m_contentSerializer->SetPanelVertPadding(containerID, 5);
		m_contentSerializer->RegisterChildOfParent(2000, containerID);

		// Make the container the selected element so new elements go into it
		m_selectedElementID = containerID;

		// Only update UI if property serializer is initialized (not during Init)
		if (m_propertySerializer)
		{
			UpdatePropertyPanel();
			UpdateStatusFooter();
		}

		Log("Created default container panel with ID: " + to_string(containerID));
	}
}

// Helper function to prepare common insertion setup
GhostState::InsertContext GhostState::PrepareInsert(const std::string& elementTypeName)
{
	InsertContext ctx;

	Log("Inserting " + elementTypeName);

	// Save undo state before making changes
	PushUndoState();

	// Get next ID for the new element
	ctx.newID = m_contentSerializer->GetNextAutoID();
	m_contentSerializer->SetAutoIDStart(ctx.newID + 1);

	// Determine where to insert based on currently selected element
	ctx.parentID = -1;

	if (m_selectedElementID == -1)
	{
		// No selection - add as child of root
		ctx.parentID = m_contentSerializer->GetRootElementID();
	}
	else
	{
		// Check if selected element is a panel
		auto selectedElement = m_gui->GetElement(m_selectedElementID);
		if (selectedElement && selectedElement->m_Type == GUI_PANEL)
		{
			// Selected element is a panel - add new element as its child
			ctx.parentID = m_selectedElementID;
			Log("Adding " + elementTypeName + " as child of selected panel ID: " + to_string(ctx.parentID));
		}
		else
		{
			// Selected element is not a panel - add as sibling (same parent)
			ctx.parentID = m_contentSerializer->GetParentID(m_selectedElementID);
			if (ctx.parentID == -1)
			{
				Log("ERROR: Cannot add " + elementTypeName + " as sibling - selected element has no valid parent");
				ctx.newID = -1;  // Signal error
				return ctx;
			}
			Log("Adding " + elementTypeName + " as sibling of selected element ID: " + to_string(m_selectedElementID));
		}
	}

	// Calculate position for floating element
	auto [relX, relY] = m_contentSerializer->CalculateNextFloatingPosition(ctx.parentID, m_gui.get());
	auto parentElement = m_gui->GetElement(ctx.parentID);

	if (!parentElement)
	{
		Log("ERROR: Cannot insert " + elementTypeName + " - parent element ID " + to_string(ctx.parentID) + " not found in GUI");
		ctx.newID = -1;  // Signal error
		return ctx;
	}

	ctx.absoluteX = parentElement->m_Pos.x + relX;
	ctx.absoluteY = parentElement->m_Pos.y + relY;

	return ctx;
}

// Helper function to finalize common insertion cleanup
void GhostState::FinalizeInsert(int newID, int parentID, const std::string& elementTypeName, bool isFloating)
{
	// Ensure the newly inserted element is inactive (not interactive in content window)
	auto newElement = m_gui->GetElement(newID);
	if (newElement)
	{
		newElement->m_Active = false;
	}

	// Mark as floating if requested
	if (isFloating)
	{
		m_contentSerializer->SetFloating(newID, true);
	}

	// Register this element with its parent
	m_contentSerializer->RegisterChildOfParent(parentID, newID);

	// Reflow the parent panel to recalculate positions and resize
	m_contentSerializer->ReflowPanel(parentID, m_gui.get());

	// Make this element the new selection
	m_selectedElementID = newID;

	// Mark as dirty
	m_contentSerializer->SetDirty(true);

	// Update property panel for the new element
	UpdatePropertyPanel();
	UpdateStatusFooter();

	// Sync scrollbar tracking variables after populating property panel
	// This prevents false "change" detections on first frame after insertion
	// (Static variables are declared at file scope)

	int columnsScrollbarID = m_propertySerializer->GetElementID("PROPERTY_COLUMNS");
	if (columnsScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(columnsScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			lastColumnsScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int horzPaddingScrollbarID = m_propertySerializer->GetElementID("PROPERTY_HORZ_PADDING");
	if (horzPaddingScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(horzPaddingScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			lastHorzPaddingScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int vertPaddingScrollbarID = m_propertySerializer->GetElementID("PROPERTY_VERT_PADDING");
	if (vertPaddingScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(vertPaddingScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			lastVertPaddingScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int fontSizeScrollbarID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
	if (fontSizeScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(fontSizeScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			lastFontSizeScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int widthScrollbarID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
	if (widthScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(widthScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			lastWidthScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int heightScrollbarID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
	if (heightScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(heightScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			lastHeightScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int valueRangeScrollbarID = m_propertySerializer->GetElementID("PROPERTY_VALUE_RANGE");
	if (valueRangeScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(valueRangeScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			lastValueRangeScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int textInputFontSizeScrollbarID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
	if (textInputFontSizeScrollbarID != -1)
	{
		auto elem = m_gui->GetElement(textInputFontSizeScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			lastTextInputFontSizeScrollbarValue = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	Log(elementTypeName + " inserted with ID: " + to_string(newID) + " as child of parent ID: " + to_string(parentID));
}

Font* GhostState::GetInheritedFont(int parentID, int& outFontSize, std::string& outFontName)
{
	// Build inherited properties from parent
	ghost_json inheritedProps = m_contentSerializer->BuildInheritedProps(parentID);

	// Check if we have inherited font properties
	if (inheritedProps.contains("font") && inheritedProps.contains("fontSize"))
	{
		string fontName = inheritedProps["font"].get<string>();
		int fontSize = inheritedProps["fontSize"].get<int>();

		// Load the font at the specified size
		string fontPath = m_fontPath + fontName;
		auto fontPtr = make_shared<Font>(LoadFontEx(fontPath.c_str(), fontSize, 0, 0));

		if (fontPtr->texture.id != 0)
		{
			// Store the font in m_preservedFonts to keep it alive
			m_preservedFonts.push_back(fontPtr);
			outFontSize = fontSize;
			outFontName = fontName;
			Log("GetInheritedFont: Loaded inherited font '" + fontName + "' at size " + to_string(fontSize) + " from parent " + to_string(parentID));
			return fontPtr.get();
		}
		else
		{
			Log("GetInheritedFont: Failed to load font '" + fontPath + "'");
		}
	}

	// No inherited font or failed to load - return nullptr
	outFontSize = 0;
	outFontName = "";
	return nullptr;
}

void GhostState::InsertPanel()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("panel");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Add a new panel at calculated position
	m_gui->AddPanel(ctx.newID, ctx.absoluteX, ctx.absoluteY, 200, 100, DARKGRAY, true, 0, true);

	// Set default layout to "horz", padding to 5, and columns to 2
	m_contentSerializer->SetPanelLayout(ctx.newID, "horz");
	m_contentSerializer->SetPanelHorzPadding(ctx.newID, 5);
	m_contentSerializer->SetPanelVertPadding(ctx.newID, 5);
	m_contentSerializer->SetPanelColumns(ctx.newID, 2);

	// Use helper to finalize insertion (panels are not floating)
	FinalizeInsert(ctx.newID, ctx.parentID, "Panel", false);
}

void GhostState::InsertLabel()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("label");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Try to get inherited font from parent
	int fontSize = 0;
	std::string fontName = "";
	Font* font = GetInheritedFont(ctx.parentID, fontSize, fontName);
	if (font == nullptr)
	{
		// No inherited font - use default GUI font
		font = m_gui->m_Font.get();
	}

	// Add a text area (label) at calculated position
	// Note: width parameter is multiplied by font baseSize in GuiTextArea
	// Measure the text and calculate the width and height parameters needed
	std::string labelText = "Label Text";
	Vector2 textDims = MeasureTextEx(*font, labelText.c_str(), font->baseSize, 1);
	int widthParam = int(textDims.x / font->baseSize) + 1;  // Add 1 for a bit of padding
	int heightParam = int(textDims.y);  // Use actual text height
	m_gui->AddTextArea(ctx.newID, font, labelText, ctx.absoluteX, ctx.absoluteY, widthParam, heightParam, WHITE, 0, 0, true, false);

	// Mark color as explicit so it gets saved (prevents inheriting dark colors from parent)
	m_contentSerializer->MarkPropertyAsExplicit(ctx.newID, "color");

	// Store the font information in the serializer if we got an inherited font
	if (fontSize > 0 && !fontName.empty())
	{
		m_contentSerializer->SetElementFontSize(ctx.newID, fontSize);
		m_contentSerializer->SetElementFont(ctx.newID, fontName);
	}

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "Label");
}

void GhostState::InsertButton()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("button");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Try to get inherited font from parent
	int fontSize = 0;
	std::string fontName = "";
	Font* font = GetInheritedFont(ctx.parentID, fontSize, fontName);
	if (font == nullptr)
	{
		// No inherited font - use default GUI font
		font = m_gui->m_Font.get();
	}

	// Add a text button at calculated position
	m_gui->AddTextButton(ctx.newID, ctx.absoluteX, ctx.absoluteY, "Button", font, WHITE, DARKGRAY, WHITE, 0, true);

	// Store the font information in the serializer if we got an inherited font
	if (fontSize > 0 && !fontName.empty())
	{
		m_contentSerializer->SetElementFontSize(ctx.newID, fontSize);
		m_contentSerializer->SetElementFont(ctx.newID, fontName);
	}

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "Button");
}

void GhostState::InsertSprite()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("sprite");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Get fallback sprite definition (48x48 yellow square from image.png)
	string filename;
	int x, y, width, height;
	SpriteUtils::GetFallbackForType("sprite", filename, x, y, width, height);

	Log("InsertSprite: Using fallback sprite: " + filename + " at (" + to_string(x) + "," + to_string(y) +
		") size " + to_string(width) + "x" + to_string(height));

	// Load sprite texture
	string spritePath = m_spritePath + filename;
	Texture* texture = g_ResourceManager->GetTexture(spritePath);

	// Create sprite with the specified source rectangle
	shared_ptr<Sprite> sprite = make_shared<Sprite>();
	sprite->m_texture = texture;
	sprite->m_sourceRect = Rectangle{
		static_cast<float>(x),
		static_cast<float>(y),
		static_cast<float>(width),
		static_cast<float>(height)
	};

	// Add sprite at calculated position
	m_gui->AddSprite(ctx.newID, ctx.absoluteX, ctx.absoluteY, sprite, 1.0f, 1.0f, WHITE, 0, true);

	// Store the sprite filename for serialization
	m_contentSerializer->SetSpriteName(ctx.newID, filename);

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "Sprite");
}

void GhostState::InsertTextInput()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("text input");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Try to get inherited font from parent
	int fontSize = 0;
	std::string fontName = "";
	Font* font = GetInheritedFont(ctx.parentID, fontSize, fontName);
	if (font == nullptr)
	{
		// No inherited font - use default GUI font
		font = m_gui->m_Font.get();
		fontSize = 20;  // Default font size
	}

	// Scale height based on font size (baseline is 20px for default font)
	int baseHeight = 20;
	int scaledHeight = baseHeight;
	if (fontSize != 20)
	{
		scaledHeight = (int)((float)baseHeight * ((float)fontSize / 20.0f));
	}

	// Add a text input field at calculated position
	m_gui->AddTextInput(ctx.newID, ctx.absoluteX, ctx.absoluteY, 150, scaledHeight, font, "", WHITE, WHITE, Color{0, 0, 0, 255}, 0, true);

	// Store the font information in the serializer if we got an inherited font
	if (fontSize > 0 && !fontName.empty())
	{
		m_contentSerializer->SetElementFontSize(ctx.newID, fontSize);
		m_contentSerializer->SetElementFont(ctx.newID, fontName);
	}

	// Disable the text input so it can't accept keyboard input (content is for display only)
	auto newElement = m_gui->GetElement(ctx.newID);
	if (newElement)
	{
		newElement->m_Active = false;
	}

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "Text input");
}

void GhostState::InsertCheckbox()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("checkbox");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Add a checkbox (simple box rendering, not sprites) at calculated position
	m_gui->AddCheckBox(ctx.newID, ctx.absoluteX, ctx.absoluteY, 20, 20, 1.0f, 1.0f, WHITE, 0, true);

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "Checkbox");
}

void GhostState::InsertRadioButton()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("radio button");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Add a radio button (simple circle rendering, not sprites) at calculated position
	m_gui->AddRadioButton(ctx.newID, ctx.absoluteX, ctx.absoluteY, 20, 20, 1.0f, 1.0f, WHITE, 0, true, false);

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "Radio button");
}

void GhostState::InsertIconButton()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("icon button");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Get fallback sprite definition for icon button (48x48 square from image.png)
	string filename;
	int x, y, width, height;
	SpriteUtils::GetFallbackForType("iconbutton", filename, x, y, width, height);

	// Load sprite texture
	string spritePath = m_spritePath + filename;
	Texture* texture = g_ResourceManager->GetTexture(spritePath);

	// Create sprite with the specified source rectangle
	shared_ptr<Sprite> sprite = make_shared<Sprite>();
	sprite->m_texture = texture;
	sprite->m_sourceRect = Rectangle{
		static_cast<float>(x),
		static_cast<float>(y),
		static_cast<float>(width),
		static_cast<float>(height)
	};

	// Add icon button at calculated position (using simple form with one sprite)
	m_gui->AddIconButton(ctx.newID, ctx.absoluteX, ctx.absoluteY, sprite, nullptr, nullptr, "", nullptr, WHITE, 1.0f, 0, true, false);

	// Store the sprite filename for serialization
	m_contentSerializer->SetSpriteName(ctx.newID, filename);

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "Icon button");
}

void GhostState::InsertScrollBar()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("scroll bar");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Add a scroll bar at calculated position (simple form, vertical by default)
	m_gui->AddScrollBar(ctx.newID, 100, ctx.absoluteX, ctx.absoluteY, 20, 100, true, WHITE, DARKGRAY, 0, true, false);

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "Scroll bar");
}

void GhostState::InsertOctagonBox()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("octagon box");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Load default border sprites for octagon box
	string defaultSpriteName = "image.png";
	string spritePath = m_spritePath + defaultSpriteName;
	Texture* texture = g_ResourceManager->GetTexture(spritePath);

	// Create 8 border sprites (all using same default image for now)
	vector<shared_ptr<Sprite>> borders;
	for (int i = 0; i < 8; i++)
	{
		shared_ptr<Sprite> sprite = make_shared<Sprite>();
		sprite->m_texture = texture;
		sprite->m_sourceRect = Rectangle{0, 0, float(texture->width), float(texture->height)};
		borders.push_back(sprite);
	}

	// Add octagon box at calculated position
	m_gui->AddOctagonBox(ctx.newID, ctx.absoluteX, ctx.absoluteY, 100, 100, borders, WHITE, 0, true);

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "Octagon box");
}

void GhostState::InsertStretchButton()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("stretch button");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Get fallback sprite definitions for left, center, and right
	string leftFilename, centerFilename, rightFilename;
	int leftX, leftY, leftW, leftH;
	int centerX, centerY, centerW, centerH;
	int rightX, rightY, rightW, rightH;

	SpriteUtils::GetFallbackForType("left", leftFilename, leftX, leftY, leftW, leftH);
	SpriteUtils::GetFallbackForType("center", centerFilename, centerX, centerY, centerW, centerH);
	SpriteUtils::GetFallbackForType("right", rightFilename, rightX, rightY, rightW, rightH);

	Log("InsertStretchButton: Left sprite: " + leftFilename + " (" + to_string(leftX) + "," + to_string(leftY) + " " + to_string(leftW) + "x" + to_string(leftH) + ")");
	Log("InsertStretchButton: Center sprite: " + centerFilename + " (" + to_string(centerX) + "," + to_string(centerY) + " " + to_string(centerW) + "x" + to_string(centerH) + ")");
	Log("InsertStretchButton: Right sprite: " + rightFilename + " (" + to_string(rightX) + "," + to_string(rightY) + " " + to_string(rightW) + "x" + to_string(rightH) + ")");

	// Load the texture
	string spritePath = m_spritePath + leftFilename;  // All use the same file (image.png)
	Texture* texture = g_ResourceManager->GetTexture(spritePath);

	// Create sprites for left, center, and right parts using fallback coordinates
	auto createSprite = [&](int x, int y, int w, int h) {
		shared_ptr<Sprite> sprite = make_shared<Sprite>();
		sprite->m_texture = texture;
		sprite->m_sourceRect = Rectangle{float(x), float(y), float(w), float(h)};
		return sprite;
	};

	shared_ptr<Sprite> activeLeft = createSprite(leftX, leftY, leftW, leftH);
	shared_ptr<Sprite> activeCenter = createSprite(centerX, centerY, centerW, centerH);
	shared_ptr<Sprite> activeRight = createSprite(rightX, rightY, rightW, rightH);
	shared_ptr<Sprite> inactiveLeft = createSprite(leftX, leftY, leftW, leftH);
	shared_ptr<Sprite> inactiveCenter = createSprite(centerX, centerY, centerW, centerH);
	shared_ptr<Sprite> inactiveRight = createSprite(rightX, rightY, rightW, rightH);

	// Add stretch button at calculated position
	m_gui->AddStretchButton(ctx.newID, ctx.absoluteX, ctx.absoluteY, 100, "Button",
		activeLeft, activeRight, activeCenter, inactiveLeft, inactiveRight, inactiveCenter,
		0, WHITE, 0, true, false);

	// Store sprite metadata so it can be serialized
	GhostSerializer::SpriteDefinition leftDef;
	leftDef.spritesheet = leftFilename;
	leftDef.x = leftX;
	leftDef.y = leftY;
	leftDef.w = leftW;
	leftDef.h = leftH;

	GhostSerializer::SpriteDefinition centerDef;
	centerDef.spritesheet = centerFilename;
	centerDef.x = centerX;
	centerDef.y = centerY;
	centerDef.w = centerW;
	centerDef.h = centerH;

	GhostSerializer::SpriteDefinition rightDef;
	rightDef.spritesheet = rightFilename;
	rightDef.x = rightX;
	rightDef.y = rightY;
	rightDef.w = rightW;
	rightDef.h = rightH;

	m_contentSerializer->SetStretchButtonLeftSprite(ctx.newID, leftDef);
	m_contentSerializer->SetStretchButtonCenterSprite(ctx.newID, centerDef);
	m_contentSerializer->SetStretchButtonRightSprite(ctx.newID, rightDef);

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "Stretch button");
}

void GhostState::InsertList()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("list");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Try to get inherited font from parent
	int fontSize = 0;
	std::string fontName = "";
	Font* font = GetInheritedFont(ctx.parentID, fontSize, fontName);
	if (font == nullptr)
	{
		// No inherited font - use default GUI font
		font = m_gui->m_Font.get();
	}

	// Add a list at calculated position with some default items
	vector<string> defaultItems = {"Item 1", "Item 2", "Item 3"};
	m_gui->AddGuiList(ctx.newID, ctx.absoluteX, ctx.absoluteY, 150, 100, font,
		defaultItems, WHITE, Color{0, 0, 0, 255}, WHITE, 0, true);

	// Store the font information in the serializer if we got an inherited font
	if (fontSize > 0 && !fontName.empty())
	{
		m_contentSerializer->SetElementFontSize(ctx.newID, fontSize);
		m_contentSerializer->SetElementFont(ctx.newID, fontName);
	}

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "List");
}

void GhostState::InsertListBox()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("listbox");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Try to get inherited font from parent
	int fontSize = 0;
	std::string fontName = "";
	Font* font = GetInheritedFont(ctx.parentID, fontSize, fontName);
	if (font == nullptr)
	{
		// No inherited font - use default GUI font
		font = m_gui->m_Font.get();
	}

	// Add a listbox at calculated position with some default items
	vector<string> defaultItems = {"Item 1", "Item 2", "Item 3"};
	m_gui->AddListBox(ctx.newID, ctx.absoluteX, ctx.absoluteY, 150, 200, font,
		defaultItems, WHITE, Color{80, 80, 80, 255}, WHITE, 0, true);

	// Store the font information in the serializer if we got an inherited font
	if (fontSize > 0 && !fontName.empty())
	{
		m_contentSerializer->SetElementFontSize(ctx.newID, fontSize);
		m_contentSerializer->SetElementFont(ctx.newID, fontName);
	}

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "ListBox");
}

void GhostState::InsertFileInclude()
{
	Log("Inserting file include - not yet implemented");
	// TODO: Show a file picker and insert an include element

	// Clear the active element to prevent infinite loop
	m_gui->m_ActiveElement = -1;
}

void GhostState::ClearPropertyPanel()
{
	if (!m_propertySerializer)
		return;

	// Get all property panel content elements (ID > 3000, not the container itself)
	vector<int> propertyIDs = m_propertySerializer->GetAllElementIDs();

	// Remove all property content elements from the GUI (but keep container ID 3000)
	for (int id : propertyIDs)
	{
		if (id > 3000)  // Only remove property content, not the container panel
		{
			auto element = m_gui->GetElement(id);
			if (element)
			{
				m_gui->m_GuiElementList.erase(id);
			}
		}
	}

	// Reset the property serializer
	m_propertySerializer.reset();
	m_propertySerializer = make_unique<GhostSerializer>();
	m_propertySerializer->SetAutoIDStart(3001);  // Content starts at 3001

	// Reset the last property element type so property panel will reload when needed
	m_lastPropertyElementType = -1;

	Log("Property panel cleared");
}

void GhostState::UpdatePropertyPanel()
{
	// Skip ID 2000 (content container) - it's just an internal layout container
	// Also skip if nothing is selected
	if (m_selectedElementID == -1 || m_selectedElementID == 2000)
	{
		if (m_lastPropertyElementType != -1)
		{
			ClearPropertyPanel();
			m_lastPropertyElementType = -1;
		}
		return;
	}

	// Get the selected element
	auto selectedElement = m_gui->GetElement(m_selectedElementID);
	if (!selectedElement)
		return;

	// Check if element type changed
	if (m_lastPropertyElementType == selectedElement->m_Type)
	{
		// Same type, no need to reload property panel, but DO need to repopulate fields
		PopulatePropertyPanelFields();
		return;
	}

	// Clear existing property panel
	ClearPropertyPanel();

	// Determine which property file to load based on element type
	string propertyFile;
	switch (selectedElement->m_Type)
	{
		case GUI_TEXTBUTTON:
			propertyFile = "Gui/ghost_prop_textbutton.ghost";
			break;
		case GUI_ICONBUTTON:
			propertyFile = "Gui/ghost_prop_iconbutton.ghost";
			break;
		case GUI_SCROLLBAR:
			propertyFile = "Gui/ghost_prop_scrollbar.ghost";
			break;
		case GUI_RADIOBUTTON:
			propertyFile = "Gui/ghost_prop_radiobutton.ghost";
			break;
		case GUI_CHECKBOX:
			propertyFile = "Gui/ghost_prop_checkbox.ghost";
			break;
		case GUI_TEXTINPUT:
			propertyFile = "Gui/ghost_prop_textinput.ghost";
			break;
		case GUI_PANEL:
			propertyFile = "Gui/ghost_prop_panel.ghost";
			break;
		case GUI_TEXTAREA:
			propertyFile = "Gui/ghost_prop_textarea.ghost";
			break;
		case GUI_SPRITE:
			propertyFile = "Gui/ghost_prop_sprite.ghost";
			break;
		case GUI_OCTAGONBOX:
			propertyFile = "Gui/ghost_prop_octagonbox.ghost";
			break;
		case GUI_STRETCHBUTTON:
			propertyFile = "Gui/ghost_prop_stretchbutton.ghost";
			break;
		case GUI_LIST:
			propertyFile = "Gui/ghost_prop_list.ghost";
			break;
		case GUI_LISTBOX:
			propertyFile = "Gui/ghost_prop_listbox.ghost";
			break;
		default:
			Log("No property panel for element type: " + to_string(selectedElement->m_Type));
			return;
	}

	// Find the property panel container (ID 3000) to get its position
	auto propertyContainer = m_gui->GetElement(3000);
	if (!propertyContainer)
	{
		Log("ERROR: Property panel container (ID 3000) not found!");
		return;
	}

	// Set the property panel container as the root element for this serializer
	// This allows GetAllElementIDs() to find all property panel elements when clearing
	m_propertySerializer->SetRootElementID(3000);

	// Load the property file into the property panel container
	// Use the container's position and make it the parent
	int containerX = static_cast<int>(propertyContainer->m_Pos.x);
	int containerY = static_cast<int>(propertyContainer->m_Pos.y);

	if (m_propertySerializer->LoadIntoPanel(propertyFile, m_gui.get(), containerX, containerY, 3000))
	{
		m_lastPropertyElementType = selectedElement->m_Type;
		Log("Loaded property panel: " + propertyFile);

		// Debug: Check ALL text inputs to see their IDs
		Log("=== Checking all text inputs after property panel load ===");
		for (auto& [id, element] : m_gui->m_GuiElementList)
		{
			if (element && element->m_Type == GUI_TEXTINPUT)
			{
				Log("Text input found: ID " + to_string(id) + ", Active: " + to_string(element->m_Active));
			}
		}
		Log("=== End of text input check ===");

		// Populate property panel fields with selected element's data
		PopulatePropertyPanelFields();

		// Preserve fonts from property serializer
		auto& fonts = m_propertySerializer->GetLoadedFonts();
		m_preservedFonts.insert(m_preservedFonts.end(), fonts.begin(), fonts.end());
	}
	else
	{
		Log("Failed to load property panel: " + propertyFile);
	}
}

std::string GhostState::GetElementName(int elementID)
{
	// Reverse lookup: find element name from ID in content serializer
	if (!m_contentSerializer)
		return "";

	// Search through the name->ID map to find the name for this ID
	for (const auto& [name, id] : m_contentSerializer->GetElementNameToIDMap())
	{
		if (id == elementID)
			return name;
	}
	return ""; // No name found
}

void GhostState::PopulatePropertyPanelFields()
{
	if (m_selectedElementID == -1)
		return;

	// Get the selected element once at the top
	auto selectedElement = m_gui->GetElement(m_selectedElementID);

	// Populate name property (every element has a name)
	std::string elementName = GetElementName(m_selectedElementID);
	Log("PopulatePropertyPanelFields: element " + to_string(m_selectedElementID) + " name is: '" + elementName + "'");
	PopulateTextInputProperty("PROPERTY_NAME", elementName);

	// Get the PROPERTY_TEXT input from property panel (for textarea and textbutton elements)
	int textInputID = m_propertySerializer->GetElementID("PROPERTY_TEXT");
	if (textInputID != -1)
	{
		auto textInput = m_gui->GetElement(textInputID);
		if (textInput && textInput->m_Type == GUI_TEXTINPUT)
		{
			if (selectedElement && (selectedElement->m_Type == GUI_TEXTAREA || selectedElement->m_Type == GUI_TEXTBUTTON))
			{
				// Both GuiTextArea and GuiTextButton have m_String member
				std::string elementText;
				if (selectedElement->m_Type == GUI_TEXTAREA)
				{
					auto textarea = static_cast<GuiTextArea*>(selectedElement.get());
					elementText = textarea->m_String;
				}
				else if (selectedElement->m_Type == GUI_TEXTBUTTON)
				{
					auto textbutton = static_cast<GuiTextButton*>(selectedElement.get());
					elementText = textbutton->m_String;
				}

				// Populate the input with the element's text
				auto propertyInput = static_cast<GuiTextInput*>(textInput.get());
				propertyInput->m_String = elementText;

				Log("Populated PROPERTY_TEXT with: " + elementText);
			}
		}
	}

	// Populate textarea properties (for textarea elements)
	if (selectedElement && selectedElement->m_Type == GUI_TEXTAREA)
	{
		auto textarea = static_cast<GuiTextArea*>(selectedElement.get());

		PopulateScrollbarProperty("PROPERTY_WIDTH", static_cast<int>(textarea->m_Width));
		PopulateScrollbarProperty("PROPERTY_HEIGHT", static_cast<int>(textarea->m_Height));
		PopulateTextInputProperty("PROPERTY_FONT", m_contentSerializer->GetElementFont(m_selectedElementID));
		PopulateScrollbarProperty("PROPERTY_FONT_SIZE", m_contentSerializer->GetElementFontSize(m_selectedElementID));
	}

	// Populate layout radio buttons and columns field (for panel elements)
	if (selectedElement && selectedElement->m_Type == GUI_PANEL)
	{
		// Get the panel's current layout
		std::string layout = m_contentSerializer->GetPanelLayout(m_selectedElementID);
		int columns = m_contentSerializer->GetPanelColumns(m_selectedElementID);

		Log("PopulatePropertyPanelFields: Panel layout='" + layout + "', columns=" + to_string(columns));

		// Set the appropriate radio button
		int horzRadioID = m_propertySerializer->GetElementID("PROPERTY_LAYOUT_HORZ");
		int vertRadioID = m_propertySerializer->GetElementID("PROPERTY_LAYOUT_VERT");
		int tableRadioID = m_propertySerializer->GetElementID("PROPERTY_LAYOUT_TABLE");

		Log("Radio button IDs: horz=" + to_string(horzRadioID) + ", vert=" + to_string(vertRadioID) + ", table=" + to_string(tableRadioID));

		// Debug: Log radio button and text input positions to check for overlaps
		auto logBounds = [this](const std::string& name, int id) {
			auto elem = m_gui->GetElement(id);
			if (elem) {
				float absX = m_gui->m_Pos.x + elem->m_Pos.x;
				float absY = m_gui->m_Pos.y + elem->m_Pos.y;
				Log("  " + name + " (ID " + to_string(id) + "): absPos(" + to_string(absX) + ", " + to_string(absY) +
					") size(" + to_string(elem->m_Width) + " x " + to_string(elem->m_Height) + ")");
			}
		};

		Log("Element bounds:");
		logBounds("HORZ radio", horzRadioID);
		logBounds("VERT radio", vertRadioID);
		logBounds("TABLE radio", tableRadioID);
		logBounds("COLUMNS input", m_propertySerializer->GetElementID("PROPERTY_COLUMNS"));

		// Set the correct radio button to selected (deselection happens in the loop below)
		int selectedRadioID = -1;
		if (layout == "horz") selectedRadioID = horzRadioID;
		else if (layout == "vert") selectedRadioID = vertRadioID;
		else if (layout == "table") selectedRadioID = tableRadioID;

		if (selectedRadioID != -1)
		{
			auto selectedRadio = m_gui->GetElement(selectedRadioID);
			if (selectedRadio && selectedRadio->m_Type == GUI_RADIOBUTTON)
			{
				// First deselect ALL radio buttons in this group (mimicking what radio button click does)
				for (auto& [id, element] : m_gui->m_GuiElementList)
				{
					if (element && element->m_Type == GUI_RADIOBUTTON && element->m_Group == selectedRadio->m_Group)
					{
						element->m_Selected = false;
					}
				}

				// Now select only the one we want
				selectedRadio->m_Selected = true;
				Log("Set radio button ID " + to_string(selectedRadioID) + " to SELECTED for layout: " + layout);

				// Verify all three radio buttons immediately after setting
				if (horzRadioID != -1) {
					auto radio = m_gui->GetElement(horzRadioID);
					if (radio) Log("  Verify: HORZ (3005) m_Selected=" + to_string(radio->m_Selected));
				}
				if (vertRadioID != -1) {
					auto radio = m_gui->GetElement(vertRadioID);
					if (radio) Log("  Verify: VERT (3007) m_Selected=" + to_string(radio->m_Selected));
				}
				if (tableRadioID != -1) {
					auto radio = m_gui->GetElement(tableRadioID);
					if (radio) Log("  Verify: TABLE (3009) m_Selected=" + to_string(radio->m_Selected));
				}
			}
		}

		// Populate columns field (can be textinput or scrollbar)
		PopulateIntProperty("PROPERTY_COLUMNS", columns);

		// Populate horizontal padding field (can be textinput or scrollbar)
		int horzPadding = m_contentSerializer->GetPanelHorzPadding(m_selectedElementID);
		PopulateIntProperty("PROPERTY_HORZ_PADDING", horzPadding);

		// Populate vertical padding field (can be textinput or scrollbar)
		int vertPadding = m_contentSerializer->GetPanelVertPadding(m_selectedElementID);
		PopulateIntProperty("PROPERTY_VERT_PADDING", vertPadding);

		Log("Finished populating layout properties - layout: " + layout + ", columns: " + to_string(columns));
	}

	// PROPERTY_SPRITE is now a button that opens the sprite picker dialog
	// No need to populate it - the sprite picker will load current values when opened

	// Populate font fields (for panels and text elements)
	PopulateFontProperty();
	PopulateFontSizeProperty();

	// Populate scrollbar/slider properties (for scrollbar elements)
	if (selectedElement && selectedElement->m_Type == GUI_SCROLLBAR)
	{
		auto scrollbar = static_cast<GuiScrollBar*>(selectedElement.get());

		PopulateScrollbarProperty("PROPERTY_WIDTH", static_cast<int>(scrollbar->m_Width));
		PopulateScrollbarProperty("PROPERTY_HEIGHT", static_cast<int>(scrollbar->m_Height));
		PopulateScrollbarProperty("PROPERTY_VALUE_RANGE", scrollbar->m_ValueRange);

		PopulateCheckboxProperty("PROPERTY_VERTICAL", scrollbar->m_Vertical);
	}

	// Populate textinput properties (for textinput elements)
	if (selectedElement && selectedElement->m_Type == GUI_TEXTINPUT)
	{
		auto textinput = static_cast<GuiTextInput*>(selectedElement.get());

		PopulateScrollbarProperty("PROPERTY_WIDTH", static_cast<int>(textinput->m_Width));
		PopulateScrollbarProperty("PROPERTY_HEIGHT", static_cast<int>(textinput->m_Height));
		PopulateTextInputProperty("PROPERTY_FONT", m_contentSerializer->GetElementFont(m_selectedElementID));
		PopulateScrollbarProperty("PROPERTY_FONT_SIZE", m_contentSerializer->GetElementFontSize(m_selectedElementID));
	}

	// Populate checkbox properties (for checkbox elements)
	if (selectedElement && selectedElement->m_Type == GUI_CHECKBOX)
	{
		auto checkbox = static_cast<GuiCheckBox*>(selectedElement.get());

		PopulateScrollbarProperty("PROPERTY_WIDTH", static_cast<int>(checkbox->m_Width));
		PopulateScrollbarProperty("PROPERTY_HEIGHT", static_cast<int>(checkbox->m_Height));
		PopulateGroupProperty(selectedElement.get());
	}

	// Populate radiobutton properties (for radiobutton elements)
	if (selectedElement && selectedElement->m_Type == GUI_RADIOBUTTON)
	{
		auto radiobutton = static_cast<GuiRadioButton*>(selectedElement.get());

		PopulateScrollbarProperty("PROPERTY_WIDTH", static_cast<int>(radiobutton->m_Width));
		PopulateScrollbarProperty("PROPERTY_HEIGHT", static_cast<int>(radiobutton->m_Height));
		PopulateGroupProperty(selectedElement.get());
	}

	// Populate iconbutton properties (for iconbutton elements)
	if (selectedElement && selectedElement->m_Type == GUI_ICONBUTTON)
	{
		auto iconbutton = static_cast<GuiIconButton*>(selectedElement.get());

		PopulateTextInputProperty("PROPERTY_SPRITE", m_contentSerializer->GetSpriteName(m_selectedElementID));
		PopulateTextInputProperty("PROPERTY_TEXT", iconbutton->m_String);
		PopulateScrollbarProperty("PROPERTY_SCALE", static_cast<int>(iconbutton->m_Scale * 10));
		PopulateCheckboxProperty("PROPERTY_CANBEHELD", iconbutton->m_CanBeHeld);
		PopulateGroupProperty(selectedElement.get());
	}

	// Populate octagonbox properties (for octagonbox elements)
	if (selectedElement && selectedElement->m_Type == GUI_OCTAGONBOX)
	{
		auto octagonbox = static_cast<GuiOctagonBox*>(selectedElement.get());

		PopulateScrollbarProperty("PROPERTY_WIDTH", static_cast<int>(octagonbox->m_Width));
		PopulateScrollbarProperty("PROPERTY_HEIGHT", static_cast<int>(octagonbox->m_Height));
		PopulateGroupProperty(selectedElement.get());
	}

	// Populate stretchbutton properties (for stretchbutton elements)
	if (selectedElement && selectedElement->m_Type == GUI_STRETCHBUTTON)
	{
		auto stretchbutton = static_cast<GuiStretchButton*>(selectedElement.get());

		PopulateTextInputProperty("PROPERTY_TEXT", stretchbutton->m_String);
		PopulateScrollbarProperty("PROPERTY_WIDTH", static_cast<int>(stretchbutton->m_Width));
		PopulateScrollbarProperty("PROPERTY_INDENT", stretchbutton->m_Indent);
		PopulateCheckboxProperty("PROPERTY_SHADOWED", stretchbutton->m_Shadowed);
		PopulateGroupProperty(selectedElement.get());

		// Sprite picker buttons will show sprite dialog when clicked (handled in Update)
	}

	// Populate list properties (for list elements)
	if (selectedElement && selectedElement->m_Type == GUI_LIST)
	{
		auto list = static_cast<GuiList*>(selectedElement.get());

		PopulateScrollbarProperty("PROPERTY_WIDTH", static_cast<int>(list->m_Width));
		PopulateScrollbarProperty("PROPERTY_HEIGHT", static_cast<int>(list->m_Height));
		PopulateTextInputProperty("PROPERTY_FONT", m_contentSerializer->GetElementFont(m_selectedElementID));
		PopulateScrollbarProperty("PROPERTY_FONT_SIZE", m_contentSerializer->GetElementFontSize(m_selectedElementID));
		PopulateGroupProperty(selectedElement.get());
	}

	// Populate listbox properties (for listbox elements)
	if (selectedElement && selectedElement->m_Type == GUI_LISTBOX)
	{
		auto listbox = static_cast<GuiListBox*>(selectedElement.get());

		PopulateScrollbarProperty("PROPERTY_WIDTH", static_cast<int>(listbox->m_Width));
		PopulateScrollbarProperty("PROPERTY_HEIGHT", static_cast<int>(listbox->m_Height));
		PopulateTextInputProperty("PROPERTY_FONT", m_contentSerializer->GetElementFont(m_selectedElementID));
		PopulateScrollbarProperty("PROPERTY_FONT_SIZE", m_contentSerializer->GetElementFontSize(m_selectedElementID));
	}

	// Update color picker button text colors to match the active colors
	if (selectedElement)
	{
		switch (selectedElement->m_Type)
		{
		case GUI_TEXTAREA:
			UpdateColorButton("PROPERTY_TEXTCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_TEXTCOLOR"));
			break;
		case GUI_PANEL:
			UpdateColorButton("PROPERTY_BACKGROUND", GetElementColor(selectedElement.get(), "PROPERTY_BACKGROUND"));
			break;
		case GUI_TEXTINPUT:
			UpdateColorButton("PROPERTY_TEXTCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_TEXTCOLOR"));
			UpdateColorButton("PROPERTY_BORDERCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_BORDERCOLOR"));
			UpdateColorButton("PROPERTY_BACKGROUNDCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_BACKGROUNDCOLOR"));
			break;
		case GUI_TEXTBUTTON:
			UpdateColorButton("PROPERTY_TEXTCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_TEXTCOLOR"));
			UpdateColorButton("PROPERTY_BORDERCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_BORDERCOLOR"));
			UpdateColorButton("PROPERTY_BACKGROUNDCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_BACKGROUNDCOLOR"));
			break;
		case GUI_SCROLLBAR:
			UpdateColorButton("PROPERTY_SPURCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_SPURCOLOR"));
			UpdateColorButton("PROPERTY_BACKGROUNDCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_BACKGROUNDCOLOR"));
			break;
		case GUI_ICONBUTTON:
			UpdateColorButton("PROPERTY_TEXTCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_TEXTCOLOR"));
			break;
		case GUI_OCTAGONBOX:
		case GUI_STRETCHBUTTON:
			UpdateColorButton("PROPERTY_COLOR", GetElementColor(selectedElement.get(), "PROPERTY_COLOR"));
			break;
		case GUI_LIST:
			UpdateColorButton("PROPERTY_TEXTCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_TEXTCOLOR"));
			UpdateColorButton("PROPERTY_BORDERCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_BORDERCOLOR"));
			UpdateColorButton("PROPERTY_BACKGROUNDCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_BACKGROUNDCOLOR"));
			break;
		case GUI_LISTBOX:
			UpdateColorButton("PROPERTY_TEXTCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_TEXTCOLOR"));
			UpdateColorButton("PROPERTY_BORDERCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_BORDERCOLOR"));
			UpdateColorButton("PROPERTY_BACKGROUNDCOLOR", GetElementColor(selectedElement.get(), "PROPERTY_BACKGROUNDCOLOR"));
			break;
		}
	}
}

void GhostState::UpdateElementFromPropertyPanel()
{
	int activeID = m_gui->GetActiveElementID();
	Log("UpdateElementFromPropertyPanel called, activeID=" + to_string(activeID) + ", selectedElementID=" + to_string(m_selectedElementID));

	if (m_selectedElementID == -1)
	{
		Log("  Skipping update: no element selected");
		return;
	}

	bool wasUpdated = false;

	// Get the selected element once at the top
	auto selectedElement = m_gui->GetElement(m_selectedElementID);

	// Update name property (every element has a name)
	if (UpdateNameProperty()) wasUpdated = true;

	// Update PROPERTY_TEXT if it exists (for textarea and textbutton elements)
	int textInputID = m_propertySerializer->GetElementID("PROPERTY_TEXT");
	if (textInputID != -1)
	{
		auto textInput = m_gui->GetElement(textInputID);
		if (textInput && textInput->m_Type == GUI_TEXTINPUT)
		{
			if (selectedElement && (selectedElement->m_Type == GUI_TEXTAREA || selectedElement->m_Type == GUI_TEXTBUTTON))
			{
				auto propertyInput = static_cast<GuiTextInput*>(textInput.get());
				std::string newText = propertyInput->m_String;

				if (selectedElement->m_Type == GUI_TEXTAREA)
				{
					auto textarea = static_cast<GuiTextArea*>(selectedElement.get());
					textarea->m_String = newText;

					// Recalculate the textarea's width based on the new text
					Vector2 textDims = MeasureTextEx(*textarea->m_Font, textarea->m_String.c_str(), textarea->m_Font->baseSize, 1);
					textarea->m_Width = textDims.x;

					Log("Updated textarea " + to_string(m_selectedElementID) + " text to: " + newText);
				}
				else if (selectedElement->m_Type == GUI_TEXTBUTTON)
				{
					auto textbutton = static_cast<GuiTextButton*>(selectedElement.get());
					textbutton->m_String = newText;

					// Recalculate the textbutton's width based on the new text
					Vector2 textDims = MeasureTextEx(*textbutton->m_Font, textbutton->m_String.c_str(), textbutton->m_Font->baseSize, 1);
					textbutton->m_Width = textDims.x;

					Log("Updated textbutton " + to_string(m_selectedElementID) + " text to: " + newText);
				}

				wasUpdated = true;
			}
		}
	}

	// Update layout properties if it's a panel
	if (selectedElement && selectedElement->m_Type == GUI_PANEL)
	{
		// Check which layout radio button is selected
		int horzRadioID = m_propertySerializer->GetElementID("PROPERTY_LAYOUT_HORZ");
		int vertRadioID = m_propertySerializer->GetElementID("PROPERTY_LAYOUT_VERT");
		int tableRadioID = m_propertySerializer->GetElementID("PROPERTY_LAYOUT_TABLE");

		Log("UpdateElementFromPropertyPanel reading radio buttons:");
		std::string newLayout = "";
		if (horzRadioID != -1)
		{
			auto horzRadio = m_gui->GetElement(horzRadioID);
			Log("  HORZ (3005) m_Selected=" + to_string(horzRadio ? horzRadio->m_Selected : -1));
			if (horzRadio && horzRadio->m_Selected) newLayout = "horz";
		}
		if (vertRadioID != -1)
		{
			auto vertRadio = m_gui->GetElement(vertRadioID);
			Log("  VERT (3007) m_Selected=" + to_string(vertRadio ? vertRadio->m_Selected : -1));
			if (vertRadio && vertRadio->m_Selected) newLayout = "vert";
		}
		if (tableRadioID != -1)
		{
			auto tableRadio = m_gui->GetElement(tableRadioID);
			Log("  TABLE (3009) m_Selected=" + to_string(tableRadio ? tableRadio->m_Selected : -1));
			if (tableRadio && tableRadio->m_Selected) newLayout = "table";
		}
		Log("  Determined newLayout='" + newLayout + "'");

		// Update layout if changed
		if (!newLayout.empty())
		{
			std::string oldLayout = m_contentSerializer->GetPanelLayout(m_selectedElementID);
			if (newLayout != oldLayout)
			{
				m_contentSerializer->SetPanelLayout(m_selectedElementID, newLayout);
				Log("Updated panel " + to_string(m_selectedElementID) + " layout from " + oldLayout + " to " + newLayout);
				wasUpdated = true;
			}
		}

		// Update columns if changed (can be textinput or scrollbar)
		int newColumns = 0;
		if (ReadIntProperty("PROPERTY_COLUMNS", newColumns) && newColumns > 0)
		{
			int oldColumns = m_contentSerializer->GetPanelColumns(m_selectedElementID);
			if (newColumns != oldColumns)
			{
				m_contentSerializer->SetPanelColumns(m_selectedElementID, newColumns);
				Log("Updated panel " + to_string(m_selectedElementID) + " columns from " + to_string(oldColumns) + " to " + to_string(newColumns));
				wasUpdated = true;
			}
		}

		// Update horizontal padding if changed (can be textinput or scrollbar)
		int newHorzPadding = 0;
		if (ReadIntProperty("PROPERTY_HORZ_PADDING", newHorzPadding) && newHorzPadding >= 0)
		{
			int oldHorzPadding = m_contentSerializer->GetPanelHorzPadding(m_selectedElementID);
			if (newHorzPadding != oldHorzPadding)
			{
				m_contentSerializer->SetPanelHorzPadding(m_selectedElementID, newHorzPadding);
				Log("Updated panel " + to_string(m_selectedElementID) + " horz padding from " + to_string(oldHorzPadding) + " to " + to_string(newHorzPadding));
				wasUpdated = true;
			}
		}

		// Update vertical padding if changed (can be textinput or scrollbar)
		int newVertPadding = 0;
		if (ReadIntProperty("PROPERTY_VERT_PADDING", newVertPadding) && newVertPadding >= 0)
		{
			int oldVertPadding = m_contentSerializer->GetPanelVertPadding(m_selectedElementID);
			if (newVertPadding != oldVertPadding)
			{
				m_contentSerializer->SetPanelVertPadding(m_selectedElementID, newVertPadding);
				Log("Updated panel " + to_string(m_selectedElementID) + " vert padding from " + to_string(oldVertPadding) + " to " + to_string(newVertPadding));
				wasUpdated = true;
			}
		}

	}

	// Update font if changed (applies to all element types that have fonts)
	if (UpdateFontProperty()) wasUpdated = true;

	// Update font size if changed (applies to all element types that have fonts)
	if (UpdateFontSizeProperty()) wasUpdated = true;

	// Update scrollbar/slider properties if changed
	if (selectedElement && selectedElement->m_Type == GUI_SCROLLBAR)
	{
		auto scrollbar = static_cast<GuiScrollBar*>(selectedElement.get());

		if (UpdateWidthProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateHeightProperty(selectedElement.get())) wasUpdated = true;

		// Update PROPERTY_VALUE_RANGE
		int valueRangeInputID = m_propertySerializer->GetElementID("PROPERTY_VALUE_RANGE");
		if (valueRangeInputID != -1)
		{
			auto valueRangeInput = m_gui->GetElement(valueRangeInputID);
			if (valueRangeInput && valueRangeInput->m_Type == GUI_SCROLLBAR)
			{
				auto valueRangeScrollbar = static_cast<GuiScrollBar*>(valueRangeInput.get());
				int newValueRange = valueRangeScrollbar->m_Value;
				if (newValueRange > 0 && newValueRange != scrollbar->m_ValueRange)
				{
					scrollbar->m_ValueRange = newValueRange;
					// Clamp the current value to the new range
					if (scrollbar->m_Value > scrollbar->m_ValueRange)
					{
						scrollbar->m_Value = scrollbar->m_ValueRange;
					}
					Log("Updated scrollbar " + to_string(m_selectedElementID) + " value range to " + to_string(newValueRange));
					wasUpdated = true;
				}
			}
		}

		// Update PROPERTY_VERTICAL checkbox
		int verticalCheckboxID = m_propertySerializer->GetElementID("PROPERTY_VERTICAL");
		if (verticalCheckboxID != -1)
		{
			auto verticalCheckbox = m_gui->GetElement(verticalCheckboxID);
			if (verticalCheckbox && verticalCheckbox->m_Type == GUI_CHECKBOX)
			{
				bool newVertical = verticalCheckbox->m_Selected;
				if (newVertical != scrollbar->m_Vertical)
				{
					scrollbar->m_Vertical = newVertical;

					// Swap width and height when changing orientation
					float oldWidth = scrollbar->m_Width;
					float oldHeight = scrollbar->m_Height;
					scrollbar->m_Width = oldHeight;
					scrollbar->m_Height = oldWidth;

					Log("Updated scrollbar " + to_string(m_selectedElementID) + " vertical to " + to_string(newVertical) +
					    ", swapped dimensions: width=" + to_string(scrollbar->m_Width) + ", height=" + to_string(scrollbar->m_Height));

					// Update the property panel scrollbars to reflect the swapped dimensions
					int widthInputID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
					if (widthInputID != -1)
					{
						auto widthInput = m_gui->GetElement(widthInputID);
						if (widthInput && widthInput->m_Type == GUI_SCROLLBAR)
						{
							auto widthScrollbar = static_cast<GuiScrollBar*>(widthInput.get());
							widthScrollbar->m_Value = static_cast<int>(scrollbar->m_Width);
						}
					}

					int heightInputID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
					if (heightInputID != -1)
					{
						auto heightInput = m_gui->GetElement(heightInputID);
						if (heightInput && heightInput->m_Type == GUI_SCROLLBAR)
						{
							auto heightScrollbar = static_cast<GuiScrollBar*>(heightInput.get());
							heightScrollbar->m_Value = static_cast<int>(scrollbar->m_Height);
						}
					}

					wasUpdated = true;
				}
			}
		}
	}

	// Update textinput properties if changed
	if (selectedElement && selectedElement->m_Type == GUI_TEXTINPUT)
	{
		if (UpdateWidthProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateHeightProperty(selectedElement.get())) wasUpdated = true;
		// Font and font size are already handled by UpdateFontProperty() and UpdateFontSizeProperty() above
	}

	// Update checkbox properties if changed
	if (selectedElement && selectedElement->m_Type == GUI_CHECKBOX)
	{
		if (UpdateWidthProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateHeightProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateGroupProperty(selectedElement.get())) wasUpdated = true;
	}

	// Update radiobutton properties if changed
	if (selectedElement && selectedElement->m_Type == GUI_RADIOBUTTON)
	{
		if (UpdateWidthProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateHeightProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateGroupProperty(selectedElement.get())) wasUpdated = true;
	}

	// Update iconbutton properties
	if (selectedElement && selectedElement->m_Type == GUI_ICONBUTTON)
	{
		auto iconbutton = static_cast<GuiIconButton*>(selectedElement.get());

		if (UpdateTextInputProperty("PROPERTY_TEXT", iconbutton->m_String)) wasUpdated = true;

		// Update PROPERTY_SCALE
		int scaleInputID = m_propertySerializer->GetElementID("PROPERTY_SCALE");
		if (scaleInputID != -1)
		{
			auto scaleInput = m_gui->GetElement(scaleInputID);
			if (scaleInput && scaleInput->m_Type == GUI_SCROLLBAR)
			{
				auto scaleScrollbar = static_cast<GuiScrollBar*>(scaleInput.get());
				float newScale = scaleScrollbar->m_Value / 10.0f; // Map 0-100 to 0-10
				if (iconbutton->m_Scale != newScale)
				{
					iconbutton->m_Scale = newScale;
					Log("Updated iconbutton " + to_string(m_selectedElementID) + " scale to: " + to_string(newScale));
					wasUpdated = true;
				}
			}
		}

		if (UpdateCheckboxProperty("PROPERTY_CANBEHELD", iconbutton->m_CanBeHeld)) wasUpdated = true;
		if (UpdateGroupProperty(selectedElement.get())) wasUpdated = true;
	}

	// Update octagonbox properties
	if (selectedElement && selectedElement->m_Type == GUI_OCTAGONBOX)
	{
		if (UpdateWidthProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateHeightProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateGroupProperty(selectedElement.get())) wasUpdated = true;
	}

	// Update stretchbutton properties
	if (selectedElement && selectedElement->m_Type == GUI_STRETCHBUTTON)
	{
		auto stretchbutton = static_cast<GuiStretchButton*>(selectedElement.get());

		if (UpdateTextInputProperty("PROPERTY_TEXT", stretchbutton->m_String)) wasUpdated = true;
		if (UpdateWidthProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateScrollbarProperty("PROPERTY_INDENT", stretchbutton->m_Indent)) wasUpdated = true;
		if (UpdateCheckboxProperty("PROPERTY_SHADOWED", stretchbutton->m_Shadowed)) wasUpdated = true;
		if (UpdateGroupProperty(selectedElement.get())) wasUpdated = true;

		// Sprite filenames updated via sprite picker dialog (handled in Update with button clicks)
	}

	// Update list properties
	if (selectedElement && selectedElement->m_Type == GUI_LIST)
	{
		if (UpdateWidthProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateHeightProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateGroupProperty(selectedElement.get())) wasUpdated = true;
		// Font and font size are already handled by UpdateFontProperty() and UpdateFontSizeProperty() above
	}

	// Update textarea properties if changed
	if (selectedElement && selectedElement->m_Type == GUI_TEXTAREA)
	{
		if (UpdateWidthProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateHeightProperty(selectedElement.get())) wasUpdated = true;
		// Font and font size are already handled by UpdateFontProperty() and UpdateFontSizeProperty() above
	}

	// Update listbox properties if changed
	if (selectedElement && selectedElement->m_Type == GUI_LISTBOX)
	{
		if (UpdateWidthProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateHeightProperty(selectedElement.get())) wasUpdated = true;
		// Font and font size are already handled by UpdateFontProperty() and UpdateFontSizeProperty() above
	}

	// PROPERTY_SPRITE is now a button that opens the sprite picker dialog
	// Sprite updates are handled when returning from SpritePickerState

	// Always reflow after any update - just do it, don't be fancy
	if (selectedElement)
	{
		// If the selected element is a panel, reflow it directly
		if (selectedElement->m_Type == GUI_PANEL)
		{
			m_contentSerializer->ReflowPanel(m_selectedElementID, m_gui.get());
			Log("Reflowed panel " + to_string(m_selectedElementID) + " after update");
		}
		// Otherwise, reflow its parent panel
		else
		{
			int parentID = m_contentSerializer->GetParentID(m_selectedElementID);
			if (parentID != -1)
			{
				m_contentSerializer->ReflowPanel(parentID, m_gui.get());
				Log("Reflowed parent panel " + to_string(parentID) + " after update");
			}
		}
	}

	// Mark as dirty so user knows to save
	if (wasUpdated)
	{
		m_contentSerializer->SetDirty(true);

		// Update status footer to reflect any changes (especially name changes)
		UpdateStatusFooter();
	}
}

void GhostState::PushUndoState()
{
	if (!m_contentSerializer)
		return;

	// Get the root element ID
	int rootID = m_contentSerializer->GetRootElementID();
	if (rootID == -1)
	{
		Log("No root element to save undo state");
		return;
	}

	// Serialize the entire content tree
	ghost_json undoState = m_contentSerializer->SerializeElement(rootID, m_gui.get(), 0, 0);
	if (undoState.is_null())
	{
		Log("Failed to serialize undo state");
		return;
	}

	// Add to undo stack
	m_undoStack.push_back(undoState);

	// Limit stack size
	if (m_undoStack.size() > MAX_UNDO_LEVELS)
	{
		m_undoStack.erase(m_undoStack.begin());
	}

	// Clear redo stack since we made a new change
	m_redoStack.clear();

	Log("Undo state saved (stack size: " + to_string(m_undoStack.size()) + ")");
}

void GhostState::Undo()
{
	if (m_undoStack.empty())
	{
		Log("Undo stack is empty");
		return;
	}

	if (!m_contentSerializer)
	{
		Log("No content serializer for undo");
		return;
	}

	// Save current state to redo stack first
	int rootID = m_contentSerializer->GetRootElementID();
	if (rootID != -1)
	{
		ghost_json redoState = m_contentSerializer->SerializeElement(rootID, m_gui.get(), 0, 0);
		if (!redoState.is_null())
		{
			m_redoStack.push_back(redoState);

			// Limit redo stack size
			if (m_redoStack.size() > MAX_UNDO_LEVELS)
			{
				m_redoStack.erase(m_redoStack.begin());
			}
		}
	}

	// Pop state from undo stack
	ghost_json undoState = m_undoStack.back();
	m_undoStack.pop_back();

	// Clear current content
	std::vector<int> allIDs = m_contentSerializer->GetAllElementIDs();
	for (int id : allIDs)
	{
		if (id >= 2001)  // Remove all content elements
		{
			m_gui->m_GuiElementList.erase(id);
		}
	}

	// Clear selection and property panel
	m_selectedElementID = -1;
	ClearPropertyPanel();

	// Reset content serializer
	m_contentSerializer.reset();
	m_contentSerializer = make_unique<GhostSerializer>();
	m_contentSerializer->SetAutoIDStart(2001);

	// Restore the undo state
	ghost_json tempJson;
	tempJson["gui"]["elements"] = ghost_json::array();
	tempJson["gui"]["elements"].push_back(undoState);

	if (m_contentSerializer->ParseJson(tempJson, m_gui.get()))
	{
		Log("Undo successful (undo stack: " + to_string(m_undoStack.size()) + ", redo stack: " + to_string(m_redoStack.size()) + ")");
		m_contentSerializer->SetDirty(true);
	}
	else
	{
		Log("Failed to restore undo state");
	}
}

void GhostState::Redo()
{
	if (m_redoStack.empty())
	{
		Log("Redo stack is empty");
		return;
	}

	if (!m_contentSerializer)
	{
		Log("No content serializer for redo");
		return;
	}

	// Save current state to undo stack first
	int rootID = m_contentSerializer->GetRootElementID();
	if (rootID != -1)
	{
		ghost_json undoState = m_contentSerializer->SerializeElement(rootID, m_gui.get(), 0, 0);
		if (!undoState.is_null())
		{
			m_undoStack.push_back(undoState);

			// Limit undo stack size
			if (m_undoStack.size() > MAX_UNDO_LEVELS)
			{
				m_undoStack.erase(m_undoStack.begin());
			}
		}
	}

	// Pop state from redo stack
	ghost_json redoState = m_redoStack.back();
	m_redoStack.pop_back();

	// Clear current content
	std::vector<int> allIDs = m_contentSerializer->GetAllElementIDs();
	for (int id : allIDs)
	{
		if (id >= 2001)  // Remove all content elements
		{
			m_gui->m_GuiElementList.erase(id);
		}
	}

	// Clear selection and property panel
	m_selectedElementID = -1;
	ClearPropertyPanel();

	// Reset content serializer
	m_contentSerializer.reset();
	m_contentSerializer = make_unique<GhostSerializer>();
	m_contentSerializer->SetAutoIDStart(2001);

	// Restore the redo state
	ghost_json tempJson;
	tempJson["gui"]["elements"] = ghost_json::array();
	tempJson["gui"]["elements"].push_back(redoState);

	if (m_contentSerializer->ParseJson(tempJson, m_gui.get()))
	{
		Log("Redo successful (undo stack: " + to_string(m_undoStack.size()) + ", redo stack: " + to_string(m_redoStack.size()) + ")");
		m_contentSerializer->SetDirty(true);
	}
	else
	{
		Log("Failed to restore redo state");
	}
}

void GhostState::UpdateStatusFooter()
{
	// Don't update if content serializer isn't initialized yet
	if (!m_contentSerializer)
	{
		return;
	}

	// Get the status footer element (ID 4000)
	auto footer = m_gui->GetElement(4000);
	if (!footer || footer->m_Type != GUI_TEXTAREA)
	{
		return;
	}

	auto footerText = static_cast<GuiTextArea*>(footer.get());

	// If no element selected, clear the footer
	if (m_selectedElementID == -1)
	{
		footerText->m_String = "";
		return;
	}

	// Get the selected element
	auto selectedElement = m_gui->GetElement(m_selectedElementID);
	if (!selectedElement)
	{
		footerText->m_String = "";
		return;
	}

	// Get element type name
	std::string typeName;
	switch (selectedElement->m_Type)
	{
		case GUI_PANEL: typeName = "Panel"; break;
		case GUI_TEXTAREA: typeName = "TextArea"; break;
		case GUI_TEXTINPUT: typeName = "TextInput"; break;
		case GUI_TEXTBUTTON: typeName = "TextButton"; break;
		case GUI_ICONBUTTON: typeName = "IconButton"; break;
		case GUI_SCROLLBAR: typeName = "ScrollBar"; break;
		case GUI_RADIOBUTTON: typeName = "RadioButton"; break;
		case GUI_CHECKBOX: typeName = "CheckBox"; break;
		case GUI_SPRITE: typeName = "Sprite"; break;
		case GUI_OCTAGONBOX: typeName = "OctagonBox"; break;
		case GUI_STRETCHBUTTON: typeName = "StretchButton"; break;
		case GUI_LIST: typeName = "List"; break;
		case GUI_LISTBOX: typeName = "ListBox"; break;
		default: typeName = "Unknown"; break;
	}

	// Get element name
	std::string elementName = GetElementName(m_selectedElementID);
	if (elementName.empty())
	{
		elementName = "(unnamed)";
	}

	// Build the status string
	footerText->m_String = typeName + " Name: " + elementName + " ID: " + to_string(m_selectedElementID);
}
