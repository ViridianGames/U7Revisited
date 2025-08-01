#include <fstream>
#include <string>
#include <sstream>
#include <algorithm>

#include "U7Gump.h"
#include "Geist/Config.h"
#include "Geist/Engine.h"
#include "Geist/Globals.h"
#include "Geist/ResourceManager.h"
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
	m_isDone = false;
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

	m_containerObject = GetObjectFromID(m_containerId).get();

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
		make_shared<Sprite>(g_ResourceManager->GetTexture("Images/GUI/gumps.png", false), m_containerData.m_texturePos.x, m_containerData.m_texturePos.y, m_containerData.m_textureSize.x, m_containerData.m_textureSize.y), m_scale * 2, m_scale * 2, Color{255, 255, 255, 255});
	m_gui.AddIconButton(1005, 4 * m_scale * 2, 34 * m_scale * 2, g_gumpCheckmarkUp, g_gumpCheckmarkDown, g_gumpCheckmarkUp, "", g_SmallFont.get(), Color{255, 255, 255, 255}, 2, 0, 1, false);

	m_gui.AddStretchButton(1006, 4 * m_scale * 2, 12 * m_scale * 2, 28, "Sort",
		g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
		g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM);

	m_gui.SetDoneButtonId(1005);
	m_gui.m_Draggable = true;

	//gump->SetContainerType(Gump::g_gumpData[gump->m_containerType].m_containerType);

	shared_ptr<U7Object> thisObject = GetObjectFromID(m_containerId);
	if(thisObject->m_shouldBeSorted)
	{
		SortContainer();
	}
}

void Gump::Update()
{
	m_gui.Update();
	if(m_gui.m_ActiveElement == m_gui.m_doneButtonId)
	{
		m_isDone = true;
	}

	if(m_gui.m_ActiveElement == 1006)
	{
		SortContainer();
	}

	// Handle dragging
	Vector2 mousePos = GetMousePosition();
	mousePos.x /= g_DrawScale;
	mousePos.y /= g_DrawScale;

	//  Are we in the box bounds of the gump?
	if (CheckCollisionPointRec(mousePos, Rectangle{ m_gui.m_Pos.x + (m_containerData.m_boxOffset.x * m_scale * 2), m_gui.m_Pos.y + (m_containerData.m_boxOffset.y * m_scale * 2),
		m_containerData.m_boxSize.x * m_scale * 2, m_containerData.m_boxSize.y * m_scale * 2 }))
	{
		if (IsMouseButtonDown(MOUSE_LEFT_BUTTON))
		{
			if(!m_draggingObject)
			{
				for (auto containerObjectId : m_containerObject->m_inventory)
				{
					auto object = GetObjectFromID(containerObjectId).get();
					if (object && object->m_shapeData)
					{
						if (CheckCollisionPointRec(mousePos, Rectangle{ m_gui.m_Pos.x + (m_containerData.m_boxOffset.x * 2) + object->m_GumpPos.x, m_gui.m_Pos.y + (m_containerData.m_boxOffset.y * 2) + object->m_GumpPos.y, float(object->m_shapeData->GetDefaultTextureImage().width), float(object->m_shapeData->GetDefaultTextureImage().height) }))
						{
							m_draggedObjectId = object->m_ID;
							m_draggingObject = true;
							m_dragOffset.x = mousePos.x - m_gui.m_Pos.x - m_containerData.m_boxOffset.x - object->m_GumpPos.x;
							m_dragOffset.y = mousePos.y - m_gui.m_Pos.y - m_containerData.m_boxOffset.y - object->m_GumpPos.y;

							// Move the selected object to the back of the inventory list so it draws on top
							auto it = std::find(m_containerObject->m_inventory.begin(), m_containerObject->m_inventory.end(), m_draggedObjectId);
							if (it != m_containerObject->m_inventory.end())
							{
								m_containerObject->m_inventory.erase(it);
								m_containerObject->m_inventory.push_back(m_draggedObjectId);
							}
							break; //  We found the object we are dragging, so break out of the loop
						}
					}
				}
			}
			else
			{
				//  We are dragging an object, so move it
				auto object = GetObjectFromID(m_draggedObjectId);
				if (object && object->m_shapeData)
				{
					object->m_GumpPos.x = mousePos.x - m_containerData.m_boxOffset.x - m_gui.m_Pos.x - m_dragOffset.x;
					object->m_GumpPos.y = mousePos.y - m_containerData.m_boxOffset.y - m_gui.m_Pos.y - m_dragOffset.y;
					m_containerObject->m_shouldBeSorted = false; //  We are dragging an object, so we no longer need to sort.
				}
			}
		}
		else
		{
			m_draggingObject = false;
			m_draggedObjectId = -1;
		}
	}
}

void Gump::Draw()
{
	m_gui.Draw();

	shared_ptr<U7Object> thisObject = GetObjectFromID(m_containerId);

	for (auto& item : thisObject->m_inventory)
	{
		auto object = GetObjectFromID(item);
		DrawTextureEx(*object->m_shapeData->GetTexture(), Vector2{m_gui.m_Pos.x + m_containerData.m_boxOffset.x * m_scale * 2 + object->m_GumpPos.x, m_gui.m_Pos.y + m_containerData.m_boxOffset.y * m_scale * 2 + object->m_GumpPos.y}, 0, 1, Color{255, 255, 255, 255});
	}
}

void Gump::SortContainer()
{
	shared_ptr<U7Object> thisObject = GetObjectFromID(m_containerId);

	if (thisObject->m_inventory.empty())
	{
        return;
    }

    // Sort items by height (tallest first) for better packing
    std::sort(thisObject->m_inventory.begin(), thisObject->m_inventory.end(), [](int a, int b)
	{
		U7Object* aObj = GetObjectFromID(a).get();
		U7Object* bObj = GetObjectFromID(b).get();

		return (aObj->m_shapeData->GetDefaultTextureImage().height > bObj->m_shapeData->GetDefaultTextureImage().height);
	});

    float currentX = 0.0f;      // Current x position in the current row
    float currentY = 0.0f;      // Current y position (top of current row)
    float maxRowHeight = 0.0f;  // Height of the tallest item in the current row
    float totalWidth = 0.0f;    // Maximum width of the entire arrangement

    for (int item : thisObject->m_inventory) {
        // If adding the item exceeds maxWidth, move to the next row
		U7Object* itemObj = GetObjectFromID(item).get();
        if (currentX + itemObj->m_shapeData->GetDefaultTextureImage().width > m_containerData.m_boxSize.x * 2) {
            currentX = 0.0f;
            currentY += maxRowHeight;
            maxRowHeight = 0.0f;
        }

        // Place the item
        itemObj->m_GumpPos = { currentX, currentY };
        currentX += itemObj->m_shapeData->GetDefaultTextureImage().width;
        maxRowHeight = std::max(int(maxRowHeight), itemObj->m_shapeData->GetDefaultTextureImage().height);
        totalWidth = std::max(totalWidth, currentX);
    }

	thisObject->m_isSorted = true;
}

