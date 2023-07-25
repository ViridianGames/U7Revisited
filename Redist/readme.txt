This is a work-in-progress demo of my game Planitia.

Current version is .70.

NOTE: IF YOU GET A MESSAGE SAYING THAT D3D9_**.DLL IS MISSING THEN YOU NEED TO UPDATE YOUR DIRECTX.

Planitia is a real-time strategy game that allows you to both build an army and use god powers to crush your enemies.

In this demo you play Green.  In the main window you will see the game world, your general (the large guy with the green cape) and your village.


---------------------
BASIC CAMERA CONTROLS
---------------------

Planitia is meant to be played with one hand on the mouse and one hand on the WASD cluster on your keyboard.  (Sorry left-handers - I'll get controls in for you soon!)  You use the mouse to interact with the interface.  You can also move the camera by pushing the mouse to an edge of the screen, but it's much easier to move the camera with the WASD cluster.  You can rotate the camera using the Q and E keys.  You can also click on the minimap to jump the camera to that location.


--------------------
NEW TERRAIN CONTROLS
--------------------

If you've played previous versions of Planitia, you'll notice some changes to the icons on the right side.  The "Flatten Terrain" icon is gone.  Your cursor is now always in "Manipulate Terrain" mode as long as you have not clicked another spell to cast.  (You can tell what mode you're in by the color of the targeting circle; if it's white you are in Terrain mode, if not the circle will be the color of the spell you're casting.)

While in Terrain mode, left-clicking raises the terrain under the circle.  Right-clicking lowers the terrain under the circle.  Clicking with both buttons at once flattens the terrain under the circle, and flattens it to the height of the terrain cell you first clicked on.  Thus, if you want to flatten terrain to the height of your current villages, you should click and hold both mouse buttons while the cursor is in your village, then move to the terrain you wish to flatten.

----------
GOD POWERS
----------

On the right side you will see a GUI display with a minimap.  The blue bar below the minimap is your mana.  Below that are buttons for the god powers.  Only some of the god powers work now, inactive god powers have their buttons greyed out.  The working god powers are:

Flatten Land (looks like up/down arrows):  Costs 3 mana per second.

Allows you to raise or lower land to village height.  Click and hold in the world window on any terrain to affect it.  Flattening the land around your village will allow it to grow, and the more villagers you have the faster your mana will regenerate.  Villages only grow at certain populations, so your village may not grow immediately even if you've flattened the land properly.  Just be patient.  You may also need to use this tool to create land bridges so that you can attack your enemy.


Earthquake (looks like concentric circles):  Costs 25 mana.

Drops an earthquake wherever you click in the world window.  Be careful not to cast it on your own village.  The earthquake prevents enemy villages from growing and forces their gods to use more mana fixing what you've done.


Lightning Bolt (looks like...um...a lightning bolt):  Costs 10 mana.

Casts a lightning bolt wherever you click.  The lightning bolt damages units and throws them into the air.  You can even knock them off the game world this way.


All god powers have a shared 1.5 second cooldown.



--------------
MILITARY UNITS
--------------

You can left-click on your general to select him and move him by right-clicking on the terrain.  You cannot select your villagers.

If you click on the second tab on the GUI (looks like a red general) you will see the military buttons.  You will see buttons for archers, barbarians and warriors, along with a display of how many you currently have of each.

Clicking the archer, barbarian or warrior buttons converts a villager into a military unit of that type and adds it to your army.  Your army will always follow your general so you don't have to worry about controlling units individually.  You can attack enemy armies or villages simply by moving near them - once your units get within combat range they will attack automatically.

One thing to keep in mind is that once you convert a villager to a military unit it no longer gives you mana.


-------
OPTIONS
-------

If you click on the third tab on the GUI (which is currently blank) you'll see the exit button.  You can also exit the demo by pressing ESC.

If you wish to give me feedback on this demo, you can do so at anthony.salter@gmail.com, or comment on my blog at www.viridiangames.com.


Copyright 2006, 2007, 2008 by Anthony Salter.  All rights reserved.