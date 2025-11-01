--- Best guess: Handles door locking/unlocking based on quality and flag states, with item spawning.
function utility_unknown_0790(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_001A, var_001B, var_001C, var_001D, var_001E, var_001F, var_0020, var_0021

    var_0000 = objectref
    var_0001 = false
    var_0002 = get_object_quality(var_0000) --- Guess: Gets item quality
    if var_0002 == 0 then
        var_0003 = create_array(526) --- Guess: Creates array
        -- Guess: sloop sets item types
        for i = 1, 5 do
            var_0006 = {4, 5, 6, 3, 138}[i]
            set_object_type(889, var_0006) --- Guess: Sets item type
            var_0007 = find_nearby(128, 10, 440, var_0006) --- Guess: Sets NPC location
            var_0008 = get_object_position(var_0006) --- Guess: Gets position data
            var_0009 = {var_0008[3], var_0008[2] + 3, var_0008[1] + 3}
            -- Guess: sloop checks item positions
            for i = 1, 5 do
                var_000C = {10, 11, 12, 7, 52}[i]
                var_000D = get_object_position(var_000C) --- Guess: Gets position data
                if var_0009[1] == var_000D[1] and var_0009[2] == var_000D[2] then
                    destroy_object_silent(var_000C) --- Guess: Destroys item silently
                end
            end
        end
        var_0003 = create_array(889) --- Guess: Creates array
        -- Guess: sloop creates items
        for i = 1, 5 do
            var_0006 = {14, 15, 6, 3, 75}[i]
            set_object_type(526, var_0006) --- Guess: Sets item type
            var_0007 = get_object_status(440) --- Guess: Gets item status
            if not var_0007 then
                var_0008 = get_object_position(var_0006) --- Guess: Gets position data
                var_0001 = update_last_created({var_0008[3], var_0008[2] + 3, var_0008[1] + 3}) --- Guess: Updates position
            end
        end
        var_0001 = true
    end
    if var_0002 >= 1 and var_0002 < 251 then
        var_0010 = find_nearby(0, 80, 845, var_0000) --- Guess: Sets NPC location
        var_0010 = find_nearby(0, 80, 828, var_0000) --- Guess: Sets NPC location
        -- Guess: sloop handles door locking/unlocking
        for i = 1, 5 do
            var_0013 = {17, 18, 19, 16, 52}[i]
            if get_object_quality(var_0013) == var_0002 then
                if get_object_type(var_0013) == 845 then
                    var_0001 = lock_door(var_0013) --- Guess: Locks door
                else
                    var_0001 = unlock_door(var_0013) --- Guess: Unlocks door
                end
            end
        end
    elseif var_0002 == 251 then
        if not get_flag(740) then
            var_0014 = {1, 0, 0}
        end
        if not get_flag(741) then
            var_0014 = {0, 0, 1}
        end
        if not get_flag(742) then
            var_0014 = {0, 1, 0}
        end
        if not get_flag(740) and not get_flag(741) and not get_flag(742) then
            var_0014 = {1, 0, 0}
        end
        utility_unknown_0791(var_0014) --- External call to update door states
        var_0001 = true
    elseif var_0002 == 253 then
        if not get_flag(740) then
            var_0014 = {1, 0, 0}
        end
        if not get_flag(741) then
            var_0014 = {0, 0, 1}
        end
        if not get_flag(742) then
            var_0014 = {0, 1, 0}
        end
        if not get_flag(740) and not get_flag(741) and not get_flag(742) then
            var_0014 = {0, 0, 1}
        end
        utility_unknown_0791(var_0014) --- External call to update door states
        var_0001 = true
    elseif var_0002 == 252 then
        var_0001 = false
        var_0015 = 0
        if not get_flag(740) then
            var_0015 = 230
        end
        if not get_flag(741) then
            var_0015 = 220
        end
        if not get_flag(742) then
            var_0015 = 210
        end
        var_0010 = find_nearby(0, 60, 828, var_0000) --- Guess: Sets NPC location
        -- Guess: sloop checks door qualities
        for i = 1, 5 do
            var_0013 = {22, 23, 19, 16, 57}[i]
            var_0018 = get_object_quality(var_0013) --- Guess: Gets item quality
            if var_0018 == 230 or var_0018 == 220 or var_0018 == 210 or var_0018 ~= var_0015 then
                var_0001 = unlock_door(var_0013) --- Guess: Unlocks door
            end
        end
        var_0019 = get_object_position(var_0000) --- Guess: Gets position data
        var_0010 = find_nearby(0, 60, 845, var_0019) --- Guess: Sets NPC location
        var_001A = find_nearby(0, 60, 949, var_0019) --- Guess: Sets NPC location
        -- Guess: sloop handles door locking
        for i = 1, 5 do
            var_0013 = {27, 28, 19, 16, 26}[i]
            if get_object_quality(var_0013) == var_0015 then
                var_0001 = lock_door(var_0013) --- Guess: Locks door
            end
        end
        -- Guess: sloop adds items for effect
        for i = 1, 5 do
            var_001F = {29, 30, 31, 26, 54}[i]
            if get_object_quality(var_001F) == var_0015 then
                var_0001 = add_containerobject_s(var_001F, {6, -1, 17419, 8014, 1, 8006, 32, 7768})
                var_0001 = true
            end
        end
        var_0020 = find_nearby(0, 12, 270, var_0000) --- Guess: Sets NPC location
        if var_0020 then
            object_door_0270(var_0020) --- External call to unknown function
        end
    end
    if not var_0001 then
        var_0021 = get_object_frame(var_0000) --- Guess: Gets item frame
        if var_0021 % 2 == 0 then
            set_object_frame(var_0000, var_0021 + 1) --- Guess: Sets item frame
        else
            set_object_frame(var_0000, var_0021 - 1) --- Guess: Sets item frame
        end
        set_object_behavior(objectref, 28) --- Guess: Sets item behavior
    else
        trigger_explosion(0) --- Guess: Triggers explosion
    end
end