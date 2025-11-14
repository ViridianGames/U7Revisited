--- Best guess: Handles bed interaction, triggering rest or dialogue if in combat or not a bedroll.
function utility_unknown_0768(objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    start_conversation()
    reset_flags() --- Guess: Resets flags
    set_flag(744, false)
    var_0001 = get_active_player() --- Guess: Gets active player
    if is_in_combat() then --- Guess: Checks combat state
        switch_talk_to(var_0001) --- Guess: Initiates dialogue
        var_0002 = get_player_name(var_0001) --- Guess: Gets player name
        if var_0001 == 356 then
            add_dialogue("\"This is no time to sleep! Look alive!\"")
        else
            add_dialogue(var_0002 .. " glares. \"This is no time to sleep! Look alive!\"")
        end
        if utility_unknown_0769(var_0000) then --- External call to check bedroll
            utility_event_0292(var_0000) --- External call to unknown function
        end
        hide_npc(var_0001) --- Guess: Hides NPC
    else
        var_0003 = get_object_frame(var_0000) --- Guess: Gets item frame
        var_0004 = get_object_shape(var_0000) --- Guess: Gets item type
        if var_0003 > 3 and not utility_unknown_0769(var_0000) then
            var_0005 = get_object_position(var_0000) --- Guess: Gets position data
            var_0006 = find_nearby(0, 2, var_0004, var_0000) --- Guess: Sets NPC location
            -- Guess: sloop checks item positions
            for i = 1, 5 do
                var_0009 = ({7, 8, 9, 6, 81})[i]
                if get_object_frame(var_0009) <= 2 then
                    var_000A = get_object_position(var_0009) --- Guess: Gets position data
                    if var_000A[1] == var_0005[1] and var_000A[2] == var_0005[2] and var_000A[3] + 1 == var_0005[3] then
                        var_0000 = var_0009
                    end
                end
            end
        end
        if not utility_unknown_0769(objectref) then --- External call to check bedroll
            var_000B = add_containerobject_s(356, {0, 30, 17492, 7715})
        end
        var_000C = remove_from_party(get_party_members(), 356) --- Guess: Removes from party
        set_schedule_type(14, 356) --- Guess: Sets object behavior
        party_rest(var_0000) --- Guess: Initiates party rest
    end
end