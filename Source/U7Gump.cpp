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

void Gump::OnEnter()
{
	int posx = int(g_NonVitalRNG->Random(150));
	int posy = int(g_NonVitalRNG->Random(150));

	m_containerObject = GetObjectFromID(m_containerId);

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
			m_containerData = g_containerData[static_cast<int>(ContainerType::CONTAINER_DRAWER)];
			break;
		case 1000: //  Corpse
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
	m_gui.AddIconButton(1005, 4, 34, g_gumpCheckmarkUp, g_gumpCheckmarkDown, g_gumpCheckmarkUp, "", g_SmallFont.get(), Color{255, 255, 255, 255}, 1, 0, 1, false);

	m_gui.AddStretchButton(1006, 6, 18, 28, "Sort",
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

	//  Are we in the box bounds of the gump?
	if (CheckCollisionPointRec(mousePos, Rectangle{ m_gui.m_Pos.x + (m_containerData.m_boxOffset.x), m_gui.m_Pos.y + (m_containerData.m_boxOffset.y),
		m_containerData.m_boxSize.x, m_containerData.m_boxSize.y }))
	{
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
}

U7Object* Gump::GetObjectUnderMousePointer()
{
	// Skip gumps without container objects (paperdolls, spellbooks, etc.)
	if (m_containerObject == nullptr)
		return nullptr;

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

	// Debug: Log what container we're drawing
	static bool loggedGump = false;
	if (!loggedGump && thisObject)
	{
		Log("Gump::Draw - Drawing container " + std::to_string(m_containerId) +
			", inventory size=" + std::to_string(thisObject->m_inventory.size()) +
			", isContainer=" + std::string(thisObject->m_isContainer ? "true" : "false"));

		// Log first few items
		int count = 0;
		for (auto& itemId : thisObject->m_inventory)
		{
			if (count < 5)
			{
				auto obj = GetObjectFromID(itemId);
				if (obj && obj->m_shapeData)
				{
					Log("  Item " + std::to_string(count) + ": id=" + std::to_string(itemId) +
						", shape=" + std::to_string(obj->m_shapeData->GetShape()));
				}
				count++;
			}
		}
		loggedGump = true;
	}

	for (auto& item : thisObject->m_inventory)
	{
		if (item != g_gumpManager->m_draggedObjectId) // Don't draw dragged object, GumpManager handles that.
		{
			auto object = GetObjectFromID(item);
			DrawTextureEx(*object->m_shapeData->GetTexture(), Vector2{m_gui.m_Pos.x + m_containerData.m_boxOffset.x + object->m_InventoryPos.x, m_gui.m_Pos.y + m_containerData.m_boxOffset.y + object->m_InventoryPos.y}, 0, 1, Color{255, 255, 255, 255});
		}
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

		return (aObj->m_shapeData->GetDefaultTextureImage().height > bObj->m_shapeData->GetDefaultTextureImage().height);
	});

    float currentX = 0.0f;      // Current x position in the current row
    float currentY = 0.0f;      // Current y position (top of current row)
    float maxRowHeight = 0.0f;  // Height of the tallest item in the current row
    float totalWidth = 0.0f;    // Maximum width of the entire arrangement

    for (int item : thisObject->m_inventory) {
        // If adding the item exceeds maxWidth, move to the next row
		U7Object* itemObj = GetObjectFromID(item);
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

