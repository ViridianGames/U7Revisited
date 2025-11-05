#include "GhostState.h"
#include "../Geist/Globals.h"
#include "../Geist/Engine.h"
#include "../Geist/Logging.h"
#include "../Geist/ResourceManager.h"
#include "../Geist/Config.h"
#include "FileDialog.h"
#include "raylib.h"
#include <fstream>

using namespace std;

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

	if (activeID >= 3000 && activeID != lastActiveID)
	{
		// Don't call UpdateElementFromPropertyPanel on initial activation
		// Only call it when switching between different property inputs
		lastActiveID = activeID;

		// Track initial value if we just activated the columns input
		int columnsInputID = m_propertySerializer->GetElementID("PROPERTY_COLUMNS");
		if (activeID == columnsInputID)
		{
			auto columnsInput = m_gui->GetElement(columnsInputID);
			if (columnsInput && columnsInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(columnsInput.get());
				lastColumnsValue = textInput->m_String;
			}
		}

		// Track initial value if we just activated the sprite input
		int spriteInputID = m_propertySerializer->GetElementID("PROPERTY_SPRITE");
		if (activeID == spriteInputID)
		{
			auto spriteInput = m_gui->GetElement(spriteInputID);
			if (spriteInput && spriteInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(spriteInput.get());
				lastSpriteValue = textInput->m_String;
			}
		}

		// Track initial value if we just activated the text input
		int textInputID = m_propertySerializer->GetElementID("PROPERTY_TEXT");
		if (activeID == textInputID)
		{
			auto textInput = m_gui->GetElement(textInputID);
			if (textInput && textInput->m_Type == GUI_TEXTINPUT)
			{
				auto propertyInput = static_cast<GuiTextInput*>(textInput.get());
				lastTextValue = propertyInput->m_String;
			}
		}

		// Track initial value if we just activated the horz padding input
		int horzPaddingInputID = m_propertySerializer->GetElementID("PROPERTY_HORZ_PADDING");
		if (activeID == horzPaddingInputID)
		{
			auto horzPaddingInput = m_gui->GetElement(horzPaddingInputID);
			if (horzPaddingInput && horzPaddingInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(horzPaddingInput.get());
				lastHorzPaddingValue = textInput->m_String;
			}
		}

		// Track initial value if we just activated the vert padding input
		int vertPaddingInputID = m_propertySerializer->GetElementID("PROPERTY_VERT_PADDING");
		if (activeID == vertPaddingInputID)
		{
			auto vertPaddingInput = m_gui->GetElement(vertPaddingInputID);
			if (vertPaddingInput && vertPaddingInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(vertPaddingInput.get());
				lastVertPaddingValue = textInput->m_String;
			}
		}
	}
	else if (activeID < 3000)
	{
		lastActiveID = -1;
		lastColumnsValue = "";
		lastSpriteValue = "";
		lastTextValue = "";
		lastHorzPaddingValue = "";
		lastVertPaddingValue = "";
	}

	// Check if columns value changed while typing (for live reflow)
	int columnsInputID = m_propertySerializer->GetElementID("PROPERTY_COLUMNS");
	if (activeID == columnsInputID && columnsInputID != -1)
	{
		auto columnsInput = m_gui->GetElement(columnsInputID);
		if (columnsInput && columnsInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(columnsInput.get());
			if (textInput->m_String != lastColumnsValue)
			{
				lastColumnsValue = textInput->m_String;
				UpdateElementFromPropertyPanel();
			}
		}
	}

	// Check if sprite value changed while typing (for live image reload)
	int spriteInputID = m_propertySerializer->GetElementID("PROPERTY_SPRITE");
	if (activeID == spriteInputID && spriteInputID != -1)
	{
		auto spriteInput = m_gui->GetElement(spriteInputID);
		if (spriteInput && spriteInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(spriteInput.get());
			if (textInput->m_String != lastSpriteValue)
			{
				lastSpriteValue = textInput->m_String;
				UpdateElementFromPropertyPanel();
			}
		}
	}

	// Check if text value changed while typing (for live text update)
	int textInputID = m_propertySerializer->GetElementID("PROPERTY_TEXT");
	if (activeID == textInputID && textInputID != -1)
	{
		auto textInput = m_gui->GetElement(textInputID);
		if (textInput && textInput->m_Type == GUI_TEXTINPUT)
		{
			auto propertyInput = static_cast<GuiTextInput*>(textInput.get());
			if (propertyInput->m_String != lastTextValue)
			{
				lastTextValue = propertyInput->m_String;
				UpdateElementFromPropertyPanel();
			}
		}
	}

	// Check if horz padding value changed while typing (for live reflow)
	int horzPaddingInputID = m_propertySerializer->GetElementID("PROPERTY_HORZ_PADDING");
	if (activeID == horzPaddingInputID && horzPaddingInputID != -1)
	{
		auto horzPaddingInput = m_gui->GetElement(horzPaddingInputID);
		if (horzPaddingInput && horzPaddingInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(horzPaddingInput.get());
			if (textInput->m_String != lastHorzPaddingValue)
			{
				lastHorzPaddingValue = textInput->m_String;
				UpdateElementFromPropertyPanel();
			}
		}
	}

	// Check if vert padding value changed while typing (for live reflow)
	int vertPaddingInputID = m_propertySerializer->GetElementID("PROPERTY_VERT_PADDING");
	if (activeID == vertPaddingInputID && vertPaddingInputID != -1)
	{
		auto vertPaddingInput = m_gui->GetElement(vertPaddingInputID);
		if (vertPaddingInput && vertPaddingInput->m_Type == GUI_TEXTINPUT)
		{
			auto textInput = static_cast<GuiTextInput*>(vertPaddingInput.get());
			if (textInput->m_String != lastVertPaddingValue)
			{
				lastVertPaddingValue = textInput->m_String;
				UpdateElementFromPropertyPanel();
			}
		}
	}

	// Check if a content element was clicked (IDs 2000-2999, not property panel 3000+)
	if (activeID >= 2000 && activeID < 3000)
	{
		m_selectedElementID = activeID;
		Log("Selected element ID: " + to_string(activeID));
		UpdatePropertyPanel();  // Update property panel when selection changes
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
		for (int id : clickedElements)
		{
			if (id == 2000) continue;  // Skip invisible root

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

		if (bestID != -1)
		{
			m_selectedElementID = bestID;
			Log("Selected element ID: " + to_string(bestID));
			UpdatePropertyPanel();  // Update property panel when selection changes
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
	else if (activeID == m_serializer->GetElementID("FILE"))
	{
		Log("File button clicked!");
		InsertFileInclude();
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
}

void GhostState::OnEnter()
{
	// Called when state becomes active
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
		m_contentSerializer->SetPanelPadding(containerID, 5);
		m_contentSerializer->RegisterChildOfParent(2000, containerID);

		// Make the container the selected element so new elements go into it
		m_selectedElementID = containerID;

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
	// Mark as floating if requested
	if (isFloating)
	{
		m_contentSerializer->SetFloating(newID, true);
	}

	// Register this element with its parent
	m_contentSerializer->RegisterChildOfParent(parentID, newID);

	// Make this element the new selection
	m_selectedElementID = newID;

	// Mark as dirty
	m_contentSerializer->SetDirty(true);

	// Update property panel for the new element
	UpdatePropertyPanel();

	Log(elementTypeName + " inserted with ID: " + to_string(newID) + " as child of parent ID: " + to_string(parentID));
}

void GhostState::InsertPanel()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("panel");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Add a new panel at calculated position
	m_gui->AddPanel(ctx.newID, ctx.absoluteX, ctx.absoluteY, 200, 100, DARKGRAY, true, 0, true);

	// Set default layout to "horz" and padding to 5
	m_contentSerializer->SetPanelLayout(ctx.newID, "horz");
	m_contentSerializer->SetPanelPadding(ctx.newID, 5);

	// Use helper to finalize insertion (panels are not floating)
	FinalizeInsert(ctx.newID, ctx.parentID, "Panel", false);
}

void GhostState::InsertLabel()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("label");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Add a text area (label) at calculated position
	// Note: width parameter is multiplied by font baseSize in GuiTextArea
	// Measure the text and calculate the width parameter needed
	std::string labelText = "Label Text";
	Vector2 textDims = MeasureTextEx(*m_gui->m_Font.get(), labelText.c_str(), m_gui->m_Font->baseSize, 1);
	int widthParam = int(textDims.x / m_gui->m_Font->baseSize) + 1;  // Add 1 for a bit of padding
	m_gui->AddTextArea(ctx.newID, m_gui->m_Font.get(), labelText, ctx.absoluteX, ctx.absoluteY, widthParam, 30, WHITE, 0, 0, true, false);

	// Mark color as explicit so it gets saved (prevents inheriting dark colors from parent)
	m_contentSerializer->MarkPropertyAsExplicit(ctx.newID, "color");

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "Label");
}

