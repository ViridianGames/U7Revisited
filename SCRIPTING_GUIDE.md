Bringing Ultima VII To Life: A Guide to Objects and Scripts

First things first – if you’re serious about this, please join my Discord!  It’ll make getting answers to questions and submitting your changes much easier!  https://discord.gg/9FWAMGcXgd

Here’s a quick overview of how the game world of Ultima VII works.

Everything in the world of Ultima VII is an “object”, even NPCs (though they do have some unique handling code and have unique IDs).  Every object has a “shape” and a “frame” that controls both how the object is drawn in the world, and has the associated script that runs when the object is double-clicked on.

Back when Ultima VII was under development, scripting systems like Lua and Python hadn’t been invented yet.  So the Ultima VII developers created a proprietary scripting system called “Usecode”.  But my goal is to make it much easier to change and add new things to Ultima VII and so I took all the original Usecode scripts, which were frankly one step up from assembly language, and converted them to Lua.  As you might guess, such a mass conversion was fraught with problems and I’ve no doubt lots of errors still exist in the scripts.  The scripts also need to be attached to their associated objects.  Which scripts go with which objects?  Good question!

That’s why I’m asking for help assigning the scripts to the correct objects and ensuring that they work correctly.

If you want to help, here's what you need to do:

*  Download this repository.  You DON'T have to be able to build it!  That's the magic of scripting!
*  Add the Ultima VII files to the Data/U7 folder as specified in the README.md file.
*  Make sure you can run the program by going into the Redist folder and running the executable for your platform (for Windows it would be "u7revisited.exe")

Now that the game is running, you can click on any object and then press F1 to edit that object.  This will open the Shape Editor.

In this example, I'm going to edit the script for these shutters so that they open.

