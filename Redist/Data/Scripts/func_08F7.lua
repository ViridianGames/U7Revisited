--- Best guess: Checks if an NPC is in the player’s party and not affected by a specific status, returning true if both conditions are met, false otherwise.
function func_08F7(var_0000)
    local var_0001, var_0002

    var_0001 = unknown_001BH(var_0000)
    var_0002 = unknown_002FH(var_0001)
    if unknown_0088H(0, var_0001) then
        var_0002 = false
    end
    return var_0002
end