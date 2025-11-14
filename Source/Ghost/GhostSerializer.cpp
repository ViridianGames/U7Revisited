#include "GhostSerializer.h"
#include "../Geist/Logging.h"
#include "../Geist/ResourceManager.h"
#include "../Geist/Primitives.h"
#include "../Geist/Config.h"
#include "../../ThirdParty/nlohmann/json.hpp"
#include <fstream>
#include <functional>

using namespace std;

extern std::unique_ptr<ResourceManager> g_ResourceManager;

// Initialize static members
std::string GhostSerializer::s_baseFontPath = "Fonts/";
std::string GhostSerializer::s_baseSpritePath = "Images/";
std::string GhostSerializer::s_baseGhostPath = "Gui/Ghost/";

GhostSerializer::GhostSerializer()
{
}

GhostSerializer::~GhostSerializer()
{
}

void GhostSerializer::SetBaseFontPath(const std::string& path)
{
	s_baseFontPath = path;
}

void GhostSerializer::SetBaseSpritePath(const std::string& path)
{
	s_baseSpritePath = path;
}

void GhostSerializer::SetBaseGhostPath(const std::string& path)
{
	s_baseGhostPath = path;
}

ghost_json GhostSerializer::ReadJsonFromFile(const std::string& filename)
{
	try
	{
		ifstream file(filename);
		if (!file.is_open())
		{
			Log("GhostSerializer::ReadJsonFromFile - Could not open file: " + filename);
			return ghost_json();
		}

		ghost_json j;
		file >> j;
		file.close();

		Log("GhostSerializer::ReadJsonFromFile - Successfully read: " + filename);
		return j;
	}
	catch (const exception& e)
	{
		Log("GhostSerializer::ReadJsonFromFile - Exception: " + string(e.what()));
		return ghost_json();
	}
}

bool GhostSerializer::ParseJson(const ghost_json& j, Gui* gui)
{
	if (!gui)
	{
		Log("GhostSerializer::ParseJson - gui is null");
		return false;
	}

	if (j.empty())
	{
		Log("GhostSerializer::ParseJson - JSON is empty");
		return false;
	}

	try
	{
		// Parse the GUI object
		if (!j.contains("gui"))
		{
			Log("GhostSerializer::ParseJson - JSON does not contain 'gui' object");
			return false;
		}

		auto guiObj = j["gui"];

		// Parse elements
		if (guiObj.contains("elements"))
		{
			ParseElements(guiObj["elements"], gui);
		}

		Log("GhostSerializer::ParseJson - Successfully parsed GUI");
		return true;
	}
	catch (const exception& e)
	{
		Log("GhostSerializer::ParseJson - Exception: " + string(e.what()));
		return false;
	}
}

int GhostSerializer::GetElementID(const std::string& name) const
{
	auto it = m_elementNameToID.find(name);
	if (it != m_elementNameToID.end())
	{
		return it->second;
	}
	return -1;  // Not found
}

std::pair<int, int> GhostSerializer::CalculateNextFloatingPosition(int parentID, Gui* gui) const
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

