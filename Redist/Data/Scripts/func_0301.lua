--- Best guess: Manages a smokebomb, creating a smoke effect at the player’s location and affecting nearby NPCs.
function func_0301(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 or eventid == 4 then
        unknown_007EH()
        var_0000 = unknown_0035H(0, 300, 494, itemref)
        for var_0001 in ipairs(var_0000) do
            unknown_001DH(0, var_0003)
            unknown_004BH(7, var_0003)
            unknown_004CH(-356, var_0003)
        end
        var_0004 = unknown_0018H(itemref)
        unknown_005CH(itemref)
        unknown_0053H(25, 0, 0, 0, var_0004[2], var_0004[1], 3)
        unknown_0053H(25, 1, 0, 2, var_0004[2], var_0004[1], 3)
        unknown_0053H(25, 2, 0, -2, var_0004[2], var_0004[1], 3)
        unknown_0053H(25, 3, 2, 0, var_0004[2], var_0004[1], 3)
        unknown_0053H(25, 4, -2, 0, var_0004[2], var_0004[1], 3)
        unknown_0053H(25, 1, 2, 2, var_0004[2], var_0004[1], 3)
        unknown_0053H(25, 2, -2, 2, var_0004[2], var_0004[1], 3)
        unknown_0053H(25, 3, 2, -2, var_0004[2], var_0004[1], 3)
        unknown_0053H(25, 4, -2, -2, var_0004[2], var_0004[1], 3)
        unknown_006FH(itemref)
    end
end