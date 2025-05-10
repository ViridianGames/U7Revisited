--- Best guess: Manages a game mechanic checking for items (IDs 604, 729) and transforming a container (ID 641) with specific effects and sound.
function func_070C(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0000 = unknown_000EH(1, 604, itemref)
    if not var_0000 then
        var_0001 = unknown_000EH(8, 729, itemref)
        if not var_0001 then
            var_0002 = _get_object_quality(var_0001)
            if var_0002 == 7 then
                var_0003 = unknown_0018H(var_0001)
                unknown_006FH(var_0001)
                unknown_006FH(var_0000)
                var_0004 = unknown_0024H(641)
                get_object_frame(var_0004, 30)
                var_0005 = unknown_0015H(66, var_0004)
                var_0005 = unknown_0026H(var_0003)
                unknown_0053H(-1, 0, 0, 0, var_0003[2] - 2, var_0003[1] - 1, 13)
                unknown_000FH(37)
            end
        end
    end
end