void GhostSerializer::ParseElements(const ghost_json& elementsArray, Gui* gui, const ghost_json& inheritedProps, int parentX, int parentY, int parentElementID, const std::string& namePrefix, int insertIndex)
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

		// Handle includes first - they have no position or visual properties
		if (type == "include")
		{
			// Include elements from another file
			// Includes have no position - they simply compose the included file's content
			// The included file's root element handles its own positioning
			string filename = element["filename"];
			string includeNamePrefix = element.value("namePrefix", "");  // Optional name prefix for included elements

			if (!includeNamePrefix.empty())
			{
				Log("GhostSerializer::ParseElements - Loading included file: " + filename + " with namePrefix: " + includeNamePrefix);
			}
			else
			{
				Log("GhostSerializer::ParseElements - Loading included file: " + filename);
			}

			// Track children before include so we can find what was added
			vector<int> childrenBefore;
			if (parentElementID != -1 && m_childrenMap.find(parentElementID) != m_childrenMap.end())
			{
				childrenBefore = m_childrenMap[parentElementID];
			}

			// Read and parse the included file
			ghost_json includedJson = ReadJsonFromFile(s_baseGhostPath + filename);
			if (!includedJson.empty() && includedJson.contains("gui") && includedJson["gui"].contains("elements"))
			{
				// Parse included elements with parent's offsets PLUS current layout position
				// Pass the namePrefix to prepend to all element names in the included file
				ParseElements(includedJson["gui"]["elements"], gui, inheritedProps,
				             parentX + layoutX, parentY + layoutY, parentElementID, includeNamePrefix);
			}

			// Update layout position based on what was added by the include
			// Find the new children that were added
			if (parentElementID != -1 && m_childrenMap.find(parentElementID) != m_childrenMap.end())
			{
				const vector<int>& childrenAfter = m_childrenMap[parentElementID];

				// Track the first child added by the include for serialization purposes
				int firstIncludedChildID = -1;

				// Find newly added children (those in childrenAfter but not in childrenBefore)
				for (int childID : childrenAfter)
				{
					// Check if this child existed before
					if (find(childrenBefore.begin(), childrenBefore.end(), childID) != childrenBefore.end())
						continue;  // Skip existing children

					// Track first child for include metadata
					if (firstIncludedChildID == -1)
					{
						firstIncludedChildID = childID;
						// Store include metadata for this child
						IncludeMetadata metadata;
						metadata.filename = filename;
						metadata.namePrefix = includeNamePrefix;
						m_includeElements[childID] = metadata;
						Log("Marked element " + to_string(childID) + " as include from: " + filename);
					}

					// This is a new child added by the include
					auto child = gui->GetElement(childID);
					if (child && IsFloating(childID))
					{
						// Advance layout position based on this child's size
						if (parentLayout == "horz")
						{
							layoutX += child->m_Width + horzPadding;
						}
						else if (parentLayout == "vert")
						{
							layoutY += child->m_Height + vertPadding;
						}
						else if (parentLayout == "table")
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
						Log("Include child " + to_string(childID) + " consumed space, updated layout: layoutX=" + to_string(layoutX) + ", layoutY=" + to_string(layoutY));
					}
				}
			}

			continue;  // Skip to next element, includes have no further processing
		}

		// All non-include elements have a position
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
			// Apply namePrefix if provided (for includes)
			string prefixedName = namePrefix + name;
			m_elementNameToID[prefixedName] = id;
		}

		// Store hover text if provided (for tooltips)
		if (element.contains("hoverText"))
		{
			string hoverText = element["hoverText"];
			if (!hoverText.empty())
			{
				SetElementHoverText(id, hoverText);
			}
		}

		// Track tree structure for real elements
		// If this is a root element (parentElementID == -1), store as root
		if (parentElementID == -1 && m_rootElementID == -1)
		{
			m_rootElementID = id;
		}
		// Add to parent's children list at the specified index
		if (parentElementID != -1)
		{
			if (insertIndex >= 0)
			{
				RegisterChildOfParentAtIndex(parentElementID, id, insertIndex);
				// Increment insertIndex for next element in this batch
				insertIndex++;
			}
			else
			{
				m_childrenMap[parentElementID].push_back(id);
			}
		}

		if (type == "panel")
		{
			auto size = element["size"];
			int width = size[0];
			int height = size[1];

			auto colorArr = element["backgroundColor"];
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

			// Store the original panel size from JSON
			m_panelSizes[id] = std::make_pair(width, height);

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
				// Pass along the same namePrefix to child elements
				ParseElements(element["elements"], gui, childInheritedProps, absoluteX, absoluteY, id, namePrefix);

				// Recalculate panel size to fit all children
				ReflowPanel(id, gui);
			}
		}
		else if (type == "textbutton")
		{
			string text = element["text"];

			// Load font with inheritance support
			string fontName;
			int fontSize;
			Font* font = LoadFontWithInheritance(element, inheritedProps, id, fontName, fontSize);

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

			// Check if explicit size is provided, otherwise use auto-sizing
			if (element.contains("size"))
			{
				auto sizeArr = element["size"];
				int width = sizeArr[0].get<int>();
				int height = sizeArr[1].get<int>();
				gui->AddTextButton(id, absoluteX, absoluteY, width, height, text, font,
				                   textColor, bgColor, borderColor, group, active);
			}
			else
			{
				// Use the auto-sizing version of AddTextButton
				gui->AddTextButton(id, absoluteX, absoluteY, text, font,
				                   textColor, bgColor, borderColor, group, active);
			}
		}
		else if (type == "textarea")
		{
			string text = element["text"];

			// Load font with inheritance support
			string fontName;
			int fontSize;
			Font* font = LoadFontWithInheritance(element, inheritedProps, id, fontName, fontSize);

			// Get textColor with inheritance
			Color color = WHITE;
			if (element.contains("textColor"))
			{
				m_explicitProperties[id].insert("textColor");
				auto arr = element["textColor"];
				color = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				              (unsigned char)arr[2], (unsigned char)arr[3] };
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("textColor"))
			{
				auto arr = inheritedProps["textColor"];
				color = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				              (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Get width and height - support both new "size" array format and legacy "width"/"height" format
			int width = 0;
			int height = 0;

			if (element.contains("size") && element["size"].is_array() && element["size"].size() >= 2)
			{
				// New standard format: "size": [width, height] (both in pixels)
				width = element["size"][0];
				height = element["size"][1];
			}
			else
			{
				// Legacy format: separate "width" (character count) and "height" (pixels) properties
				// Convert character count to pixels for backward compatibility
				int charWidth = element.value("width", 0);
				height = element.value("height", 0);

				// If we have a character width, multiply by font baseSize
				if (charWidth > 0)
				{
					width = charWidth * font->baseSize;
				}
			}

			int justified = element.value("justified", 0);

			// Add parent offsets to make position absolute
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			// Width and height are now both in pixels, pass them directly
			gui->AddTextArea(id, font, text, absoluteX, absoluteY, width, height, color, justified, group, active, false);
		}
		else if (type == "textinput")
		{
			string text = element.value("text", "");
			// If text is empty and example text is enabled, use "example" as default to show the font
			if (text.empty() && m_useExampleText)
			{
				text = "example";
			}
			auto size = element["size"];
			int width = size[0];
			int height = size[1];

			// Load font with inheritance support
			string fontName;
			int fontSize;
			Font* font = LoadFontWithInheritance(element, inheritedProps, id, fontName, fontSize);

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
			// Support borderColor (preferred) or boxColor (legacy) for textinput border
			if (element.contains("borderColor"))
			{
				m_explicitProperties[id].insert("borderColor");
				auto arr = element["borderColor"];
				boxColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                (unsigned char)arr[2], (unsigned char)arr[3] };
			}
			else if (element.contains("boxColor"))
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

			// Add the text input
			gui->AddTextInput(id, absoluteX, absoluteY, width, height, font, text, textColor, boxColor, bgColor, group, active);
		}
		else if (type == "sprite")
		{
			// Parse sprite definition (support both old string format and new object format)
			SpriteDefinition spriteDef;
			if (element.contains("sprite"))
			{
				if (element["sprite"].is_string())
				{
					// Old format: "sprite": "filename.png"
					string spriteName = element["sprite"].get<string>();
					// Load full texture and store definition
					string spritePath = spriteName.empty() ? "" : s_baseSpritePath + spriteName;
					Texture loadedTexture = LoadTexture(spritePath.c_str());
					spriteDef.spritesheet = spriteName;
					spriteDef.x = 0;
					spriteDef.y = 0;
					spriteDef.w = (loadedTexture.id != 0) ? loadedTexture.width : 48;
					spriteDef.h = (loadedTexture.id != 0) ? loadedTexture.height : 48;
					if (loadedTexture.id != 0)
						UnloadTexture(loadedTexture);  // We'll reload it below
				}
				else if (element["sprite"].is_object())
				{
					// New format: "sprite": {"spritesheet": "file.png", "x": 0, "y": 0, "w": 32, "h": 32}
					auto spriteObj = element["sprite"];
					spriteDef.spritesheet = spriteObj.value("spritesheet", "");
					spriteDef.x = spriteObj.value("x", 0);
					spriteDef.y = spriteObj.value("y", 0);
					spriteDef.w = spriteObj.value("w", 48);
					spriteDef.h = spriteObj.value("h", 48);
				}
			}

			// Store sprite definition
			SetSprite(id, spriteDef);

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

			// Load the sprite texture with the specified rectangle
			string spritePath = spriteDef.spritesheet.empty() ? "" : s_baseSpritePath + spriteDef.spritesheet;
			Texture loadedTexture = LoadTexture(spritePath.c_str());

			shared_ptr<Sprite> sprite = make_shared<Sprite>();
			if (loadedTexture.id == 0)
			{
				Log("GhostSerializer::ParseElements - Failed to load sprite: " + spritePath);
				// Create a default sprite without a texture
				sprite->m_sourceRect = Rectangle{0, 0, 32, 32};
				sprite->m_texture = nullptr;
			}
			else
			{
				// Allocate texture on heap and copy the loaded texture
				Texture* texture = new Texture();
				*texture = loadedTexture;
				sprite->m_texture = texture;
				// Use the specified rectangle from the sprite definition
				sprite->m_sourceRect = Rectangle{
					static_cast<float>(spriteDef.x),
					static_cast<float>(spriteDef.y),
					static_cast<float>(spriteDef.w),
					static_cast<float>(spriteDef.h)
				};
			}

			// Add the sprite element
			gui->AddSprite(id, absoluteX, absoluteY, sprite, scaleX, scaleY, color, group, active);
		}
		else if (type == "cycle")
		{
			// Parse sprite definition (same as sprite)
			SpriteDefinition spriteDef;
			if (element.contains("sprite"))
			{
				if (element["sprite"].is_string())
				{
					// Old format: "sprite": "filename.png"
					string spriteName = element["sprite"].get<string>();
					// Load full texture and store definition
					string spritePath = spriteName.empty() ? "" : s_baseSpritePath + spriteName;
					Texture loadedTexture = LoadTexture(spritePath.c_str());
					spriteDef.spritesheet = spriteName;
					spriteDef.x = 0;
					spriteDef.y = 0;
					spriteDef.w = (loadedTexture.id != 0) ? loadedTexture.width : 48;
					spriteDef.h = (loadedTexture.id != 0) ? loadedTexture.height : 48;
					if (loadedTexture.id != 0)
						UnloadTexture(loadedTexture);  // We'll reload it below
				}
				else if (element["sprite"].is_object())
				{
					// New format: "sprite": {"spritesheet": "file.png", "x": 0, "y": 0, "w": 32, "h": 32}
					auto spriteObj = element["sprite"];
					spriteDef.spritesheet = spriteObj.value("spritesheet", "");
					spriteDef.x = spriteObj.value("x", 0);
					spriteDef.y = spriteObj.value("y", 0);
					spriteDef.w = spriteObj.value("w", 48);
					spriteDef.h = spriteObj.value("h", 48);
				}
			}

			// Store sprite definition
			SetSprite(id, spriteDef);

			// Get frame count (default to 1)
			int frameCount = element.value("frameCount", 1);

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

			// Load the sprite texture with the specified rectangle
			string spritePath = spriteDef.spritesheet.empty() ? "" : s_baseSpritePath + spriteDef.spritesheet;
			Texture loadedTexture = LoadTexture(spritePath.c_str());

			// Create frames using helper function
			vector<shared_ptr<Sprite>> frames;
			if (loadedTexture.id == 0)
			{
				Log("GhostSerializer::ParseElements - Failed to load cycle sprite: " + spritePath);
				// Create default frames
				for (int i = 0; i < frameCount; i++)
				{
					auto sprite = make_shared<Sprite>();
					sprite->m_sourceRect = Rectangle{0, 0, 32, 32};
					sprite->m_texture = nullptr;
					frames.push_back(sprite);
				}
			}
			else
			{
				// Allocate texture on heap and copy the loaded texture
				Texture* texture = new Texture();
				*texture = loadedTexture;

				// Use CreateHorizontalSpriteFrames to generate frames
				frames = CreateHorizontalSpriteFrames(
					texture,
					spriteDef.x, spriteDef.y,
					spriteDef.w, spriteDef.h,
					frameCount
				);
			}

			// Add the cycle element
			gui->AddCycle(id, absoluteX, absoluteY, frames, scaleX, scaleY, color, group, active);
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
		else if (type == "list")
		{
			auto size = element["size"];
			int width = size[0];
			int height = size[1];

			// Get items array
			vector<string> items;
			if (element.contains("items"))
			{
				for (const auto& item : element["items"])
				{
					items.push_back(item.get<string>());
				}
			}

			// Get text color with inheritance
			Color textColor = WHITE;
			if (element.contains("textColor"))
			{
				m_explicitProperties[id].insert("textColor");
				auto arr = element["textColor"];
				textColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                  (unsigned char)arr[2], (unsigned char)arr[3] };
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("textColor"))
			{
				auto arr = inheritedProps["textColor"];
				textColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                  (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Get background color
			Color bgColor = BLACK;
			if (element.contains("backgroundColor"))
			{
				m_explicitProperties[id].insert("backgroundColor");
				auto arr = element["backgroundColor"];
				bgColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                (unsigned char)arr[2], (unsigned char)arr[3] };
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("backgroundColor"))
			{
				auto arr = inheritedProps["backgroundColor"];
				bgColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Get border color
			Color borderColor = WHITE;
			if (element.contains("borderColor"))
			{
				m_explicitProperties[id].insert("borderColor");
				auto arr = element["borderColor"];
				borderColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                    (unsigned char)arr[2], (unsigned char)arr[3] };
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("borderColor"))
			{
				auto arr = inheritedProps["borderColor"];
				borderColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                    (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Load font with inheritance support
			string fontName;
			int fontSize;
			Font* font = LoadFontWithInheritance(element, inheritedProps, id, fontName, fontSize);

			// Add parent offsets to make position absolute
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			// Add the list
			gui->AddGuiList(id, absoluteX, absoluteY, width, height, font, items, textColor, bgColor, borderColor, group, active);
		}
		else if (type == "listbox")
		{
			auto size = element["size"];
			int width = size[0];
			int height = size[1];

			// Get items array (optional - can be populated later)
			vector<string> items;
			if (element.contains("items"))
			{
				for (const auto& item : element["items"])
				{
					items.push_back(item.get<string>());
				}
			}

			// Get text color with inheritance
			Color textColor = WHITE;
			if (element.contains("textColor"))
			{
				m_explicitProperties[id].insert("textColor");
				auto arr = element["textColor"];
				textColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                  (unsigned char)arr[2], (unsigned char)arr[3] };
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("textColor"))
			{
				auto arr = inheritedProps["textColor"];
				textColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                  (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Get background color
			Color bgColor = BLACK;
			if (element.contains("backgroundColor"))
			{
				m_explicitProperties[id].insert("backgroundColor");
				auto arr = element["backgroundColor"];
				bgColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                (unsigned char)arr[2], (unsigned char)arr[3] };
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("backgroundColor"))
			{
				auto arr = inheritedProps["backgroundColor"];
				bgColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Get border color
			Color borderColor = WHITE;
			if (element.contains("borderColor"))
			{
				m_explicitProperties[id].insert("borderColor");
				auto arr = element["borderColor"];
				borderColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                    (unsigned char)arr[2], (unsigned char)arr[3] };
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("borderColor"))
			{
				auto arr = inheritedProps["borderColor"];
				borderColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                    (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Load font with inheritance support
			string fontName;
			int fontSize;
			Font* font = LoadFontWithInheritance(element, inheritedProps, id, fontName, fontSize);

			// Add parent offsets to make position absolute
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			// Add the listbox
			gui->AddListBox(id, absoluteX, absoluteY, width, height, font, items, textColor, bgColor, borderColor, group, active);
		}
		else if (type == "iconbutton")
		{
			// Parse sprite definition (support both old string format and new object format)
			SpriteDefinition spriteDef;
			if (element.contains("sprite"))
			{
				if (element["sprite"].is_string())
				{
					// Old format: "sprite": "filename.png"
					string spriteName = element["sprite"].get<string>();
					// Load full texture and store definition
					string spritePath = spriteName.empty() ? "" : s_baseSpritePath + spriteName;
					Texture loadedTexture = LoadTexture(spritePath.c_str());
					spriteDef.spritesheet = spriteName;
					spriteDef.x = 0;
					spriteDef.y = 0;
					spriteDef.w = (loadedTexture.id != 0) ? loadedTexture.width : 48;
					spriteDef.h = (loadedTexture.id != 0) ? loadedTexture.height : 48;
					if (loadedTexture.id != 0)
						UnloadTexture(loadedTexture);  // We'll reload it below
				}
				else if (element["sprite"].is_object())
				{
					// New format: "sprite": {"spritesheet": "file.png", "x": 0, "y": 0, "w": 32, "h": 32}
					auto spriteObj = element["sprite"];
					spriteDef.spritesheet = spriteObj.value("spritesheet", "");
					spriteDef.x = spriteObj.value("x", 0);
					spriteDef.y = spriteObj.value("y", 0);
					spriteDef.w = spriteObj.value("w", 48);
					spriteDef.h = spriteObj.value("h", 48);
				}
			}

			// Store sprite definition
			SetSprite(id, spriteDef);

			// Get text (optional)
			string text = element.value("text", "");

			// Get scale
			float scale = element.value("scale", 1.0f);

			// Get canBeHeld flag
			bool canBeHeld = element.value("canBeHeld", false);

			// Get text color (called "color" in JSON for iconbutton)
			Color fontColor = WHITE;
			if (element.contains("color"))
			{
				m_explicitProperties[id].insert("textColor");
				auto arr = element["color"];
				fontColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                  (unsigned char)arr[2], (unsigned char)arr[3] };
			}
			else if (!inheritedProps.is_null() && inheritedProps.contains("textColor"))
			{
				auto arr = inheritedProps["textColor"];
				fontColor = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
				                  (unsigned char)arr[2], (unsigned char)arr[3] };
			}

			// Load font with inheritance support
			string fontName;
			int fontSize;
			Font* font = LoadFontWithInheritance(element, inheritedProps, id, fontName, fontSize);

			// Add parent offsets to make position absolute
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			// Load sprite with the specified rectangle
			shared_ptr<Sprite> upSprite = nullptr;
			if (!spriteDef.spritesheet.empty())
			{
				string spritePath = s_baseSpritePath + spriteDef.spritesheet;
				Texture loadedTexture = LoadTexture(spritePath.c_str());

				upSprite = make_shared<Sprite>();
				if (loadedTexture.id == 0)
				{
					Log("GhostSerializer::ParseElements - Failed to load iconbutton sprite: " + spritePath);
					upSprite->m_sourceRect = Rectangle{0, 0, 32, 32};
					upSprite->m_texture = nullptr;
				}
				else
				{
					Texture* texture = new Texture();
					*texture = loadedTexture;
					upSprite->m_texture = texture;
					// Use the specified rectangle from the sprite definition
					upSprite->m_sourceRect = Rectangle{
						static_cast<float>(spriteDef.x),
						static_cast<float>(spriteDef.y),
						static_cast<float>(spriteDef.w),
						static_cast<float>(spriteDef.h)
					};
				}
			}

			// Parse and load down sprite definition (optional)
			shared_ptr<Sprite> downSprite = nullptr;
			if (element.contains("downSprite") && element["downSprite"].is_object())
			{
				auto downSpriteObj = element["downSprite"];
				SpriteDefinition downSpriteDef;
				downSpriteDef.spritesheet = downSpriteObj.value("spritesheet", "");
				downSpriteDef.x = downSpriteObj.value("x", 0);
				downSpriteDef.y = downSpriteObj.value("y", 0);
				downSpriteDef.w = downSpriteObj.value("w", 48);
				downSpriteDef.h = downSpriteObj.value("h", 48);

				// Store down sprite definition
				SetIconButtonDownSprite(id, downSpriteDef);

				// Load down sprite texture
				if (!downSpriteDef.spritesheet.empty())
				{
					string downSpritePath = s_baseSpritePath + downSpriteDef.spritesheet;
					Texture loadedTexture = LoadTexture(downSpritePath.c_str());

					downSprite = make_shared<Sprite>();
					if (loadedTexture.id == 0)
					{
						Log("GhostSerializer::ParseElements - Failed to load iconbutton down sprite: " + downSpritePath);
						downSprite->m_sourceRect = Rectangle{0, 0, 32, 32};
						downSprite->m_texture = nullptr;
					}
					else
					{
						Texture* texture = new Texture();
						*texture = loadedTexture;
						downSprite->m_texture = texture;
						downSprite->m_sourceRect = Rectangle{
							static_cast<float>(downSpriteDef.x),
							static_cast<float>(downSpriteDef.y),
							static_cast<float>(downSpriteDef.w),
							static_cast<float>(downSpriteDef.h)
						};
					}
				}
			}

			// Add the iconbutton (inactivebutton defaults to nullptr)
			gui->AddIconButton(id, absoluteX, absoluteY, upSprite, downSprite, nullptr, text,
			                  font, fontColor, scale, group, active, canBeHeld);
		}
		else if (type == "octagonbox")
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

			// Load 9 border sprites if specified
			// Order: topLeft, top, topRight, left, center, right, bottomLeft, bottom, bottomRight
			vector<shared_ptr<Sprite>> borders;
			vector<string> borderSpriteNames;
			const char* borderNames[] = {
				"borderTopLeft", "borderTop", "borderTopRight",
				"borderLeft", "borderCenter", "borderRight",
				"borderBottomLeft", "borderBottom", "borderBottomRight"
			};

			for (int i = 0; i < 9; i++)
			{
				if (element.contains(borderNames[i]))
				{
					string spriteName = element[borderNames[i]].get<string>();

					// Load sprite using same pattern as other sprite loading
					string spritePath = s_baseSpritePath + spriteName;
					Texture loadedTexture = LoadTexture(spritePath.c_str());

					shared_ptr<Sprite> sprite = make_shared<Sprite>();
					if (loadedTexture.id == 0)
					{
						Log("GhostSerializer::ParseElements - Failed to load octagonbox border sprite: " + spritePath);
						sprite->m_sourceRect = Rectangle{0, 0, 32, 32};
						sprite->m_texture = nullptr;
					}
					else
					{
						Texture* texture = new Texture();
						*texture = loadedTexture;
						sprite->m_texture = texture;
						sprite->m_sourceRect = Rectangle{0, 0, float(texture->width), float(texture->height)};
					}

					borders.push_back(sprite);
					borderSpriteNames.push_back(spriteName);
				}
				else
				{
					// If any border is missing, push null sprite and empty name
					borders.push_back(nullptr);
					borderSpriteNames.push_back("");
				}
			}

			// Store border sprite names for serialization
			m_octagonBoxBorderSprites[id] = borderSpriteNames;

			// Add parent offsets to make position absolute
			int absoluteX = parentX + posx;
			int absoluteY = parentY + posy;

			// Add the octagonbox
			gui->AddOctagonBox(id, absoluteX, absoluteY, width, height, borders, color, group, active);
		}
		else if (type == "stretchbutton")
	{
		// Get width and label
		int width = element.value("width", 100);
		string label = element.value("label", "");
		int indent = element.value("indent", 0);

		// Get color
		Color color = WHITE;
		if (element.contains("color"))
		{
			auto arr = element["color"];
			color = Color{ (unsigned char)arr[0], (unsigned char)arr[1],
			              (unsigned char)arr[2], (unsigned char)arr[3] };
		}

		// Add parent offsets to make position absolute
		int absoluteX = parentX + posx;
		int absoluteY = parentY + posy;

		// Parse sprite definitions and create Sprite objects
		std::shared_ptr<Sprite> leftSprite = nullptr;
		std::shared_ptr<Sprite> centerSprite = nullptr;
		std::shared_ptr<Sprite> rightSprite = nullptr;

		// Helper lambda to parse sprite definition and create Sprite
		auto parseSprite = [&](const string& key) -> std::shared_ptr<Sprite> {
			if (element.contains(key))
			{
				auto spriteObj = element[key];
				if (spriteObj.contains("spritesheet") &&
				    spriteObj.contains("x") && spriteObj.contains("y") &&
				    spriteObj.contains("w") && spriteObj.contains("h"))
				{
					string spritesheet = spriteObj["spritesheet"];
					int x = spriteObj["x"];
					int y = spriteObj["y"];
					int w = spriteObj["w"];
					int h = spriteObj["h"];

					// Load spritesheet texture using ResourceManager
					// Prepend the base sprite path to the spritesheet filename
					string fullSpritePath = s_baseSpritePath + spritesheet;
					Log("GhostSerializer::ParseElements - Attempting to load spritesheet: " + fullSpritePath);
					Texture* texture = g_ResourceManager->GetTexture(fullSpritePath);
					if (texture && texture->id != 0 && texture->width > 0 && texture->height > 0)
					{
						// Create and return Sprite
						Log("GhostSerializer::ParseElements - Successfully loaded " + spritesheet + ", creating sprite at (" + to_string(x) + "," + to_string(y) + ") size " + to_string(w) + "x" + to_string(h));
				return std::make_shared<Sprite>(texture, x, y, w, h);
					}
					else
					{
						Log("GhostSerializer::ParseElements - FAILED to load spritesheet: " + spritesheet + " (texture is invalid or empty), using fallback");
					}
				}
			}
			return nullptr;
		};

		// Helper lambda to create fallback sprite
		auto createFallbackSprite = [&](const string& key) -> std::shared_ptr<Sprite> {
			string fallbackPath = s_baseSpritePath + "image.png";
			Texture* fallbackTexture = g_ResourceManager->GetTexture(fallbackPath);

			if (fallbackTexture && fallbackTexture->id != 0 && fallbackTexture->width > 0 && fallbackTexture->height > 0)
			{
				// Default fallback positions for each sprite type
				if (key == "spriteLeft")
					return std::make_shared<Sprite>(fallbackTexture, 0, 0, 16, 48);
				else if (key == "spriteCenter")
					return std::make_shared<Sprite>(fallbackTexture, 16, 0, 16, 48);
				else if (key == "spriteRight")
					return std::make_shared<Sprite>(fallbackTexture, 32, 0, 16, 48);
			}
			return nullptr;
		};

		// Parse the three sprites, use fallback if load fails
		leftSprite = parseSprite("spriteLeft");
		if (!leftSprite)
			leftSprite = createFallbackSprite("spriteLeft");

		centerSprite = parseSprite("spriteCenter");
		if (!centerSprite)
			centerSprite = createFallbackSprite("spriteCenter");

		rightSprite = parseSprite("spriteRight");
		if (!rightSprite)
			rightSprite = createFallbackSprite("spriteRight");

	// If any sprites still failed to load (even fallback failed), create dummy sprites
	if (!leftSprite || !centerSprite || !rightSprite)
	{
		Log("GhostSerializer::ParseElements - One or more stretchbutton sprites failed to load (including fallback), using dummy placeholders");
		Texture* dummyTexture = g_ResourceManager->GetTexture("image.png");
		if (dummyTexture)
		{
			if (!leftSprite) leftSprite = std::make_shared<Sprite>(dummyTexture, 0, 0, 10, 10);
			if (!centerSprite) centerSprite = std::make_shared<Sprite>(dummyTexture, 0, 0, 10, 10);
			if (!rightSprite) rightSprite = std::make_shared<Sprite>(dummyTexture, 0, 0, 10, 10);
		}
	}

		// Store sprite definitions in metadata
		if (element.contains("spriteLeft"))
		{
			auto spriteObj = element["spriteLeft"];
			SpriteDefinition def;
			def.spritesheet = spriteObj.value("spritesheet", "");
			def.x = spriteObj.value("x", 0);
			def.y = spriteObj.value("y", 0);
			def.w = spriteObj.value("w", 0);
			def.h = spriteObj.value("h", 0);
			SetStretchButtonLeftSprite(id, def);
		}
		if (element.contains("spriteCenter"))
		{
			auto spriteObj = element["spriteCenter"];
			SpriteDefinition def;
			def.spritesheet = spriteObj.value("spritesheet", "");
			def.x = spriteObj.value("x", 0);
			def.y = spriteObj.value("y", 0);
			def.w = spriteObj.value("w", 0);
			def.h = spriteObj.value("h", 0);
			SetStretchButtonCenterSprite(id, def);
		}
		if (element.contains("spriteRight"))
		{
			auto spriteObj = element["spriteRight"];
			SpriteDefinition def;
			def.spritesheet = spriteObj.value("spritesheet", "");
			def.x = spriteObj.value("x", 0);
			def.y = spriteObj.value("y", 0);
			def.w = spriteObj.value("w", 0);
			def.h = spriteObj.value("h", 0);
			SetStretchButtonRightSprite(id, def);
		}

		// Add the stretchbutton
		// Note: The same 3 sprites are reused for both active and inactive states
		gui->AddStretchButton(id, absoluteX, absoluteY, width, label,
		                      leftSprite, rightSprite, centerSprite,
		                      leftSprite, rightSprite, centerSprite,
		                      indent, color, group, active, false);
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

bool GhostSerializer::LoadFromFile(const std::string& filename, Gui* gui)
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

ghost_json GhostSerializer::BuildInheritedProps(int parentElementID) const
{
	ghost_json inheritedProps;

	// Walk up the parent chain to find font properties
	int currentID = parentElementID;
	while (currentID != -1)
	{
		// Get font properties from current ancestor if available
		auto fontIt = m_elementFonts.find(currentID);
		if (fontIt != m_elementFonts.end() && !inheritedProps.contains("font"))
		{
			inheritedProps["font"] = fontIt->second;
			Log("BuildInheritedProps: Inheriting font '" + fontIt->second + "' from ancestor " + std::to_string(currentID));
		}

		auto fontSizeIt = m_elementFontSizes.find(currentID);
		if (fontSizeIt != m_elementFontSizes.end() && !inheritedProps.contains("fontSize"))
		{
			inheritedProps["fontSize"] = fontSizeIt->second;
			Log("BuildInheritedProps: Inheriting fontSize " + std::to_string(fontSizeIt->second) + " from ancestor " + std::to_string(currentID));
		}

		// If we found both properties, we're done
		if (inheritedProps.contains("font") && inheritedProps.contains("fontSize"))
		{
			break;
		}

		// Move up to the next parent using GetParentID
		currentID = GetParentID(currentID);
	}

	return inheritedProps;
}

std::string GhostSerializer::ResolveStringProperty(int elementID, const std::string& propertyName) const
{
	// Check if element has explicit property
	if (propertyName == "font")
	{
		auto it = m_elementFonts.find(elementID);
		if (it != m_elementFonts.end())
		{
			return it->second;
		}
	}

	// Walk up parent chain to find inherited value
	int currentID = GetParentID(elementID);
	while (currentID != -1)
	{
		if (propertyName == "font")
		{
			auto it = m_elementFonts.find(currentID);
			if (it != m_elementFonts.end())
			{
				return it->second;
			}
		}
		currentID = GetParentID(currentID);
	}

	return "";  // Not found
}

int GhostSerializer::ResolveIntProperty(int elementID, const std::string& propertyName, int defaultValue) const
{
	// Check if element has explicit property
	if (propertyName == "fontSize")
	{
		auto it = m_elementFontSizes.find(elementID);
		if (it != m_elementFontSizes.end())
		{
			return it->second;
		}
	}

	// Walk up parent chain to find inherited value
	int currentID = GetParentID(elementID);
	while (currentID != -1)
	{
		if (propertyName == "fontSize")
		{
			auto it = m_elementFontSizes.find(currentID);
			if (it != m_elementFontSizes.end())
			{
				return it->second;
			}
		}
		currentID = GetParentID(currentID);
	}

	return defaultValue;  // Not found, return default
}

bool GhostSerializer::CenterLoadedGUI(Gui* gui, float inputScale)
{
	// Get the original panel size from JSON (not the calculated size from children)
	auto sizeIt = m_panelSizes.find(m_rootElementID);
	if (sizeIt == m_panelSizes.end())
	{
		Log("CenterLoadedGUI: Failed to find panel size for root element ID " + std::to_string(m_rootElementID));
		return false;
	}

	int panelWidth = sizeIt->second.first;
	int panelHeight = sizeIt->second.second;

	Log("CenterLoadedGUI: Root panel size: " + std::to_string(panelWidth) + "x" + std::to_string(panelHeight));

	// Use SetLayout with GUIP_CENTER to center the GUI
	gui->SetLayout(0, 0, panelWidth, panelHeight, inputScale, Gui::GUIP_CENTER);

	return true;
}

bool GhostSerializer::LoadIntoPanel(const std::string& filename, Gui* gui, int parentX, int parentY, int parentElementID, int insertIndex)
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
		ParseElements(j["gui"]["elements"], gui, inheritedProps, parentX, parentY, parentElementID, "", insertIndex);
		return true;
	}

	return false;
}

bool GhostSerializer::SaveToFile(const std::string& filename, Gui* gui)
{
	if (!gui)
	{
		Log("GhostSerializer::SaveToFile - gui is null");
		return false;
	}

	// Check if we have a root element to serialize
	if (m_rootElementID == -1)
	{
		Log("GhostSerializer::SaveToFile - No root element to serialize");
		return false;
	}

	try
	{
		ghost_json j;
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
				Log("GhostSerializer::SaveToFile - Warning: No elements to save");
				// Still save empty elements array
			}
			else if (children.size() > 1)
			{
				Log("GhostSerializer::SaveToFile - Error: Multiple root elements detected (" + std::to_string(children.size()) + " elements)");
				Log("GhostSerializer::SaveToFile - Files must have exactly ONE root element. Use a panel to group multiple elements.");
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
			Log("GhostSerializer::SaveToFile - Could not open file for writing: " + filename);
			return false;
		}

		file << j.dump(2); // Pretty print with 2-space indent
		file.close();

		Log("GhostSerializer::SaveToFile - Successfully saved: " + filename);
		return true;
	}
	catch (const exception& e)
	{
		Log("GhostSerializer::SaveToFile - Exception: " + string(e.what()));
		return false;
	}
}

