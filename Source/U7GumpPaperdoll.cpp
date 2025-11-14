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
extern std::shared_ptr<Font> g_ConversationFont;
extern float g_DrawScale;
extern std::shared_ptr<Sprite> g_gumpCheckmarkUp;
extern std::shared_ptr<Sprite> g_gumpCheckmarkDown;

GumpPaperdoll::GumpPaperdoll()
	: m_npcId(-1)
	, m_paperdollType(0)
	, m_data{}
	, m_backgroundTexture(nullptr)
	, m_hoverText("")
	, m_hoverTextDuration(0.0f)
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

// #define DEBUG_PAPERDOLLS 1
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

	// Set up drag area validation: allow dragging from solid background but not from slots/buttons
	m_gui.m_DragAreaValidationCallback = [this](Vector2 mousePos) {
		return this->IsMouseOverSolidPixel(mousePos) && !this->IsOverSlot(mousePos);
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

	// Slot names array - shared by multiple sections
	static const char* slotNames[] = {
		"SLOT_HEAD", "SLOT_NECK", "SLOT_TORSO", "SLOT_LEGS", "SLOT_HANDS", "SLOT_FEET",
		"SLOT_LEFT_HAND", "SLOT_RIGHT_HAND", "SLOT_AMMO", "SLOT_LEFT_RING", "SLOT_RIGHT_RING",
		"SLOT_BELT", "SLOT_BACKPACK"
	};

	// Handle slot highlighting when dragging over paperdoll
	Vector2 mousePos = GetMousePosition();
	mousePos.x /= g_DrawScale;
	mousePos.y /= g_DrawScale;

	bool shouldHighlight = false;
	std::vector<EquipmentSlot> validSlots;

	if (g_gumpManager->m_draggingObject && g_gumpManager->m_draggedObjectId != -1)
	{
		// Check if THIS paperdoll is the topmost gump under the mouse cursor
		if (g_gumpManager->GetGumpUnderMouse() == this)
		{
			// Get the dragged object
			auto objIt = g_objectList.find(g_gumpManager->m_draggedObjectId);
			if (objIt != g_objectList.end() && objIt->second && objIt->second->m_shapeData)
			{
				int shape = objIt->second->m_shapeData->GetShape();
				validSlots = GetEquipmentSlotsForShape(shape);

				if (!validSlots.empty())
				{
					shouldHighlight = true;
					static bool loggedOnce = false;
					if (!loggedOnce)
					{
						Log("Paperdoll - Highlighting enabled for shape " + std::to_string(shape) + ", " + std::to_string(validSlots.size()) + " valid slots");
						loggedOnce = true;
					}
				}
			}
		}
	}

	// Determine which slots should be highlighted
	m_highlightedSlots.clear();
	if (shouldHighlight)
	{
		auto npcData = g_NPCData[m_npcId].get();
		for (int i = 0; i < 13; i++)
		{
			EquipmentSlot slot = static_cast<EquipmentSlot>(i);
			bool isValidSlot = std::find(validSlots.begin(), validSlots.end(), slot) != validSlots.end();
			bool isEmpty = npcData->GetEquippedItem(slot) == -1;

			if (isValidSlot && isEmpty)
			{
				m_highlightedSlots.insert(i);
				static int logCount = 0;
				if (logCount < 5)
				{
					Log("Paperdoll - Will highlight slot " + std::to_string(i) + " (" + std::string(slotNames[i]) + ")");
					logCount++;
				}
			}
		}
	}

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

	// Handle equipment slot clicks
	auto npcIt = g_NPCData.find(m_npcId);
	if (npcIt != g_NPCData.end() && npcIt->second)
	{
		NPCData* npcData = npcIt->second.get();

		// Get mouse position in GUI space
		Vector2 mousePos = GetMousePosition();
		mousePos.x /= g_DrawScale;
		mousePos.y /= g_DrawScale;

		// Reset drag start if mouse button is released
		if (!IsMouseButtonDown(MOUSE_LEFT_BUTTON))
		{
			m_dragStart = {0, 0};
		}

		for (int i = 0; i < static_cast<int>(EquipmentSlot::SLOT_COUNT); i++)
		{
			int slotID = m_serializer->GetElementID(slotNames[i]);
			if (slotID != -1)
			{
				auto element = m_gui.GetElement(slotID);
				if (element)
				{
					GuiSprite* slotSprite = dynamic_cast<GuiSprite*>(element.get());
					if (slotSprite && slotSprite->m_Sprite)
					{
						// Check if mouse is over this slot
						Rectangle slotRect = {
							m_gui.m_Pos.x + slotSprite->m_Pos.x,
							m_gui.m_Pos.y + slotSprite->m_Pos.y,
							slotSprite->m_Sprite->m_sourceRect.width,
							slotSprite->m_Sprite->m_sourceRect.height
						};

						if (CheckCollisionPointRec(mousePos, slotRect))
						{
							EquipmentSlot slot = static_cast<EquipmentSlot>(i);
							int objectId = npcData->GetEquippedItem(slot);

							// Check for double-click on backpack
							if (slot == EquipmentSlot::SLOT_BACKPACK && objectId != -1)
							{
								if (WasMouseButtonDoubleClicked(MOUSE_BUTTON_LEFT))
								{
									Log("Paperdoll - Double-click on backpack, opening gump for objectId=" + std::to_string(objectId));
									// Open the backpack gump
									if (g_mainState)
									{
										Log("Paperdoll - Calling g_mainState->OpenGump(" + std::to_string(objectId) + ")");
										g_mainState->OpenGump(objectId);
										Log("Paperdoll - OpenGump returned successfully");
									}
									else
									{
										Log("Paperdoll - ERROR: g_mainState is null!");
									}
									break; // Don't process bark after opening gump
								}
							}

							// Check for double-click on spellbook (shape 761)
							if (objectId != -1)
							{
								auto objIt = g_objectList.find(objectId);
								if (objIt != g_objectList.end() && objIt->second->m_shapeData && objIt->second->m_shapeData->m_shape == 761)
								{
									if (WasMouseButtonDoubleClicked(MOUSE_BUTTON_LEFT))
									{
										Log("Paperdoll - Double-click on spellbook, opening spellbook gump for NPC=" + std::to_string(m_npcId));
										// Open the spellbook gump
										if (g_mainState)
										{
											g_mainState->OpenSpellbookGump(m_npcId);
										}
										else
										{
											Log("Paperdoll - ERROR: g_mainState is null!");
										}
										break; // Don't process bark after opening gump
									}
								}
							}

							// Handle drag start for equipped items
							if (objectId != -1 && IsMouseButtonDown(MOUSE_LEFT_BUTTON))
							{
								// Track drag start position
								if (m_dragStart.x == 0 && m_dragStart.y == 0)
								{
									m_dragStart = mousePos;
								}

								// If mouse moved enough, start dragging
								if (Vector2DistanceSqr(m_dragStart, mousePos) > 4 && !g_gumpManager->m_draggingObject)
								{
									// Start dragging this equipped item
									g_gumpManager->m_draggedObjectId = objectId;
									g_gumpManager->m_draggingObject = true;
									g_gumpManager->m_sourceGump = this;
									g_gumpManager->m_sourceSlotIndex = i;  // Remember which slot we dragged from

									// Close any gump associated with this object to prevent dragging into itself
									g_gumpManager->CloseGumpForObject(objectId);

									// Unequip from ALL slots this item fills
									auto objIt = g_objectList.find(objectId);
									// Center the drag image on the cursor
									if (objIt != g_objectList.end() && objIt->second && objIt->second->m_shapeData)
									{
										auto& img = objIt->second->m_shapeData->GetDefaultTextureImage();
										g_gumpManager->m_draggedObjectOffset = {-img.width / 2.0f, -img.height / 2.0f};
									}
									if (objIt != g_objectList.end() && objIt->second && objIt->second->m_shapeData)
									{
										int shape = objIt->second->m_shapeData->GetShape();

										// If it's a spellbook (shape 761), close the spellbook gump
										if (shape == 761)
										{
											g_gumpManager->CloseSpellbookForNpc(m_npcId);
										}
										std::vector<EquipmentSlot> fillSlots = GetEquipmentSlotsFilled(shape);

										// If item has explicit fills, clear all those slots
										// Otherwise just clear the clicked slot
										if (!fillSlots.empty())
										{
											for (EquipmentSlot fillSlot : fillSlots)
											{
												npcData->UnequipItem(fillSlot);
											}
											Log("Started dragging equipped item from slot " + std::to_string(i) + ", objectId=" + std::to_string(objectId) +
											    " (cleared " + std::to_string(fillSlots.size()) + " fills slots)");
										}
										else
										{
											// Single-slot item - just clear the clicked slot
											npcData->UnequipItem(static_cast<EquipmentSlot>(i));
											Log("Started dragging equipped item from slot " + std::to_string(i) + ", objectId=" + std::to_string(objectId));
										}
									}

									break;
								}
							}

							// Single click (without drag): show item name
							if (objectId != -1 && IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
							{
								Log("Paperdoll - Single click on slot " + std::to_string(i) + ", objectId=" + std::to_string(objectId));
								auto objIt = g_objectList.find(objectId);
								if (objIt != g_objectList.end() && objIt->second)
								{
									U7Object* obj = objIt->second.get();
									if (obj->m_shapeData)
									{
										int quantity = (obj->m_Quality > 0) ? obj->m_Quality : 1;
										m_hoverText = GetShapeFrameName(obj->m_shapeData->GetShape(), obj->m_shapeData->GetFrame(), quantity);
										Log("Paperdoll - Showing hover text: " + m_hoverText);
										m_hoverTextDuration = 2.0f;

										// Calculate screen position from GUI coordinates
										float screenX = (m_gui.m_Pos.x + slotSprite->m_Pos.x + slotSprite->m_Sprite->m_sourceRect.width / 2.0f);
										float screenY = (m_gui.m_Pos.y + slotSprite->m_Pos.y);
										m_hoverTextPos.x = screenX;
										m_hoverTextPos.y = screenY;

										Log("Hover text position: screen(" + std::to_string(screenX) + ", " + std::to_string(screenY) +
											") gui.pos(" + std::to_string(m_gui.m_Pos.x) + ", " + std::to_string(m_gui.m_Pos.y) +
											") slot.pos(" + std::to_string(slotSprite->m_Pos.x) + ", " + std::to_string(slotSprite->m_Pos.y) + ")");
									}
								}
								break; // Don't process multiple slots
							}
						}
					}
				}
			}
		}
	}

	// Update hover text timer
	if (m_hoverTextDuration > 0.0f)
	{
		m_hoverTextDuration -= GetFrameTime();
		if (m_hoverTextDuration <= 0.0f)
		{
			m_hoverText.clear();
		}
	}

	// Also allow ESC key to close
	if (IsKeyPressed(KEY_ESCAPE))
	{
		OnExit();
	}
}

// Helper function to update a sprite's texture and resize it
static void SetSpriteTexture(GuiSprite* sprite, Texture* texture)
{
	if (!sprite || !sprite->m_Sprite || !texture)
		return;

	sprite->m_Sprite->m_texture = texture;
	sprite->m_Sprite->m_sourceRect.x = 0;
	sprite->m_Sprite->m_sourceRect.y = 0;
	sprite->m_Sprite->m_sourceRect.width = texture->width;
	sprite->m_Sprite->m_sourceRect.height = texture->height;
	sprite->m_Width = texture->width;
	sprite->m_Height = texture->height;
}

void GumpPaperdoll::Draw()
{
	// Update CARRY text area to show weight
	int carryTextID = m_serializer->GetElementID("CARRY");
	if (carryTextID != -1)
	{
		auto carryElement = m_gui.GetElement(carryTextID);
		if (carryElement && carryElement->m_Type == GUI_TEXTAREA)
		{
			auto carryText = static_cast<GuiTextArea*>(carryElement.get());

			// Get the NPC's object to calculate weight
			auto npcIt = g_NPCData.find(m_npcId);
			if (npcIt != g_NPCData.end() && npcIt->second)
			{
				U7Object* npcObject = g_objectList[npcIt->second->m_objectID].get();
				if (npcObject)
				{
					int currentWeight = static_cast<int>(npcObject->GetWeight());
					int maxWeight = static_cast<int>(g_Player->GetMaxWeight()); // For now all NPCs use Avatar's max weight
					carryText->m_String = std::to_string(currentWeight) + "/" + std::to_string(maxWeight);
				}
			}
		}
	}

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

		// Debug: Log equipment check
		static bool loggedOnce = false;
		if (!loggedOnce && m_npcId == 0)
		{
			Log("Paperdoll Draw - Checking equipment for NPC " + std::to_string(m_npcId));
			loggedOnce = true;
		}

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

					// Debug: Log what we find
					static int debugCount = 0;
					if (debugCount < 13 && m_npcId == 0)
					{
						if (objectId != -1)
						{
							auto objIt = g_objectList.find(objectId);
							if (objIt != g_objectList.end() && objIt->second)
							{
								int shape = objIt->second->m_shapeData ? objIt->second->m_shapeData->GetShape() : -1;
								Log("Paperdoll - " + std::string(slotNames[i]) + " has objectId=" + std::to_string(objectId) + ", shape=" + std::to_string(shape));
							}
						}
						else
						{
							Log("Paperdoll - " + std::string(slotNames[i]) + " is EMPTY");
						}
						debugCount++;
					}

					// Update slot texture based on equipped item (highlighting is done separately via border drawing)
					if (objectId != -1)
					{
						// Item is equipped - show the item's texture
						auto objIt = g_objectList.find(objectId);
						if (objIt != g_objectList.end() && objIt->second && objIt->second->m_shapeData)
						{
							U7Object* obj = objIt->second.get();
							Texture* itemTexture = obj->m_shapeData->GetTexture();

							// Debug: Log texture info
							static int textureLogCount = 0;
							if (textureLogCount < 10 && m_npcId == 0 && itemTexture)
							{
								Log("Paperdoll - Setting texture for " + std::string(slotNames[i]) +
									": texture=" + std::to_string((long long)itemTexture) +
									", size=" + std::to_string(itemTexture->width) + "x" + std::to_string(itemTexture->height));
								textureLogCount++;
							}

							SetSpriteTexture(slotSprite, itemTexture);
						}
						else
						{
							// Debug: Log why texture failed
							static int failLogCount = 0;
							if (failLogCount < 5 && m_npcId == 0)
							{
								Log("Paperdoll - FAILED to get texture for " + std::string(slotNames[i]) +
									": objFound=" + std::string((objIt != g_objectList.end()) ? "yes" : "no") +
									", objValid=" + std::string((objIt != g_objectList.end() && objIt->second) ? "yes" : "no") +
									", hasShapeData=" + std::string((objIt != g_objectList.end() && objIt->second && objIt->second->m_shapeData) ? "yes" : "no"));
								failLogCount++;
							}
						}
					}
					else
					{
						// No item equipped - use empty texture
						SetSpriteTexture(slotSprite, g_EmptyTexture);
					}
				}
			}
		}
	}

	// Draw all GUI elements (including slot sprites)
	m_gui.Draw();

	// Draw green borders around highlighted slots
	if (!m_highlightedSlots.empty())
	{
		static const char* slotNames[] = {
			"SLOT_HEAD", "SLOT_NECK", "SLOT_TORSO", "SLOT_LEGS", "SLOT_HANDS", "SLOT_FEET",
			"SLOT_LEFT_HAND", "SLOT_RIGHT_HAND", "SLOT_AMMO", "SLOT_LEFT_RING", "SLOT_RIGHT_RING",
			"SLOT_BELT", "SLOT_BACKPACK"
		};

		for (int slotIndex : m_highlightedSlots)
		{
			int slotID = m_serializer->GetElementID(slotNames[slotIndex]);
			if (slotID != -1)
			{
				auto element = m_gui.GetElement(slotID);
				if (element)
				{
					GuiSprite* slotSprite = dynamic_cast<GuiSprite*>(element.get());
					if (slotSprite)
					{
						// Draw green border around the slot (use at least 16x16 for empty slots)
						float width = slotSprite->m_Width * slotSprite->m_ScaleX;
						float height = slotSprite->m_Height * slotSprite->m_ScaleY;
						if (width < 16.0f) width = 16.0f;
						if (height < 16.0f) height = 16.0f;

						Rectangle slotRect = {
							m_gui.m_Pos.x + slotSprite->m_Pos.x,
							m_gui.m_Pos.y + slotSprite->m_Pos.y,
							width,
							height
						};
						DrawRectangleLinesEx(slotRect, 1.0f, Color{ 0, 255, 0, 200 });
					}
				}
			}
		}
	}

	// Draw hover text if active (uses same style as bark text)
	if (!m_hoverText.empty() && m_hoverTextDuration > 0.0f)
	{
		// Measure text with conversation font
		float width = MeasureTextEx(*g_ConversationFont, m_hoverText.c_str(), g_ConversationFont->baseSize, 1).x * 1.2f;
		float height = g_ConversationFont->baseSize * 1.2f;

		// Center text horizontally at stored slot position, slightly above
		Vector2 textPos = {
			m_hoverTextPos.x - width / 2.0f,
			m_hoverTextPos.y - height - 5.0f  // Above slot
		};

		// Draw rounded rectangle background (pill-shaped, semi-transparent)
		DrawRectangleRounded({textPos.x, textPos.y, width, height}, 5.0f, 10, Color{0, 0, 0, 192});

		// Draw text in yellow (same as bark)
		DrawTextEx(*g_ConversationFont, m_hoverText.c_str(),
			{ textPos.x + (width * 0.1f), textPos.y + (height * 0.1f) },
			g_ConversationFont->baseSize, 1, YELLOW);
	}
}

