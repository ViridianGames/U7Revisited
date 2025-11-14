--- Best guess: Manages the entry to the forge, handling Erethian's dialogue, mirror interactions, and flag-based sequences when event ID 2 or 3 is triggered.
function utility_event_0504(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_0020, var_0021, var_0022, var_0023, var_0024, var_0025, var_0026, var_0027, var_0028, var_0029, var_0030, var_0031

    if eventid == 3 then
        var_0000 = get_object_quality(objectref)
        if var_0000 == 0 then
            var_0001 = find_nearest(10, 848, objectref)
            var_0002 = get_object_frame(var_0001)
            if not var_0002 == 9 then
                set_object_frame(3, var_0001)
            end
        elseif var_0000 == 1 then
            var_0003 = find_nearby(0, 1, 726, objectref)
            if var_0003 then
                set_flag(831, true)
            else
                set_flag(831, false)
            end
            if get_flag(831) and get_flag(828) then
                -- Skip
            end
        elseif var_0000 == 2 then
            var_0003 = find_nearby(0, 1, 726, objectref)
            if var_0003 then
                set_flag(828, true)
            else
                set_flag(828, false)
            end
            if get_flag(828) and get_flag(831) then
                -- Skip
            end
        elseif var_0000 == 4 then
            if get_flag(828) and get_flag(831) then
                -- Skip
            end
        end
        var_0004 = find_nearest(10, 990, objectref)
        if var_0004 then
            var_0005 = get_object_position(var_0004)
            var_0006 = find_nearby(0, 1, 955, var_0004)
            var_0007 = false
            for i = 1, #var_0006 do
                var_0010 = var_0006[i]
                var_0011 = get_object_frame(var_0010)
                var_0012 = get_object_position(var_0010)
                if var_0011 == 8 and var_0012[1] == var_0005[1] - 1 and var_0012[2] == var_0005[2] and var_0012[3] == 4 then
                    var_0007 = var_0007 + 1
                elseif var_0011 == 9 and var_0012[1] == var_0005[1] and var_0012[2] == var_0005[2] - 1 and var_0012[3] == 4 then
                    var_0007 = var_0007 + 1
                elseif var_0011 == 10 and var_0012[1] == var_0005[1] and var_0012[2] == var_0005[2] and var_0012[3] == 4 then
                    var_0007 = var_0007 + 1
                end
            end
            if var_0007 == 3 then
                var_000D = false
                var_000E = find_nearby(0, 40, 435, 356)
                for i = 1, #var_000E do
                    var_0011 = var_000E[i]
                    var_0012 = get_object_position(var_0011)
                    if (var_0012[1] == 2208 or var_0012[1] == 2221) and var_0012[2] == 1514 and var_0012[3] == 1 then
                        var_000D = var_000D + 1
                    end
                end
                if var_000D == 2 then
                    utility_unknown_0893()
                    var_0013 = get_object_position(get_npc_name(356))
                    if var_0013[2] > var_0005[2] then
                        if is_player_female() then
                            set_object_frame(20, utility_event_0897())
                        else
                            set_object_frame(18, utility_event_0897())
                        end
                    else
                        if is_player_female() then
                            set_object_frame(21, utility_event_0897())
                        else
                            set_object_frame(19, utility_event_0897())
                        end
                    end
                    var_0014 = create_new_object(955)
                    set_object_frame(7, var_0014)
                    set_object_frame(1, var_0004)
                    var_0015 = update_last_created({var_0005[1] - 1, var_0005[2] - 1, var_0005[3] + 2})
                    sprite_effect(-1, 0, 0, 0, var_0005[2] - 2, var_0005[1] - 2, 7)
                    play_sound_effect(68)
                    execute_usecode_array(var_0004, {1784, 17493, 7937, 31, 8006, 24, -1, 17419, 8014, 5, 7750})
                end
            end
        end
    elseif eventid == 2 then
        if not get_flag(780) then
            if not get_flag(750) then
                utility_unknown_1023("@'Tis sad that Erethian's lust for power has brought him to this evil pass.@")
                utility_unknown_1023("@Perhaps, at last, he is at rest.@")
            end
            if not is_dead(23) then
                utility_unknown_1023("@I am sure that Lord British even now awaits news of Exodus' exile.@")
            end
            utility_unknown_1023("@It is time to leave this barren island behind.@")
            return
        end
        var_0005 = get_object_position(objectref)
        var_0013 = get_object_position(get_npc_name(356))
        if get_flag(831) and get_flag(828) then
            if not get_flag(750) then
                var_0017 = false
                var_0018 = false
                var_0019 = find_nearby(8, 80, 154, objectref)
                for i = 1, #var_0019 do
                    var_001C = var_0019[i]
                    if not get_cont_items(4, 240, 797, var_001C) and not (get_distance(objectref, var_001C) < 8) then
                        sprite_effect(-1, 0, 0, 0, get_object_position(var_001C)[2] - 1, get_object_position(var_001C)[1] - 1, 13)
                        utility_event_0998(var_001C)
                    else
                        var_0017 = var_001C
                    end
                end
                if not var_0017 then
                    var_0017 = create_new_object(154)
                    set_item_flag(18, var_0017)
                    var_001E = get_object_position(get_npc_name(356))
                    if var_001E[2] > var_0013[2] then
                        set_object_frame(19, var_0017)
                        var_001D = {1510, 2}
                    else
                        set_object_frame(3, var_0017)
                        var_001D = {1518, 2}
                    end
                    var_0015 = update_last_created(var_001D)
                    sprite_effect(-1, 0, 0, 0, var_001D[2] - 1, var_001D[1] - 1, 13)
                    execute_usecode_array(var_0017, {8048, 5, 8487, var_0013[2], 7769})
                end
                earthquake(1)
                sprite_effect(-1, 0, 0, 0, var_0013[1], var_0013[2], 17)
                play_sound_effect(62)
                set_flag(828, false)
                delayed_execute_usecode_array(7, 1784, {7765}, objectref)
                return
            end
            switch_talk_to(286, 1)
            add_dialogue("\"No! Thou must not do this!\" Erethian's voice is full of anguish. He raises his arms and begins a powerful spell.")
            add_dialogue("\"Vas Ort Rel Tym...\"")
            add_dialogue("He stops mid-spell and begins another, pointing towards the Talisman of Infinity.")
            add_dialogue("\"Vas An Ort Ailem!\"")
            add_dialogue("You immediately recognize the resonance of a spell gone awry, and apparently so does Erethian. A look of horror comes to his wrinkled features which appear to become more lined by the second.*")
            var_001C = find_nearest(10, 154, objectref)
            execute_usecode_array(var_001C, {8045, 2, 17447, 8044, 2, 7719})
            earthquake(1)
            var_0022 = find_nearby(16, 10, 275, objectref)
            for i = 1, #var_0022 do
                var_0025 = var_0022[i]
                if get_object_frame(var_0025) == 7 and get_object_quality(var_0025) == 1 then
                    var_0026 = get_object_position(var_0025)
                    sprite_effect(3, 0, 0, 0, var_0026[2], var_0026[1], 17)
                end
            end
            sprite_effect(-1, 0, 0, 0, var_0005[2] - 2, var_0005[1] - 2, 17)
            set_flag(828, false)
            set_flag(831, true)
            delayed_execute_usecode_array(7, 1784, {7765}, objectref)
            return
        end
        if not get_flag(831) then
            if not get_flag(750) then
                var_001C = find_nearest(10, 528, objectref)
                var_0027 = get_object_frame(var_001C)
                var_0028 = get_object_position(var_001C)
                utility_event_0998(var_001C)
                var_0029 = create_new_object(892)
                set_item_flag(18, var_0029)
                if var_0027 == 12 then
                    set_object_frame(14, var_0029)
                elseif var_0027 == 28 then
                    set_object_frame(22, var_0029)
                end
                var_0015 = update_last_created(var_0028)
                set_flag(750, true)
                play_music(0, 17)
            end
            earthquake(1)
            var_0022 = find_nearby(16, 10, 275, objectref)
            for i = 1, #var_0022 do
                var_0025 = var_0022[i]
                if get_object_frame(var_0025) == 7 and get_object_quality(var_0025) == 2 then
                    var_0026 = get_object_position(var_0025)
                    sprite_effect(3, 0, 0, 0, var_0026[2], var_0026[1], 17)
                end
            end
            sprite_effect(-1, 0, 0, 0, var_0005[2] - 2, var_0005[1] - 2, 17)
            sprite_effect(-1, 0, 0, 0, var_0005[2] - 2, var_0005[1] - 2, 8)
            play_sound_effect(9)
            var_0006 = find_nearby(0, 1, 955, objectref)
            for i = 1, #var_0006 do
                var_0010 = var_0006[i]
                var_0011 = get_object_frame(var_0010)
                if var_0011 == 7 then
                    remove_item(var_0010)
                elseif var_0011 == 8 then
                    remove_item(var_0010)
                elseif var_0011 == 9 then
                    remove_item(var_0010)
                elseif var_0011 == 10 then
                    remove_item(var_0010)
                end
            end
            clear_item_flag(16, 356)
            delayed_execute_usecode_array(14, 17453, {7724}, utility_event_0897())
            execute_usecode_array(get_npc_name(356), {1693, 8021, 12, 7719})
            var_0030 = find_nearest(10, 726, objectref)
            if var_0030 then
                execute_usecode_array(var_0030, {1784, 8021, 16, 7719})
            end
            remove_item(objectref)
            set_flag(780, true)
        end
    end
    return
end