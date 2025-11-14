--- Best guess: Manages item interactions for event ID 2, adjusting positions and triggering effects for items with specific quality and frame, likely part of a forge or environmental mechanic.
function utility_event_0509(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014

    if eventid == 2 then
        var_0000 = false
        var_0001 = false
        var_0002 = find_nearby(0, 80, 797, get_npc_name(356))
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = get_object_quality(var_0005)
            var_0007 = get_object_frame(var_0005)
            if var_0006 == 150 and var_0007 == 4 then
                var_0000 = var_0005
                var_0001 = get_object_position(var_0005)
            end
        end
        var_0008 = get_object_position(objectref)
        var_0009 = utility_unknown_0903(var_0000, var_0001, var_0008)
        if not var_0009 then
            remove_item(var_0000)
        end
        var_0010 = create_new_object(895)
        set_object_frame(0, var_0010)
        set_item_flag(18, var_0010)
        if not is_not_blocked(0, 721, var_0009) then
            var_0011 = update_last_created(var_0009)
        elseif not is_not_blocked(0, 721, {var_0009[1], var_0009[2] + 1, var_0009[3]}) then
            var_0011 = update_last_created({var_0009[1], var_0009[2] + 1, var_0009[3]})
        elseif not is_not_blocked(0, 721, {var_0009[1], var_0009[2] - 2, var_0009[3]}) then
            var_0011 = update_last_created({var_0009[1], var_0009[2] - 2, var_0009[3]})
        else
            sprite_effect(-1, 0, 0, 0, var_0009[2], var_0009[1], 4)
            play_sound_effect(9)
            var_0012 = create_new_object(275)
            set_object_frame(6, var_0012)
            set_item_flag(18, var_0012)
            var_0011 = set_object_quality(151, var_0012)
            var_0011 = update_last_created(var_0009)
            utility_ship_0904(var_0012)
            remove_item(var_0000)
            remove_item(var_0012)
        end
        var_0013 = delayed_execute_usecode_array(9, {17493, 7715, 1800}, var_0010)
        var_0008 = get_object_position(var_0010)
        var_0009 = utility_unknown_0903(var_0000, var_0001, var_0008)
        if not var_0009 then
            remove_item(var_0000)
        end
        var_0010 = create_new_object(895)
        set_object_frame(0, var_0010)
        set_item_flag(18, var_0010)
        if not is_not_blocked(0, 721, var_0009) then
            var_0011 = update_last_created(var_0009)
        elseif not is_not_blocked(0, 721, {var_0009[1], var_0009[2] + 1, var_0009[3]}) then
            var_0011 = update_last_created({var_0009[1], var_0009[2] + 1, var_0009[3]})
        elseif not is_not_blocked(0, 721, {var_0009[1], var_0009[2] - 2, var_0009[3]}) then
            var_0011 = update_last_created({var_0009[1], var_0009[2] - 2, var_0009[3]})
        else
            sprite_effect(-1, 0, 0, 0, var_0009[2], var_0009[1], 4)
            play_sound_effect(9)
            var_0012 = create_new_object(275)
            set_object_frame(6, var_0012)
            set_item_flag(18, var_0012)
            var_0011 = set_object_quality(151, var_0012)
            var_0011 = update_last_created(var_0009)
            utility_ship_0904(var_0012)
            remove_item(var_0000)
            remove_item(var_0012)
        end
        var_0013 = delayed_execute_usecode_array(9, {17493, 7715, 1800}, var_0010)
        var_0014 = execute_usecode_array(var_0010, {1789, 17493, 7715})
    end
    return
end