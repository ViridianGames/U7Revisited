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
---@param frame integer The frame/portrait to display
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
---@return integer x X coordinate
---@return integer y Y coordinate
---@return integer z Z coordinate
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
function get_npc_name_from_id(npc_id) end

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

---Gets an NPC's training level for a specific skill
---@param skill integer The skill type: 0=Strength, 1=Dexterity, 2=Intelligence, 4=Combat, 6=Magic
---@param npc_id integer The NPC to query (0 = Avatar/player)
---@return integer level The training level for that skill
function get_npc_training_level(skill, npc_id) end

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
-- UNKNOWN FUNCTIONS (Discovered via Exult Research)
-- ============================================================================
-- These functions exist in the original Ultima VII usecode and are called
-- by our scripts, but haven't been implemented in C++ yet.
-- Documentation is based on Exult project research.
-- ============================================================================

---[Exult 0x2C] Adds items to party members' inventories
---@param temporary boolean|integer Whether items should be marked as temporary (0/false = permanent)
---@param quality integer Quality value for items (or 359 for any/default)
---@param frame integer Frame number for items (or 359 for any/default)
---@param shape integer The item's shape ID (type of item)
---@param quantity integer Number of items to add
---@return boolean success True if items were successfully added to inventory
function unknown_002CH(temporary, quality, frame, shape, quantity) end

---[Exult 0x2B] Removes items from party members' inventories
---⚠ PARAMETERS NEED VERIFICATION - likely similar to add_party_items
---@param shape integer The item's shape ID (type of item)
---@param quantity integer Number of items to remove
---@return boolean success True if items were successfully removed
function unknown_002BH(shape, quantity) end

---[Exult 0x44] Gets the current weather state
---@return integer weather Weather type: 0=clear, 1=snow, 2=storm, 3=sparkle/anti-magic, 4=fog, 5=unknown, 6=clear no overcast
function unknown_0044H() end

---[Exult 0x45] Sets the weather
---⚠ PARAMETERS NEED VERIFICATION
---@param weather integer Weather type (see get_weather for values)
function unknown_0045H(weather) end

-- ============================================================================
-- UNKNOWN FUNCTIONS (Not Yet Researched)
-- ============================================================================
-- These functions are called in scripts but we haven't determined their
-- purpose yet. Add documentation here as you discover what they do!
-- ============================================================================

---❓ Unknown function - needs research
function unknown_0001H(...) end

---❓ Unknown function - needs research
function unknown_0002H(...) end

---❓ Unknown function - needs research
function unknown_0018H(...) end

---❓ Unknown function - needs research
function unknown_0024H(...) end

---❓ Unknown function - needs research
function unknown_0025H(...) end

---❓ Unknown function - needs research
function unknown_0026H(...) end

---❓ Unknown function - needs research
function unknown_002EH(...) end

---❓ Unknown function - needs research
function unknown_0035H(...) end

---❓ Unknown function - needs research
function unknown_0038H(...) end

---❓ Unknown function - needs research
function unknown_0039H(...) end

---❓ Unknown function - needs research
function unknown_0040H(...) end

---❓ Unknown function - needs research
function unknown_0058H(...) end

---❓ Unknown function - needs research
function unknown_005CH(...) end

---❓ Unknown function - needs research
function unknown_006FH(...) end

---❓ Unknown function - needs research
function unknown_0079H(...) end

---❓ Unknown function - needs research
function unknown_007EH(...) end

---❓ Unknown function - needs research
function unknown_007FH(...) end

---❓ Unknown function - needs research
function unknown_0081H(...) end

---❓ Unknown function - needs research
function unknown_0088H(...) end

---❓ Unknown function - needs research
function unknown_0089H(...) end

---❓ Unknown function - needs research
function unknown_008AH(...) end

---❓ Unknown function - needs research
function unknown_0628H(...) end

---❓ Unknown function - needs research
function unknown_0802H(...) end

---❓ Unknown function - needs research
function unknown_080DH(...) end

---❓ Unknown function - needs research
function unknown_0827H(...) end

---❓ Unknown function - needs research
function unknown_0830H(...) end

---❓ Unknown function - needs research
function unknown_0831H(...) end

---❓ Unknown function - needs research
function unknown_08B3H(...) end

---❓ Unknown function - needs research
function unknown_08FEH(...) end

---❓ Unknown function - needs research
function unknown_08FFH(...) end

-- Add more unknown functions here as you discover them in scripts!
-- Format: function unknown_XXXXH(...) end
-- Then research and document them when you figure out what they do.
