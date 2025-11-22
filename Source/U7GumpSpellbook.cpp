#include <fstream>
#include <string>
#include <algorithm>

#include "U7Gump.h"
#include "U7GumpSpellbook.h"
#include "Geist/Config.h"
#include "Geist/Globals.h"
#include "Geist/ResourceManager.h"
#include "Geist/Logging.h"
#include "U7Globals.h"
#include "U7Object.h"

#include "raylib.h"
#include "../ThirdParty/raylib/include/raylib.h"

using namespace std;

const int BOOKMARK_LEFT_X = 78;
const int BOOKMARK_RIGHT_X = 125;

// Static storage for bookmark state (persists between spellbook opens)
// TODO: Move this to NPC data structure when that system is implemented
static int s_savedBookmarkedCircle = -1;
static int s_savedBookmarkedSpellIndex = -1;

GumpSpellbook::GumpSpellbook()
	: m_npcId(-1)
	, m_currentCircle(1)
	, m_selectedSpellId(-1)
	, m_isDragging(false)
	, m_dragStart({ 0, 0 })
{
}

GumpSpellbook::~GumpSpellbook()
{
}

void GumpSpellbook::OnEnter()
{
	Log("GumpSpellbook::OnEnter() - m_currentCircle=" + std::to_string(m_currentCircle) + 
		" bookmarked circle=" + std::to_string(m_bookmarkedCircle));

	// Update circle display now that GUI is loaded (Setup called UpdateCircleDisplay before Init loaded the GUI)
	UpdateCircleDisplay();
	UpdateBookmark();

	// Enable dragging for the spellbook gump
	m_gui.m_Draggable = true;
	m_gui.m_DragAreaHeight = int(m_gui.m_Height);  // Allow dragging from anywhere, not just top

	// Set up pixel-perfect drag area validation
	m_gui.m_DragAreaValidationCallback = [this](Vector2 mousePos) {
		// First check if over solid pixel
		if (!this->IsMouseOverSolidPixel(mousePos))
			return false;

		// Don't allow dragging from CLOSE button
		int closeButtonID = m_serializer->GetElementID("CLOSE");
		if (closeButtonID != -1)
		{
			auto element = m_gui.GetElement(closeButtonID);
			if (element)
			{
				Rectangle btnRect = element->GetBounds();
				btnRect.x += m_gui.m_Pos.x;
				btnRect.y += m_gui.m_Pos.y;
				if (CheckCollisionPointRec(mousePos, btnRect))
					return false;
			}
		}

		// Don't allow dragging from PREV button
		if (m_prevButtonId != -1)
		{
			auto element = m_gui.GetElement(m_prevButtonId);
			if (element)
			{
				Rectangle btnRect = element->GetBounds();
				btnRect.x += m_gui.m_Pos.x;
				btnRect.y += m_gui.m_Pos.y;
				if (CheckCollisionPointRec(mousePos, btnRect))
					return false;
			}
		}

		// Don't allow dragging from NEXT button
		if (m_nextButtonId != -1)
		{
			auto element = m_gui.GetElement(m_nextButtonId);
			if (element)
			{
				Rectangle btnRect = element->GetBounds();
				btnRect.x += m_gui.m_Pos.x;
				btnRect.y += m_gui.m_Pos.y;
				if (CheckCollisionPointRec(mousePos, btnRect))
					return false;
			}
		}

		// Don't allow dragging from spell sprites (1-8)
		for (int i = 0; i < 8; i++)
		{
			if (m_spellSpriteIds[i] != -1)
			{
				auto element = m_gui.GetElement(m_spellSpriteIds[i]);
				if (element)
				{
					Rectangle spriteRect = element->GetBounds();
					spriteRect.x += m_gui.m_Pos.x;
					spriteRect.y += m_gui.m_Pos.y;
					if (CheckCollisionPointRec(mousePos, spriteRect))
						return false;
				}
			}
		}

		return true;
	};
}

