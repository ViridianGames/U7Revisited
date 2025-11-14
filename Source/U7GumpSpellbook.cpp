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

GumpSpellbook::GumpSpellbook()
	: m_npcId(-1)
	, m_currentCircle(1)
	, m_selectedSpellId(-1)
	, m_isDragging(false)
	, m_dragStart({0, 0})
{
}

GumpSpellbook::~GumpSpellbook()
{
}

void GumpSpellbook::OnEnter()
{
	Log("GumpSpellbook::OnEnter()");

	// Enable dragging for the spellbook gump
	m_gui.m_Draggable = true;

	// Set up pixel-perfect drag area validation
	m_gui.m_DragAreaValidationCallback = [this](Vector2 mousePos) {
		return this->IsMouseOverSolidPixel(mousePos);
	};
}

void GumpSpellbook::Init(const std::string& data)
{
	// Position spellbook on screen (centered)
	m_Pos.x = (640 - 160) / 2;  // Center horizontally (160 is spellbook width)
	m_Pos.y = (360 - 90) / 2;   // Center vertically (90 is spellbook height)

	// Set up GUI layout
	m_gui.m_Font = g_SmallFont;
	m_gui.SetLayout(m_Pos.x, m_Pos.y, 160, 90, g_DrawScale, Gui::GUIP_USE_XY);

	// Load spellbook GUI from spell_book.ghost file
	m_serializer = std::make_unique<GhostSerializer>();
	GhostSerializer::SetBaseFontPath("Fonts/");
	GhostSerializer::SetBaseSpritePath("Images/");

	if (m_serializer->LoadFromFile("GUI/spell_book.ghost", &m_gui))
	{
		Log("GumpSpellbook::Init - Successfully loaded spell_book.ghost");

		// Keep loaded fonts alive
		m_loadedFonts = m_serializer->GetLoadedFonts();

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
	m_currentCircle = 1;
	m_selectedSpellId = -1;

	// TODO: Load learned spells for this NPC from their inventory
	// Check for spell scrolls in NPC's inventory to determine which spells are learned

	Log("GumpSpellbook::Setup() for NPC " + std::to_string(npcId));
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
	m_gui.Update();

	// Close spellbook if user presses ESC or clicks outside
	if (IsKeyPressed(KEY_ESCAPE) || m_gui.m_isDone)
	{
		m_IsDead = true;
		return;
	}

	// Handle circle navigation (1-8 keys or left/right arrows)
	if (IsKeyPressed(KEY_LEFT) && m_currentCircle > 1)
	{
		m_currentCircle--;
		m_selectedSpellId = -1;
	}
	else if (IsKeyPressed(KEY_RIGHT) && m_currentCircle < 8)
	{
		m_currentCircle++;
		m_selectedSpellId = -1;
	}
	else if (IsKeyPressed(KEY_ONE)) m_currentCircle = 1;
	else if (IsKeyPressed(KEY_TWO)) m_currentCircle = 2;
	else if (IsKeyPressed(KEY_THREE)) m_currentCircle = 3;
	else if (IsKeyPressed(KEY_FOUR)) m_currentCircle = 4;
	else if (IsKeyPressed(KEY_FIVE)) m_currentCircle = 5;
	else if (IsKeyPressed(KEY_SIX)) m_currentCircle = 6;
	else if (IsKeyPressed(KEY_SEVEN)) m_currentCircle = 7;
	else if (IsKeyPressed(KEY_EIGHT)) m_currentCircle = 8;

	// TODO: Handle spell selection and casting
	// TODO: Handle mouse clicks on spell icons
}

void GumpSpellbook::Draw()
{
	// Draw the spellbook GUI (loaded from spell_book.ghost)
	m_gui.Draw();

	// TODO: Draw spell icons for current circle
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
