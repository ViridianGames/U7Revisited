--- Best guess: Checks if the player’s position is within specific coordinate bounds, likely for triggering a quest or event.
function func_08E7()
    local var_0000, var_0001, var_0002

    var_0000 = unknown_0018H(-356)
    var_0001 = {1392, 1936}
    var_0002 = {1743, 2495}
    if var_0000[1] >= var_0001[1] and var_0000[2] >= var_0001[2] and var_0000[1] <= var_0002[1] and var_0000[2] <= var_0002[2] then
        return 1
    end
    return 0
end