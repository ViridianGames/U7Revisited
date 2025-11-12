#include "GumpManager.h"
#include "U7Gump.h"
#include "U7GumpPaperdoll.h"
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
	m_draggedObjectOffset = {0, 0};

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
	m_isMouseOverGump = false;
	m_gumpUnderMouse = nullptr;  // Clear this every frame
	std::shared_ptr<Gump> gumpToMoveToFront = nullptr;
	Gump* topmostGumpUnderMouse = nullptr;

	// First pass: Find topmost gump under mouse (iterate backwards to find last one)
	for (auto it = m_GumpList.rbegin(); it != m_GumpList.rend(); ++it)
	{
		Rectangle gumpRect = { (*it)->m_gui.m_Pos.x, (*it)->m_gui.m_Pos.y, (*it)->m_gui.m_Width, (*it)->m_gui.m_Height };
		bool collision = CheckCollisionPointRec(mousePos, gumpRect);

		// If bounding box collision, check pixel-perfect collision
		if (collision)
		{
			collision = (*it)->IsMouseOverSolidPixel(mousePos);
		}

		if (collision)
		{
			topmostGumpUnderMouse = (*it).get();
			m_isMouseOverGump = true;
			m_gumpUnderMouse = topmostGumpUnderMouse;

			// If mouse clicked on this gump, bring it to front (if not already at front)
			if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
			{
				gumpToMoveToFront = *it;
			}
			break; // Found topmost, stop searching
		}
	}

	// Second pass: Update all gumps, but only let topmost one receive drag input
	for (vector<std::shared_ptr<Gump>>::iterator gump = m_GumpList.begin(); gump != m_GumpList.end();)
	{
		// Temporarily disable dragging for non-topmost gumps
		bool wasDraggable = (*gump)->m_gui.m_Draggable;
		if (topmostGumpUnderMouse != nullptr && (*gump).get() != topmostGumpUnderMouse)
		{
			(*gump)->m_gui.m_Draggable = false;
		}

		(*gump).get()->Update();

		// Restore draggable state
		(*gump)->m_gui.m_Draggable = wasDraggable;

		if ((*gump).get()->GetIsDead())
		{
			// Log which gump is being removed
			GumpPaperdoll* paperdoll = dynamic_cast<GumpPaperdoll*>(gump->get());
			if (paperdoll)
			{
				Log("Removing paperdoll for NPC " + std::to_string(paperdoll->GetNpcId()));
			}
			else
			{
				Log("Removing container gump");
			}
			gump = m_GumpList.erase(gump);
		}
		else
		{
			++gump;
		}
	}

	// Bring clicked gump to front by moving it to the end of the list
	if (gumpToMoveToFront)
	{
		auto it = std::find(m_GumpList.begin(), m_GumpList.end(), gumpToMoveToFront);
		if (it != m_GumpList.end() && it != m_GumpList.end() - 1)
		{
			m_GumpList.erase(it);
			m_GumpList.push_back(gumpToMoveToFront);
		}
	}

	// Handle using objects from inventory


	// Handle dragging
	if (g_gumpManager->m_draggingObject && !IsMouseButtonDown(MOUSE_LEFT_BUTTON))
	{
		auto object = GetObjectFromID(g_gumpManager->m_draggedObjectId);

		// Safety check - object may not exist
		if (object == nullptr)
		{
			g_gumpManager->m_draggingObject = false;
			g_gumpManager->m_draggedObjectId = -1;
			g_gumpManager->m_sourceGump = nullptr;
			return;
		}

		//  Dragging from inventory to inventory
		for (auto gump : g_gumpManager->m_GumpList)
		{
			// Skip paperdolls - they don't have container objects
			if (dynamic_cast<GumpPaperdoll*>(gump.get()))
				continue;

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

			// Validate m_sourceGump is still in the active gump list
			bool gumpStillValid = false;
			if (m_sourceGump != nullptr)
			{
				for (const auto& gump : m_GumpList)
				{
					if (gump.get() == m_sourceGump)
					{
						gumpStillValid = true;
						break;
					}
				}
			}

			if (gumpStillValid && m_sourceGump->m_containerObject != nullptr)
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
	// Debug: Log gump count every frame to detect disappearing gumps
	static int lastGumpCount = -1;
	if (m_GumpList.size() != lastGumpCount)
	{
		Log("GumpManager::Draw - Drawing " + std::to_string(m_GumpList.size()) + " gumps");
		lastGumpCount = m_GumpList.size();
	}

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
		DrawTextureEx(*object->m_shapeData->GetTexture(), Vector2Add(mousePos, m_draggedObjectOffset), 0, 1, Color{255, 255, 255, 255});
	}
}

void GumpManager::AddGump(std::shared_ptr<Gump> Gump)
{
	m_GumpList.push_back(Gump);
}