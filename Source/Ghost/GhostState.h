#ifndef _GHOSTSTATE_H_
#define _GHOSTSTATE_H_

#include "../Geist/State.h"
#include "../Geist/Gui.h"
#include "GhostSerializer.h"
#include <memory>

class GhostState : public State
{
public:
	GhostState() {};
	~GhostState();

	void Init(const std::string& configfile) override;
	void Shutdown() override;
	void Update() override;
	void Draw() override;
	void OnEnter() override;
	void OnExit() override;

private:
	void LoadGhostFile(const std::string& filepath);
	void SaveGhostFile();
	void ClearLoadedContent();
	void EnsureContentRoot();  // Create root container if it doesn't exist
	void InsertPanel();
	void InsertLabel();
	void InsertButton();
	void InsertIconButton();
	void InsertSprite();
	void InsertCycle();
	void InsertTextInput();
	void InsertCheckbox();
	void InsertRadioButton();
	void InsertScrollBar();
	void InsertOctagonBox();
	void InsertStretchButton();
	void InsertList();
	void InsertListBox();
	void InsertFileInclude();

private:
	// Helper functions for Insert operations
	struct InsertContext {
		int newID;
		int parentID;
		int absoluteX;
		int absoluteY;
	};

	InsertContext PrepareInsert(const std::string& elementTypeName);
	void FinalizeInsert(int newID, int parentID, const std::string& elementTypeName, bool isFloating = true);

	// Get inherited font from parent element (returns nullptr if no inherited font)
	Font* GetInheritedFont(int parentID, int& outFontSize, std::string& outFontName);

	// Helper functions for property tracking
	bool TrackPropertyValue(int activeID, const std::string& propertyName, std::string& lastValue);
	bool CheckPropertyChanged(int activeID, const std::string& propertyName, std::string& lastValue);
	bool CheckScrollbarChanged(const std::string& propertyName, int& lastValue);
	bool CheckCheckboxChanged(const std::string& propertyName, bool& lastValue);

	// Generic color property helpers
	Color GetElementColor(GuiElement* element, const std::string& propertyName);
	void SetElementColor(GuiElement* element, const std::string& propertyName, Color color);
	void UpdateColorButton(const std::string& buttonPropertyName, Color color);

public:

	std::unique_ptr<Gui> m_gui;
	std::shared_ptr<Font> m_guiFont;
	std::unique_ptr<GhostSerializer> m_serializer; // For main app layout (menu, etc.)
	std::unique_ptr<GhostSerializer> m_contentSerializer; // For loaded content files
	std::unique_ptr<GhostSerializer> m_propertySerializer; // For property panel (ID 3000+)
	std::string m_loadedGhostFile; // Track currently loaded file
	std::vector<std::shared_ptr<Font>> m_preservedFonts; // Keep fonts alive across multiple loads
	int m_selectedElementID; // Currently selected element in content panel (-1 = none)
	int m_lastPropertyElementType; // Track last element type shown in property panel (-1 = none)

	// Track which color property button was clicked (e.g., "PROPERTY_TEXTCOLOR", "PROPERTY_BACKGROUNDCOLOR")
	std::string m_editingColorProperty;

	// Track which sprite property button was clicked (e.g., "PROPERTY_SPRITE_LEFT", "PROPERTY_SPRITE_CENTER", "PROPERTY_SPRITE_RIGHT")
	std::string m_editingSpriteProperty;

	// Track if we're waiting for font picker results from FileChooserState
	bool m_waitingForFontPicker = false;

	// Double-click detection for toggling floating/positioned state
	double m_lastClickTime = 0.0;
	int m_lastClickedElementID = -1;
	static constexpr double DOUBLE_CLICK_TIME = 0.3; // 300ms for double-click

	// Drag-and-drop for positioned controls
	bool m_isDragging = false;
	int m_dragElementID = -1;
	Vector2 m_dragStartMousePos = { 0, 0 };
	Vector2 m_dragStartElementPos = { 0, 0 };

