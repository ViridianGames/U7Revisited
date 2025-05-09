--- Best guess: Interacts with container items (type 377), randomly selecting and using items based on position checks.
function func_0627(eventid, itemref)
    local var_0000, var_0001, var_0002

    var_0000 = unknown_0035H(0, 3, 513, itemref) --- Guess: Sets NPC location
    var_0001 = get_container_items(itemref, 359, 377, 359) --- Guess: Gets container items
    if var_0001 then
        var_0002 = unknown_0025H(var_0001[1]) --- Guess: Checks position
        if var_0002 and var_0000 then
            var_0002 = unknown_0036H(var_0000[1]) --- Guess: Uses container item
        end
        if random(1, 2) == 1 and var_0001[2] ~= 0 then
            var_0002 = unknown_0025H(var_0001[2]) --- Guess: Checks position
            if var_0002 and var_0000 then
                var_0002 = unknown_0036H(var_0000[1]) --- Guess: Uses container item
            end
        end
    end
    if var_0000 and random(1, 2) == 1 then
        var_0001 = unknown_0035H(0, 10, 377, 1) --- Guess: Sets NPC location
        if var_0001 then
            var_0002 = unknown_0025H(var_0001[1]) --- Guess: Checks position
            if not var_0002 then
                var_0002 = unknown_0036H(var_0001[1]) --- Guess: Uses container item
            end
        end
    end
end