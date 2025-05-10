--- Best guess: Reorders array elements, possibly for position or state updates.
function func_0822(eventid, objectref)
    local var_0000, var_0001

    var_0000 = objectref
    var_0001 = var_0000
    var_0001[1] = var_0000[2]
    var_0001[2] = var_0000[3]
    var_0001[3] = var_0000[4]
    return var_0001
end