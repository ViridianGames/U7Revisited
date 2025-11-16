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
static int lastLayoutListValue = -1;
static int lastJustifyListValue = -1;

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
	std::string ghostPath = config->GetString("GhostPath");

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

	if (ghostPath.empty())
	{
		ghostPath = "Gui/Ghost/";
		Log("GhostPath not found in config, using default: " + ghostPath);
	}
	else
	{
		// Ensure path ends with a separator
		if (!ghostPath.empty() && ghostPath.back() != '/' && ghostPath.back() != '\\')
		{
			ghostPath += "/";
		}
		Log("GhostPath from config: " + ghostPath);
	}

	// Set the resource paths in GhostSerializer so they can be used for loading
	GhostSerializer::SetBaseFontPath(m_fontPath);
	GhostSerializer::SetBaseSpritePath(m_spritePath);
	GhostSerializer::SetBaseGhostPath(ghostPath);

	// Create the main GUI
	m_gui = make_unique<Gui>();
	m_gui->m_Pos = {0, 0};

	// Create serializer (keep it alive to preserve loaded fonts)
	m_serializer = make_unique<GhostSerializer>();

	// Enable "example" placeholder text for empty textinput fields (Ghost editor only)
	m_serializer->SetUseExampleText(true);

	// Load GUI from JSON file
	if (!m_serializer->LoadFromFile(GhostSerializer::GetBaseGhostPath() + "ghost_app.ghost", m_gui.get()))
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

	// Populate the element hierarchy listbox with the initial root container
	// This must come after m_propertySerializer is initialized
	PopulateElementHierarchy();

	// Select the root element automatically on startup
	if (!m_elementIDList.empty())
	{
		int rootID = m_elementIDList[0];  // First element is always the root
		m_selectedElementID = rootID;
		UpdatePropertyPanel();
		UpdateStatusFooter();

		// Also select it in the hierarchy listbox
		auto listboxElement = m_gui->GetElement(1501);
		if (listboxElement && listboxElement->m_Type == GUI_LISTBOX)
		{
			auto listbox = static_cast<GuiListBox*>(listboxElement.get());
			listbox->SetSelectedIndex(0);
		}
	}
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

// Helper to find next element to select after deleting/cutting current element
int GhostState::FindNextSelectionAfterRemoval(int elementID, int parentID)
{
	int newSelection = -1;
	if (parentID != -1)
	{
		auto& siblings = m_contentSerializer->GetChildren(parentID);
		// Find the element's position in sibling list
		for (size_t i = 0; i < siblings.size(); i++)
		{
			if (siblings[i] == elementID)
			{
				// Select next sibling if available, otherwise previous sibling
				if (i + 1 < siblings.size())
					newSelection = siblings[i + 1];
				else if (i > 0)
					newSelection = siblings[i - 1];
				else
					newSelection = parentID; // No siblings, select parent
				break;
			}
		}
	}
	return newSelection;
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

				// DEBUG: Check if the old name actually maps to THIS element
				if (!oldName.empty())
				{
					int mappedID = m_contentSerializer->GetElementID(oldName);
					if (mappedID != m_selectedElementID)
					{
						Log("WARNING: oldName '" + oldName + "' maps to element " + to_string(mappedID) + ", but selected element is " + to_string(m_selectedElementID));
						Log("This indicates the name mapping is incorrect - skipping name removal to preserve correct mapping");
					}
					else
					{
						// Only remove if it actually maps to this element
						m_contentSerializer->RemoveElementName(oldName);
					}
				}

				// Set new name mapping if not empty
				if (!newName.empty())
				{
					// Check if the new name already exists and points to a different element
					int existingID = m_contentSerializer->GetElementID(newName);
					if (existingID != -1 && existingID != m_selectedElementID)
					{
						Log("ERROR: Name '" + newName + "' already exists for element " + to_string(existingID) + " - cannot rename element " + to_string(m_selectedElementID));
						// Revert the text input to show the old name
						textInput->m_String = oldName;
						return false;
					}

					// Safe to set the new name
					m_contentSerializer->SetElementName(newName, m_selectedElementID);
				}

				// Update the element hierarchy listbox to show the new name
				PopulateElementHierarchy();
				UpdateElementHierarchySelection();

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
			auto textInput = static_cast<GuiTextInput*>(fontInput.get());

			// Only populate if font is explicitly set (not inherited)
			if (m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "font"))
			{
				std::string font = m_contentSerializer->GetElementFont(m_selectedElementID);
				textInput->m_String = font;
				Log("Populated PROPERTY_FONT with explicit value: " + font);
			}
			else
			{
				textInput->m_String = "";
				Log("PROPERTY_FONT cleared (property is inherited, not explicit)");
			}
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

		// Only populate if fontSize is explicitly set (not inherited)
		int fontSize = 0;
		if (m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "fontSize"))
		{
			fontSize = m_contentSerializer->GetElementFontSize(m_selectedElementID);
		}

		if (fontSizeInput && fontSizeInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(fontSizeInput.get());
			if (fontSize != 0)
			{
				textInput->m_String = to_string(fontSize);
				Log("Populated PROPERTY_FONT_SIZE with explicit value: " + to_string(fontSize));
			}
			else
			{
				textInput->m_String = "";
				Log("PROPERTY_FONT_SIZE cleared (property is inherited, not explicit)");
			}
		}
		else if (fontSizeInput && fontSizeInput->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(fontSizeInput.get());
			if (fontSize != 0)
			{
				scrollbar->m_Value = fontSize;
				Log("Populated PROPERTY_FONT_SIZE scrollbar with explicit value: " + to_string(fontSize));
			}
			else
			{
				scrollbar->m_Value = 0;
				Log("PROPERTY_FONT_SIZE scrollbar cleared (property is inherited, not explicit)");
			}
		}
	}
}

// Control-type-specific font update helpers
// Each function handles ALL font-related updates for that control type

void GhostState::UpdateTextButtonFont(GuiTextButton* button, Font* font)
{
	button->m_Font = font;
	// Recalculate textbutton dimensions with new font
	Vector2 textDims = MeasureTextEx(*button->m_Font, button->m_String.c_str(), button->m_Font->baseSize, 1);
	button->m_Width = textDims.x;
	button->m_Height = textDims.y;
}

void GhostState::UpdateIconButtonFont(GuiIconButton* button, Font* font)
{
	button->m_Font = font;
}

