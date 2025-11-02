---@meta u7_engine_api
--[[
  U7Revisited Engine API Type Definitions

  This file provides type definitions and documentation for U7Revisited's C++ engine functions.
  It is used by the Lua Language Server (LuaLS) VSCode extension for IntelliSense/hover documentation.

  This file is NOT loaded by the game engine - it's purely for IDE support.
  The @meta annotation tells LuaLS this is a definition-only file.

  Documentation Status:
  - ✓ Documented: Function purpose and parameters are known
  - ⚠ Partially Known: Some information available, needs verification
  - ❓ Unknown: Function exists but purpose/parameters unclear

  Add documentation as you discover what functions do!
]]

-- ============================================================================
-- CONVERSATION SYSTEM
-- ============================================================================

---Switches the currently speaking NPC in a conversation
---@param npc_id integer The NPC ID to switch to
---@param frame? integer The frame/portrait to display (defaults to 0 if not provided)
function switch_talk_to(npc_id, frame) end

---Shows a second speaker in the conversation
---@param npc_id integer The NPC ID
---@param frame integer The frame/portrait to display
---@param dialogue string The dialogue text
function second_speaker(npc_id, frame, dialogue) end

---Hides an NPC from the conversation display
---@param npc_id integer The NPC ID to hide
function hide_npc(npc_id) end

---Adds dialogue text to the current conversation
---@param text string The dialogue text to display
function add_dialogue(text) end

---Adds one or more answer options to the conversation system
---@param answer string|table Either a single answer string, or a table of answer strings
---@usage add_answer("Single answer") or add_answer({"Answer 1", "Answer 2", "Answer 3"})
function add_answer(answer) end

---Starts a conversation (pushes conversation state)
function start_conversation() end

---Ends a conversation (pops conversation state, closes UI)
function end_conversation() end

