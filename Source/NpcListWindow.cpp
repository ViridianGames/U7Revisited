#include "NpcListWindow.h"
#include "Ghost/GhostWindow.h"
#include "Geist/GuiElements.h"
#include "Geist/Gui.h"
#include "U7Globals.h"
#include <algorithm>
#include <cctype>

// Activity names for display (Ultima 7 official schedule types)
static const char* ACTIVITY_NAMES[] = {
    "Combat",          // 0
    "Horizontal Pace", // 1
    "Vertical Pace",   // 2
    "Talk",            // 3
    "Dance",           // 4
    "Eat",             // 5
    "Farm",            // 6
    "Tend Shop",       // 7
    "Miner",           // 8
    "Hound",           // 9
    "Stand",           // 10
    "Loiter",          // 11
    "Wander",          // 12
    "Blacksmith",      // 13
    "Sleep",           // 14
    "Wait",            // 15
    "Major Sit",       // 16
    "Graze",           // 17
    "Bake",            // 18
    "Sew",             // 19
    "Shy",             // 20
    "Lab",             // 21
    "Thief",           // 22
    "Waiter",          // 23
    "Special",         // 24
    "Kid Games",       // 25
    "Eat at Inn",      // 26
    "Duel",            // 27
    "Preach",          // 28
    "Patrol",          // 29
    "Desk Work",       // 30
    "Follow Avatar"    // 31
};

NpcListWindow::NpcListWindow(ResourceManager* resourceManager, int screenWidth, int screenHeight)
	: m_window(nullptr)
	, m_lastSearchText("")
	, m_sortMode(SortMode::BY_ID)
	, m_lastScheduleTime(0)
	, m_lastRefreshTime(0.0)
{
	m_window = new GhostWindow("Gui/npc_list_window.ghost", "Gui",
	                           resourceManager, screenWidth, screenHeight,
	                           false, 1.0f, 1.0f);  // Not modal - uses g_mouseOverUI instead

	// Don't build list in constructor - it will be built when window is first shown
	// This ensures InitializeNPCActivitiesFromSchedules() has run first
}

NpcListWindow::~NpcListWindow()
{
	delete m_window;
}

void NpcListWindow::Update(bool schedulesEnabled)
{
	if (!m_window || !m_window->IsVisible())
		return;

	m_window->Update();

	// Update header status based on schedule state
	UpdateHeaderStatus(schedulesEnabled);

	// Check if search text changed
	Gui* gui = m_window->GetGui();
	if (!gui)
		return;

	int searchInputId = m_window->GetElementID("SEARCH_INPUT");
	auto searchElement = gui->GetElement(searchInputId);

	if (searchElement && searchElement->m_Type == GUI_TEXTINPUT)
	{
		auto textInput = static_cast<GuiTextInput*>(searchElement.get());
		if (textInput->m_String != m_lastSearchText)
		{
			m_lastSearchText = textInput->m_String;
			RebuildFilteredList();
		}
	}

	// Check for CLEAR button click
	int clearButtonId = m_window->GetElementID("CLEAR");
	auto clearButtonElement = gui->GetElement(clearButtonId);

	if (clearButtonElement && clearButtonElement->m_Type == GUI_ICONBUTTON)
	{
		auto clearButton = static_cast<GuiIconButton*>(clearButtonElement.get());
		if (clearButton->m_Clicked)
		{
			// Clear the search input
			if (searchElement && searchElement->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(searchElement.get());
				textInput->m_String = "";
				m_lastSearchText = "";
				RebuildFilteredList();
			}
			clearButton->m_Clicked = false;
		}
	}

	// Check for sort button clicks
	int sortIdButtonId = m_window->GetElementID("SORT_ID");
	auto sortIdElement = gui->GetElement(sortIdButtonId);
	if (sortIdElement && sortIdElement->m_Type == GUI_TEXTBUTTON)
	{
		auto sortIdButton = static_cast<GuiTextButton*>(sortIdElement.get());
		if (sortIdButton->m_Clicked)
		{
			m_sortMode = SortMode::BY_ID;
			SortNPCList();
			RebuildFilteredList();
			sortIdButton->m_Clicked = false;
		}
	}

	int sortNameButtonId = m_window->GetElementID("SORT_NAME");
	auto sortNameElement = gui->GetElement(sortNameButtonId);
	if (sortNameElement && sortNameElement->m_Type == GUI_TEXTBUTTON)
	{
		auto sortNameButton = static_cast<GuiTextButton*>(sortNameElement.get());
		if (sortNameButton->m_Clicked)
		{
			m_sortMode = SortMode::BY_NAME;
			SortNPCList();
			RebuildFilteredList();
			sortNameButton->m_Clicked = false;
		}
	}

	int sortActivityButtonId = m_window->GetElementID("SORT_ACTIVITY");
	auto sortActivityElement = gui->GetElement(sortActivityButtonId);
	if (sortActivityElement && sortActivityElement->m_Type == GUI_TEXTBUTTON)
	{
		auto sortActivityButton = static_cast<GuiTextButton*>(sortActivityElement.get());
		if (sortActivityButton->m_Clicked)
		{
			m_sortMode = SortMode::BY_ACTIVITY;
			SortNPCList();
			RebuildFilteredList();
			sortActivityButton->m_Clicked = false;
		}
	}

	// Check for click on listbox (single-click to move camera)
	int listboxId = m_window->GetElementID("NPC_LISTBOX");
	auto listboxElement = gui->GetElement(listboxId);

	if (listboxElement && listboxElement->m_Type == GUI_LISTBOX)
	{
		auto listbox = static_cast<GuiListBox*>(listboxElement.get());

		// Single-click moves camera to NPC
		if (listbox->m_Clicked)
		{
			HandleDoubleClick();  // Reuse same function for single-click
			listbox->m_Clicked = false;  // Reset flag
		}
	}

	// Check if schedule time has changed - rebuild list to show updated activities
	// This happens at the start of each 3-hour schedule block (0:00, 3:00, 6:00, 9:00, etc.)
	extern unsigned int g_scheduleTime;
	if (g_scheduleTime != m_lastScheduleTime)
	{
		m_lastScheduleTime = g_scheduleTime;
		BuildNPCList();
		RebuildFilteredList();
	}
}