void GhostState::UpdateTextInputFont(GuiTextInput* input, Font* font)
{
	input->m_Font = font;
	// Recalculate textinput height to accommodate new font size
	float minHeight = static_cast<float>(input->m_Font->baseSize) + 4.0f;
	if (input->m_Height < minHeight)
	{
		input->m_Height = minHeight;

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
}

void GhostState::UpdateTextAreaFont(GuiTextArea* textarea, Font* font)
{
	textarea->m_Font = font;
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
}

void GhostState::UpdateListFont(GuiList* list, Font* font)
{
	list->m_Font = font;
}

void GhostState::UpdateListBoxFont(GuiListBox* listbox, Font* font)
{
	listbox->m_Font = font;
	// Recalculate item height and visible item count based on new font
	listbox->m_ItemHeight = font->baseSize + 4;
	listbox->m_VisibleItemCount = static_cast<int>(listbox->m_Height / listbox->m_ItemHeight);
}

void GhostState::UpdatePanelFont(GuiPanel* panel, Font* font, int panelID)
{
	// Update the panel itself
	panel->m_Font = font;

	// Update children that inherit (don't have explicit font/fontSize)
	std::vector<int> allIDs = m_contentSerializer->GetAllElementIDs();
	for (int childID : allIDs)
	{
		if (m_contentSerializer->GetParentID(childID) == panelID)
		{
			bool hasExplicitFont = m_contentSerializer->IsPropertyExplicit(childID, "font");
			bool hasExplicitSize = m_contentSerializer->IsPropertyExplicit(childID, "fontSize");

			if (!hasExplicitFont && !hasExplicitSize)
			{
				ApplyFontToElement(childID, font);  // Recursive dispatch
			}
		}
	}
}

void GhostState::ApplyFontToElement(int elementID, Font* fontPtr)
{
	auto elem = m_gui->GetElement(elementID);
	if (!elem) return;

	switch (elem->m_Type)
	{
	case GUI_TEXTBUTTON:
		UpdateTextButtonFont(static_cast<GuiTextButton*>(elem.get()), fontPtr);
		break;
	case GUI_ICONBUTTON:
		UpdateIconButtonFont(static_cast<GuiIconButton*>(elem.get()), fontPtr);
		break;
	case GUI_TEXTINPUT:
		UpdateTextInputFont(static_cast<GuiTextInput*>(elem.get()), fontPtr);
		break;
	case GUI_TEXTAREA:
		UpdateTextAreaFont(static_cast<GuiTextArea*>(elem.get()), fontPtr);
		break;
	case GUI_LIST:
		UpdateListFont(static_cast<GuiList*>(elem.get()), fontPtr);
		break;
	case GUI_LISTBOX:
		UpdateListBoxFont(static_cast<GuiListBox*>(elem.get()), fontPtr);
		break;
	case GUI_PANEL:
		UpdatePanelFont(static_cast<GuiPanel*>(elem.get()), fontPtr, elementID);
		break;
	default:
		break;
	}
}

// Helper to update font property from property panel
// Returns true if the property was updated
bool GhostState::UpdateFontProperty()
{
	// 1. Get new font value from UI
	int fontInputID = m_propertySerializer->GetElementID("PROPERTY_FONT");
	if (fontInputID == -1 || m_selectedElementID == -1) return false;

	auto fontInput = m_gui->GetElement(fontInputID);
	if (!fontInput || fontInput->m_Type != GUI_TEXTINPUT) return false;

	std::string newFont = static_cast<GuiTextInput*>(fontInput.get())->m_String;

	// 2. If the textinput is empty, this means the font is inherited - no change needed
	if (newFont.empty()) return false;

	// 3. Compare with old value
	std::string oldFont = m_contentSerializer->ResolveStringProperty(m_selectedElementID, "font");
	if (oldFont.empty()) oldFont = "babyblocks.ttf";
	if (newFont == oldFont) return false;

	// 3. Load font with CURRENT font size
	int fontSize = m_contentSerializer->ResolveIntProperty(m_selectedElementID, "fontSize", 16);
	std::string fontPath = m_fontPath + newFont;
	auto newFontPtr = std::make_shared<Font>(LoadFontEx(fontPath.c_str(), fontSize, 0, 0));

	// 4. Apply to element (dispatcher handles everything)
	ApplyFontToElement(m_selectedElementID, newFontPtr.get());

	// 5. Save changes
	m_preservedFonts.push_back(newFontPtr);
	m_contentSerializer->SetElementFont(m_selectedElementID, newFont);

	Log("Updated element " + to_string(m_selectedElementID) + " font to: " + newFont);
	return true;
}

// Helper to update font size property from property panel
// Returns true if the property was updated
bool GhostState::UpdateFontSizeProperty()
{
	// 1. Get new fontSize value from UI (TextInput OR ScrollBar)
	int fontSizeInputID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
	if (fontSizeInputID == -1 || m_selectedElementID == -1) return false;

	auto fontSizeInput = m_gui->GetElement(fontSizeInputID);
	if (!fontSizeInput) return false;

	int newFontSize = 0;
	if (fontSizeInput->m_Type == GUI_TEXTINPUT)
	{
		try { newFontSize = std::stoi(static_cast<GuiTextInput*>(fontSizeInput.get())->m_String); }
		catch (...) { return false; }
	}
	else if (fontSizeInput->m_Type == GUI_SCROLLBAR)
	{
		auto scrollbar = static_cast<GuiScrollBar*>(fontSizeInput.get());
		newFontSize = scrollbar->m_Value;

		// Map scrollbar value: 0 = inherited, 1-9 = snap to 10 (minimum explicit size)
		// Update the scrollbar to reflect the snapped value
		if (newFontSize > 0 && newFontSize < 10)
		{
			newFontSize = 10;
			scrollbar->m_Value = 10;  // Update scrollbar to show 10
		}
	}

	// 2. Compare with old value
	int oldFontSize = m_contentSerializer->GetElementFontSize(m_selectedElementID);
	if (newFontSize == oldFontSize) return false;

	// 3. If newFontSize is 0, clear the explicit property (make it inherited)
	if (newFontSize == 0)
	{
		// Clear the explicit fontSize property
		m_contentSerializer->ClearElementFontSize(m_selectedElementID);

		// Resolve and apply the inherited font size
		std::string fontName = m_contentSerializer->ResolveStringProperty(m_selectedElementID, "font");
		if (fontName.empty()) fontName = "babyblocks.ttf";
		int inheritedFontSize = m_contentSerializer->ResolveIntProperty(m_selectedElementID, "fontSize", 16);
		std::string fontPath = m_fontPath + fontName;
		auto inheritedFontPtr = std::make_shared<Font>(LoadFontEx(fontPath.c_str(), inheritedFontSize, 0, 0));

		ApplyFontToElement(m_selectedElementID, inheritedFontPtr.get());
		m_preservedFonts.push_back(inheritedFontPtr);

		Log("Cleared explicit fontSize for element " + to_string(m_selectedElementID) + ", now inheriting: " + to_string(inheritedFontSize));
		return true;
	}

	// 4. Load font with CURRENT font name
	std::string fontName = m_contentSerializer->ResolveStringProperty(m_selectedElementID, "font");
	if (fontName.empty()) fontName = "babyblocks.ttf";
	std::string fontPath = m_fontPath + fontName;
	auto newFontPtr = std::make_shared<Font>(LoadFontEx(fontPath.c_str(), newFontSize, 0, 0));

	// 5. Apply to element (dispatcher handles everything)
	ApplyFontToElement(m_selectedElementID, newFontPtr.get());

	// 6. Save changes - preserve the font object and save only the explicit fontSize
	// Note: The font name can remain inherited while fontSize is explicit
	m_preservedFonts.push_back(newFontPtr);
	m_contentSerializer->SetElementFontSize(m_selectedElementID, newFontSize);

	Log("Updated element " + to_string(m_selectedElementID) + " font size to: " + to_string(newFontSize));
	return true;
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

	// Debug: Log when arrow keys are pressed
	if (IsKeyPressed(KEY_LEFT) || IsKeyPressed(KEY_RIGHT) || IsKeyPressed(KEY_UP) || IsKeyPressed(KEY_DOWN))
	{
		Log("Arrow key pressed in GhostState::Update - activeID: " + to_string(activeID) + ", LastElement: " + to_string(m_gui->m_LastElement));
	}

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

	// Check PROPERTY_LAYOUT list (dropdown) for changes
	if (m_selectedElementID != -1 && m_propertySerializer)
	{
		int layoutListID = m_propertySerializer->GetElementID("PROPERTY_LAYOUT");
		if (layoutListID != -1)
		{
			auto layoutElement = m_gui->GetElement(layoutListID);
			if (layoutElement && layoutElement->m_Type == GUI_LIST)
			{
				auto layoutList = static_cast<GuiList*>(layoutElement.get());
				if (layoutList->m_SelectedIndex != lastLayoutListValue)
				{
					lastLayoutListValue = layoutList->m_SelectedIndex;
					Log("Layout list value changed to " + to_string(layoutList->m_SelectedIndex) + ", triggering update");
					UpdateElementFromPropertyPanel();
				}
			}
		}
	}

	// Check PROPERTY_JUSTIFY list (dropdown) for changes
	if (m_selectedElementID != -1 && m_propertySerializer)
	{
		int justifyListID = m_propertySerializer->GetElementID("PROPERTY_JUSTIFY");
		if (justifyListID != -1)
		{
			auto justifyElement = m_gui->GetElement(justifyListID);
			if (justifyElement && justifyElement->m_Type == GUI_LIST)
			{
				auto justifyList = static_cast<GuiList*>(justifyElement.get());
				if (justifyList->m_SelectedIndex != lastJustifyListValue)
				{
					lastJustifyListValue = justifyList->m_SelectedIndex;
					Log("Justify list value changed to " + to_string(justifyList->m_SelectedIndex) + ", triggering update");
					UpdateElementFromPropertyPanel();
				}
			}
		}
	}

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

	// Element hierarchy listbox click handler
	// Check if user clicked an item in the hierarchy listbox
	auto hierarchyListboxElement = m_gui->GetElement(1501);
	if (hierarchyListboxElement && hierarchyListboxElement->m_Type == GUI_LISTBOX)
	{
		auto hierarchyListbox = static_cast<GuiListBox*>(hierarchyListboxElement.get());
		if (hierarchyListbox->m_Clicked && hierarchyListbox->m_SelectedIndex >= 0)
		{
			// Get the element ID from the parallel list
			if (hierarchyListbox->m_SelectedIndex < static_cast<int>(m_elementIDList.size()))
			{
				int clickedElementID = m_elementIDList[hierarchyListbox->m_SelectedIndex];
				if (clickedElementID != m_selectedElementID)
				{
					m_selectedElementID = clickedElementID;
					Log("Selected element from hierarchy: " + std::to_string(clickedElementID));
					UpdatePropertyPanel();
					UpdateStatusFooter();
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
		if (selectedElement && (selectedElement->m_Type == GUI_STRETCHBUTTON || selectedElement->m_Type == GUI_SPRITE || selectedElement->m_Type == GUI_CYCLE || selectedElement->m_Type == GUI_ICONBUTTON || selectedElement->m_Type == GUI_CHECKBOX || selectedElement->m_Type == GUI_RADIOBUTTON))
		{
			// List of all sprite property button names
			vector<string> spriteProperties = {
				"PROPERTY_SPRITE_LEFT", "PROPERTY_SPRITE_CENTER", "PROPERTY_SPRITE_RIGHT", "PROPERTY_SPRITE", "PROPERTY_DOWNSPRITE", "PROPERTY_SELECTED_SPRITE", "PROPERTY_DESELECT_SPRITE"
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
								// Get the sprite definition from serializer (includes x, y, w, h)
								sprite = m_contentSerializer->GetSprite(m_selectedElementID);
							}
							else if (propName == "PROPERTY_DOWNSPRITE")
							{
								// Get the down sprite definition for icon button
								sprite = m_contentSerializer->GetIconButtonDownSprite(m_selectedElementID);
							}
							else if (propName == "PROPERTY_SELECTED_SPRITE")
							{
								// Get the select sprite definition for checkbox/radiobutton
								if (selectedElement->m_Type == GUI_CHECKBOX)
									sprite = m_contentSerializer->GetCheckBoxSelectSprite(m_selectedElementID);
								else if (selectedElement->m_Type == GUI_RADIOBUTTON)
									sprite = m_contentSerializer->GetRadioButtonSelectSprite(m_selectedElementID);
							}
							else if (propName == "PROPERTY_DESELECT_SPRITE")
							{
								// Get the deselect sprite definition for checkbox/radiobutton
								if (selectedElement->m_Type == GUI_CHECKBOX)
									sprite = m_contentSerializer->GetCheckBoxDeselectSprite(m_selectedElementID);
								else if (selectedElement->m_Type == GUI_RADIOBUTTON)
									sprite = m_contentSerializer->GetRadioButtonDeselectSprite(m_selectedElementID);
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

	// Font picker button click handler
	if (m_selectedElementID != -1)
	{
		auto selectedElement = m_gui->GetElement(m_selectedElementID);
		if (selectedElement)
		{
			// Check PROPERTY_PICK_FONT button
			int pickFontButtonID = m_propertySerializer->GetElementID("PROPERTY_PICK_FONT");
			if (pickFontButtonID != -1)
			{
				auto button = m_gui->GetElement(pickFontButtonID);
				if (button && button->m_Type == GUI_ICONBUTTON)
				{
					auto iconButton = static_cast<GuiIconButton*>(button.get());
					if (iconButton->m_Clicked)
					{
						Log("Opening file chooser for font selection");

						// Get current font if one exists
						std::string currentFont = m_contentSerializer->GetElementFont(m_selectedElementID);
						std::string initialFilename = currentFont;

						// Open FileChooserState for font selection
						auto fileChooserState = static_cast<FileChooserState*>(g_StateMachine->GetState(3));
						fileChooserState->SetMode(false, ".ttf", m_fontPath, "Select Font", initialFilename);
						g_StateMachine->PushState(3);

						// Set flag so we know to check for results when we resume
						m_waitingForFontPicker = true;
					}
				}
			}

			// Check PROPERTY_CLEAR_FONT button
			int clearFontButtonID = m_propertySerializer->GetElementID("PROPERTY_CLEAR_FONT");
			if (clearFontButtonID != -1)
			{
				auto button = m_gui->GetElement(clearFontButtonID);
				if (button && button->m_Type == GUI_ICONBUTTON)
				{
					auto iconButton = static_cast<GuiIconButton*>(button.get());
					if (iconButton->m_Clicked)
					{
						Log("Clearing font property for element " + std::to_string(m_selectedElementID));

						// Remove font from serializer metadata
						m_contentSerializer->ClearElementFont(m_selectedElementID);

						// Clear the PROPERTY_FONT textinput
						int fontInputID = m_propertySerializer->GetElementID("PROPERTY_FONT");
						if (fontInputID != -1)
						{
							auto fontInput = m_gui->GetElement(fontInputID);
							if (fontInput && fontInput->m_Type == GUI_TEXTINPUT)
							{
								static_cast<GuiTextInput*>(fontInput.get())->m_String = "";
							}
						}

						// Now resolve and apply the inherited font
						std::string inheritedFont = m_contentSerializer->ResolveStringProperty(m_selectedElementID, "font");
						if (inheritedFont.empty()) inheritedFont = "babyblocks.ttf";

						int fontSize = m_contentSerializer->ResolveIntProperty(m_selectedElementID, "fontSize", 16);
						std::string fontPath = m_fontPath + inheritedFont;
						auto inheritedFontPtr = std::make_shared<Font>(LoadFontEx(fontPath.c_str(), fontSize, 0, 0));

						ApplyFontToElement(m_selectedElementID, inheritedFontPtr.get());
						m_preservedFonts.push_back(inheritedFontPtr);

						Log("Font property cleared and element now inherits font from parent");
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
		// Get content panel anchor for zoom calculations
		auto contentPanel = m_gui->GetElement(2000);
		float anchorX = contentPanel ? contentPanel->m_Pos.x : 0.0f;
		float anchorY = contentPanel ? contentPanel->m_Pos.y : 0.0f;

		std::vector<int> clickedElements;
		for (const auto& pair : m_gui->m_GuiElementList)
		{
			const auto& element = pair.second;
			if (element->m_ID >= 2000 && element->m_ID < 3000 && element->m_Visible)
			{
				float elemX, elemY, elemW, elemH;

				if (element->m_ID >= 2001)
				{
					// Apply zoom relative to anchor for content elements
					float relX = element->m_Pos.x - anchorX;
					float relY = element->m_Pos.y - anchorY;
					elemX = m_gui->m_Pos.x + anchorX + relX * m_contentZoom;
					elemY = m_gui->m_Pos.y + anchorY + relY * m_contentZoom;
					elemW = element->m_Width * m_contentZoom;
					elemH = element->m_Height * m_contentZoom;
				}
				else
				{
					// Root container 2000 - no zoom
					elemX = m_gui->m_Pos.x + element->m_Pos.x;
					elemY = m_gui->m_Pos.y + element->m_Pos.y;
					elemW = element->m_Width;
					elemH = element->m_Height;
				}

				if (scaledX >= elemX && scaledX <= elemX + elemW &&
					scaledY >= elemY && scaledY <= elemY + elemH)
				{
					clickedElements.push_back(element->m_ID);
				}
			}
		}

		// Find the best element: prioritize by depth first (deepest wins), then by highest ID
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

			// Prioritize by depth, then by highest ID for same depth
			if (depth > maxDepth || (depth == maxDepth && id > bestID))
			{
				maxDepth = depth;
				bestID = id;
			}
		}

		Log("Clicked elements: " + to_string(clickedElements.size()) + ", bestID: " + to_string(bestID));

		// If we clicked the invisible root (2000) and nothing else, select the normal root (2001)
		if (bestID == -1 && clickedInvisibleRoot)
		{
			bestID = 2001;
		}

		if (bestID != -1)
		{
			// Check for double-click to toggle floating/positioned state
			double currentTime = GetTime();
			bool isDoubleClick = false;

			if (bestID == m_lastClickedElementID &&
			    (currentTime - m_lastClickTime) < DOUBLE_CLICK_TIME)
			{
				isDoubleClick = true;

				// Toggle floating state
				bool isFloating = m_contentSerializer->IsFloating(bestID);
				int parentID = m_contentSerializer->GetParentID(bestID);

				if (isFloating)
				{
					// Make it positioned: save current screen position and convert to relative position
					// Floating (-1,-1) = controlled by parent layout
					// Positioned (x,y) = NOT controlled by layout, fixed position
					auto element = m_gui->GetElement(bestID);

					if (element)
					{
						// Element m_Pos is already stored relative to GUI root
						// When drawn: screen_pos = m_Gui->m_Pos + element->m_Pos
						// The layout system has already positioned this floating element correctly,
						// so we just need to keep the current m_Pos value (don't modify it)

						Log("Converting floating to positioned, keeping current m_Pos (" + to_string(element->m_Pos.x) + ", " + to_string(element->m_Pos.y) + ")");
					}

					m_contentSerializer->SetFloating(bestID, false);
					Log("Toggled element " + to_string(bestID) + " to positioned");
				}
				else
				{
					// Make it floating: set position to (-1, -1)
					m_contentSerializer->SetFloating(bestID, true);
					Log("Toggled element " + to_string(bestID) + " to floating (-1, -1)");
				}

				// Reflow parent panel after toggling
				if (parentID != -1)
				{
					m_contentSerializer->ReflowPanel(parentID, m_gui.get());
					Log("Reflowed parent panel " + to_string(parentID) + " after toggle");

					// Log the element's position after reflow to verify it stayed put
					auto element = m_gui->GetElement(bestID);
					if (element)
					{
						Log("After reflow: element screen pos (" + to_string(element->m_Pos.x) + ", " + to_string(element->m_Pos.y) + ")");
					}
				}

				// Reset double-click tracking
				m_lastClickTime = 0.0;
				m_lastClickedElementID = -1;
			}
			else
			{
				// Single click - update tracking for potential double-click
				m_lastClickTime = currentTime;
				m_lastClickedElementID = bestID;
			}

			m_selectedElementID = bestID;
			Log("Selected element ID: " + to_string(bestID));
			UpdatePropertyPanel();  // Update property panel when selection changes
			UpdateStatusFooter();  // Update status footer with selected element info
			UpdateElementHierarchySelection();  // Update listbox selection to match clicked element

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

	// Handle drag-and-drop for positioned controls
	if (m_selectedElementID != -1 && !m_contentSerializer->IsFloating(m_selectedElementID))
	{
		// Start dragging on mouse down
		if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
		{
			Vector2 mousePos = GetMousePosition();
			float scaledX = mousePos.x / m_gui->m_InputScale;
			float scaledY = mousePos.y / m_gui->m_InputScale;

			auto element = m_gui->GetElement(m_selectedElementID);
			auto contentPanel = m_gui->GetElement(2000);
			if (element && contentPanel)
			{
				// Apply zoom to element bounds for hit testing
				float anchorX = contentPanel->m_Pos.x;
				float anchorY = contentPanel->m_Pos.y;
				float relX = element->m_Pos.x - anchorX;
				float relY = element->m_Pos.y - anchorY;
				float elemX = m_gui->m_Pos.x + anchorX + relX * m_contentZoom;
				float elemY = m_gui->m_Pos.y + anchorY + relY * m_contentZoom;
				float elemW = element->m_Width * m_contentZoom;
				float elemH = element->m_Height * m_contentZoom;

				// Check if mouse is over the selected positioned element
				if (scaledX >= elemX && scaledX <= elemX + elemW &&
				    scaledY >= elemY && scaledY <= elemY + elemH)
				{
					m_isDragging = true;
					m_dragElementID = m_selectedElementID;
					m_dragStartMousePos = { scaledX, scaledY };
					m_dragStartElementPos = element->m_Pos;
					Log("Started dragging element " + to_string(m_selectedElementID));
				}
			}
		}
	}

	// Update drag position while dragging
	if (m_isDragging && IsMouseButtonDown(MOUSE_LEFT_BUTTON))
	{
		Vector2 mousePos = GetMousePosition();
		float scaledX = mousePos.x / m_gui->m_InputScale;
		float scaledY = mousePos.y / m_gui->m_InputScale;

		// Calculate delta from drag start, accounting for zoom
		float deltaX = (scaledX - m_dragStartMousePos.x) / m_contentZoom;
		float deltaY = (scaledY - m_dragStartMousePos.y) / m_contentZoom;

		// Update element position
		auto element = m_gui->GetElement(m_dragElementID);
		if (element)
		{
			// Calculate new position
			float newX = m_dragStartElementPos.x + deltaX;
			float newY = m_dragStartElementPos.y + deltaY;

			// Get parent position to calculate relative position (for clamping)
			int parentID = m_contentSerializer->GetParentID(m_dragElementID);
			float parentX = 0;
			float parentY = 0;
			if (parentID != -1)
			{
				auto parent = m_gui->GetElement(parentID);
				if (parent)
				{
					parentX = parent->m_Pos.x;
					parentY = parent->m_Pos.y;
				}
			}

			// Clamp to prevent negative relative positions
			if (newX < parentX) newX = parentX;
			if (newY < parentY) newY = parentY;

			element->m_Pos.x = newX;
			element->m_Pos.y = newY;
			UpdateStatusFooter();  // Update status to show new position
		}
	}

	// Stop dragging and reflow parent on mouse release
	if (m_isDragging && IsMouseButtonReleased(MOUSE_LEFT_BUTTON))
	{
		Log("Stopped dragging element " + to_string(m_dragElementID));

		// Get parent for reflow
		int parentID = m_contentSerializer->GetParentID(m_dragElementID);
		if (parentID != -1)
		{
			m_contentSerializer->ReflowPanel(parentID, m_gui.get());
			Log("Reflowed parent panel " + to_string(parentID) + " after drag");
		}

		m_isDragging = false;
		m_dragElementID = -1;
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

		// Remove name mapping if this element has a name
		std::string elementName = GetElementName(m_selectedElementID);
		if (!elementName.empty())
		{
			m_contentSerializer->RemoveElementName(elementName);
			Log("Removed name mapping for deleted element: " + elementName);
		}

		// Find the next sibling to select after delete
		int newSelection = FindNextSelectionAfterRemoval(m_selectedElementID, parentID);

		// Remove from GUI
		m_gui->m_GuiElementList.erase(m_selectedElementID);

		// Remove from content serializer's tree
		m_contentSerializer->UnregisterChild(m_selectedElementID);

		// Reflow the parent panel if it exists
		if (parentID != -1)
		{
			m_contentSerializer->ReflowPanel(parentID, m_gui.get());
		}

		// Select the next appropriate element
		m_selectedElementID = newSelection;
		UpdatePropertyPanel();
		UpdateStatusFooter();

		// Update the element hierarchy listbox
		PopulateElementHierarchy();
		UpdateElementHierarchySelection();

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

		// Serialize element to clipboard (with forCopy=true to capture all current properties)
		m_clipboard = m_contentSerializer->SerializeElement(m_selectedElementID, m_gui.get(), parentX, parentY, true);
		m_hasClipboard = !m_clipboard.is_null();

		if (m_hasClipboard)
		{
			Log("Element copied to clipboard");
		}

		// Remove name mapping if this element has a name
		std::string elementName = GetElementName(m_selectedElementID);
		if (!elementName.empty())
		{
			m_contentSerializer->RemoveElementName(elementName);
			Log("Removed name mapping for cut element: " + elementName);
		}

		// Find the next sibling to select after cut
		int newSelection = FindNextSelectionAfterRemoval(m_selectedElementID, parentID);

		// Remove from GUI
		m_gui->m_GuiElementList.erase(m_selectedElementID);

		// Remove from content serializer's tree
		m_contentSerializer->UnregisterChild(m_selectedElementID);

		// Reflow the parent panel if it exists
		if (parentID != -1)
		{
			m_contentSerializer->ReflowPanel(parentID, m_gui.get());
		}

		// Select the next appropriate element
		m_selectedElementID = newSelection;
		UpdatePropertyPanel();
		UpdateStatusFooter();

		// Update the element hierarchy listbox
		PopulateElementHierarchy();
		UpdateElementHierarchySelection();

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

		// Serialize element to clipboard (with forCopy=true to capture all current properties)
		m_clipboard = m_contentSerializer->SerializeElement(m_selectedElementID, m_gui.get(), parentX, parentY, true);
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

		// Determine where to paste based on currently selected element
		int parentID = -1;
		int insertIndex = -1;  // -1 means append at end

		if (m_selectedElementID == -1)
		{
			// No selection - paste as child of root at end
			parentID = m_contentSerializer->GetRootElementID();
			insertIndex = -1;
			Log("Pasting as child of root ID: " + to_string(parentID));
		}
		else
		{
			// Check if selected element is a panel
			auto selectedElement = m_gui->GetElement(m_selectedElementID);
			if (selectedElement && selectedElement->m_Type == GUI_PANEL)
			{
				// Selected element is a panel - paste as its FIRST child
				parentID = m_selectedElementID;
				insertIndex = 0;  // Insert at beginning of panel's children
				Log("Pasting as first child of selected panel ID: " + to_string(parentID));
			}
			else
			{
				// Selected element is not a panel - paste immediately after it as sibling
				parentID = m_contentSerializer->GetParentID(m_selectedElementID);
				if (parentID == -1)
				{
					Log("ERROR: Cannot paste as sibling - selected element has no valid parent");
					return;
				}

				// Find the index of the selected element in its parent's children
				const auto& siblings = m_contentSerializer->GetChildren(parentID);
				for (size_t i = 0; i < siblings.size(); i++)
				{
					if (siblings[i] == m_selectedElementID)
					{
						insertIndex = static_cast<int>(i) + 1;  // Insert after selected element
						break;
					}
				}

				Log("Pasting immediately after selected element ID: " + to_string(m_selectedElementID) + " at index: " + to_string(insertIndex));
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

		// Get next auto ID for the pasted element and reserve it
		int newElementID = m_contentSerializer->GetNextAutoID();
		m_contentSerializer->SetAutoIDStart(newElementID + 1);

		// Create a copy of the clipboard data to modify
		ghost_json pasteData = m_clipboard;

		// If the element has a name, make it unique only if there's a naming conflict
		if (pasteData.contains("name"))
		{
			string originalName = pasteData["name"];
			string newName = originalName;

			// Only add "_copy" if the original name conflicts
			if (m_contentSerializer->GetElementID(newName) != -1)
			{
				newName = originalName + "_copy";

				// If that name already exists, append a number
				int copyNumber = 1;
				while (m_contentSerializer->GetElementID(newName) != -1)
				{
					newName = originalName + "_copy" + to_string(copyNumber);
					copyNumber++;
				}

				pasteData["name"] = newName;
				Log("Renamed pasted element from '" + originalName + "' to '" + newName + "'");
			}
		}

		// Create a temporary .ghost file structure in memory with proper format
		ghost_json tempFileJson;
		tempFileJson["gui"]["elements"] = ghost_json::array();
		tempFileJson["gui"]["elements"].push_back(pasteData);

		// Write to a temporary file
		string tempFilename = "temp_paste_" + to_string(newElementID) + ".ghost";
		ofstream tempFile(tempFilename);
		if (tempFile.is_open())
		{
			tempFile << tempFileJson.dump(2);
			tempFile.close();

			Log("Pasting element with parent offset (" + to_string(parentX) + ", " + to_string(parentY) + ") at index: " + to_string(insertIndex));

			// Load using LoadIntoPanel which handles parent offset correctly
			if (m_contentSerializer->LoadIntoPanel(tempFilename, m_gui.get(), parentX, parentY, parentID, insertIndex))
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

				// Update the element hierarchy listbox
				PopulateElementHierarchy();
				UpdateElementHierarchySelection();

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

	// Arrow keys: Nudge selected positioned element (green highlight) by 1 pixel
	if (m_selectedElementID >= 2002 && m_selectedElementID < 3000)
	{
		auto selectedElement = m_gui->GetElement(m_selectedElementID);
		if (selectedElement)
		{
			// Skip nudging if a property panel scrollbar is active (let scrollbar handle arrow keys)
			bool scrollbarActive = false;
			if (m_gui->m_LastElement >= 3000 && m_gui->m_LastElement < 4000)
			{
				auto lastElement = m_gui->GetElement(m_gui->m_LastElement);
				if (lastElement && lastElement->m_Type == GUI_SCROLLBAR)
				{
					scrollbarActive = true;
					Log("Skipping nudge - scrollbar " + to_string(m_gui->m_LastElement) + " is active");
				}
			}

			// Only allow nudging if element is positioned (green highlight), not floating (yellow highlight)
			bool isFloating = m_contentSerializer->IsFloating(m_selectedElementID);
			if (!isFloating && !scrollbarActive)
			{
				bool nudged = false;
				int deltaX = 0, deltaY = 0;

				if (IsKeyPressed(KEY_LEFT))
				{
					deltaX = -1;
					nudged = true;
				}
				else if (IsKeyPressed(KEY_RIGHT))
				{
					deltaX = 1;
					nudged = true;
				}
				else if (IsKeyPressed(KEY_UP))
				{
					deltaY = -1;
					nudged = true;
				}
				else if (IsKeyPressed(KEY_DOWN))
				{
					deltaY = 1;
					nudged = true;
				}

				if (nudged)
				{
					// Save undo state before making changes
					PushUndoState();

					// Update position in the element
					selectedElement->m_Pos.x += deltaX;
					selectedElement->m_Pos.y += deltaY;

					// If this is a panel, reflow its children
					if (selectedElement->m_Type == GUI_PANEL)
					{
						m_contentSerializer->ReflowPanel(m_selectedElementID, m_gui.get());
					}

					// Mark as dirty (position will be serialized from element on save)
					m_contentSerializer->SetDirty(true);

					Log("Nudged element " + to_string(m_selectedElementID) + " by (" +
						to_string(deltaX) + ", " + to_string(deltaY) + ")");
				}
			}
		}
	}

	// Mouse wheel zoom for content panel
	float wheelMove = GetMouseWheelMove();
	if (wheelMove != 0.0f)
	{
		// Check if mouse is over content panel (ID 2000)
		Vector2 mousePos = GetMousePosition();
		auto contentPanel = m_gui->GetElement(2000);
		if (contentPanel)
		{
			float scaledX = mousePos.x / m_gui->m_InputScale;
			float scaledY = mousePos.y / m_gui->m_InputScale;
			float panelX = m_gui->m_Pos.x + contentPanel->m_Pos.x;
			float panelY = m_gui->m_Pos.y + contentPanel->m_Pos.y;

			if (scaledX >= panelX && scaledX <= panelX + contentPanel->m_Width &&
			    scaledY >= panelY && scaledY <= panelY + contentPanel->m_Height)
			{
				// Adjust zoom
				m_contentZoom += wheelMove * ZOOM_STEP;

				// Clamp zoom to valid range
				if (m_contentZoom < MIN_ZOOM)
					m_contentZoom = MIN_ZOOM;
				if (m_contentZoom > MAX_ZOOM)
					m_contentZoom = MAX_ZOOM;
			}
		}
	}

	// Check for button clicks using name-based lookup
	if (activeID == m_serializer->GetElementID("NEW"))
	{
		Log("New button clicked!");
		ClearLoadedContent();
		EnsureContentRoot();  // Recreate empty root after clearing
		PopulateElementHierarchy();  // Update listbox with new content
		m_contentZoom = 1.0f;  // Reset zoom to 100%
	}
	else if (activeID == m_serializer->GetElementID("CLOSE"))
	{
		Log("Close button clicked!");
		g_Engine->m_Done = true;
	}
	else if (activeID == m_serializer->GetElementID("OPEN"))
	{
		Log("Open button clicked!");
		Log("  activeID=" + to_string(activeID) + ", OPEN ID=" + to_string(m_serializer->GetElementID("OPEN")) +
		    ", SAVE ID=" + to_string(m_serializer->GetElementID("SAVE")));

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
	else if (activeID == m_serializer->GetElementID("CYCLE"))
	{
		Log("Cycle button clicked!");
		InsertCycle();
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
	// Get content panel position as anchor point for zoom
	auto contentPanel = m_gui->GetElement(2000);
	float anchorX = contentPanel ? contentPanel->m_Pos.x : 0.0f;
	float anchorY = contentPanel ? contentPanel->m_Pos.y : 0.0f;

	// Apply zoom scale to content elements before drawing
	if (m_contentZoom != 1.0f)
	{
		for (auto& [id, element] : m_gui->m_GuiElementList)
		{
			if (id >= 2001 && id < 3000 && element)
			{
				// Scale position relative to content panel anchor and scale size
				float relX = element->m_Pos.x - anchorX;
				float relY = element->m_Pos.y - anchorY;
				element->m_Pos.x = anchorX + relX * m_contentZoom;
				element->m_Pos.y = anchorY + relY * m_contentZoom;
				element->m_Width *= m_contentZoom;
				element->m_Height *= m_contentZoom;
			}
		}
	}

	// Draw the GUI
	m_gui->Draw();

	// Restore content elements to original scale
	if (m_contentZoom != 1.0f)
	{
		for (auto& [id, element] : m_gui->m_GuiElementList)
		{
			if (id >= 2001 && id < 3000 && element)
			{
				// Restore position relative to content panel anchor and restore size
				float relX = element->m_Pos.x - anchorX;
				float relY = element->m_Pos.y - anchorY;
				element->m_Pos.x = anchorX + relX / m_contentZoom;
				element->m_Pos.y = anchorY + relY / m_contentZoom;
				element->m_Width /= m_contentZoom;
				element->m_Height /= m_contentZoom;
			}
		}
	}

	// Draw selection highlight around the selected element
	if (m_selectedElementID != -1)
	{
		auto selectedElement = m_gui->GetElement(m_selectedElementID);
		if (selectedElement)
		{
			// Draw outline: yellow for floating controls (-1,-1), green for positioned
			bool isFloating = m_contentSerializer->IsFloating(m_selectedElementID);
			Color highlightColor = isFloating ? YELLOW : GREEN;

			// Apply zoom to highlight box if this is a content element
			if (m_selectedElementID >= 2001 && m_selectedElementID < 3000)
			{
				// Scale relative to content panel anchor
				float relX = selectedElement->m_Pos.x - anchorX;
				float relY = selectedElement->m_Pos.y - anchorY;
				DrawRectangleLines(
					static_cast<int>(m_gui->m_Pos.x + anchorX + relX * m_contentZoom - 2),
					static_cast<int>(m_gui->m_Pos.y + anchorY + relY * m_contentZoom - 2),
					static_cast<int>(selectedElement->m_Width * m_contentZoom + 4),
					static_cast<int>(selectedElement->m_Height * m_contentZoom + 4),
					highlightColor
				);
			}
			else
			{
				// Non-content elements (property panel, etc.) - no zoom
				DrawRectangleLines(
					static_cast<int>(m_gui->m_Pos.x + selectedElement->m_Pos.x - 2),
					static_cast<int>(m_gui->m_Pos.y + selectedElement->m_Pos.y - 2),
					static_cast<int>(selectedElement->m_Width + 4),
					static_cast<int>(selectedElement->m_Height + 4),
					highlightColor
				);
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

					// Mark this color property as explicit so it gets saved
					std::string propertyName;
					if (m_editingColorProperty == "PROPERTY_TEXTCOLOR") propertyName = "textColor";
					else if (m_editingColorProperty == "PROPERTY_BORDERCOLOR") propertyName = "borderColor";
					else if (m_editingColorProperty == "PROPERTY_BACKGROUNDCOLOR") propertyName = "backgroundColor";
					else if (m_editingColorProperty == "PROPERTY_BACKGROUND") propertyName = "backgroundColor";
					else if (m_editingColorProperty == "PROPERTY_SPURCOLOR") propertyName = "spurColor";
					else if (m_editingColorProperty == "PROPERTY_COLOR") propertyName = "color";

					if (!propertyName.empty())
					{
						m_contentSerializer->MarkPropertyAsExplicit(m_selectedElementID, propertyName);
						m_contentSerializer->SetDirty(true);
						Log("Marked " + propertyName + " as explicit for element " + std::to_string(m_selectedElementID));
					}

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
						// Create new sprite with the specified source rectangle using proper constructor
						shared_ptr<Sprite> newSprite = make_shared<Sprite>(
							texture,
							sprite.x,
							sprite.y,
							sprite.w,
							sprite.h
						);

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
						// Create new sprite with the specified source rectangle using proper constructor
						shared_ptr<Sprite> newSprite = make_shared<Sprite>(
							texture,
							sprite.x,
							sprite.y,
							sprite.w,
							sprite.h
						);

						// Update the sprite element
						spriteElem->m_Sprite = newSprite;
						spriteElem->m_Width = sprite.w;
						spriteElem->m_Height = sprite.h;

						// Store full sprite definition in serializer (with x/y/w/h)
						m_contentSerializer->SetSprite(m_selectedElementID, sprite);

						Log("Updated sprite: " + sprite.spritesheet + " at (" + std::to_string(sprite.x) + "," + std::to_string(sprite.y) +
							") size (" + std::to_string(sprite.w) + "x" + std::to_string(sprite.h) + ")");
					}
					else
					{
						Log("ERROR: Failed to load texture: " + spritePath);
					}
				}
			else if (selectedElement && selectedElement->m_Type == GUI_CYCLE && m_editingSpriteProperty == "PROPERTY_SPRITE")
			{
				// Update cycle element with new sprite data
				auto cycleElem = static_cast<GuiCycle*>(selectedElement.get());

				// Load the new sprite texture
				string spritePath = m_spritePath + sprite.spritesheet;
				Texture* texture = g_ResourceManager->GetTexture(spritePath);

				if (texture)
				{
					// Get current frame count from the element
					int frameCount = cycleElem->m_FrameCount;
					if (frameCount < 1) frameCount = 1;

					// Create new frames from horizontal sprite sheet
					vector<shared_ptr<Sprite>> frames = CreateHorizontalSpriteFrames(
						texture, sprite.x, sprite.y, sprite.w, sprite.h, frameCount
					);

					// Update the cycle element
					cycleElem->m_Frames = frames;
					cycleElem->m_Width = sprite.w;
					cycleElem->m_Height = sprite.h;

					// Store full sprite definition in serializer (with x/y/w/h)
					m_contentSerializer->SetSprite(m_selectedElementID, sprite);

					Log("Updated cycle: " + sprite.spritesheet + " at (" + std::to_string(sprite.x) + "," + std::to_string(sprite.y) +
						") size (" + std::to_string(sprite.w) + "x" + std::to_string(sprite.h) + ") frames=" + std::to_string(frameCount));
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
					// Create new sprite with the specified source rectangle using proper constructor
					shared_ptr<Sprite> newSprite = make_shared<Sprite>(
						texture,
						sprite.x,
						sprite.y,
						sprite.w,
						sprite.h
					);

					// Update the icon button's up texture
					iconElem->m_UpTexture = newSprite;
					iconElem->m_Width = sprite.w;
					iconElem->m_Height = sprite.h;

					// Store full sprite definition in serializer (with x/y/w/h)
					m_contentSerializer->SetSprite(m_selectedElementID, sprite);

					Log("Updated iconbutton sprite: " + sprite.spritesheet + " at (" + std::to_string(sprite.x) + "," + std::to_string(sprite.y) +
						") size (" + std::to_string(sprite.w) + "x" + std::to_string(sprite.h) + ")");
				}
				else
				{
					Log("ERROR: Failed to load texture: " + spritePath);
				}
			}
			else if (selectedElement && selectedElement->m_Type == GUI_ICONBUTTON && m_editingSpriteProperty == "PROPERTY_DOWNSPRITE")
			{
				// Update icon button down sprite
				auto iconElem = static_cast<GuiIconButton*>(selectedElement.get());

				// Load the new sprite texture
				string spritePath = m_spritePath + sprite.spritesheet;
				Texture* texture = g_ResourceManager->GetTexture(spritePath);

				if (texture)
				{
					// Create new sprite with the specified source rectangle using proper constructor
					shared_ptr<Sprite> newSprite = make_shared<Sprite>(
						texture,
						sprite.x,
						sprite.y,
						sprite.w,
						sprite.h
					);

					// Update the icon button's down texture
					iconElem->m_DownTexture = newSprite;

					// Store full down sprite definition in serializer
					m_contentSerializer->SetIconButtonDownSprite(m_selectedElementID, sprite);

					Log("Updated iconbutton down sprite: " + sprite.spritesheet + " at (" + std::to_string(sprite.x) + "," + std::to_string(sprite.y) +
						") size (" + std::to_string(sprite.w) + "x" + std::to_string(sprite.h) + ")");
				}
				else
				{
					Log("ERROR: Failed to load texture: " + spritePath);
				}
			}
			else if (selectedElement && selectedElement->m_Type == GUI_CHECKBOX && m_editingSpriteProperty == "PROPERTY_SELECTED_SPRITE")
			{
				// Update checkbox select sprite
				auto checkboxElem = static_cast<GuiCheckBox*>(selectedElement.get());

				// Load the new sprite texture
				string spritePath = m_spritePath + sprite.spritesheet;
				Texture* texture = g_ResourceManager->GetTexture(spritePath);

				if (texture)
				{
					// Create new sprite with the specified source rectangle using proper constructor
					shared_ptr<Sprite> newSprite = make_shared<Sprite>(
						texture,
						sprite.x,
						sprite.y,
						sprite.w,
						sprite.h
					);

					// Update the checkbox's select sprite
					checkboxElem->m_SelectSprite = newSprite;

					// Store full sprite definition in serializer
					m_contentSerializer->SetCheckBoxSelectSprite(m_selectedElementID, sprite);

					Log("Updated checkbox select sprite: " + sprite.spritesheet + " at (" + std::to_string(sprite.x) + "," + std::to_string(sprite.y) +
						") size (" + std::to_string(sprite.w) + "x" + std::to_string(sprite.h) + ")");
				}
				else
				{
					Log("ERROR: Failed to load texture: " + spritePath);
				}
			}
			else if (selectedElement && selectedElement->m_Type == GUI_CHECKBOX && m_editingSpriteProperty == "PROPERTY_DESELECT_SPRITE")
			{
				// Update checkbox deselect sprite
				auto checkboxElem = static_cast<GuiCheckBox*>(selectedElement.get());

				// Load the new sprite texture
				string spritePath = m_spritePath + sprite.spritesheet;
				Texture* texture = g_ResourceManager->GetTexture(spritePath);

				if (texture)
				{
					// Create new sprite with the specified source rectangle using proper constructor
					shared_ptr<Sprite> newSprite = make_shared<Sprite>(
						texture,
						sprite.x,
						sprite.y,
						sprite.w,
						sprite.h
					);

					// Update the checkbox's deselect sprite
					checkboxElem->m_DeselectSprite = newSprite;

					// Store full sprite definition in serializer
					m_contentSerializer->SetCheckBoxDeselectSprite(m_selectedElementID, sprite);

					Log("Updated checkbox deselect sprite: " + sprite.spritesheet + " at (" + std::to_string(sprite.x) + "," + std::to_string(sprite.y) +
						") size (" + std::to_string(sprite.w) + "x" + std::to_string(sprite.h) + ")");
				}
				else
				{
					Log("ERROR: Failed to load texture: " + spritePath);
				}
			}
			else if (selectedElement && selectedElement->m_Type == GUI_RADIOBUTTON && m_editingSpriteProperty == "PROPERTY_SELECTED_SPRITE")
			{
				// Update radiobutton select sprite
				auto radioElem = static_cast<GuiRadioButton*>(selectedElement.get());

				// Load the new sprite texture
				string spritePath = m_spritePath + sprite.spritesheet;
				Texture* texture = g_ResourceManager->GetTexture(spritePath);

				if (texture)
				{
					// Create new sprite with the specified source rectangle using proper constructor
					shared_ptr<Sprite> newSprite = make_shared<Sprite>(
						texture,
						sprite.x,
						sprite.y,
						sprite.w,
						sprite.h
					);

					// Update the radiobutton's select sprite
					radioElem->m_SelectSprite = newSprite;

					// Store full sprite definition in serializer
					m_contentSerializer->SetRadioButtonSelectSprite(m_selectedElementID, sprite);

					Log("Updated radiobutton select sprite: " + sprite.spritesheet + " at (" + std::to_string(sprite.x) + "," + std::to_string(sprite.y) +
						") size (" + std::to_string(sprite.w) + "x" + std::to_string(sprite.h) + ")");
				}
				else
				{
					Log("ERROR: Failed to load texture: " + spritePath);
				}
			}
			else if (selectedElement && selectedElement->m_Type == GUI_RADIOBUTTON && m_editingSpriteProperty == "PROPERTY_DESELECT_SPRITE")
			{
				// Update radiobutton deselect sprite
				auto radioElem = static_cast<GuiRadioButton*>(selectedElement.get());

				// Load the new sprite texture
				string spritePath = m_spritePath + sprite.spritesheet;
				Texture* texture = g_ResourceManager->GetTexture(spritePath);

				if (texture)
				{
					// Create new sprite with the specified source rectangle using proper constructor
					shared_ptr<Sprite> newSprite = make_shared<Sprite>(
						texture,
						sprite.x,
						sprite.y,
						sprite.w,
						sprite.h
					);

					// Update the radiobutton's deselect sprite
					radioElem->m_DeselectSprite = newSprite;

					// Store full sprite definition in serializer
					m_contentSerializer->SetRadioButtonDeselectSprite(m_selectedElementID, sprite);

					Log("Updated radiobutton deselect sprite: " + sprite.spritesheet + " at (" + std::to_string(sprite.x) + "," + std::to_string(sprite.y) +
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

		// Check if we were waiting for font picker results
		if (m_waitingForFontPicker)
		{
			Log("GhostState: Processing font picker results");
			m_waitingForFontPicker = false;

			if (fileChooserState->WasAccepted())
			{
				string filepath = fileChooserState->GetSelectedPath();
				Log("Selected font file: " + filepath);

				// Extract just the filename from the full path
				string fontFilename = filepath;
				size_t lastSlash = filepath.find_last_of("/\\");
				if (lastSlash != string::npos)
				{
					fontFilename = filepath.substr(lastSlash + 1);
				}

				Log("Font filename: " + fontFilename);

				// Update the PROPERTY_FONT textinput (UpdateFontProperty will read from here)
				int fontInputID = m_propertySerializer->GetElementID("PROPERTY_FONT");
				if (fontInputID != -1)
				{
					auto fontInput = m_gui->GetElement(fontInputID);
					if (fontInput && fontInput->m_Type == GUI_TEXTINPUT)
					{
						static_cast<GuiTextInput*>(fontInput.get())->m_String = fontFilename;
					}
				}

				// Apply the new font by calling UpdateFontProperty (it will load, apply, and save the font)
				UpdateFontProperty();

				Log("Font applied: " + fontFilename);
			}
		}
		else
		{
			// Only process file selection if user clicked OK (not Cancel)
			Log("GhostState: WasAccepted = " + std::string(fileChooserState->WasAccepted() ? "true" : "false"));
			if (fileChooserState->WasAccepted())
			{
				string filepath = fileChooserState->GetSelectedPath();
				Log("Selected file: " + filepath);

				// Check the mode that was set when the dialog was opened
				if (fileChooserState->IsSaveMode())
				{
					Log("FileChooser was in SAVE mode, saving file");

					// Ensure .ghost extension
					if (filepath.find(".ghost") == string::npos)
					{
						filepath += ".ghost";
					}

					m_loadedGhostFile = filepath;
					SaveGhostFile();
				}
				else
				{
					Log("FileChooser was in OPEN mode, loading file");
					LoadGhostFile(filepath);
				}
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

	// Reset zoom to 100% when loading a new file
	m_contentZoom = 1.0f;

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

		// Populate the element hierarchy listbox with loaded elements
		PopulateElementHierarchy();
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

	// Clear the element hierarchy listbox
	auto listboxElement = m_gui->GetElement(1501);
	if (listboxElement && listboxElement->m_Type == GUI_LISTBOX)
	{
		auto listbox = static_cast<GuiListBox*>(listboxElement.get());
		listbox->m_Items.clear();
		listbox->m_SelectedIndex = -1;
	}
	m_elementIDList.clear();

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

		// Create as floating panel - parent will position it during layout
		int containerX = static_cast<int>(contentContainer->m_Pos.x);
		int containerY = static_cast<int>(contentContainer->m_Pos.y);

		m_gui->AddPanel(containerID, containerX, containerY, 620, 700, Color{60, 60, 60, 255}, true, 0, true);
		m_contentSerializer->SetPanelLayout(containerID, "horz");
		m_contentSerializer->SetPanelHorzPadding(containerID, 5);
		m_contentSerializer->SetPanelVertPadding(containerID, 5);
		m_contentSerializer->SetElementFont(containerID, "babyblocks.ttf");  // Set default font for inheritance
		m_contentSerializer->SetElementFontSize(containerID, 30);  // Set default font size for inheritance
		m_contentSerializer->RegisterChildOfParent(2000, containerID);
		m_contentSerializer->SetFloating(containerID, true);  // Mark as floating

		// Make the container the selected element so new elements go into it
		m_selectedElementID = containerID;

		// Only update UI if property serializer is initialized (not during Init)
		if (m_propertySerializer)
		{
			UpdatePropertyPanel();
			UpdateStatusFooter();

			// Update the element hierarchy listbox
			PopulateElementHierarchy();
			UpdateElementHierarchySelection();
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

	// Update the element hierarchy listbox
	PopulateElementHierarchy();
	UpdateElementHierarchySelection();

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
	// Measure the text and calculate the width and height parameters needed
	std::string labelText = "Label Text";
	Vector2 textDims = MeasureTextEx(*font, labelText.c_str(), font->baseSize, 1);
	int widthParam = int(textDims.x);  // Width in pixels
	int heightParam = int(textDims.y);  // Height in pixels
	m_gui->AddTextArea(ctx.newID, font, labelText, ctx.absoluteX, ctx.absoluteY, widthParam, heightParam, WHITE, 0, 0, true, false);

	// Mark color as explicit so it gets saved (prevents inheriting dark colors from parent)
	m_contentSerializer->MarkPropertyAsExplicit(ctx.newID, "color");

	// Don't store inherited font/fontSize - let it inherit from parent when loaded

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

	// Don't store inherited font/fontSize - let it inherit from parent when loaded

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

	// Store the full sprite definition for serialization
	GhostSerializer::SpriteDefinition spriteDef;
	spriteDef.spritesheet = filename;
	spriteDef.x = x;
	spriteDef.y = y;
	spriteDef.w = width;
	spriteDef.h = height;
	m_contentSerializer->SetSprite(ctx.newID, spriteDef);

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "Sprite");
}

void GhostState::InsertCycle()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("cycle");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Get fallback sprite for cycle (same as sprite)
	string filename;
	int x, y, width, height;
	SpriteUtils::GetFallbackForType("sprite", filename, x, y, width, height);

	Log("InsertCycle: Using fallback sprite: " + filename + " at (" + to_string(x) + "," + to_string(y) +
		") size " + to_string(width) + "x" + to_string(height));

	// Load sprite texture
	string spritePath = m_spritePath + filename;
	Texture* texture = g_ResourceManager->GetTexture(spritePath);

	// Create frames for cycle (default to 1 frame)
	int frameCount = 1;
	vector<shared_ptr<Sprite>> frames = CreateHorizontalSpriteFrames(
		texture, x, y, width, height, frameCount
	);

	// Add cycle at calculated position
	m_gui->AddCycle(ctx.newID, ctx.absoluteX, ctx.absoluteY, frames, 1.0f, 1.0f, WHITE, 0, true);

	// Store the full sprite definition for serialization
	GhostSerializer::SpriteDefinition spriteDef;
	spriteDef.spritesheet = filename;
	spriteDef.x = x;
	spriteDef.y = y;
	spriteDef.w = width;
	spriteDef.h = height;
	m_contentSerializer->SetSprite(ctx.newID, spriteDef);

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "Cycle");
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
	m_gui->AddTextInput(ctx.newID, ctx.absoluteX, ctx.absoluteY, 150, scaledHeight, font, "example", WHITE, WHITE, Color{0, 0, 0, 255}, 0, true);

	// Don't store inherited font/fontSize - let it inherit from parent when loaded

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

	// Store the full sprite definition for serialization
	GhostSerializer::SpriteDefinition spriteDef;
	spriteDef.spritesheet = filename;
	spriteDef.x = x;
	spriteDef.y = y;
	spriteDef.w = width;
	spriteDef.h = height;
	m_contentSerializer->SetSprite(ctx.newID, spriteDef);

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

	// Don't store inherited font/fontSize - let it inherit from parent when loaded

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

	// Don't store inherited font/fontSize - let it inherit from parent when loaded

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
	string basePath = GhostSerializer::GetBaseGhostPath();
	switch (selectedElement->m_Type)
	{
		case GUI_TEXTBUTTON:
			propertyFile = basePath + "ghost_prop_textbutton.ghost";
			break;
		case GUI_ICONBUTTON:
			propertyFile = basePath + "ghost_prop_iconbutton.ghost";
			break;
		case GUI_SCROLLBAR:
			propertyFile = basePath + "ghost_prop_scrollbar.ghost";
			break;
		case GUI_RADIOBUTTON:
			propertyFile = basePath + "ghost_prop_radiobutton.ghost";
			break;
		case GUI_CHECKBOX:
			propertyFile = basePath + "ghost_prop_checkbox.ghost";
			break;
		case GUI_TEXTINPUT:
			propertyFile = basePath + "ghost_prop_textinput.ghost";
			break;
		case GUI_PANEL:
			propertyFile = basePath + "ghost_prop_panel.ghost";
			break;
		case GUI_TEXTAREA:
			propertyFile = basePath + "ghost_prop_textarea.ghost";
			break;
		case GUI_SPRITE:
			propertyFile = basePath + "ghost_prop_sprite.ghost";
			break;
		case GUI_CYCLE:
			propertyFile = basePath + "ghost_prop_cycle.ghost";
			break;
		case GUI_OCTAGONBOX:
			propertyFile = basePath + "ghost_prop_octagonbox.ghost";
			break;
		case GUI_STRETCHBUTTON:
			propertyFile = basePath + "ghost_prop_stretchbutton.ghost";
			break;
		case GUI_LIST:
			propertyFile = basePath + "ghost_prop_list.ghost";
			break;
		case GUI_LISTBOX:
			propertyFile = basePath + "ghost_prop_listbox.ghost";
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

		// Enable debug value display on all property panel scrollbars (ID >= 3000)
		for (auto& [id, element] : m_gui->m_GuiElementList)
		{
			if (id >= 3000 && element && element->m_Type == GUI_SCROLLBAR)
			{
				auto scrollbar = static_cast<GuiScrollBar*>(element.get());
				scrollbar->m_DebugValue = true;
			}
		}

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

std::string GhostState::GetTypeName(int elementType)
{
	switch (elementType)
	{
	case GUI_PANEL: return "Panel";
	case GUI_TEXTAREA: return "TextArea";
	case GUI_TEXTBUTTON: return "TextButton";
	case GUI_ICONBUTTON: return "IconButton";
	case GUI_SPRITE: return "Sprite";
	case GUI_CYCLE: return "Cycle";
	case GUI_TEXTINPUT: return "TextInput";
	case GUI_CHECKBOX: return "CheckBox";
	case GUI_RADIOBUTTON: return "RadioButton";
	case GUI_SCROLLBAR: return "ScrollBar";
	case GUI_OCTAGONBOX: return "OctagonBox";
	case GUI_STRETCHBUTTON: return "StretchButton";
	case GUI_LIST: return "List";
	case GUI_LISTBOX: return "ListBox";
	default: return "Unknown";
	}
}

void GhostState::PopulateElementHierarchy()
{
	// Get the listbox element
	auto listboxElement = m_gui->GetElement(1501);
	if (!listboxElement || listboxElement->m_Type != GUI_LISTBOX)
	{
		Log("ERROR: Could not find element hierarchy listbox (ID 1501)");
		return;
	}
	auto listbox = static_cast<GuiListBox*>(listboxElement.get());
	if (!listbox)
	{
		Log("ERROR: Could not find element hierarchy listbox (ID 1501)");
		return;
	}

	// Clear the current list
	listbox->m_Items.clear();
	m_elementIDList.clear();

	// Get all element IDs in depth-first order (already hierarchical)
	std::vector<int> allIDs = m_contentSerializer->GetAllElementIDs();

	Log("PopulateElementHierarchy: Got " + std::to_string(allIDs.size()) + " element IDs from serializer");

	// Build the hierarchical list with indentation
	for (int id : allIDs)
	{
		// Skip the content container itself (ID 2000) - it's part of the app, not user content
		if (id == 2000)
			continue;

		// Get element to check its type
		// Note: Include directives don't create GUI elements, so they won't exist here - that's OK, just skip them
		auto element = m_gui->GetElement(id);
		if (!element)
		{
			Log("PopulateElementHierarchy: Skipping ID " + std::to_string(id) + " (no GUI element found - likely an include directive)");
			continue;
		}

		// Calculate depth by counting parent hops
		int depth = 0;
		int currentID = id;
		while (true)
		{
			int parentID = m_contentSerializer->GetParentID(currentID);
			if (parentID == -1 || parentID == 2000) // Stop at root container
				break;
			depth++;
			currentID = parentID;
		}

		// Build the display string with indentation (1 space per level)
		std::string indent(depth, ' ');
		std::string typeName = GetTypeName(element->m_Type);
		std::string name = GetElementName(id);

		std::string displayText;
		if (!name.empty())
		{
			displayText = indent + name + ": " + typeName;
		}
		else
		{
			displayText = indent + typeName + " (" + std::to_string(id) + ")";
		}

		// Add to listbox and parallel ID list
		listbox->m_Items.push_back(displayText);
		m_elementIDList.push_back(id);
	}

	Log("Populated element hierarchy with " + std::to_string(listbox->m_Items.size()) + " items");
}

void GhostState::UpdateElementHierarchySelection()
{
	// Get the listbox element
	auto listboxElement = m_gui->GetElement(1501);
	if (!listboxElement || listboxElement->m_Type != GUI_LISTBOX)
		return;
	auto listbox = static_cast<GuiListBox*>(listboxElement.get());

	// Find the index of the selected element in our ID list
	int selectedIndex = -1;
	for (size_t i = 0; i < m_elementIDList.size(); i++)
	{
		if (m_elementIDList[i] == m_selectedElementID)
		{
			selectedIndex = static_cast<int>(i);
			break;
		}
	}

	// Update the listbox selection
	listbox->m_SelectedIndex = selectedIndex;
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

		// Only populate font properties if they are explicitly set (not inherited)
		if (m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "font"))
			PopulateTextInputProperty("PROPERTY_FONT", m_contentSerializer->GetElementFont(m_selectedElementID));
		if (m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "fontSize"))
			PopulateScrollbarProperty("PROPERTY_FONT_SIZE", m_contentSerializer->GetElementFontSize(m_selectedElementID));

		// Populate justify dropdown list
		int justifyListID = m_propertySerializer->GetElementID("PROPERTY_JUSTIFY");
		if (justifyListID != -1)
		{
			auto justifyList = m_gui->GetElement(justifyListID);
			if (justifyList && justifyList->m_Type == GUI_LIST)
			{
				auto list = static_cast<GuiList*>(justifyList.get());
				// GuiTextArea::m_Justified: LEFT=0, CENTERED=1, RIGHT=2
				list->m_SelectedIndex = static_cast<int>(textarea->m_Justified);

				// Sync the tracking variable to prevent false triggers
				lastJustifyListValue = list->m_SelectedIndex;
			}
		}
	}

	// Populate layout radio buttons and columns field (for panel elements)
	if (selectedElement && selectedElement->m_Type == GUI_PANEL)
	{
		// Get the panel's current layout
		std::string layout = m_contentSerializer->GetPanelLayout(m_selectedElementID);
		int columns = m_contentSerializer->GetPanelColumns(m_selectedElementID);

		Log("PopulatePropertyPanelFields: Panel layout='" + layout + "', columns=" + to_string(columns));

		// Set the layout dropdown list
		int layoutListID = m_propertySerializer->GetElementID("PROPERTY_LAYOUT");
		if (layoutListID != -1)
		{
			auto layoutList = m_gui->GetElement(layoutListID);
			if (layoutList && layoutList->m_Type == GUI_LIST)
			{
				auto list = static_cast<GuiList*>(layoutList.get());

				// Set the selected index based on layout value
				if (layout == "horz") list->m_SelectedIndex = 0;
				else if (layout == "vert") list->m_SelectedIndex = 1;
				else if (layout == "table") list->m_SelectedIndex = 2;
				else list->m_SelectedIndex = 0; // Default to Horz
				
				// Sync the tracking variable to prevent false triggers
				lastLayoutListValue = list->m_SelectedIndex;
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

		// Only populate font properties if they are explicitly set (not inherited)
		if (m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "font"))
			PopulateTextInputProperty("PROPERTY_FONT", m_contentSerializer->GetElementFont(m_selectedElementID));
		if (m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "fontSize"))
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

		// Only populate font properties if they are explicitly set (not inherited)
		if (m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "font"))
			PopulateTextInputProperty("PROPERTY_FONT", m_contentSerializer->GetElementFont(m_selectedElementID));
		if (m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "fontSize"))
			PopulateScrollbarProperty("PROPERTY_FONT_SIZE", m_contentSerializer->GetElementFontSize(m_selectedElementID));

		// If no explicit font, ensure inherited font is applied
		if (!m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "font") &&
		    !m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "fontSize"))
		{
			std::string fontName = m_contentSerializer->ResolveStringProperty(m_selectedElementID, "font");
			if (fontName.empty()) fontName = "babyblocks.ttf";
			int fontSize = m_contentSerializer->ResolveIntProperty(m_selectedElementID, "fontSize", 16);
			std::string fontPath = m_fontPath + fontName;
			auto inheritedFontPtr = std::make_shared<Font>(LoadFontEx(fontPath.c_str(), fontSize, 0, 0));
			ApplyFontToElement(m_selectedElementID, inheritedFontPtr.get());
			m_preservedFonts.push_back(inheritedFontPtr);
		}

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

		// Only populate font properties if they are explicitly set (not inherited)
		if (m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "font"))
			PopulateTextInputProperty("PROPERTY_FONT", m_contentSerializer->GetElementFont(m_selectedElementID));
		if (m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "fontSize"))
			PopulateScrollbarProperty("PROPERTY_FONT_SIZE", m_contentSerializer->GetElementFontSize(m_selectedElementID));

		PopulateGroupProperty(selectedElement.get());
	}

	// Populate listbox properties (for listbox elements)
	if (selectedElement && selectedElement->m_Type == GUI_LISTBOX)
	{
		auto listbox = static_cast<GuiListBox*>(selectedElement.get());

		PopulateScrollbarProperty("PROPERTY_WIDTH", static_cast<int>(listbox->m_Width));
		PopulateScrollbarProperty("PROPERTY_HEIGHT", static_cast<int>(listbox->m_Height));

		// Only populate font properties if they are explicitly set (not inherited)
		if (m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "font"))
			PopulateTextInputProperty("PROPERTY_FONT", m_contentSerializer->GetElementFont(m_selectedElementID));
		if (m_contentSerializer->IsPropertyExplicit(m_selectedElementID, "fontSize"))
			PopulateScrollbarProperty("PROPERTY_FONT_SIZE", m_contentSerializer->GetElementFontSize(m_selectedElementID));
	}

	// Populate cycle properties (for cycle elements)
	if (selectedElement && selectedElement->m_Type == GUI_CYCLE)
	{
		auto cycle = static_cast<GuiCycle*>(selectedElement.get());

		PopulateScrollbarProperty("PROPERTY_FRAMECOUNT", cycle->m_FrameCount);
		PopulateScrollbarProperty("PROPERTY_SCALE", static_cast<int>(cycle->m_ScaleX * 10));
		PopulateGroupProperty(selectedElement.get());
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
		// Check layout dropdown list
		int layoutListID = m_propertySerializer->GetElementID("PROPERTY_LAYOUT");
		std::string newLayout = "";

		if (layoutListID != -1)
		{
			auto layoutList = m_gui->GetElement(layoutListID);
			if (layoutList && layoutList->m_Type == GUI_LIST)
			{
				auto list = static_cast<GuiList*>(layoutList.get());

				// Convert list index to layout string
				if (list->m_SelectedIndex == 0) newLayout = "horz";
				else if (list->m_SelectedIndex == 1) newLayout = "vert";
				else if (list->m_SelectedIndex == 2) newLayout = "table";
			}
		}

		// Update layout if changed
		if (!newLayout.empty())
		{
			std::string oldLayout = m_contentSerializer->GetPanelLayout(m_selectedElementID);
			if (newLayout != oldLayout)
			{
				m_contentSerializer->SetPanelLayout(m_selectedElementID, newLayout);

				// When switching to table layout, ensure columns is initialized if not already set
				// This ensures the default value (2) is properly stored in the map
				if (newLayout == "table")
				{
					int currentColumns = m_contentSerializer->GetPanelColumns(m_selectedElementID);
					m_contentSerializer->SetPanelColumns(m_selectedElementID, currentColumns);
				}

				// Reflow children to update positions based on new layout
				m_contentSerializer->ReflowPanel(m_selectedElementID, m_gui.get());

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

		// Update justify property from dropdown list
		int justifyListID = m_propertySerializer->GetElementID("PROPERTY_JUSTIFY");
		if (justifyListID != -1)
		{
			auto justifyElement = m_gui->GetElement(justifyListID);
			if (justifyElement && justifyElement->m_Type == GUI_LIST)
			{
				auto justifyList = static_cast<GuiList*>(justifyElement.get());
				auto textarea = static_cast<GuiTextArea*>(selectedElement.get());

				// Update the GuiTextArea's m_Justified (LEFT=0, CENTERED=1, RIGHT=2)
				int newJustify = justifyList->m_SelectedIndex;
				if (textarea->m_Justified != newJustify)
				{
					textarea->m_Justified = newJustify;
					wasUpdated = true;
				}
			}
		}
	}

	// Update listbox properties if changed
	if (selectedElement && selectedElement->m_Type == GUI_LISTBOX)
	{
		if (UpdateWidthProperty(selectedElement.get())) wasUpdated = true;
		if (UpdateHeightProperty(selectedElement.get())) wasUpdated = true;
		// Font and font size are already handled by UpdateFontProperty() and UpdateFontSizeProperty() above
	}

	// Update cycle properties if changed
	if (selectedElement && selectedElement->m_Type == GUI_CYCLE)
	{
		auto cycle = static_cast<GuiCycle*>(selectedElement.get());

		// Update PROPERTY_FRAMECOUNT - when changed, regenerate frames from current sprite
		int frameCountInputID = m_propertySerializer->GetElementID("PROPERTY_FRAMECOUNT");
		if (frameCountInputID != -1)
		{
			auto frameCountInput = m_gui->GetElement(frameCountInputID);
			if (frameCountInput && frameCountInput->m_Type == GUI_SCROLLBAR)
			{
				auto frameCountScrollbar = static_cast<GuiScrollBar*>(frameCountInput.get());
				int newFrameCount = frameCountScrollbar->m_Value;
				if (newFrameCount > 0 && newFrameCount != cycle->m_FrameCount)
				{
					// Get the current sprite definition
					GhostSerializer::SpriteDefinition sprite = m_contentSerializer->GetSprite(m_selectedElementID);
					if (!sprite.IsEmpty())
					{
						// Load the sprite texture
						string spritePath = m_spritePath + sprite.spritesheet;
						Texture* texture = g_ResourceManager->GetTexture(spritePath);

						if (texture)
						{
							// Regenerate frames with new frame count
							vector<shared_ptr<Sprite>> frames = CreateHorizontalSpriteFrames(
								texture, sprite.x, sprite.y, sprite.w, sprite.h, newFrameCount
							);

							cycle->m_Frames = frames;
							cycle->m_FrameCount = newFrameCount;

							// Clamp current frame to new frame count
							if (cycle->m_CurrentFrame >= newFrameCount)
								cycle->m_CurrentFrame = newFrameCount - 1;

							Log("Updated cycle " + to_string(m_selectedElementID) + " frame count to " + to_string(newFrameCount));
							wasUpdated = true;
						}
					}
				}
			}
		}

		// Update PROPERTY_SCALE
		int scaleInputID = m_propertySerializer->GetElementID("PROPERTY_SCALE");
		if (scaleInputID != -1)
		{
			auto scaleInput = m_gui->GetElement(scaleInputID);
			if (scaleInput && scaleInput->m_Type == GUI_SCROLLBAR)
			{
				auto scaleScrollbar = static_cast<GuiScrollBar*>(scaleInput.get());
				float newScale = scaleScrollbar->m_Value / 10.0f; // Map 0-100 to 0-10
				if (cycle->m_ScaleX != newScale || cycle->m_ScaleY != newScale)
				{
					cycle->m_ScaleX = newScale;
					cycle->m_ScaleY = newScale;
					Log("Updated cycle " + to_string(m_selectedElementID) + " scale to: " + to_string(newScale));
					wasUpdated = true;
				}
			}
		}

		if (UpdateGroupProperty(selectedElement.get())) wasUpdated = true;
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
	m_contentSerializer->SetRootElementID(2000); // Set root to content panel container

	// Restore the undo state
	// The undoState contains the serialized root element with all its children
	// We need to restore the children into the content panel (ID 2000)

	// Get the content panel to find its position
	auto contentPanel = m_gui->GetElement(2000);
	if (!contentPanel)
	{
		Log("ERROR: Content panel (ID 2000) not found during undo");
		return;
	}

	int containerX = static_cast<int>(contentPanel->m_Pos.x);
	int containerY = static_cast<int>(contentPanel->m_Pos.y);

	// Build inherited properties from the content panel
	ghost_json inheritedProps = m_contentSerializer->BuildInheritedProps(2000);

	// Parse the children directly into the content panel
	if (undoState.contains("elements") && undoState["elements"].is_array())
	{
		m_contentSerializer->ParseElements(undoState["elements"], m_gui.get(), inheritedProps, containerX, containerY, 2000);
		Log("Undo successful (undo stack: " + to_string(m_undoStack.size()) + ", redo stack: " + to_string(m_redoStack.size()) + ")");
		m_contentSerializer->SetDirty(true);

		// Update the element hierarchy listbox
		PopulateElementHierarchy();
		UpdateElementHierarchySelection();  // Clear selection in listbox since m_selectedElementID is -1
	}
	else
	{
		Log("Undo state has no elements to restore");
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
	m_contentSerializer->SetRootElementID(2000); // Set root to content panel container

	// Restore the redo state
	// The redoState contains the serialized root element with all its children
	// We need to restore the children into the content panel (ID 2000)

	// Get the content panel to find its position
	auto contentPanel = m_gui->GetElement(2000);
	if (!contentPanel)
	{
		Log("ERROR: Content panel (ID 2000) not found during redo");
		return;
	}

	int containerX = static_cast<int>(contentPanel->m_Pos.x);
	int containerY = static_cast<int>(contentPanel->m_Pos.y);

	// Build inherited properties from the content panel
	ghost_json inheritedProps = m_contentSerializer->BuildInheritedProps(2000);

	// Parse the children directly into the content panel
	if (redoState.contains("elements") && redoState["elements"].is_array())
	{
		m_contentSerializer->ParseElements(redoState["elements"], m_gui.get(), inheritedProps, containerX, containerY, 2000);
		Log("Redo successful (undo stack: " + to_string(m_undoStack.size()) + ", redo stack: " + to_string(m_redoStack.size()) + ")");
		m_contentSerializer->SetDirty(true);

		// Update the element hierarchy listbox
		PopulateElementHierarchy();
		UpdateElementHierarchySelection();  // Clear selection in listbox since m_selectedElementID is -1
	}
	else
	{
		Log("Redo state has no elements to restore");
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

	// Get element type name using shared helper function
	std::string typeName = GetTypeName(selectedElement->m_Type);

	// Get element name
	std::string elementName = GetElementName(m_selectedElementID);
	if (elementName.empty())
	{
		elementName = "(unnamed)";
	}

	// Get position info (floating vs positioned)
	std::string positionInfo;
	if (m_contentSerializer->IsFloating(m_selectedElementID))
	{
		positionInfo = " [Floating]";
	}
	else
	{
		// Get parent to calculate relative position
		int parentID = m_contentSerializer->GetParentID(m_selectedElementID);
		int relativeX = static_cast<int>(selectedElement->m_Pos.x);
		int relativeY = static_cast<int>(selectedElement->m_Pos.y);

		if (parentID != -1)
		{
			auto parent = m_gui->GetElement(parentID);
			if (parent)
			{
				relativeX = static_cast<int>(selectedElement->m_Pos.x - parent->m_Pos.x);
				relativeY = static_cast<int>(selectedElement->m_Pos.y - parent->m_Pos.y);
			}
		}

		positionInfo = " [" + to_string(relativeX) + ", " + to_string(relativeY) + "]";
	}

	// Build the status string
	footerText->m_String = typeName + " Name: " + elementName + " ID: " + to_string(m_selectedElementID) + positionInfo;
}
