--- Best guess: Manages item selection and positioning for event ID 2, adjusting coordinates and triggering effects, likely part of a forge or combat mechanic.
function utility_event_0508(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018

    if eventid == 2 then
        var_0000 = click_on_item()
        var_0001 = get_item_shape(var_0000)
        var_0002 = false
        var_0003 = get_object_position(get_npc_name(356))
        if var_0001 == 721 or var_0001 == 989 then
            -- Skip
        elseif not is_npc(var_0000) then
            halt_scheduled(var_0000)
            var_0002 = get_object_position(var_0000)
        elseif var_0000 == 0 then
            var_0002[2] = var_0002[2] - 2
            var_0002[3] = var_0002[3] - 2
            var_0002[4] = var_0002[4] - 2
        else
            var_0002 = get_object_position(var_0000)
        end
        var_0004 = create_new_object(797)
        set_object_frame(4, var_0004)
        set_item_flag(18, var_0004)
        var_0005 = set_object_quality(150, var_0004)
        var_0005 = update_last_created(var_0002)
        var_0006 = utility_unknown_1069(var_0004)
        var_0007 = execute_usecode_array(get_npc_name(356), {7769, var_0006})
        if var_0002[1] ~= var_0003[1] then
            if var_0002[1] < var_0003[1] then
                var_0003[1] = var_0003[1] - 1
            else
                var_0003[1] = var_0003[1] + 2
            end
        end
        if var_0002[2] ~= var_0003[2] then
            if var_0002[2] < var_0003[2] then
                var_0003[2] = var_0003[2] - 1
            else
                var_0003[2] = var_0003[2] + 2
            end
        end
        var_0008 = create_new_object(895)
        set_object_frame(0, var_0008)
        set_item_flag(18, var_0008)
        if not is_not_blocked(0, 721, var_0003) then
            var_0005 = update_last_created(var_0003)
        elseif not is_not_blocked(0, 721, {var_0003[1], var_0003[2] + 1, var_0003[3]}) then
            var_0005 = update_last_created({var_0003[1], var_0003[2] + 1, var_0003[3]})
        elseif not is_not_blocked(0, 721, {var_0003[1], var_0003[2] - 2, var_0003[3]}) then
            var_0005 = update_last_created({var_0003[1], var_0003[2] - 2, var_0003[3]})
        else
            sprite_effect(-1, 0, 0, 0, var_0003[2], var_0003[1], 9)
            play_sound_effect(46)
            remove_item(var_0004)
        end
        var_0009 = delayed_execute_usecode_array(9, {17493, 7715, 1800}, var_0008)
        var_0010 = execute_usecode_array(var_0008, {1789, 17493, 7715})
    elseif eventid == 1 then
        var_0011 = find_nearby(0, 80, 797, get_npc_name(356))
        for i = 1, #var_0011 do
            var_0014 = var_0011[i]
            var_0015 = get_object_quality(var_0014)
            var_0016 = get_object_frame(var_0014)
            if var_0015 == 150 and var_0016 == 4 then
                close_gumps()
                var_0017 = get_object_position(get_npc_name(356))
                sprite_effect(-1, 0, 0, 0, var_0017[2] - 1, var_0017[1] - 1, 9)
                play_sound_effect(46)
            end
        end
        close_gumps()
        var_0018 = delayed_execute_usecode_array(1, {17493, 7715, 1788}, objectref)
    end
    return
end