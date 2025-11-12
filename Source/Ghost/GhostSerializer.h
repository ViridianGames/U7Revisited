#ifndef _GHOSTSERIALIZER_H_
#define _GHOSTSERIALIZER_H_

#include <string>
#include <memory>
#include <algorithm>
#include <set>
#include "../Geist/Gui.h"
#include "../../ThirdParty/nlohmann/json.hpp"

// Use ordered_json to preserve property insertion order in output files
using ghost_json = nlohmann::ordered_json;

class GhostSerializer
{
public:
	GhostSerializer();
	~GhostSerializer();

	// Set the base font path (e.g., "Fonts/")
	static void SetBaseFontPath(const std::string& path);

	// Set the base sprite path (e.g., "Images/")
	static void SetBaseSpritePath(const std::string& path);

	// Get the base sprite path
	static std::string GetBaseSpritePath() { return s_baseSpritePath; }

	// Set the base Ghost GUI path (e.g., "Gui/Ghost/")
	static void SetBaseGhostPath(const std::string& path);

	// Get the base Ghost GUI path
	static std::string GetBaseGhostPath() { return s_baseGhostPath; }

	// Load a GUI from a .ghost JSON file
	bool LoadFromFile(const std::string& filename, Gui* gui);

	// Save a GUI to a .ghost JSON file
	bool SaveToFile(const std::string& filename, Gui* gui);

	// Save only selected elements to a .ghost JSON file
	bool SaveSelectedElements(const std::string& filename, Gui* gui, const std::vector<int>& elementIDs);

	// Read JSON from file (returns empty json on error)
	ghost_json ReadJsonFromFile(const std::string& filename);

	// Parse JSON and create GUI elements
	bool ParseJson(const ghost_json& j, Gui* gui);

	// Get loaded fonts (to keep them alive)
	std::vector<std::shared_ptr<Font>>& GetLoadedFonts() { return m_loadedFonts; }

	// Get element ID by name (returns -1 if not found)
	int GetElementID(const std::string& name) const;

	// Load elements from a file and add them at a specific parent position
	// parentElementID specifies which element should be the parent (-1 for root level)
	bool LoadIntoPanel(const std::string& filename, Gui* gui, int parentX, int parentY, int parentElementID = -1);

	// Get the current auto-ID counter value (for tracking loaded content)
	int GetNextAutoID() const { return m_nextAutoID; }

	// Set the starting value for auto-generated IDs
	void SetAutoIDStart(int startID) { m_nextAutoID = startID; }

	// Dirty flag management
	bool IsDirty() const { return m_dirty; }
	void SetDirty(bool dirty) { m_dirty = dirty; }

	// Register an element as a child of the root (for manually inserted elements)
	void RegisterChildElement(int childID)
	{
		if (m_rootElementID != -1)
			m_childrenMap[m_rootElementID].push_back(childID);
	}

	// Register an element as a child of a specific parent
	void RegisterChildOfParent(int parentID, int childID)
	{
		m_childrenMap[parentID].push_back(childID);
	}

	// Reflow floating children of a panel
	void ReflowPanel(int panelID, Gui* gui);

	// Remove an element from its parent's children list
	void UnregisterChild(int childID)
	{
		for (auto& pair : m_childrenMap)
		{
			auto& children = pair.second;
			auto it = std::find(children.begin(), children.end(), childID);
			if (it != children.end())
			{
				children.erase(it);
				return;
			}
		}
	}

	// Get the parent ID of an element (returns -1 if not found)
	int GetParentID(int elementID) const
	{
		for (const auto& pair : m_childrenMap)
		{
			const std::vector<int>& children = pair.second;
			if (std::find(children.begin(), children.end(), elementID) != children.end())
			{
				return pair.first;
			}
		}
		return -1;
	}

	// Get the root element ID
	int GetRootElementID() const { return m_rootElementID; }

	// Set the root element ID (for manually creating a root container)
	void SetRootElementID(int rootID) { m_rootElementID = rootID; }

	// Get all element IDs in the tree (including root and all descendants)
	std::vector<int> GetAllElementIDs() const;

	// Panel layout metadata methods
	void SetPanelLayout(int panelID, const std::string& layout) { m_panelLayouts[panelID] = layout; }
	std::string GetPanelLayout(int panelID) const
	{
		auto it = m_panelLayouts.find(panelID);
		return (it != m_panelLayouts.end()) ? it->second : "horz";
	}

	// Panel horizontal/vertical padding metadata methods
	void SetPanelHorzPadding(int panelID, int padding) { m_panelHorzPaddings[panelID] = padding; }
	int GetPanelHorzPadding(int panelID) const
	{
		auto it = m_panelHorzPaddings.find(panelID);
		return (it != m_panelHorzPaddings.end()) ? it->second : 5;  // Default 5px padding
	}