void GumpSpellbook::Init(const std::string& data)
{
	// Load spellbook GUI from spell_book.ghost file
	m_serializer = std::make_unique<GhostSerializer>();

	if (m_serializer->LoadFromFile("GUI/spell_book.ghost", &m_gui))
	{
		Log("GumpSpellbook::Init - Successfully loaded spell_book.ghost");

		// Keep loaded fonts alive
		m_loadedFonts = m_serializer->GetLoadedFonts();

		// Center the GUI on screen
		m_serializer->CenterLoadedGUI(&m_gui, g_DrawScale);

		m_Pos.x = m_gui.m_Pos.x;
		m_Pos.y = m_gui.m_Pos.y;

		// Set the CLOSE button as the done button
		int closeButtonID = m_serializer->GetElementID("CLOSE");
		if (closeButtonID != -1)
		{
			m_gui.SetDoneButtonId(closeButtonID);
			Log("GumpSpellbook::Init - Set CLOSE button as done button");
		}
		else
		{
			Log("GumpSpellbook::Init - WARNING: CLOSE button not found in spell_book.ghost");
		}

		// Store element IDs for navigation buttons, level text, and bookmark
		m_prevButtonId = m_serializer->GetElementID("PREV");
		m_nextButtonId = m_serializer->GetElementID("NEXT");
		m_levelTextId = m_serializer->GetElementID("LEVEL");
		m_bookmarkId = m_serializer->GetElementID("BOOKMARK");

		if (m_prevButtonId == -1 || m_nextButtonId == -1 || m_levelTextId == -1)
		{
			Log("GumpSpellbook::Init - WARNING: Could not find PREV, NEXT, or LEVEL elements");
		}

		if (m_bookmarkId == -1)
		{
			Log("GumpSpellbook::Init - WARNING: Could not find BOOKMARK element");
		}

		// Store element IDs for spell sprites (named "1" through "8")
		for (int i = 0; i < 8; i++)
		{
			m_spellSpriteIds[i] = m_serializer->GetElementID(std::to_string(i + 1));
			if (m_spellSpriteIds[i] == -1)
			{
				Log("GumpSpellbook::Init - WARNING: Could not find spell sprite " + std::to_string(i + 1));
			}
		}

		// Hide PAGE1-PAGE4 sprites (used for page turn animations)
		for (int i = 1; i <= 4; i++)
		{
			int pageId = m_serializer->GetElementID("PAGE" + std::to_string(i));
			m_pageSpriteIds[i - 1] = pageId;
			if (pageId != -1)
			{
				std::shared_ptr<GuiElement> pageElement = m_gui.GetElement(pageId);
				if (pageElement)
				{
					pageElement->m_Visible = false;
					Log("GumpSpellbook::Init - Set PAGE" + std::to_string(i) + " to invisible");
				}
			}
			else
			{
				Log("GumpSpellbook::Init - WARNING: Could not find PAGE" + std::to_string(i) + " element");
			}
		}
	}
	else
	{
		Log("GumpSpellbook::Init - ERROR: Failed to load spell_book.ghost");
	}

	Log("GumpSpellbook::Init() completed");
}

void GumpSpellbook::Setup(int npcId)
{
	m_npcId = npcId;
	m_selectedSpellId = -1;

	// TODO: Load learned spells for this NPC from their inventory
	// Check for spell scrolls in NPC's inventory to determine which spells are learned

	// TODO: Load bookmarked spell from NPC data
	// For now, load from static storage (persists between spellbook opens)
	Log("GumpSpellbook::Setup - Loading from static: circle=" + std::to_string(s_savedBookmarkedCircle) + 
		" index=" + std::to_string(s_savedBookmarkedSpellIndex));
	m_bookmarkedCircle = s_savedBookmarkedCircle;
	m_bookmarkedSpellIndex = s_savedBookmarkedSpellIndex;

	// If there's a bookmarked spell, start on that circle; otherwise start on circle 1
	if (m_bookmarkedCircle != -1)
	{
		m_currentCircle = m_bookmarkedCircle;
		Log("GumpSpellbook::Setup() - Opening to bookmarked circle " + std::to_string(m_currentCircle));
	}
	else
	{
		m_currentCircle = 1;
		Log("GumpSpellbook::Setup() - Opening to First circle (no bookmark)");
	}

	// Update the circle display
	UpdateCircleDisplay();

	// Update bookmark visibility
	UpdateBookmark();

	Log("GumpSpellbook::Setup() for NPC " + std::to_string(npcId));
}

