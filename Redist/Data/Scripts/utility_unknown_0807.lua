--- Best guess: Sets an array value at a specific index, likely for state management.
function utility_unknown_0807(eventid, objectref, arg1)
    local var_0000, var_0001

    var_0000 = objectref
    var_0001 = arg1
    return set_array_value(var_0000, var_0001, var_0000[var_0001]) --- Guess: Sets array value
end