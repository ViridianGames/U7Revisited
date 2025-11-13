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

	// Second pass: Update all gumps, but only let topmost one receive input
	for (vector<std::shared_ptr<Gump>>::iterator gump = m_GumpList.begin(); gump != m_GumpList.end();)
	{
		// Temporarily disable ALL input (including buttons) for non-topmost gumps
		// BUT: if a gump is already being dragged, keep it active (for smooth dragging)
		bool wasActive = (*gump)->m_gui.m_Active;
		bool isBeingDragged = (*gump)->m_gui.m_IsDragging;
		if (topmostGumpUnderMouse != nullptr && (*gump).get() != topmostGumpUnderMouse && !isBeingDragged)
		{
			(*gump)->m_gui.m_Active = false;
		}

		(*gump).get()->Update();

		// Restore active state
		(*gump)->m_gui.m_Active = wasActive;

		if ((*gump).get()->GetIsDead())
		{
			// Clear m_gumpUnderMouse if it's pointing to the gump being removed
			if (m_gumpUnderMouse == (*gump).get())
			{
				m_gumpUnderMouse = nullptr;
			}

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

		//  First check if we're dropping on a paperdoll
		bool droppedOnPaperdoll = false;
		bool attemptedPaperdollDrop = false;
		for (auto gump : g_gumpManager->m_GumpList)
		{
			GumpPaperdoll* paperdoll = dynamic_cast<GumpPaperdoll*>(gump.get());
			if (paperdoll)
			{
				// Check if mouse is over this paperdoll
				if (CheckCollisionPointRec(mousePos, Rectangle{ gump->m_gui.m_Pos.x, gump->m_gui.m_Pos.y, gump->m_gui.m_Width, gump->m_gui.m_Height}))
				{
					attemptedPaperdollDrop = true;

					// Get which slot this item should go to based on its shape
					int shape = object->m_shapeData->GetShape();
					EquipmentSlot slot = GetEquipmentSlotForShape(shape);

					if (slot != EquipmentSlot::SLOT_COUNT)
					{
						// Get NPC data
						auto npcIt = g_NPCData.find(paperdoll->GetNpcId());
						if (npcIt != g_NPCData.end())
						{
							NPCData* npcData = npcIt->second.get();

							// Check if slot is empty
							int currentEquipped = npcData->GetEquippedItem(slot);
							if (currentEquipped == -1)
							{
								// Slot is empty, equip the item
								npcData->SetEquippedItem(slot, object->m_ID);

								// Item was already removed from source when drag started, so just mark as contained
								object->m_isContained = true; // Equipped items are considered contained
								droppedOnPaperdoll = true;

								Log("Equipped shape " + std::to_string(shape) + " to slot " + std::to_string(static_cast<int>(slot)));
							}
							else
							{
								Log("Cannot equip - slot " + std::to_string(static_cast<int>(slot)) + " is already occupied");
							}
						}
					}
					else
					{
						Log("Cannot equip shape " + std::to_string(shape) + " - not an equippable item");
					}

					// If we attempted to drop on paperdoll but failed, return item to source
					if (attemptedPaperdollDrop && !droppedOnPaperdoll)
					{
						// Return to source container if we dragged from one
						if (m_sourceGump != nullptr)
						{
							GumpPaperdoll* sourcePaperdoll = dynamic_cast<GumpPaperdoll*>(m_sourceGump);
							if (sourcePaperdoll)
							{
								// Re-equip to the paperdoll we dragged from
								auto sourceNpcIt = g_NPCData.find(sourcePaperdoll->GetNpcId());
								if (sourceNpcIt != g_NPCData.end() && slot != EquipmentSlot::SLOT_COUNT)
								{
									sourceNpcIt->second->SetEquippedItem(slot, object->m_ID);
									object->m_isContained = true;
									Log("Returned item to source paperdoll slot " + std::to_string(static_cast<int>(slot)));
								}
							}
							else if (m_sourceGump->m_containerObject != nullptr)
							{
								// Return to source container inventory
								m_sourceGump->m_containerObject->m_inventory.push_back(object->m_ID);
								object->m_isContained = true;
								Log("Returned item to source container");
							}
						}
					}

					if (droppedOnPaperdoll || attemptedPaperdollDrop)
					{
						g_gumpManager->m_draggingObject = false;
						g_gumpManager->m_draggedObjectId = -1;
						g_gumpManager->m_sourceGump = nullptr;
						break;
					}
				}
			}
		}

		//  If not dropped on paperdoll, check dragging to regular containers
		if (!droppedOnPaperdoll)
		{
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

					// Add to new container (item was already removed from source when drag started)
					gump->m_containerObject->m_inventory.push_back(object->m_ID);
					object->m_isContained = true;
					if (object->m_shapeData->GetShape() == 641 && object->m_Quality == 253)
					{
						g_ScriptingSystem->SetFlag(60, 1);
					}

					g_gumpManager->m_draggingObject = false;
					g_gumpManager->m_draggedObjectId = -1;
					g_gumpManager->m_sourceGump = nullptr;
					break;
				}
			}
		}

		//  Didn't drag into another container?  Drop to ground
		if (g_gumpManager->m_draggingObject)
		{
			object->SetPos(g_terrainUnderMousePointer);
			object->m_isContained = false;

			// Item was already removed from source when drag started, so just clean up drag state
			g_gumpManager->m_draggingObject = false;
			g_gumpManager->m_draggedObjectId = -1;
			g_gumpManager->m_sourceGump = nullptr;
		}
	}

	// Process pending gumps (added after iteration to avoid iterator invalidation)
	if (!m_PendingGumps.empty())
	{
		for (auto& gump : m_PendingGumps)
		{
			m_GumpList.push_back(gump);
		}
		m_PendingGumps.clear();
	}
}

void GumpManager::Draw()
{
	// Debug: Log gump count every frame to detect disappearing gumps
	static int lastGumpCount = -1;
	if (m_GumpList.size() != lastGumpCount)
	{
		Log("GumpManager::Draw - Drawing " + std::to_string(m_GumpList.size()) + " gumps");
		lastGumpCount = static_cast<int>(m_GumpList.size());
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
	// Add to pending list instead of directly to avoid iterator invalidation
	m_PendingGumps.push_back(Gump);
}

bool GumpManager::IsAnyGumpBeingDragged()
{
	for (const auto& gump : m_GumpList)
	{
		if (gump->m_gui.m_IsDragging)
		{
			return true;
		}
	}
	return false;
}