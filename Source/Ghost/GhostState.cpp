#include "GhostState.h"
#include "../Geist/Globals.h"
#include "../Geist/Engine.h"
#include "../Geist/StateMachine.h"
#include "../Geist/Logging.h"
#include "../Geist/ResourceManager.h"
#include "../Geist/Config.h"
#include "FileDialog.h"
#include "ColorPickerState.h"
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
static int lastTextInputWidthScrollbarValue = -1;
static int lastTextInputHeightScrollbarValue = -1;
static int lastTextInputFontSizeScrollbarValue = -1;
static bool lastVerticalCheckboxValue = false;

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
	m_editingColorProperty = NONE;

	// Load config to get resource paths
	Log("Loading config from: Data/ghost.cfg");
	Config* config = g_ResourceManager->GetConfig("Data/ghost.cfg");
	if (!config)
	{
		Log("ERROR: Failed to load config!");
		m_fontPath = "Data/";
		m_spritePath = "Data/";
		GuiSerializer::SetBaseFontPath(m_fontPath);
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

	// Set the resource paths in GuiSerializer so they can be used for loading
	GuiSerializer::SetBaseFontPath(m_fontPath);
	GuiSerializer::SetBaseSpritePath(m_spritePath);

	// Create the main GUI
	m_gui = make_unique<Gui>();
	m_gui->m_Pos = {0, 0};

	// Create serializer (keep it alive to preserve loaded fonts)
	m_serializer = make_unique<GuiSerializer>();

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
	m_propertySerializer = make_unique<GuiSerializer>();
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

void GhostState::Update()
{
	m_gui->Update();

	int activeID = m_gui->GetActiveElementID();

	// Update element properties when property panel inputs change
	// Only update if a property panel element just became active (was clicked/interacted with)
	static int lastActiveID = -1;
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

	// Check PROPERTY_COLUMNS scrollbar
	int columnsScrollbarID = m_propertySerializer->GetElementID("PROPERTY_COLUMNS");
	if (columnsScrollbarID != -1 && m_selectedElementID != -1)
	{
		auto columnsElement = m_gui->GetElement(columnsScrollbarID);
		if (columnsElement && columnsElement->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(columnsElement.get());
			if (scrollbar->m_Value != lastColumnsScrollbarValue)
			{
				lastColumnsScrollbarValue = scrollbar->m_Value;
				Log("Columns scrollbar value changed to " + to_string(scrollbar->m_Value) + ", triggering update");
				UpdateElementFromPropertyPanel();
			}
		}
	}

	// Check PROPERTY_HORZ_PADDING scrollbar
	int horzPaddingScrollbarID = m_propertySerializer->GetElementID("PROPERTY_HORZ_PADDING");
	if (horzPaddingScrollbarID != -1 && m_selectedElementID != -1)
	{
		auto horzPaddingElement = m_gui->GetElement(horzPaddingScrollbarID);
		if (horzPaddingElement && horzPaddingElement->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(horzPaddingElement.get());
			if (scrollbar->m_Value != lastHorzPaddingScrollbarValue)
			{
				lastHorzPaddingScrollbarValue = scrollbar->m_Value;
				Log("Horz padding scrollbar value changed to " + to_string(scrollbar->m_Value) + ", triggering update");
				UpdateElementFromPropertyPanel();
			}
		}
	}

	// Check PROPERTY_VERT_PADDING scrollbar
	int vertPaddingScrollbarID = m_propertySerializer->GetElementID("PROPERTY_VERT_PADDING");
	if (vertPaddingScrollbarID != -1 && m_selectedElementID != -1)
	{
		auto vertPaddingElement = m_gui->GetElement(vertPaddingScrollbarID);
		if (vertPaddingElement && vertPaddingElement->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(vertPaddingElement.get());
			if (scrollbar->m_Value != lastVertPaddingScrollbarValue)
			{
				lastVertPaddingScrollbarValue = scrollbar->m_Value;
				Log("Vert padding scrollbar value changed to " + to_string(scrollbar->m_Value) + ", triggering update");
				UpdateElementFromPropertyPanel();
			}
		}
	}

	// Check PROPERTY_FONT_SIZE scrollbar
	int fontSizeScrollbarID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
	if (fontSizeScrollbarID != -1 && m_selectedElementID != -1)
	{
		auto fontSizeElement = m_gui->GetElement(fontSizeScrollbarID);
		if (fontSizeElement && fontSizeElement->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(fontSizeElement.get());
			if (scrollbar->m_Value != lastFontSizeScrollbarValue)
			{
				lastFontSizeScrollbarValue = scrollbar->m_Value;
				Log("Font size scrollbar value changed to " + to_string(scrollbar->m_Value) + ", triggering update");
				UpdateElementFromPropertyPanel();
			}
		}
	}

	// Check PROPERTY_WIDTH scrollbar
	int widthScrollbarID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
	if (widthScrollbarID != -1 && m_selectedElementID != -1)
	{
		auto widthElement = m_gui->GetElement(widthScrollbarID);
		if (widthElement && widthElement->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(widthElement.get());
			if (scrollbar->m_Value != lastWidthScrollbarValue)
			{
				lastWidthScrollbarValue = scrollbar->m_Value;
				Log("Width scrollbar value changed to " + to_string(scrollbar->m_Value) + ", triggering update");
				UpdateElementFromPropertyPanel();
			}
		}
	}

	// Check PROPERTY_HEIGHT scrollbar
	int heightScrollbarID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
	if (heightScrollbarID != -1 && m_selectedElementID != -1)
	{
		auto heightElement = m_gui->GetElement(heightScrollbarID);
		if (heightElement && heightElement->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(heightElement.get());
			if (scrollbar->m_Value != lastHeightScrollbarValue)
			{
				lastHeightScrollbarValue = scrollbar->m_Value;
				Log("Height scrollbar value changed to " + to_string(scrollbar->m_Value) + ", triggering update");
				UpdateElementFromPropertyPanel();
			}
		}
	}

	// Check PROPERTY_VALUE_RANGE scrollbar
	int valueRangeScrollbarID = m_propertySerializer->GetElementID("PROPERTY_VALUE_RANGE");
	if (valueRangeScrollbarID != -1 && m_selectedElementID != -1)
	{
		auto valueRangeElement = m_gui->GetElement(valueRangeScrollbarID);
		if (valueRangeElement && valueRangeElement->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(valueRangeElement.get());
			if (scrollbar->m_Value != lastValueRangeScrollbarValue)
			{
				lastValueRangeScrollbarValue = scrollbar->m_Value;
				Log("Value range scrollbar value changed to " + to_string(scrollbar->m_Value) + ", triggering update");
				UpdateElementFromPropertyPanel();
			}
		}
	}

	// Check PROPERTY_VERTICAL checkbox for scrollbar elements
	int verticalCheckboxID = m_propertySerializer->GetElementID("PROPERTY_VERTICAL");
	if (verticalCheckboxID != -1 && m_selectedElementID != -1)
	{
		auto verticalElement = m_gui->GetElement(verticalCheckboxID);
		if (verticalElement && verticalElement->m_Type == GUI_CHECKBOX)
		{
			auto checkbox = static_cast<GuiCheckBox*>(verticalElement.get());
			if (checkbox->m_Selected != lastVerticalCheckboxValue)
			{
				lastVerticalCheckboxValue = checkbox->m_Selected;
				Log("Vertical checkbox value changed to " + to_string(checkbox->m_Selected) + ", triggering update");
				UpdateElementFromPropertyPanel();
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

	// Check for PROPERTY_TEXTCOLOR button click to open color picker (for textarea, textinput, textbutton)
	int textColorButtonID = m_propertySerializer->GetElementID("PROPERTY_TEXTCOLOR");
	if (textColorButtonID != -1 && m_selectedElementID != -1)
	{
		auto textColorButton = m_gui->GetElement(textColorButtonID);
		if (textColorButton && textColorButton->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(textColorButton.get());
			if (button->m_Clicked)
			{
				auto selectedElement = m_gui->GetElement(m_selectedElementID);

				if (selectedElement && selectedElement->m_Type == GUI_TEXTAREA)
				{
					auto textarea = static_cast<GuiTextArea*>(selectedElement.get());
					m_editingColorProperty = TEXTAREA_TEXTCOLOR;
					auto colorPickerState = static_cast<ColorPickerState*>(g_StateMachine->GetState(1));
					colorPickerState->SetColor(textarea->m_Color);
					g_StateMachine->PushState(1);
					Log("Opening color picker for textarea text color");
				}
				else if (selectedElement && selectedElement->m_Type == GUI_TEXTINPUT)
				{
					auto textinput = static_cast<GuiTextInput*>(selectedElement.get());
					m_editingColorProperty = TEXTINPUT_TEXTCOLOR;
					auto colorPickerState = static_cast<ColorPickerState*>(g_StateMachine->GetState(1));
					colorPickerState->SetColor(textinput->m_TextColor);
					g_StateMachine->PushState(1);
					Log("Opening color picker for textinput text color");
				}
				else if (selectedElement && selectedElement->m_Type == GUI_TEXTBUTTON)
				{
					auto textbutton = static_cast<GuiTextButton*>(selectedElement.get());
					m_editingColorProperty = TEXTBUTTON_TEXTCOLOR;
					auto colorPickerState = static_cast<ColorPickerState*>(g_StateMachine->GetState(1));
					colorPickerState->SetColor(textbutton->m_TextColor);
					g_StateMachine->PushState(1);
					Log("Opening color picker for textbutton text color");
				}
			}
		}
	}

	// Check for PROPERTY_BACKGROUND button click to open color picker
	int backgroundButtonID = m_propertySerializer->GetElementID("PROPERTY_BACKGROUND");
	if (backgroundButtonID != -1 && m_selectedElementID != -1)
	{
		auto backgroundButton = m_gui->GetElement(backgroundButtonID);
		if (backgroundButton && backgroundButton->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(backgroundButton.get());
			if (button->m_Clicked)
			{
				auto selectedElement = m_gui->GetElement(m_selectedElementID);

				// Handle panel background color
				if (selectedElement && selectedElement->m_Type == GUI_PANEL)
				{
					auto panel = static_cast<GuiPanel*>(selectedElement.get());

					// Track that we're editing panel background color
					m_editingColorProperty = PANEL_BACKGROUND;

					// Set color on ColorPickerState and push it
					auto colorPickerState = static_cast<ColorPickerState*>(g_StateMachine->GetState(1));
					colorPickerState->SetColor(panel->m_Color);
					g_StateMachine->PushState(1);

					Log("Opening color picker for panel background color");
				}
			}
		}
	}

	// Check for PROPERTY_BORDERCOLOR button click (for textinput and textbutton)
	int borderColorButtonID = m_propertySerializer->GetElementID("PROPERTY_BORDERCOLOR");
	if (borderColorButtonID != -1 && m_selectedElementID != -1)
	{
		auto borderColorButton = m_gui->GetElement(borderColorButtonID);
		if (borderColorButton && borderColorButton->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(borderColorButton.get());
			if (button->m_Clicked)
			{
				auto selectedElement = m_gui->GetElement(m_selectedElementID);

				if (selectedElement && selectedElement->m_Type == GUI_TEXTINPUT)
				{
					auto textinput = static_cast<GuiTextInput*>(selectedElement.get());
					m_editingColorProperty = TEXTINPUT_BORDERCOLOR;
					auto colorPickerState = static_cast<ColorPickerState*>(g_StateMachine->GetState(1));
					colorPickerState->SetColor(textinput->m_BoxColor);
					g_StateMachine->PushState(1);
					Log("Opening color picker for textinput border color");
				}
				else if (selectedElement && selectedElement->m_Type == GUI_TEXTBUTTON)
				{
					auto textbutton = static_cast<GuiTextButton*>(selectedElement.get());
					m_editingColorProperty = TEXTBUTTON_BORDERCOLOR;
					auto colorPickerState = static_cast<ColorPickerState*>(g_StateMachine->GetState(1));
					colorPickerState->SetColor(textbutton->m_BorderColor);
					g_StateMachine->PushState(1);
					Log("Opening color picker for textbutton border color");
				}
			}
		}
	}

	// Check for PROPERTY_BACKGROUNDCOLOR button click (for textinput and textbutton)
	int backgroundColorButtonID = m_propertySerializer->GetElementID("PROPERTY_BACKGROUNDCOLOR");
	if (backgroundColorButtonID != -1 && m_selectedElementID != -1)
	{
		auto backgroundColorButton = m_gui->GetElement(backgroundColorButtonID);
		if (backgroundColorButton && backgroundColorButton->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(backgroundColorButton.get());
			if (button->m_Clicked)
			{
				auto selectedElement = m_gui->GetElement(m_selectedElementID);

				if (selectedElement && selectedElement->m_Type == GUI_TEXTINPUT)
				{
					auto textinput = static_cast<GuiTextInput*>(selectedElement.get());
					m_editingColorProperty = TEXTINPUT_BACKGROUNDCOLOR;
					auto colorPickerState = static_cast<ColorPickerState*>(g_StateMachine->GetState(1));
					colorPickerState->SetColor(textinput->m_BackgroundColor);
					g_StateMachine->PushState(1);
					Log("Opening color picker for textinput background color");
				}
				else if (selectedElement && selectedElement->m_Type == GUI_TEXTBUTTON)
				{
					auto textbutton = static_cast<GuiTextButton*>(selectedElement.get());
					m_editingColorProperty = TEXTBUTTON_BACKGROUNDCOLOR;
					auto colorPickerState = static_cast<ColorPickerState*>(g_StateMachine->GetState(1));
					colorPickerState->SetColor(textbutton->m_BackgroundColor);
					g_StateMachine->PushState(1);
					Log("Opening color picker for textbutton background color");
				}
				else if (selectedElement && selectedElement->m_Type == GUI_SCROLLBAR)
				{
					auto scrollbar = static_cast<GuiScrollBar*>(selectedElement.get());
					m_editingColorProperty = SCROLLBAR_BACKGROUNDCOLOR;
					auto colorPickerState = static_cast<ColorPickerState*>(g_StateMachine->GetState(1));
					colorPickerState->SetColor(scrollbar->m_BackgroundColor);
					g_StateMachine->PushState(1);
					Log("Opening color picker for scrollbar background color");
				}
			}
		}
	}

	// Check for PROPERTY_SPURCOLOR button click to open color picker (for scrollbar)
	int spurColorButtonID = m_propertySerializer->GetElementID("PROPERTY_SPURCOLOR");
	if (spurColorButtonID != -1 && m_selectedElementID != -1)
	{
		auto spurColorButton = m_gui->GetElement(spurColorButtonID);
		if (spurColorButton && spurColorButton->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(spurColorButton.get());
			if (button->m_Clicked)
			{
				auto selectedElement = m_gui->GetElement(m_selectedElementID);

				if (selectedElement && selectedElement->m_Type == GUI_SCROLLBAR)
				{
					auto scrollbar = static_cast<GuiScrollBar*>(selectedElement.get());
					m_editingColorProperty = SCROLLBAR_SPURCOLOR;
					auto colorPickerState = static_cast<ColorPickerState*>(g_StateMachine->GetState(1));
					colorPickerState->SetColor(scrollbar->m_SpurColor);
					g_StateMachine->PushState(1);
					Log("Opening color picker for scrollbar spur color");
				}
			}
		}
	}

	if (activeID >= 3000 && activeID != lastActiveID)
	{
		lastActiveID = activeID;

		// Track initial values when property inputs are activated
		// This ensures we have the correct baseline before checking for changes
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
		lastColumnsValue = "";
		lastSpriteValue = "";
		lastTextValue = "";
		lastHorzPaddingValue = "";
		lastVertPaddingValue = "";
		lastFontValue = "";
		lastFontSizeValue = "";
	}

	// Check for property value changes while typing (for live updates)
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
		tempFileJson["gui"]["position"] = {0, 0};
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

				// Disable interactive elements in the pasted content (IDs 2001-2999)
				for (auto& [id, element] : m_gui->m_GuiElementList)
				{
					if (id >= 2001 && id < 3000 && element)
					{
						if (element->m_Type == GUI_TEXTINPUT || element->m_Type == GUI_RADIOBUTTON || element->m_Type == GUI_CHECKBOX)
						{
							element->m_Active = false;
						}
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

		// Show file open dialog
		string filepath = FileDialog::OpenFile("Open Ghost File", "Ghost Files (*.ghost)\0*.ghost\0All Files (*.*)\0*.*\0");

		if (!filepath.empty())
		{
			LoadGhostFile(filepath);  // LoadGhostFile now handles clearing content
		}
	}
	else if (activeID == m_serializer->GetElementID("SAVE"))
	{
		Log("Save button clicked!");

		// If no file is loaded, prompt for a filename
		if (m_loadedGhostFile.empty())
		{
			Log("No file loaded, showing save dialog");
			string filepath = FileDialog::SaveFile("Save Ghost File", "Ghost Files (*.ghost)\0*.ghost\0All Files (*.*)\0*.*\0");

			if (filepath.empty())
			{
				Log("Save cancelled by user");
				return;
			}

			// Ensure .ghost extension
			if (filepath.find(".ghost") == string::npos)
			{
				filepath += ".ghost";
			}

			m_loadedGhostFile = filepath;
		}

		SaveGhostFile();
	}
	else if (activeID == m_serializer->GetElementID("SAVE AS"))
	{
		Log("Save As button clicked!");

		// Always prompt for a new filename
		string filepath = FileDialog::SaveFile("Save Ghost File As", "Ghost Files (*.ghost)\0*.ghost\0All Files (*.*)\0*.*\0");

		if (filepath.empty())
		{
			Log("Save As cancelled by user");
			return;
		}

		// Ensure .ghost extension
		if (filepath.find(".ghost") == string::npos)
		{
			filepath += ".ghost";
		}

		m_loadedGhostFile = filepath;
		SaveGhostFile();
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
			"PROPERTY_FONT_SIZE"
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
			if (m_selectedElementID != -1)
			{
				auto selectedElement = m_gui->GetElement(m_selectedElementID);

				if (m_editingColorProperty == PANEL_BACKGROUND && selectedElement->m_Type == GUI_PANEL)
				{
					auto panel = static_cast<GuiPanel*>(selectedElement.get());
					panel->m_Color = selectedColor;
					Log("Applied panel background color from picker");

					// Update the PROPERTY_BACKGROUND button text color to match
					int backgroundButtonID = m_propertySerializer->GetElementID("PROPERTY_BACKGROUND");
					if (backgroundButtonID != -1)
					{
						auto backgroundButton = m_gui->GetElement(backgroundButtonID);
						if (backgroundButton && backgroundButton->m_Type == GUI_TEXTBUTTON)
						{
							auto button = static_cast<GuiTextButton*>(backgroundButton.get());
							button->m_TextColor = selectedColor;
							Log("Updated PROPERTY_BACKGROUND button text color to match new panel color");
						}
					}
				}
				else if (m_editingColorProperty == TEXTAREA_TEXTCOLOR && selectedElement->m_Type == GUI_TEXTAREA)
				{
					auto textarea = static_cast<GuiTextArea*>(selectedElement.get());
					textarea->m_Color = selectedColor;
					Log("Applied textarea text color from picker");

					// Update the PROPERTY_TEXTCOLOR button text color to match
					int textColorButtonID = m_propertySerializer->GetElementID("PROPERTY_TEXTCOLOR");
					if (textColorButtonID != -1)
					{
						auto textColorButton = m_gui->GetElement(textColorButtonID);
						if (textColorButton && textColorButton->m_Type == GUI_TEXTBUTTON)
						{
							auto button = static_cast<GuiTextButton*>(textColorButton.get());
							button->m_TextColor = selectedColor;
							Log("Updated PROPERTY_TEXTCOLOR button text color to match new textarea color");
						}
					}
				}
				else if (m_editingColorProperty == TEXTINPUT_TEXTCOLOR && selectedElement->m_Type == GUI_TEXTINPUT)
				{
					auto textinput = static_cast<GuiTextInput*>(selectedElement.get());
					textinput->m_TextColor = selectedColor;
					Log("Applied textinput text color from picker");

					// Update button text color
					int textColorButtonID = m_propertySerializer->GetElementID("PROPERTY_TEXTCOLOR");
					if (textColorButtonID != -1)
					{
						auto button = static_cast<GuiTextButton*>(m_gui->GetElement(textColorButtonID).get());
						if (button) button->m_TextColor = selectedColor;
					}
				}
				else if (m_editingColorProperty == TEXTINPUT_BORDERCOLOR && selectedElement->m_Type == GUI_TEXTINPUT)
				{
					auto textinput = static_cast<GuiTextInput*>(selectedElement.get());
					textinput->m_BoxColor = selectedColor;
					Log("Applied textinput border color from picker");

					// Update button text color
					int borderColorButtonID = m_propertySerializer->GetElementID("PROPERTY_BORDERCOLOR");
					if (borderColorButtonID != -1)
					{
						auto button = static_cast<GuiTextButton*>(m_gui->GetElement(borderColorButtonID).get());
						if (button) button->m_TextColor = selectedColor;
					}
				}
				else if (m_editingColorProperty == TEXTINPUT_BACKGROUNDCOLOR && selectedElement->m_Type == GUI_TEXTINPUT)
				{
					auto textinput = static_cast<GuiTextInput*>(selectedElement.get());
					textinput->m_BackgroundColor = selectedColor;
					Log("Applied textinput background color from picker");

					// Update button text color
					int backgroundColorButtonID = m_propertySerializer->GetElementID("PROPERTY_BACKGROUNDCOLOR");
					if (backgroundColorButtonID != -1)
					{
						auto button = static_cast<GuiTextButton*>(m_gui->GetElement(backgroundColorButtonID).get());
						if (button) button->m_TextColor = selectedColor;
					}
				}
				else if (m_editingColorProperty == TEXTBUTTON_TEXTCOLOR && selectedElement->m_Type == GUI_TEXTBUTTON)
				{
					auto textbutton = static_cast<GuiTextButton*>(selectedElement.get());
					textbutton->m_TextColor = selectedColor;
					Log("Applied textbutton text color from picker");

					// Update button text color
					int textColorButtonID = m_propertySerializer->GetElementID("PROPERTY_TEXTCOLOR");
					if (textColorButtonID != -1)
					{
						auto button = static_cast<GuiTextButton*>(m_gui->GetElement(textColorButtonID).get());
						if (button) button->m_TextColor = selectedColor;
					}
				}
				else if (m_editingColorProperty == TEXTBUTTON_BORDERCOLOR && selectedElement->m_Type == GUI_TEXTBUTTON)
				{
					auto textbutton = static_cast<GuiTextButton*>(selectedElement.get());
					textbutton->m_BorderColor = selectedColor;
					Log("Applied textbutton border color from picker");

					// Update button text color
					int borderColorButtonID = m_propertySerializer->GetElementID("PROPERTY_BORDERCOLOR");
					if (borderColorButtonID != -1)
					{
						auto button = static_cast<GuiTextButton*>(m_gui->GetElement(borderColorButtonID).get());
						if (button) button->m_TextColor = selectedColor;
					}
				}
				else if (m_editingColorProperty == TEXTBUTTON_BACKGROUNDCOLOR && selectedElement->m_Type == GUI_TEXTBUTTON)
				{
					auto textbutton = static_cast<GuiTextButton*>(selectedElement.get());
					textbutton->m_BackgroundColor = selectedColor;
					Log("Applied textbutton background color from picker");

					// Update button text color
					int backgroundColorButtonID = m_propertySerializer->GetElementID("PROPERTY_BACKGROUNDCOLOR");
					if (backgroundColorButtonID != -1)
					{
						auto button = static_cast<GuiTextButton*>(m_gui->GetElement(backgroundColorButtonID).get());
						if (button) button->m_TextColor = selectedColor;
					}
				}
				else if (m_editingColorProperty == SCROLLBAR_SPURCOLOR && selectedElement->m_Type == GUI_SCROLLBAR)
				{
					auto scrollbar = static_cast<GuiScrollBar*>(selectedElement.get());
					scrollbar->m_SpurColor = selectedColor;
					Log("Applied scrollbar spur color from picker");

					// Update button text color
					int spurColorButtonID = m_propertySerializer->GetElementID("PROPERTY_SPURCOLOR");
					if (spurColorButtonID != -1)
					{
						auto button = static_cast<GuiTextButton*>(m_gui->GetElement(spurColorButtonID).get());
						if (button) button->m_TextColor = selectedColor;
					}
				}
				else if (m_editingColorProperty == SCROLLBAR_BACKGROUNDCOLOR && selectedElement->m_Type == GUI_SCROLLBAR)
				{
					auto scrollbar = static_cast<GuiScrollBar*>(selectedElement.get());
					scrollbar->m_BackgroundColor = selectedColor;
					Log("Applied scrollbar background color from picker");

					// Update button text color
					int backgroundColorButtonID = m_propertySerializer->GetElementID("PROPERTY_BACKGROUNDCOLOR");
					if (backgroundColorButtonID != -1)
					{
						auto button = static_cast<GuiTextButton*>(m_gui->GetElement(backgroundColorButtonID).get());
						if (button) button->m_TextColor = selectedColor;
					}
				}

				Log("Applied color: R=" + std::to_string(selectedColor.r) +
					", G=" + std::to_string(selectedColor.g) +
					", B=" + std::to_string(selectedColor.b) +
					", A=" + std::to_string(selectedColor.a));
			}

			// Reset the tracking variable
			m_editingColorProperty = NONE;
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
	m_contentSerializer = make_unique<GuiSerializer>();
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
				if (element->m_Type == GUI_TEXTINPUT || element->m_Type == GUI_RADIOBUTTON || element->m_Type == GUI_CHECKBOX)
				{
					element->m_Active = false;
					Log("Disabled interactive element in content panel: ID " + to_string(id) + ", type " + to_string(element->m_Type));
				}
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
		m_contentSerializer = make_unique<GuiSerializer>();
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

	// Load default sprite image
	string defaultSpriteName = "image.png";
	string spritePath = m_spritePath + defaultSpriteName;
	Texture* texture = g_ResourceManager->GetTexture(spritePath);

	// Create sprite with the loaded texture
	shared_ptr<Sprite> sprite = make_shared<Sprite>();
	sprite->m_texture = texture;
	sprite->m_sourceRect = Rectangle{0, 0, float(texture->width), float(texture->height)};

	Log("Loaded sprite from: " + spritePath + " (size: " + to_string(texture->width) + "x" + to_string(texture->height) + ")");

	// Add sprite at calculated position
	m_gui->AddSprite(ctx.newID, ctx.absoluteX, ctx.absoluteY, sprite, 1.0f, 1.0f, WHITE, 0, true);

	// Store the sprite filename for serialization
	m_contentSerializer->SetSpriteName(ctx.newID, defaultSpriteName);

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

	// Load default sprite image for icon button
	string defaultSpriteName = "image.png";
	string spritePath = m_spritePath + defaultSpriteName;
	Texture* texture = g_ResourceManager->GetTexture(spritePath);

	// Create sprite for the button
	shared_ptr<Sprite> sprite = make_shared<Sprite>();
	sprite->m_texture = texture;
	sprite->m_sourceRect = Rectangle{0, 0, float(texture->width), float(texture->height)};

	// Add icon button at calculated position (using simple form with one sprite)
	m_gui->AddIconButton(ctx.newID, ctx.absoluteX, ctx.absoluteY, sprite, nullptr, nullptr, "", nullptr, WHITE, 1.0f, 0, true, false);

	// Store the sprite filename for serialization
	m_contentSerializer->SetSpriteName(ctx.newID, defaultSpriteName);

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

	// Load default sprite image for stretch button parts
	string defaultSpriteName = "image.png";
	string spritePath = m_spritePath + defaultSpriteName;
	Texture* texture = g_ResourceManager->GetTexture(spritePath);

	// Create sprites for left, center, and right parts (active and inactive)
	auto createSprite = [&]() {
		shared_ptr<Sprite> sprite = make_shared<Sprite>();
		sprite->m_texture = texture;
		sprite->m_sourceRect = Rectangle{0, 0, float(texture->width), float(texture->height)};
		return sprite;
	};

	shared_ptr<Sprite> activeLeft = createSprite();
	shared_ptr<Sprite> activeCenter = createSprite();
	shared_ptr<Sprite> activeRight = createSprite();
	shared_ptr<Sprite> inactiveLeft = createSprite();
	shared_ptr<Sprite> inactiveCenter = createSprite();
	shared_ptr<Sprite> inactiveRight = createSprite();

	// Add stretch button at calculated position
	m_gui->AddStretchButton(ctx.newID, ctx.absoluteX, ctx.absoluteY, 100, "Button",
		activeLeft, activeRight, activeCenter, inactiveLeft, inactiveRight, inactiveCenter,
		0, WHITE, 0, true, false);

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
	m_propertySerializer = make_unique<GuiSerializer>();
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

	// Get the PROPERTY_NAME input from property panel
	int nameInputID = m_propertySerializer->GetElementID("PROPERTY_NAME");
	if (nameInputID != -1)
	{
		auto nameInput = m_gui->GetElement(nameInputID);
		if (nameInput && nameInput->m_Type == GUI_TEXTINPUT)
		{
			// Get the selected element's name
			std::string elementName = GetElementName(m_selectedElementID);

			// Populate the input with the name
			auto textInput = static_cast<GuiTextInput*>(nameInput.get());
			textInput->m_String = elementName;

			Log("Populated PROPERTY_NAME with: " + elementName);
		}
	}

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

		// First, manually deselect all radio buttons in the group to ensure clean state
		if (horzRadioID != -1)
		{
			auto horzRadio = m_gui->GetElement(horzRadioID);
			if (horzRadio && horzRadio->m_Type == GUI_RADIOBUTTON)
			{
				horzRadio->m_Selected = false;
			}
		}
		if (vertRadioID != -1)
		{
			auto vertRadio = m_gui->GetElement(vertRadioID);
			if (vertRadio && vertRadio->m_Type == GUI_RADIOBUTTON)
			{
				vertRadio->m_Selected = false;
			}
		}
		if (tableRadioID != -1)
		{
			auto tableRadio = m_gui->GetElement(tableRadioID);
			if (tableRadio && tableRadio->m_Type == GUI_RADIOBUTTON)
			{
				tableRadio->m_Selected = false;
			}
		}

		// Now set the correct one to selected AND deselect all others in group
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
		int columnsInputID = m_propertySerializer->GetElementID("PROPERTY_COLUMNS");
		if (columnsInputID != -1)
		{
			auto columnsInput = m_gui->GetElement(columnsInputID);
			if (columnsInput && columnsInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(columnsInput.get());
				textInput->m_String = to_string(columns);
				Log("Populated PROPERTY_COLUMNS with: " + to_string(columns));
			}
			else if (columnsInput && columnsInput->m_Type == GUI_SCROLLBAR)
			{
				auto scrollbar = static_cast<GuiScrollBar*>(columnsInput.get());
				scrollbar->m_Value = columns;
				Log("Populated PROPERTY_COLUMNS scrollbar with: " + to_string(columns));
			}
		}

		// Populate horizontal padding field (can be textinput or scrollbar)
		int horzPadding = m_contentSerializer->GetPanelHorzPadding(m_selectedElementID);
		int horzPaddingInputID = m_propertySerializer->GetElementID("PROPERTY_HORZ_PADDING");
		if (horzPaddingInputID != -1)
		{
			auto horzPaddingInput = m_gui->GetElement(horzPaddingInputID);
			if (horzPaddingInput && horzPaddingInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(horzPaddingInput.get());
				textInput->m_String = to_string(horzPadding);
				Log("Populated PROPERTY_HORZ_PADDING with: " + to_string(horzPadding));
			}
			else if (horzPaddingInput && horzPaddingInput->m_Type == GUI_SCROLLBAR)
			{
				auto scrollbar = static_cast<GuiScrollBar*>(horzPaddingInput.get());
				scrollbar->m_Value = horzPadding;
				Log("Populated PROPERTY_HORZ_PADDING scrollbar with: " + to_string(horzPadding));
			}
		}

		// Populate vertical padding field (can be textinput or scrollbar)
		int vertPadding = m_contentSerializer->GetPanelVertPadding(m_selectedElementID);
		int vertPaddingInputID = m_propertySerializer->GetElementID("PROPERTY_VERT_PADDING");
		if (vertPaddingInputID != -1)
		{
			auto vertPaddingInput = m_gui->GetElement(vertPaddingInputID);
			if (vertPaddingInput && vertPaddingInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(vertPaddingInput.get());
				textInput->m_String = to_string(vertPadding);
				Log("Populated PROPERTY_VERT_PADDING with: " + to_string(vertPadding));
			}
			else if (vertPaddingInput && vertPaddingInput->m_Type == GUI_SCROLLBAR)
			{
				auto scrollbar = static_cast<GuiScrollBar*>(vertPaddingInput.get());
				scrollbar->m_Value = vertPadding;
				Log("Populated PROPERTY_VERT_PADDING scrollbar with: " + to_string(vertPadding));
			}
		}

		Log("Finished populating layout properties - layout: " + layout + ", columns: " + to_string(columns));
	}

	// Populate sprite filename field (for sprite elements)
	if (selectedElement && selectedElement->m_Type == GUI_SPRITE)
	{
		int spriteInputID = m_propertySerializer->GetElementID("PROPERTY_SPRITE");
		if (spriteInputID != -1)
		{
			auto spriteInput = m_gui->GetElement(spriteInputID);
			if (spriteInput && spriteInput->m_Type == GUI_TEXTINPUT)
			{
				// Get the sprite's filename from the serializer
				std::string filename = m_contentSerializer->GetSpriteName(m_selectedElementID);

				// Populate the input with the filename
				auto textInput = static_cast<GuiTextInput*>(spriteInput.get());
				textInput->m_String = filename;

				Log("Populated PROPERTY_SPRITE with: " + filename);
			}
		}
	}

	// Populate font fields (for panels and text elements)
	int fontInputID = m_propertySerializer->GetElementID("PROPERTY_FONT");
	if (fontInputID != -1)
	{
		auto fontInput = m_gui->GetElement(fontInputID);
		if (fontInput && fontInput->m_Type == GUI_TEXTINPUT)
		{
			// Get the font from the serializer
			std::string font = m_contentSerializer->GetElementFont(m_selectedElementID);

			// Populate the input with the font name
			auto textInput = static_cast<GuiTextInput*>(fontInput.get());
			textInput->m_String = font;

			Log("Populated PROPERTY_FONT with: " + font);
		}
	}

	int fontSizeInputID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
	if (fontSizeInputID != -1)
	{
		auto fontSizeInput = m_gui->GetElement(fontSizeInputID);
		// Get the font size from the serializer
		int fontSize = m_contentSerializer->GetElementFontSize(m_selectedElementID);

		if (fontSizeInput && fontSizeInput->m_Type == GUI_TEXTINPUT)
		{
			// Populate the input with the font size (only if not 0, which means not set)
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
			// Populate the scrollbar with the font size
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

	// Populate scrollbar/slider properties (for scrollbar elements)
	if (selectedElement && selectedElement->m_Type == GUI_SCROLLBAR)
	{
		auto scrollbar = static_cast<GuiScrollBar*>(selectedElement.get());

		// Populate PROPERTY_WIDTH
		int widthInputID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
		if (widthInputID != -1)
		{
			auto widthInput = m_gui->GetElement(widthInputID);
			if (widthInput && widthInput->m_Type == GUI_SCROLLBAR)
			{
				auto widthScrollbar = static_cast<GuiScrollBar*>(widthInput.get());
				widthScrollbar->m_Value = static_cast<int>(scrollbar->m_Width);
				Log("Populated PROPERTY_WIDTH scrollbar with: " + to_string(static_cast<int>(scrollbar->m_Width)));
			}
		}

		// Populate PROPERTY_HEIGHT
		int heightInputID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
		if (heightInputID != -1)
		{
			auto heightInput = m_gui->GetElement(heightInputID);
			if (heightInput && heightInput->m_Type == GUI_SCROLLBAR)
			{
				auto heightScrollbar = static_cast<GuiScrollBar*>(heightInput.get());
				heightScrollbar->m_Value = static_cast<int>(scrollbar->m_Height);
				Log("Populated PROPERTY_HEIGHT scrollbar with: " + to_string(static_cast<int>(scrollbar->m_Height)));
			}
		}

		// Populate PROPERTY_VALUE_RANGE
		int valueRangeInputID = m_propertySerializer->GetElementID("PROPERTY_VALUE_RANGE");
		if (valueRangeInputID != -1)
		{
			auto valueRangeInput = m_gui->GetElement(valueRangeInputID);
			if (valueRangeInput && valueRangeInput->m_Type == GUI_SCROLLBAR)
			{
				auto valueRangeScrollbar = static_cast<GuiScrollBar*>(valueRangeInput.get());
				valueRangeScrollbar->m_Value = scrollbar->m_ValueRange;
				Log("Populated PROPERTY_VALUE_RANGE scrollbar with: " + to_string(scrollbar->m_ValueRange));
			}
		}

		// Populate PROPERTY_VERTICAL checkbox
		int verticalCheckboxID = m_propertySerializer->GetElementID("PROPERTY_VERTICAL");
		if (verticalCheckboxID != -1)
		{
			auto verticalCheckbox = m_gui->GetElement(verticalCheckboxID);
			if (verticalCheckbox && verticalCheckbox->m_Type == GUI_CHECKBOX)
			{
				verticalCheckbox->m_Selected = scrollbar->m_Vertical;
				Log("Populated PROPERTY_VERTICAL checkbox with: " + to_string(scrollbar->m_Vertical));
			}
		}
	}

	// Populate textinput properties (for textinput elements)
	if (selectedElement && selectedElement->m_Type == GUI_TEXTINPUT)
	{
		auto textinput = static_cast<GuiTextInput*>(selectedElement.get());

		// Populate PROPERTY_WIDTH
		int widthInputID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
		if (widthInputID != -1)
		{
			auto widthInput = m_gui->GetElement(widthInputID);
			if (widthInput && widthInput->m_Type == GUI_SCROLLBAR)
			{
				auto widthScrollbar = static_cast<GuiScrollBar*>(widthInput.get());
				widthScrollbar->m_Value = static_cast<int>(textinput->m_Width);
				Log("Populated PROPERTY_WIDTH scrollbar with: " + to_string(static_cast<int>(textinput->m_Width)));
			}
		}

		// Populate PROPERTY_HEIGHT
		int heightInputID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
		if (heightInputID != -1)
		{
			auto heightInput = m_gui->GetElement(heightInputID);
			if (heightInput && heightInput->m_Type == GUI_SCROLLBAR)
			{
				auto heightScrollbar = static_cast<GuiScrollBar*>(heightInput.get());
				heightScrollbar->m_Value = static_cast<int>(textinput->m_Height);
				Log("Populated PROPERTY_HEIGHT scrollbar with: " + to_string(static_cast<int>(textinput->m_Height)));
			}
		}

		// Populate PROPERTY_FONT
		int fontInputID = m_propertySerializer->GetElementID("PROPERTY_FONT");
		if (fontInputID != -1)
		{
			auto fontInput = m_gui->GetElement(fontInputID);
			if (fontInput && fontInput->m_Type == GUI_TEXTINPUT)
			{
				auto fontTextInput = static_cast<GuiTextInput*>(fontInput.get());
				std::string fontName = m_contentSerializer->GetElementFont(m_selectedElementID);
				fontTextInput->m_String = fontName;
				Log("Populated PROPERTY_FONT with: " + fontName);
			}
		}

		// Populate PROPERTY_FONT_SIZE
		int fontSizeInputID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
		if (fontSizeInputID != -1)
		{
			auto fontSizeInput = m_gui->GetElement(fontSizeInputID);
			if (fontSizeInput && fontSizeInput->m_Type == GUI_SCROLLBAR)
			{
				auto fontSizeScrollbar = static_cast<GuiScrollBar*>(fontSizeInput.get());
				int fontSize = m_contentSerializer->GetElementFontSize(m_selectedElementID);
				fontSizeScrollbar->m_Value = fontSize;
				Log("Populated PROPERTY_FONT_SIZE scrollbar with: " + to_string(fontSize));
			}
		}
	}

	// Populate checkbox properties (for checkbox elements)
	if (selectedElement && selectedElement->m_Type == GUI_CHECKBOX)
	{
		auto checkbox = static_cast<GuiCheckBox*>(selectedElement.get());

		// Populate PROPERTY_WIDTH
		int widthInputID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
		if (widthInputID != -1)
		{
			auto widthInput = m_gui->GetElement(widthInputID);
			if (widthInput && widthInput->m_Type == GUI_SCROLLBAR)
			{
				auto widthScrollbar = static_cast<GuiScrollBar*>(widthInput.get());
				widthScrollbar->m_Value = static_cast<int>(checkbox->m_Width);
				Log("Populated PROPERTY_WIDTH scrollbar with: " + to_string(static_cast<int>(checkbox->m_Width)));
			}
		}

		// Populate PROPERTY_HEIGHT
		int heightInputID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
		if (heightInputID != -1)
		{
			auto heightInput = m_gui->GetElement(heightInputID);
			if (heightInput && heightInput->m_Type == GUI_SCROLLBAR)
			{
				auto heightScrollbar = static_cast<GuiScrollBar*>(heightInput.get());
				heightScrollbar->m_Value = static_cast<int>(checkbox->m_Height);
				Log("Populated PROPERTY_HEIGHT scrollbar with: " + to_string(static_cast<int>(checkbox->m_Height)));
			}
		}

		// Populate PROPERTY_GROUP
		int groupInputID = m_propertySerializer->GetElementID("PROPERTY_GROUP");
		if (groupInputID != -1)
		{
			auto groupInput = m_gui->GetElement(groupInputID);
			if (groupInput && groupInput->m_Type == GUI_SCROLLBAR)
			{
				auto groupScrollbar = static_cast<GuiScrollBar*>(groupInput.get());
				groupScrollbar->m_Value = checkbox->m_Group;
				Log("Populated PROPERTY_GROUP scrollbar with: " + to_string(checkbox->m_Group));
			}
		}
	}

	// Populate radiobutton properties (for radiobutton elements)
	if (selectedElement && selectedElement->m_Type == GUI_RADIOBUTTON)
	{
		auto radiobutton = static_cast<GuiRadioButton*>(selectedElement.get());

		// Populate PROPERTY_WIDTH
		int widthInputID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
		if (widthInputID != -1)
		{
			auto widthInput = m_gui->GetElement(widthInputID);
			if (widthInput && widthInput->m_Type == GUI_SCROLLBAR)
			{
				auto widthScrollbar = static_cast<GuiScrollBar*>(widthInput.get());
				widthScrollbar->m_Value = static_cast<int>(radiobutton->m_Width);
				Log("Populated PROPERTY_WIDTH scrollbar with: " + to_string(static_cast<int>(radiobutton->m_Width)));
			}
		}

		// Populate PROPERTY_HEIGHT
		int heightInputID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
		if (heightInputID != -1)
		{
			auto heightInput = m_gui->GetElement(heightInputID);
			if (heightInput && heightInput->m_Type == GUI_SCROLLBAR)
			{
				auto heightScrollbar = static_cast<GuiScrollBar*>(heightInput.get());
				heightScrollbar->m_Value = static_cast<int>(radiobutton->m_Height);
				Log("Populated PROPERTY_HEIGHT scrollbar with: " + to_string(static_cast<int>(radiobutton->m_Height)));
			}
		}

		// Populate PROPERTY_GROUP
		int groupInputID = m_propertySerializer->GetElementID("PROPERTY_GROUP");
		if (groupInputID != -1)
		{
			auto groupInput = m_gui->GetElement(groupInputID);
			if (groupInput && groupInput->m_Type == GUI_SCROLLBAR)
			{
				auto groupScrollbar = static_cast<GuiScrollBar*>(groupInput.get());
				groupScrollbar->m_Value = radiobutton->m_Group;
				Log("Populated PROPERTY_GROUP scrollbar with: " + to_string(radiobutton->m_Group));
			}
		}
	}

	// Update color picker button text colors to match the active colors
	// For textarea: update PROPERTY_TEXTCOLOR button to show current text color
	if (selectedElement && selectedElement->m_Type == GUI_TEXTAREA)
	{
		auto textarea = static_cast<GuiTextArea*>(selectedElement.get());
		int textColorButtonID = m_propertySerializer->GetElementID("PROPERTY_TEXTCOLOR");
		if (textColorButtonID != -1)
		{
			auto textColorButton = m_gui->GetElement(textColorButtonID);
			if (textColorButton && textColorButton->m_Type == GUI_TEXTBUTTON)
			{
				auto button = static_cast<GuiTextButton*>(textColorButton.get());
				button->m_TextColor = textarea->m_Color;
				Log("Updated PROPERTY_TEXTCOLOR button text color to match textarea text color");
			}
		}
	}

	// For panel: update PROPERTY_BACKGROUND button to show current background color
	if (selectedElement && selectedElement->m_Type == GUI_PANEL)
	{
		auto panel = static_cast<GuiPanel*>(selectedElement.get());
		int backgroundButtonID = m_propertySerializer->GetElementID("PROPERTY_BACKGROUND");
		if (backgroundButtonID != -1)
		{
			auto backgroundButton = m_gui->GetElement(backgroundButtonID);
			if (backgroundButton && backgroundButton->m_Type == GUI_TEXTBUTTON)
			{
				auto button = static_cast<GuiTextButton*>(backgroundButton.get());
				button->m_TextColor = panel->m_Color;
				Log("Updated PROPERTY_BACKGROUND button text color to match panel background color");
			}
		}
	}

	// For textinput: update color buttons to show current colors
	if (selectedElement && selectedElement->m_Type == GUI_TEXTINPUT)
	{
		auto textinput = static_cast<GuiTextInput*>(selectedElement.get());

		// Update PROPERTY_TEXTCOLOR button
		int textColorButtonID = m_propertySerializer->GetElementID("PROPERTY_TEXTCOLOR");
		if (textColorButtonID != -1)
		{
			auto button = static_cast<GuiTextButton*>(m_gui->GetElement(textColorButtonID).get());
			if (button) button->m_TextColor = textinput->m_TextColor;
		}

		// Update PROPERTY_BORDERCOLOR button
		int borderColorButtonID = m_propertySerializer->GetElementID("PROPERTY_BORDERCOLOR");
		if (borderColorButtonID != -1)
		{
			auto button = static_cast<GuiTextButton*>(m_gui->GetElement(borderColorButtonID).get());
			if (button) button->m_TextColor = textinput->m_BoxColor;
		}

		// Update PROPERTY_BACKGROUNDCOLOR button
		int backgroundColorButtonID = m_propertySerializer->GetElementID("PROPERTY_BACKGROUNDCOLOR");
		if (backgroundColorButtonID != -1)
		{
			auto button = static_cast<GuiTextButton*>(m_gui->GetElement(backgroundColorButtonID).get());
			if (button) button->m_TextColor = textinput->m_BackgroundColor;
		}
	}

	// For textbutton: update color buttons to show current colors
	if (selectedElement && selectedElement->m_Type == GUI_TEXTBUTTON)
	{
		auto textbutton = static_cast<GuiTextButton*>(selectedElement.get());

		// Update PROPERTY_TEXTCOLOR button
		int textColorButtonID = m_propertySerializer->GetElementID("PROPERTY_TEXTCOLOR");
		if (textColorButtonID != -1)
		{
			auto button = static_cast<GuiTextButton*>(m_gui->GetElement(textColorButtonID).get());
			if (button) button->m_TextColor = textbutton->m_TextColor;
		}

		// Update PROPERTY_BORDERCOLOR button
		int borderColorButtonID = m_propertySerializer->GetElementID("PROPERTY_BORDERCOLOR");
		if (borderColorButtonID != -1)
		{
			auto button = static_cast<GuiTextButton*>(m_gui->GetElement(borderColorButtonID).get());
			if (button) button->m_TextColor = textbutton->m_BorderColor;
		}

		// Update PROPERTY_BACKGROUNDCOLOR button
		int backgroundColorButtonID = m_propertySerializer->GetElementID("PROPERTY_BACKGROUNDCOLOR");
		if (backgroundColorButtonID != -1)
		{
			auto button = static_cast<GuiTextButton*>(m_gui->GetElement(backgroundColorButtonID).get());
			if (button) button->m_TextColor = textbutton->m_BackgroundColor;
		}
	}

	// For scrollbar: update color buttons to show current colors
	if (selectedElement && selectedElement->m_Type == GUI_SCROLLBAR)
	{
		auto scrollbar = static_cast<GuiScrollBar*>(selectedElement.get());

		// Update PROPERTY_SPURCOLOR button
		int spurColorButtonID = m_propertySerializer->GetElementID("PROPERTY_SPURCOLOR");
		if (spurColorButtonID != -1)
		{
			auto button = static_cast<GuiTextButton*>(m_gui->GetElement(spurColorButtonID).get());
			if (button) button->m_TextColor = scrollbar->m_SpurColor;
		}

		// Update PROPERTY_BACKGROUNDCOLOR button
		int backgroundColorButtonID = m_propertySerializer->GetElementID("PROPERTY_BACKGROUNDCOLOR");
		if (backgroundColorButtonID != -1)
		{
			auto button = static_cast<GuiTextButton*>(m_gui->GetElement(backgroundColorButtonID).get());
			if (button) button->m_TextColor = scrollbar->m_BackgroundColor;
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

	// Update PROPERTY_NAME if it exists
	int nameInputID = m_propertySerializer->GetElementID("PROPERTY_NAME");
	if (nameInputID != -1)
	{
		auto nameInput = m_gui->GetElement(nameInputID);
		if (nameInput && nameInput->m_Type == GUI_TEXTINPUT)
		{
			// Get the new name from the input
			auto textInput = static_cast<GuiTextInput*>(nameInput.get());
			std::string newName = textInput->m_String;

			// Update the element's name in the content serializer
			// First, remove old name mapping if it exists
			std::string oldName = GetElementName(m_selectedElementID);
			if (!oldName.empty())
			{
				m_contentSerializer->RemoveElementName(oldName);
			}

			// Add new name mapping if not empty
			if (!newName.empty())
			{
				m_contentSerializer->SetElementName(newName, m_selectedElementID);
				Log("Updated element " + to_string(m_selectedElementID) + " name to: " + newName);
			}

			wasUpdated = true;
		}
	}

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
		int columnsInputID = m_propertySerializer->GetElementID("PROPERTY_COLUMNS");
		if (columnsInputID != -1)
		{
			auto columnsInput = m_gui->GetElement(columnsInputID);
			int newColumns = 0;

			if (columnsInput && columnsInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(columnsInput.get());
				try
				{
					newColumns = std::stoi(textInput->m_String);
				}
				catch (...)
				{
					// Invalid number, ignore
					newColumns = 0;
				}
			}
			else if (columnsInput && columnsInput->m_Type == GUI_SCROLLBAR)
			{
				auto scrollbar = static_cast<GuiScrollBar*>(columnsInput.get());
				newColumns = scrollbar->m_Value;
			}

			if (columnsInput && newColumns > 0)
			{
				int oldColumns = m_contentSerializer->GetPanelColumns(m_selectedElementID);
				if (newColumns != oldColumns)
				{
					m_contentSerializer->SetPanelColumns(m_selectedElementID, newColumns);
					Log("Updated panel " + to_string(m_selectedElementID) + " columns from " + to_string(oldColumns) + " to " + to_string(newColumns));
					wasUpdated = true;
				}
			}
		}

		// Update horizontal padding if changed (can be textinput or scrollbar)
		int horzPaddingInputID = m_propertySerializer->GetElementID("PROPERTY_HORZ_PADDING");
		if (horzPaddingInputID != -1)
		{
			auto horzPaddingInput = m_gui->GetElement(horzPaddingInputID);
			int newHorzPadding = 0;

			if (horzPaddingInput && horzPaddingInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(horzPaddingInput.get());
				try
				{
					if (!textInput->m_String.empty())
					{
						newHorzPadding = std::stoi(textInput->m_String);
					}
				}
				catch (...)
				{
					// Invalid number, treat as 0
					newHorzPadding = 0;
				}
			}
			else if (horzPaddingInput && horzPaddingInput->m_Type == GUI_SCROLLBAR)
			{
				auto scrollbar = static_cast<GuiScrollBar*>(horzPaddingInput.get());
				newHorzPadding = scrollbar->m_Value;
			}

			if (horzPaddingInput)
			{
				int oldHorzPadding = m_contentSerializer->GetPanelHorzPadding(m_selectedElementID);
				if (newHorzPadding != oldHorzPadding && newHorzPadding >= 0)
				{
					m_contentSerializer->SetPanelHorzPadding(m_selectedElementID, newHorzPadding);
					Log("Updated panel " + to_string(m_selectedElementID) + " horz padding from " + to_string(oldHorzPadding) + " to " + to_string(newHorzPadding));
					wasUpdated = true;
				}
			}
		}

		// Update vertical padding if changed (can be textinput or scrollbar)
		int vertPaddingInputID = m_propertySerializer->GetElementID("PROPERTY_VERT_PADDING");
		if (vertPaddingInputID != -1)
		{
			auto vertPaddingInput = m_gui->GetElement(vertPaddingInputID);
			int newVertPadding = 0;

			if (vertPaddingInput && vertPaddingInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(vertPaddingInput.get());
				try
				{
					if (!textInput->m_String.empty())
					{
						newVertPadding = std::stoi(textInput->m_String);
					}
				}
				catch (...)
				{
					// Invalid number, treat as 0
					newVertPadding = 0;
				}
			}
			else if (vertPaddingInput && vertPaddingInput->m_Type == GUI_SCROLLBAR)
			{
				auto scrollbar = static_cast<GuiScrollBar*>(vertPaddingInput.get());
				newVertPadding = scrollbar->m_Value;
			}

			if (vertPaddingInput)
			{
				int oldVertPadding = m_contentSerializer->GetPanelVertPadding(m_selectedElementID);
				if (newVertPadding != oldVertPadding && newVertPadding >= 0)
				{
					m_contentSerializer->SetPanelVertPadding(m_selectedElementID, newVertPadding);
					Log("Updated panel " + to_string(m_selectedElementID) + " vert padding from " + to_string(oldVertPadding) + " to " + to_string(newVertPadding));
					wasUpdated = true;
				}
			}
		}

	}

	// Update font if changed (applies to all element types that have fonts)
	int fontInputID = m_propertySerializer->GetElementID("PROPERTY_FONT");
	if (fontInputID != -1)
	{
		auto fontInput = m_gui->GetElement(fontInputID);
		if (fontInput && fontInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(fontInput.get());
			std::string newFont = textInput->m_String;
			std::string oldFont = m_contentSerializer->GetElementFont(m_selectedElementID);

			if (newFont != oldFont && !newFont.empty())
			{
				m_contentSerializer->SetElementFont(m_selectedElementID, newFont);
				m_contentSerializer->MarkPropertyAsExplicit(m_selectedElementID, "font");

				// Reload the font with the current size and assign it to the element
				int fontSize = m_contentSerializer->GetElementFontSize(m_selectedElementID);
				if (fontSize > 0)
				{
					std::string fontPath = m_fontPath + newFont;
					auto newFontPtr = std::make_shared<Font>(LoadFontEx(fontPath.c_str(), fontSize, 0, 0));

					// Update the font on the actual GUI element based on its type
					if (selectedElement->m_Type == GUI_TEXTAREA)
					{
						auto textarea = static_cast<GuiTextArea*>(selectedElement.get());
						textarea->m_Font = newFontPtr.get();
						// Recalculate width based on new font
						Vector2 textDims = MeasureTextEx(*textarea->m_Font, textarea->m_String.c_str(), textarea->m_Font->baseSize, 1);
						textarea->m_Width = textDims.x;
					}
					else if (selectedElement->m_Type == GUI_TEXTBUTTON)
					{
						auto textbutton = static_cast<GuiTextButton*>(selectedElement.get());
						textbutton->m_Font = newFontPtr.get();
						// Recalculate width based on new font
						Vector2 textDims = MeasureTextEx(*textbutton->m_Font, textbutton->m_String.c_str(), textbutton->m_Font->baseSize, 1);
						textbutton->m_Width = textDims.x;
					}
					else if (selectedElement->m_Type == GUI_PANEL)
					{
						auto panel = static_cast<GuiPanel*>(selectedElement.get());
						panel->m_Font = newFontPtr.get();
					}

					// Keep the font alive
					m_preservedFonts.push_back(newFontPtr);
				}

				Log("Updated element " + to_string(m_selectedElementID) + " font from '" + oldFont + "' to '" + newFont + "'");
				wasUpdated = true;
			}
		}
	}

	// Update font size if changed (can be textinput or scrollbar, applies to all element types that have fonts)
	int fontSizeInputID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
	if (fontSizeInputID != -1)
	{
		auto fontSizeInput = m_gui->GetElement(fontSizeInputID);
		int newFontSize = 0;

		if (fontSizeInput && fontSizeInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(fontSizeInput.get());
			try
			{
				if (!textInput->m_String.empty())
				{
					newFontSize = std::stoi(textInput->m_String);
				}
			}
			catch (...)
			{
				// Invalid number, ignore
				newFontSize = 0;
			}
		}
		else if (fontSizeInput && fontSizeInput->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(fontSizeInput.get());
			newFontSize = scrollbar->m_Value;
		}

		if (fontSizeInput && newFontSize > 0)
		{
			int oldFontSize = m_contentSerializer->GetElementFontSize(m_selectedElementID);
			if (newFontSize != oldFontSize)
			{
				m_contentSerializer->SetElementFontSize(m_selectedElementID, newFontSize);
				m_contentSerializer->MarkPropertyAsExplicit(m_selectedElementID, "fontSize");

				// Reload the font at the new size and assign it to the element
				std::string fontName = m_contentSerializer->GetElementFont(m_selectedElementID);
				Log("Font name for element " + to_string(m_selectedElementID) + ": '" + fontName + "'");

				// If no font name is set, try to get it from the element's current font or use a default
				if (fontName.empty())
				{
					// Try to inherit from parent
					int parentID = m_contentSerializer->GetParentID(m_selectedElementID);
					if (parentID != -1)
					{
						fontName = m_contentSerializer->GetElementFont(parentID);
						Log("Inherited font '" + fontName + "' from parent " + to_string(parentID));
					}

					// If still empty, use a default font
					if (fontName.empty())
					{
						fontName = "babyblocks.ttf";  // Default font
						Log("Using default font: " + fontName);
					}

					// Store the font name so we don't have to do this again
					m_contentSerializer->SetElementFont(m_selectedElementID, fontName);
					m_contentSerializer->MarkPropertyAsExplicit(m_selectedElementID, "font");
				}

				if (!fontName.empty())
				{
					std::string fontPath = m_fontPath + fontName;
					Log("Loading font from: " + fontPath + " at size " + to_string(newFontSize));
					auto newFont = std::make_shared<Font>(LoadFontEx(fontPath.c_str(), newFontSize, 0, 0));

					// Update the font on the actual GUI element based on its type
					if (selectedElement->m_Type == GUI_TEXTAREA)
					{
						auto textarea = static_cast<GuiTextArea*>(selectedElement.get());
						textarea->m_Font = newFont.get();
						// Recalculate width and height based on new font size
						Vector2 textDims = MeasureTextEx(*textarea->m_Font, textarea->m_String.c_str(), textarea->m_Font->baseSize, 1);
						textarea->m_Width = textDims.x;
						textarea->m_Height = textDims.y;
					}
					else if (selectedElement->m_Type == GUI_TEXTBUTTON)
					{
						auto textbutton = static_cast<GuiTextButton*>(selectedElement.get());
						textbutton->m_Font = newFont.get();
						// Recalculate width and height based on new font size
						Vector2 textDims = MeasureTextEx(*textbutton->m_Font, textbutton->m_String.c_str(), textbutton->m_Font->baseSize, 1);
						textbutton->m_Width = textDims.x;
						textbutton->m_Height = textDims.y;
					}
					else if (selectedElement->m_Type == GUI_PANEL)
					{
						auto panel = static_cast<GuiPanel*>(selectedElement.get());
						panel->m_Font = newFont.get();
					}

					// Keep the font alive
					m_preservedFonts.push_back(newFont);

					// Update all children that inherited this font (don't have explicit font/fontSize)
					auto updateChildFonts = [&](int parentID, auto& updateChildFontsRef) -> void {
						// Get all children of this parent
						auto allIDs = m_contentSerializer->GetAllElementIDs();
						for (int childID : allIDs)
						{
							if (m_contentSerializer->GetParentID(childID) == parentID)
							{
								// Check if this child has explicit font properties
								bool hasExplicitFont = m_contentSerializer->GetElementFont(childID) != "";
								bool hasExplicitFontSize = m_contentSerializer->GetElementFontSize(childID) != 0;

								// Only update if the child doesn't have explicit font size (inherited from parent)
								if (!hasExplicitFontSize)
								{
									auto childElement = m_gui->GetElement(childID);
									if (childElement)
									{
										// Update the child's font based on its type
										if (childElement->m_Type == GUI_TEXTAREA)
										{
											auto textarea = static_cast<GuiTextArea*>(childElement.get());
											textarea->m_Font = newFont.get();
											Vector2 textDims = MeasureTextEx(*textarea->m_Font, textarea->m_String.c_str(), textarea->m_Font->baseSize, 1);
											textarea->m_Width = textDims.x;
											textarea->m_Height = textDims.y;
										}
										else if (childElement->m_Type == GUI_TEXTBUTTON)
										{
											auto textbutton = static_cast<GuiTextButton*>(childElement.get());
											textbutton->m_Font = newFont.get();
											Vector2 textDims = MeasureTextEx(*textbutton->m_Font, textbutton->m_String.c_str(), textbutton->m_Font->baseSize, 1);
											textbutton->m_Width = textDims.x;
											textbutton->m_Height = textDims.y;
										}
										else if (childElement->m_Type == GUI_PANEL)
										{
											auto panel = static_cast<GuiPanel*>(childElement.get());
											panel->m_Font = newFont.get();
										}

										// Recursively update this child's children
										updateChildFontsRef(childID, updateChildFontsRef);
									}
								}
							}
						}
					};
					updateChildFonts(m_selectedElementID, updateChildFonts);
				}

				Log("Updated element " + to_string(m_selectedElementID) + " font size from " + to_string(oldFontSize) + " to " + to_string(newFontSize));
				wasUpdated = true;
			}
		}
	}

	// Update scrollbar/slider properties if changed
	if (selectedElement && selectedElement->m_Type == GUI_SCROLLBAR)
	{
		auto scrollbar = static_cast<GuiScrollBar*>(selectedElement.get());

		// Update PROPERTY_WIDTH
		int widthInputID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
		if (widthInputID != -1)
		{
			auto widthInput = m_gui->GetElement(widthInputID);
			if (widthInput && widthInput->m_Type == GUI_SCROLLBAR)
			{
				auto widthScrollbar = static_cast<GuiScrollBar*>(widthInput.get());
				int newWidth = widthScrollbar->m_Value;
				if (newWidth > 0 && newWidth != static_cast<int>(scrollbar->m_Width))
				{
					scrollbar->m_Width = static_cast<float>(newWidth);
					Log("Updated scrollbar " + to_string(m_selectedElementID) + " width to " + to_string(newWidth));
					wasUpdated = true;
				}
			}
		}

		// Update PROPERTY_HEIGHT
		int heightInputID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
		if (heightInputID != -1)
		{
			auto heightInput = m_gui->GetElement(heightInputID);
			if (heightInput && heightInput->m_Type == GUI_SCROLLBAR)
			{
				auto heightScrollbar = static_cast<GuiScrollBar*>(heightInput.get());
				int newHeight = heightScrollbar->m_Value;
				if (newHeight > 0 && newHeight != static_cast<int>(scrollbar->m_Height))
				{
					scrollbar->m_Height = static_cast<float>(newHeight);
					Log("Updated scrollbar " + to_string(m_selectedElementID) + " height to " + to_string(newHeight));
					wasUpdated = true;
				}
			}
		}

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
		auto textinput = static_cast<GuiTextInput*>(selectedElement.get());

		// Update PROPERTY_WIDTH
		int widthInputID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
		if (widthInputID != -1)
		{
			auto widthInput = m_gui->GetElement(widthInputID);
			if (widthInput && widthInput->m_Type == GUI_SCROLLBAR)
			{
				auto widthScrollbar = static_cast<GuiScrollBar*>(widthInput.get());
				int newWidth = widthScrollbar->m_Value;
				if (newWidth > 0 && newWidth != static_cast<int>(textinput->m_Width))
				{
					textinput->m_Width = static_cast<float>(newWidth);
					Log("Updated textinput " + to_string(m_selectedElementID) + " width to " + to_string(newWidth));
					wasUpdated = true;
				}
			}
		}

		// Update PROPERTY_HEIGHT
		int heightInputID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
		if (heightInputID != -1)
		{
			auto heightInput = m_gui->GetElement(heightInputID);
			if (heightInput && heightInput->m_Type == GUI_SCROLLBAR)
			{
				auto heightScrollbar = static_cast<GuiScrollBar*>(heightInput.get());
				int newHeight = heightScrollbar->m_Value;
				if (newHeight > 0 && newHeight != static_cast<int>(textinput->m_Height))
				{
					textinput->m_Height = static_cast<float>(newHeight);
					Log("Updated textinput " + to_string(m_selectedElementID) + " height to " + to_string(newHeight));
					wasUpdated = true;
				}
			}
		}

		// Update PROPERTY_FONT
		int fontInputID = m_propertySerializer->GetElementID("PROPERTY_FONT");
		if (fontInputID != -1)
		{
			auto fontInput = m_gui->GetElement(fontInputID);
			if (fontInput && fontInput->m_Type == GUI_TEXTINPUT)
			{
				auto fontTextInput = static_cast<GuiTextInput*>(fontInput.get());
				std::string newFontName = fontTextInput->m_String;
				std::string oldFontName = m_contentSerializer->GetElementFont(m_selectedElementID);

				if (newFontName != oldFontName && !newFontName.empty())
				{
					// Try to load the new font
					std::string fontPath = m_fontPath + "/" + newFontName;
					int oldFontSize = m_contentSerializer->GetElementFontSize(m_selectedElementID);
					if (oldFontSize == 0) oldFontSize = 12; // Default size if not set

					auto newFontPtr = std::make_shared<Font>(LoadFontEx(fontPath.c_str(), oldFontSize, 0, 0));
					if (newFontPtr->texture.id != 0)
					{
						textinput->m_Font = newFontPtr.get();
						m_preservedFonts.push_back(newFontPtr); // Keep font alive
						m_contentSerializer->SetElementFont(m_selectedElementID, newFontName);
						m_contentSerializer->SetElementFontSize(m_selectedElementID, oldFontSize);
						Log("Updated textinput " + to_string(m_selectedElementID) + " font to " + newFontName);
						wasUpdated = true;
					}
					else
					{
						Log("Failed to load font: " + fontPath);
					}
				}
			}
		}

		// Update PROPERTY_FONT_SIZE
		int fontSizeInputID = m_propertySerializer->GetElementID("PROPERTY_FONT_SIZE");
		if (fontSizeInputID != -1)
		{
			auto fontSizeInput = m_gui->GetElement(fontSizeInputID);
			if (fontSizeInput && fontSizeInput->m_Type == GUI_SCROLLBAR)
			{
				auto fontSizeScrollbar = static_cast<GuiScrollBar*>(fontSizeInput.get());
				int newFontSize = fontSizeScrollbar->m_Value;
				int oldFontSize = m_contentSerializer->GetElementFontSize(m_selectedElementID);

				if (newFontSize > 0 && newFontSize != oldFontSize)
				{
					std::string fontName = m_contentSerializer->GetElementFont(m_selectedElementID);
					if (!fontName.empty())
					{
						// Reload font with new size
						std::string fontPath = m_fontPath + "/" + fontName;
						auto newFontPtr = std::make_shared<Font>(LoadFontEx(fontPath.c_str(), newFontSize, 0, 0));
						if (newFontPtr->texture.id != 0)
						{
							textinput->m_Font = newFontPtr.get();
							m_preservedFonts.push_back(newFontPtr); // Keep font alive
							m_contentSerializer->SetElementFontSize(m_selectedElementID, newFontSize);
							Log("Updated textinput " + to_string(m_selectedElementID) + " font size to " + to_string(newFontSize));
							wasUpdated = true;
						}
						else
						{
							Log("Failed to reload font with new size: " + fontPath);
						}
					}
				}
			}
		}
	}

	// Update checkbox properties if changed
	if (selectedElement && selectedElement->m_Type == GUI_CHECKBOX)
	{
		auto checkbox = static_cast<GuiCheckBox*>(selectedElement.get());

		// Update PROPERTY_WIDTH
		int widthInputID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
		if (widthInputID != -1)
		{
			auto widthInput = m_gui->GetElement(widthInputID);
			if (widthInput && widthInput->m_Type == GUI_SCROLLBAR)
			{
				auto widthScrollbar = static_cast<GuiScrollBar*>(widthInput.get());
				int newWidth = widthScrollbar->m_Value;
				if (newWidth > 0 && newWidth != static_cast<int>(checkbox->m_Width))
				{
					checkbox->m_Width = static_cast<float>(newWidth);
					Log("Updated checkbox " + to_string(m_selectedElementID) + " width to " + to_string(newWidth));
					wasUpdated = true;
				}
			}
		}

		// Update PROPERTY_HEIGHT
		int heightInputID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
		if (heightInputID != -1)
		{
			auto heightInput = m_gui->GetElement(heightInputID);
			if (heightInput && heightInput->m_Type == GUI_SCROLLBAR)
			{
				auto heightScrollbar = static_cast<GuiScrollBar*>(heightInput.get());
				int newHeight = heightScrollbar->m_Value;
				if (newHeight > 0 && newHeight != static_cast<int>(checkbox->m_Height))
				{
					checkbox->m_Height = static_cast<float>(newHeight);
					Log("Updated checkbox " + to_string(m_selectedElementID) + " height to " + to_string(newHeight));
					wasUpdated = true;
				}
			}
		}

		// Update PROPERTY_GROUP
		int groupInputID = m_propertySerializer->GetElementID("PROPERTY_GROUP");
		if (groupInputID != -1)
		{
			auto groupInput = m_gui->GetElement(groupInputID);
			if (groupInput && groupInput->m_Type == GUI_SCROLLBAR)
			{
				auto groupScrollbar = static_cast<GuiScrollBar*>(groupInput.get());
				int newGroup = groupScrollbar->m_Value;
				if (newGroup != checkbox->m_Group)
				{
					checkbox->m_Group = newGroup;
					Log("Updated checkbox " + to_string(m_selectedElementID) + " group to " + to_string(newGroup));
					wasUpdated = true;
				}
			}
		}
	}

	// Update radiobutton properties if changed
	if (selectedElement && selectedElement->m_Type == GUI_RADIOBUTTON)
	{
		auto radiobutton = static_cast<GuiRadioButton*>(selectedElement.get());

		// Update PROPERTY_WIDTH
		int widthInputID = m_propertySerializer->GetElementID("PROPERTY_WIDTH");
		if (widthInputID != -1)
		{
			auto widthInput = m_gui->GetElement(widthInputID);
			if (widthInput && widthInput->m_Type == GUI_SCROLLBAR)
			{
				auto widthScrollbar = static_cast<GuiScrollBar*>(widthInput.get());
				int newWidth = widthScrollbar->m_Value;
				if (newWidth > 0 && newWidth != static_cast<int>(radiobutton->m_Width))
				{
					radiobutton->m_Width = static_cast<float>(newWidth);
					Log("Updated radiobutton " + to_string(m_selectedElementID) + " width to " + to_string(newWidth));
					wasUpdated = true;
				}
			}
		}

		// Update PROPERTY_HEIGHT
		int heightInputID = m_propertySerializer->GetElementID("PROPERTY_HEIGHT");
		if (heightInputID != -1)
		{
			auto heightInput = m_gui->GetElement(heightInputID);
			if (heightInput && heightInput->m_Type == GUI_SCROLLBAR)
			{
				auto heightScrollbar = static_cast<GuiScrollBar*>(heightInput.get());
				int newHeight = heightScrollbar->m_Value;
				if (newHeight > 0 && newHeight != static_cast<int>(radiobutton->m_Height))
				{
					radiobutton->m_Height = static_cast<float>(newHeight);
					Log("Updated radiobutton " + to_string(m_selectedElementID) + " height to " + to_string(newHeight));
					wasUpdated = true;
				}
			}
		}

		// Update PROPERTY_GROUP
		int groupInputID = m_propertySerializer->GetElementID("PROPERTY_GROUP");
		if (groupInputID != -1)
		{
			auto groupInput = m_gui->GetElement(groupInputID);
			if (groupInput && groupInput->m_Type == GUI_SCROLLBAR)
			{
				auto groupScrollbar = static_cast<GuiScrollBar*>(groupInput.get());
				int newGroup = groupScrollbar->m_Value;
				if (newGroup != radiobutton->m_Group)
				{
					radiobutton->m_Group = newGroup;
					Log("Updated radiobutton " + to_string(m_selectedElementID) + " group to " + to_string(newGroup));
					wasUpdated = true;
				}
			}
		}
	}

	// Update sprite filename if changed
	if (selectedElement && selectedElement->m_Type == GUI_SPRITE)
	{
		int spriteInputID = m_propertySerializer->GetElementID("PROPERTY_SPRITE");
		if (spriteInputID != -1)
		{
			auto spriteInput = m_gui->GetElement(spriteInputID);
			if (spriteInput && spriteInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(spriteInput.get());
				std::string newFilename = textInput->m_String;
				std::string oldFilename = m_contentSerializer->GetSpriteName(m_selectedElementID);

				if (newFilename != oldFilename && !newFilename.empty())
				{
					// Try to load the new sprite texture
					std::string spritePath = m_spritePath + newFilename;
					Texture* texture = g_ResourceManager->GetTexture(spritePath);
					std::string actualFilename = newFilename; // Track what we actually loaded

					// If loading failed, fall back to default image.png
					if (!texture || texture->id == 0)
					{
						Log("Failed to load sprite texture: " + spritePath + ", falling back to image.png");
						std::string defaultPath = m_spritePath + "image.png";
						texture = g_ResourceManager->GetTexture(defaultPath);
						actualFilename = "image.png"; // Update to reflect what we actually loaded

						// If even the default fails, log error but continue
						if (!texture || texture->id == 0)
						{
							Log("ERROR: Failed to load default sprite: " + defaultPath);
							return;
						}
					}

					// Create new sprite with the loaded texture
					auto sprite = std::make_shared<Sprite>();
					sprite->m_texture = texture;
					sprite->m_sourceRect = Rectangle{0, 0, float(texture->width), float(texture->height)};

					// Update the GuiSprite element
					auto guiSprite = std::static_pointer_cast<GuiSprite>(selectedElement);
					guiSprite->SetSprite(sprite);

					// Update the GuiSprite's width and height to match the new texture dimensions
					guiSprite->m_Width = texture->width * guiSprite->m_ScaleX;
					guiSprite->m_Height = texture->height * guiSprite->m_ScaleY;

					// Update sprite metadata in serializer with the actual loaded filename
					m_contentSerializer->SetSpriteName(m_selectedElementID, actualFilename);

					Log("Updated sprite " + to_string(m_selectedElementID) + " from '" + oldFilename + "' to '" + actualFilename + "'");
					wasUpdated = true;
				}
			}
		}
	}

	// Always reflow after any property change to ensure layout is updated
	if (wasUpdated)
	{
		auto selectedElement = m_gui->GetElement(m_selectedElementID);
		if (selectedElement)
		{
			// If the selected element is a panel, reflow it directly
			if (selectedElement->m_Type == GUI_PANEL)
			{
				m_contentSerializer->ReflowPanel(m_selectedElementID, m_gui.get());
				Log("Reflowed panel " + to_string(m_selectedElementID) + " after property change");
			}
			// Otherwise, reflow its parent panel
			else
			{
				int parentID = m_contentSerializer->GetParentID(m_selectedElementID);
				if (parentID != -1)
				{
					m_contentSerializer->ReflowPanel(parentID, m_gui.get());
					Log("Reflowed parent panel " + to_string(parentID) + " after property change");
				}
			}
		}
	}

	// Mark as dirty so user knows to save
	if (wasUpdated)
	{
		m_contentSerializer->SetDirty(true);
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
	m_contentSerializer = make_unique<GuiSerializer>();
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
	m_contentSerializer = make_unique<GuiSerializer>();
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
