# furroy's NPC Pathfinding Notes  10/23/2025

Only implemented in Sandbox mode.  To enable in Trinsic Demo, each NPC honors its m_followingSchedule, so when an NPC is controlled by a cutscene it just needs to set this flag appropriately.

Use red/green square in upper left corner of the screen to toggle schedules on/off (m_npcSchedulesEnabled)  Loops through all NPCs to toggle their m_followingSchedule.

Added F10 to toggle pathfinding debug tiles. Green is walkable, red is not.

Added F7 to toggle being able to move static objects to help debug pathing.

NPCs will open doors standing in their way by using door->Interact()

Made some fixes so both sides of double doors open properly. These might not be the "correct" fixes, but they do open/close properly. They do not open in tandem and perhaps they should?

Pressing right arrow -> bumps time to next whole hour to help test schedule changes.

Added FPS display in lower right corner to aid debugging.

When lua debug is on, clicking NPCs will output their schedule (sorted by time) in the debug console. If currently pathfinding, it will show their waypoints.

# KNOWN ISSUES

Some NPCs start out on unwalkable tiles, so they never move.

Some NPCs have crazy longs paths and the astar gives up before a path is found.

Not sure how "double doors" should work, do they always open/close in tandem?