std::string GumpSpellbook::GetCircleName(int circle)
{
	switch (circle)
	{
	case 1: return "First";
	case 2: return "Second";
	case 3: return "Third";
	case 4: return "Fourth";
	case 5: return "Fifth";
	case 6: return "Sixth";
	case 7: return "Seventh";
	case 8: return "Eighth";
	default: return "Unknown";
	}
}

void GumpSpellbook::UpdateCircleDisplay()
{
	if (m_levelTextId != -1)
	{
		std::shared_ptr<GuiElement> levelElement = m_gui.GetElement(m_levelTextId);
		if (levelElement && levelElement->m_Type == GUI_TEXTAREA)
		{
			levelElement->m_String = GetCircleName(m_currentCircle);
		}
	}
}

void GumpSpellbook::UpdateBookmark()
{
	if (m_bookmarkId == -1)
	{
		Log("GumpSpellbook::UpdateBookmark - m_bookmarkId is -1");
		return;
	}

	std::shared_ptr<GuiElement> bookmarkElement = m_gui.GetElement(m_bookmarkId);
	if (!bookmarkElement)
	{
		Log("GumpSpellbook::UpdateBookmark - bookmarkElement is null");
		return;
	}

	if (bookmarkElement->m_Type != GUI_CYCLE)
	{
		Log("GumpSpellbook::UpdateBookmark - bookmarkElement is not GUI_CYCLE, type=" + std::to_string(bookmarkElement->m_Type));
		return;
	}

	GuiCycle* bookmark = static_cast<GuiCycle*>(bookmarkElement.get());

	// Make bookmark non-interactive so it can't be clicked
	bookmark->m_Active = false;
	Log("GumpSpellbook::UpdateBookmark - Set bookmark m_Active = false");

	// If no spell is bookmarked, hide the bookmark
	if (m_bookmarkedCircle == -1 || m_bookmarkedSpellIndex == -1)
	{
		Log("GumpSpellbook::UpdateBookmark - No spell bookmarked, hiding");
		bookmark->m_Visible = false;
		return;
	}

	Log("GumpSpellbook::UpdateBookmark - Setting bookmark visible, circle=" + std::to_string(m_bookmarkedCircle) +
		" index=" + std::to_string(m_bookmarkedSpellIndex));
	bookmark->m_Visible = true;

	// Check if viewing the bookmarked circle
	if (m_currentCircle == m_bookmarkedCircle)
	{
		// Bookmark is on current page - set frame based on row (1-4)
		// Spells are in 2 columns (LEFT: indices 0-3, RIGHT: indices 4-7)
		// Frame 1 = top row, frame 2 = second row, etc.
		int row = (m_bookmarkedSpellIndex % 4) + 1; // Row 1-4
		bookmark->m_CurrentFrame = row;
	}
	else
	{
		// Viewing a different circle - use frame 0
		bookmark->m_CurrentFrame = 0;
	}

	// Set X position based on left (0-3) or right (4-7) column
	if (m_bookmarkedSpellIndex < 4)
	{
		// Left page
		bookmark->m_Pos.x = BOOKMARK_LEFT_X;
		// Log("GumpSpellbook::UpdateBookmark - On bookmarked circle, LEFT page, frame=" + std::to_string(row) + " x=200");
	}
	else
	{
		// Right page
		bookmark->m_Pos.x = BOOKMARK_RIGHT_X;
		// Log("GumpSpellbook::UpdateBookmark - On bookmarked circle, RIGHT page, frame=" + std::to_string(row) + " x=400");
	}
}