void NpcListWindow::Draw()
{
	if (m_window && m_window->IsVisible())
	{
		m_window->Draw();
	}
}

void NpcListWindow::Show()
{
	if (m_window)
	{
		DebugPrint("NpcListWindow::Show() called");
		// Debug: Check Blacktooth's activity before building list
		if (g_NPCData.find(226) != g_NPCData.end())
		{
			DebugPrint("  Before BuildNPCList: Blacktooth m_currentActivity=" + 
			           std::to_string(g_NPCData[226]->m_currentActivity));
		}
		
		m_window->Show();
		BuildNPCList();  // Refresh list when shown
		RebuildFilteredList();
	}
}

void NpcListWindow::Hide()
{
	if (m_window)
		m_window->Hide();
}

void NpcListWindow::Toggle()
{
	if (m_window)
	{
		m_window->Toggle();
		// If we just became visible, refresh the NPC list
		if (m_window->IsVisible())
		{
			BuildNPCList();
			RebuildFilteredList();
		}
	}
}

bool NpcListWindow::IsVisible() const
{
	return m_window && m_window->IsVisible();
}

void NpcListWindow::BuildNPCList()
{
	m_allNPCs.clear();

	DebugPrint("BuildNPCList: g_NPCData has " + std::to_string(g_NPCData.size()) + " NPCs");

	extern unsigned int g_scheduleTime;

	// Iterate through all NPCs in g_NPCData
	for (const auto& pair : g_NPCData)
	{
		int npcId = pair.first;
		NPCData* npcData = pair.second.get();

		if (!npcData)
			continue;

		NPCListEntry entry;
		entry.npcId = npcId;
		entry.name = std::string(npcData->name);
		entry.activityId = npcData->m_currentActivity;
		entry.activityName = GetActivityName(npcData->m_currentActivity);
		
		// Debug: Log activity for Blacktooth
		if (npcId == 226)
		{
			DebugPrint("BuildNPCList: Blacktooth (226) m_currentActivity=" + std::to_string(npcData->m_currentActivity) + 
			           " activityName=" + entry.activityName);
		}

		// Check if this is a "continued" activity (not an exact schedule match for current time)
		bool isContinued = false;
		if (g_NPCSchedules.find(npcId) != g_NPCSchedules.end())
		{
			const auto& schedules = g_NPCSchedules[npcId];

			// Check if there's an exact schedule match for current time
			bool exactMatch = false;
			for (const auto& schedule : schedules)
			{
				if (schedule.m_time == g_scheduleTime)
				{
					exactMatch = true;
					break;
				}
			}

			// If no exact match and we have a valid activity, it's continued from previous
			if (!exactMatch && npcData->m_currentActivity >= 0)
			{
				isContinued = true;
			}
		}

		// Format: "ID: Name - Activity" or "ID: Name - Activity - cont"
		entry.displayText = std::to_string(npcId) + ": " +
		                   entry.name + " - " +
		                   entry.activityName;

		if (isContinued)
		{
			entry.displayText += " - cont";
		}

		m_allNPCs.push_back(entry);
	}

	SortNPCList();

	DebugPrint("BuildNPCList: Built list with " + std::to_string(m_allNPCs.size()) + " NPCs");
}

