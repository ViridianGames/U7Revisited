#include <fstream>
#include <string>
#include <sstream>
#include <algorithm>

#include "U7Gump.h"
#include "Geist/Config.h"
#include "Geist/Engine.h"
#include "Geist/Globals.h"
#include "Geist/ResourceManager.h"
#include "Geist/Logging.h"
#include "U7Globals.h"

#include "raylib.h"

using namespace std;

Gump::Gump()
{
	std::vector<Sprite> m_gumpBackgrounds;

	m_gumpBackgrounds.resize(1);

	m_gui.m_PositionFlag = Gui::GUIP_USE_XY;
	m_gui.m_Width = 0;
	m_gui.m_Height = 0;
	m_gui.m_Active = 1;
	m_gui.m_Editing = false;
	m_gui.m_ActiveElement = -1;
	m_gui.m_LastElement = -2;
	m_gui.m_InputScale = 1;
	m_gui.m_Font = make_shared<Font>(GetFontDefault());
	m_gui.m_Draggable = false;  // Dragging is off by default
	m_gui.m_IsDragging = false;
	m_gui.m_DragOffset = { 0, 0 };
	m_gui.m_DragAreaHeight = 20;  // Default title bar height
	m_IsDead = false;
	m_gui.m_doneButtonId = -3;
	m_containerObject = nullptr;
	m_containerId = -1;
}

Gump::~Gump()
{
}

void Gump::OnExit()
{
	m_IsDead = true;

	// Clear any references to the container object to prevent accessing stale pointers
	if (m_containerObject)
	{
		// Reset the sorted flag so the container will re-sort when reopened
		m_containerObject->m_isSorted = false;
		m_containerObject = nullptr;
	}
}

void Gump::OnEnter()
{
	int posx = int(g_NonVitalRNG->Random(150));
	int posy = int(g_NonVitalRNG->Random(150));

	m_containerObject = GetObjectFromID(m_containerId);
	int x = 4, y = 34;

	//  Find out what kind of container this is and set the gump background accordingly
	switch(m_containerObject->m_ObjectType)
	{
		case 788: //  Box
		case 798:
			m_containerData = g_containerData[static_cast<int>(ContainerType::CONTAINER_BOX)];
			break;
		case 804: //  Crate
			m_containerData = g_containerData[static_cast<int>(ContainerType::CONTAINER_CRATE)];
			break;
		case 819: //  Barrel
			m_containerData = g_containerData[static_cast<int>(ContainerType::CONTAINER_BARREL)];
			break;
		case 802: //  Small Sack
			m_containerData = g_containerData[static_cast<int>(ContainerType::CONTAINER_BAG)];
			break;
		case 801: //  Backpack
			m_containerData = g_containerData[static_cast<int>(ContainerType::CONTAINER_BACKPACK)];
			break;
		case 803: //  Basket
			m_containerData = g_containerData[static_cast<int>(ContainerType::CONTAINER_BASKET)];
			break;
		case 800: //  Treasure Chest
		case 522:
			m_containerData = g_containerData[static_cast<int>(ContainerType::CONTAINER_TREASURECHEST)];
			break;
		case 679: //  Drawer
		case 416: //  Drawer
		case 407: //  Drawer
		case 283: //  Drawer
		case 406: //  Nightstand
			m_containerData = g_containerData[static_cast<int>(ContainerType::CONTAINER_DRAWER)];
			break;
		case 507: //  Corpse
			m_containerData = g_containerData[static_cast<int>(ContainerType::CONTAINER_CORPSE)];
			break;
		default:
			m_containerData = g_containerData[static_cast<int>(ContainerType::CONTAINER_BACKPACK)];
			break;
	}

	m_gui.m_Font = g_SmallFont;
	m_gui.SetLayout(posx, posy, 220, 150, g_DrawScale, Gui::GUIP_USE_XY);
	m_gui.AddSprite(1004, 0, 0,
		make_shared<Sprite>(g_ResourceManager->GetTexture("Images/GUI/biggumps.png", false), m_containerData.m_texturePos.x, m_containerData.m_texturePos.y, m_containerData.m_textureSize.x, m_containerData.m_textureSize.y), 1, 1, Color{255, 255, 255, 255});
	int checkX = m_containerData.m_checkMarkOffset.x;
	int checkY = m_containerData.m_checkMarkOffset.y;
	m_gui.AddIconButton(1005, checkX, checkY, g_gumpCheckmarkUp, g_gumpCheckmarkDown, g_gumpCheckmarkUp, "", g_SmallFont.get(), Color{255, 255, 255, 255}, 1, 0, 1, false);

	m_gui.AddStretchButton(1006, checkX + 2, checkY - 16, 28, "Sort",
		g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
		g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM);

	m_gui.SetDoneButtonId(1005);
	m_gui.m_Draggable = true;

	// Set up pixel-perfect drag area validation
	m_gui.m_DragAreaValidationCallback = [this](Vector2 mousePos) {
		return this->IsMouseOverSolidPixel(mousePos);
	};

	U7Object* thisObject = GetObjectFromID(m_containerId);
	if(thisObject->m_shouldBeSorted)
	{
		SortContainer();
	}
}

