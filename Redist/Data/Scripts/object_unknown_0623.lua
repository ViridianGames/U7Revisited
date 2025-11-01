--- Best guess: Manages sword forging by hammering, checking heat levels (frame 8-15) and transforming the sword (type 991) if conditions are met, with failure messages.
function object_unknown_0623(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 1 then
        if not is_readied(359, 623, 1, 356) then
            flash_mouse(2)
        end
        close_gumps()
        utility_unknown_0400(objectref)
    elseif eventid == 2 then
        var_0000 = false
        var_0001 = get_item_shape(objectref)
        if var_0001 == 991 then
            var_0000 = find_nearest(1, 668, objectref)
        elseif var_0001 == 623 then
            var_0000 = click_on_item()
        end
        if var_0000 and get_item_shape(var_0000) == 668 then
            var_0002 = find_nearest(3, 991, var_0000)
            if not var_0002 then
                var_0003 = get_object_position(var_0002)
                var_0004 = get_object_position(var_0000)
                if var_0004[1] == var_0003[1] and var_0004[2] == var_0003[2] and var_0004[3] == var_0003[3] - 1 then
                    var_0005 = get_item_frame(var_0000)
                    if var_0005 >= 8 and var_0005 <= 15 then
                        utility_position_0808(var_0000, 0, 2, 0, 623, var_0002, 7)
                    end
                end
            end
        end
    elseif eventid == 7 then
        var_0006 = find_nearest(3, 668, get_npc_name(-356))
        var_0005 = get_item_frame(var_0006)
        var_0007 = get_npc_name(-356)
        var_0008 = utility_unknown_1069(objectref)
        if var_0005 >= 13 and var_0005 <= 15 then
            item_say("@The sword is not heated.@", var_0007)
            var_0009 = execute_usecode_array(var_0008, 7769, var_0007)
        elseif var_0005 == 8 or var_0005 == 9 then
            item_say("@The sword is too cool.@", var_0007)
            var_0009 = execute_usecode_array(var_0008, 7769, var_0007)
        elseif var_0005 >= 10 and var_0005 <= 12 then
            var_0009 = execute_usecode_array({17505, 17508, 17511, 17509, 8548, var_0008, 7769}, var_0007)
            var_0002 = find_nearest(3, 991, get_npc_name(-356))
            var_0009 = execute_usecode_array({1681, 8021, 4, 7719}, var_0002)
        end
    end
    return
end