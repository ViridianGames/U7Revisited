--- Best guess: Manages a dungeon forge egg, spawning mages, dragons, or golems based on item quality and container contents, with specific flag checks.
--- Quality 1 now finds or creates the shape 154 mage and stores scroll 797 (quality 240, frame 4) on him. That scroll marks him as Erethian.
function utility_forge_0419(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_001A, var_001B, var_001C, var_001D, var_001E

    if eventid ~= 3 then
        return
    end
    -- This shared Forge egg dispatches by quality. Qualities 1 and 2 restore
    -- the marked mages; later qualities create quest creatures and markers.
    var_0000 = get_object_quality(objectref)
    if var_0000 == 1 and not get_flag(750) then
        var_0001 = false
        var_0002 = find_nearby(objectref, 154, 80, 8)
        -- Check each nearby mage; the old decompile tested the unset var_0005.
        if var_0002 then
            for _, mage in ipairs(var_0002) do
                if get_cont_items(mage, 797, 240, 4) then
                    var_0001 = mage
                    break
                end
            end
        end
        if not var_0001 then
            var_0006 = find_nearest(objectref, 154, 1)
            if not var_0006 then
                -- The translated fn_08EB/position helper path aborted before
                -- creating anything in U7R, so create its shape 154 mage here.
                local pos = get_object_position(objectref)
                var_0006 = create_new_object(154)
                if var_0006 and pos then
                    update_last_created(pos)
                end
            end
            if var_0006 then
                -- Original Func06A3: UI_set_schedule_type(mage, sleep/loiter/sit).
                -- Do not reverse args; first is the world object, not NPC 11/14/16.
                -- C++ die_roll is (num_dice, num_sides); decompiler emitted (6, 1) = 6d1.
                var_000A = die_roll(1, 6)
                if var_000A == 1 then
                    set_schedule_type(var_0006, 14)
                elseif var_000A >= 2 and var_000A <= 4 then
                    set_schedule_type(var_0006, 11)
                elseif var_000A >= 5 then
                    set_schedule_type(var_0006, 16)
                end
                var_000B = create_new_object(797)
                -- C++ setters are (object, value); decompiler emitted (value, object).
                set_item_flag(var_000B, 18)
                var_0009 = set_object_quality(var_000B, 240)
                set_object_frame(var_000B, 4)
                -- This mage is a plain shape, and this call stores the scroll on him.
                var_0009 = move_object_to_container(var_000B, var_0006)
                var_000C = delayed_execute_usecode_array(3, 1783, {17493, 17443, 7724}, var_000B)
            end
        end
    elseif var_0000 == 2 and not get_flag(751) then
        var_0001 = false
        var_0002 = find_nearby(8, 80, 504, objectref)
        for i = 1, 5 do
            if get_cont_items(4, 241, 797, var_0005) then
                var_0001 = var_0005
                break
            end
        end
        if not var_0001 then
            var_0006 = find_nearest(1, 504, objectref)
            if not var_0006 then
                if not is_not_blocked(19, 504, get_object_position(objectref)) then
                    utility_position_1003(19, 504, objectref)
                end
                var_0007 = get_object_position(objectref)[-359][0]
                var_0008 = find_nearby(16, 0, 275, var_0007)
                var_0009 = execute_usecode_array(8520, var_0008)
                var_0009 = execute_usecode_array(1699, {17493, 7724}, objectref)
            else
                set_schedule_type(var_0006, 15)
                set_object_frame(var_0006, 19)
                set_item_flag(var_0006, 18)
                var_000F = create_new_object(797)
                set_item_flag(var_000F, 18)
                var_0009 = set_object_quality(var_000F, 241)
                set_object_frame(var_000F, 4)
                var_0009 = give_last_created(var_0006)
                var_000C = delayed_execute_usecode_array(3, 1783, {17493, 17443, 7724}, var_000F)
            end
        end
    elseif var_0000 == 4 and not get_flag(753) and get_flag(795) then
        var_0001 = false
        var_0002 = find_nearby(8, 80, 1015, objectref)
        for i = 1, 5 do
            if get_cont_items(4, 243, 797, var_0005) then
                var_0001 = var_0005
                break
            end
        end
        if not var_0001 then
            var_0006 = find_nearest(1, 1015, objectref)
            if not var_0006 then
                if not is_not_blocked(16, 1015, get_object_position(objectref)) then
                    utility_position_1003(16, 1015, objectref)
                end
                var_0007 = get_object_position(objectref)[-359][0]
                var_0008 = find_nearby(16, 0, 275, var_0007)
                var_0009 = execute_usecode_array(8520, var_0008)
                var_0009 = execute_usecode_array(1699, {17493, 7724}, objectref)
            else
                set_object_frame(var_0006, 16)
                if not get_flag(795) or not get_flag(796) or not get_flag(806) then
                    set_schedule_type(var_0006, 11)
                else
                    set_schedule_type(var_0006, 15)
                end
                var_0009 = give_last_created(var_0006)
                var_000C = delayed_execute_usecode_array(3, 1783, {17493, 17443, 7724}, var_0006)
                var_0009 = execute_usecode_array(2, {7769}, var_0006)
            end
        end
    elseif var_0000 == 5 and not get_flag(754) and not get_flag(796) then
        var_0001 = false
        var_0002 = find_nearby(8, 80, 1015, objectref)
        for i = 1, 5 do
            if get_cont_items(4, 244, 797, var_0005) then
                var_0001 = var_0005
                break
            end
        end
        if not var_0001 then
            var_0006 = find_nearest(1, 1015, objectref)
            if not var_0006 then
                if not is_not_blocked(16, 1015, get_object_position(objectref)) then
                    utility_position_1003(16, 1015, objectref)
                end
                var_0007 = get_object_position(objectref)[-359][0]
                var_0008 = find_nearby(16, 0, 275, var_0007)
                var_0009 = execute_usecode_array(8520, var_0008)
                var_0009 = execute_usecode_array(1699, {17493, 7724}, objectref)
            else
                set_object_frame(var_0006, 16)
                if not get_flag(795) or not get_flag(796) or not get_flag(806) then
                    set_schedule_type(var_0006, 11)
                else
                    set_schedule_type(var_0006, 15)
                end
                set_item_flag(var_0006, 18)
                var_0012 = create_new_object(797)
                set_item_flag(var_0012, 18)
                var_0009 = set_object_quality(var_0012, 244)
                set_object_frame(var_0012, 4)
                var_0009 = give_last_created(var_0006)
                var_000C = delayed_execute_usecode_array(3, 1783, {17493, 17443, 7724}, var_0012)
                var_0009 = execute_usecode_array(2, {7769}, var_0006)
            end
        end
    elseif var_0000 == 6 then
        var_0015 = find_nearby(8, 10, 1, objectref)
        for i = 1, 5 do
            if get_object_shape(var_0018) == 504 and not get_cont_items(4, 241, 797, var_0018) then
                object_unknown_0504(objectref)
            end
        end
    elseif var_0000 == 7 and not get_flag(755) then
        var_0019 = 245
    elseif var_0000 == 8 and not get_flag(756) then
        var_0019 = 246
        var_001A = 4
    elseif var_0000 == 9 and not get_flag(757) then
        var_0019 = 247
        var_001A = 4
    elseif var_0000 == 10 and not get_flag(758) then
        var_0019 = 248
    elseif var_0000 == 11 and not get_flag(759) then
        var_0019 = 249
        var_001A = 4
    elseif var_0000 == 12 and not get_flag(760) then
        var_0019 = 250
    elseif var_0000 == 13 and not get_flag(761) then
        var_0019 = 251
    elseif var_0000 == 14 and not get_flag(762) then
        var_0019 = 252
    elseif var_0000 == 15 and not get_flag(763) then
        var_0019 = 253
    elseif var_0000 == 16 and not get_flag(764) then
        var_0019 = 254
    end
    if var_0019 then
        var_0002 = find_nearby(4, 80, 1015, objectref)
        for i = 1, 5 do
            if get_cont_items(4, var_0019, 797, var_0005) then
                var_0001 = var_0005
                break
            end
        end
        if not var_0001 then
            var_0006 = find_nearest(1, 1015, objectref)
            if not var_0006 then
                if not is_not_blocked(16, 1015, get_object_position(objectref)) then
                    utility_position_1003(16, 1015, objectref)
                end
                var_0007 = get_object_position(objectref)[-359][0]
                var_0008 = find_nearby(16, 0, 275, var_0007)
                var_0009 = execute_usecode_array(8520, var_0008)
                var_0009 = execute_usecode_array(1699, {17493, 7724}, objectref)
            else
                set_object_frame(var_0006, 0)
                set_item_flag(var_0006, 18)
                var_001D = execute_usecode_array(var_001A or 0, {7769}, var_0006)
                set_alignment(2, var_0006)
                var_0012 = create_new_object(797)
                set_item_flag(var_0012, 18)
                var_0009 = set_object_quality(var_0012, var_0019)
                set_object_frame(var_0012, 4)
                var_0009 = give_last_created(var_0006)
                var_000C = delayed_execute_usecode_array(3, 1783, {17493, 17443, 7724}, var_0012)
            end
        end
    end
    return
end