void Gump::Update()
{
	m_gui.Update();
	m_gui.m_Pos.x = int(m_gui.m_Pos.x);
	m_gui.m_Pos.y = int(m_gui.m_Pos.y);
	if(m_gui.m_ActiveElement == m_gui.m_doneButtonId)
	{
		m_IsDead = true;
	}

	if(m_gui.m_ActiveElement == 1006)
	{
		SortContainer();
	}

	// Handle dragging
	Vector2 mousePos = GetMousePosition();
	mousePos.x = int(mousePos.x /= g_DrawScale);
	mousePos.y = int(mousePos.y /= g_DrawScale);

	if (!IsMouseButtonDown(MOUSE_LEFT_BUTTON))
	{
		m_dragStart = {0, 0};
	}

	//  Are we in the box bounds of the gump AND are we the topmost gump?
	bool isTopmostGump = (g_gumpManager->m_gumpUnderMouse == this);
	if (isTopmostGump && CheckCollisionPointRec(mousePos, Rectangle{ m_gui.m_Pos.x + (m_containerData.m_boxOffset.x), m_gui.m_Pos.y + (m_containerData.m_boxOffset.y),
		m_containerData.m_boxSize.x, m_containerData.m_boxSize.y }))
	{
		// Check for double-click on spellbook or map
		if (WasMouseButtonDoubleClicked(MOUSE_BUTTON_LEFT))
		{
			for (auto containerObjectId : m_containerObject->m_inventory)
			{
				auto object = GetObjectFromID(containerObjectId);
				if (object && object->m_shapeData)
				{
					if (CheckCollisionPointRec(mousePos, Rectangle{ m_gui.m_Pos.x + (m_containerData.m_boxOffset.x * 1) + object->m_InventoryPos.x, m_gui.m_Pos.y + (m_containerData.m_boxOffset.y * 1) + object->m_InventoryPos.y, float(object->m_shapeData->GetDefaultTextureImage().width), float(object->m_shapeData->GetDefaultTextureImage().height) }))
					{
						// Check for spellbook (shape 761)
						if (object->m_shapeData->m_shape == 761)
						{
							Log("Container - Double-click on spellbook, opening spellbook gump");
							if (g_mainState)
							{
								g_mainState->OpenSpellbookGump(0); // Use Avatar's spellbook (NPC ID 0)
							}
							return; // Exit Update to prevent drag handling
						}
						// Check for map (shape 178)
						else if (object->m_shapeData->m_shape == 178)
						{
							Log("Container - Double-click on map, opening minimap gump");
							if (g_mainState)
							{
								g_mainState->OpenMinimapGump(0); // Use Avatar's map (NPC ID 0)
							}
							return; // Exit Update to prevent drag handling
						}
					}
				}
			}
		}

		// Handle single click to show item name
		if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
		{
			for (auto it = m_containerObject->m_inventory.begin(); it != m_containerObject->m_inventory.end(); ++it)
			{
				int containerObjectId = *it;
				auto object = GetObjectFromID(containerObjectId);
				if (object && object->m_shapeData)
				{
					Rectangle itemRect = {
						m_gui.m_Pos.x + (m_containerData.m_boxOffset.x * 1) + object->m_InventoryPos.x,
						m_gui.m_Pos.y + (m_containerData.m_boxOffset.y * 1) + object->m_InventoryPos.y,
						float(object->m_shapeData->GetDefaultTextureImage().width),
						float(object->m_shapeData->GetDefaultTextureImage().height)
					};

					if (CheckCollisionPointRec(mousePos, itemRect))
					{
					// Show item name
					m_hoverText = GetObjectDisplayName(object);
						m_hoverTextDuration = 2.0f;

						// Position text above the item
						m_hoverTextPos.x = itemRect.x + itemRect.width / 2.0f;
						m_hoverTextPos.y = itemRect.y;
						break;
					}
				}
			}
		}

		if (IsMouseButtonDown(MOUSE_LEFT_BUTTON))
		{
			if (m_dragStart.x == 0 && m_dragStart.y == 0)
			{
				m_dragStart = mousePos;
			}

			if (Vector2DistanceSqr(m_dragStart, mousePos) > 4 && !g_gumpManager->m_draggingObject)
			{
				for (auto it = m_containerObject->m_inventory.begin(); it != m_containerObject->m_inventory.end(); ++it)
				{
					int containerObjectId = *it;
					auto object = GetObjectFromID(containerObjectId);
					if (object && object->m_shapeData)
					{
						if (CheckCollisionPointRec(mousePos, Rectangle{ m_gui.m_Pos.x + (m_containerData.m_boxOffset.x * 1) + object->m_InventoryPos.x, m_gui.m_Pos.y + (m_containerData.m_boxOffset.y * 1) + object->m_InventoryPos.y, float(object->m_shapeData->GetDefaultTextureImage().width), float(object->m_shapeData->GetDefaultTextureImage().height) }))
						{
							g_gumpManager->m_draggedObjectId = object->m_ID;
							g_gumpManager->m_draggingObject = true;
							g_gumpManager->m_sourceGump = this;
							g_gumpManager->m_sourceSlotIndex = -1;  // Not from a paperdoll slot

							// Center the drag image on the cursor
							auto img = object->m_shapeData->GetDefaultTextureImage();
							g_gumpManager->m_draggedObjectOffset = {-img.width / 2.0f, -img.height / 2.0f};

							m_containerObject->m_shouldBeSorted = false; //  We are dragging an object, so we no longer need to sort.

							// Close any gump associated with this container object to prevent dragging into itself
							g_gumpManager->CloseGumpForObject(object->m_ID);

							// Remove from inventory immediately when drag starts
							int objectToRemove = *it;
							m_containerObject->RemoveObjectFromInventory(objectToRemove);
							Log("Removed object " + std::to_string(object->m_ID) + " from container on drag start");

							break; //  We found the object we are dragging, so break out of the loop
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
}

U7Object* Gump::GetObjectUnderMousePointer()
{
	// Skip gumps without container objects (paperdolls, spellbooks, etc.)
	//if (m_containerObject == nullptr)
		//return nullptr;

	Vector2 mousePos = GetMousePosition();
	mousePos.x = int(mousePos.x /= g_DrawScale);
	mousePos.y = int(mousePos.y /= g_DrawScale);

	for (auto containerObjectId : m_containerObject->m_inventory)
	{
		auto object = GetObjectFromID(containerObjectId);
		if (object && object->m_shapeData)
		{
			if (CheckCollisionPointRec(mousePos, Rectangle{ m_gui.m_Pos.x + (m_containerData.m_boxOffset.x * 1) + object->m_InventoryPos.x, m_gui.m_Pos.y + (m_containerData.m_boxOffset.y * 1) + object->m_InventoryPos.y, float(object->m_shapeData->GetDefaultTextureImage().width), float(object->m_shapeData->GetDefaultTextureImage().height) }))
			{
				return object;
			}
		}
	}
	return nullptr;
}

void Gump::Draw()
{
	m_gui.Draw();

	U7Object* thisObject = GetObjectFromID(m_containerId);
	if (thisObject)
	{
		for (auto& item : thisObject->m_inventory)
		{
			if (item != g_gumpManager->m_draggedObjectId) // Don't draw dragged object, GumpManager handles that.
			{
				auto object = GetObjectFromID(item);
				DrawTextureEx(*object->m_shapeData->GetTexture(), Vector2{m_gui.m_Pos.x + m_containerData.m_boxOffset.x + object->m_InventoryPos.x, m_gui.m_Pos.y + m_containerData.m_boxOffset.y + object->m_InventoryPos.y}, 0, 1, Color{255, 255, 255, 255});
			}
		}
	}

	// Draw hover text if active (uses same style as bark text)
	if (!m_hoverText.empty() && m_hoverTextDuration > 0.0f)
	{
		// Measure text with conversation font
		float width = MeasureTextEx(*g_ConversationFont, m_hoverText.c_str(), g_ConversationFont->baseSize, 1).x * 1.2f;
		float height = g_ConversationFont->baseSize * 1.2f;

		// Center text horizontally at stored position, slightly above
		Vector2 textPos = {
			m_hoverTextPos.x - width / 2.0f,
			m_hoverTextPos.y - height - 5.0f  // Above item
		};

		// Draw rounded rectangle background (pill-shaped, semi-transparent)
		DrawRectangleRounded({textPos.x, textPos.y, width, height}, 5.0f, 10, Color{0, 0, 0, 192});

		// Draw text in yellow (same as bark)
		DrawTextEx(*g_ConversationFont, m_hoverText.c_str(),
			{ textPos.x + (width * 0.1f), textPos.y + (height * 0.1f) },
			g_ConversationFont->baseSize, 1, YELLOW);
	}
}

void Gump::SortContainer()
{
	U7Object* thisObject = GetObjectFromID(m_containerId);

	if (thisObject->m_inventory.empty())
	{
        return;
    }

    // Sort items by height (tallest first) for better packing
    std::sort(thisObject->m_inventory.begin(), thisObject->m_inventory.end(), [](int a, int b)
	{
		U7Object* aObj = GetObjectFromID(a);
		U7Object* bObj = GetObjectFromID(b);

		// Safety check: if either object is invalid or has no shape data, consider them equal
		if (!aObj || !bObj || !aObj->m_shapeData || !bObj->m_shapeData)
			return false;

		return (aObj->m_shapeData->GetDefaultTextureImage().height > bObj->m_shapeData->GetDefaultTextureImage().height);
	});

    float currentX = 0.0f;      // Current x position in the current row
    float currentY = 0.0f;      // Current y position (top of current row)
    float maxRowHeight = 0.0f;  // Height of the tallest item in the current row
    float totalWidth = 0.0f;    // Maximum width of the entire arrangement

    for (int item : thisObject->m_inventory) {
        // If adding the item exceeds maxWidth, move to the next row
		U7Object* itemObj = GetObjectFromID(item);

		// Safety check: skip invalid objects or objects without shape data
		if (!itemObj || !itemObj->m_shapeData)
			continue;

        if (currentX + itemObj->m_shapeData->GetDefaultTextureImage().width > m_containerData.m_boxSize.x * 1) {
            currentX = 0.0f;
            currentY += maxRowHeight;
            maxRowHeight = 0.0f;
        }

        // Place the item
        itemObj->m_InventoryPos = { currentX, currentY };
        currentX += itemObj->m_shapeData->GetDefaultTextureImage().width;
        maxRowHeight = std::max(int(maxRowHeight), itemObj->m_shapeData->GetDefaultTextureImage().height);
        totalWidth = std::max(totalWidth, currentX);
    }

	thisObject->m_isSorted = true;
}

bool Gump::IsMouseOverSolidPixel(Vector2 mousePos)
{
	// Get the biggumps texture (used for container gump backgrounds)
	Texture* backgroundTexture = g_ResourceManager->GetTexture("Images/GUI/biggumps.png");

	// If no texture, default to solid (always block input)
	if (!backgroundTexture)
		return true;

	// Convert mouse position to local gump coordinates
	float localX = mousePos.x - m_gui.m_Pos.x;
	float localY = mousePos.y - m_gui.m_Pos.y;

	// Calculate pixel position in the source texture
	int texX = int(m_containerData.m_texturePos.x + localX);
	int texY = int(m_containerData.m_texturePos.y + localY);

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