void GhostState::InsertButton()
{
	// Use helper to prepare insertion
	InsertContext ctx = PrepareInsert("button");
	if (ctx.newID == -1)
		return;  // Error already logged

	// Add a text button at calculated position
	m_gui->AddTextButton(ctx.newID, ctx.absoluteX, ctx.absoluteY, "Button", m_gui->m_Font.get(), WHITE, DARKGRAY, WHITE, 0, true);

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

	// Add a text input field at calculated position
	m_gui->AddTextInput(ctx.newID, ctx.absoluteX, ctx.absoluteY, 150, 20, m_gui->m_Font.get(), "", WHITE, WHITE, Color{0, 0, 0, 255}, 0, true);

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

	// Add a list at calculated position with some default items
	vector<string> defaultItems = {"Item 1", "Item 2", "Item 3"};
	m_gui->AddGuiList(ctx.newID, ctx.absoluteX, ctx.absoluteY, 150, 100, m_gui->m_Font.get(),
		defaultItems, WHITE, Color{0, 0, 0, 255}, WHITE, 0, true);

	// Use helper to finalize insertion
	FinalizeInsert(ctx.newID, ctx.parentID, "List");
}

void GhostState::InsertFileInclude()
{
	Log("Inserting file include - not yet implemented");
	// TODO: Show a file picker and insert an include element
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

		// Populate columns field
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
		}

		// Populate horizontal padding field
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
		}

		// Populate vertical padding field
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
}

