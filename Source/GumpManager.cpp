#include "GumpManager.h"
#include "U7Gump.h"
#include "U7GumpPaperdoll.h"
#include "U7GumpSpellbook.h"
#include "Gui.h"
#include "Logging.h"
#include <memory>
#include <algorithm>

#include "InputSystem.h"
#include "ScriptingSystem.h"
#include "U7Globals.h"
#include "ResourceManager.h"
#include "SoundSystem.h"

using namespace std;

extern std::unique_ptr<ResourceManager> g_ResourceManager;

void GumpManager::Init(const std::string& configfile)
{
	Log("Starting GumpManager::Init()");

	m_ConfigFileName = configfile;
	m_GumpManagerConfig.Load(configfile);
	m_draggingObject = false;
	m_draggedObjectId = -1;
	m_draggedObjectOffset = { 0, 0 };

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

	// While a gump window is being dragged, that gump owns input for the whole press
	// (even if the cursor leaves its solid pixels or overlaps another gump).
	Gump* draggingGump = nullptr;
	for (const auto& gump : m_GumpList)
	{
		if (gump->m_gui.m_IsDragging || gump->m_gui.m_DragPressCaptured)
		{
			draggingGump = gump.get();
			break;
		}
	}

	// First pass: Find topmost gump under mouse (iterate backwards to find last one)
	for (auto it = m_GumpList.rbegin(); it != m_GumpList.rend(); ++it)
	{
		Rectangle gumpRect = (*it)->m_gui.GetBounds();
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
			if (g_InputSystem->IsLButtonJustDown() && !m_draggingObject && draggingGump == nullptr)
			{
				gumpToMoveToFront = *it;
			}
			break; // Found topmost, stop searching
		}
	}

	// While window-dragging, force hit-test / mouse-over to the dragged gump so
	// it stays "topmost" for input and stays visually treated as the active window.
	if (draggingGump != nullptr && !m_draggingObject)
	{
		topmostGumpUnderMouse = draggingGump;
		m_isMouseOverGump = true;
		m_gumpUnderMouse = draggingGump;
	}

	// Second pass: Update all gumps, but only let topmost one receive input
	for (vector<std::shared_ptr<Gump>>::iterator gump = m_GumpList.begin(); gump != m_GumpList.end();)
	{
		// Temporarily disable ALL input (including buttons) for non-topmost gumps.
		// Keep the window-drag owner active so it continues to follow the mouse and
		// can clear IsDragging on release even if the cursor left its pixels.
		bool wasActive = (*gump)->m_gui.m_Active;
		const bool isDragOwner = (draggingGump != nullptr && (*gump).get() == draggingGump);
		if (m_draggingObject ||
			(!isDragOwner && topmostGumpUnderMouse != nullptr && (*gump).get() != topmostGumpUnderMouse))
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

	// After updates, re-find the window-drag owner (may have just started this frame).
	draggingGump = nullptr;
	for (const auto& gump : m_GumpList)
	{
		if (gump->m_gui.m_IsDragging || gump->m_gui.m_DragPressCaptured)
		{
			draggingGump = gump.get();
			break;
		}
	}

	// Keep the drag owner drawn on top for the whole drag.
	if (draggingGump != nullptr)
	{
		for (const auto& gump : m_GumpList)
		{
			if (gump.get() == draggingGump)
			{
				gumpToMoveToFront = gump;
				break;
			}
		}
	}

	// Bring clicked / drag-owner gump to front by moving it to the end of the list
	if (gumpToMoveToFront)
	{
		auto it = std::find(m_GumpList.begin(), m_GumpList.end(), gumpToMoveToFront);
		if (it != m_GumpList.end() && it != m_GumpList.end() - 1)
		{
			m_GumpList.erase(it);
			m_GumpList.push_back(gumpToMoveToFront);
		}
	}

	// Safety: if LMB is up, force-clear window-drag state on every gump so a
	// previously-deactivated owner cannot leave m_IsDragging stuck.
	if (!g_InputSystem->IsLButtonDown())
	{
		for (auto& gump : m_GumpList)
		{
			gump->m_gui.m_IsDragging = false;
			gump->m_gui.m_DragPressCaptured = false;
		}
	}

	// Handle using objects from inventory


	// Handle dragging
	if (g_gumpManager->m_draggingObject && !g_InputSystem->IsLButtonDown())
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

		// Re-check which gump is under mouse now (may have changed during drag)
		// Use same logic as initial check: proper z-order (rbegin) and pixel-perfect collision
		m_gumpUnderMouse = nullptr;
		m_isMouseOverGump = false;
		for (auto it = m_GumpList.rbegin(); it != m_GumpList.rend(); ++it)
		{
			Rectangle gumpRect = (*it)->m_gui.GetBounds();
			bool collision = CheckCollisionPointRec(mousePos, gumpRect);

			// Pixel-perfect collision detection (checks transparency)
			if (collision)
			{
				collision = (*it)->IsMouseOverSolidPixel(mousePos);
			}

			if (collision)
			{
				m_gumpUnderMouse = (*it).get();
				m_isMouseOverGump = true;
				break;  // Found topmost gump with solid pixel under mouse
			}
		}

		// Handle dropping onto the Avatar or other party member.
		if (g_objectUnderMousePointer != nullptr && g_objectUnderMousePointer == g_Player->GetAvatarObject())
		{
			//  Attempt to drop the object into the Avatar's inventory.
			U7Object* avatar = g_Player->GetAvatarObject();
			U7Object* draggedObject = GetObjectFromID(m_draggedObjectId);
			if (avatar->GetRemainingCarryCapacity() > object->GetWeight())
			{
				AddConsoleString("Added " + GetObjectDisplayName(draggedObject) + " to Avatar's inventory.", WHITE);
				int backpackId = g_NPCData[0]->GetEquippedItem(EquipmentSlot::SLOT_BACKPACK);

				AddObjectToContainer(m_draggedObjectId, backpackId);
				if (draggedObject->m_shapeData->GetShape() == 641 && draggedObject->m_Quality == 253)
				{
					g_ScriptingSystem->SetFlag(60, 1);
				}
				g_SoundSystem->PlaySound(BuildU7SfxPath(74));
				g_gumpManager->m_draggingObject = false;
				g_gumpManager->m_draggedObjectId = -1;
				g_gumpManager->m_sourceGump = nullptr;
			}
			else
			{
				AddConsoleString("Too heavy!", RED);
			}
		}

		//  First check if we're dropping on a paperdoll
		bool droppedOnPaperdoll = false;
		bool attemptedPaperdollDrop = false;

		// Use m_gumpUnderMouse which already has proper z-order and pixel-perfect collision
		GumpPaperdoll* paperdoll = dynamic_cast<GumpPaperdoll*>(m_gumpUnderMouse);
		if (paperdoll)
		{
			attemptedPaperdollDrop = true;
			droppedOnPaperdoll = paperdoll->HandleDrop(object, mousePos);

			if (droppedOnPaperdoll)
			{
				g_SoundSystem->PlaySound(BuildU7SfxPath(74));
				g_gumpManager->m_draggingObject = false;
				g_gumpManager->m_draggedObjectId = -1;
				g_gumpManager->m_sourceGump = nullptr;
			}
		}

		//  If not dropped on paperdoll, check dragging to regular containers
		if (!droppedOnPaperdoll)
		{
			// Only allow dropping on the gump that's actually under the mouse (proper z-order and pixel-perfect)
			Gump* targetGump = m_gumpUnderMouse;

			// Check if the gump under mouse is a container gump
			if (targetGump != nullptr && targetGump->m_containerObject != nullptr)
			{
				auto& gump = targetGump;

				if (CheckCollisionPointRec(mousePos, gump->m_gui.GetBounds()))
				{
					// Check if root owner is an NPC and can carry this item
					U7Object* rootNPC = GetRootNPCFromContainer(gump->m_containerObject);
					float itemWeight = object->GetWeight();
					bool canCarry = true;

					if (rootNPC != nullptr)
					{
						float remainingCapacity = rootNPC->GetRemainingCarryCapacity();
						if (itemWeight > remainingCapacity)
						{
							canCarry = false;
							AddConsoleString("Too heavy! Cannot carry that much.", RED);
							Log("Drop failed: Item weight " + std::to_string(itemWeight) +
								" exceeds NPC remaining capacity " + std::to_string(remainingCapacity));
						}
					}

					if (canCarry)
					{
						if (CheckCollisionPointRec(mousePos, Rectangle{ gump->m_gui.m_Pos.x + (gump->m_containerData.m_boxOffset.x), gump->m_gui.m_Pos.y + (gump->m_containerData.m_boxOffset.y),
	gump->m_containerData.m_boxSize.x, gump->m_containerData.m_boxSize.y }))
						{
							// Center item on cursor by offsetting by half the item's size
							float itemWidth = object->m_shapeData->GetDefaultTextureImage().width;
							float itemHeight = object->m_shapeData->GetDefaultTextureImage().height;
							object->m_InventoryPos = {
								mousePos.x - (gump->m_gui.m_Pos.x + (gump->m_containerData.m_boxOffset.x)) - (itemWidth / 2.0f),
								mousePos.y - (gump->m_gui.m_Pos.y + (gump->m_containerData.m_boxOffset.y)) - (itemHeight / 2.0f)
							};
						}
						else // In the container but not in the box area
						{
							object->m_InventoryPos = { 0, 0 };
						}

						// Add to new container (item was already removed from source when drag started)
						gump->m_containerObject->AddObjectToInventory(object->m_ID);
						if (object->m_shapeData->GetShape() == 641 && object->m_Quality == 253)
						{
							g_ScriptingSystem->SetFlag(60, 1);
						}

						g_SoundSystem->PlaySound(BuildU7SfxPath(74));
						g_gumpManager->m_draggingObject = false;
						g_gumpManager->m_draggedObjectId = -1;
						g_gumpManager->m_sourceGump = nullptr;
					}
					// If can't carry, leave m_draggingObject true so it falls through to return-to-source logic
				}
			}
		}

		//  Didn't drag into another container?  Try to return to source, otherwise drop to ground
		if (g_gumpManager->m_draggingObject)
		{
			bool returnedToSource = false;

			// Return to source when: over a gump (failed container drop), or world drop is invalid.
			const bool wantReturnToSource =
				m_sourceGump != nullptr &&
				(m_gumpUnderMouse != nullptr || !m_dropValid);

			if (wantReturnToSource)
			{
				GumpPaperdoll* sourcePaperdoll = dynamic_cast<GumpPaperdoll*>(m_sourceGump);
				if (sourcePaperdoll)
				{
					auto sourceNpcIt = g_NPCData.find(sourcePaperdoll->GetNpcId());
					if (sourceNpcIt != g_NPCData.end() && m_sourceSlotIndex >= 0)
					{
						int shape = object->m_shapeData->GetShape();
						std::vector<EquipmentSlot> fillSlots = GetEquipmentSlotsFilled(shape);
						if (!fillSlots.empty())
						{
							for (EquipmentSlot fillSlot : fillSlots)
								sourceNpcIt->second->SetEquippedItem(fillSlot, object->m_ID);
						}
						else
						{
							sourceNpcIt->second->SetEquippedItem(
								static_cast<EquipmentSlot>(m_sourceSlotIndex), object->m_ID);
						}
						g_SoundSystem->PlaySound(BuildU7SfxPath(76));
						if (g_mainState) g_mainState->ShowErrorCursor();
						returnedToSource = true;
					}
				}
				else if (m_sourceGump->m_containerObject != nullptr)
				{
					m_sourceGump->m_containerObject->AddObjectToInventory(object->m_ID);
					g_SoundSystem->PlaySound(BuildU7SfxPath(76));
					if (g_mainState) g_mainState->ShowErrorCursor();
					returnedToSource = true;
					Log(!m_dropValid
						? "Returned item to source container (blocked placement)"
						: "Returned item to source container");
				}
			}

			if (!returnedToSource)
			{
				// World-origin drag with invalid/failed drop → original world pos.
				if (!m_dropValid || m_gumpUnderMouse != nullptr)
				{
					object->SetPos(m_draggedObjectOriginalPos);
					object->SetDest(m_draggedObjectOriginalDest);
					g_SoundSystem->PlaySound(BuildU7SfxPath(76));
					if (g_mainState) g_mainState->ShowErrorCursor();
					Log(!m_dropValid
						? "Returned item to original world position (blocked placement)"
						: "Returned item to original world position (drop failed)");
				}
				else
				{
					object->SetPos(m_dropPosition);
					g_SoundSystem->PlaySound(BuildU7SfxPath(74));
					Log("Dropped item to ground");

					if (m_draggedObjectOriginalPos.x == m_draggedObjectOriginalDest.x &&
						m_draggedObjectOriginalPos.y == m_draggedObjectOriginalDest.y &&
						m_draggedObjectOriginalPos.z == m_draggedObjectOriginalDest.z)
					{
						object->SetDest(object->m_Pos);
					}

					// Dough dropped onto a baking hearth → start bake timer (event 3).
					if (object->m_ObjectType == 658 && g_ScriptingSystem)
					{
						g_ScriptingSystem->CallScript("object_dough_0658",
							{ static_cast<lua_Integer>(3), static_cast<lua_Integer>(object->m_ID) });
					}
				}
				object->m_isContained = false;
			}

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

		//mousePos = Vector2Add(mousePos, m_draggedObjectOffset);
		mousePos = Vector2Subtract(mousePos, {float(object->m_shapeData->m_texture->m_Image.width) * .75f, float(object->m_shapeData->m_texture->m_Image.height) * .75f });

		object->m_shapeData->DrawInventoryIcon(int(mousePos.x), int(mousePos.y));
	}
}