bool GhostSerializer::SaveSelectedElements(const std::string& filename, Gui* gui, const std::vector<int>& elementIDs)
{
	if (!gui)
	{
		Log("GhostSerializer::SaveSelectedElements - gui is null");
		return false;
	}

	try
	{
		ghost_json j;
		j["gui"]["elements"] = ghost_json::array();

		// Only serialize elements in the provided ID list
		for (int id : elementIDs)
		{
			auto it = gui->m_GuiElementList.find(id);
			if (it == gui->m_GuiElementList.end())
			{
				Log("GhostSerializer::SaveSelectedElements - Element ID " + to_string(id) + " not found");
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
			Log("GhostSerializer::SaveSelectedElements - Could not open file for writing: " + filename);
			return false;
		}

		file << j.dump(2); // Pretty print with 2-space indent
		file.close();

		Log("GhostSerializer::SaveSelectedElements - Successfully saved " + to_string(elementIDs.size()) + " elements to: " + filename);
		return true;
	}
	catch (const exception& e)
	{
		Log("GhostSerializer::SaveSelectedElements - Exception: " + string(e.what()));
		return false;
	}
}

void GhostSerializer::ReflowPanel(int panelID, Gui* gui)
{
	// Get the panel element
	auto panelIt = gui->m_GuiElementList.find(panelID);
	if (panelIt == gui->m_GuiElementList.end() || panelIt->second->m_Type != GUI_PANEL)
		return;

	auto panel = static_cast<GuiPanel*>(panelIt->second.get());

	// Get layout direction, padding, and columns (use getter methods for consistent defaults)
	string layout = GetPanelLayout(panelID);
	int horzPadding = GetPanelHorzPadding(panelID);
	int vertPadding = GetPanelVertPadding(panelID);
	int columns = GetPanelColumns(panelID);

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
	// Calculate the bounding box of ALL children (both floating and non-floating)
	float maxX = 0;
	float maxY = 0;

	for (int childID : childrenIt->second)
	{
		auto childIt = gui->m_GuiElementList.find(childID);
		if (childIt == gui->m_GuiElementList.end())
			continue;

		auto child = childIt->second;

		// Skip children with zero width/height (they haven't been properly initialized)
		if (child->m_Width <= 0 || child->m_Height <= 0)
			continue;

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
	// Only update if we found at least one valid child
	if (maxX > 0 || maxY > 0)
	{
		panel->m_Width = maxX + horzPadding;
		panel->m_Height = maxY + vertPadding;
	}
}

ghost_json GhostSerializer::SerializeElement(int elementID, Gui* gui, int parentX, int parentY, bool forCopy)
{
	auto it = gui->m_GuiElementList.find(elementID);
	if (it == gui->m_GuiElementList.end())
	{
		Log("GhostSerializer::SerializeElement - Element ID " + to_string(elementID) + " not found");
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
		case GUI_CYCLE:
			type = "cycle";
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
		case GUI_LISTBOX:
			type = "listbox";
			break;
		// Add more types as needed
		default:
			Log("GhostSerializer::SerializeElement - Unknown element type: " + to_string(element->m_Type));
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
		elementJson["size"] = { static_cast<int>(panel->m_Width), static_cast<int>(panel->m_Height) };
		elementJson["backgroundColor"] = { panel->m_Color.r, panel->m_Color.g, panel->m_Color.b, panel->m_Color.a };
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
				if (fontIt != m_elementFonts.end() && !fontIt->second.empty())
					elementJson["font"] = fontIt->second;
			}

			if (explicitProps.count("fontSize") > 0)
			{
				auto sizeIt = m_elementFontSizes.find(elementID);
				if (sizeIt != m_elementFontSizes.end() && sizeIt->second > 0)
					elementJson["fontSize"] = sizeIt->second;
			}
		}
	}
	else if (element->m_Type == GUI_TEXTBUTTON)
	{
		auto button = static_cast<GuiTextButton*>(element.get());
		elementJson["text"] = button->m_String;

		if (forCopy)
		{
			// For copy/paste, serialize explicit properties only (let pasted element inherit from its new parent)
			// BUT always include colors since they're stored in the element itself
			auto fontIt = m_elementFonts.find(elementID);
			if (fontIt != m_elementFonts.end())
			{
				elementJson["font"] = fontIt->second;
			}

			auto sizeIt = m_elementFontSizes.find(elementID);
			if (sizeIt != m_elementFontSizes.end())
			{
				elementJson["fontSize"] = sizeIt->second;
			}

			// Always include colors (they're not inherited, they're stored in the element)
			elementJson["textColor"] = { button->m_TextColor.r, button->m_TextColor.g, button->m_TextColor.b, button->m_TextColor.a };
			elementJson["backgroundColor"] = { button->m_BackgroundColor.r, button->m_BackgroundColor.g, button->m_BackgroundColor.b, button->m_BackgroundColor.a };
			elementJson["borderColor"] = { button->m_BorderColor.r, button->m_BorderColor.g, button->m_BorderColor.b, button->m_BorderColor.a };
		}
		else
		{
			// For file save, only serialize properties that were explicitly set (not inherited)
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
				if (fontIt != m_elementFonts.end() && !fontIt->second.empty())
					elementJson["font"] = fontIt->second;
			}

			if (explicitProps.count("fontSize") > 0)
			{
				auto sizeIt = m_elementFontSizes.find(elementID);
				if (sizeIt != m_elementFontSizes.end() && sizeIt->second > 0)
					elementJson["fontSize"] = sizeIt->second;
			}

			if (explicitProps.count("textColor") > 0)
				elementJson["textColor"] = { textarea->m_Color.r, textarea->m_Color.g, textarea->m_Color.b, textarea->m_Color.a };
		}

		// Use standard size array format (both in pixels) to match other elements
		elementJson["size"] = { static_cast<int>(textarea->m_Width), static_cast<int>(textarea->m_Height) };
		elementJson["justified"] = textarea->m_Justified;
	}
	else if (element->m_Type == GUI_TEXTINPUT)
	{
		auto textinput = static_cast<GuiTextInput*>(element.get());
		// Don't save "example" text - it was just added for display purposes
		string textToSave = (textinput->m_String == "example") ? "" : textinput->m_String;
		elementJson["text"] = textToSave;
		elementJson["size"] = { static_cast<int>(textinput->m_Width), static_cast<int>(textinput->m_Height) };

		// Only serialize properties that were explicitly set (not inherited)
		auto explicitIt = m_explicitProperties.find(elementID);
		if (explicitIt != m_explicitProperties.end())
		{
			const auto& explicitProps = explicitIt->second;

			if (explicitProps.count("textColor") > 0)
				elementJson["textColor"] = { textinput->m_TextColor.r, textinput->m_TextColor.g, textinput->m_TextColor.b, textinput->m_TextColor.a };

			// Write as borderColor (preferred) or boxColor (legacy)
			if (explicitProps.count("borderColor") > 0)
				elementJson["borderColor"] = { textinput->m_BoxColor.r, textinput->m_BoxColor.g, textinput->m_BoxColor.b, textinput->m_BoxColor.a };
			else if (explicitProps.count("boxColor") > 0)
				elementJson["boxColor"] = { textinput->m_BoxColor.r, textinput->m_BoxColor.g, textinput->m_BoxColor.b, textinput->m_BoxColor.a };

			if (explicitProps.count("backgroundColor") > 0)
				elementJson["backgroundColor"] = { textinput->m_BackgroundColor.r, textinput->m_BackgroundColor.g, textinput->m_BackgroundColor.b, textinput->m_BackgroundColor.a };
		}
	}
	else if (element->m_Type == GUI_CHECKBOX)
	{
		auto checkbox = static_cast<GuiCheckBox*>(element.get());
		elementJson["size"] = { static_cast<int>(checkbox->m_Width), static_cast<int>(checkbox->m_Height) };
		elementJson["color"] = { checkbox->m_Color.r, checkbox->m_Color.g, checkbox->m_Color.b, checkbox->m_Color.a };
		elementJson["selected"] = checkbox->m_Selected;
		elementJson["scale"] = { checkbox->m_ScaleX, checkbox->m_ScaleY };
	}
	else if (element->m_Type == GUI_RADIOBUTTON)
	{
		auto radio = static_cast<GuiRadioButton*>(element.get());
		elementJson["size"] = { static_cast<int>(radio->m_Width), static_cast<int>(radio->m_Height) };
		elementJson["color"] = { radio->m_Color.r, radio->m_Color.g, radio->m_Color.b, radio->m_Color.a };
		elementJson["selected"] = radio->m_Selected;
		elementJson["scale"] = { radio->m_ScaleX, radio->m_ScaleY };
	}
	else if (element->m_Type == GUI_SPRITE)
	{
		auto sprite = static_cast<GuiSprite*>(element.get());

		// Serialize sprite definition (with x/y/w/h)
		SpriteDefinition spriteDef = GetSprite(elementID);
		if (!spriteDef.IsEmpty())
		{
			elementJson["sprite"] = {
				{"spritesheet", spriteDef.spritesheet},
				{"x", spriteDef.x},
				{"y", spriteDef.y},
				{"w", spriteDef.w},
				{"h", spriteDef.h}
			};
		}

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
	else if (element->m_Type == GUI_CYCLE)
	{
		auto cycle = static_cast<GuiCycle*>(element.get());

		// Serialize sprite definition (with x/y/w/h)
		SpriteDefinition spriteDef = GetSprite(elementID);
		if (!spriteDef.IsEmpty())
		{
			elementJson["sprite"] = {
				{"spritesheet", spriteDef.spritesheet},
				{"x", spriteDef.x},
				{"y", spriteDef.y},
				{"w", spriteDef.w},
				{"h", spriteDef.h}
			};
		}

		elementJson["frameCount"] = cycle->m_FrameCount;
		elementJson["scaleX"] = cycle->m_ScaleX;
		elementJson["scaleY"] = cycle->m_ScaleY;

		// Only serialize color if explicitly set (not inherited)
		auto explicitIt = m_explicitProperties.find(elementID);
		if (explicitIt != m_explicitProperties.end())
		{
			const auto& explicitProps = explicitIt->second;
			if (explicitProps.count("color") > 0)
				elementJson["color"] = { cycle->m_Color.r, cycle->m_Color.g, cycle->m_Color.b, cycle->m_Color.a };
		}
	}
	else if (element->m_Type == GUI_SCROLLBAR)
	{
		auto scrollbar = static_cast<GuiScrollBar*>(element.get());
		elementJson["valueRange"] = scrollbar->m_ValueRange;
		elementJson["size"] = { static_cast<int>(scrollbar->m_Width), static_cast<int>(scrollbar->m_Height) };
		elementJson["vertical"] = scrollbar->m_Vertical;
		elementJson["spurColor"] = { scrollbar->m_SpurColor.r, scrollbar->m_SpurColor.g, scrollbar->m_SpurColor.b, scrollbar->m_SpurColor.a };
		elementJson["backgroundColor"] = { scrollbar->m_BackgroundColor.r, scrollbar->m_BackgroundColor.g, scrollbar->m_BackgroundColor.b, scrollbar->m_BackgroundColor.a };
	}
	else if (element->m_Type == GUI_ICONBUTTON)
	{
		auto iconbutton = static_cast<GuiIconButton*>(element.get());

		// Serialize sprite definition (with x/y/w/h)
		SpriteDefinition spriteDef = GetSprite(elementID);
		if (!spriteDef.IsEmpty())
		{
			elementJson["sprite"] = {
				{"spritesheet", spriteDef.spritesheet},
				{"x", spriteDef.x},
				{"y", spriteDef.y},
				{"w", spriteDef.w},
				{"h", spriteDef.h}
			};
		}

		// Serialize down sprite definition (optional)
		SpriteDefinition downSpriteDef = GetIconButtonDownSprite(elementID);
		if (!downSpriteDef.IsEmpty())
		{
			elementJson["downSprite"] = {
				{"spritesheet", downSpriteDef.spritesheet},
				{"x", downSpriteDef.x},
				{"y", downSpriteDef.y},
				{"w", downSpriteDef.w},
				{"h", downSpriteDef.h}
			};
		}

		if (!iconbutton->m_String.empty())
			elementJson["text"] = iconbutton->m_String;
		elementJson["color"] = { iconbutton->m_FontColor.r, iconbutton->m_FontColor.g, iconbutton->m_FontColor.b, iconbutton->m_FontColor.a };
		elementJson["scale"] = iconbutton->m_Scale;
		if (iconbutton->m_CanBeHeld)
			elementJson["canBeHeld"] = iconbutton->m_CanBeHeld;

		// Serialize font/fontSize if explicitly set
		auto explicitIt = m_explicitProperties.find(elementID);
		if (explicitIt != m_explicitProperties.end())
		{
			const auto& explicitProps = explicitIt->second;

			if (explicitProps.count("font") > 0)
			{
				auto fontIt = m_elementFonts.find(elementID);
				if (fontIt != m_elementFonts.end() && !fontIt->second.empty())
					elementJson["font"] = fontIt->second;
			}

			if (explicitProps.count("fontSize") > 0)
			{
				auto sizeIt = m_elementFontSizes.find(elementID);
				if (sizeIt != m_elementFontSizes.end() && sizeIt->second > 0)
					elementJson["fontSize"] = sizeIt->second;
			}
		}
	}
	else if (element->m_Type == GUI_OCTAGONBOX)
	{
		auto octagonbox = static_cast<GuiOctagonBox*>(element.get());
		elementJson["size"] = { static_cast<int>(octagonbox->m_Width), static_cast<int>(octagonbox->m_Height) };
		elementJson["color"] = { octagonbox->m_Color.r, octagonbox->m_Color.g, octagonbox->m_Color.b, octagonbox->m_Color.a };

		// Serialize border sprites if they exist
		auto borderIt = m_octagonBoxBorderSprites.find(elementID);
		if (borderIt != m_octagonBoxBorderSprites.end())
		{
			const vector<string>& borderNames = borderIt->second;
			const char* jsonBorderNames[] = {
				"borderTopLeft", "borderTop", "borderTopRight",
				"borderLeft", "borderCenter", "borderRight",
				"borderBottomLeft", "borderBottom", "borderBottomRight"
			};

			for (int i = 0; i < 9 && i < borderNames.size(); i++)
			{
				if (!borderNames[i].empty())
				{
					elementJson[jsonBorderNames[i]] = borderNames[i];
				}
			}
		}
	}
	else if (element->m_Type == GUI_STRETCHBUTTON)
	{
		auto stretchbutton = static_cast<GuiStretchButton*>(element.get());
		elementJson["width"] = stretchbutton->m_Width;
		elementJson["label"] = stretchbutton->m_String;
		elementJson["indent"] = stretchbutton->m_Indent;
		elementJson["color"] = { stretchbutton->m_Color.r, stretchbutton->m_Color.g, stretchbutton->m_Color.b, stretchbutton->m_Color.a };

		// Serialize sprite definitions (3 sprites, reused for active and inactive states)
		SpriteDefinition leftSprite = GetStretchButtonLeftSprite(elementID);
		SpriteDefinition centerSprite = GetStretchButtonCenterSprite(elementID);
		SpriteDefinition rightSprite = GetStretchButtonRightSprite(elementID);

		if (!leftSprite.IsEmpty())
		{
			elementJson["spriteLeft"] = {
				{"spritesheet", leftSprite.spritesheet},
				{"x", leftSprite.x},
				{"y", leftSprite.y},
				{"w", leftSprite.w},
				{"h", leftSprite.h}
			};
		}
		if (!centerSprite.IsEmpty())
		{
			elementJson["spriteCenter"] = {
				{"spritesheet", centerSprite.spritesheet},
				{"x", centerSprite.x},
				{"y", centerSprite.y},
				{"w", centerSprite.w},
				{"h", centerSprite.h}
			};
		}
		if (!rightSprite.IsEmpty())
		{
			elementJson["spriteRight"] = {
				{"spritesheet", rightSprite.spritesheet},
				{"x", rightSprite.x},
				{"y", rightSprite.y},
				{"w", rightSprite.w},
				{"h", rightSprite.h}
			};
		}
	}
	else if (element->m_Type == GUI_LIST)
	{
		auto list = static_cast<GuiList*>(element.get());
		elementJson["size"] = { static_cast<int>(list->m_Width), static_cast<int>(list->m_Height) };
		elementJson["items"] = list->m_Items;
		elementJson["textColor"] = { list->m_TextColor.r, list->m_TextColor.g, list->m_TextColor.b, list->m_TextColor.a };
		elementJson["backgroundColor"] = { list->m_BackgroundColor.r, list->m_BackgroundColor.g, list->m_BackgroundColor.b, list->m_BackgroundColor.a };
		elementJson["borderColor"] = { list->m_BorderColor.r, list->m_BorderColor.g, list->m_BorderColor.b, list->m_BorderColor.a };

		// Serialize font/fontSize if explicitly set
		auto explicitIt = m_explicitProperties.find(elementID);
		if (explicitIt != m_explicitProperties.end())
		{
			const auto& explicitProps = explicitIt->second;

			if (explicitProps.count("font") > 0)
			{
				auto fontIt = m_elementFonts.find(elementID);
				if (fontIt != m_elementFonts.end() && !fontIt->second.empty())
					elementJson["font"] = fontIt->second;
			}

			if (explicitProps.count("fontSize") > 0)
			{
				auto sizeIt = m_elementFontSizes.find(elementID);
				if (sizeIt != m_elementFontSizes.end() && sizeIt->second > 0)
					elementJson["fontSize"] = sizeIt->second;
			}
		}
	}
	else if (element->m_Type == GUI_LISTBOX)
	{
		auto listbox = static_cast<GuiListBox*>(element.get());
		elementJson["size"] = { static_cast<int>(listbox->m_Width), static_cast<int>(listbox->m_Height) };
		elementJson["items"] = listbox->m_Items;
		elementJson["textColor"] = { listbox->m_TextColor.r, listbox->m_TextColor.g, listbox->m_TextColor.b, listbox->m_TextColor.a };
		elementJson["backgroundColor"] = { listbox->m_BackgroundColor.r, listbox->m_BackgroundColor.g, listbox->m_BackgroundColor.b, listbox->m_BackgroundColor.a };
		elementJson["borderColor"] = { listbox->m_BorderColor.r, listbox->m_BorderColor.g, listbox->m_BorderColor.b, listbox->m_BorderColor.a };

		// Serialize font/fontSize if explicitly set
		auto explicitIt = m_explicitProperties.find(elementID);
		if (explicitIt != m_explicitProperties.end())
		{
			const auto& explicitProps = explicitIt->second;

			if (explicitProps.count("font") > 0)
			{
				auto fontIt = m_elementFonts.find(elementID);
				if (fontIt != m_elementFonts.end() && !fontIt->second.empty())
					elementJson["font"] = fontIt->second;
			}

			if (explicitProps.count("fontSize") > 0)
			{
				auto sizeIt = m_elementFontSizes.find(elementID);
				if (sizeIt != m_elementFontSizes.end() && sizeIt->second > 0)
					elementJson["fontSize"] = sizeIt->second;
			}
		}
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
			// Check if this child represents an include
			auto includeIt = m_includeElements.find(childID);
			if (includeIt != m_includeElements.end())
			{
				// Serialize as an include instead of expanding the element
				ghost_json includeJson;
				includeJson["type"] = "include";
				includeJson["filename"] = includeIt->second.filename;
				if (!includeIt->second.namePrefix.empty())
				{
					includeJson["namePrefix"] = includeIt->second.namePrefix;
				}
				elementJson["elements"].push_back(includeJson);
				Log("Serialized element " + to_string(childID) + " as include: " + includeIt->second.filename);
			}
			else
			{
				// Normal child - serialize recursively
				// Pass this element's position as the parent position for children
				ghost_json childJson = SerializeElement(childID, gui, element->m_Pos.x, element->m_Pos.y);
				if (!childJson.is_null())
				{
					elementJson["elements"].push_back(childJson);
				}
			}
		}
	}

	return elementJson;
}

