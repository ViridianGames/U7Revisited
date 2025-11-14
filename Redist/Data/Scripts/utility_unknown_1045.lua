--- Best guess: Improves an NPC's dexterity training level based on strength.
function utility_unknown_1045(arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    var_0002 = 0
    while var_0002 < arg1 do
        var_0003 = get_training_level(1, arg2) --- Guess: Gets training level
        set_training_level(1, arg2, 1) --- Guess: Sets training level
        var_0004 = var_0003 + 1
        var_0005 = get_training_level(4, arg2) --- Guess: Gets training level
        var_0006 = (var_0004 * var_0005 + var_0003 - 1) / var_0003
        set_training_level(4, arg2, var_0006 - var_0005) --- Guess: Sets training level
        set_training_level(7, arg2, -1) --- Guess: Sets training level
        var_0002 = var_0002 + 1
    end
end