bool GumpSpellbook::IsSpellLearned(int spellId)
{
	// TODO: Check if NPC has learned this spell
	// For now, return true for all First Circle spells as a placeholder
	if (spellId >= 0 && spellId < 8)
		return true;

	return false;
}

bool GumpSpellbook::HasReagents(int spellId)
{
	// TODO: Check if NPC has the required reagents in inventory
	// Look up spell data from g_spellData
	// Check NPC's inventory for each required reagent (shape 842, specific frames)

	if (spellId < 0 || spellId >= 64)
		return false;

	// For now, always return true as placeholder
	return true;
}

void GumpSpellbook::CastSpell(int spellId)
{
	if (spellId < 0 || spellId >= 64)
	{
		Log("GumpSpellbook::CastSpell() - Invalid spell ID: " + std::to_string(spellId));
		return;
	}

	if (!IsSpellLearned(spellId))
	{
		Log("GumpSpellbook::CastSpell() - Spell not learned: " + std::to_string(spellId));
		return;
	}

	if (!HasReagents(spellId))
	{
		Log("GumpSpellbook::CastSpell() - Missing reagents for spell: " + std::to_string(spellId));
		return;
	}

	// TODO: Consume reagents from NPC inventory
	// TODO: Execute spell script (utility_spell_*.lua)
	// TODO: Close spellbook after casting

	Log("GumpSpellbook::CastSpell() - Casting spell ID: " + std::to_string(spellId));
}