void NpcListWindow::SortNPCList()
{
	switch (m_sortMode)
	{
		case SortMode::BY_ID:
			std::sort(m_allNPCs.begin(), m_allNPCs.end(),
			         [](const NPCListEntry& a, const NPCListEntry& b) {
				         return a.npcId < b.npcId;
			         });
			break;

		case SortMode::BY_NAME:
			std::sort(m_allNPCs.begin(), m_allNPCs.end(),
			         [](const NPCListEntry& a, const NPCListEntry& b) {
				         return a.name < b.name;
			         });
			break;

		case SortMode::BY_ACTIVITY:
			std::sort(m_allNPCs.begin(), m_allNPCs.end(),
			         [](const NPCListEntry& a, const NPCListEntry& b) {
				         // "No Schedule" always goes to the end
				         bool aIsNoSchedule = (a.activityId < 0);
				         bool bIsNoSchedule = (b.activityId < 0);

				         if (aIsNoSchedule && !bIsNoSchedule) return false;  // a goes after b
				         if (!aIsNoSchedule && bIsNoSchedule) return true;   // a goes before b
				         if (aIsNoSchedule && bIsNoSchedule) return a.npcId < b.npcId;  // Both "No Schedule", sort by ID

				         // Both have activities, sort by activity name
				         return a.activityName < b.activityName;
			         });
			break;
	}
}

void NpcListWindow::RebuildFilteredList()
{
	// Get current selection before rebuilding
	Gui* gui = m_window->GetGui();
	if (!gui)
	{
		DebugPrint("RebuildFilteredList: No GUI!");
		return;
	}

	int listboxId = m_window->GetElementID("NPC_LISTBOX");
	auto listboxElement = gui->GetElement(listboxId);

	if (!listboxElement || listboxElement->m_Type != GUI_LISTBOX)
	{
		DebugPrint("RebuildFilteredList: NPC_LISTBOX not found or wrong type! ID=" + std::to_string(listboxId));
		return;
	}

	auto listbox = static_cast<GuiListBox*>(listboxElement.get());

	// Save currently selected NPC ID (if any)
	int selectedNpcId = -1;
	int oldSelectedIndex = listbox->GetSelectedIndex();
	if (oldSelectedIndex >= 0 && oldSelectedIndex < (int)m_filteredNPCs.size())
	{
		selectedNpcId = m_filteredNPCs[oldSelectedIndex].npcId;
	}

	m_filteredNPCs.clear();

	// Convert search text to lowercase for case-insensitive search
	std::string searchLower = m_lastSearchText;
	std::transform(searchLower.begin(), searchLower.end(), searchLower.begin(),
	              [](unsigned char c) { return std::tolower(c); });

	// Filter NPCs
	for (const auto& entry : m_allNPCs)
	{
		if (searchLower.empty())
		{
			// No filter - add all
			m_filteredNPCs.push_back(entry);
		}
		else
		{
			// Case-insensitive substring match on name
			std::string nameLower = entry.displayText;
			std::transform(nameLower.begin(), nameLower.end(), nameLower.begin(),
			              [](unsigned char c) { return std::tolower(c); });

			if (nameLower.find(searchLower) != std::string::npos)
			{
				m_filteredNPCs.push_back(entry);
			}
		}
	}

	// Update listbox with filtered items
	listbox->Clear();

	for (const auto& entry : m_filteredNPCs)
	{
		listbox->AddItem(entry.displayText);
	}

	// Restore selection if the NPC is still in the filtered list
	if (selectedNpcId >= 0)
	{
		for (size_t i = 0; i < m_filteredNPCs.size(); i++)
		{
			if (m_filteredNPCs[i].npcId == selectedNpcId)
			{
				listbox->SetSelectedIndex((int)i);
				break;
			}
		}
	}

	DebugPrint("RebuildFilteredList: Added " + std::to_string(m_filteredNPCs.size()) + " items to listbox");
}

