--- Best guess: Checks for items (type 414) within a specific area, likely for puzzle or ritual validation.
function utility_unknown_0788(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0000 = {}
    var_0001 = find_nearby(0, 40, 414, 356) --- Guess: Sets NPC location
    -- Guess: sloop checks item positions
    for i = 1, 5 do
        var_0004 = {2, 3, 4, 1, 111}[i]
        var_0005 = get_object_position(var_0004) --- Guess: Gets position data
        if var_0005[1] >= 2487 - 8 and var_0005[1] <= 2487 + 8 and var_0005[2] >= 1736 - 8 and var_0005[2] <= 1736 + 8 and (get_object_frame(var_0004) == 4 or get_object_frame(var_0004) == 5) then
            table.insert(var_0000, var_0004)
        end
    end
    return var_0000
end