![image](https://github.com/user-attachments/assets/a3a87836-8959-4a13-a320-fec1cb412456)


![image](https://github.com/user-attachments/assets/38a5967e-82c5-4dce-9dab-652a363fb861)

A lot of shapes have scripts that are named the same as the shape's ID number in hexadecimal.  The shape button at the top of the panel shows the shape's ID in both decimal and hex.

![image](https://github.com/user-attachments/assets/519162b1-8902-4e72-bfad-14f2cd438fa0)

But to make things easier, I also added a button that will automatically assign the appropriate script for that shape to the shape...if it exists.

![image](https://github.com/user-attachments/assets/63b51e3f-f30d-4cab-a65a-25714c314aed)

In this case, clicking "Set Script to ShapeID" automatically set the script to func_0122, the one for this shape.  Fortunately, this is the correct function!

But if we press F1 to go back to the game and double-click the shutter, nothing happens.  So we know there's a problem with the script.  So we press F1 to go back to the shape editor and click this button:

![image](https://github.com/user-attachments/assets/69fc7321-d146-4b1d-b721-773d171f85ae)

This will open the script in whatever text editor you have set to open Lua scripts.

Here's the script.

![image](https://github.com/user-attachments/assets/7e9cb29c-8023-4442-99cd-423a7f47f708)

Well, we can see the first problem - the function name is wrong.  It's supposed to be func_0122, not func_0122H.  This is a vestige of the auto-conversion process, so some functions may have this error.

Let's fix it:

![image](https://github.com/user-attachments/assets/8f52ad2b-aed7-4723-bca8-f99299410243)

Now we can switch back to the game and try again.  We don't have to shut the game down or rebuild anything, that's the magic of scripting!

![image](https://github.com/user-attachments/assets/d8ba4d38-c528-4d17-9b09-b328991ddadc)


Hmmm...the script still has an error.

![image](https://github.com/user-attachments/assets/a41ef10f-a7db-4dc2-93e4-dd3f78d40d86)

Okay, it's calling two functions, U7SetItemType and U7SetItemQuality.  They're the right functions but due to conversion issues, they aren't named correctly.

(How will you know what names to use?  There's a complete function listing at the bottom of this document!)

The correct replacement for U7SetItemType is set_object_shape and the correct replacement for U7SetItemQuality is set_object_quality.  So the script becomes:

We make those changes and save the file.  Again, we don't even have to shut down the game!

Double-click the shutter and the scripts now properly replace the "closed shutter" shape with the "open shutter" shape...

![image](https://github.com/user-attachments/assets/6314d6ae-0f22-4561-908c-53fe114a42b0)

And the shutter opens!

Note that double-clicking the open shutter does NOT close it, because the shutter is now a different shape, using a different script!  I leave fixing this script as an exercise for the reader.

Here is the list of Lua functions the scripts can call, and what they do.

These functions handle the conversation system:

switch_talk_to(npc_id, frame) - Presents further dialogue using the portrait of the NPC specified (different frames can express different emotions). Returns true or false if the NPC is not present.
hide_npc(npc_id) - Hides NPC face away from the conversation.
add_dialogue(string) - Adds the string to the dialogue to be presented when the conversation starts.
add_answer(str_or_array) - Adds an answer or set of answers to be presented at the end of the dialogue.
start_conversation() - Starts the conversation system with the added information.
remove_answer(str_or_array) - Removes an answer or set of answers from set, typically after it's been used.
save_answers() - Save current set of answers and clear working set.  Typically used when you want to ask a yes/no question.
restore_answers() - Restores current set of answers from saved set.
get_answer() - Get answer from player as a string.

These functions are used to manipulate the game world:

get_object_shape(objectId) - returns the "shape" value of the object
set_object_shape(objectId, shape) - changes the shape of given object to the new value
get_object_frame(objectId) - returns the "frame" value of the object
set_object_frame(objectId, frame) - Set object to given frame.
get_object_quality(objectId) - returns a "quality" value of the object
set_object_quality(objectId, ) - sets the "quality" value of the object

These functions manipulate NPCs and the party:

get_npc_property(objectId, property_id) - returns NPC's property value (9 is food level)
set_npc_property(objectId, property_id, value) - sets NPC's property value (9 is food level)
get_party_member(index) - Returns the ID of the party member at index.
get_party_members() - Returns an array of strings containing a list of NPC's in the party
get_player_name() - Returns name of the player as a string, or "Avatar" if not set
npc_in_party(npc_id) - Returns true if the given NPC is in the party

These are general utility functions:

ask_yes_no() - Pops up a modal dialogue prompting the user to choose "yes" or "no".
ask_number(min, max, step, default) - Pops up a modal dialogue that allows the user to choose a number by showing a slider with given parameters.
item_select_modal() - switches the engine to cross-cursor "use" mode. Returns an objectId of the object selected by user by single-click. Does not return until user the user single-clicks on something.
random(lo, hi) - Returns a random integer from lo to hi inclusively.
get_container_items(container_objectId, type, quality, ???) - returns an array of items in container.  Can filter by item type or quality.
play_music(objectId, songnum) - Play song.
display_sign(signnum, text) - Display sign (the gump numbered signnum) and display the text given ("text" is an array of strings).  Also for books, gravestones, etc.
get_time_hour() - Return game time (hours, 0-23).
get_time_minute() - Return game time (minutes, 0-59).
bark(objectId, str) - displays a string on the screen near the specified item
is_player_female() - returns 0 if male, 1 if female
start_end_game() - starts the endgame

Problems you're going to encounter:

*  Figuring out what script goes where.  Some objects have scripts that are the same number as the shape of the object (in hex) so that’s a good way to start.  Most of the conversation scripts will be easy since they all start with 04 and they mention the name of the character somewhere.  But it'll be harder to identify other scripts and it's possible we won't figure out where every script goes.  I've provided a list of each script number and a blurb about our best guess for what that script is for.

Click to open the script number list.

*  Misspelled functions (or incorrect functions).  Now that I've got an 85% or so complete list of the functions these scripts call, it's clear that a lot of these function names changed during the conversion.  I've done my best to go through with mass search-and-replace, but there will still be some issues.

*  Functions not fully implemented. Every function will at least put a string on the screen telling you the function has been called but many don't do anything beyond that.  Further implementations are coming!

*  Broken scripts.  I have verified that all the scripts at least load, but many don't run successfully.  If a script is broken, then running it will add a console string telling you what the file is and what line the error is on.

Thank you!  Please enjoy scripting Ultima VII!  Feel free to experiment with the system!  You can email me at anthony.salter@gmail.com with questions, but again, it's much faster if you join my Discord!
