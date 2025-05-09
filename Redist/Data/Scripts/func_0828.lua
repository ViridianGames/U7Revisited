--- Best guess: Moves items (e.g., bucket contents) to a new location, handling arrays and positioning.
function func_0828(eventid, itemref, arg1, arg2, arg3, arg4, arg5, arg6)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    var_0000 = eventid
    var_0001 = itemref
    var_0002 = arg1
    var_0003 = arg2
    var_0004 = arg3
    var_0005 = arg4
    var_0006 = arg5
    if get_item_container(var_0006) then --- Guess: Gets item container
        trigger_explosion(0) --- Guess: Triggers explosion
        return
    end
    destroy_item(356) --- Guess: Destroys item
    var_0007 = unknown_0018H(var_0006) --- Guess: Gets position data
    if var_0005 < 0 and array_size(var_0005) == 1 then
        var_0008 = var_0003
        if var_0008 <= var_0007[3] then
            var_0009 = {var_0007[1], var_0007[2], var_0007[3] + var_0008}
            while var_0008 >= -var_0005 do
                while var_0008 >= -var_0004 do
                    move_item_to_location(var_0000, var_0001, var_0002, var_0009) --- Guess: Moves item to location
                    var_0008 = var_0008 - 1
                end
                var_000A = var_000A - 1
            end
        end
    else
        var_000C = 0
        -- Guess: sloop moves items based on arrays
        for i = 1, 5 do
            var_000C = var_000C + 1
            var_000B = var_0004[var_000C]
            var_0008 = var_0003[var_000C]
            var_0009 = {var_0007[1] + var_000A, var_0007[2] + var_000B, var_0007[3]}
            if var_0003 < -1 then
                var_0008 = 0
                while var_0008 >= var_0003 do
                    var_0009 = {var_0007[1], var_0007[2], var_0007[3] + var_0008}
                    move_item_to_location(var_0000, var_0001, var_0002, var_0009) --- Guess: Moves item to location
                    var_0008 = var_0008 - 1
                end
            else
                if var_0003 == -1 then
                    var_0009 = {var_0007[1], var_0007[2], var_0007[3]}
                else
                    var_0009 = {var_0007[1], var_0007[2], var_0007[3] + var_0008}
                end
                move_item_to_location(var_0000, var_0001, var_0002, var_0009) --- Guess: Moves item to location
            end
        end
    end
    trigger_explosion(0) --- Guess: Triggers explosion
end