void GumpManager::AddGump(std::shared_ptr<Gump> Gump)
{
	// Add to pending list instead of directly to avoid iterator invalidation
	m_PendingGumps.push_back(Gump);

	// Play gump open sound
	g_SoundSystem->PlaySound(BuildU7SfxPath(14));
}

void GumpManager::CloseGumpForObject(int objectId)
{
	// Close any gump associated with this object to prevent dragging into itself
	for (auto& gump : m_GumpList)
	{
		if (gump->GetContainerId() == objectId)
		{
			gump->OnExit();
			Log("Closed gump for container " + std::to_string(objectId) + " on drag start");
			break;
		}
	}
}

void GumpManager::CloseSpellbookForNpc(int npcId)
{
	// Close any spellbook gump for this NPC
	for (auto& gump : m_GumpList)
	{
		GumpSpellbook* spellbook = dynamic_cast<GumpSpellbook*>(gump.get());
		if (spellbook && spellbook->GetNpcId() == npcId)
		{
			spellbook->OnExit();
			Log("Closed spellbook gump for NPC " + std::to_string(npcId));
			break;
		}
	}
}

void GumpManager::CloseAllGumps()
{
	// Call OnExit on all gumps and immediately clear the list
	int count = static_cast<int>(m_GumpList.size());
	for (auto& gump : m_GumpList)
	{
		gump->OnExit();
	}
	m_GumpList.clear();
	m_PendingGumps.clear();  // Also clear any pending gumps
	m_isMouseOverGump = false;
	m_gumpUnderMouse = nullptr;

	Log("Closed all gumps (" + std::to_string(count) + " total)");
}

bool GumpManager::IsAnyGumpBeingDragged()
{
	for (const auto& gump : m_GumpList)
	{
		if (gump->m_gui.m_IsDragging || gump->m_gui.m_DragPressCaptured)
		{
			return true;
		}
	}
	return false;
}