std::vector<int> GhostSerializer::GetAllElementIDs() const
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

// StretchButton sprite definition getter/setter implementations
void GhostSerializer::SetStretchButtonLeftSprite(int buttonID, const SpriteDefinition& sprite)
{
	m_stretchButtonLeftSprites[buttonID] = sprite;
}

void GhostSerializer::SetStretchButtonCenterSprite(int buttonID, const SpriteDefinition& sprite)
{
	m_stretchButtonCenterSprites[buttonID] = sprite;
}

void GhostSerializer::SetStretchButtonRightSprite(int buttonID, const SpriteDefinition& sprite)
{
	m_stretchButtonRightSprites[buttonID] = sprite;
}

GhostSerializer::SpriteDefinition GhostSerializer::GetStretchButtonLeftSprite(int buttonID) const
{
	auto it = m_stretchButtonLeftSprites.find(buttonID);
	return (it != m_stretchButtonLeftSprites.end()) ? it->second : SpriteDefinition();
}

GhostSerializer::SpriteDefinition GhostSerializer::GetStretchButtonCenterSprite(int buttonID) const
{
	auto it = m_stretchButtonCenterSprites.find(buttonID);
	return (it != m_stretchButtonCenterSprites.end()) ? it->second : SpriteDefinition();
}

GhostSerializer::SpriteDefinition GhostSerializer::GetStretchButtonRightSprite(int buttonID) const
{
	auto it = m_stretchButtonRightSprites.find(buttonID);
	return (it != m_stretchButtonRightSprites.end()) ? it->second : SpriteDefinition();
}

