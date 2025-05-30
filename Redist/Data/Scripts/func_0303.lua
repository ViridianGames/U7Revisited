--- Best guess: Handles a wand’s interaction with specific items (e.g., Black Gate, ID 305) or NPCs (e.g., Batlin, ID 403), triggering effects or dialogue.
function func_0303(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 4 then
        var_0000 = objectref
    else
        var_0000 = object_select_modal()
    end
    if var_0000 then
        unknown_007EH()
        var_0001 = get_object_shape(var_0000)
        if var_0001 == 914 then
            var_0002 = unknown_092DH(var_0000)
            var_0003 = unknown_0001H({7981, 5, 7719}, var_0000)
            var_0003 = unknown_0041H(704, var_0000, -356)
            var_0003 = unknown_0001H({17530, 17505, 17511, 8449, var_0002, 7769}, -356)
        elseif var_0001 == 305 then
            var_0004 = unknown_0035H(176, 12, 168, objectref)
            var_0005 = unknown_0035H(0, 80, 403, -356)
            if not var_0005 and not var_0004 then
                unknown_0075H(true)
            else
                switch_talk_to(26, 0)
                add_dialogue("The wand glows faintly. Batlin smirks. \"Not yet, Avatar.\"")
                hide_npc(-26)
                abort()
            end
        end
        unknown_000FH(62)
        start_endgame()
    end
end