	// Content panel zoom support
	float m_contentZoom = 1.0f; // Current zoom level (1.0 = 100%, 2.0 = 200%, etc.)
	static constexpr float MIN_ZOOM = 0.5f; // Minimum 50% zoom
	static constexpr float MAX_ZOOM = 4.0f;  // Maximum 400% zoom
	static constexpr float ZOOM_STEP = 0.1f; // Zoom in/out by 10% per wheel tick

	// Element hierarchy listbox support
	std::vector<int> m_elementIDList; // Parallel list of element IDs for listbox index mapping
	void PopulateElementHierarchy(); // Populate the element hierarchy listbox
	void UpdateElementHierarchySelection(); // Update listbox selection to match selected element
	std::string GetTypeName(int elementType); // Get display name for element type

	// Generic property helpers
	int GetElementGroup(GuiElement* element);
	void SetElementGroup(GuiElement* element, int group);
	void PopulateGroupProperty(GuiElement* selectedElement);
	bool UpdateGroupProperty(GuiElement* selectedElement);

	// Generic scrollbar property helpers
	void PopulateScrollbarProperty(const std::string& propertyName, int value);
	bool UpdateScrollbarProperty(const std::string& propertyName, int& outValue);

	// Generic text input property helpers
	void PopulateTextInputProperty(const std::string& propertyName, const std::string& value);
	bool UpdateTextInputProperty(const std::string& propertyName, std::string& outValue);

	// Generic checkbox property helpers
	void PopulateCheckboxProperty(const std::string& propertyName, bool value);
	bool UpdateCheckboxProperty(const std::string& propertyName, bool& outValue);

	// Name property has special serializer management logic
	bool UpdateNameProperty();

	// Generic font property helpers (for elements that have fonts)
	void PopulateFontProperty();
	void PopulateFontSizeProperty();
	bool UpdateFontProperty();
	bool UpdateFontSizeProperty();

	// Control-type-specific font update helpers
	void UpdateTextButtonFont(GuiTextButton* button, Font* font);
	void UpdateIconButtonFont(GuiIconButton* button, Font* font);
	void UpdateTextInputFont(GuiTextInput* input, Font* font);
	void UpdateTextAreaFont(GuiTextArea* textarea, Font* font);
	void UpdateListFont(GuiList* list, Font* font);
	void UpdateListBoxFont(GuiListBox* listbox, Font* font);
	void UpdatePanelFont(GuiPanel* panel, Font* font, int panelID);
	void ApplyFontToElement(int elementID, Font* fontPtr);

	// Generic width/height property helpers
	bool UpdateWidthProperty(GuiElement* element);
	bool UpdateHeightProperty(GuiElement* element);

	// Generic helper to read int value from textinput or scrollbar
	bool ReadIntProperty(const std::string& propertyName, int& outValue);

	// Generic helper to populate int property (textinput or scrollbar)
	void PopulateIntProperty(const std::string& propertyName, int value);

	// Resource paths from config
	std::string m_fontPath; // Base path for fonts
	std::string m_spritePath; // Base path for sprites

	// Clipboard support
	ghost_json m_clipboard; // Stores copied element JSON
	bool m_hasClipboard; // Track if clipboard has valid data

	// Undo/redo support
	std::vector<ghost_json> m_undoStack; // Stack of previous states
	std::vector<ghost_json> m_redoStack; // Stack of undone states
	static const size_t MAX_UNDO_LEVELS = 50; // Maximum undo history
	void PushUndoState(); // Save current state to undo stack
	void Undo(); // Restore previous state
	void Redo(); // Restore next state from redo stack
	void UpdatePropertyPanel(); // Reload property panel based on selected element
	void ClearPropertyPanel(); // Clear all property panel elements
	void PopulatePropertyPanelFields(); // Populate property panel fields with selected element's data
	void UpdateElementFromPropertyPanel(); // Update selected element from property panel changes
	void UpdateStatusFooter(); // Update status footer with selected element info
	std::string GetElementName(int elementID); // Get element name by ID from content serializer
};

#endif
