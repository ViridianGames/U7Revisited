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
		}
	}
	else
	{
		Log("ERROR: GumpStats::OnEnter - Failed to load stats.ghost");
	}

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
	// TODO: Update stats display with current NPC stats values
	// For now, just draw the GUI
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
