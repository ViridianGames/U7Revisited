--- Best guess: Manages sword interactions during forging, checking heat (frame 8-12) and position, updating frames or displaying failure messages, with specific event triggers.
function object_swordblank_0668(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    if eventid == 1 then
        if is_readied(359, 623, 1, -356) then
            var_0000 = find_nearest(3, 991, objectref)
            if var_0000 then
                var_0001 = get_object_position(objectref)
                var_0002 = get_object_position(var_0000)
                if var_0001[1] == var_0002[1] and var_0001[2] == var_0002[2] and var_0001[3] == var_0002[3] + 1 then
                    var_0003 = get_object_frame(var_0000)
                    if var_0003 >= 10 and var_0003 <= 12 then
                        object_hammer_0623(var_0000)
                    end
                end
            end
        end
        close_gumps()
        var_0004 = get_object_frame(objectref)
        if var_0004 >= 8 and var_0004 <= 15 then
            if not get_container(objectref) then
                var_0005 = {1, -1, 1, 0}
                var_0006 = {0, 2, 1, 2}
                utility_position_0808(objectref, var_0005, var_0006, -3, 668, objectref, 7)
            else
                var_0007 = utility_unknown_1093(objectref)
                var_0005 = {1, -1, 1, 0}
                var_0006 = {0, 2, 1, 2}
                utility_position_0808(var_0007, var_0005, var_0006, -3, 668, var_0007, 7)
            end
        end
    elseif eventid == 7 then
        var_0009 = utility_unknown_1069(objectref)
        var_0008 = execute_usecode_array({8033, 3, 17447, 8556, var_0009, 7769}, get_npc_name(-356))
        var_0008 = execute_usecode_array({1815, 8021, 3, 7719}, objectref)
    elseif eventid == 2 then
        var_000A = get_cont_items(-359, -359, 668, get_npc_name(-356))
        if var_000A then
            var_000B = click_on_item()
            var_000C = get_item_shape(var_000B)
            if var_000C == 991 and get_object_frame(var_000B) == 1 then
                utility_position_0808(var_000B, 0, 0, 2, 668, var_000B, 8)
            elseif var_000C == 739 and get_object_frame(var_000B) >= 4 and get_object_frame(var_000B) <= 7 then
                utility_position_0808(var_000B, 1, 0, 0, 668, var_000B, 9)
            elseif var_000C == 741 then
                var_0003 = get_object_frame(var_000A)
                if var_0003 >= 8 and var_0003 <= 12 then
                    utility_position_0808(var_000B, 0, 1, 0, 668, var_000B, 10)
                else
                    item_say("@The sword's not hot.@", get_npc_name(-356))
                end
            end
        else
            item_say("@I can't pick it up.@", get_npc_name(-356))
        end
    elseif eventid == 8 then
        var_0009 = utility_unknown_1069(objectref)
        var_0008 = execute_usecode_array({8033, 3, 17447, 8556, var_0009, 7769}, get_npc_name(-356))
        var_000A = get_cont_items(-359, -359, 668, get_npc_name(-356))
        var_0008 = execute_usecode_array({1675, 8021, 3, 7719}, var_000A)
    elseif eventid == 9 then
        var_0009 = utility_unknown_1069(objectref)
        var_0008 = execute_usecode_array({8033, 3, 17447, 8556, var_0009, 7769}, get_npc_name(-356))
        var_000A = get_cont_items(-359, -359, 668, get_npc_name(-356))
        var_0008 = execute_usecode_array({1676, 8021, 3, 7719}, var_000A)
    elseif eventid == 10 then
        var_0009 = utility_unknown_1069(objectref)
        var_0008 = execute_usecode_array({8556, var_0009, 7769}, get_npc_name(-356))
        var_0008 = execute_usecode_array({1677, 8021, 5, 7719}, objectref)
    end
    return
end