	void SetPanelVertPadding(int panelID, int padding) { m_panelVertPaddings[panelID] = padding; }
	int GetPanelVertPadding(int panelID) const
	{
		auto it = m_panelVertPaddings.find(panelID);
		return (it != m_panelVertPaddings.end()) ? it->second : 5;  // Default 5px padding
	}

	// Panel columns metadata methods (for table layout)
	void SetPanelColumns(int panelID, int columns) { m_panelColumns[panelID] = columns; }
	int GetPanelColumns(int panelID) const
	{
		auto it = m_panelColumns.find(panelID);
		return (it != m_panelColumns.end()) ? it->second : 2;  // Default 2 columns
	}

	// Sprite definition structure (used by all sprite-based elements)
	struct SpriteDefinition
	{
		std::string spritesheet;
		int x = 0;
		int y = 0;
		int w = 0;
		int h = 0;

		bool IsEmpty() const { return spritesheet.empty(); }
	};

	// Unified sprite metadata methods (for GuiSprite and IconButton)
	void SetSprite(int elementID, const SpriteDefinition& sprite) { m_spriteDefinitions[elementID] = sprite; }
	SpriteDefinition GetSprite(int elementID) const
	{
		auto it = m_spriteDefinitions.find(elementID);
		if (it != m_spriteDefinitions.end())
			return it->second;
		// Return default fallback
		return SpriteDefinition{"image.png", 0, 0, 48, 48};
	}

	// Legacy compatibility methods (deprecated - use SetSprite/GetSprite instead)
	void SetSpriteName(int spriteID, const std::string& filename)
	{
		SpriteDefinition def = GetSprite(spriteID);
		def.spritesheet = filename;
		SetSprite(spriteID, def);
	}
	std::string GetSpriteName(int spriteID) const
	{
		return GetSprite(spriteID).spritesheet;
	}

	// StretchButton sprite metadata methods
	void SetStretchButtonLeftSprite(int buttonID, const SpriteDefinition& sprite);
	void SetStretchButtonCenterSprite(int buttonID, const SpriteDefinition& sprite);
	void SetStretchButtonRightSprite(int buttonID, const SpriteDefinition& sprite);

	SpriteDefinition GetStretchButtonLeftSprite(int buttonID) const;
	SpriteDefinition GetStretchButtonCenterSprite(int buttonID) const;
	SpriteDefinition GetStretchButtonRightSprite(int buttonID) const;

	// Font metadata methods
	void SetElementFont(int elementID, const std::string& fontName)
	{
		m_elementFonts[elementID] = fontName;
		m_explicitProperties[elementID].insert("font");
	}
	std::string GetElementFont(int elementID) const
	{
		auto it = m_elementFonts.find(elementID);
		return (it != m_elementFonts.end()) ? it->second : "";
	}
	void ClearElementFont(int elementID)
	{
		m_elementFonts.erase(elementID);
		auto it = m_explicitProperties.find(elementID);
		if (it != m_explicitProperties.end())
		{
			it->second.erase("font");
		}
	}

	void SetElementFontSize(int elementID, int fontSize)
	{
		m_elementFontSizes[elementID] = fontSize;
		m_explicitProperties[elementID].insert("fontSize");
	}
	int GetElementFontSize(int elementID) const
	{
		auto it = m_elementFontSizes.find(elementID);
		return (it != m_elementFontSizes.end()) ? it->second : 0;  // 0 means not set
	}
	void ClearElementFontSize(int elementID)
	{
		m_elementFontSizes.erase(elementID);
		auto it = m_explicitProperties.find(elementID);
		if (it != m_explicitProperties.end())
		{
			it->second.erase("fontSize");
		}
	}

	// Property metadata methods
	void MarkPropertyAsExplicit(int elementID, const std::string& propertyName)
	{
		m_explicitProperties[elementID].insert(propertyName);
	}

	bool IsPropertyExplicit(int elementID, const std::string& propertyName) const
	{
		auto it = m_explicitProperties.find(elementID);
		if (it == m_explicitProperties.end())
			return false;
		return it->second.count(propertyName) > 0;
	}

	// Floating element methods
	void SetFloating(int elementID, bool floating)
	{
		if (floating)
			m_floatingElements.insert(elementID);
		else
			m_floatingElements.erase(elementID);
	}
	bool IsFloating(int elementID) const
	{
		return m_floatingElements.find(elementID) != m_floatingElements.end();
	}

	// Calculate the next position for a floating element within a parent
	// Returns the position where the next floating element should be placed
	std::pair<int, int> CalculateNextFloatingPosition(int parentID, Gui* gui) const;

