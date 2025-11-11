--- Best guess: Manages bucket interactions, handling water usage for drinking, filling troughs, dousing fires, and other actions, with appropriate messages.
function object_bucket_0810(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_001A, var_001B, var_001C, var_001D, var_001E, var_001F, var_0020, var_0021, var_0022

    if eventid == 1 then
        close_gumps()
        var_0000 = get_object_frame(objectref)
        if var_0000 == 6 then
        end
        if not get_container(objectref) then
            var_0001 = {-1, -1, -1, -1, 1, 1, 1, 0}
            var_0002 = {-1, 0, -1, 1, -1, 0, 1, 1}
            utility_position_0808(objectref, var_0001, var_0002, -3, 810, objectref, 3)
        elseif not utility_unknown_1092(objectref) then
            close_gumps()
            var_0003 = utility_unknown_1093(objectref)
            var_0001 = {1, -1, 1, 0}
            var_0002 = {0, 2, 1, 2}
            utility_position_0808(var_0003, var_0001, var_0002, -3, 810, objectref, 3)
        else
            close_gumps()
            var_0004 = execute_usecode_array(objectref, {810, 8021, 2, 7719})
        end
    elseif eventid == 3 then
        var_0003 = utility_unknown_1093(objectref)
        var_0005 = utility_unknown_1069(var_0003)
        if is_npc(var_0003) then
            var_0004 = execute_usecode_array(get_npc_name(-356), {8033, 3, 17447, 8548, var_0005, 7769})
            var_0004 = execute_usecode_array(objectref, {810, 8021, 2, 7975, 1682, 8021, 3, 7719})
        else
            var_0004 = execute_usecode_array(get_npc_name(-356), {8033, 3, 17447, 8556, var_0005, 7769})
            var_0004 = execute_usecode_array(objectref, {810, 8021, 2, 7975, 1682, 8021, 3, 7719})
        end
    elseif eventid == 2 then
        var_0000 = get_object_frame(objectref)
        var_0006 = click_on_item()
        var_0007 = get_item_shape(var_0006)
        if var_0007 == 721 or var_0007 == 989 then
            if var_0000 == 2 then
                item_say("@No, thank thee.@", get_npc_name(-356))
            elseif var_0000 == 0 then
                item_say("@The bucket is empty.@", get_npc_name(-356))
            else
                item_say("@Ahhh, how refreshing.@", get_npc_name(-356))
                var_0004 = execute_usecode_array(objectref, {0, 7750})
            end
        elseif is_npc(var_0006) then
            var_0001 = {-2, 0, 2, 0}
            var_0002 = {0, -2, 0, 2}
            if var_0000 == 0 then
                item_say("@The bucket is empty.@", get_npc_name(-356))
            else
                var_0004 = execute_usecode_array(var_0006, {50, -2, 7947, 1, 7719})
                utility_position_0808(var_0006, var_0001, var_0002, 0, 810, var_0006, 4)
            end
        elseif var_0007 == 741 then
            var_0001 = {-4, -4, 1, 1, -2, -1, -2, -1}
            var_0002 = {-1, -1, 0, 1, -2, -2, 1, 1}
            utility_position_0808(var_0006, var_0001, var_0002, 0, 810, var_0006, 7)
        elseif var_0007 == 719 then
            var_0001 = {-1, 0, -1, 1, -2, -1, -2, -1}
            var_0002 = {-1, -1, 0, 0, -2, -2, 1, 1}
            utility_position_0808(var_0006, var_0001, var_0002, 0, 810, var_0006, 7)
        elseif var_0007 == 739 then
            var_0001 = {-4, -4, -2, -1, 1, 1, -2, -1}
            var_0002 = {-1, -1, -2, -1, 1, 1, -2, -1}
            if get_object_frame(var_0006) >= 4 and get_object_frame(var_0006) <= 7 then
                var_0001 = {-4, -4, -2, -1, 1, 1, -2, -1}
                var_0002 = {-1, -1, -2, -1, 1, 1, -2, -1}
                if var_0000 == 0 then
                    item_say("@The bucket is empty.@", get_npc_name(-356))
                else
                    utility_position_0808(var_0006, var_0001, var_0002, -5, 810, var_0006, 8)
                end
            end
        elseif var_0007 == 338 or var_0007 == 435 or var_0007 == 701 or var_0007 == 658 or var_0007 == 825 then
            var_0001 = {0, -2, 0, 2}
            var_0002 = {-2, 0, 2, 0}
            if var_0000 == 0 then
                item_say("@The bucket is empty.@", get_npc_name(-356))
            elseif var_0000 > 1 then
            elseif var_0000 == 1 then
                utility_position_0808(var_0006, var_0001, var_0002, -5, 810, var_0006, 8)
            end
        elseif var_0007 == 740 then
            if var_0000 == 0 then
                var_0008 = find_nearest(3, 470, var_0006)
                if var_0008 then
                    var_0001 = {-5, -5}
                    var_0002 = {-1, -1}
                    utility_position_0808(var_0008, var_0001, var_0002, 0, 810, objectref, 9)
                end
            else
                item_say("@The bucket is full.@", get_npc_name(-356))
            end
        elseif var_0007 == 470 then
            if var_0000 == 0 then
                var_0001 = {-5, -5}
                var_0002 = {-1, -1}
                utility_position_0808(var_0006, var_0001, var_0002, 0, 810, objectref, 9)
            else
                item_say("@The bucket is full.@", get_npc_name(-356))
            end
        elseif var_0007 == 331 then
            if var_0000 == 0 then
                item_say("@The bucket is empty.@", get_npc_name(-356))
            else
                var_0008 = get_object_position(var_0006)
                var_0008[2] = var_0008[2] + 1
                var_0009 = path_run_usecode(10, 810, objectref, var_0008)
            end
        else
            if var_0000 == 0 then
                item_say("@The bucket is empty.@", get_npc_name(-356))
            else
                var_0008 = get_object_position(var_0006)
                var_0008[2] = var_0008[2] + 1
                var_0009 = path_run_usecode(10, 810, objectref, var_0008)
            end
        end
    elseif eventid == 4 then
        var_000A = get_cont_items(-359, -359, 810, get_npc_name(-356))
        var_0000 = get_object_frame(var_000A)
        var_000B = utility_unknown_1069(objectref)
        var_000C = (var_000B + 4) % 8
        if var_0000 == 2 then
            var_000D = execute_usecode_array(objectref, {5, 7463, "@Foul miscreant!@", 8018, 2, 8487, var_000C, 7769})
        else
            var_000D = execute_usecode_array(objectref, {5, 7463, "@Hey, stop that!@", 8018, 2, 8487, var_000C, 7769})
        end
        var_000E = execute_usecode_array(get_npc_name(-356), {17505, 17508, 8551, var_000B, 7769})
        var_000F = execute_usecode_array(var_000A, {0, 8006, 2, 7719})
    elseif eventid == 7 then
        var_0010 = false
        var_0010 = find_nearest(5, 741, get_npc_name(-356))
        if not var_0010 then
            var_0010 = find_nearest(5, 719, get_npc_name(-356))
        end
        if var_0010 then
            var_0000 = get_object_frame(objectref)
            var_0011 = get_object_frame(var_0010)
            if var_0000 > 1 then
            elseif var_0000 == 1 then
                if var_0011 == 3 or var_0011 == 7 then
                    item_say("@The trough is full.@", get_npc_name(-356))
                else
                    var_0012 = var_0011 + 1
                    var_0013 = 0
                end
            else
                if var_0011 == 0 or var_0011 == 4 then
                    item_say("@The trough is empty.@", get_npc_name(-356))
                else
                    var_0012 = var_0011 - 1
                    var_0013 = 1
                end
            end
            var_0014 = execute_usecode_array(get_npc_name(-356), {17505, 17508, 8551, var_0005, 7769})
            var_0014 = execute_usecode_array(var_0010, {40, 17496, 8449, var_0012, 8006, 2, 7719})
            var_0015 = execute_usecode_array(objectref, {var_0013, 8006, 2, 7719})
        end
    elseif eventid == 8 then
        var_000A = get_cont_items(-359, -359, 810, get_npc_name(-356))
        var_0000 = get_object_frame(var_000A)
        var_0007 = get_item_shape(objectref)
        var_0015 = get_object_frame(objectref)
        if var_0007 == 739 then
            if var_0015 == 4 then
                item_say("@There are only coals.@", get_npc_name(-356))
            elseif var_0015 == 7 then
                var_0016 = execute_usecode_array(objectref, {17488, 17488, 17488, 7937, 1683, 7765})
            elseif var_0015 == 6 then
                var_0016 = execute_usecode_array(objectref, {17488, 17488, 7937, 1683, 7765})
            elseif var_0015 == 5 then
                var_0016 = execute_usecode_array(objectref, {17488, 7937, 1683, 7765})
            end
            var_0005 = utility_unknown_1069(objectref)
            var_0016 = execute_usecode_array(get_npc_name(-356), {8033, 2, 17447, 8556, var_0005, 7769})
            if var_0007 == 338 then
                var_001A = 336
            elseif var_0007 == 435 then
                var_001A = 481
            elseif var_0007 == 701 then
                var_001A = 595
            end
            remove_item(objectref)
            var_001B = create_new_object(var_001A)
            var_0019 = get_object_quality(objectref)
            var_001C = set_object_quality(var_001B, var_0019)
            set_object_frame(var_001B, var_0015)
            var_0017 = get_object_position(objectref)
            var_0005 = utility_unknown_1069(objectref)
            var_001E = execute_usecode_array(get_npc_name(-356), {8033, 2, 17447, 8556, var_0005, 7769})
            var_001D = {var_0017[1], var_0017[2]}
            sprite_effect(-1, 0, 0, 0, var_001D[2], var_001D[1], 9)
            play_sound_effect(46)
        elseif var_0007 == 825 then
            if var_0015 == 0 then
                item_say("@There are only coals.@", get_npc_name(-356))
            else
                var_001E = execute_usecode_array(objectref, {0, 7750})
                var_0005 = utility_unknown_1069(objectref)
                var_001E = execute_usecode_array(get_npc_name(-356), {8033, 2, 17447, 8556, var_0005, 7769})
                var_001F = get_object_position(objectref)
                sprite_effect(-1, 0, 0, 0, var_001F[2], var_001F[1], 9)
                play_sound_effect(46)
            end
        elseif var_0007 == 658 then
            if var_0015 == 0 then
                var_0005 = utility_unknown_1069(objectref)
                var_001E = execute_usecode_array(get_npc_name(-356), {8033, 2, 17447, 8556, var_0005, 7769})
                set_object_frame(objectref, 2)
            end
        end
    elseif eventid == 9 then
        var_0020 = find_nearest(10, 740, get_npc_name(-356))
        var_0021 = get_object_frame(var_0020)
        if var_0021 >= 0 and var_0021 <= 11 then
            var_0021 = 1
        elseif var_0021 >= 12 and var_0021 <= 23 then
            var_0021 = 13
        end
        var_0022 = execute_usecode_array(var_0020, {8014, 1, 17447, 8014, 1, 17447, 8014, 1, 17447, 8014, 1, 17447, 8014, 2, 8487, var_0021, 8006, 1, 7719})
        var_0022 = execute_usecode_array(get_npc_name(-356), {4, 17447, 8039, 1, 17447, 8036, 1, 17447, 8038, 1, 17447, 8037, 1, 7975, 4, 8025, 2, 17447, 8039, 2, 7769})
        var_0022 = execute_usecode_array(objectref, {1685, 8021, 17, 7719})
    elseif eventid == 10 then
        var_000E = execute_usecode_array(get_npc_name(-356), {8033, 3, 17447, 8044, 0, 7769})
        var_000F = execute_usecode_array(objectref, {1684, 8021, 3, 7719})
    end
end