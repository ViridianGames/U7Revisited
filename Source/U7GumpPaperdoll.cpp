#include "U7GumpPaperdoll.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "Geist/ResourceManager.h"
#include "Geist/Logging.h"
#include <filesystem>

extern std::unique_ptr<ResourceManager> g_ResourceManager;
extern std::unique_ptr<U7Player> g_Player;
extern std::unordered_map<int, std::unique_ptr<NPCData>> g_NPCData;
extern std::unordered_map<int, std::unique_ptr<U7Object>> g_objectList;
extern std::shared_ptr<Font> g_SmallFont;
extern float g_DrawScale;
extern std::shared_ptr<Sprite> g_gumpCheckmarkUp;
extern std::shared_ptr<Sprite> g_gumpCheckmarkDown;

GumpPaperdoll::GumpPaperdoll()
	: m_npcId(-1)
	, m_paperdollType(0)
{
}

GumpPaperdoll::~GumpPaperdoll()
{
}

void GumpPaperdoll::Init(const std::string& data)
{
	// Nothing to do here for now
}

void GumpPaperdoll::Setup(int npcId)
{
	m_npcId = npcId;
	// Map NPC ID to paperdoll type
	// NPC IDs: 0=Avatar, 1=Iolo, 2=Shamino, 3=Dupre, 4=Spark, 5=Sentri, 6=Tseramed, 7=Jaana, 8=Katrina, 9=Julia
	switch (npcId)
	{
		case 0:  // Avatar
			if (g_Player->GetIsMale())
				m_paperdollType = static_cast<int>(PaperdollType::PAPERDOLL_MALE_AVATAR);
			else
				m_paperdollType = static_cast<int>(PaperdollType::PAPERDOLL_FEMALE_AVATAR);
			break;
		case 1:  // Iolo
			m_paperdollType = static_cast<int>(PaperdollType::PAPERDOLL_IOLO);
			break;
		case 2:  // Shamino
			m_paperdollType = static_cast<int>(PaperdollType::PAPERDOLL_SHAMINO);
			break;
		case 3:  // Dupre
			m_paperdollType = static_cast<int>(PaperdollType::PAPERDOLL_DUPRE);
			break;
		case 4:  // Spark
			m_paperdollType = static_cast<int>(PaperdollType::PAPERDOLL_SPARK);
			break;
		case 5:  // Sentri
			m_paperdollType = static_cast<int>(PaperdollType::PAPERDOLL_SENTRI);
			break;
		case 6:  // Tseramed
			m_paperdollType = static_cast<int>(PaperdollType::PAPERDOLL_TSERAMED);
			break;
		case 7:  // Jaana
			m_paperdollType = static_cast<int>(PaperdollType::PAPERDOLL_JAANA);
			break;
		case 8:  // Katrina
			m_paperdollType = static_cast<int>(PaperdollType::PAPERDOLL_KATRINA);
			break;
		case 9:  // Julia
			m_paperdollType = static_cast<int>(PaperdollType::PAPERDOLL_JULIA);
			break;
		default:
			// Unknown NPC, default to Iolo paperdoll
			Log("WARNING: Unknown NPC ID " + std::to_string(npcId) + ", defaulting to Iolo paperdoll");
			m_paperdollType = static_cast<int>(PaperdollType::PAPERDOLL_IOLO);
			break;
	}

	// Cache the paperdoll data
	m_data = m_paperdollData[m_paperdollType];

	Log("GumpPaperdoll::Setup - NPC " + std::to_string(npcId) + ", type " + std::to_string(m_paperdollType));

#define DEBUG_PAPERDOLLS 1
#ifdef DEBUG_PAPERDOLLS
	// Create Debug/Paperdolls folder if it doesn't exist
	std::filesystem::create_directories("Debug/Paperdolls");

	// Load the biggumps texture
	Texture* biggumps = g_ResourceManager->GetTexture(GUMPS_TEXTURE_PATH);
	if (biggumps)
	{
		Image paperdollImage = LoadImageFromTexture(*biggumps);

		// Loop through all paperdoll types and extract them
		for (int i = 0; i < static_cast<int>(PaperdollType::PAPERDOLL_LAST); i++)
		{
			PaperdollData data = m_paperdollData[i];

			// Skip entries with zero coordinates (not yet mapped)
			if (data.m_texturePos.x == 0 && data.m_texturePos.y == 0)
				continue;

			// Extract the paperdoll region from the texture
			Image cropped = ImageFromImage(paperdollImage,
				Rectangle{
					data.m_texturePos.x,
					data.m_texturePos.y,
					data.m_textureSize.x,
					data.m_textureSize.y
				});

			// Build filename based on paperdoll type
			std::string filename = "Debug/Paperdolls/paperdoll_" + std::to_string(i) + ".png";

			// Save the cropped image
			ExportImage(cropped, filename.c_str());

			// Clean up
			UnloadImage(cropped);

			Log("DEBUG: Saved paperdoll image to " + filename);
		}

		// Clean up
		UnloadImage(paperdollImage);
	}
#endif
}

