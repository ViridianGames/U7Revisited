# Ultima VII: Revisited Roadmap

*last revised January 12, 2024*

I've gotten a lot of questions about this, so I wanted to go ahead and explain the roadmap I've currently got for Ultima VII: Revisited.

The goal is to make the game fully playable in a 3D engine, without harming what makes the game an Ultima.

So, here's the plan:

## 0.1.0 - THE STATIC WORLD -
At this release point, every object in the game (and everything in the game is considered an object, even NPCs and monsters) will be loaded from the
original data files, placed at its initial location, and drawn in the 3D world in the best manner I can manage (not being an artist).  This release will
effectively be a 3D map viewer of the starting state of Ultima VII: The Black Gate.

## 0.2.0 - THE INTERACTIVE WORLD -
At this release point, every object that has interactivity will be interactive.  Lamps can be lit, containers can be opened and their contents viewed
(though not changed), babies can be diapered, musical instruments can be played, etc.  Double-clicking an NPC will initiate its dialogue tree and/or open its inventory.

## 0.3.0 - THE LIVING WORLD -
At this release point, all scripts on objects will run.  This will enable NPC schedules, monsters attacking, animations on objects, eggs "hatching",
etc.  At this point, the game effectively be a 3D diorama of the Britannia of Ultima VII.  NPCs and monsters will no longer walk/move in tiles, but
smoothly animate from one place to another.  The 3D engine will choose which angle to show each NPC/monster from based on how the camera is rotated vs
where the NPC/monster is facing.

## 0.4.0 - THE AVATAR ARRIVES - 
At this release point, the game will no longer allow free 3D movement through the world (unless you use a cheat).  The Avatar player character will be
implemented.  Scripts that require the Avatar will now work.  The player will be able to move the Avatar around, open their inventory, add/remove objects
from containers (including themselves), equip weapons and armor, and cast spells.  The Avatar will also be able to recruit companions, who also will be
able to do all these things.  At this point, rudimentary combat should work.  The game should be mostly playable but doubtless will not be completable
due to...

## 0.5.0 - SPECIAL CASES GALORE - 
Many things that occur during the course of the game don't follow the normal rules of the engine. These include things like the vision of Alagner's
murder, the orrery, the Soul Cage in Skara Brae, the Sphere, Cube and Tetrahedron, etc.  Cleaning all these up will be necessary, but the result will
be...

## 0.6.0 - THE GUARDIAN DEFEATED -
With this release, the game should be completable.  It will doubtless have tons of bugs and issues, but the player should be able to pursue the plotline
of the game logically from the investigation of Christopher's death all the way to the final fight with Batlin, Elizabeth, Abraham, Forskis and Hook.

## 0.7.0 - CHASING BATLIN -
While implemeting this engine for The Black Gate will make a lot of people happy, Ultima VII has two parts, and the engine won't be complete until it also supports Serpent Isle.  This will require a lot of replacement sprites, UI elements and scripts but probably won't require changing too much in the base engine.  I hope.

## 0.8.0 - SOWING THE SEEDS -
I'll be ensuring that the Windows and Linux builds are updated during the entire process, but with this milestone I'll be ensuring the game can be built
and played on as many different systems as possible.  I want it to run on every system that can run DOSBox or Exult.  There will doubtless also be bugs
and other issues that need to be continually fixed.

Have fun, and Rule Britannia.
