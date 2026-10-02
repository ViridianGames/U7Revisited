#include <fstream>
#include <string>
#include <algorithm>
#include <cstdio>
#include <cstring>
#include <functional>

#include "U7Gump.h"
#include "U7GumpSpellbook.h"
#include "Geist/Config.h"
#include "Geist/Globals.h"
#include "Geist/InputSystem.h"
#include "Geist/ResourceManager.h"
#include "Geist/Logging.h"
#include "Geist/ScriptingSystem.h"
#include "U7Globals.h"
#include "U7Object.h"

#include "raylib.h"
#include "../ThirdParty/raylib/include/raylib.h"

using namespace std;

namespace
{
	constexpr int kReagentShape = 842;

	int ReagentFrameForName(const std::string& name)
	{
		for (const ReagentData& reagent : g_reagentData)
		{
			if (reagent.name == name)
				return reagent.frame;
		}
		return -1;
	}

	int GetStackQuantity(U7Object* obj)
	{
		if (!obj)
			return 0;
		if (obj->m_shapeData)
		{
			const int shape = obj->m_shapeData->GetShape();
			if (shape >= 0 && shape < 1024 && g_objectDataTable[shape].m_shapeType == 3)
			{
				int quantity = obj->m_Quality & 0x7f;
				return quantity == 0 ? 1 : quantity;
			}
		}
		return 1;
	}

	void SetStackQuantity(U7Object* obj, int quantity)
	{
		if (!obj || !obj->m_shapeData)
			return;
		const int shape = obj->m_shapeData->GetShape();
		if (shape >= 0 && shape < 1024 && g_objectDataTable[shape].m_shapeType == 3)
			obj->m_Quality = (quantity & 0x7f) | (obj->m_Quality & 0x80);
	}

	// Walk backpack (and nested bags) looking for shape/frame. visitor returns true to stop.
	bool ForEachPartyInventoryItem(const std::function<bool(U7Object*, U7Object*)>& visitor)
	{
		if (!g_Player)
			return false;

		std::function<bool(U7Object*)> walk = [&](U7Object* container) -> bool {
			if (!container)
				return false;
			// Copy ids in case visitor mutates inventory
			std::vector<int> ids = container->m_inventory;
			for (int itemId : ids)
			{
				U7Object* item = GetObjectFromID(itemId);
				if (!item)
					continue;
				if (visitor(container, item))
					return true;
				if (!item->m_inventory.empty() && walk(item))
					return true;
			}
			return false;
		};

		std::vector<int> partyIds = g_Player->GetPartyMemberIds();
		// Prefer Avatar first
		std::vector<int> order;
		order.push_back(0);
		for (int id : partyIds)
		{
			if (id != 0)
				order.push_back(id);
		}

		for (int npcId : order)
		{
			if (g_NPCData.find(npcId) == g_NPCData.end() || !g_NPCData[npcId])
				continue;
			const int backpackId = g_NPCData[npcId]->GetEquippedItem(EquipmentSlot::SLOT_BACKPACK);
			if (backpackId < 0)
				continue;
			if (walk(GetObjectFromID(backpackId)))
				return true;
		}
		return false;
	}

	U7Object* FindReagentInParty(int frame, U7Object** outContainer)
	{
		U7Object* found = nullptr;
		U7Object* foundContainer = nullptr;
		ForEachPartyInventoryItem([&](U7Object* container, U7Object* item) {
			if (item->m_ObjectType == kReagentShape && item->m_Frame == frame)
			{
				found = item;
				foundContainer = container;
				return true;
			}
			return false;
		});
		if (outContainer)
			*outContainer = foundContainer;
		return found;
	}
}

// Static storage for bookmark state (persists between spellbook opens)
// TODO: Move this to NPC data structure when that system is implemented
static int s_savedBookmarkedCircle = -1;
static int s_savedBookmarkedSpellIndex = -1;

