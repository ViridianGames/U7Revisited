#include "GuiSerializer.h"
#include "../Geist/Logging.h"
#include "../../ThirdParty/nlohmann/json.hpp"
#include <fstream>
#include <functional>

using namespace std;

// Initialize static members
std::string GuiSerializer::s_baseFontPath = "Fonts/";
std::string GuiSerializer::s_baseSpritePath = "Images/";

GuiSerializer::GuiSerializer()
{
}

GuiSerializer::~GuiSerializer()
{
}

void GuiSerializer::SetBaseFontPath(const std::string& path)
{
	s_baseFontPath = path;
}

void GuiSerializer::SetBaseSpritePath(const std::string& path)
{
	s_baseSpritePath = path;
}

ghost_json GuiSerializer::ReadJsonFromFile(const std::string& filename)
{
	try
	{
		ifstream file(filename);
		if (!file.is_open())
		{
			Log("GuiSerializer::ReadJsonFromFile - Could not open file: " + filename);
			return ghost_json();
		}

		ghost_json j;
		file >> j;
		file.close();

		Log("GuiSerializer::ReadJsonFromFile - Successfully read: " + filename);
		return j;
	}
	catch (const exception& e)
	{
		Log("GuiSerializer::ReadJsonFromFile - Exception: " + string(e.what()));
		return ghost_json();
	}
}

bool GuiSerializer::ParseJson(const ghost_json& j, Gui* gui)
{
	if (!gui)
	{
		Log("GuiSerializer::ParseJson - gui is null");
		return false;
	}

	if (j.empty())
	{
		Log("GuiSerializer::ParseJson - JSON is empty");
		return false;
	}

	try
	{
		// Parse the GUI object
		if (!j.contains("gui"))
		{
			Log("GuiSerializer::ParseJson - JSON does not contain 'gui' object");
			return false;
		}

		auto guiObj = j["gui"];

		// Set GUI position
		if (guiObj.contains("position"))
		{
			auto pos = guiObj["position"];
			gui->m_Pos = Vector2{ float(pos[0]), float(pos[1]) };
		}

		// Parse elements
		if (guiObj.contains("elements"))
		{
			ParseElements(guiObj["elements"], gui);
		}

		Log("GuiSerializer::ParseJson - Successfully parsed GUI");
		return true;
	}
	catch (const exception& e)
	{
		Log("GuiSerializer::ParseJson - Exception: " + string(e.what()));
		return false;
	}
}

int GuiSerializer::GetElementID(const std::string& name) const
{
	auto it = m_elementNameToID.find(name);
	if (it != m_elementNameToID.end())
	{
		return it->second;
	}
	return -1;  // Not found
}

std::pair<int, int> GuiSerializer::CalculateNextFloatingPosition(int parentID, Gui* gui) const
{
	// Get parent element to determine layout and base position
	auto parent = gui->GetElement(parentID);
	if (!parent)
	{
		Log("CalculateNextFloatingPosition: Parent " + to_string(parentID) + " not found");
		return {0, 0};  // Default if parent not found
	}

	// Get parent's layout type, padding, and columns
	string layout = GetPanelLayout(parentID);
	int horzPadding = GetPanelHorzPadding(parentID);
	int vertPadding = GetPanelVertPadding(parentID);
	int columns = GetPanelColumns(parentID);

	// Get parent's absolute position as the starting point
	int parentX = parent->m_Pos.x;
	int parentY = parent->m_Pos.y;

	// Track the current layout position, starting with padding offset
	int layoutX = parentX + horzPadding;
	int layoutY = parentY + vertPadding;
	int columnIndex = 0;  // Track current column for table layout
	int maxRowHeight = 0; // Track max height in current row for table layout

	Log("CalculateNextFloatingPosition: Parent " + to_string(parentID) + " at (" + to_string(parentX) + ", " + to_string(parentY) + "), layout=" + layout + ", horzPadding=" + to_string(horzPadding) + ", vertPadding=" + to_string(vertPadding));

	// Iterate through all children of this parent
	auto childIt = m_childrenMap.find(parentID);
	if (childIt != m_childrenMap.end())
	{
		Log("CalculateNextFloatingPosition: Found " + to_string(childIt->second.size()) + " children");
		for (int childID : childIt->second)
		{
			// Only count floating children for layout calculation
			if (!IsFloating(childID))
			{
				Log("CalculateNextFloatingPosition: Child " + to_string(childID) + " is NOT floating, skipping");
				continue;
			}

			auto child = gui->GetElement(childID);
			if (!child)
			{
				Log("CalculateNextFloatingPosition: Child " + to_string(childID) + " element not found");
				continue;
			}

			Log("CalculateNextFloatingPosition: Child " + to_string(childID) + " is floating, size=(" + to_string(child->m_Width) + ", " + to_string(child->m_Height) + ")");

			// Advance layout position based on this child's size plus padding
			if (layout == "horz")
			{
				layoutX += child->m_Width + horzPadding;  // Add horizontal padding between elements
			}
			else if (layout == "vert")
			{
				layoutY += child->m_Height + vertPadding;  // Add vertical padding between elements
			}
			else if (layout == "table")
			{
				// Track max height in this row
				if (child->m_Height > maxRowHeight)
					maxRowHeight = child->m_Height;

				columnIndex++;

				// Move to next column or wrap to next row
				if (columnIndex >= columns)
				{
					// Wrap to next row
					layoutX = parentX + horzPadding;
					layoutY += maxRowHeight + vertPadding;
					columnIndex = 0;
					maxRowHeight = 0;
				}
				else
				{
					// Move to next column
					layoutX += child->m_Width + horzPadding;
				}
			}
		}
	}
	else
	{
		Log("CalculateNextFloatingPosition: No children found for parent " + to_string(parentID));
	}

	int relX = layoutX - parentX;
	int relY = layoutY - parentY;
	Log("CalculateNextFloatingPosition: Returning relative position (" + to_string(relX) + ", " + to_string(relY) + ")");

	// Return relative position (subtract parent position)
	return {relX, relY};
}