// Helper function to load font with inheritance support
Font* GhostSerializer::LoadFontWithInheritance(const ghost_json& element, const ghost_json& inheritedProps, int elementID, std::string& outFontName, int& outFontSize)
{
	// Get font name - check element first, then inherited
	outFontName = "";
	bool fontIsExplicit = false;

	if (element.contains("font"))
	{
		outFontName = element["font"].get<std::string>();
		// Only mark as explicit if non-empty
		if (!outFontName.empty())
		{
			m_explicitProperties[elementID].insert("font");
			m_elementFonts[elementID] = outFontName;
			fontIsExplicit = true;
		}
	}

	// If no valid explicit font, try inherited
	if (!fontIsExplicit && !inheritedProps.is_null() && inheritedProps.contains("font"))
	{
		outFontName = inheritedProps["font"].get<std::string>();
	}

	// Get font size - check element first, then inherited
	outFontSize = 20;  // default
	bool fontSizeIsExplicit = false;

	if (element.contains("fontSize"))
	{
		outFontSize = element["fontSize"].get<int>();
		// Only mark as explicit if valid (> 0)
		if (outFontSize > 0)
		{
			m_explicitProperties[elementID].insert("fontSize");
			m_elementFontSizes[elementID] = outFontSize;
			fontSizeIsExplicit = true;
		}
	}

	// If no valid explicit fontSize, try inherited
	if (!fontSizeIsExplicit && !inheritedProps.is_null() && inheritedProps.contains("fontSize"))
	{
		outFontSize = inheritedProps["fontSize"].get<int>();
	}

	// Load the font file
	Font font;
	if (!outFontName.empty())
	{
		std::string fontPath = s_baseFontPath + outFontName;
		font = LoadFontEx(fontPath.c_str(), outFontSize, 0, 0);
		if (font.texture.id == 0)
		{
			Log("GhostSerializer::LoadFontWithInheritance - Failed to load font: " + fontPath + ", using default");
			font = GetFontDefault();
		}
		else
		{
			Log("GhostSerializer::LoadFontWithInheritance - Loaded font '" + fontPath + "' at size " + std::to_string(outFontSize));
		}
	}
	else
	{
		// No font specified, use default
		font = GetFontDefault();
	}

	// Store font in shared_ptr to keep it alive
	auto fontPtr = std::make_shared<Font>(font);
	m_loadedFonts.push_back(fontPtr);
	return fontPtr.get();
}
