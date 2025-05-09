--- Best guess: Manages a dungeon trap, checking nearby items (type 981) and applying effects to items (type 275, quality 50) when event ID 3 is triggered.
function func_06D6(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 3 then
        var_0000 = unknown_0035H(0, 1, 981, itemref)
        var_0001 = {}
        for i = 1, #var_0000 do
            var_0004 = var_0000[i]
            var_0001 = unknown_0019H(var_0001, itemref, var_0004)
        end
        var_0000 = unknown_093DH(var_0001, var_0000)
        if unknown_082EH(var_0000[1]) then
            var_0005 = unknown_0035H(16, 20, 275, itemref)
            for i = 1, #var_0005 do
                var_0008 = var_0005[i]
                if unknown_0014H(var_0008) == 50 then
                    unknown_006FH(var_0008)
                end
            end
        end
    end
    return
end