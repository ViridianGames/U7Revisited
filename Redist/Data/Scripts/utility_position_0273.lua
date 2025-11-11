--- Best guess: Transforms an item's type (e.g., 515 to 870 or back) based on position data, possibly for dynamic object state changes.
function utility_position_0273(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = get_object_shape(objectref) --- Guess: Gets item type
    if var_0000 == 515 then
        var_0001 = 870
        var_0002 = 7
    else
        var_0001 = 515
        var_0002 = -7
    end
    var_0003 = get_object_position(objectref) --- Guess: Gets position data
    var_0003[2] = var_0003[2] + var_0002
    -- Placeholder for unknown opcode 46H
    set_object_shape(objectref, var_0001) --- Guess: Sets item type
    if not set_last_created(objectref) then --- Guess: Checks position
        var_0004 = update_last_created(var_0003) --- Guess: Updates position
    end
end