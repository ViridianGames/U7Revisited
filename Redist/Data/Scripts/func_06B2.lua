--- Best guess: Triggers external functions (IDs 336, 595, 889) for party members when event ID 3 is received, likely part of a dungeon environmental effect.
function func_06B2(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 3 then
        unknown_000FH(28)
        var_0000 = unknown_0014H(itemref)
        var_0001 = unknown_0035H(0, var_0000, 336, itemref)
        for i = 1, #var_0001 do
            var_0004 = var_0001[i]
            unknown_0150H(var_0004)
        end
        var_0001 = unknown_0035H(0, var_0000, 595, itemref)
        for i = 1, #var_0001 do
            var_0004 = var_0001[i]
            unknown_0253H(var_0004)
        end
        var_0001 = unknown_0035H(0, var_0000, 889, itemref)
        for i = 1, #var_0001 do
            var_0004 = var_0001[i]
            unknown_0379H(var_0004)
        end
    end
    return
end