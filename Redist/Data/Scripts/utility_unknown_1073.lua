--- Best guess: Checks if a party has sufficient items of a specific type, returning true if the condition is met.
function utility_unknown_1073(eventid, objectref, arg1, arg2, arg3, arg4)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0005 = check_object_ownership(arg1, arg2, arg3, arg4) --- Guess: Checks item ownership
    if var_0005 >= arg4 then
        return true
    end
    return false
end