---Immediately terminates the current script execution
---Useful for early exit conditions (e.g., if player doesn't have required item)
function abort() end

---Removes one or more answer options from the conversation system
---@param answer string|table Either a single answer string, or a table of answer strings to remove
---@usage remove_answer("Single answer") or remove_answer({"Answer 1", "Answer 2"})
function remove_answer(answer) end

---Saves the current answer list (for later restoration)
function save_answers() end

---Restores a previously saved answer list
function restore_answers() end

---Gets the player's selected answer
---@return string answer The selected answer text
function get_answer() end

---Clears all current answer options
function clear_answers() end

---Gets a purchase option selection from the player
---Displays a menu with purchase options and returns the selected index.
---NOTE: The C++ implementation reverses the order of answers (except the first element which is the prompt),
---so the returned index will be reversed relative to how options appear in the input table.
---@param options table A table where [1] is the prompt string and [2]...[n] are the option strings
---@return integer option The selected option index (0-based, where 0 typically means the last option/cancel)
function get_purchase_option(options) end

---Handles purchasing an object
---Checks if the player has enough gold and carrying capacity, then adds the objects to player inventory.
---@param shape integer The object shape ID to purchase
---@param frame integer The object frame number
---@param cost_per integer The cost per unit in gold
---@param amount integer The number of units to purchase
---@return integer result 0=aborted (amount was 0), 1=success, 2=too heavy, 3=can't afford
function purchase_object(shape, frame, cost_per, amount) end

---Checks if a conversation is currently running
---@return boolean running True if conversation is active
function is_conversation_running() end

-- ============================================================================
-- USER INPUT / DIALOGUE
-- ============================================================================

---Asks the player a yes/no question
---@param question? string Optional question to ask (defaults to empty string)
---@return boolean answer True if player selected "Yes", false if "No"
function ask_yes_no(question) end

---Presents answer choices without a question prompt
---All elements in the table are treated as answer choices
---@param answers string[] Array of answer strings
---@return string choice The selected answer text
---@usage ask_answer({"lead", "blackrock", "gold"})
function ask_answer(answers) end

---Presents multiple choice options to the player
---@param options string[] Array where first element is the question, remaining are choices
---@return string choice The selected choice text
function ask_multiple_choice(options) end

---Asks the player to input a number using a slider interface
---@param prompt string Optional dialog text to display (can be empty string or 0)
---@param min integer Minimum value for the slider
---@param max integer Maximum value for the slider
---@param default integer Initial/default value
---@return integer number The number selected by the player
---@usage ask_number(0, 1, 100, 50) -- slider from 1 to 100, starting at 50
function ask_number(prompt, min, max, default) end

---Opens a modal for selecting an object
---@return integer object_id The selected object ID
function object_select_modal() end

-- ============================================================================
-- GAME STATE & FLAGS
-- ============================================================================

---Gets a game flag value
---@param flag_id integer The flag ID to check
---@return boolean value The flag's current value
function get_flag(flag_id) end

---Sets a game flag value
---@param flag_id integer The flag ID to set
---@param value boolean The value to set
function set_flag(flag_id, value) end

-- ============================================================================
-- INVENTORY & OBJECTS
-- ============================================================================

---Generates a random number in the range [min, max] (inclusive)
---Note: Lua also has math.random() which works differently
---@param min integer Minimum value (inclusive)
---@param max integer Maximum value (inclusive)
---@return integer result Random number from min to max
function random(min, max) end

---Alias for random() - Generates a random number in the range [min, max] (inclusive)
---Arguments can be provided in either order (min, max) or (max, min)
---@param min integer Minimum value (inclusive)
---@param max integer Maximum value (inclusive)
---@return integer result Random number from min to max
function random2(min, max) end

---Finds objects near a reference object (Exult intrinsic 0x35)
---Searches for objects within a radius of the reference object
---@param objectref integer The reference object to search near
---@param shape integer Shape ID to find (0 for any shape)
---@param distance integer Search radius in tiles
---@param mask integer Filter mask (typically 0, may be used for quality/frame filtering)
---@return integer|nil objectref The found object reference, or nil if not found
---@usage find_nearby(objectref, 176, 4, 0) -- Find shape 176 within 4 tiles
function find_nearby(objectref, shape, distance, mask) end

---Checks if an object is in an NPC's inventory
---@param object_id integer The object to check for
---@param npc_id integer The NPC to check
---@return boolean found True if object is in NPC inventory
function is_object_in_npc_inventory(object_id, npc_id) end

---Checks if an object is in a container
---@param object_id integer The object to check for
---@param container_id integer The container to check
---@return boolean found True if object is in container
function is_object_in_container(object_id, container_id) end

---Checks if the party has an object of the given type
---@param shape integer The object shape/type to check for
---@return boolean found True if party has object of this type
function has_object_of_type(shape) end

---Adds an object to a container
---@param object_id integer The object to add
---@param container_id integer The container to add to
---@return boolean success True if object was added
function add_object_to_container(object_id, container_id) end

---Adds an object to an NPC's inventory
---@param object_id integer The object to add
---@param npc_id integer The NPC to add to
---@return boolean success True if object was added
function add_object_to_npc_inventory(object_id, npc_id) end

-- ============================================================================
-- OBJECT PROPERTIES
-- ============================================================================

---Gets an object's shape ID
---@param object_id integer The object to query
---@return integer shape The object's shape ID
function get_object_shape(object_id) end

---Sets an object's shape ID
---@param object_id integer The object to modify
---@param shape integer The new shape ID
function set_object_shape(object_id, shape) end

---Gets an object's frame number
---@param object_id integer The object to query
---@return integer frame The object's frame number
function get_object_frame(object_id) end

---Sets an object's frame number
---@param object_id integer The object to modify
---@param frame integer The new frame number
function set_object_frame(object_id, frame) end

---Gets an object's quality value
---@param object_id integer The object to query
---@return integer quality The object's quality value
function get_object_quality(object_id) end

---Sets an object's quality value
---@param object_id integer The object to modify
---@param quality integer The new quality value
function set_object_quality(object_id, quality) end

---Gets an object's position
---@param object_id integer The object to query
---@return table position Position array {x, y, z}
function get_object_position(object_id) end

---Sets an object's position
---@param object_id integer The object to modify
---@param x integer X coordinate
---@param y integer Y coordinate
---@param z integer Z coordinate
function set_object_position(object_id, x, y, z) end

---Sets an object's visibility
---@param object_id integer The object to modify
---@param visible boolean Whether the object should be visible
function set_object_visibility(object_id, visible) end

---Spawns a new object
---@param shape integer The shape ID of the object to spawn
---@param x integer X coordinate
---@param y integer Y coordinate
---@param z integer Z coordinate
---@return integer object_id The ID of the spawned object
function spawn_object(shape, x, y, z) end

---Destroys an object
---@param object_id integer The object to destroy
function destroy_object(object_id) end

-- ============================================================================
-- NPC PROPERTIES
-- ============================================================================

---Gets an NPC property value
---@param npc_id integer The NPC to query
---@param property string The property name
---@return any value The property value
function get_npc_property(npc_id, property) end

---Sets an NPC property value
---@param npc_id integer The NPC to modify
---@param property string The property name
---@param value any The new value
function set_npc_property(npc_id, property, value) end

---Sets an NPC's position
---@param npc_id integer The NPC to move
---@param x integer X coordinate
---@param y integer Y coordinate
---@param z integer Z coordinate
function set_npc_pos(npc_id, x, y, z) end

---Sets an NPC's destination (pathfinding)
---@param npc_id integer The NPC to command
---@param x integer Target X coordinate
---@param y integer Target Y coordinate
---@param z integer Target Z coordinate
function set_npc_dest(npc_id, x, y, z) end

---Sets an NPC's animation frame
---@param npc_id integer The NPC to modify
---@param frame integer The animation frame
function set_npc_frame(npc_id, frame) end

---Sets an NPC's visibility
---@param npc_id integer The NPC to modify
---@param visible boolean Whether the NPC should be visible
function set_npc_visibility(npc_id, visible) end

---Starts an NPC's schedule
---@param npc_id integer The NPC to start schedule for
function start_npc_schedule(npc_id) end

---Stops an NPC's schedule
---@param npc_id integer The NPC to stop schedule for
function stop_npc_schedule(npc_id) end

-- ============================================================================
-- PARTY MANAGEMENT
-- ============================================================================

---Gets a party member by index
---@param index integer The party member index (-1 for Avatar, -2 for companion slot 1, etc.)
---@return integer npc_id The NPC ID of the party member
function get_party_member(index) end

---Gets all party member names
---@return string[] names Array of party member names
function get_party_members() end

---Checks if an NPC ID is in the party
---@param npc_id integer The NPC ID to check
---@return boolean in_party True if NPC is in party
function npc_id_in_party(npc_id) end

---Checks if an NPC name is in the party
---@param name string The NPC name to check
---@return boolean in_party True if NPC is in party
function npc_name_in_party(name) end

---Adds an NPC to the party
---@param npc_id integer The NPC to add
---@return boolean success True if NPC was added
function add_to_party(npc_id) end

---Removes an NPC from the party
---@param npc_id integer The NPC to remove
---@return boolean success True if NPC was removed
function remove_from_party(npc_id) end

---Gets an NPC's name from their ID
---@param npc_id integer The NPC ID
---@return string name The NPC's name
function get_npc_name(npc_id) end

---Gets an NPC's ID from their name
---@param name string The NPC name
---@return integer npc_id The NPC's ID
function get_npc_id_from_name(name) end

---Presents a list of party members for selection
---@return integer npc_id The selected party member's ID
function select_party_member_by_name() end

---Gets the party's total gold
---@return integer gold The amount of gold
function get_party_gold() end

---Removes gold from the party
---@param amount integer The amount of gold to remove
---@return boolean success True if gold was removed (party had enough)
function remove_party_gold(amount) end

---Gets an NPC's training points
---@param npc_id integer The NPC to query
---@return integer points The training points
function get_npc_training_points(npc_id) end

---Gets a training level for a specific skill
---@param npc_id integer The NPC to query (0 = Avatar/player)
---@param skill integer The skill type: 0=Strength, 1=Dexterity, 2=Intelligence, 4=Combat, 6=Magic
---@return integer level The training level for that skill
function get_training_level(npc_id, skill) end

---Sets a training level for a specific skill
---@param npc_id integer The NPC to modify (0 = Avatar/player)
---@param skill integer The skill type: 0=Strength, 1=Dexterity, 2=Intelligence, 4=Combat, 6=Magic
---@param value integer The new training level value
function set_training_level(npc_id, skill, value) end

---Increases an NPC's combat level
---@param npc_id integer The NPC to level up
function increase_npc_combat_level(npc_id) end

-- ============================================================================
-- PLAYER / AVATAR
-- ============================================================================

---Gets the player's name
---@return string name The player's name
function get_player_name() end

---Checks if the player/Avatar is female
---@return boolean is_female True if player is female
function is_player_female() end

---Gets the appropriate "Lord" or "Lady" title for the player
---@return string title "Lord" or "Lady" based on player gender
function get_lord_or_lady() end

---Gets the appropriate "him" or "her" pronoun for the player
---@return string pronoun "him" or "her" based on player gender
function get_him_or_her() end

---Checks if the player is wearing the Fellowship medallion
---@return boolean wearing True if wearing the medallion
function is_player_wearing_fellowship_medallion() end

-- ============================================================================
-- TIME & WORLD
-- ============================================================================

---Gets the current game hour (0-23)
---@return integer hour The current hour
function get_time_hour() end

---Gets the current game minute (0-59)
---@return integer minute The current minute
function get_time_minute() end

---Gets the current schedule time period
---@return integer schedule The schedule period ID
function get_schedule_time() end

---Gets the current schedule for an NPC
---@param npc_id integer The NPC to query
---@return integer schedule The schedule ID
function get_schedule(npc_id) end

---Plays a music track
---⚠ Currently a stub (not fully implemented)
---@param track integer The music track number to play
---@param loop integer Loop behavior (0=play once, 255=loop forever, other values TBD)
function play_music(track, loop) end

-- ============================================================================
-- UI / DISPLAY
-- ============================================================================

---Opens a book/scroll/sign/plaque interface with text
---Note: A "book" encompasses scripts, plaques, signs, and gravestones as well
---@param book_type integer The type of book/display (determines visual style)
---@param text_lines string[] Array of text lines to display in the book
---@usage open_book(1, {"Page 1 text", "Page 2 text"})
function open_book(book_type, text_lines) end

---Displays a bark (short message above character/object)
---@param object_id integer The object/NPC to display the bark from
---@param text string The bark text
function bark(object_id, text) end

---Displays a bark from a specific NPC
---@param npc_id integer The NPC to bark from
---@param text string The bark text
function bark_npc(npc_id, text) end

---Blocks player input
function block_input() end

---Resumes player input (unblocks)
function resume_input() end

---Sets the game pause state
---@param paused boolean Whether to pause the game
function set_pause(paused) end

---Pauses script execution for the specified duration
---@param seconds number Duration to wait in seconds
function wait(seconds) end

---Fades the screen out
---@param duration number Fade duration in seconds
function fade_out(duration) end

---Fades the screen in
---@param duration number Fade duration in seconds
function fade_in(duration) end

---Shows UI elements
function show_ui_elements() end

---Hides UI elements
function hide_ui_elements() end

-- ============================================================================
-- CAMERA
-- ============================================================================

---Sets the camera angle
---@param angle number The camera angle in degrees
function set_camera_angle(angle) end

---Instantly jumps the camera to an angle (no interpolation)
---@param angle number The camera angle in degrees
function jump_camera_angle(angle) end

-- ============================================================================
-- ANIMATION
-- ============================================================================

---Sets a model's animation frame
---@param model_id integer The model to modify
---@param frame integer The animation frame
function set_model_animation_frame(model_id, frame) end

-- ============================================================================
-- UTILITY
-- ============================================================================

---Checks if an integer is in an array
---@param value integer The value to search for
---@param array integer[] The array to search in
---@return boolean found True if value is in array
function is_int_in_array(value, array) end

---Checks if a string is in an array
---@param value string The value to search for
---@param array string[] The array to search in
---@return boolean found True if value is in array
function is_string_in_array(value, array) end

---Debug print (outputs to console/log)
---@param message string The message to print
function debug_print(message) end

-- ============================================================================
-- EXULT INTRINSICS - SEARCH & FIND FUNCTIONS
-- ============================================================================

---[Exult 0x000E] Finds the nearest object of a given shape within distance
---@param object_id integer Reference object to search from
---@param shape integer Shape ID to search for
---@param distance integer Maximum search radius
---@return integer|nil object_id The nearest matching object, or nil if not found
function find_nearest(object_id, shape, distance) end

---[Exult 0x0029] Finds an object by shape and frame
---@param shape integer Shape ID to find
---@param frame integer Frame number to match
---@param quality integer Quality value to match
---@return integer|nil object_id The found object, or nil if not found
function find_object(shape, frame, quality) end

---[Exult 0x0019] Gets the distance between two objects
---@param obj1 integer First object ID
---@param obj2 integer Second object ID
---@return integer distance Distance in tiles
function get_distance(obj1, obj2) end

---[Exult 0x001A] Finds the direction from one object to another
---@param from_obj integer Source object ID
---@param to_obj integer Target object ID
---@return integer direction Direction (0-7, where 0=North, clockwise)
function find_direction(from_obj, to_obj) end

---[Exult 0x0087] Gets the direction from an object
---@param object_id integer The object ID
---@return integer direction Current facing direction (0-7)
function direction_from(object_id) end

---[Exult 0x0028] Counts objects of a given type
---@param shape integer Shape ID to count
---@param quality integer Quality value filter (-359 for any)
---@param frame integer Frame number filter (-359 for any)
---@return integer count Number of matching objects
function count_objects(shape, quality, frame) end

---[Exult 0x0030] Finds nearby Avatar (party member check)
---@param object_id integer Reference object
---@param distance integer Search radius
---@return integer|nil object_id Nearby party member, or nil
function find_nearby_avatar(object_id, distance) end

-- ============================================================================
-- EXULT INTRINSICS - INVENTORY & ITEMS
-- ============================================================================

---[Exult 0x0016] Gets the quantity of an item
---@param object_id integer The item to query
---@return integer quantity The item's quantity/stack size
function get_item_quantity(object_id) end

---[Exult 0x0017] Sets the quantity of an item
---@param object_id integer The item to modify
---@param quantity integer New quantity value
function set_item_quantity(object_id, quantity) end

---[Exult 0x002B] Removes items from party members' inventories
---@param shape integer The item's shape ID (type of item)
---@param quantity integer Number of items to remove
---@param quality integer Quality filter (-359 for any)
---@param frame integer Frame filter (-359 for any)
---@return boolean success True if items were successfully removed
function remove_party_items(shape, quantity, quality, frame) end

---[Exult 0x002C] Adds items to party members' inventories
---@param shape integer The item's shape ID (type of item)
---@param quantity integer Number of items to add
---@param quality integer Quality value for items
---@param frame integer Frame number for items
---@param temporary boolean|integer Whether items should be marked as temporary
---@return boolean success True if items were successfully added to inventory
function add_party_items(shape, quantity, quality, frame, temporary) end

---[Exult 0x0025] Sets the "last created" object reference
---@param object_id integer Object to mark as last created
function set_last_created(object_id) end

---[Exult 0x0026] Updates the position of the last created object
---@param position table Position array {x, y, z}
---@return boolean success True if successful, false if no object exists
function update_last_created(position) end

---[Exult 0x0036] Gives the last created object to an NPC
---@param npc_id integer NPC to give object to
function give_last_created(npc_id) end

---[Exult 0x006F] Removes/destroys an item
---@param object_id integer The item to remove
function remove_item(object_id) end

---[Exult 0x006E] Gets the container of an object
---@param object_id integer The object to query
---@return integer|nil container_id The container holding this object, or nil
function get_container(object_id) end

---[Exult 0x0088] Gets an item flag value
---@param object_id integer The object to query
---@param flag_id integer Flag ID to check
---@return integer value The flag value (0 or 1)
function get_item_flag(object_id, flag_id) end

---[Exult 0x0089] Sets an item flag
---@param object_id integer The object to modify
---@param flag_id integer Flag ID to set
function set_item_flag(object_id, flag_id) end

---[Exult 0x008A] Clears an item flag
---@param object_id integer The object to modify
---@param flag_id integer Flag ID to clear
function clear_item_flag(object_id, flag_id) end

---[Exult 0x0042] Gets object lift/elevation
---@param object_id integer The object to query
---@return integer lift The object's lift value
function get_lift(object_id) end

---[Exult 0x0043] Sets object lift/elevation
---@param object_id integer The object to modify
---@param lift integer New lift value
function set_lift(object_id, lift) end

-- ============================================================================
-- EXULT INTRINSICS - COMBAT
-- ============================================================================

---[Exult 0x0041] Sets an NPC to attack mode
---@param npc_id integer NPC to set attacking
---@param target_id integer Target to attack
function set_to_attack(npc_id, target_id) end

---[Exult 0x004B] Sets NPC combat mode
---@param npc_id integer NPC to modify
---@param mode integer Combat mode value
function set_attack_mode(npc_id, mode) end

---[Exult 0x004C] Sets NPC oppressor (who they're mad at)
---@param npc_id integer NPC to modify
---@param oppressor_id integer Who is oppressing them
function set_oppressor(npc_id, oppressor_id) end

---[Exult 0x0054] Makes an NPC attack an object
---@param npc_id integer Attacker
---@param target_id integer Target
function attack_object(npc_id, target_id) end

---[Exult 0x0076] Fires a projectile
---@param shape integer Projectile shape ID
---@param from_obj integer Source object
---@param to_obj integer Target object
---@param speed integer Projectile speed
function fire_projectile(shape, from_obj, to_obj, speed) end

---[Exult 0x007A] Summons guards to attack
---@param target_id integer Who guards should attack
function call_guards(target_id) end

---[Exult 0x008E] Checks if in combat mode
---@return boolean in_combat True if combat is active
function in_combat() end

---[Exult 0x0061] Applies damage to an NPC
---@param npc_id integer NPC to damage
---@param amount integer Damage amount
function apply_damage(npc_id, amount) end

---[Exult 0x0071] Reduces NPC health
---@param npc_id integer NPC to damage
---@param amount integer Amount to reduce
function reduce_health(npc_id, amount) end

-- ============================================================================
-- EXULT INTRINSICS - NPC MANAGEMENT
-- ============================================================================

---[Exult 0x0031] Checks if object is an NPC
---@param object_id integer Object to check
---@return boolean is_npc True if object is an NPC
function is_npc(object_id) end

---[Exult 0x0037] Checks if NPC is dead
---@param npc_id integer NPC to check
---@return boolean is_dead True if NPC is dead
function is_dead(npc_id) end

---[Exult 0x003A] Gets NPC number/ID
---@param object_id integer Object to query
---@return integer npc_num The NPC number (-1 if not an NPC)
function get_npc_number(object_id) end

---[Exult 0x003C] Gets NPC alignment
---@param npc_id integer NPC to query
---@return integer alignment Alignment value
function get_alignment(npc_id) end

---[Exult 0x003D] Sets NPC alignment
---@param npc_id integer NPC to modify
---@param alignment integer New alignment value
function set_alignment(npc_id, alignment) end

---[Exult 0x0049] Kills an NPC
---@param npc_id integer NPC to kill
function kill_npc(npc_id) end

---[Exult 0x0051] Resurrects an NPC
---@param npc_id integer NPC to resurrect
function resurrect(npc_id) end

---[Exult 0x0047] Summons a creature/NPC
---@param shape integer Shape to summon
---@param x integer X position
---@param y integer Y position
---@param z integer Z position
---@return integer object_id The summoned object
function summon(shape, x, y, z) end

---[Exult 0x0046] Makes NPC sit down in a chair
---@param npc_id integer NPC to sit
---@param chair_id integer Chair object to sit in
function sit_down(npc_id, chair_id) end

---[Exult 0x001D] Sets NPC schedule type
---@param npc_id integer NPC to modify
---@param schedule integer Schedule type
function set_schedule_type(npc_id, schedule) end

---[Exult 0x0022] Gets Avatar object reference
---@return integer object_id The Avatar's object ID
function get_avatar_ref() end

---[Exult 0x008D] Gets party list (alternate version)
---@return integer[] party_members Array of party member IDs
function get_party_list2() end

---[Exult 0x0093] Gets dead party members
---@return integer[] dead_members Array of dead party member IDs
function get_dead_party() end

-- ============================================================================
-- EXULT INTRINSICS - USECODE & SCRIPTING
-- ============================================================================

---[Exult 0x0001] Executes usecode function with array of params
---@param usecode_num integer Usecode function number
---@param event_type integer Event type
---@param params table Array of parameters
function execute_usecode_array(usecode_num, event_type, params) end

---[Exult 0x0002] Delayed execution of usecode function
---@param delay integer Delay in ticks
---@param usecode_num integer Usecode function number
---@param event_type integer Event type
---@param params table Array of parameters
function delayed_execute_usecode_array(delay, usecode_num, event_type, params) end

---[Exult 0x0079] Checks if currently in usecode
---@return boolean in_usecode True if usecode is running
function in_usecode() end

---[Exult 0x007D] Runs usecode when path complete
---@param npc_id integer NPC to wait for
---@param usecode_num integer Usecode to run
function path_run_usecode(npc_id, usecode_num) end

---[Exult 0x005C] Halts scheduled activity
---@param npc_id integer NPC to halt
function halt_scheduled(npc_id) end

---[Exult 0x008B] Sets path failure handler
---@param usecode_num integer Usecode to call on path failure
function set_path_failure(usecode_num) end

-- ============================================================================
-- EXULT INTRINSICS - WORLD & ENVIRONMENT
-- ============================================================================

---[Exult 0x0044] Gets the current weather state
---@return integer weather Weather type: 0=clear, 1=snow, 2=storm, 3=sparkle/anti-magic, 4=fog, 5=unknown, 6=clear no overcast
function get_weather() end

---[Exult 0x0045] Sets the weather
---@param weather integer Weather type (see get_weather for values)
function set_weather(weather) end

---[Exult 0x0090] Checks if location is water
---@param x integer X coordinate
---@param y integer Y coordinate
---@return boolean is_water True if location is water
function is_water(x, y) end

-- ============================================================================
-- EXULT INTRINSICS - AUDIO
-- ============================================================================

---[Exult 0x000F] Plays a sound effect
---@param sound_id integer Sound effect ID
function play_sound_effect(sound_id) end

---[Exult 0x0069] Gets speech track number
---@param npc_id integer NPC ID
---@return integer track_num Speech track number
function get_speech_track(npc_id) end

-- ============================================================================
-- EXULT INTRINSICS - VISUAL EFFECTS
-- ============================================================================

---[Exult 0x0053] Creates a sprite effect
---@param effect_id integer Effect type
---@param x integer X position
---@param y integer Y position
---@param z integer Z position
function sprite_effect(effect_id, x, y, z) end

---[Exult 0x007B] Creates sprite effect on object
---@param effect_id integer Effect type
---@param object_id integer Object to attach effect to
function obj_sprite_effect(effect_id, object_id) end

---[Exult 0x008C] Fades palette
---@param fade_type integer Fade type/color
---@param ticks integer Duration in ticks
function fade_palette(fade_type, ticks) end

---[Exult 0x0092] Sets camera to follow object
---@param object_id integer Object to follow
function set_camera(object_id) end

---[Exult 0x0091] Resets conversation face position
function reset_conv_face() end

-- ============================================================================
-- EXULT INTRINSICS - COLLISION & PATHFINDING
-- ============================================================================

---[Exult 0x0085] Checks if tile is not blocked
---@param x integer X coordinate
---@param y integer Y coordinate
---@param z integer Z coordinate
---@return boolean not_blocked True if tile is passable
function is_not_blocked(x, y, z) end

---[Exult 0x0072] Checks if item is readied/equipped
---@param object_id integer Item to check
---@param npc_id integer NPC to check on
---@return boolean is_readied True if item is equipped
function is_readied(object_id, npc_id) end

-- ============================================================================
-- EXULT INTRINSICS - RANDOM & GAME MECHANICS
-- ============================================================================

---[Exult 0x0010] Rolls dice
---@param num_dice integer Number of dice to roll
---@param num_sides integer Number of sides per die
---@return integer result Sum of dice rolls
function die_roll(num_dice, num_sides) end

---[Exult 0x004A] Rolls to win (skill check)
---@param odds integer Odds of success (percentage)
---@return boolean success True if roll succeeded
function roll_to_win(odds) end

-- ============================================================================
-- EXULT INTRINSICS - UI & GUMPS
-- ============================================================================

---[Exult 0x007E] Closes all gumps/windows
function close_gumps() end

---[Exult 0x0080] Closes specific gump
---@param object_id integer Object whose gump to close
function close_gump(object_id) end

---[Exult 0x0081] Checks if in gump mode
---@return boolean in_gump True if gump is open
function in_gump_mode() end

---[Exult 0x0055] Opens book mode
---@param book_id integer Book to open
function book_mode(book_id) end

---[Exult 0x0033] Simulates clicking on item
---@param object_id integer Item to click
function click_on_item(object_id) end

---[Exult 0x000C] Gets numeric input from user
---@param min integer Minimum value
---@param max integer Maximum value
---@param default integer Default value
---@return integer value User's input
function input_numeric_value(min, max, default) end

---[Exult 0x0009] Clears conversation answers
function clear_answers() end

-- ============================================================================
-- EXULT INTRINSICS - SPECIAL EFFECTS
-- ============================================================================

---[Exult 0x0059] Creates earthquake effect
---@param strength integer Earthquake intensity
function earthquake(strength) end

---[Exult 0x005B] Armageddon spell effect
function armageddon() end

---[Exult 0x0050] Wizard eye spell
---@param x integer X position to view
---@param y integer Y position to view
function wizard_eye(x, y) end

---[Exult 0x0095] Telekinesis effect
---@param object_id integer Object to move
function telekenesis(object_id) end

---[Exult 0x0057] Creates light effect
---@param x integer X position
---@param y integer Y position
---@param z integer Z position
function cause_light(x, y, z) end

---[Exult 0x0048] Displays map
function display_map() end

---[Exult 0x004F] Displays area map
---@param x integer X position
---@param y integer Y position
function display_area(x, y) end

---[Exult 0x0094] Views a tile
---@param tile_id integer Tile to view
function view_tile(tile_id) end

---[Exult 0x006A] Flashes mouse cursor (currently not implemented)
---@param flash_type integer The type of flash effect
function flash_mouse(flash_type) end

---[Exult 0x0056] Stops time (Time Lord spell)
function stop_time() end

-- ============================================================================
-- EXULT INTRINSICS - GAME CONTROL
-- ============================================================================

---[Exult 0x0073] Restarts the game
function restart_game() end

---[Exult 0x0075] Runs endgame sequence
function run_endgame() end

-- ============================================================================
-- EXULT INTRINSICS - MISCELLANEOUS
-- ============================================================================

---[Exult 0x006B] Gets item frame with rotation
---@param object_id integer Object to query
---@return integer frame Frame with rotation bits
function get_item_frame_rot(object_id) end

---[Exult 0x006C] Sets item frame with rotation
---@param object_id integer Object to modify
---@param frame integer Frame with rotation bits
function set_item_frame_rot(object_id, frame) end

---[Exult 0x0058] Gets barge object is on
---@param object_id integer Object to check
---@return integer|nil barge_id Barge object ID or nil
function get_barge(object_id) end

---[Exult 0x0065] Gets timer value
---@param timer_id integer Timer to query
---@return integer value Timer value
function get_timer(timer_id) end

---[Exult 0x0066] Sets timer value
---@param timer_id integer Timer to set
---@param value integer New timer value
function set_timer(timer_id, value) end

---[Exult 0x0062] Checks if PC is inside
---@return boolean inside True if player is indoors
function is_pc_inside() end

---[Exult 0x0063] Sets orrery state
---@param state integer Orrery state
function set_orrery(state) end

---[Exult 0x005F] Marks virtue stone
---@param stone_id integer Stone to mark
function mark_virtue_stone(stone_id) end

---[Exult 0x0060] Recalls to virtue stone
---@param stone_id integer Stone to recall to
function recall_virtue_stone(stone_id) end

---[Exult 0x0083] Sets time-based palette
---@param palette_id integer Palette to use
function set_time_palette(palette_id) end
