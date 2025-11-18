#ifndef _GUMPSPELLBOOK_H_
#define _GUMPSPELLBOOK_H_

#include <string>
#include <vector>
#include <memory>
#include "U7Gump.h"
#include "U7Globals.h"
#include "Geist/Gui.h"
#include "Geist/GuiElements.h"
#include "Ghost/GhostSerializer.h"

// Forward declaration
class U7Object;

// Spell data structures are defined in U7Globals.h

/// @brief Spellbook gump UI class
/// Displays the Avatar's spellbook with all learned spells organized by circle
class GumpSpellbook : public Gump
{
public:
	GumpSpellbook();
	virtual ~GumpSpellbook();

	void Update() override;
	void Draw() override;
	void Init() override { Init(std::string("")); }
	void Init(const std::string& data) override;
	void OnExit() override { m_IsDead = true; }
	void OnEnter() override;

	/// @brief Set up the spellbook for a specific NPC
	/// @param npcId The NPC ID who owns this spellbook
	void Setup(int npcId);

	/// @brief Check if the player has learned a specific spell
	/// @param spellId The spell ID to check (0-63)
	/// @return true if the spell is learned
	bool IsSpellLearned(int spellId);

	/// @brief Check if the player has the required reagents for a spell
	/// @param spellId The spell ID to check (0-63)
	/// @return true if all reagents are available
	bool HasReagents(int spellId);

	/// @brief Cast a spell
	/// @param spellId The spell ID to cast (0-63)
	void CastSpell(int spellId);

	/// @brief Get the NPC ID who owns this spellbook
	/// @return The NPC ID
	int GetNpcId() const { return m_npcId; }

	/// @brief Check if mouse is over a non-transparent pixel in the spellbook texture
	/// @param mousePos The mouse position to check
	/// @return true if the mouse is over a solid pixel
	bool IsMouseOverSolidPixel(Vector2 mousePos) override;

private:
	int m_npcId;                      // Owner of this spellbook (usually Avatar)
	int m_currentCircle;              // Currently displayed circle (1-8)
	int m_selectedSpellId;            // Currently selected spell (-1 = none)
	bool m_isDragging;                // Is the gump being dragged?
	Vector2 m_dragStart;              // Where the drag started
	std::unique_ptr<GhostSerializer> m_serializer; // GUI serializer for loading spell_book.ghost
	std::vector<std::shared_ptr<Font>> m_loadedFonts; // Keep fonts alive

	// GUI element IDs
	int m_prevButtonId = -1;          // PREV button for going to previous circle
	int m_nextButtonId = -1;          // NEXT button for going to next circle
	int m_levelTextId = -1;           // LEVEL text area showing circle name
	int m_bookmarkId = -1;            // BOOKMARK cycle button
	int m_spellSpriteIds[8];          // Sprite IDs for spells 1-8
	int m_pageSpriteIds[4];           // Sprite IDs for PAGE1-PAGE4 (page turn animation)

	// Bookmark state (tracks NPC's chosen spell for quick access)
	int m_bookmarkedCircle = -1;     // Circle where bookmark is set (-1 = none)
	int m_bookmarkedSpellIndex = -1; // Spell index within circle (0-7, -1 = none)

	// Page turn animation state
	bool m_isAnimating = false;       // Is a page turn animation playing?
	bool m_animateForward = true;     // true = NEXT (4,3,2,1), false = PREV (1,2,3,4)
	int m_animFrame = 0;              // Current animation frame (0-4)
	int m_lastLoggedFrame = -1;       // Last frame we logged (to avoid duplicate logs)
	int m_frameCounter = 0;           // Counts updates for current frame
	const int m_updatesPerFrame = 2;  // How many Update() calls per animation frame

	/// @brief Get the name of a circle (e.g., "First", "Second", etc.)
	/// @param circle Circle number (1-8)
	/// @return Circle name
	std::string GetCircleName(int circle);

	/// @brief Update the level text to show current circle
	void UpdateCircleDisplay();

	/// @brief Update the bookmark position and frame based on bookmarked spell
	void UpdateBookmark();
};

#endif
