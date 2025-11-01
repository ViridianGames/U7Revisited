--- Best guess: Calls an unknown function with three arguments, possibly for NPC interaction or state modification.
function utility_unknown_1072(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002

    var_0002 = delayed_execute_usecode_array(1, arg1, arg2) --- Guess: Unknown function call
    return var_0002
end