void GhostState::UpdateElementFromPropertyPanel()
{
	Log("UpdateElementFromPropertyPanel called, activeID=" + to_string(m_gui->GetActiveElementID()));

	if (m_selectedElementID == -1)
		return;

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

				// Reflow the parent panel to adjust layout
				int parentID = m_contentSerializer->GetParentID(m_selectedElementID);
				if (parentID != -1)
				{
					m_contentSerializer->ReflowPanel(parentID, m_gui.get());
					Log("Reflowed parent panel ID: " + to_string(parentID));
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
				m_contentSerializer->ReflowPanel(m_selectedElementID, m_gui.get());
				Log("Updated panel " + to_string(m_selectedElementID) + " layout from " + oldLayout + " to " + newLayout);
				wasUpdated = true;
			}
		}

		// Update columns if changed
		int columnsInputID = m_propertySerializer->GetElementID("PROPERTY_COLUMNS");
		if (columnsInputID != -1)
		{
			auto columnsInput = m_gui->GetElement(columnsInputID);
			if (columnsInput && columnsInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(columnsInput.get());
				try
				{
					int newColumns = std::stoi(textInput->m_String);
					int oldColumns = m_contentSerializer->GetPanelColumns(m_selectedElementID);
					if (newColumns != oldColumns && newColumns > 0)
					{
						m_contentSerializer->SetPanelColumns(m_selectedElementID, newColumns);
						m_contentSerializer->ReflowPanel(m_selectedElementID, m_gui.get());
						Log("Updated panel " + to_string(m_selectedElementID) + " columns from " + to_string(oldColumns) + " to " + to_string(newColumns));
						wasUpdated = true;
					}
				}
				catch (...)
				{
					// Invalid number, ignore
				}
			}
		}

		// Update horizontal padding if changed
		int horzPaddingInputID = m_propertySerializer->GetElementID("PROPERTY_HORZ_PADDING");
		if (horzPaddingInputID != -1)
		{
			auto horzPaddingInput = m_gui->GetElement(horzPaddingInputID);
			if (horzPaddingInput && horzPaddingInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(horzPaddingInput.get());
				try
				{
					int newHorzPadding = std::stoi(textInput->m_String);
					int oldHorzPadding = m_contentSerializer->GetPanelHorzPadding(m_selectedElementID);
					if (newHorzPadding != oldHorzPadding && newHorzPadding >= 0)
					{
						m_contentSerializer->SetPanelHorzPadding(m_selectedElementID, newHorzPadding);
						m_contentSerializer->ReflowPanel(m_selectedElementID, m_gui.get());
						Log("Updated panel " + to_string(m_selectedElementID) + " horz padding from " + to_string(oldHorzPadding) + " to " + to_string(newHorzPadding));
						wasUpdated = true;
					}
				}
				catch (...)
				{
					// Invalid number, ignore
				}
			}
		}

		// Update vertical padding if changed
		int vertPaddingInputID = m_propertySerializer->GetElementID("PROPERTY_VERT_PADDING");
		if (vertPaddingInputID != -1)
		{
			auto vertPaddingInput = m_gui->GetElement(vertPaddingInputID);
			if (vertPaddingInput && vertPaddingInput->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(vertPaddingInput.get());
				try
				{
					int newVertPadding = std::stoi(textInput->m_String);
					int oldVertPadding = m_contentSerializer->GetPanelVertPadding(m_selectedElementID);
					if (newVertPadding != oldVertPadding && newVertPadding >= 0)
					{
						m_contentSerializer->SetPanelVertPadding(m_selectedElementID, newVertPadding);
						m_contentSerializer->ReflowPanel(m_selectedElementID, m_gui.get());
						Log("Updated panel " + to_string(m_selectedElementID) + " vert padding from " + to_string(oldVertPadding) + " to " + to_string(newVertPadding));
						wasUpdated = true;
					}
				}
				catch (...)
				{
					// Invalid number, ignore
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

					// If loading failed, fall back to default image.png
					if (!texture || texture->id == 0)
					{
						Log("Failed to load sprite texture: " + spritePath + ", falling back to image.png");
						std::string defaultPath = m_spritePath + "image.png";
						texture = g_ResourceManager->GetTexture(defaultPath);

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

					// Update sprite metadata in serializer
					m_contentSerializer->SetSpriteName(m_selectedElementID, newFilename);

					// Get parent ID and reflow the parent panel
					int parentID = m_contentSerializer->GetParentID(m_selectedElementID);
					if (parentID != -1)
					{
						m_contentSerializer->ReflowPanel(parentID, m_gui.get());
						Log("Reflowed parent panel " + to_string(parentID) + " after sprite change");
					}

					Log("Updated sprite " + to_string(m_selectedElementID) + " from '" + oldFilename + "' to '" + newFilename + "'");
					wasUpdated = true;
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
