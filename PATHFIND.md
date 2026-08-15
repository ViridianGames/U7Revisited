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

Updated tile path costing values in Redist\Data\terrain_walkable.csv Note: these must be greater than 0!

Updated red/green tiles to show an array of colors to more easily see path costs

Updated doors in shapedata.dat and a couple lua scripts so they open/close when clicked.

When F10 is active, clicking an NPC that has active astar waypoints will plot them in blue tiles

# KNOWN ISSUES

A couple NPCs have crazy longs paths and the astar gives up before a path is found.

# 2026-08-11 pathfinding climb / stacking work

- Standable tops: any solid with TFA height (crates, boxes, chests…) plus floors/stairs allowlist.
  Surface Y = obj.y + TFA height (roofs/flats: plane at m_Pos.y). Step limit MAX_CLIMBABLE_HEIGHT (1.0).
  Height-2 props (barrels, tables) need intermediate steps.
- Tile overlap for pathfinding uses TFA SE-origin footprints (not iso draw bboxes).
- A* walkable cache is height-aware; neighbors emit same/up/down surfaces within one step.
- Diagonal moves require both orthogonal corners free (no corner-cutting).
- maxNodesToExplore raised 500 → 4000; hierarchical threshold 240 → 48.
- Path smoothing removes redundant waypoints (Bresenham walkability).
- Right-click pathfind targets tile centers + standable surface Y (including crate tops).

# 2026-08-13 robustness / NPC slide

- All units wall-slide in UpdateMovement (prefer slide that still approaches dest).
- Micro-step slide: if full deltav blocked, try 50% then 25% step with same axis slide.
- Discrete climb snap on path-follow when dest Y is within one step and XZ is close.
- Stuck recovery: skip next waypoint after ~10 blocked frames; repath to final goal
  after ~28; give up after ~60.
- Near-dest snap when blocked within 0.55 tiles XZ.
- Manual TryMove clears path waypoints so click-path cannot fight steer.

# 2026-08-13 A* speed

- CheckTileWalkable: single GetOverlappingObjects (heights derived, no double scan).
- GetWalkableSurfaceHeightsFromObjects for reuse.
- ValidateMove: removed unused overlapping-objects fetch.
- A* move-cost cache per (x,z); node pool reuses open keys / skips closed.
- Hierarchical intermediates carry start.y (not forced ground).

# 2026-08-15 stairs / curtains

- Climb rewrite removed hard skips for curtains (657/678) and treated stairs as
  solid volumes → stair tiles blocked at ground, curtains impassable.
- Pass-through objects (curtains): never block, not stand surfaces.
- Non-blocking walk surfaces (floors/stairs/rugs/bridges; not crates): never
  block body volume; still contribute stand heights for climbs.

# 2026-08-15 1-tile climb steps on tall solids

- Tall standables (fence height 2, stair-on-fence, etc.) emit intermediate
  surface heights every MAX_CLIMBABLE_HEIGHT (1.0) between base and top.
- CanStandOnSurface / ValidateMove allow feet anywhere in [base, surface]
  of a standable object (intermediate rungs), not only the exact top.
- Manual walk prefers highest reachable surface within one step.

# 2026-08-15 roof walk over walls

- ValidateMove used full iso draw AABBs for collision; wall art boxes extend
  through upper floors and blocked roof movement.
- Collision Y is clamped to TFA logical [base, surface]; objects with top at
  or below feet never block (roof over wall).

# SANDBOX TEST (chimney stairs)

1. F10 path debug; F7 if needed to move statics.
2. Place height-1 crates as steps (offset each level).
3. Double-right-click ground → crate → higher crate / roof ledge.
4. 1-tile hallways should path orthogonally without wall clips.
