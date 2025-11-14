--- Best guess: Validates an NPC ID, ensuring it's within a valid range or returning its owner.
function utility_unknown_1081(arg1)
    local var_0000, var_0001

    var_0000 = arg1
    if var_0000 < 0 and var_0000 >= 356 then
        var_0001 = get_object_owner(var_0000) --- Guess: Gets item owner
    else
        var_0001 = var_0000
    end
    return var_0001
end