void GumpPaperdoll::OnEnter()
{
	Log("GumpPaperdoll::OnEnter - NPC " + std::to_string(m_npcId));

	// Position paperdoll on screen with cascading offsets for multiple paperdolls
	// Count how many paperdolls are already open
	int paperdollCount = 0;
	for (const auto& gump : g_gumpManager->m_GumpList)
	{
		if (dynamic_cast<GumpPaperdoll*>(gump.get()))
		{
			paperdollCount++;
		}
	}

	// Cascade position: each new paperdoll offset by 30 pixels right and down
	const int CASCADE_OFFSET = 30;
	m_Pos.x = 100 + (paperdollCount * CASCADE_OFFSET);
	m_Pos.y = 100 + (paperdollCount * CASCADE_OFFSET);

	// Set up GUI layout
	m_gui.m_Font = g_SmallFont;
	m_gui.SetLayout(m_Pos.x, m_Pos.y, m_data.m_textureSize.x, m_data.m_textureSize.y, g_DrawScale, Gui::GUIP_USE_XY);

	// Load paperdoll GUI from paperdoll.ghost file
	m_serializer = std::make_unique<GhostSerializer>();
	GhostSerializer::SetBaseFontPath("Fonts/");
	GhostSerializer::SetBaseSpritePath("Images/");

	if (m_serializer->LoadFromFile("GUI/paperdoll.ghost", &m_gui))
	{
		Log("GumpPaperdoll::OnEnter - Successfully loaded paperdoll.ghost");

		// Keep loaded fonts alive
		m_loadedFonts = m_serializer->GetLoadedFonts();

		// Update the PAPERDOLL sprite to use the correct paperdoll type
		int paperdollSpriteID = m_serializer->GetElementID("PAPERDOLL");
		if (paperdollSpriteID != -1)
		{
			auto paperdollSprite = m_gui.GetElement(paperdollSpriteID);
			if (paperdollSprite && paperdollSprite->m_Type == GUI_SPRITE)
			{
				auto sprite = static_cast<GuiSprite*>(paperdollSprite.get());
				// Update sprite source rectangle to match the selected paperdoll type
				sprite->m_Sprite->m_sourceRect = Rectangle{
					m_data.m_texturePos.x,
					m_data.m_texturePos.y,
					m_data.m_textureSize.x,
					m_data.m_textureSize.y
				};
			}
		}

		// Set the CLOSE button as the done button
		int closeButtonID = m_serializer->GetElementID("CLOSE");
		if (closeButtonID != -1)
		{
			m_gui.SetDoneButtonId(closeButtonID);
		}

		// Debug: Check cycle button states
		int peaceID = m_serializer->GetElementID("PEACE");
		int haloID = m_serializer->GetElementID("HALO");
		int formationID = m_serializer->GetElementID("FORMATION");

		if (peaceID != -1)
		{
			auto peaceElem = m_gui.GetElement(peaceID);
			if (peaceElem && peaceElem->m_Type == GUI_CYCLE)
			{
				auto cycle = static_cast<GuiCycle*>(peaceElem.get());
				Rectangle hitRect = {
					m_gui.m_Pos.x + peaceElem->m_Pos.x,
					m_gui.m_Pos.y + peaceElem->m_Pos.y,
					peaceElem->m_Width * cycle->m_ScaleX,
					peaceElem->m_Height * cycle->m_ScaleY
				};
				Log("PEACE button - ID: " + std::to_string(peaceID) + ", Active: " + std::to_string(peaceElem->m_Active) +
					", Visible: " + std::to_string(peaceElem->m_Visible) + ", Type: " + std::to_string(peaceElem->m_Type) +
					", FrameCount: " + std::to_string(cycle->m_FrameCount) + ", Frames size: " + std::to_string(cycle->m_Frames.size()) +
					", HitRect: (" + std::to_string((int)hitRect.x) + "," + std::to_string((int)hitRect.y) + "," +
					std::to_string((int)hitRect.width) + "," + std::to_string((int)hitRect.height) + ")");
			}
		}
		if (haloID != -1)
		{
			auto haloElem = m_gui.GetElement(haloID);
			if (haloElem && haloElem->m_Type == GUI_CYCLE)
			{
				auto cycle = static_cast<GuiCycle*>(haloElem.get());
				Log("HALO button - ID: " + std::to_string(haloID) + ", Active: " + std::to_string(haloElem->m_Active) +
					", Visible: " + std::to_string(haloElem->m_Visible) + ", Type: " + std::to_string(haloElem->m_Type) +
					", FrameCount: " + std::to_string(cycle->m_FrameCount) + ", Frames size: " + std::to_string(cycle->m_Frames.size()));
			}
		}
		if (formationID != -1)
		{
			auto formationElem = m_gui.GetElement(formationID);
			if (formationElem && formationElem->m_Type == GUI_CYCLE)
			{
				auto cycle = static_cast<GuiCycle*>(formationElem.get());
				Log("FORMATION button - ID: " + std::to_string(formationID) + ", Active: " + std::to_string(formationElem->m_Active) +
					", Visible: " + std::to_string(formationElem->m_Visible) + ", Type: " + std::to_string(formationElem->m_Type) +
					", FrameCount: " + std::to_string(cycle->m_FrameCount) + ", Frames size: " + std::to_string(cycle->m_Frames.size()));
			}
		}
	}
	else
	{
		Log("ERROR: GumpPaperdoll::OnEnter - Failed to load paperdoll.ghost");
	}

	// Make the paperdoll draggable
	m_gui.m_Draggable = true;

	// Set up pixel-perfect drag area validation
	m_gui.m_DragAreaValidationCallback = [this](Vector2 mousePos) {
		return this->IsMouseOverSolidPixel(mousePos);
	};

	// Store texture reference for pixel-perfect collision
	m_backgroundTexture = g_ResourceManager->GetTexture(GUMPS_TEXTURE_PATH);

	// Debug: Log GUI bounds for collision detection
	Log("GumpPaperdoll::OnEnter - GUI bounds: pos(" + std::to_string(m_gui.m_Pos.x) + ", " + std::to_string(m_gui.m_Pos.y) +
		") size(" + std::to_string(m_gui.m_Width) + ", " + std::to_string(m_gui.m_Height) + ")");
}

