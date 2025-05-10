--- Best guess: Locks a door (type 828) if not blocked, setting behavior flags.
function func_0820(eventid, objectref)
    local var_0000, var_0001

    var_0000 = objectref
    var_0001 = get_door_state(var_0000) --- Guess: Gets door state
    if var_0001 == 1 then
        if not check_door_blocked(7, 0, 0, 0, 828, var_0000) then --- Guess: Checks door blockage
            set_object_behavior(objectref, 31) --- Guess: Sets item behavior
        else
            calle_0818H() --- External call to display blocked message
            return false
        end
    elseif var_0001 == 0 then
        if not check_door_blocked(7, 0, 0, 1, 828, var_0000) then --- Guess: Checks door blockage
            set_object_behavior(objectref, 30) --- Guess: Sets item behavior
        else
            calle_0818H() --- External call to display blocked message
            return false
        end
    end
    return true
end