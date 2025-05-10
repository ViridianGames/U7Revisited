--- Best guess: Evaluates training ability, checking gold and training level caps, returning 0 (insufficient experience), 1 (insufficient gold), 2 (maxed out), or 3 (can train).
function func_0922(eventid, objectref, arg1, arg2, arg3, arg4)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    var_0004 = false
    var_0005 = get_training_level(7, arg2) --- Guess: Gets training level
    var_0006 = check_object_ownership(359, 644, 359, 357) --- Guess: Checks item ownership
    if var_0006 <= arg3 then
        return 1
    end
    if var_0005 < arg1 then
        return 0
    end
    for _, var_0009 in ipairs({7, 8, 9, 3}) do
        var_000A = get_training_level(var_0009, arg2) --- Guess: Gets training level
        if var_000A < 30 then
            var_0004 = true
        end
    end
    if not var_0004 then
        return 2
    end
    return 3
end