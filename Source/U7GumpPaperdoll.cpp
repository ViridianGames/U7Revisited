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
	Texture* biggumps = g_ResourceManager->GetTexture("Images/GUI/biggumps.png");
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

	// Position paperdoll on screen
	// TODO: Better positioning logic (maybe cascade based on number of open paperdolls)
	m_Pos.x = 100;
	m_Pos.y = 100;

	// Set up GUI layout
	m_gui.m_Font = g_SmallFont;
	m_gui.SetLayout(m_Pos.x, m_Pos.y, m_data.m_textureSize.x, m_data.m_textureSize.y, g_DrawScale, Gui::GUIP_USE_XY);

	// Add paperdoll background sprite
	m_gui.AddSprite(1000, 0, 0,
		std::make_shared<Sprite>(g_ResourceManager->GetTexture("Images/GUI/biggumps.png", false),
			m_data.m_texturePos.x, m_data.m_texturePos.y,
			m_data.m_textureSize.x, m_data.m_textureSize.y),
		1, 1, Color{255, 255, 255, 255});

	// Add close button (checkmark) near bottom-left corner
	// Y position = paperdoll height - checkmark height - small margin
	// Paperdoll height is 205, checkmark is ~32px, so position at ~159
	m_gui.AddIconButton(1001, 4, 159, g_gumpCheckmarkUp, g_gumpCheckmarkDown, g_gumpCheckmarkUp, "", g_SmallFont.get(), Color{255, 255, 255, 255}, 1, 0, 1, false);

	// Set the close button as the done button
	m_gui.SetDoneButtonId(1001);

	// Make the paperdoll draggable
	m_gui.m_Draggable = true;

	// Set up pixel-perfect drag area validation
	m_gui.m_DragAreaValidationCallback = [this](Vector2 mousePos) {
		return this->IsMouseOverSolidPixel(mousePos);
	};

	// Store texture reference for pixel-perfect collision
	m_backgroundTexture = g_ResourceManager->GetTexture("Images/GUI/biggumps.png");

	// Debug: Log GUI bounds for collision detection
	Log("GumpPaperdoll::OnEnter - GUI bounds: pos(" + std::to_string(m_gui.m_Pos.x) + ", " + std::to_string(m_gui.m_Pos.y) +
		") size(" + std::to_string(m_gui.m_Width) + ", " + std::to_string(m_gui.m_Height) + ")");
}

void GumpPaperdoll::Update()
{
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

void GumpPaperdoll::Draw()
{
	// Draw GUI elements first (background will be added as sprite)
	m_gui.Draw();

	// Draw equipped items
	auto it = g_NPCData.find(m_npcId);
	if (it != g_NPCData.end() && it->second)
	{
		NPCData* npcData = it->second.get();
		for (int i = 0; i < static_cast<int>(EquipmentSlot::SLOT_COUNT); i++)
		{
			EquipmentSlot slot = static_cast<EquipmentSlot>(i);
			int objectId = npcData->GetEquippedItem(slot);

			if (objectId != -1)
			{
				auto objIt = g_objectList.find(objectId);
				if (objIt != g_objectList.end() && objIt->second && objIt->second->m_shapeData)
				{
					// Draw equipped item sprite at slot position
					U7Object* obj = objIt->second.get();
					Rectangle slotRect = m_slotRects[i];
					Texture* itemTexture = obj->m_shapeData->GetTexture();
					if (itemTexture)
					{
						DrawTextureEx(*itemTexture,
							Vector2{ m_gui.m_Pos.x + slotRect.x, m_gui.m_Pos.y + slotRect.y },
							0, 1, WHITE);
					}
				}
			}
		}
	}
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
