--- Best guess: Manages an egg outside the forge, triggering different item creations based on event IDs and item types, with flag checks and dialogue.
function utility_event_0505(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_0020, var_0021, var_0022, var_0023, var_0024, var_0025, var_0026, var_0027, var_0028, var_0029, var_0030, var_0031

    var_0000 = false
    var_0001 = false
    if eventid == 2 then
        var_0002 = get_item_shape(objectref)
        if var_0002 == 854 then
            return
        elseif var_0002 == 707 then
            var_0000 = {1530, 2192}
            var_0001 = 0
        else
            fade_palette(1, 1, 12)
            if var_0002 == 955 then
                var_0003 = false
                var_0004 = find_nearby(0, 20, 854, 356)
                if var_0004 then
                    for i = 1, #var_0004 do
                        var_0007 = var_0004[i]
                        if get_object_frame(objectref) == 8 and get_object_frame(var_0007) == 16 then
                            var_0003 = var_0007
                        elseif get_object_frame(objectref) == 9 and get_object_frame(var_0007) == 15 then
                            var_0003 = var_0007
                        elseif get_object_frame(objectref) == 10 and get_object_frame(var_0007) == 14 then
                            var_0003 = var_0007
                        end
                    end
                    object_unknown_0854(4, var_0003)
                end
            end
        end
    elseif eventid == 1 then
        var_0000 = {1637, 2168}
        var_0001 = 4
    elseif eventid == 4 then
        var_0000 = {1530, 2192}
        var_0001 = 0
    elseif eventid == 7 then
        var_0000 = {1487, 2187}
        var_0001 = 6
    elseif eventid == 3 then
        var_0008 = get_object_quality(objectref)
        if var_0008 == 1 then
            if not get_flag(808) then
                var_0000 = {1671, 2464}
                var_0001 = 4
            end
        elseif var_0008 == 2 then
            if not get_flag(834) then
                var_0000 = {1637, 2216}
                var_0001 = 4
            end
        elseif var_0008 == 3 then
            var_0000 = {1483, 2191}
            var_0001 = 0
        elseif var_0008 == 4 then
            if not get_flag(808) then
                var_0000 = {1502, 2182}
                var_0001 = 4
            end
        elseif var_0008 == 5 then
            var_0000 = {1502, 2201}
            var_0001 = 4
        elseif var_0008 == 6 then
            var_0000 = {1591, 2312}
            var_0001 = 0
        elseif var_0008 == 7 then
            if not utility_unknown_1000(8) then
                var_0000 = {1483, 2191}
                var_0001 = 0
                set_flag(793, true)
            else
                var_0009 = find_nearby(0, 80, 955, objectref)
                for i = 1, #var_0009 do
                    var_0012 = var_0009[i]
                    var_0013 = get_object_frame(var_0012)
                    if var_0013 == 8 then
                        var_0014 = get_object_position(var_0012)
                        var_0015 = set_last_created(objectref)
                        update_last_created(var_0014)
                    end
                end
            end
        elseif var_0008 == 8 then
            if not utility_unknown_1000(9) then
                var_0000 = {1487, 2195}
                var_0001 = 2
                set_flag(834, true)
            else
                var_0009 = find_nearby(0, 80, 955, objectref)
                for i = 1, #var_0009 do
                    var_0012 = var_0009[i]
                    var_0013 = get_object_frame(var_0012)
                    if var_0013 == 9 then
                        var_0014 = get_object_position(var_0012)
                        var_0015 = set_last_created(objectref)
                        update_last_created(var_0014)
                    end
                end
            end
        elseif var_0008 == 9 then
            var_0012 = find_nearest(0, 955, objectref)
            if var_0012 and get_object_frame(var_0012) == 11 then
                if not utility_unknown_1000(11) then
                    remove_item(var_0012)
                    var_0014 = get_object_position(objectref)
                    sprite_effect(-1, 0, 0, 0, var_0014[2] - 2, var_0014[1] - 2, 7)
                    play_sound_effect(67)
                end
                var_0009 = find_nearby(0, 25, 955, 356)
                if var_0009 then
                    for i = 1, #var_0009 do
                        var_0013 = var_0009[i]
                        var_001D = get_object_frame(var_0013)
                        if var_001D == 11 then
                            remove_item(var_0013)
                            var_0014 = get_object_position(objectref)
                            sprite_effect(-1, 0, 0, 0, var_0014[2] - 2, var_0014[1] - 2, 7)
                            play_sound_effect(67)
                        end
                    end
                end
                var_0017 = find_nearby(0, 8, 750, objectref)
                var_001B = find_nearby(0, 8, 849, objectref)
                var_001B = {var_001B, unpack(find_nearby(0, 8, 293, objectref))}
                var_001B = {var_001B, unpack(find_nearby(0, 8, 678, objectref))}
                var_001B = {var_001B, unpack(find_nearby(0, 8, 657, objectref))}
                var_001B = {var_001B, unpack(find_nearby(0, 8, 750, objectref))}
                var_001C = find_nearby(0, 8, 338, objectref)
                for i = 1, #var_001C do
                    var_001F = var_001C[i]
                    var_0020 = get_object_frame(var_001F)
                    if var_0020 == 2 then
                        var_001B = {var_001B, var_001F}
                    end
                end
                var_0021 = find_nearby(0, 8, 336, objectref)
                for i = 1, #var_0021 do
                    var_001F = var_0021[i]
                    var_0020 = get_object_frame(var_001F)
                    if var_0020 == 2 then
                        var_001B = {var_001B, var_001F}
                    end
                end
                var_0024 = find_nearby(0, 8, 997, objectref)
                for i = 1, #var_0024 do
                    var_001F = var_0024[i]
                    var_0020 = get_object_frame(var_001F)
                    if var_0020 == 2 then
                        var_001B = {var_001B, var_001F}
                    end
                end
                for i = 1, #var_001B do
                    var_001A = var_001B[i]
                    remove_item(var_001A)
                end
                var_0029 = find_nearest(8, 718, objectref)
                set_object_frame(1, var_0029)
            end
        elseif var_0008 == 10 then
            var_0012 = find_nearest(0, 955, objectref)
            if var_0012 and get_object_frame(var_0012) == 11 then
                set_flag(832, true)
                if not utility_unknown_1000(11) then
                    remove_item(var_0012)
                    var_0014 = get_object_position(objectref)
                    sprite_effect(-1, 0, 0, 0, var_0014[2] - 2, var_0014[1] - 2, 7)
                    play_sound_effect(67)
                end
                var_0009 = find_nearby(0, 25, 955, 356)
                if var_0009 then
                    for i = 1, #var_0009 do
                        var_0013 = var_0009[i]
                        var_001D = get_object_frame(var_0013)
                        if var_001D == 11 then
                            remove_item(var_0013)
                            var_0014 = get_object_position(objectref)
                            sprite_effect(-1, 0, 0, 0, var_0014[2] - 2, var_0014[1] - 2, 7)
                            play_sound_effect(67)
                        end
                    end
                end
                var_002C = find_nearest(10, 515, objectref)
                remove_item(var_002C)
                var_002D = create_new_object(870)
                set_object_frame(0, var_002D)
                var_0014 = get_object_position(objectref)
                var_0015 = update_last_created(var_0014)
            end
        elseif var_0008 == 11 then
            if not get_flag(832) then
                var_002C = find_nearest(10, 515, objectref)
                remove_item(var_002C)
                var_002D = create_new_object(870)
                set_object_frame(0, var_002D)
                var_0014 = get_object_position(objectref)
                var_0015 = update_last_created(var_0014)
            end
            var_0000 = {1590, 2391}
            var_0001 = 0
        elseif var_0008 == 12 then
            var_0000 = {1589, 2392}
            var_0001 = 4
        elseif var_0008 == 13 then
            var_0000 = {1401, 2152}
            var_0001 = 4
        elseif var_0008 == 14 then
            if not get_flag(808) then
                var_0000 = {1495, 2439}
                var_0001 = 4
            end
        elseif var_0008 == 15 then
            if not get_flag(808) then
                var_0000 = {1732, 2520}
                var_0001 = 0
            end
        elseif var_0008 == 16 then
            var_0000 = {1590, 2391}
            var_0001 = 0
        elseif var_0008 == 17 then
            var_0000 = {1476, 2359}
            var_0001 = 4
        elseif var_0008 == 20 then
            var_0000 = {1560, 2740}
            var_0001 = 6
        elseif var_0008 == 21 then
            var_002E = find_nearest(3, 268, objectref)
            if not var_002E then
                set_object_frame(2, var_002E)
                play_sound_effect(37)
            end
        end
        if var_0000 and not get_item_flag(var_0000, 10) then
            fade_palette(0, 1, 12)
            move_object(var_0000, 357)
            if get_flag(793) and not get_flag(792) then
                if not utility_unknown_1000(8) then
                    var_000C = utility_unknown_1000(8)
                    set_flag(791, true)
                    var_002F = execute_usecode_array({1785, 8021, 2, 7719}, var_000C)
                    var_0030 = execute_usecode_array({2, 8487, var_0001, 7769}, 356)
                end
            elseif get_flag(808) and not get_flag(807) then
                if not utility_unknown_1000(10) then
                    var_000C = utility_unknown_1000(10)
                    set_flag(791, true)
                    var_002F = execute_usecode_array({1785, 8021, 2, 7719}, var_000C)
                    var_0030 = execute_usecode_array({2, 8487, var_0001, 7769}, 356)
                end
            elseif get_flag(834) and not get_flag(833) then
                if not utility_unknown_1000(9) then
                    var_000C = utility_unknown_1000(9)
                    set_flag(791, true)
                    var_002F = execute_usecode_array({1785, 8021, 2, 7719}, var_000C)
                    var_0030 = execute_usecode_array({2, 8487, var_0001, 7769}, 356)
                end
            end
            var_0030 = execute_usecode_array({1785, 8021, 1, 8487, var_0001, 7769}, 356)
        end
    end
    return
end