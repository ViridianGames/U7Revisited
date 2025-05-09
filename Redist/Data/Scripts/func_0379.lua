--- Best guess: Manages a lamppost, toggling its state (on/off) and changing its type if specific conditions are met.
function func_0379(eventid, itemref)
    local var_0000, var_0001

    if eventid == 1 or eventid == 2 then
        var_0000 = unknown_0024H(440) --- Guess: Checks a condition in an area
        if var_0000 then
            var_0001 = unknown_0018H(itemref) --- Guess: Retrieves object position or attributes
            var_0001[1] = var_0001[1] + 3
            var_0001[2] = var_0001[2] + 3
            set_object_frame(var_0000, random(0, 7))
            if not unknown_0026H(var_0001) then --- Guess: Validates a position
                set_object_shape(itemref, 526)
                set_object_quality(itemref, 106)
            end
        end
    end
end