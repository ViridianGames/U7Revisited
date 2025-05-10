--- Best guess: Manages a dungeon sequence, checking flag 87 and applying effects to items (type 912) and NPCs (414) based on their frames and timers.
function func_06C2(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 3 then
        if not get_flag(87) then
            unknown_080FH()
            var_0000 = unknown_0035H(176, 60, 912, objectref)
            for i = 1, #var_0000 do
                var_0003 = var_0000[i]
                var_0004 = unknown_0025H(var_0003)
                if not var_0004 then
                    var_0004 = unknown_0026H(358)
                end
            end
            var_0005 = unknown_0035H(0, 80, 414, objectref)
            for i = 1, #var_0005 do
                var_0008 = var_0005[i]
                var_0009 = unknown_0012H(var_0008)
                if var_0009 > 20 then
                    var_0004 = unknown_0025H(var_0008)
                    if not var_0004 then
                        var_0004 = unknown_0026H(358)
                    end
                end
            end
            unknown_006FH(objectref)
        end
    end
    return
end