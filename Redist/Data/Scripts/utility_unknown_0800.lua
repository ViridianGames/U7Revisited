--- Best guess: Locks a door (type 828) if not blocked, setting behavior flags.
---@param objectref integer The door object reference to lock
---@return boolean success True if the door was locked successfully, false if blocked
function utility_unknown_0800(objectref)
    local var_0000, var_0001

    var_0000 = objectref
    var_0001 = get_door_state(var_0000) --- Guess: Gets door state
    if var_0001 == 1 then
        if not check_door_blocked(7, 0, 0, 0, 828, var_0000) then --- Guess: Checks door blockage
            set_object_behavior(objectref, 31) --- Guess: Sets item behavior
        else
            utility_unknown_0792(objectref) --- External call to display blocked message
            return false
        end
    elseif var_0001 == 0 then
        if not check_door_blocked(7, 0, 0, 1, 828, var_0000) then --- Guess: Checks door blockage
            set_object_behavior(objectref, 30) --- Guess: Sets item behavior
        else
            utility_unknown_0792(objectref) --- External call to display blocked message
            return false
        end
    end
    return true
end