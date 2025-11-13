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

		//  First check if we're dropping on a paperdoll
		bool droppedOnPaperdoll = false;
		bool attemptedPaperdollDrop = false;
		// Iterate backwards to check topmost gumps first (last in list = highest z-order)
		for (auto it = g_gumpManager->m_GumpList.rbegin(); it != g_gumpManager->m_GumpList.rend(); ++it)
		{
			auto& gump = *it;
			GumpPaperdoll* paperdoll = dynamic_cast<GumpPaperdoll*>(gump.get());
			if (paperdoll)
			{
				// Check if mouse is over this paperdoll
				if (CheckCollisionPointRec(mousePos, gump->m_gui.GetBounds()))
				{
					attemptedPaperdollDrop = true;

					// Get all valid slots this item can be equipped to
					int shape = object->m_shapeData->GetShape();
					std::vector<EquipmentSlot> validSlots = GetEquipmentSlotsForShape(shape);
					std::vector<EquipmentSlot> fillSlots = GetEquipmentSlotsFilled(shape);

					if (!validSlots.empty())
					{
						// Get NPC data
						auto npcIt = g_NPCData.find(paperdoll->GetNpcId());
						if (npcIt != g_NPCData.end())
						{
							NPCData* npcData = npcIt->second.get();

							// Check if mouse is over a specific highlighted slot
							EquipmentSlot targetSlot = EquipmentSlot::SLOT_COUNT;
							if (!paperdoll->m_highlightedSlots.empty())
							{
								// Check each highlighted slot to see if mouse is over it
								for (int slotIndex : paperdoll->m_highlightedSlots)
								{
									EquipmentSlot slot = static_cast<EquipmentSlot>(slotIndex);
									// Check if this is a valid slot for this item
									if (std::find(validSlots.begin(), validSlots.end(), slot) != validSlots.end())
									{
										// Get slot sprite bounds to check mouse position
										static const char* slotNames[] = {
											"SLOT_HEAD", "SLOT_NECK", "SLOT_TORSO", "SLOT_LEGS", "SLOT_HANDS", "SLOT_FEET",
											"SLOT_LEFT_HAND", "SLOT_RIGHT_HAND", "SLOT_AMMO", "SLOT_LEFT_RING", "SLOT_RIGHT_RING",
											"SLOT_BELT", "SLOT_BACKPACK"
										};

										int slotID = paperdoll->m_serializer->GetElementID(slotNames[slotIndex]);
										if (slotID != -1)
										{
											auto element = paperdoll->m_gui.GetElement(slotID);
											if (element)
											{
												GuiSprite* slotSprite = dynamic_cast<GuiSprite*>(element.get());
												if (slotSprite)
												{
													float width = slotSprite->m_Width * slotSprite->m_ScaleX;
													float height = slotSprite->m_Height * slotSprite->m_ScaleY;
													if (width < 16.0f) width = 16.0f;
													if (height < 16.0f) height = 16.0f;

													Rectangle slotRect = {
														paperdoll->m_gui.m_Pos.x + slotSprite->m_Pos.x,
														paperdoll->m_gui.m_Pos.y + slotSprite->m_Pos.y,
														width,
														height
													};

													if (CheckCollisionPointRec(mousePos, slotRect))
													{
														targetSlot = slot;
														break;
													}
												}
											}
										}
									}
								}
							}

							// If we found a specific target slot, try that first; otherwise try all valid slots
							std::vector<EquipmentSlot> slotsToTry;
							if (targetSlot != EquipmentSlot::SLOT_COUNT)
							{
								slotsToTry.push_back(targetSlot);
								// Add remaining valid slots as fallback
								for (EquipmentSlot slot : validSlots)
								{
									if (slot != targetSlot)
										slotsToTry.push_back(slot);
								}
							}
							else
							{
								slotsToTry = validSlots;
							}

							// Try each slot in order (target slot first if specified)
							for (EquipmentSlot slot : slotsToTry)
							{
								// If item has explicit fills, check all those slots are empty
								// Otherwise just check the single slot
								bool allSlotsEmpty = true;
								if (!fillSlots.empty())
								{
									// Multi-slot item (e.g., crossbow, gauntlets) - check ALL fill slots
									for (EquipmentSlot fillSlot : fillSlots)
									{
										if (npcData->GetEquippedItem(fillSlot) != -1)
										{
											allSlotsEmpty = false;
											break;
										}
									}
								}
								else
								{
									// Single-slot item - just check this slot
									allSlotsEmpty = (npcData->GetEquippedItem(slot) == -1);
								}

								if (allSlotsEmpty)
								{
									// Equip: if fills is specified, use those slots; otherwise just the single slot
									if (!fillSlots.empty())
									{
										for (EquipmentSlot fillSlot : fillSlots)
										{
											npcData->SetEquippedItem(fillSlot, object->m_ID);
										}
									}
									else
									{
										npcData->SetEquippedItem(slot, object->m_ID);
									}
									object->m_isContained = true;
									droppedOnPaperdoll = true;
									Log("Equipped shape " + std::to_string(shape) + " to slot " + std::to_string(static_cast<int>(slot)) +
									    " (fills " + std::to_string(fillSlots.size()) + " slots)");
									break;
								}
							}

							if (!droppedOnPaperdoll)
							{
								Log("Cannot equip - required slots are occupied");
							}
						}
					}
					else
					{
						Log("Cannot equip shape " + std::to_string(shape) + " - not an equippable item");
					}

					// Only break if we successfully dropped on paperdoll
					// If we failed, continue to check other gumps (containers)
					if (droppedOnPaperdoll)
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

				if (CheckCollisionPointRec(mousePos, gump->m_gui.GetBounds()))
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

		//  Didn't drag into another container?  Try to return to source, otherwise drop to ground
		if (g_gumpManager->m_draggingObject)
		{
			bool returnedToSource = false;

			// Only return to source if mouse is over a gump (failed drop attempt)
			// If mouse is over the world (m_gumpUnderMouse == nullptr), user wants to drop to ground
			if (m_sourceGump != nullptr && m_gumpUnderMouse != nullptr)
			{
				GumpPaperdoll* sourcePaperdoll = dynamic_cast<GumpPaperdoll*>(m_sourceGump);
				if (sourcePaperdoll)
				{
					// Re-equip to the exact slot(s) we dragged from
					auto sourceNpcIt = g_NPCData.find(sourcePaperdoll->GetNpcId());
					if (sourceNpcIt != g_NPCData.end() && m_sourceSlotIndex >= 0)
					{
						int shape = object->m_shapeData->GetShape();
						std::vector<EquipmentSlot> fillSlots = GetEquipmentSlotsFilled(shape);

						// Re-equip to the same slot(s) we removed from
						if (!fillSlots.empty())
						{
							// Multi-slot item - re-equip to all fill slots
							for (EquipmentSlot fillSlot : fillSlots)
							{
								sourceNpcIt->second->SetEquippedItem(fillSlot, object->m_ID);
							}
							Log("Returned multi-slot item to source paperdoll slot " + std::to_string(m_sourceSlotIndex) +
							    " (filled " + std::to_string(fillSlots.size()) + " slots)");
						}
						else
						{
							// Single-slot item - re-equip to the exact slot
							sourceNpcIt->second->SetEquippedItem(static_cast<EquipmentSlot>(m_sourceSlotIndex), object->m_ID);
							Log("Returned item to source paperdoll slot " + std::to_string(m_sourceSlotIndex));
						}
						object->m_isContained = true;
						returnedToSource = true;
					}
				}
				else if (m_sourceGump->m_containerObject != nullptr)
				{
					// Return to source container inventory
					m_sourceGump->m_containerObject->m_inventory.push_back(object->m_ID);
					object->m_isContained = true;
					returnedToSource = true;
					Log("Returned item to source container");
				}
			}

			// If we couldn't return to source, drop to ground
			if (!returnedToSource)
			{
				object->SetPos(g_terrainUnderMousePointer);
				object->m_isContained = false;
				Log("Dropped item to ground");
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