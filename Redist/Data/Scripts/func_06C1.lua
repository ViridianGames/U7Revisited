--- Best guess: Manages a complex dungeon sequence, checking flags and applying effects to items (types 867, 338, 810, 912) and NPCs (167, 177) based on timers and conditions.
function func_06C1(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010

    if eventid == 3 then
        if get_flag(343) and not get_flag(404) then
            unknown_003FH(246)
            var_0000 = unknown_0035H(0, 15, 867, itemref)
            var_0001 = unknown_0035H(0, 15, 338, itemref)
            var_0002 = unknown_0035H(0, 15, 810, itemref)
            var_0003 = unknown_0035H(176, 15, 912, itemref)
            var_0004 = {var_0000, var_0001, var_0002, var_0003}
            for i = 1, #var_0004 do
                var_0007 = var_0004[i]
                var_0008 = unknown_0011H(var_0007)
                var_0009 = unknown_0018H(var_0007)
                if var_0009[3] == 6 then
                    if var_0008 == 867 or var_0008 == 912 then
                        var_000A = {1, var_0009[2], var_0009[1]}
                    else
                        var_000A = {0, var_0009[2], var_0009[1]}
                    end
                    var_000B = unknown_0025H(var_0007)
                    if not var_000B then
                        var_000B = unknown_0026H(var_000A)
                    end
                end
            end
            var_000C = unknown_0035H(0, 40, 400, itemref)
            var_000C = var_000C[unknown_0035H(0, 40, 414, itemref)]
            for i = 1, #var_000C do
                var_000F = var_000C[i]
                if unknown_0014H(var_000F) == 1 and unknown_0016H(var_000F, 1) == 118 then
                    unknown_006FH(var_000F)
                end
            end
            set_flag(404, true)
            unknown_0066H(6)
        elseif not get_flag(343) then
            var_0010 = unknown_0065H(6)
            if var_0010 >= 24 then
                unknown_080FH()
                unknown_006FH(itemref)
            end
        end
    end
    return
end