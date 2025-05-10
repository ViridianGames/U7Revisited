--- Best guess: Initializes multiple training levels for an NPC (properties 2 and 7).
function func_0916(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003

    var_0002 = 0
    while var_0002 < arg1 do
        var_0003 = get_training_level(2, arg2) --- Guess: Gets training level
        set_training_level(2, arg2, 1) --- Guess: Sets training level
        set_training_level(7, arg2, -1) --- Guess: Sets training level
        var_0002 = var_0002 + 1
    end
end