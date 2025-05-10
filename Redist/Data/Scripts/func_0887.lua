--- Best guess: Performs complex item manipulation and explosion creation, possibly for combat or traps.
function func_0887(eventid, objectref, positions1, positions2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F

    var_0003 = false
    var_0004 = false
    var_0005 = false
    var_0006 = false
    var_0007 = false
    var_0008 = false
    var_0009 = false
    var_000A = false
    var_000B = false
    if positions1[1] ~= positions2[1] or positions1[2] ~= positions2[2] then
        var_0003 = true
    else
        if positions1[1] < positions2[1] then
            positions2[1] = positions2[1] - 1
            var_0004 = true
        elseif positions1[1] > positions2[1] then
            positions2[1] = positions2[1] + 1
            var_0005 = true
        end
    end
    if positions1[2] ~= positions2[2] then
        if positions1[2] < positions2[2] then
            if var_0004 then
                positions2[2] = positions2[2] - 1
                var_0008 = true
                var_0004 = false
            elseif var_0005 then
                positions2[1] = positions2[1] - 1
                var_000A = true
                var_0005 = false
            else
                var_0006 = true
            end
        elseif positions1[2] > positions2[2] then
            if var_0004 then
                positions2[2] = positions2[2] + 1
                var_0009 = true
                var_0004 = false
            elseif var_0005 then
                positions2[1] = positions2[1] + 1
                var_000B = true
                var_0005 = false
            else
                var_0007 = true
            end
        end
    end
    if var_0003 then
        create_explosion(-1, 0, 0, 0, positions2[2] - 1, positions2[1] - 1, 4) --- Guess: Creates explosion
        unknown_000FH(9) --- Guess: Unknown function
        var_000C = set_object_type(275, objectref) --- Guess: Sets item type
        set_object_frame(6, var_000C) --- Guess: Sets item frame
        set_object_flag(18, var_000C, true) --- Guess: Sets item flag
        var_000D = set_object_quality(151, var_000C) --- Guess: Sets item quality
        var_000D = update_position(positions2) --- Guess: Updates position
        calle_0888H(var_000C) --- External call to item processing
        unknown_006FH(var_000C) --- Guess: Unknown function, possibly removes item
        unknown_006FH(eventid) --- Guess: Unknown function, possibly removes item
        destroyobject_(objectref) --- Guess: Destroys item
        add_containerobject_s(objectref, {1800, 17493, 7715}) --- Guess: Adds items to container
        return 0
    end
    if not var_0004 and not var_0005 then
        var_000F = random(-1, 1) --- Guess: Generates random number
        positions2[2] = positions2[2] + var_000F
    end
    if not var_0006 and not var_0007 then
        var_000F = random(-1, 1) --- Guess: Generates random number
        positions2[1] = positions2[1] + var_000F
    end
    if var_000A then
        if random(1, 3) == 1 then
            positions2[2] = positions2[2] + 1
        elseif random(1, 3) == 2 then
            positions2[1] = positions2[1] - 1
        end
    end
    if var_0008 then
        if random(1, 3) == 1 then
            positions2[2] = positions2[2] + 1
        elseif random(1, 3) == 2 then
            positions2[1] = positions2[1] + 1
        end
    end
    if var_000B then
        if random(1, 3) == 1 then
            positions2[2] = positions2[2] - 1
        elseif random(1, 3) == 2 then
            positions2[1] = positions2[1] - 1
        end
    end
    if var_0009 then
        if random(1, 3) == 1 then
            positions2[2] = positions2[2] - 1
        elseif random(1, 3) == 2 then
            positions2[1] = positions2[1] + 1
        end
    end
    return positions2
end