bool GumpPaperdoll::IsOverSlot(Vector2 mousePos)
{
	// Check if mouse is over any equipment slots or buttons
	const char* slotNames[] = {
		"SLOT_HEAD", "SLOT_NECK", "SLOT_TORSO", "SLOT_LEGS", "SLOT_HANDS", "SLOT_FEET",
		"SLOT_LEFT_HAND", "SLOT_RIGHT_HAND", "SLOT_AMMO", "SLOT_LEFT_RING", "SLOT_RIGHT_RING",
		"SLOT_BELT", "SLOT_BACKPACK"
	};

	for (int i = 0; i < 13; i++)
	{
		int slotID = m_serializer->GetElementID(slotNames[i]);
		if (slotID != -1)
		{
			auto element = m_gui.GetElement(slotID);
			if (element)
			{
				GuiSprite* slotSprite = dynamic_cast<GuiSprite*>(element.get());
				if (slotSprite && slotSprite->m_Sprite)
				{
					Rectangle slotRect = {
						m_gui.m_Pos.x + slotSprite->m_Pos.x,
						m_gui.m_Pos.y + slotSprite->m_Pos.y,
						slotSprite->m_Sprite->m_sourceRect.width,
						slotSprite->m_Sprite->m_sourceRect.height
					};

					if (CheckCollisionPointRec(mousePos, slotRect))
					{
						return true;
					}
				}
			}
		}
	}

	// Check for buttons (HEART, CLOSE, DISK, etc.)
	const char* buttonNames[] = {"HEART", "CLOSE", "DISK", "PEACE", "HALO", "FORMATION"};
	for (int i = 0; i < 6; i++)
	{
		int buttonID = m_serializer->GetElementID(buttonNames[i]);
		if (buttonID != -1)
		{
			auto element = m_gui.GetElement(buttonID);
			if (element)
			{
				Rectangle btnRect = element->GetBounds();
				btnRect.x += m_gui.m_Pos.x;
				btnRect.y += m_gui.m_Pos.y;
				if (CheckCollisionPointRec(mousePos, btnRect))
				{
					return true;
				}
			}
		}
	}

	return false;
}

bool GumpPaperdoll::IsMouseOverSolidPixel(Vector2 mousePos)
{
	// Check if over solid background pixel (transparent areas let world clicks through)
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