	// Element name management
	const std::map<std::string, int>& GetElementNameToIDMap() const { return m_elementNameToID; }
	void SetElementName(const std::string& name, int id) { m_elementNameToID[name] = id; }
	void RemoveElementName(const std::string& name) { m_elementNameToID.erase(name); }

	// Build inherited properties JSON from a parent element (for both loading and dynamic insertion)
	// Returns a JSON object with properties that children should inherit (font, fontSize, etc.)
	ghost_json BuildInheritedProps(int parentElementID) const;

	// Resolve a property value by checking the element first, then walking up the parent chain
	// Returns the property value if found, or empty string if not found
	// This is used to get the actual runtime value of a property (explicit or inherited)
	std::string ResolveStringProperty(int elementID, const std::string& propertyName) const;
	int ResolveIntProperty(int elementID, const std::string& propertyName, int defaultValue = 0) const;

	// Serialize an element and its children to JSON (for clipboard/undo support)
	// parentX and parentY are the parent's absolute position (for calculating relative positions)
	// forCopy: if true, serialize ALL current properties (for copy/paste); if false, only serialize explicit properties (for file save)
	ghost_json SerializeElement(int elementID, Gui* gui, int parentX = 0, int parentY = 0, bool forCopy = false);

private:
	// Helper function to recursively parse elements with property inheritance
	// parentX and parentY track the cumulative offset from nested parents
	// parentElementID tracks the parent in the tree structure (-1 for root level)
	// namePrefix is prepended to all element names (used for includes to avoid name collisions)
	void ParseElements(const ghost_json& elementsArray, Gui* gui, const ghost_json& inheritedProps = ghost_json(), int parentX = 0, int parentY = 0, int parentElementID = -1, const std::string& namePrefix = "");

	// Helper function to load font with inheritance support
	// Returns the loaded Font pointer (owned by m_loadedFonts)
	// Tracks explicit font/fontSize properties only if non-empty/valid
	// outFontName and outFontSize are populated with the resolved values
	Font* LoadFontWithInheritance(const ghost_json& element, const ghost_json& inheritedProps, int elementID, std::string& outFontName, int& outFontSize);

	// Storage for loaded fonts to keep them alive
	std::vector<std::shared_ptr<Font>> m_loadedFonts;

	// Map element names to IDs for easy lookup
	std::map<std::string, int> m_elementNameToID;

	// Auto-incrementing ID counter for generating unique IDs
	int m_nextAutoID = 1000;

	// Dirty flag to track if content has been modified
	bool m_dirty = false;

	// Track the root element ID and tree structure
	int m_rootElementID = -1;
	std::map<int, std::vector<int>> m_childrenMap;  // Maps parent ID -> child IDs

	// Panel layout metadata (since Geist GuiPanel doesn't have this property)
	std::map<int, std::string> m_panelLayouts;  // Maps panel ID -> layout ("horz", "vert", or "table")
	std::map<int, int> m_panelHorzPaddings;  // Maps panel ID -> horizontal padding in pixels
	std::map<int, int> m_panelVertPaddings;  // Maps panel ID -> vertical padding in pixels
	std::map<int, int> m_panelColumns;  // Maps panel ID -> number of columns (for table layout)

	// Sprite metadata (full sprite definition with x/y/w/h)
	std::map<int, SpriteDefinition> m_spriteDefinitions;  // Maps sprite/iconbutton ID -> full sprite definition

	// StretchButton sprite metadata (3 sprite definitions per button)
	std::map<int, SpriteDefinition> m_stretchButtonLeftSprites;    // Maps stretchbutton ID -> left sprite definition
	std::map<int, SpriteDefinition> m_stretchButtonCenterSprites;  // Maps stretchbutton ID -> center sprite definition
	std::map<int, SpriteDefinition> m_stretchButtonRightSprites;   // Maps stretchbutton ID -> right sprite definition

	// OctagonBox sprite metadata (9 border sprite names per octagonbox)
	std::map<int, std::vector<std::string>> m_octagonBoxBorderSprites;  // Maps octagonbox ID -> 9 sprite names

	// Floating element tracking (elements that should use automatic layout)
	std::set<int> m_floatingElements;  // Set of element IDs that are floating

	// Track which properties were explicitly set in JSON (vs inherited)
	std::map<int, std::set<std::string>> m_explicitProperties;  // Maps element ID -> set of property names

	// Store values for properties that we need to serialize (can't be extracted from runtime objects)
	std::map<int, std::string> m_elementFonts;  // Maps element ID -> font name
	std::map<int, int> m_elementFontSizes;  // Maps element ID -> font size

	// Static base paths for resources
	static std::string s_baseFontPath;
	static std::string s_baseSpritePath;
	static std::string s_baseGhostPath;
};

#endif
