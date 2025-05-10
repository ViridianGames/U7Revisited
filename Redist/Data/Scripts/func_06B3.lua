--- Best guess: Triggers external functions (IDs 338, 701, 526) for party members when event ID 3 is received, likely part of a dungeon environmental effect.
function func_06B3(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 3 then
        unknown_000FH(28)
        var_0000 = unknown_0014H(objectref)
        var_0001 = unknown_0035H(0, var_0000, 338, objectref)
        for i = 1, #var_0001 do
            var_0004 = var_0001[i]
            unknown_0152H(var_0004)
        end
        var_0001 = unknown_0035H(0, var_0000, 701, objectref)
        for i = 1, #var_0001 do
            var_0004 = var_0001[i]
            unknown_02BDH(var_0004)
        end
        var_0001 = unknown_0035H(0, var_0000, 526, objectref)
        for i = 1, #var_0001 do
            var_0004 = var_0001[i]
            unknown_020EH(var_0004)
        end
    end
    return
end