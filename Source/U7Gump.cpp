#include <fstream>
#include <string>
#include <sstream>
#include <algorithm>

#include "U7Gump.h"

#include "InputSystem.h"
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
	const int gumpW = int(m_containerData.m_textureSize.x);
	const int gumpH = int(m_containerData.m_textureSize.y);
	m_gui.SetLayout(posx, posy, gumpW, gumpH, g_DrawScale, Gui::GUIP_USE_XY);
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
	m_gui.m_DragAreaHeight = gumpH;  // Grab from anywhere on the frame, not just a 20px strip

	// Drag from solid frame chrome only — not buttons, not the inventory box
	// (so item drags and Sort/close still work).
	m_gui.m_DragAreaValidationCallback = [this](Vector2 mousePos) {
		if (!this->IsMouseOverSolidPixel(mousePos))
			return false;

		Rectangle inventoryBox = {
			m_gui.m_Pos.x + m_containerData.m_boxOffset.x,
			m_gui.m_Pos.y + m_containerData.m_boxOffset.y,
			m_containerData.m_boxSize.x,
			m_containerData.m_boxSize.y
		};
		if (CheckCollisionPointRec(mousePos, inventoryBox))
			return false;

		auto checkBtn = m_gui.GetElement(1005);
		if (checkBtn)
		{
			Rectangle btnRect = checkBtn->GetBounds();
			btnRect.x += m_gui.m_Pos.x;
			btnRect.y += m_gui.m_Pos.y;
			if (CheckCollisionPointRec(mousePos, btnRect))
				return false;
		}

		auto sortBtn = m_gui.GetElement(1006);
		if (sortBtn)
		{
			Rectangle btnRect = sortBtn->GetBounds();
			btnRect.x += m_gui.m_Pos.x;
			btnRect.y += m_gui.m_Pos.y;
			if (CheckCollisionPointRec(mousePos, btnRect))
				return false;
		}

		return true;
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

	// Handle inventory item interaction / drag
	Vector2 mousePos = GetMousePosition();
	mousePos.x = int(mousePos.x /= g_DrawScale);
	mousePos.y = int(mousePos.y /= g_DrawScale);

	if (!g_InputSystem->IsLButtonDown())
	{
		m_dragStart = {0, 0};
		m_pendingDragObjectId = -1;
		m_pendingDragSlotIndex = -1;
	}

	auto findInventoryObjectAt = [&](Vector2 pos) -> U7Object*
	{
		if (!m_containerObject)
			return nullptr;
		for (auto containerObjectId : m_containerObject->m_inventory)
		{
			auto object = GetObjectFromID(containerObjectId);
			if (!object || !object->m_shapeData)
				continue;
			Rectangle itemRect = {
				m_gui.m_Pos.x + m_containerData.m_boxOffset.x + object->m_InventoryPos.x,
				m_gui.m_Pos.y + m_containerData.m_boxOffset.y + object->m_InventoryPos.y,
				float(object->m_shapeData->GetDefaultTextureImage().width),
				float(object->m_shapeData->GetDefaultTextureImage().height)
			};
			if (CheckCollisionPointRec(pos, itemRect))
				return object;
		}
		return nullptr;
	};

	Rectangle inventoryBox = {
		m_gui.m_Pos.x + m_containerData.m_boxOffset.x,
		m_gui.m_Pos.y + m_containerData.m_boxOffset.y,
		m_containerData.m_boxSize.x,
		m_containerData.m_boxSize.y
	};

	// Are we the topmost gump?
	bool isTopmostGump = (g_gumpManager->m_gumpUnderMouse == this);
	if (isTopmostGump && CheckCollisionPointRec(mousePos, inventoryBox))
	{
		// Double-click inventory items: special gumps, otherwise run the item's usecode
		// (keys → green use cursor via object_select_modal, etc.).
		if (g_InputSystem->WasLButtonDoubleClicked())
		{
			if (U7Object* object = findInventoryObjectAt(mousePos))
			{
				if (g_mainState)
					g_mainState->ClearObjectInfoTooltip();

				if (object->m_shapeData->m_shape == 761)
				{
					Log("Container - Double-click on spellbook, opening spellbook gump");
					if (g_mainState)
						g_mainState->OpenSpellbookGump(0);
					return;
				}
				else if (object->m_shapeData->m_shape == 178)
				{
					Log("Container - Double-click on map, opening minimap gump");
					if (g_mainState)
						g_mainState->OpenMinimapGump(0);
					return;
				}
				else
				{
					Log("Container - Double-click on item shape " +
						std::to_string(object->m_shapeData->m_shape) +
						" id=" + std::to_string(object->m_ID) + ", Interact(1)");
					object->Interact(1);
					return;
				}
			}
		}

		// Single click: show shared object info tooltip (name / weight / volume).
		if (g_InputSystem->WasLButtonClicked() && !g_gumpManager->m_draggingObject && g_mainState)
		{
			if (U7Object* object = findInventoryObjectAt(mousePos))
				g_mainState->ShowObjectInfoTooltip(object);
		}

		// Capture the object under the cursor at press time — not when the
		// move threshold is crossed (fast drags otherwise steal a neighbor).
		if (g_InputSystem->IsLButtonJustDown() && !g_gumpManager->m_draggingObject)
		{
			if (U7Object* object = findInventoryObjectAt(mousePos))
			{
				m_pendingDragObjectId = object->m_ID;
				m_pendingDragSlotIndex = -1;
				m_dragStart = mousePos;
			}
		}
	}

	// Promote pending press to a real item drag once the mouse moves a bit.
	// Uses the press-time object even if the cursor has already left that icon.
	if (m_pendingDragObjectId != -1 && !g_gumpManager->m_draggingObject &&
		g_InputSystem->IsLButtonDown() &&
		Vector2DistanceSqr(m_dragStart, mousePos) > 4)
	{
		U7Object* object = GetObjectFromID(m_pendingDragObjectId);
		if (object && object->m_shapeData && m_containerObject)
		{
			g_gumpManager->m_draggedObjectId = object->m_ID;
			g_gumpManager->m_draggingObject = true;
			g_gumpManager->m_dropValid = true;
			g_gumpManager->m_sourceGump = this;
			g_gumpManager->m_sourceSlotIndex = -1;

			auto img = object->m_shapeData->GetDefaultTextureImage();
			g_gumpManager->m_draggedObjectOffset = {-img.width / 2.0f, -img.height / 2.0f};

			m_containerObject->m_shouldBeSorted = false;
			g_gumpManager->CloseGumpForObject(object->m_ID);
			m_containerObject->RemoveObjectFromInventory(object->m_ID);
			Log("Removed object " + std::to_string(object->m_ID) + " from container on drag start");
		}
		m_pendingDragObjectId = -1;
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
	if (thisObject)
	{
		for (auto& item : thisObject->m_inventory)
		{
			if (item != g_gumpManager->m_draggedObjectId) // Don't draw dragged object, GumpManager handles that.
			{
				auto object = GetObjectFromID(item);
				object->m_shapeData->DrawInventoryIcon(
					int(m_gui.m_Pos.x + m_containerData.m_boxOffset.x + object->m_InventoryPos.x),
					int(m_gui.m_Pos.y + m_containerData.m_boxOffset.y + object->m_InventoryPos.y));
			}
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
	static constexpr const char* kBigGumpsPath = "Images/GUI/biggumps.png";
	const Image* img = GetCachedGuiImage(kBigGumpsPath);
	// If no image, default to solid (always block input)
	if (!img || img->data == nullptr)
		return true;

	// Convert mouse position to local gump coordinates
	const float localX = mousePos.x - m_gui.m_Pos.x;
	const float localY = mousePos.y - m_gui.m_Pos.y;

	// Must be inside this container's sprite rect (not just the atlas)
	if (localX < 0 || localY < 0 ||
		localX >= m_containerData.m_textureSize.x ||
		localY >= m_containerData.m_textureSize.y)
		return false;

	// Calculate pixel position in the source texture
	const int texX = int(m_containerData.m_texturePos.x + localX);
	const int texY = int(m_containerData.m_texturePos.y + localY);

	if (texX < 0 || texY < 0 || texX >= img->width || texY >= img->height)
		return false;

	return GetImageColor(*img, texX, texY).a > 0;
}
