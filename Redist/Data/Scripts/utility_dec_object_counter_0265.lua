--- Best guess: Decrements an item counter, possibly for tracking usage or state.
function utility_unknown_0265(eventid, objectref)
    local var_0000

    var_0000 = get_object_counter(objectref) - 1 --- Guess: Gets item counter
    set_object_counter(objectref, var_0000) --- Guess: Sets item counter
end