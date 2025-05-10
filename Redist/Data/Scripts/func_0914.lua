--- Best guess: Initializes training levels for an NPC (properties 0 and 3).
function func_0914(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002

    var_0002 = 0
    while var_0002 < arg1 do
        set_training_level(0, arg2, 1) --- Guess: Sets training level
        set_training_level(3, arg2, 1) --- Guess: Sets training level
        set_training_level(7, arg2, -1) --- Guess: Sets training level
        var_0002 = var_0002 + 1
    end
end