#ifndef _NPCLISTWINDOW_H_
#define _NPCLISTWINDOW_H_

#include "Ghost/GhostWindow.h"
#include <string>
#include <vector>

class Gui;
class GuiTextInput;
class GuiListBox;

struct NPCListEntry
{
	int npcId;
	std::string name;
	int activityId;
	std::string activityName;
	std::string displayText;  // Format: "ID: Name - Activity"
};

class NpcListWindow
{
public:
	NpcListWindow(ResourceManager* resourceManager, int screenWidth, int screenHeight);
	~NpcListWindow();

	void Update(bool schedulesEnabled);
	void Draw();

	void Show();
	void Hide();
	void Toggle();
	bool IsVisible() const;
	GhostWindow* GetWindow() const { return m_window; }

private:
	enum class SortMode
	{
		BY_ID,
		BY_NAME,
		BY_ACTIVITY
	};

	void BuildNPCList();  // Build full list of all NPCs
	void RebuildFilteredList();  // Rebuild list based on search filter
	void SortNPCList();  // Sort list based on current sort mode
	void HandleDoubleClick();  // Handle double-click on NPC in list
	std::string GetActivityName(int activityId);  // Convert activity ID to name
	void UpdateHeaderStatus(bool schedulesEnabled);  // Update header text/color based on schedule state

	GhostWindow* m_window;
	std::vector<NPCListEntry> m_allNPCs;  // All NPCs
	std::vector<NPCListEntry> m_filteredNPCs;  // Filtered by search
	std::string m_lastSearchText;  // Track search text changes
	SortMode m_sortMode;  // Current sort mode
	unsigned int m_lastScheduleTime;  // Track schedule changes
};

#endif