void GumpSpellbook::Update()
{
	// Make bookmark non-interactive every frame (prevent it from being clicked)
	if (m_bookmarkId != -1)
	{
		std::shared_ptr<GuiElement> bookmarkElement = m_gui.GetElement(m_bookmarkId);
		if (bookmarkElement && bookmarkElement->m_Type == GUI_CYCLE)
		{
			bookmarkElement->m_Active = false;
		}
	}

	m_gui.Update();

	// Close spellbook if user presses ESC or clicks outside
	if (IsKeyPressed(KEY_ESCAPE) || m_gui.m_isDone)
	{
		m_IsDead = true;
		return;
	}

	// Handle PREV button click - trigger page turn animation
	if (m_gui.m_ActiveElement == m_prevButtonId && m_currentCircle > 1 && !m_isAnimating)
	{
		// Start PREV animation (1,2,3,4)
		m_isAnimating = true;
		m_animateForward = false;
		m_animFrame = 0;
		m_frameCounter = 0;
		m_lastLoggedFrame = -1;
	}

	// Handle NEXT button click - trigger page turn animation
	if (m_gui.m_ActiveElement == m_nextButtonId && m_currentCircle < 8 && !m_isAnimating)
	{
		// Start NEXT animation (4,3,2,1)
		m_isAnimating = true;
		m_animateForward = true;
		m_animFrame = 0;
		m_frameCounter = 0;
		m_lastLoggedFrame = -1;
	}

	// Update page turn animation
	if (m_isAnimating)
	{
		// Increment counter and advance frame FIRST
		m_frameCounter++;

		if (m_frameCounter >= m_updatesPerFrame)
		{
			m_frameCounter = 0;
			m_animFrame++;

			// Change circle at frame 3 (after halfway through animation)
			if (m_animFrame == 3)
			{
				if (m_animateForward)
				{
					m_currentCircle++;
				}
				else
				{
					m_currentCircle--;
				}

				UpdateCircleDisplay();
				UpdateBookmark();
				m_selectedSpellId = -1;
			}

			// Animation has 5 frames total (first and last page show twice)
			if (m_animFrame >= 5)
			{
				m_isAnimating = false;
				m_animFrame = 0;

				// Hide all page sprites when animation ends
				for (int i = 0; i < 4; i++)
				{
					if (m_pageSpriteIds[i] != -1)
					{
						std::shared_ptr<GuiElement> pageElement = m_gui.GetElement(m_pageSpriteIds[i]);
						if (pageElement)
						{
							pageElement->m_Visible = false;
						}
					}
				}

				return; // Exit early when animation is done
			}
		}

		// THEN show the current animation frame's page sprite
		{
			// Hide all pages first
			for (int i = 0; i < 4; i++)
			{
				if (m_pageSpriteIds[i] != -1)
				{
					std::shared_ptr<GuiElement> pageElement = m_gui.GetElement(m_pageSpriteIds[i]);
					if (pageElement)
					{
						pageElement->m_Visible = false;
					}
				}
			}

			// Show the current frame
			int pageIndex;
			if (m_animateForward)
			{
				// NEXT: 4,4,3,2,1 (frames 0,1,2,3,4 -> indices 3,3,2,1,0)
				if (m_animFrame <= 1)
					pageIndex = 3; // PAGE4 for frames 0 and 1
				else
					pageIndex = 4 - m_animFrame; // frame 2->idx 2 (PAGE3), frame 3->idx 1 (PAGE2), frame 4->idx 0 (PAGE1)
			}
			else
			{
				// PREV: 1,1,2,3,4 (frames 0,1,2,3,4 -> indices 0,0,1,2,3)
				if (m_animFrame <= 1)
					pageIndex = 0; // PAGE1 for frames 0 and 1
				else
					pageIndex = m_animFrame - 1; // frame 2->idx 1 (PAGE2), frame 3->idx 2 (PAGE3), frame 4->idx 3 (PAGE4)
			}

			if (pageIndex >= 0 && pageIndex < 4 && m_pageSpriteIds[pageIndex] != -1)
			{
				std::shared_ptr<GuiElement> pageElement = m_gui.GetElement(m_pageSpriteIds[pageIndex]);
				if (pageElement)
				{
					pageElement->m_Visible = true;
				}
			}
		}
	}

	// Handle circle navigation (1-8 keys or left/right arrows)
	if (IsKeyPressed(KEY_LEFT) && m_currentCircle > 1)
	{
		m_currentCircle--;
		m_selectedSpellId = -1;
		UpdateCircleDisplay();
		UpdateBookmark();
	}
	else if (IsKeyPressed(KEY_RIGHT) && m_currentCircle < 8)
	{
		m_currentCircle++;
		m_selectedSpellId = -1;
		UpdateCircleDisplay();
		UpdateBookmark();
	}
	else if (IsKeyPressed(KEY_ONE))
	{
		m_currentCircle = 1;
		UpdateCircleDisplay();
		UpdateBookmark();
	}
	else if (IsKeyPressed(KEY_TWO))
	{
		m_currentCircle = 2;
		UpdateCircleDisplay();
		UpdateBookmark();
	}
	else if (IsKeyPressed(KEY_THREE))
	{
		m_currentCircle = 3;
		UpdateCircleDisplay();
		UpdateBookmark();
	}
	else if (IsKeyPressed(KEY_FOUR))
	{
		m_currentCircle = 4;
		UpdateCircleDisplay();
		UpdateBookmark();
	}
	else if (IsKeyPressed(KEY_FIVE))
	{
		m_currentCircle = 5;
		UpdateCircleDisplay();
		UpdateBookmark();
	}
	else if (IsKeyPressed(KEY_SIX))
	{
		m_currentCircle = 6;
		UpdateCircleDisplay();
		UpdateBookmark();
	}
	else if (IsKeyPressed(KEY_SEVEN))
	{
		m_currentCircle = 7;
		UpdateCircleDisplay();
		UpdateBookmark();
	}
	else if (IsKeyPressed(KEY_EIGHT))
	{
		m_currentCircle = 8;
		UpdateCircleDisplay();
		UpdateBookmark();
	}

	// Handle spell clicks - spell icons are now interactive iconbuttons
	for (int i = 0; i < 8; i++)
	{
		if (m_spellSpriteIds[i] != -1)
		{
			// Check if this spell button was clicked
			if (m_gui.m_ActiveElement == m_spellSpriteIds[i])
			{
				// Spell clicked - update bookmark to this spell
				m_bookmarkedCircle = m_currentCircle;
				m_bookmarkedSpellIndex = i;

				// Save to static storage so it persists between spellbook opens
				s_savedBookmarkedCircle = m_bookmarkedCircle;
				s_savedBookmarkedSpellIndex = m_bookmarkedSpellIndex;
				Log("GumpSpellbook::Update - Saved to static: circle=" + std::to_string(s_savedBookmarkedCircle) + 
					" index=" + std::to_string(s_savedBookmarkedSpellIndex));

				Log("GumpSpellbook::Update - Bookmarked spell " + std::to_string(i) +
					" in circle " + std::to_string(m_currentCircle));

				// Update bookmark position and frame
				UpdateBookmark();
				break;
			}
		}
	}
}

