#include "U7GumpStats.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "Geist/ResourceManager.h"
#include "Geist/Logging.h"

extern std::unique_ptr<ResourceManager> g_ResourceManager;
extern std::unordered_map<int, std::unique_ptr<NPCData>> g_NPCData;
extern std::unordered_map<int, std::unique_ptr<U7Object>> g_objectList;
extern std::shared_ptr<Font> g_ConversationFont;
extern float g_DrawScale;

GumpStats::GumpStats()
	: m_npcId(-1)
	, m_backgroundTexture(nullptr)
{
}

GumpStats::~GumpStats()
{
}

void GumpStats::Init(const std::string& data)
{
	// Nothing to do here for now
}

void GumpStats::Setup(int npcId)
{
	m_npcId = npcId;
	Log("GumpStats::Setup - NPC " + std::to_string(npcId));
}

void GumpStats::OnExit()
{
	m_IsDead = true;

	// Clear any cached state to prevent accessing stale data
	m_npcId = -1;
	m_backgroundTexture = nullptr;
}

void GumpStats::OnEnter()
{
	Log("GumpStats::OnEnter - NPC " + std::to_string(m_npcId));

	// Position GUI at default location (will be adjusted by gump manager)
	m_gui.m_Pos.x = 100;
	m_gui.m_Pos.y = 100;

	// Load the stats GUI from stats.ghost
	m_serializer = std::make_unique<GhostSerializer>();

	if (m_serializer->LoadFromFile("GUI/stats.ghost", &m_gui))
	{
		Log("GumpStats::OnEnter - Successfully loaded stats.ghost");

		// Center the GUI and set proper size
		m_serializer->CenterLoadedGUI(&m_gui, g_DrawScale);

		// Keep loaded fonts alive
		m_loadedFonts = m_serializer->GetLoadedFonts();

		// Set the CLOSE button as the done button
		int closeButtonID = m_serializer->GetElementID("CLOSE");
		if (closeButtonID != -1)
		{
			m_gui.SetDoneButtonId(closeButtonID);
		}

		// Update the NAME text area with NPC's name
		int nameTextID = m_serializer->GetElementID("NAME");
		if (nameTextID != -1)
		{
			auto nameElement = m_gui.GetElement(nameTextID);
			if (nameElement && nameElement->m_Type == GUI_TEXTAREA)
			{
				auto nameText = static_cast<GuiTextArea*>(nameElement.get());

				// Get NPC data
				auto npcIt = g_NPCData.find(m_npcId);
				if (npcIt != g_NPCData.end() && npcIt->second)
				{
					nameText->m_String = std::string(npcIt->second->name);
				}
				else
				{
					nameText->m_String = "Unknown";
				}
			}
		}

		// Get NPC data for stats
		auto npcIt = g_NPCData.find(m_npcId);
		if (npcIt != g_NPCData.end() && npcIt->second)
		{
			NPCData* npcData = npcIt->second.get();

			// Update STR
			int strTextID = m_serializer->GetElementID("STR");
			if (strTextID != -1)
			{
				auto strElement = m_gui.GetElement(strTextID);
				if (strElement && strElement->m_Type == GUI_TEXTAREA)
				{
					auto strText = static_cast<GuiTextArea*>(strElement.get());
					strText->m_String = std::to_string(static_cast<int>(npcData->str));
				}
			}

			// Update DEX
			int dexTextID = m_serializer->GetElementID("DEX");
			if (dexTextID != -1)
			{
				auto dexElement = m_gui.GetElement(dexTextID);
				if (dexElement && dexElement->m_Type == GUI_TEXTAREA)
				{
					auto dexText = static_cast<GuiTextArea*>(dexElement.get());
					dexText->m_String = std::to_string(static_cast<int>(npcData->dex));
				}
			}

			// Update INT
			int intTextID = m_serializer->GetElementID("INT");
			if (intTextID != -1)
			{
				auto intElement = m_gui.GetElement(intTextID);
				if (intElement && intElement->m_Type == GUI_TEXTAREA)
				{
					auto intText = static_cast<GuiTextArea*>(intElement.get());
					intText->m_String = std::to_string(static_cast<int>(npcData->iq));
				}
			}

			// Update COMBAT
			int combatTextID = m_serializer->GetElementID("COMBAT");
			if (combatTextID != -1)
			{
				auto combatElement = m_gui.GetElement(combatTextID);
				if (combatElement && combatElement->m_Type == GUI_TEXTAREA)
				{
					auto combatText = static_cast<GuiTextArea*>(combatElement.get());
					combatText->m_String = std::to_string(static_cast<int>(npcData->combat));
				}
			}

			// Update MAGIC
			int magicTextID = m_serializer->GetElementID("MAGIC");
			if (magicTextID != -1)
			{
				auto magicElement = m_gui.GetElement(magicTextID);
				if (magicElement && magicElement->m_Type == GUI_TEXTAREA)
				{
					auto magicText = static_cast<GuiTextArea*>(magicElement.get());
					magicText->m_String = std::to_string(static_cast<int>(npcData->magic));
				}
			}

			// Update HITS
			int hitsTextID = m_serializer->GetElementID("HITS");
			if (hitsTextID != -1)
			{
				auto hitsElement = m_gui.GetElement(hitsTextID);
				if (hitsElement && hitsElement->m_Type == GUI_TEXTAREA)
				{
					auto hitsText = static_cast<GuiTextArea*>(hitsElement.get());
					// TODO: Get actual health from NPC properties
					hitsText->m_String = "?";
				}
			}

			// Update MANA
			int manaTextID = m_serializer->GetElementID("MANA");
			if (manaTextID != -1)
			{
				auto manaElement = m_gui.GetElement(manaTextID);
				if (manaElement && manaElement->m_Type == GUI_TEXTAREA)
				{
					auto manaText = static_cast<GuiTextArea*>(manaElement.get());
					// TODO: Get actual mana from NPC properties
					manaText->m_String = "?";
				}
			}

			// Update EXP
			int expTextID = m_serializer->GetElementID("EXP");
			if (expTextID != -1)
			{
				auto expElement = m_gui.GetElement(expTextID);
				if (expElement && expElement->m_Type == GUI_TEXTAREA)
				{
					auto expText = static_cast<GuiTextArea*>(expElement.get());
					expText->m_String = std::to_string(static_cast<int>(npcData->xp));
				}
			}

			// Update LVL
			int lvlTextID = m_serializer->GetElementID("LVL");
			if (lvlTextID != -1)
			{
				auto lvlElement = m_gui.GetElement(lvlTextID);
				if (lvlElement && lvlElement->m_Type == GUI_TEXTAREA)
				{
					auto lvlText = static_cast<GuiTextArea*>(lvlElement.get());
					// TODO: Calculate level from XP or add level field to NPCData
					lvlText->m_String = "?";
				}
			}

			// Update TRAIN
			int trainTextID = m_serializer->GetElementID("TRAIN");
			if (trainTextID != -1)
			{
				auto trainElement = m_gui.GetElement(trainTextID);
				if (trainElement && trainElement->m_Type == GUI_TEXTAREA)
				{
					auto trainText = static_cast<GuiTextArea*>(trainElement.get());
					trainText->m_String = std::to_string(static_cast<int>(npcData->training));
				}
			}
		}
	}
	else
	{
		Log("ERROR: GumpStats::OnEnter - Failed to load stats.ghost");
	}

	// Activate the GUI
	m_gui.m_Active = true;
	m_gui.m_isDone = false;
	m_gui.m_IsDragging = false;
	m_gui.m_ActiveElement = -1;

	// Make the stats gump draggable
	m_gui.m_Draggable = true;
	m_gui.m_DragAreaHeight = int(m_gui.m_Height);  // Allow dragging from anywhere

	// Drag validation: don't allow dragging from CLOSE button
	m_gui.m_DragAreaValidationCallback = [this](Vector2 mousePos) {
		// Check if mouse is over CLOSE button
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
				{
					return false;  // Don't allow drag from button
				}
			}
		}
		return this->IsMouseOverSolidPixel(mousePos);
	};

	// Store texture reference for pixel-perfect collision
	m_backgroundTexture = g_ResourceManager->GetTexture("Images/GUI/gumps.png");

	// Debug: Log GUI bounds for collision detection
	Log("GumpStats::OnEnter - GUI bounds: pos(" + std::to_string(m_gui.m_Pos.x) + ", " + std::to_string(m_gui.m_Pos.y) +
		") size(" + std::to_string(m_gui.m_Width) + ", " + std::to_string(m_gui.m_Height) + ")");
}