GumpSpellbook::GumpSpellbook()
	: m_npcId(-1)
	, m_currentCircle(0)
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

		auto blocksDrag = [&](const std::shared_ptr<GuiElement>& element) {
			if (!element)
				return false;
			Rectangle btnRect = GetScaledElementBounds(element);
			btnRect.x += m_gui.m_Pos.x;
			btnRect.y += m_gui.m_Pos.y;
			return CheckCollisionPointRec(mousePos, btnRect);
		};

		// Don't allow dragging from CLOSE / PREV / NEXT / spell icons
		int closeButtonID = m_serializer->GetElementID("CLOSE");
		if (closeButtonID != -1 && blocksDrag(m_gui.GetElement(closeButtonID)))
			return false;
		if (m_prevButtonId != -1 && blocksDrag(m_gui.GetElement(m_prevButtonId)))
			return false;
		if (m_nextButtonId != -1 && blocksDrag(m_gui.GetElement(m_nextButtonId)))
			return false;

		for (int i = 0; i < 8; i++)
		{
			if (m_spellSpriteIds[i] != -1 && blocksDrag(m_gui.GetElement(m_spellSpriteIds[i])))
				return false;
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

		// Render at 2x design size; spell icon hitboxes scale with the same ratio
		ApplyDisplayScale(kDisplayScale);

		// Center using the scaled panel size (ghost stays at design 160x90)
		m_gui.SetLayout(0, 0,
			int(kDesignWidth * kDisplayScale),
			int(kDesignHeight * kDisplayScale),
			g_DrawScale, Gui::GUIP_CENTER);

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

	// If there's a bookmarked spell, start on that circle; otherwise Linear (Exult page 0)
	if (m_bookmarkedCircle != -1)
	{
		m_currentCircle = m_bookmarkedCircle;
		Log("GumpSpellbook::Setup() - Opening to bookmarked circle " + std::to_string(m_currentCircle));
	}
	else
	{
		m_currentCircle = 0;
		Log("GumpSpellbook::Setup() - Opening to Linear (no bookmark)");
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
	case 0: return "Linear";
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

	// Set X position based on left (0-3) or right (4-7) column (design coords * display scale)
	if (m_bookmarkedSpellIndex < 4)
	{
		bookmark->m_Pos.x = kDesignBookmarkLeftX * kDisplayScale;
	}
	else
	{
		bookmark->m_Pos.x = kDesignBookmarkRightX * kDisplayScale;
	}
}

bool GumpSpellbook::IsSpellLearned(int spellId)
{
	// TODO: Check spellbook flags / scrolls for learned spells
	// All circles unlocked for sandbox testing (Linear 0–7 … Eighth 64–71)
	if (spellId >= 0 && spellId < 72)
		return true;

	return false;
}

bool GumpSpellbook::HasReagents(int spellId, std::string* missingReagentName)
{
	SpellData* spell = GetSpellData(spellId);
	if (!spell)
		return false;

	for (const std::string& reagentName : spell->reagents)
	{
		const int frame = ReagentFrameForName(reagentName);
		if (frame < 0 || !FindReagentInParty(frame, nullptr))
		{
			if (missingReagentName)
				*missingReagentName = reagentName;
			return false;
		}
	}
	return true;
}

U7Object* GumpSpellbook::GetCasterObject() const
{
	auto npcIt = g_NPCData.find(m_npcId);
	if (npcIt == g_NPCData.end() || !npcIt->second)
		return nullptr;
	return GetObjectFromID(npcIt->second->m_objectID);
}

std::string GumpSpellbook::FindSpellScriptName(int scriptId) const
{
	if (!g_ScriptingSystem)
		return {};

	char suffix[16];
	snprintf(suffix, sizeof(suffix), "_%04d", scriptId);
	const size_t suffixLen = strlen(suffix);

	std::string fallback;
	for (const auto& script : g_ScriptingSystem->m_scriptFiles)
	{
		const std::string& name = script.first;
		if (name.size() < suffixLen)
			continue;
		if (name.compare(name.size() - suffixLen, suffixLen, suffix) != 0)
			continue;
		if (name.rfind("spell_", 0) == 0)
			return name;
		if (fallback.empty())
			fallback = name;
	}
	return fallback;
}

bool GumpSpellbook::ConsumeReagents(int spellId)
{
	SpellData* spell = GetSpellData(spellId);
	if (!spell)
		return false;

	for (const std::string& reagentName : spell->reagents)
	{
		const int frame = ReagentFrameForName(reagentName);
		U7Object* container = nullptr;
		U7Object* item = FindReagentInParty(frame, &container);
		if (!item || !container)
			return false;

		const int quantity = GetStackQuantity(item);
		if (quantity > 1)
		{
			SetStackQuantity(item, quantity - 1);
		}
		else
		{
			const int itemId = item->m_ID;
			container->RemoveObjectFromInventory(itemId);
			auto it = g_objectList.find(itemId);
			if (it != g_objectList.end())
				g_objectList.erase(it);
		}
	}
	return true;
}

void GumpSpellbook::CastSpell(int spellId)
{
	SpellData* spell = GetSpellData(spellId);
	if (!spell)
	{
		AddConsoleString("Can't cast spell: Unknown spell", RED);
		return;
	}

	const std::string& spellName = spell->name;

	if (!IsSpellLearned(spellId))
	{
		AddConsoleString("Can't cast " + spellName + ": Spell not learned", RED);
		return;
	}

	U7Object* caster = GetCasterObject();
	if (!caster)
	{
		AddConsoleString("Can't cast " + spellName + ": No caster", RED);
		return;
	}

	// Mana cost equals circle (Linear 0; First–Eighth = 1–8)
	const int manaCost = spell->circle;
	if (caster->m_mana < manaCost)
	{
		AddConsoleString("Can't cast " + spellName + ": Not enough mana", RED);
		return;
	}

	std::string missingReagent;
	if (!HasReagents(spellId, &missingReagent))
	{
		AddConsoleString("Can't cast " + spellName + ": Missing reagent " + missingReagent, RED);
		return;
	}

	const std::string scriptName = FindSpellScriptName(spell->scriptId);
	if (scriptName.empty() || !g_ScriptingSystem)
	{
		AddConsoleString("Can't cast " + spellName + ": Spell script missing", RED);
		return;
	}

	if (!ConsumeReagents(spellId))
	{
		AddConsoleString("Can't cast " + spellName + ": Missing reagent", RED);
		return;
	}

	caster->m_mana -= static_cast<float>(manaCost);
	if (caster->m_mana < 0.0f)
		caster->m_mana = 0.0f;

	// Pass the caster as objectref (spell scripts bark / schedule on this id).
	const std::string result = g_ScriptingSystem->CallScript(
		scriptName,
		{ static_cast<lua_Integer>(1), static_cast<lua_Integer>(caster->m_ID) });

	Log("GumpSpellbook::CastSpell - " + spellName + " via " + scriptName +
		" result='" + result + "' mana left=" + std::to_string(caster->m_mana));

	// Close the spellbook after a successful cast attempt (script ran)
	m_IsDead = true;
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

	// Handle PREV button click - trigger page turn animation (Linear=0 .. Eighth=8)
	if (m_gui.m_ActiveElement == m_prevButtonId && m_currentCircle > 0 && !m_isAnimating)
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

	// Handle circle navigation (0=Linear via 0 key; 1-8 keys; left/right arrows)
	if (IsKeyPressed(KEY_LEFT) && m_currentCircle > 0)
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
	else if (IsKeyPressed(KEY_ZERO))
	{
		m_currentCircle = 0;
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

	// Handle spell clicks - single click bookmarks; double-click tries to cast.
	// Important: InputSystem treats the second release of a double-click as
	// WasLButtonDoubleClicked only (WasLButtonClicked is false), so GuiIconButton
	// never sets m_ActiveElement on that frame. Detect double-clicks by region.
	auto bookmarkSpell = [&](int spellIndex) {
		m_bookmarkedCircle = m_currentCircle;
		m_bookmarkedSpellIndex = spellIndex;
		s_savedBookmarkedCircle = m_bookmarkedCircle;
		s_savedBookmarkedSpellIndex = m_bookmarkedSpellIndex;
		Log("GumpSpellbook::Update - Bookmarked spell " + std::to_string(spellIndex) +
			" in circle " + std::to_string(m_currentCircle));
		UpdateBookmark();
	};

	auto tryCastSpellIndex = [&](int spellIndex) {
		if (m_currentCircle < 0 || m_currentCircle >= static_cast<int>(g_spellCircles.size()))
			return;
		const auto& circleSpells = g_spellCircles[m_currentCircle].spells;
		if (spellIndex < 0 || spellIndex >= static_cast<int>(circleSpells.size()))
			return;
		CastSpell(circleSpells[spellIndex].id);
	};

	if (g_InputSystem && g_InputSystem->WasLButtonDoubleClicked())
	{
		for (int i = 0; i < 8; i++)
		{
			if (m_spellSpriteIds[i] == -1)
				continue;
			std::shared_ptr<GuiElement> element = m_gui.GetElement(m_spellSpriteIds[i]);
			if (!element)
				continue;

			Rectangle bounds = GetScaledElementBounds(element);
			const float scale = m_gui.m_InputScale;
			const int x = int((m_gui.m_Pos.x + bounds.x) * scale);
			const int y = int((m_gui.m_Pos.y + bounds.y) * scale);
			const int w = int(bounds.width * scale);
			const int h = int(bounds.height * scale);

			if (g_InputSystem->WasLButtonDoubleClickedInRegion(x, y, w, h))
			{
				bookmarkSpell(i);
				tryCastSpellIndex(i);
				return;
			}
		}
	}

	for (int i = 0; i < 8; i++)
	{
		if (m_spellSpriteIds[i] != -1 && m_gui.m_ActiveElement == m_spellSpriteIds[i])
		{
			bookmarkSpell(i);
			break;
		}
	}
}

void GumpSpellbook::Draw()
{
	// Update spell sprites for the current circle before drawing (0=Linear .. 8=Eighth)
	if (m_currentCircle >= 0 && m_currentCircle < static_cast<int>(g_spellCircles.size()))
	{
		const auto& circleSpells = g_spellCircles[m_currentCircle].spells;

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
	const Image* img = GetCachedGuiImage("Images/GUI/gumps.png");
	// If no image, default to solid (always block input)
	if (!img || img->data == nullptr)
		return true;

	// Convert mouse position to local gump coordinates, then into design-space atlas coords
	const float localX = (mousePos.x - m_gui.m_Pos.x) / kDisplayScale;
	const float localY = (mousePos.y - m_gui.m_Pos.y) / kDisplayScale;

	// Spellbook sprite is at x=18, y=451, w=160, h=90 in gumps.png
	const int texX = int(kTexOriginX + localX);
	const int texY = int(kTexOriginY + localY);

	if (texX < 0 || texY < 0 || texX >= img->width || texY >= img->height)
		return false;

	return GetImageColor(*img, texX, texY).a > 0;
}

void GumpSpellbook::ApplyDisplayScale(float scale)
{
	if (scale == 1.0f)
		return;

	for (auto& pair : m_gui.m_GuiElementList)
	{
		std::shared_ptr<GuiElement>& element = pair.second;
		if (!element)
			continue;

		element->m_Pos.x *= scale;
		element->m_Pos.y *= scale;

		switch (element->m_Type)
		{
		case GUI_ICONBUTTON:
		{
			GuiIconButton* button = static_cast<GuiIconButton*>(element.get());
			button->m_Scale *= scale;
			break;
		}
		case GUI_SPRITE:
		{
			GuiSprite* sprite = static_cast<GuiSprite*>(element.get());
			sprite->m_ScaleX *= scale;
			sprite->m_ScaleY *= scale;
			break;
		}
		case GUI_CYCLE:
		{
			GuiCycle* cycle = static_cast<GuiCycle*>(element.get());
			cycle->m_ScaleX *= scale;
			cycle->m_ScaleY *= scale;
			break;
		}
		case GUI_PANEL:
		case GUI_TEXTAREA:
			element->m_Width *= scale;
			element->m_Height *= scale;
			break;
		default:
			break;
		}
	}

	// Reload circle/level labels at 2x font size so text matches the larger book
	const int scaledFontSize = int(kDesignFontSize * scale);
	const char* fontPath = "Data/Fonts/babyblocks.ttf";
	auto scaledFont = std::make_shared<Font>(LoadFontEx(fontPath, scaledFontSize, 0, 0));
	m_loadedFonts.push_back(scaledFont);

	auto assignScaledFont = [&](int elementId) {
		if (elementId == -1)
			return;
		std::shared_ptr<GuiElement> element = m_gui.GetElement(elementId);
		if (element && element->m_Type == GUI_TEXTAREA)
		{
			GuiTextArea* text = static_cast<GuiTextArea*>(element.get());
			text->m_Font = scaledFont.get();
		}
	};

	// LEVEL / CIRCLE ids are resolved later in Init; scale any textarea found by name now if present
	assignScaledFont(m_serializer->GetElementID("LEVEL"));
	assignScaledFont(m_serializer->GetElementID("CIRCLE"));
}

Rectangle GumpSpellbook::GetScaledElementBounds(const std::shared_ptr<GuiElement>& element) const
{
	if (!element)
		return Rectangle{ 0, 0, 0, 0 };

	float width = element->m_Width;
	float height = element->m_Height;

	if (element->m_Type == GUI_ICONBUTTON)
	{
		GuiIconButton* button = static_cast<GuiIconButton*>(element.get());
		width *= button->m_Scale;
		height *= button->m_Scale;
	}
	else if (element->m_Type == GUI_SPRITE)
	{
		GuiSprite* sprite = static_cast<GuiSprite*>(element.get());
		width *= sprite->m_ScaleX;
		height *= sprite->m_ScaleY;
	}
	else if (element->m_Type == GUI_CYCLE)
	{
		GuiCycle* cycle = static_cast<GuiCycle*>(element.get());
		width *= cycle->m_ScaleX;
		height *= cycle->m_ScaleY;
	}

	return Rectangle{ element->m_Pos.x, element->m_Pos.y, width, height };
}
