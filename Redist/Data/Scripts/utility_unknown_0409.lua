--- Best guess: Aligns party members in a pattern around the Avatar, likely for a ritual or formation setup.
function utility_unknown_0409(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010

    var_0000 = get_object_position(objectref, 8, 6) --- Guess: Gets position data with array dimensions
    var_0001 = find_nearby(16, 40, 275, var_0000) --- Guess: Sets NPC location
    var_0002 = get_object_position(objectref, 9, 6) --- Guess: Gets position data with array dimensions
    var_0003 = find_nearby(16, 40, 275, var_0002) --- Guess: Sets NPC location
    if var_0001 and var_0003 then
        var_0004 = get_object_position(var_0001[1]) --- Guess: Gets position data
        var_0005 = get_object_position(var_0003[1]) --- Guess: Gets position data
        var_0006 = get_conversation_target() --- Guess: Gets conversation target
        move_object(var_0004, objectref) --- Guess: Sets NPC target
        move_object(var_0005, 356) --- Guess: Sets NPC target
        if not var_0006 then
            move_object(var_0005, var_0006) --- Guess: Sets NPC target
        end
        var_0007 = 1
        var_0008 = get_party_members()
        var_0009 = var_0005
        -- Guess: sloop aligns party members in a pattern
        for i = 1, 5 do
            var_000C = ({10, 11, 12, 8, 346})[i]
            if var_0007 == 1 then
                var_0009[1] = var_0009[1] - 2
                var_0009[2] = var_0009[2] + 2
            elseif var_0007 == 2 then
                var_0009[1] = var_0009[1] + 2
                var_0009[2] = var_0009[2] + 2
            elseif var_0007 == 3 then
                var_0009[1] = var_0009[1] - 4
                var_0009[2] = var_0009[2] + 4
            elseif var_0007 == 4 then
                var_0009[1] = var_0009[1] + 1
                var_0009[2] = var_0009[2] + 4
            elseif var_0007 == 5 then
                var_0009[1] = var_0009[1] + 4
                var_0009[2] = var_0009[2] + 4
            elseif var_0007 == 6 then
                var_0009[1] = var_0009[1] - 2
                var_0009[2] = var_0009[2] + 6
            elseif var_0007 == 7 then
                var_0009[1] = var_0009[1] + 2
                var_0009[2] = var_0009[2] + 6
            end
            if var_000C ~= 356 then
                move_object(var_0009, var_000C) --- Guess: Sets NPC target
                var_000D = add_containerobject_s(var_000C, {0, 7769})
                var_0007 = var_0007 + 1
            end
        end
        var_000E = add_containerobject_s(objectref, {1692, 8021, 2, 7975, 4, 7769})
        var_000F = add_containerobject_s(356, {0, 7769})
        if is_player_female() then --- Guess: Checks player gender
            var_0010 = add_containerobject_s(var_0006, {20, 7750})
        else
            var_0010 = add_containerobject_s(var_0006, {18, 7750})
        end
    end
end