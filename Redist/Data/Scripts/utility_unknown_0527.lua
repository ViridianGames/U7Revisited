--- Best guess: Manages a mechanic for item type 466, creating a body (ID 414) and items (IDs 797, 1783) with environmental effects, or handling container items (ID 797) with quality checks.
function utility_unknown_0527(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018

    var_0000 = get_object_shape(objectref)
    if var_0000 == 466 then
        var_0001 = get_object_position(get_npc_name(-356))
        sprite_effect(-1, 0, 0, 0, var_0001[2], var_0001[1], 17)
        play_sound_effect(62)
        var_0002 = find_nearby(8, 80, -1, get_npc_name(-356))
        for var_0003 in ipairs(var_0002) do
            var_0006 = get_object_shape(var_0005)
            if not (var_0006 == 721 or var_0006 == 989) then
                if get_alignment(var_0005) == 0 then
                    set_alignment(2, var_0005)
                    set_schedule_type(0, var_0005)
                end
            end
        end
        var_0007 = get_object_position(objectref)
        var_0008 = create_new_object(414)
        get_item_frame_rot(objectref)
        set_item_frame_rot(var_0008, objectref)
        get_object_frame(var_0008, 30)
        remove_npc(-23)
        var_0009 = update_last_created(var_0007)
        var_000A = create_new_object(797)
        get_object_frame(var_000A, 0)
        var_0009 = set_object_quality(43, var_000A)
        var_0009 = give_last_created(var_0008)
        var_000B = execute_usecode_array(var_0008, {12, 8006, 2, 7975, 31, 8006, 5, 7719})
    else
        var_000C = get_alignment(objectref)
        play_sound_effect(4)
        if not get_item_flag(objectref, 18) then
            kill_npc(objectref)
            remove_npc(objectref)
            var_0002 = find_nearby(8, 80, -1, get_npc_name(-356))
            for var_000D in ipairs(var_0002) do
                var_0006 = get_object_shape(var_0005)
                if not (var_0006 == 721 or var_0006 == 989) then
                    if get_alignment(var_0005) == var_000C then
                        set_alignment(2, var_0005)
                        set_schedule_type(0, var_0005)
                    end
                end
            end
        end
        var_000F = get_container_objects(-359, -359, 797, objectref)
        if var_000F then
            var_0010 = _get_object_quality(var_000F)
            var_0011 = false
            if var_0010 == 240 then
                set_flag(750, true)
                var_0012 = get_object_position(objectref)
                var_0011 = create_new_object(762)
                get_item_frame_rot(objectref)
                set_item_frame_rot(var_0011, objectref)
                get_object_frame(var_0011, 22)
                utility_event_0998(objectref)
                var_0009 = update_last_created(var_0012)
            elseif var_0010 == 241 then
                set_flag(751, true)
                var_0012 = get_object_position(objectref)
                var_0011 = create_new_object(778)
                get_item_frame_rot(objectref)
                set_item_frame_rot(var_0011, objectref)
                get_object_frame(var_0011, 7)
                utility_event_0998(objectref)
                var_0009 = update_last_created(var_0012)
            end
            var_0013 = create_new_object(797)
            set_item_flag(18, var_0013)
            var_0009 = set_object_quality(var_0010, var_0013)
            get_object_frame(var_0013, 4)
            var_0009 = give_last_created(var_0011)
            var_0014 = delayed_execute_usecode_array(1, 1783, {17493, 17443, 7724}, var_0013)
            var_0002 = find_nearby(8, 80, -1, get_npc_name(-356))
            for var_0015 in ipairs(var_0002) do
                var_0006 = get_object_shape(var_0005)
                if not (var_0006 == 721 or var_0006 == 989) then
                    if get_alignment(var_0005) == var_000C then
                        set_alignment(2, var_0005)
                        set_schedule_type(0, var_0005)
                    end
                end
            end
        else
            kill_npc(objectref)
            var_0002 = find_nearby(8, 80, -1, get_npc_name(-356))
            for var_0017 in ipairs(var_0002) do
                var_0006 = get_object_shape(var_0005)
                if not (var_0006 == 721 or var_0006 == 989) then
                    if get_alignment(var_0005) == var_000C then
                        set_alignment(2, var_0005)
                        set_schedule_type(0, var_0005)
                    end
                end
            end
        end
    end
end