void GumpStats::Update()
{
	// Debug: Log if gui is not active
	if (!m_gui.m_Active)
	{
		Log("GumpStats::Update - GUI is NOT ACTIVE!");
	}

	// Update GUI elements
	m_gui.Update();

	// Ensure GUI position stays integer-aligned (like Gump does)
	m_gui.m_Pos.x = int(m_gui.m_Pos.x);
	m_gui.m_Pos.y = int(m_gui.m_Pos.y);

	// Check if close button was clicked
	if (m_gui.m_ActiveElement == m_gui.m_doneButtonId)
	{
		OnExit();
	}

	// Also allow ESC key to close
	if (IsKeyPressed(KEY_ESCAPE))
	{
		OnExit();
	}
}

void GumpStats::Draw()
{
	// Update GOLD text area
	int goldTextID = m_serializer->GetElementID("GOLD");
	if (goldTextID != -1)
	{
		auto goldElement = m_gui.GetElement(goldTextID);
		if (goldElement && goldElement->m_Type == GUI_TEXTAREA)
		{
			auto goldText = static_cast<GuiTextArea*>(goldElement.get());
			goldText->m_String = "GOLD: " + std::to_string(g_Player->GetGold());
		}
	}

	// Update WEIGHT text area
	int weightTextID = m_serializer->GetElementID("WEIGHT");
	if (weightTextID != -1)
	{
		auto weightElement = m_gui.GetElement(weightTextID);
		if (weightElement && weightElement->m_Type == GUI_TEXTAREA)
		{
			auto weightText = static_cast<GuiTextArea*>(weightElement.get());

			// Get the NPC's object to calculate weight
			auto npcIt = g_NPCData.find(m_npcId);
			if (npcIt != g_NPCData.end() && npcIt->second)
			{
				U7Object* npcObject = g_objectList[npcIt->second->m_objectID].get();
				if (npcObject)
				{
					int currentWeight = static_cast<int>(npcObject->GetWeight());
					int maxWeight = static_cast<int>(g_Player->GetMaxWeight()); // For now all NPCs use Avatar's max weight
					weightText->m_String = "WEIGHT: " + std::to_string(currentWeight) + "/" + std::to_string(maxWeight);
				}
			}
		}
	}

	// Draw the GUI
	m_gui.Draw();
}

bool GumpStats::IsMouseOverSolidPixel(Vector2 mousePos)
{
	// Check if over solid background pixel (transparent areas let world clicks through)
	if (!m_backgroundTexture)
		return true;

	// Convert mouse position to local stats gump coordinates
	float localX = mousePos.x - m_gui.m_Pos.x;
	float localY = mousePos.y - m_gui.m_Pos.y;

	// Check bounds
	if (localX < 0 || localY < 0 || localX >= 135 || localY >= 135)
		return false;

	// Calculate pixel position in the source texture
	// Stats gump sprite is at (232, 437) in gumps.png, size 135x135
	int texX = int(232 + localX);
	int texY = int(437 + localY);

	// Load the texture as an image to check pixel alpha
	Image img = LoadImageFromTexture(*m_backgroundTexture);

	// Bounds check in texture
	if (texX < 0 || texY < 0 || texX >= img.width || texY >= img.height)
	{
		UnloadImage(img);
		return false;
	}

	// Get pixel color at position
	Color pixel = GetImageColor(img, texX, texY);
	UnloadImage(img);

	// Check if pixel is opaque (alpha > 128)
	return pixel.a > 128;
}
