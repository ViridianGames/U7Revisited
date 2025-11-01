--- Best guess: Improves an NPC's combat skill training level based on strength and dexterity.
function utility_unknown_1047(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0002 = 0
    while var_0002 < arg1 do
        var_0003 = get_training_level(1, arg2) --- Guess: Gets training level
        var_0004 = get_training_level(4, arg2) --- Guess: Gets training level
        var_0005 = (var_0004 + var_0003 + 1) / 2
        if var_0005 >= var_0003 then
            var_0004 = var_0004 + 1
            if var_0004 >= 30 then
                var_0004 = 30
            end
            var_0005 = var_0004
        end
        set_training_level(4, arg2, var_0005 - var_0004) --- Guess: Sets training level
        set_training_level(7, arg2, -1) --- Guess: Sets training level
        var_0002 = var_0002 + 1
    end
end