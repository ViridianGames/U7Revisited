--- Best guess: Handles a wand's interaction with specific items (e.g., Black Gate, ID 305) or NPCs (e.g., Batlin, ID 403), triggering effects or dialogue.
function object_unknown_0771(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 4 then
        var_0000 = objectref
    else
        var_0000 = object_select_modal()
    end
    if var_0000 then
        close_gumps()
        var_0001 = get_object_shape(var_0000)
        if var_0001 == 914 then
            var_0002 = utility_unknown_1069(var_0000)
            var_0003 = execute_usecode_array({7981, 5, 7719}, var_0000)
            var_0003 = set_to_attack(704, var_0000, -356)
            var_0003 = execute_usecode_array({17530, 17505, 17511, 8449, var_0002, 7769}, -356)
        elseif var_0001 == 305 then
            var_0004 = find_nearby(176, 12, 168, objectref)
            var_0005 = find_nearby(0, 80, 403, -356)
            if not var_0005 and not var_0004 then
                run_endgame(true)
            else
                switch_talk_to(26)
                add_dialogue("The wand glows faintly. Batlin smirks. \"Not yet, Avatar.\"")
                hide_npc(-26)
                abort()
            end
        end
        play_sound_effect(62)
        start_endgame()
    end
end