void GuiSerializer::ParseElements(const ghost_json& elementsArray, Gui* gui, const ghost_json& inheritedProps, int parentX, int parentY, int parentElementID)
{
	// Track layout position for floating elements
	// Get parent's layout type and padding (defaults to "horz" and 5px if no parent or not found)
	string parentLayout = "horz";
	int horzPadding = 5;
	int vertPadding = 5;
	int columns = 1;
	if (parentElementID != -1)
	{
		parentLayout = GetPanelLayout(parentElementID);
		horzPadding = GetPanelHorzPadding(parentElementID);
		vertPadding = GetPanelVertPadding(parentElementID);
		columns = GetPanelColumns(parentElementID);
	}

	// Start layout position with padding offset from parent's edge
	int layoutX = horzPadding;  // Current X offset for horizontal layout
	int layoutY = vertPadding;  // Current Y offset for vertical layout
	int columnIndex = 0;    // Current column for table layout
	int maxRowHeight = 0;   // Max height in current row for table layout

	for (auto& element : elementsArray)
	{
		string type = element["type"];

		// ID is now optional - auto-generate if not provided
		int id;
		if (element.contains("id"))
		{
			id = element["id"];
		}
		else
		{
			id = m_nextAutoID++;
		}

		string name = element.value("name", "");  // Optional name for lookup
		auto position = element["position"];
		int posx = position[0];
		int posy = position[1];

		// Check if this is a floating element (position -1, -1)
		bool isFloating = (posx == -1 && posy == -1);

		// For floating elements, calculate position based on parent's layout
		if (isFloating)
		{
			if (parentLayout == "horz")
			{
				posx = layoutX;
				posy = 0;
			}
			else if (parentLayout == "vert")
			{
				posx = 0;
				posy = layoutY;
			}
			else if (parentLayout == "table")
			{
				posx = layoutX;
				posy = layoutY;
			}
			Log("Floating element '" + type + "' positioned at relative (" + to_string(posx) + ", " + to_string(posy) + "), layout=" + parentLayout + ", layoutX=" + to_string(layoutX) + ", layoutY=" + to_string(layoutY));
		}

		int group = element.value("group", 0);

		// Active state is always true when loading - runtime context will disable if needed
		bool active = true;

		// Store name->ID mapping if name is provided
		if (!name.empty())
		{
			m_elementNameToID[name] = id;
		}

		// Track tree structure (skip includes - they're not real elements)
		if (type != "include")
		{
			// If this is a root element (parentElementID == -1), store as root
			if (parentElementID == -1 && m_rootElementID == -1)
			{
				m_rootElementID = id;
			}
			// Add to parent's children list
			if (parentElementID != -1)
			{
				m_childrenMap[parentElementID].push_back(id);
			}
		}

		if (type == "include")
		{
			// Include elements from another file at this position
			string filename = element["filename"];
			Log("GuiSerializer::ParseElements - Loading included file: " + filename);

			// Add parent offsets to the current position for included elements
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			Log("Include '" + filename + "' at absolute position (" + to_string(absoluteX) + ", " + to_string(absoluteY) + "), parentX=" + to_string(parentX) + ", parentY=" + to_string(parentY) + ", posx=" + to_string(posx) + ", posy=" + to_string(posy));

			// Read and parse the included file
			ghost_json includedJson = ReadJsonFromFile("Gui/" + filename);
			if (!includedJson.empty() && includedJson.contains("gui") && includedJson["gui"].contains("elements"))
			{
				// Parse included elements with current position and inherited properties
				// Pass through the parentElementID so included elements can use parent's layout
				ParseElements(includedJson["gui"]["elements"], gui, inheritedProps, absoluteX, absoluteY, parentElementID);
			}
		}
		else if (type == "panel")
		{
			auto size = element["size"];
			int width = size[0];
			int height = size[1];
			auto colorArr = element["color"];
			Color color = { (unsigned char)colorArr[0], (unsigned char)colorArr[1],
			                (unsigned char)colorArr[2], (unsigned char)colorArr[3] };

			// Handle "filled" field - can be bool or int in JSON
			bool filled = true;
			if (element.contains("filled"))
			{
				if (element["filled"].is_boolean())
				{
					filled = element["filled"].get<bool>();
				}
				else if (element["filled"].is_number())
				{
					filled = element["filled"].get<int>() != 0;
				}
			}

			// Add parent offsets to make position absolute
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			gui->AddPanel(id, absoluteX, absoluteY, width, height, color, filled, group, active);

			// Get the panel element so we can set font properties
			auto panelElement = gui->GetElement(id);
			GuiPanel* panel = static_cast<GuiPanel*>(panelElement.get());

			// Store layout property (defaults to "horz" if not specified)
			string layout = element.value("layout", "horz");
			m_panelLayouts[id] = layout;

			// Store horizontal and vertical padding (check for old single "padding" value for backwards compatibility)
			if (element.contains("padding"))
			{
				int padding = element.value("padding", 5);
				m_panelHorzPaddings[id] = padding;
				m_panelVertPaddings[id] = padding;
			}
			if (element.contains("horzPadding"))
			{
				m_panelHorzPaddings[id] = element.value("horzPadding", 5);
			}
			if (element.contains("vertPadding"))
			{
				m_panelVertPaddings[id] = element.value("vertPadding", 5);
			}

			// Store columns property for table layout (defaults to 1 if not specified)
			if (layout == "table")
			{
				int columns = element.value("columns", 1);
				m_panelColumns[id] = columns;
			}

			// Track font properties if explicitly set on the panel
			if (element.contains("font"))
			{
				m_explicitProperties[id].insert("font");
				string fontName = element["font"];
				m_elementFonts[id] = fontName;

				// Load and apply font to panel
				string fontPath = s_baseFontPath + fontName;
				int fontSize = element.value("fontSize", 20);  // Default if not specified
				auto fontPtr = make_shared<Font>(LoadFontEx(fontPath.c_str(), fontSize, 0, 0));
				m_loadedFonts.push_back(fontPtr);
				panel->m_Font = fontPtr.get();
			}
			if (element.contains("fontSize"))
			{
				m_explicitProperties[id].insert("fontSize");
				int fontSize = element["fontSize"];
				m_elementFontSizes[id] = fontSize;
				panel->m_FontSize = fontSize;
			}

			// Recursively parse child elements if they exist
			if (element.contains("elements"))
			{
				// Build inherited props from the panel we just created (use the maps, not the element JSON)
				ghost_json childInheritedProps = BuildInheritedProps(id);
				ParseElements(element["elements"], gui, childInheritedProps, absoluteX, absoluteY, id);
			}
		}
		else if (type == "textbutton")
		{
			string text = element["text"];

			// Inherit properties from parent, but allow override
			string fontName = element.value("font", inheritedProps.is_null() ? "" : inheritedProps.value("font", ""));
			int fontSize = element.value("fontSize", inheritedProps.is_null() ? 20 : inheritedProps.value("fontSize", 20));

			// Track which properties are explicitly set in this element
			if (element.contains("font"))
			{
				m_explicitProperties[id].insert("font");
				m_elementFonts[id] = fontName;  // Store just the font name
			}
			if (element.contains("fontSize"))
			{
				m_explicitProperties[id].insert("fontSize");
				m_elementFontSizes[id] = fontSize;
			}

			// Helper lambda to get color array with inheritance
			auto getColorArray = [&](const string& key, Color defaultColor) -> Color {
				if (element.contains(key))
				{
					m_explicitProperties[id].insert(key);  // Track explicit property
					auto arr = element[key];
					return Color{ (unsigned char)arr[0], (unsigned char)arr[1],
					             (unsigned char)arr[2], (unsigned char)arr[3] };
				}
				else if (!inheritedProps.is_null() && inheritedProps.contains(key))
				{
					auto arr = inheritedProps[key];
					return Color{ (unsigned char)arr[0], (unsigned char)arr[1],
					             (unsigned char)arr[2], (unsigned char)arr[3] };
				}
				return defaultColor;
			};

			Color textColor = getColorArray("textColor", WHITE);
			Color bgColor = getColorArray("backgroundColor", DARKGRAY);
			Color borderColor = getColorArray("borderColor", WHITE);

			// Add parent offsets to make position absolute
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			// Load font at the specified size (prepend base path)
			string fontPath = fontName.empty() ? "" : s_baseFontPath + fontName;
			Font font = LoadFontEx(fontPath.c_str(), fontSize, 0, 0);
			if (font.texture.id == 0)
			{
				Log("GuiSerializer::LoadFromFile - Failed to load font: " + fontPath);
				font = GetFontDefault();
			}

			// Create a shared pointer for the font and store it to keep it alive
			shared_ptr<Font> fontPtr = make_shared<Font>(font);
			m_loadedFonts.push_back(fontPtr);

			// Use the auto-sizing version of AddTextButton
			gui->AddTextButton(id, absoluteX, absoluteY, text, fontPtr.get(),
			                   textColor, bgColor, borderColor, group, active);
		}
		else if (type == "textarea")
		{
			string text = element["text"];

			// Get font name with inheritance
			string fontName = "";
			if (element.contains("font"))
			{
				m_explicitProperties[id].insert("font");
				fontName = element["font"].get<string>();
				m_elementFonts[id] = fontName;  // Store just the font name
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("font"))
			{
				fontName = inheritedProps["font"].get<string>();
			}

			// Get font size with inheritance
			int fontSize = 20;
			if (element.contains("fontSize"))
			{
				m_explicitProperties[id].insert("fontSize");
				fontSize = element["fontSize"].get<int>();
				m_elementFontSizes[id] = fontSize;
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("fontSize"))
			{
				fontSize = inheritedProps["fontSize"].get<int>();
			}

			// Get color with inheritance
			Color color = WHITE;
			if (element.contains("color"))
			{
				m_explicitProperties[id].insert("color");
				auto arr = element["color"];
				color = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				              (unsigned char)arr[2], (unsigned char)arr[3] };
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("color"))
			{
				auto arr = inheritedProps["color"];
				color = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				              (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Get optional width and height
			int width = element.value("width", 0);
			int height = element.value("height", 0);
			int justified = element.value("justified", 0);

			// Add parent offsets to make position absolute
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			// Load font at the specified size, or use default if no name specified (prepend base path)
			Font font;
			if (!fontName.empty())
			{
				string fontPath = s_baseFontPath + fontName;
				font = LoadFontEx(fontPath.c_str(), fontSize, 0, 0);
				if (font.texture.id == 0)
				{
					Log("GuiSerializer::ParseElements - Failed to load font: " + fontPath);
					font = GetFontDefault();
				}
			}
			else
			{
				// No font name specified, use default font
				font = GetFontDefault();
			}

			// Create a shared pointer for the font and store it to keep it alive
			shared_ptr<Font> fontPtr = make_shared<Font>(font);
			m_loadedFonts.push_back(fontPtr);

			// Note: GuiTextArea multiplies width by font.baseSize, so if the width from JSON
			// looks like it's already in pixels (>50), divide by baseSize to compensate
			int widthParam = width;
			if (width > 50 && fontPtr->baseSize > 0)
			{
				widthParam = width / fontPtr->baseSize;
			}

			// Add the text area
			gui->AddTextArea(id, fontPtr.get(), text, absoluteX, absoluteY, widthParam, height, color, justified, group, active, false);
		}
		else if (type == "textinput")
		{
			string text = element.value("text", "");
			auto size = element["size"];
			int width = size[0];
			int height = size[1];

			// Get font name with inheritance
			string fontName = "";
			if (element.contains("font"))
			{
				m_explicitProperties[id].insert("font");
				fontName = element["font"].get<string>();
				m_elementFonts[id] = fontName;  // Store just the font name
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("font"))
			{
				fontName = inheritedProps["font"].get<string>();
			}

			// Get font size with inheritance
			int fontSize = 20;
			if (element.contains("fontSize"))
			{
				m_explicitProperties[id].insert("fontSize");
				fontSize = element["fontSize"].get<int>();
				m_elementFontSizes[id] = fontSize;
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("fontSize"))
			{
				fontSize = inheritedProps["fontSize"].get<int>();
			}

			// Load font if specified
			Font* font = gui->m_Font.get();  // Default to GUI font
			if (!fontName.empty())
			{
				string fontPath = s_baseFontPath + fontName;
				auto loadedFont = LoadFontEx(fontPath.c_str(), fontSize, 0, 0);
				if (loadedFont.texture.id == 0)
				{
					Log("GuiSerializer::ParseElements - Failed to load font: " + fontPath);
				}
				else
				{
					// Store the font to keep it alive
					auto fontPtr = make_shared<Font>(loadedFont);
					m_loadedFonts.push_back(fontPtr);
					font = fontPtr.get();
				}
			}

			// Get colors
			Color textColor = WHITE;
			if (element.contains("textColor"))
			{
				m_explicitProperties[id].insert("textColor");
				auto arr = element["textColor"];
				textColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                  (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			Color boxColor = WHITE;
			if (element.contains("boxColor"))
			{
				m_explicitProperties[id].insert("boxColor");
				auto arr = element["boxColor"];
				boxColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			Color bgColor = {0, 0, 0, 0};
			if (element.contains("backgroundColor"))
			{
				m_explicitProperties[id].insert("backgroundColor");
				auto arr = element["backgroundColor"];
				bgColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				               (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Add parent offsets to make position absolute
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			// Scale height based on font size (baseline is 20px for default font)
			int scaledHeight = height;
			if (fontSize != 20)
			{
				scaledHeight = (int)((float)height * ((float)fontSize / 20.0f));
			}

			// Add the text input
			gui->AddTextInput(id, absoluteX, absoluteY, width, scaledHeight, font, text, textColor, boxColor, bgColor, group, active);
		}
		else if (type == "sprite")
		{
			// Get sprite/texture name
			string spriteName = element.value("sprite", "");

			// Get scale with defaults
			float scaleX = element.value("scaleX", 1.0f);
			float scaleY = element.value("scaleY", 1.0f);

			// Get color with inheritance
			Color color = WHITE;
			if (element.contains("color"))
			{
				m_explicitProperties[id].insert("color");
				auto arr = element["color"];
				color = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				              (unsigned char)arr[2], (unsigned char)arr[3] };
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("color"))
			{
				auto arr = inheritedProps["color"];
				color = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				              (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Add parent offsets to make position absolute
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			// Load the sprite/texture (prepend base sprite path)
			string spritePath = spriteName.empty() ? "" : s_baseSpritePath + spriteName;
			Texture loadedTexture = LoadTexture(spritePath.c_str());

			shared_ptr<Sprite> sprite = make_shared<Sprite>();
			if (loadedTexture.id == 0)
			{
				Log("GuiSerializer::ParseElements - Failed to load sprite: " + spritePath);
				// Create a default 32x32 sprite without a texture (will still crash if drawn)
				sprite->m_sourceRect = Rectangle{0, 0, 32, 32};
				sprite->m_texture = nullptr;
			}
			else
			{
				// Allocate texture on heap and copy the loaded texture
				Texture* texture = new Texture();
				*texture = loadedTexture;
				sprite->m_texture = texture;
				sprite->m_sourceRect = Rectangle{0, 0, float(texture->width), float(texture->height)};
			}

			// Store the sprite filename for serialization
			m_spriteNames[id] = spriteName;

			// Add the sprite element
			gui->AddSprite(id, absoluteX, absoluteY, sprite, scaleX, scaleY, color, group, active);
		}
		else if (type == "checkbox")
		{
			auto size = element["size"];
			int width = size[0];
			int height = size[1];

			// Get color
			Color color = WHITE;
			if (element.contains("color"))
			{
				auto arr = element["color"];
				color = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				              (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Get scale
			float scaleX = 1.0f;
			float scaleY = 1.0f;
			if (element.contains("scale"))
			{
				auto scale = element["scale"];
				scaleX = scale[0];
				scaleY = scale[1];
			}

			// Add parent offsets to make position absolute
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			// Add the checkbox (using simple box rendering, not sprites)
			auto checkbox = gui->AddCheckBox(id, absoluteX, absoluteY, width, height, scaleX, scaleY, color, group, active);

			// Set selected state if specified
			if (element.contains("selected"))
			{
				checkbox->m_Selected = element["selected"];
			}
		}
		else if (type == "radiobutton")
		{
			auto size = element["size"];
			int width = size[0];
			int height = size[1];

			// Get color
			Color color = WHITE;
			if (element.contains("color"))
			{
				auto arr = element["color"];
				color = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				              (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Get scale
			float scaleX = 1.0f;
			float scaleY = 1.0f;
			if (element.contains("scale"))
			{
				auto scale = element["scale"];
				scaleX = scale[0];
				scaleY = scale[1];
			}

			// Add parent offsets to make position absolute
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			// Add the radio button (using simple circle rendering, not sprites)
			auto radio = gui->AddRadioButton(id, absoluteX, absoluteY, width, height, scaleX, scaleY, color, group, active, false);

			// Set selected state if specified
			if (element.contains("selected"))
			{
				radio->m_Selected = element["selected"];
			}
		}
		else if (type == "scrollbar")
		{
			auto size = element["size"];
			int width = size[0];
			int height = size[1];

			// Get value range (0 to valueRange)
			int valueRange = element.value("valueRange", 100);

			// Get vertical flag
			bool vertical = element.value("vertical", true);

			// Get spur color
			Color spurColor = WHITE;
			if (element.contains("spurColor"))
			{
				auto arr = element["spurColor"];
				spurColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                  (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Get background color
			Color bgColor = DARKGRAY;
			if (element.contains("backgroundColor"))
			{
				auto arr = element["backgroundColor"];
				bgColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Add parent offsets to make position absolute
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			// Add the scrollbar
			gui->AddScrollBar(id, valueRange, absoluteX, absoluteY, width, height, vertical, spurColor, bgColor, group, active, false);
		}
		// Add more element types here as needed

		// Mark floating elements and update layout position
		if (isFloating && type != "include")
		{
			// Mark this element as floating
			SetFloating(id, true);

			// Get the created element to find its size
			auto createdElement = gui->GetElement(id);
			if (createdElement)
			{
				if (parentLayout == "horz")
				{
					// Horizontal layout: advance X by element width plus padding
					layoutX += createdElement->m_Width + horzPadding;
				}
				else if (parentLayout == "vert")
				{
					// Vertical layout: advance Y by element height plus padding
					layoutY += createdElement->m_Height + vertPadding;
				}
				else if (parentLayout == "table")
				{
					// Track max height in this row
					if (createdElement->m_Height > maxRowHeight)
						maxRowHeight = createdElement->m_Height;

					columnIndex++;

					// Move to next column or wrap to next row
					if (columnIndex >= columns)
					{
						// Wrap to next row
						layoutX = horzPadding;
						layoutY += maxRowHeight + vertPadding;
						columnIndex = 0;
						maxRowHeight = 0;
					}
					else
					{
						// Move to next column
						layoutX += static_cast<int>(createdElement->m_Width) + horzPadding;
					}
				}
			}
		}
	}
}

bool GuiSerializer::LoadFromFile(const std::string& filename, Gui* gui)
{
	// Step 1: Read JSON from file
	ghost_json j = ReadJsonFromFile(filename);
	if (j.empty())
	{
		return false;
	}

	// Step 2: Parse JSON and create GUI elements
	return ParseJson(j, gui);
}

ghost_json GuiSerializer::BuildInheritedProps(int parentElementID) const
{
	ghost_json inheritedProps;

	// Get font properties from parent if available
	auto fontIt = m_elementFonts.find(parentElementID);
	if (fontIt != m_elementFonts.end())
	{
		inheritedProps["font"] = fontIt->second;
		Log("BuildInheritedProps: Inheriting font '" + fontIt->second + "' from parent " + std::to_string(parentElementID));
	}

	auto fontSizeIt = m_elementFontSizes.find(parentElementID);
	if (fontSizeIt != m_elementFontSizes.end())
	{
		inheritedProps["fontSize"] = fontSizeIt->second;
		Log("BuildInheritedProps: Inheriting fontSize " + std::to_string(fontSizeIt->second) + " from parent " + std::to_string(parentElementID));
	}

	return inheritedProps;
}

bool GuiSerializer::LoadIntoPanel(const std::string& filename, Gui* gui, int parentX, int parentY, int parentElementID)
{
	// Read JSON from file
	ghost_json j = ReadJsonFromFile(filename);
	if (j.empty())
	{
		return false;
	}

	// Build inherited properties from parent panel
	ghost_json inheritedProps = BuildInheritedProps(parentElementID);

	// Parse elements directly at the specified position
	if (j.contains("gui") && j["gui"].contains("elements"))
	{
		ParseElements(j["gui"]["elements"], gui, inheritedProps, parentX, parentY, parentElementID);
		return true;
	}

	return false;
}

bool GuiSerializer::SaveToFile(const std::string& filename, Gui* gui)
{
	if (!gui)
	{
		Log("GuiSerializer::SaveToFile - gui is null");
		return false;
	}

	// Check if we have a root element to serialize
	if (m_rootElementID == -1)
	{
		Log("GuiSerializer::SaveToFile - No root element to serialize");
		return false;
	}

	try
	{
		ghost_json j;
		j["gui"]["position"] = { 0, 0 };  // Default position for content files
		j["gui"]["elements"] = ghost_json::array();

		// Serialize the children of the root directly (not the root itself)
		// The root is just an invisible container we use internally
		// IMPORTANT: There should be exactly ONE child of the root (single-root constraint)
		auto childIt = m_childrenMap.find(m_rootElementID);
		if (childIt != m_childrenMap.end())
		{
			const std::vector<int>& children = childIt->second;

			// Enforce single-root constraint
			if (children.empty())
			{
				Log("GuiSerializer::SaveToFile - Warning: No elements to save");
				// Still save empty elements array
			}
			else if (children.size() > 1)
			{
				Log("GuiSerializer::SaveToFile - Error: Multiple root elements detected (" + std::to_string(children.size()) + " elements)");
				Log("GuiSerializer::SaveToFile - Files must have exactly ONE root element. Use a panel to group multiple elements.");
				return false;
			}
			else
			{
				// Exactly one child - serialize it relative to the root's position
				// Get the root element to find its position
				auto rootElement = gui->GetElement(m_rootElementID);
				if (rootElement)
				{
					ghost_json childJson = SerializeElement(children[0], gui, rootElement->m_Pos.x, rootElement->m_Pos.y);
					if (!childJson.is_null())
					{
						j["gui"]["elements"].push_back(childJson);
					}
				}
			}
		}

		// Write to file
		ofstream file(filename);
		if (!file.is_open())
		{
			Log("GuiSerializer::SaveToFile - Could not open file for writing: " + filename);
			return false;
		}

		file << j.dump(2); // Pretty print with 2-space indent
		file.close();

		Log("GuiSerializer::SaveToFile - Successfully saved: " + filename);
		return true;
	}
	catch (const exception& e)
	{
		Log("GuiSerializer::SaveToFile - Exception: " + string(e.what()));
		return false;
	}
}

bool GuiSerializer::SaveSelectedElements(const std::string& filename, Gui* gui, const std::vector<int>& elementIDs)
{
	if (!gui)
	{
		Log("GuiSerializer::SaveSelectedElements - gui is null");
		return false;
	}

	try
	{
		ghost_json j;
		j["gui"]["position"] = { 0, 0 };  // Default position for standalone files
		j["gui"]["elements"] = ghost_json::array();

		// Only serialize elements in the provided ID list
		for (int id : elementIDs)
		{
			auto it = gui->m_GuiElementList.find(id);
			if (it == gui->m_GuiElementList.end())
			{
				Log("GuiSerializer::SaveSelectedElements - Element ID " + to_string(id) + " not found");
				continue;
			}

			auto element = it->second;
			ghost_json elementJson;

			elementJson["id"] = element->m_ID;
			elementJson["position"] = { element->m_Pos.x, element->m_Pos.y };
			elementJson["group"] = element->m_Group;

			// Type-specific serialization would go here
			// TODO: Add type detection and serialization for each element type

			j["gui"]["elements"].push_back(elementJson);
		}

		// Write to file
		ofstream file(filename);
		if (!file.is_open())
		{
			Log("GuiSerializer::SaveSelectedElements - Could not open file for writing: " + filename);
			return false;
		}

		file << j.dump(2); // Pretty print with 2-space indent
		file.close();

		Log("GuiSerializer::SaveSelectedElements - Successfully saved " + to_string(elementIDs.size()) + " elements to: " + filename);
		return true;
	}
	catch (const exception& e)
	{
		Log("GuiSerializer::SaveSelectedElements - Exception: " + string(e.what()));
		return false;
	}
}

void GuiSerializer::ReflowPanel(int panelID, Gui* gui)
{
	// Get the panel element
	auto panelIt = gui->m_GuiElementList.find(panelID);
	if (panelIt == gui->m_GuiElementList.end() || panelIt->second->m_Type != GUI_PANEL)
		return;

	auto panel = static_cast<GuiPanel*>(panelIt->second.get());

	// Get layout direction, padding, and columns
	string layout = m_panelLayouts.count(panelID) ? m_panelLayouts[panelID] : "horz";
	int horzPadding = m_panelHorzPaddings.count(panelID) ? m_panelHorzPaddings[panelID] : 5;
	int vertPadding = m_panelVertPaddings.count(panelID) ? m_panelVertPaddings[panelID] : 5;
	int columns = m_panelColumns.count(panelID) ? m_panelColumns[panelID] : 1;

	// Get children of this panel
	auto childrenIt = m_childrenMap.find(panelID);
	if (childrenIt == m_childrenMap.end())
		return;

	// Calculate new positions for floating children
	int layoutX = horzPadding;
	int layoutY = vertPadding;
	int columnIndex = 0;  // Track current column for table layout
	int maxRowHeight = 0; // Track max height in current row for table layout

	for (int childID : childrenIt->second)
	{
		// Only reflow floating elements
		if (!IsFloating(childID))
			continue;

		auto childIt = gui->m_GuiElementList.find(childID);
		if (childIt == gui->m_GuiElementList.end())
			continue;

		auto child = childIt->second;

		// Set new position
		child->m_Pos.x = panel->m_Pos.x + layoutX;
		child->m_Pos.y = panel->m_Pos.y + layoutY;

		// Update layout position for next element
		if (layout == "horz")
		{
			layoutX += static_cast<int>(child->m_Width) + horzPadding;
		}
		else if (layout == "vert")
		{
			layoutY += static_cast<int>(child->m_Height) + vertPadding;
		}
		else if (layout == "table")
		{
			// Track max height in this row
			if (child->m_Height > maxRowHeight)
				maxRowHeight = child->m_Height;

			columnIndex++;

			// Move to next column or wrap to next row
			if (columnIndex >= columns)
			{
				// Wrap to next row
				layoutX = horzPadding;
				layoutY += maxRowHeight + vertPadding;
				columnIndex = 0;
				maxRowHeight = 0;
			}
			else
			{
				// Move to next column
				layoutX += static_cast<int>(child->m_Width) + horzPadding;
			}
		}
	}

	// Resize panel to enclose all children with padding
	// Calculate the bounding box of all children
	float maxX = 0;
	float maxY = 0;

	for (int childID : childrenIt->second)
	{
		auto childIt = gui->m_GuiElementList.find(childID);
		if (childIt == gui->m_GuiElementList.end())
			continue;

		auto child = childIt->second;

		// Calculate the right edge and bottom edge of this child (relative to panel)
		float childRelativeX = child->m_Pos.x - panel->m_Pos.x;
		float childRelativeY = child->m_Pos.y - panel->m_Pos.y;
		float childRightEdge = childRelativeX + child->m_Width;
		float childBottomEdge = childRelativeY + child->m_Height;

		if (childRightEdge > maxX)
			maxX = childRightEdge;
		if (childBottomEdge > maxY)
			maxY = childBottomEdge;
	}

	// Set panel size to enclose all children plus padding
	panel->m_Width = maxX + horzPadding;
	panel->m_Height = maxY + vertPadding;
}

ghost_json GuiSerializer::SerializeElement(int elementID, Gui* gui, int parentX, int parentY)
{
	auto it = gui->m_GuiElementList.find(elementID);
	if (it == gui->m_GuiElementList.end())
	{
		Log("GuiSerializer::SerializeElement - Element ID " + to_string(elementID) + " not found");
		return ghost_json();
	}

	auto element = it->second;
	ghost_json elementJson;

	// Detect element type and serialize accordingly
	string type;
	switch (element->m_Type)
	{
		case GUI_PANEL:
			type = "panel";
			break;
		case GUI_TEXTBUTTON:
			type = "textbutton";
			break;
		case GUI_TEXTAREA:
			type = "textarea";
			break;
		case GUI_TEXTINPUT:
			type = "textinput";
			break;
		case GUI_CHECKBOX:
			type = "checkbox";
			break;
		case GUI_RADIOBUTTON:
			type = "radiobutton";
			break;
		case GUI_SPRITE:
			type = "sprite";
			break;
		case GUI_SCROLLBAR:
			type = "scrollbar";
			break;
		case GUI_ICONBUTTON:
			type = "iconbutton";
			break;
		case GUI_OCTAGONBOX:
			type = "octagonbox";
			break;
		case GUI_STRETCHBUTTON:
			type = "stretchbutton";
			break;
		case GUI_LIST:
			type = "list";
			break;
		// Add more types as needed
		default:
			Log("GuiSerializer::SerializeElement - Unknown element type: " + to_string(element->m_Type));
			type = "unknown";
			break;
	}

	// Common properties (in desired output order)

	// Add name if this element has one (check the name->ID map)
	for (const auto& [name, id] : m_elementNameToID)
	{
		if (id == elementID)
		{
			elementJson["name"] = name;
			break;
		}
	}

	elementJson["type"] = type;

	// Save position RELATIVE to parent
	// For floating elements, always save as -1, -1 regardless of actual position
	if (IsFloating(elementID))
	{
		elementJson["position"] = { -1, -1 };
	}
	else
	{
		int relativeX = element->m_Pos.x - parentX;
		int relativeY = element->m_Pos.y - parentY;
		elementJson["position"] = { relativeX, relativeY };
	}

	// Type-specific properties
	if (element->m_Type == GUI_PANEL)
	{
		auto panel = static_cast<GuiPanel*>(element.get());
		elementJson["size"] = { panel->m_Width, panel->m_Height };
		elementJson["color"] = { panel->m_Color.r, panel->m_Color.g, panel->m_Color.b, panel->m_Color.a };
		elementJson["filled"] = panel->m_Filled;

		// Add layout property (defaults to "horz" if not set)
		auto layoutIt = m_panelLayouts.find(elementID);
		std::string layout = (layoutIt != m_panelLayouts.end()) ? layoutIt->second : "horz";
		elementJson["layout"] = layout;

		// Add horizontal and vertical padding properties (defaults to 5 if not set)
		auto horzPaddingIt = m_panelHorzPaddings.find(elementID);
		int horzPadding = (horzPaddingIt != m_panelHorzPaddings.end()) ? horzPaddingIt->second : 5;
		elementJson["horzPadding"] = horzPadding;

		auto vertPaddingIt = m_panelVertPaddings.find(elementID);
		int vertPadding = (vertPaddingIt != m_panelVertPaddings.end()) ? vertPaddingIt->second : 5;
		elementJson["vertPadding"] = vertPadding;

		// Add columns property for table layout
		if (layout == "table")
		{
			auto columnsIt = m_panelColumns.find(elementID);
			int columns = (columnsIt != m_panelColumns.end()) ? columnsIt->second : 1;
			elementJson["columns"] = columns;
		}

		// Add font properties if explicitly set
		auto explicitIt = m_explicitProperties.find(elementID);
		if (explicitIt != m_explicitProperties.end())
		{
			const auto& explicitProps = explicitIt->second;

			if (explicitProps.count("font") > 0)
			{
				auto fontIt = m_elementFonts.find(elementID);
				if (fontIt != m_elementFonts.end())
					elementJson["font"] = fontIt->second;
			}

			if (explicitProps.count("fontSize") > 0)
			{
				auto sizeIt = m_elementFontSizes.find(elementID);
				if (sizeIt != m_elementFontSizes.end())
					elementJson["fontSize"] = sizeIt->second;
			}
		}
	}
	else if (element->m_Type == GUI_TEXTBUTTON)
	{
		auto button = static_cast<GuiTextButton*>(element.get());
		elementJson["text"] = button->m_String;

		// Only serialize properties that were explicitly set (not inherited)
		auto explicitIt = m_explicitProperties.find(elementID);
		if (explicitIt != m_explicitProperties.end())
		{
			const auto& explicitProps = explicitIt->second;

			if (explicitProps.count("font") > 0)
			{
				auto fontIt = m_elementFonts.find(elementID);
				if (fontIt != m_elementFonts.end())
					elementJson["font"] = fontIt->second;
			}

			if (explicitProps.count("fontSize") > 0)
			{
				auto sizeIt = m_elementFontSizes.find(elementID);
				if (sizeIt != m_elementFontSizes.end())
					elementJson["fontSize"] = sizeIt->second;
			}

			if (explicitProps.count("textColor") > 0)
				elementJson["textColor"] = { button->m_TextColor.r, button->m_TextColor.g, button->m_TextColor.b, button->m_TextColor.a };

			if (explicitProps.count("backgroundColor") > 0)
				elementJson["backgroundColor"] = { button->m_BackgroundColor.r, button->m_BackgroundColor.g, button->m_BackgroundColor.b, button->m_BackgroundColor.a };

			if (explicitProps.count("borderColor") > 0)
				elementJson["borderColor"] = { button->m_BorderColor.r, button->m_BorderColor.g, button->m_BorderColor.b, button->m_BorderColor.a };
		}
	}
	else if (element->m_Type == GUI_TEXTAREA)
	{
		auto textarea = static_cast<GuiTextArea*>(element.get());
		elementJson["text"] = textarea->m_String;

		// Only serialize properties that were explicitly set (not inherited)
		auto explicitIt = m_explicitProperties.find(elementID);
		if (explicitIt != m_explicitProperties.end())
		{
			const auto& explicitProps = explicitIt->second;

			if (explicitProps.count("font") > 0)
			{
				auto fontIt = m_elementFonts.find(elementID);
				if (fontIt != m_elementFonts.end())
					elementJson["font"] = fontIt->second;
			}

			if (explicitProps.count("fontSize") > 0)
			{
				auto sizeIt = m_elementFontSizes.find(elementID);
				if (sizeIt != m_elementFontSizes.end())
					elementJson["fontSize"] = sizeIt->second;
			}

			if (explicitProps.count("color") > 0)
				elementJson["color"] = { textarea->m_Color.r, textarea->m_Color.g, textarea->m_Color.b, textarea->m_Color.a };
		}

		if (textarea->m_Width > 0)
		{
			// The width is stored in pixels but needs to be saved as "character widths"
			// because AddTextArea multiplies the width parameter by font baseSize
			int charWidth = int(textarea->m_Width / textarea->m_Font->baseSize);
			elementJson["width"] = charWidth;
		}
		if (textarea->m_Height > 0)
		{
			elementJson["height"] = textarea->m_Height;
		}
		elementJson["justified"] = textarea->m_Justified;
	}
	else if (element->m_Type == GUI_TEXTINPUT)
	{
		auto textinput = static_cast<GuiTextInput*>(element.get());
		elementJson["text"] = textinput->m_String;
		elementJson["size"] = { textinput->m_Width, textinput->m_Height };

		// Only serialize properties that were explicitly set (not inherited)
		auto explicitIt = m_explicitProperties.find(elementID);
		if (explicitIt != m_explicitProperties.end())
		{
			const auto& explicitProps = explicitIt->second;

			if (explicitProps.count("textColor") > 0)
				elementJson["textColor"] = { textinput->m_TextColor.r, textinput->m_TextColor.g, textinput->m_TextColor.b, textinput->m_TextColor.a };

			if (explicitProps.count("boxColor") > 0)
				elementJson["boxColor"] = { textinput->m_BoxColor.r, textinput->m_BoxColor.g, textinput->m_BoxColor.b, textinput->m_BoxColor.a };

			if (explicitProps.count("backgroundColor") > 0)
				elementJson["backgroundColor"] = { textinput->m_BackgroundColor.r, textinput->m_BackgroundColor.g, textinput->m_BackgroundColor.b, textinput->m_BackgroundColor.a };
		}
	}
	else if (element->m_Type == GUI_CHECKBOX)
	{
		auto checkbox = static_cast<GuiCheckBox*>(element.get());
		elementJson["size"] = { checkbox->m_Width, checkbox->m_Height };
		elementJson["color"] = { checkbox->m_Color.r, checkbox->m_Color.g, checkbox->m_Color.b, checkbox->m_Color.a };
		elementJson["selected"] = checkbox->m_Selected;
		elementJson["scale"] = { checkbox->m_ScaleX, checkbox->m_ScaleY };
	}
	else if (element->m_Type == GUI_RADIOBUTTON)
	{
		auto radio = static_cast<GuiRadioButton*>(element.get());
		elementJson["size"] = { radio->m_Width, radio->m_Height };
		elementJson["color"] = { radio->m_Color.r, radio->m_Color.g, radio->m_Color.b, radio->m_Color.a };
		elementJson["selected"] = radio->m_Selected;
		elementJson["scale"] = { radio->m_ScaleX, radio->m_ScaleY };
	}
	else if (element->m_Type == GUI_SPRITE)
	{
		auto sprite = static_cast<GuiSprite*>(element.get());

		// Serialize sprite properties
		elementJson["sprite"] = GetSpriteName(elementID);
		elementJson["scaleX"] = sprite->m_ScaleX;
		elementJson["scaleY"] = sprite->m_ScaleY;

		// Only serialize color if explicitly set (not inherited)
		auto explicitIt = m_explicitProperties.find(elementID);
		if (explicitIt != m_explicitProperties.end())
		{
			const auto& explicitProps = explicitIt->second;
			if (explicitProps.count("color") > 0)
				elementJson["color"] = { sprite->m_Color.r, sprite->m_Color.g, sprite->m_Color.b, sprite->m_Color.a };
		}
	}
	else if (element->m_Type == GUI_SCROLLBAR)
	{
		auto scrollbar = static_cast<GuiScrollBar*>(element.get());
		elementJson["valueRange"] = scrollbar->m_ValueRange;
		elementJson["size"] = { scrollbar->m_Width, scrollbar->m_Height };
		elementJson["vertical"] = scrollbar->m_Vertical;
		elementJson["spurColor"] = { scrollbar->m_SpurColor.r, scrollbar->m_SpurColor.g, scrollbar->m_SpurColor.b, scrollbar->m_SpurColor.a };
		elementJson["backgroundColor"] = { scrollbar->m_BackgroundColor.r, scrollbar->m_BackgroundColor.g, scrollbar->m_BackgroundColor.b, scrollbar->m_BackgroundColor.a };
	}
	else if (element->m_Type == GUI_ICONBUTTON)
	{
		auto iconbutton = static_cast<GuiIconButton*>(element.get());
		elementJson["sprite"] = GetSpriteName(elementID);
		if (!iconbutton->m_String.empty())
			elementJson["text"] = iconbutton->m_String;
		elementJson["color"] = { iconbutton->m_FontColor.r, iconbutton->m_FontColor.g, iconbutton->m_FontColor.b, iconbutton->m_FontColor.a };
		elementJson["scale"] = iconbutton->m_Scale;
		if (iconbutton->m_CanBeHeld)
			elementJson["canBeHeld"] = iconbutton->m_CanBeHeld;
	}
	else if (element->m_Type == GUI_OCTAGONBOX)
	{
		auto octagonbox = static_cast<GuiOctagonBox*>(element.get());
		elementJson["size"] = { octagonbox->m_Width, octagonbox->m_Height };
		elementJson["color"] = { octagonbox->m_Color.r, octagonbox->m_Color.g, octagonbox->m_Color.b, octagonbox->m_Color.a };
		// Note: borders serialization not implemented yet - would need sprite name tracking for 8 sprites
	}
	else if (element->m_Type == GUI_STRETCHBUTTON)
	{
		auto stretchbutton = static_cast<GuiStretchButton*>(element.get());
		elementJson["width"] = stretchbutton->m_Width;
		elementJson["label"] = stretchbutton->m_String;
		elementJson["indent"] = stretchbutton->m_Indent;
		elementJson["color"] = { stretchbutton->m_Color.r, stretchbutton->m_Color.g, stretchbutton->m_Color.b, stretchbutton->m_Color.a };
		// Note: sprite parts serialization not implemented yet - would need sprite name tracking for 6 sprites
	}
	else if (element->m_Type == GUI_LIST)
	{
		auto list = static_cast<GuiList*>(element.get());
		elementJson["size"] = { list->m_Width, list->m_Height };
		elementJson["items"] = list->m_Items;
		elementJson["textColor"] = { list->m_TextColor.r, list->m_TextColor.g, list->m_TextColor.b, list->m_TextColor.a };
		elementJson["backgroundColor"] = { list->m_BackgroundColor.r, list->m_BackgroundColor.g, list->m_BackgroundColor.b, list->m_BackgroundColor.a };
		elementJson["borderColor"] = { list->m_BorderColor.r, list->m_BorderColor.g, list->m_BorderColor.b, list->m_BorderColor.a };
		// Note: font serialization would need font name tracking
	}

	// Common properties that go after type-specific ones
	// Only save group if it's non-zero (we're not using grouping yet)
	if (element->m_Group != 0)
	{
		elementJson["group"] = element->m_Group;
	}
	// Note: "active" property is no longer saved - elements are always created active,
	// and runtime context determines if they should be disabled

	// Recursively serialize children - ADD LAST so it appears at the end
	auto childIt = m_childrenMap.find(elementID);
	if (childIt != m_childrenMap.end() && !childIt->second.empty())
	{
		elementJson["elements"] = ghost_json::array();
		for (int childID : childIt->second)
		{
			// Pass this element's position as the parent position for children
			ghost_json childJson = SerializeElement(childID, gui, element->m_Pos.x, element->m_Pos.y);
			if (!childJson.is_null())
			{
				elementJson["elements"].push_back(childJson);
			}
		}
	}

	return elementJson;
}

std::vector<int> GuiSerializer::GetAllElementIDs() const
{
	std::vector<int> allIDs;

	if (m_rootElementID == -1)
	{
		return allIDs;  // No tree to traverse
	}

	// Add root
	allIDs.push_back(m_rootElementID);

	// Track visited nodes to prevent infinite recursion from circular references
	std::set<int> visited;
	visited.insert(m_rootElementID);

	// Recursively collect all descendants
	std::function<void(int)> collectIDs = [&](int parentID)
	{
		auto it = m_childrenMap.find(parentID);
		if (it != m_childrenMap.end())
		{
			for (int childID : it->second)
			{
				// Check for circular reference
				if (visited.find(childID) != visited.end())
				{
					Log("WARNING: Circular reference detected - element " + std::to_string(childID) + " is already in the tree");
					continue;
				}

				allIDs.push_back(childID);
				visited.insert(childID);
				collectIDs(childID);  // Recurse for grandchildren
			}
		}
	};

	collectIDs(m_rootElementID);

	return allIDs;
}