void NpcListWindow::HandleDoubleClick()
{
	Gui* gui = m_window->GetGui();
	if (!gui)
		return;

	int listboxId = m_window->GetElementID("NPC_LISTBOX");
	auto listboxElement = gui->GetElement(listboxId);

	if (!listboxElement || listboxElement->m_Type != GUI_LISTBOX)
		return;

	auto listbox = static_cast<GuiListBox*>(listboxElement.get());
	int selectedIndex = listbox->GetSelectedIndex();

	if (selectedIndex < 0 || selectedIndex >= (int)m_filteredNPCs.size())
		return;

	// Get the NPC ID from the selected entry
	int npcId = m_filteredNPCs[selectedIndex].npcId;

	// Find the NPC in g_NPCData
	if (g_NPCData.find(npcId) == g_NPCData.end())
		return;

	NPCData* npcData = g_NPCData[npcId].get();
	if (!npcData)
		return;

	// Get the NPC's object
	auto it = g_objectList.find(npcData->m_objectID);
	if (it == g_objectList.end())
		return;

	U7Object* npc = it->second.get();
	if (!npc)
		return;

	// Teleport camera to NPC position (preserving current angle and distance)
	Vector3 npcPos = npc->GetPos();
	g_camera.target = Vector3{ npcPos.x, 0, npcPos.z };

	// Recalculate camera position using current rotation and distance
	Vector3 camOffset = { g_cameraDistance, g_cameraDistance, g_cameraDistance };
	camOffset = Vector3RotateByAxisAngle(camOffset, Vector3{ 0, 1, 0 }, g_cameraRotation);
	g_camera.position = Vector3Add(g_camera.target, camOffset);

	g_CameraMoved = true;

	// DISABLED: Reduce log spam to improve responsiveness when clicking NPCs
	// DebugPrint("Camera teleported to NPC " + std::string(npcData->name) +
	//           " at (" + std::to_string((int)npcPos.x) + ", " +
	//           std::to_string((int)npcPos.z) + ")");
}

std::string NpcListWindow::GetActivityName(int activityId)
{
	if (activityId < 0)
	{
		return "No Schedule";
	}
	else if (activityId >= 0 && activityId <= 31)
	{
		return ACTIVITY_NAMES[activityId];
	}
	else
	{
		return "Unknown (" + std::to_string(activityId) + ")";
	}
}

void NpcListWindow::UpdateHeaderStatus(bool schedulesEnabled)
{
	Gui* gui = m_window->GetGui();
	if (!gui)
		return;

	int headerId = m_window->GetElementID("LIST_HEADER");
	auto headerElement = gui->GetElement(headerId);

	if (headerElement && headerElement->m_Type == GUI_TEXTAREA)
	{
		auto header = static_cast<GuiTextArea*>(headerElement.get());

		if (schedulesEnabled)
		{
			header->m_String = "NPC List";
			header->m_Color = Color{ 0, 255, 0, 255 };  // Green
		}
		else
		{
			header->m_String = "NPC List - DISABLED";
			header->m_Color = Color{ 255, 0, 0, 255 };  // Red
		}
	}
}

void NpcListWindow::SelectNPC(int npcId)
{
	if (!m_window || !m_window->IsVisible())
		return;

	Gui* gui = m_window->GetGui();
	if (!gui)
		return;

	// Clear the search input
	int searchInputId = m_window->GetElementID("SEARCH_INPUT");
	auto searchElement = gui->GetElement(searchInputId);

	if (searchElement && searchElement->m_Type == GUI_TEXTINPUT)
	{
		auto textInput = static_cast<GuiTextInput*>(searchElement.get());
		textInput->m_String = "";
		m_lastSearchText = "";
	}

	// Rebuild filtered list (now shows all NPCs since search is cleared)
	RebuildFilteredList();

	// Find the NPC in the filtered list
	int listboxId = m_window->GetElementID("NPC_LISTBOX");
	auto listboxElement = gui->GetElement(listboxId);

	if (!listboxElement || listboxElement->m_Type != GUI_LISTBOX)
		return;

	auto listbox = static_cast<GuiListBox*>(listboxElement.get());

	// Find index of NPC with matching ID
	int indexToSelect = -1;
	for (size_t i = 0; i < m_filteredNPCs.size(); i++)
	{
		if (m_filteredNPCs[i].npcId == npcId)
		{
			indexToSelect = (int)i;
			break;
		}
	}

	if (indexToSelect >= 0)
	{
		// Select the NPC (SetSelectedIndex automatically scrolls to make it visible)
		listbox->SetSelectedIndex(indexToSelect);
	}
}
