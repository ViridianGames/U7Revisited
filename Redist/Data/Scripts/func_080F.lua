--- Best guess: Clears specific items (IDs 867, 338, 336, 810, 912, 636, 168) within a radius when triggered by event 3.
function func_080F(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    if eventid == 3 then
        var_0000 = unknown_0035H(0, 15, 867, itemref)
        var_0001 = unknown_0035H(0, 15, 338, itemref)
        var_0002 = unknown_0035H(0, 15, 336, itemref)
        var_0003 = unknown_0035H(176, 15, 810, itemref)
        var_0004 = unknown_0035H(128, 15, 912, itemref)
        var_0005 = unknown_0035H(0, 15, 636, itemref)
        var_0006 = unknown_0035H(176, 15, 168, itemref)
        var_0007 = {var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006}
        for var_0008 in ipairs(var_0007) do
            unknown_006FH(var_000A)
        end
    end
end