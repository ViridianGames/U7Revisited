--- Best guess: Moves an item to a new location with offset, checking position and container validity.
function func_0837(eventid, itemref, arg1, arg2, arg3, arg4)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    var_0000 = eventid
    var_0001 = arg1
    var_0002 = arg2
    var_0003 = arg3
    var_0004 = arg4
    var_0005 = unknown_0018H(var_0003) --- Guess: Gets position data
    var_0005[1] = var_0005[1] + var_0002
    var_0005[2] = var_0005[2] + var_0001
    var_0005[3] = var_0005[3] + var_0000
    var_0006 = get_item_container(itemref) --- Guess: Gets item container
    var_0007 = unknown_0018H(itemref) --- Guess: Gets position data
    var_0008 = unknown_0025H(itemref) --- Guess: Checks position
    if spawn_item_at(get_item_type(itemref), var_0005) then --- Guess: Spawns item at position
        if not var_0008 then
            unknown_0026H(var_0005) --- Guess: Updates position
            unknown_000FH(73) --- Guess: Triggers event
            return 1
        elseif not var_0006 then
            if not get_item_position(var_0006) then --- Guess: Gets item position
                return 0
            end
        elseif unknown_0026H(var_0007) then --- Guess: Updates position
            return 0
        end
    end
    return 0
end