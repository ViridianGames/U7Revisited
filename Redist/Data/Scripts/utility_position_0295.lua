--- Best guess: Interacts with container items (type 377), randomly selecting and using items based on position checks.
function utility_position_0295(eventid, objectref)
    local var_0000, var_0001, var_0002

    var_0000 = find_nearby(0, 3, 513, objectref) --- Guess: Sets NPC location
    var_0001 = get_containerobject_s(objectref, 359, 377, 359) --- Guess: Gets container items
    if var_0001 then
        var_0002 = set_last_created(var_0001[1]) --- Guess: Checks position
        if var_0002 and var_0000 then
            var_0002 = give_last_created(var_0000[1]) --- Guess: Uses container item
        end
        if random(1, 2) == 1 and var_0001[2] ~= 0 then
            var_0002 = set_last_created(var_0001[2]) --- Guess: Checks position
            if var_0002 and var_0000 then
                var_0002 = give_last_created(var_0000[1]) --- Guess: Uses container item
            end
        end
    end
    if var_0000 and random(1, 2) == 1 then
        var_0001 = find_nearby(0, 10, 377, 1) --- Guess: Sets NPC location
        if var_0001 then
            var_0002 = set_last_created(var_0001[1]) --- Guess: Checks position
            if not var_0002 then
                var_0002 = give_last_created(var_0001[1]) --- Guess: Uses container item
            end
        end
    end
end