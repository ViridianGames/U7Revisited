#include "GumpManager.h"
#include "U7Gump.h"
#include "Gui.h"
#include "Logging.h"
#include <memory>
#include <algorithm>

#include "ScriptingSystem.h"
#include "U7Globals.h"

using namespace std;

void GumpManager::Init(const std::string& configfile)
{
	Log("Starting GumpManager::Init()");

	m_ConfigFileName = configfile;
	m_GumpManagerConfig.Load(configfile);
	m_draggingObject = false;
	m_draggedObjectId = -1;
	m_dragOffset = {0, 0};

	Log("Done with GumpManager::Init()");
}

void GumpManager::Shutdown()
{

}

//  The GumpManager is also the unoffical dragging handler, since most dragging will be in gumps.
//  It even handles spot-to-spot dragging when gumps aren't open.  It's important to have this demarcation because
//  we don't want GumpManager to interfere when we're trying to use an object or talk to an NPC.
void GumpManager::Update()
{
	Vector2 mousePos = GetMousePosition();
	mousePos.x = int(mousePos.x /= g_DrawScale);
	mousePos.y = int(mousePos.y /= g_DrawScale);

	//  Update all gumps, remove dead ones.
	m_mouseOverGump = false;
	for (vector<std::shared_ptr<Gump>>::iterator gump = m_GumpList.begin(); gump != m_GumpList.end();)
	{
		(*gump).get()->Update();
		if (CheckCollisionPointRec(mousePos, Rectangle{ gump->get()->m_gui.m_Pos.x, gump->get()->m_gui.m_Pos.y, gump->get()->m_gui.m_Width, gump->get()->m_gui.m_Height }))
		{
			m_mouseOverGump = true;
		}

		if ((*gump).get()->GetIsDead())
		{
			gump = m_GumpList.erase(gump);
		}
		else
		{
			++gump;
		}
	}

	// Handle dragging
	if (g_gumpManager->m_draggingObject && !IsMouseButtonDown(MOUSE_LEFT_BUTTON))
	{
		auto object = GetObjectFromID(g_gumpManager->m_draggedObjectId);

		//  Dragging from inventory to inventory
		for (auto gump : g_gumpManager->m_GumpList)
		{
			if (CheckCollisionPointRec(mousePos, Rectangle{ gump->m_gui.m_Pos.x, gump->m_gui.m_Pos.y, gump->m_gui.m_Width, gump->m_gui.m_Height}))
			{
				if (CheckCollisionPointRec(mousePos, Rectangle{ gump->m_gui.m_Pos.x + (gump->m_containerData.m_boxOffset.x), gump->m_gui.m_Pos.y + (gump->m_containerData.m_boxOffset.y),
gump->m_containerData.m_boxSize.x, gump->m_containerData.m_boxSize.y }))
				{
					object->m_InventoryPos = {mousePos.x - (gump->m_gui.m_Pos.x + (gump->m_containerData.m_boxOffset.x)), mousePos.y - (gump->m_gui.m_Pos.y + (gump->m_containerData.m_boxOffset.y)) };
				}
				else // In the container but not in the box area
				{
					object->m_InventoryPos = {0, 0 };
				}

				gump->m_containerObject->m_inventory.push_back(object->m_ID);
				object->m_isContained = true;
				if (object->m_shapeData->GetShape() == 641 && object->m_Quality == 253)
				{
					g_ScriptingSystem->SetFlag(60, 1);
				}

				//  If we're dragging to the same gump, or dragging from the ground, don't remove from inventory
				if (gump.get() != m_sourceGump || m_sourceGump == nullptr)
				{
					gump->m_containerObject->m_inventory.push_back(object->m_ID);
					for (std::vector<int>::iterator node = gump->m_containerObject->m_inventory.begin(); node != gump->m_containerObject->m_inventory.end(); node++)
					{
						if ((*node) == object->m_ID)
						{
							gump->m_containerObject->m_inventory.erase(node);
							break;
						}
					}
				}
				g_gumpManager->m_draggingObject = false;
				g_gumpManager->m_draggedObjectId = -1;
				g_gumpManager->m_sourceGump = nullptr;
				break;
			}
		}

		//  Didn't drag into another container?  Check dragging from inventory to ground
		if (g_gumpManager->m_draggingObject)
		{
			object->SetPos(g_terrainUnderMousePointer);

			object->m_isContained = false;

			if (m_sourceGump != nullptr)
			{
				//  If we dragged from a gump, remove from that inventory
				for (std::vector<int>::iterator node = m_sourceGump->m_containerObject->m_inventory.begin(); node != m_sourceGump->m_containerObject->m_inventory.end(); node++)
				{
					if ((*node) == object->m_ID)
					{
						m_sourceGump->m_containerObject->m_inventory.erase(node);
						break;
					}
				}
			}
			g_gumpManager->m_draggingObject = false;
			g_gumpManager->m_draggedObjectId = -1;
			g_gumpManager->m_sourceGump = nullptr;
		}
	}
}

void GumpManager::Draw()
{
	for (auto& Gump : m_GumpList)
	{
		Gump.get()->Draw();
	}

	if (m_draggingObject && m_draggedObjectId != -1)
	{
		U7Object* object = GetObjectFromID(m_draggedObjectId);
		Vector2 mousePos = GetMousePosition();
		mousePos.x = int(mousePos.x /= g_DrawScale);
		mousePos.y = int(mousePos.y /= g_DrawScale);
		DrawTextureEx(*object->m_shapeData->GetTexture(), Vector2Add(mousePos, m_dragOffset), 0, 1, Color{255, 255, 255, 255});
	}
}

void GumpManager::AddGump(std::shared_ptr<Gump> Gump)
{
	m_GumpList.push_back(Gump);
}