void GumpPaperdoll::Update()
{
	// Debug: Log accepting input state
	static bool loggedOnce = false;
	if (!loggedOnce)
	{
		Log("GumpPaperdoll::Update - m_gui.m_AcceptingInput: " + std::to_string(m_gui.m_AcceptingInput) +
			", m_gui.m_Active: " + std::to_string(m_gui.m_Active));
		loggedOnce = true;
	}

	// Update GUI elements
	m_gui.Update();

	// Ensure GUI position stays integer-aligned (like Gump does)
	m_gui.m_Pos.x = int(m_gui.m_Pos.x);
	m_gui.m_Pos.y = int(m_gui.m_Pos.y);

	// Handle cycle button clicks
	int peaceID = m_serializer->GetElementID("PEACE");
	int haloID = m_serializer->GetElementID("HALO");
	int formationID = m_serializer->GetElementID("FORMATION");

	// Log active element every frame for debugging
	static int lastActiveElement = -999;
	if (m_gui.m_ActiveElement != lastActiveElement && m_gui.m_ActiveElement != -1)
	{
		Log("GumpPaperdoll::Update - m_ActiveElement changed to: " + std::to_string(m_gui.m_ActiveElement));
		lastActiveElement = m_gui.m_ActiveElement;
	}

	if (m_gui.m_ActiveElement == peaceID)
	{
		Log("PEACE button clicked, frame: " + std::to_string(m_gui.GetElement(peaceID)->GetValue()));
	}
	else if (m_gui.m_ActiveElement == haloID)
	{
		Log("HALO button clicked, frame: " + std::to_string(m_gui.GetElement(haloID)->GetValue()));
	}
	else if (m_gui.m_ActiveElement == formationID)
	{
		Log("FORMATION button clicked, frame: " + std::to_string(m_gui.GetElement(formationID)->GetValue()));
	}

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

void GumpPaperdoll::Draw()
{
	// Update slot sprites to show equipped items
	auto it = g_NPCData.find(m_npcId);
	if (it != g_NPCData.end() && it->second)
	{
		NPCData* npcData = it->second.get();

		// Slot name mapping
		const char* slotNames[] = {
			"SLOT_HEAD", "SLOT_NECK", "SLOT_TORSO", "SLOT_LEGS", "SLOT_HANDS", "SLOT_FEET",
			"SLOT_LEFT_HAND", "SLOT_RIGHT_HAND", "SLOT_AMMO", "SLOT_LEFT_RING",
			"SLOT_RIGHT_RING", "SLOT_BELT", "SLOT_BACKPACK"
		};

		for (int i = 0; i < static_cast<int>(EquipmentSlot::SLOT_COUNT); i++)
		{
			EquipmentSlot slot = static_cast<EquipmentSlot>(i);
			int slotSpriteID = m_serializer->GetElementID(slotNames[i]);

			if (slotSpriteID != -1)
			{
				auto slotElement = m_gui.GetElement(slotSpriteID);
				if (slotElement && slotElement->m_Type == GUI_SPRITE)
				{
					auto slotSprite = static_cast<GuiSprite*>(slotElement.get());
					int objectId = npcData->GetEquippedItem(slot);

					if (objectId != -1)
					{
						// Item is equipped - show the item's texture
						auto objIt = g_objectList.find(objectId);
						if (objIt != g_objectList.end() && objIt->second && objIt->second->m_shapeData)
						{
							U7Object* obj = objIt->second.get();
							Texture* itemTexture = obj->m_shapeData->GetTexture();
							if (itemTexture && slotSprite->m_Sprite)
							{
								slotSprite->m_Sprite->m_texture = itemTexture;
							}
						}
					}
					else
					{
						// No item equipped - hide the sprite by setting texture to nullptr
						if (slotSprite->m_Sprite)
						{
							slotSprite->m_Sprite->m_texture = nullptr;
						}
					}
				}
			}
		}
	}

	// Draw all GUI elements (including slot sprites)
	m_gui.Draw();
}

bool GumpPaperdoll::IsMouseOverSolidPixel(Vector2 mousePos)
{
	// If no texture, default to solid
	if (!m_backgroundTexture)
		return true;

	// Convert mouse position to local paperdoll coordinates
	float localX = mousePos.x - m_gui.m_Pos.x;
	float localY = mousePos.y - m_gui.m_Pos.y;

	// Calculate pixel position in the source texture
	int texX = int(m_data.m_texturePos.x + localX);
	int texY = int(m_data.m_texturePos.y + localY);

	// Load the texture as an image to check pixel alpha
	Image img = LoadImageFromTexture(*m_backgroundTexture);

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
