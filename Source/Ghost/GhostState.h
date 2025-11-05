#ifndef _GHOSTSTATE_H_
#define _GHOSTSTATE_H_

#include "../Geist/State.h"
#include "../Geist/Gui.h"
#include "GuiSerializer.h"
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
	void InsertTextInput();
	void InsertCheckbox();
	void InsertRadioButton();
	void InsertScrollBar();
	void InsertSlider();
	void InsertOctagonBox();
	void InsertStretchButton();
	void InsertList();
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
	Font* GetInheritedFont(int parentID, int& outFontSize);

	// Helper functions for property tracking
	bool TrackPropertyValue(int activeID, const std::string& propertyName, std::string& lastValue);
	bool CheckPropertyChanged(int activeID, const std::string& propertyName, std::string& lastValue);

public:

	std::unique_ptr<Gui> m_gui;
	std::shared_ptr<Font> m_guiFont;
	std::unique_ptr<GuiSerializer> m_serializer; // For main app layout (menu, etc.)
	std::unique_ptr<GuiSerializer> m_contentSerializer; // For loaded content files
	std::unique_ptr<GuiSerializer> m_propertySerializer; // For property panel (ID 3000+)
	std::string m_loadedGhostFile; // Track currently loaded file
	std::vector<std::shared_ptr<Font>> m_preservedFonts; // Keep fonts alive across multiple loads
	int m_selectedElementID; // Currently selected element in content panel (-1 = none)
	int m_lastPropertyElementType; // Track last element type shown in property panel (-1 = none)

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
	std::string GetElementName(int elementID); // Get element name by ID from content serializer
};

#endif