void GumpSpellbook::Draw()
{
	// Update spell sprites for the current circle before drawing
	if (m_currentCircle >= 1 && m_currentCircle <= 8)
	{
		// Get the spells for the current circle
		const auto& circleSpells = g_spellCircles[m_currentCircle - 1].spells;

		// Get the gumps texture
		Texture* gumpsTexture = g_ResourceManager->GetTexture("Images/GUI/gumps.png");

		if (gumpsTexture)
		{
			// Update each of the 8 spell sprite elements
			for (int i = 0; i < 8 && i < circleSpells.size(); i++)
			{
				if (m_spellSpriteIds[i] != -1)
				{
					std::shared_ptr<GuiElement> element = m_gui.GetElement(m_spellSpriteIds[i]);
					
					// Get the spell data for this position
					const SpellData& spell = circleSpells[i];

					// Create a new sprite with the correct texture coordinates
					auto newSprite = std::make_shared<Sprite>(
						gumpsTexture,
						spell.x,
						spell.y,
						44,  // Width of spell icon
						16   // Height of spell icon
					);

					// Handle both GUI_SPRITE and GUI_ICONBUTTON types
					if (element && element->m_Type == GUI_SPRITE)
					{
						GuiSprite* spriteElement = static_cast<GuiSprite*>(element.get());
						spriteElement->SetSprite(newSprite);
					}
					else if (element && element->m_Type == GUI_ICONBUTTON)
					{
						GuiIconButton* iconButton = static_cast<GuiIconButton*>(element.get());
						iconButton->m_UpTexture = newSprite;
						iconButton->m_DownTexture = newSprite;  // Use same sprite for down state
					}
				}
			}
		}
	}

	// Draw the spellbook GUI (loaded from spell_book.ghost)
	m_gui.Draw();

	// TODO: Draw spell details for selected spell
	// TODO: Draw reagent requirements
	// TODO: Draw cast button
	// TODO: Update bookmark position based on current circle
}

bool GumpSpellbook::IsMouseOverSolidPixel(Vector2 mousePos)
{
	// Get the gumps texture (used for spellbook background)
	Texture* backgroundTexture = g_ResourceManager->GetTexture("Images/GUI/gumps.png");

	// If no texture, default to solid (always block input)
	if (!backgroundTexture)
		return true;

	// Convert mouse position to local gump coordinates
	float localX = mousePos.x - m_gui.m_Pos.x;
	float localY = mousePos.y - m_gui.m_Pos.y;

	// Spellbook sprite is at x=18, y=451, w=160, h=90 in gumps.png
	int texX = int(18 + localX);
	int texY = int(451 + localY);

	// Load the texture as an image to check pixel alpha
	Image img = LoadImageFromTexture(*backgroundTexture);

	// Check bounds
	if (texX < 0 || texY < 0 || texX >= img.width || texY >= img.height)
	{
		UnloadImage(img);
		return false;
	}

	// Get the pixel color at the position
	Color pixelColor = GetImageColor(img, texX, texY);
	UnloadImage(img);

	// Return true if alpha > 0 (non-transparent)
	return pixelColor.a > 0;
}
