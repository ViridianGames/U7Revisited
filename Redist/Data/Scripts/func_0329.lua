--- Best guess: Simulates a roulette game, checking time and casino state to determine outcomes and trigger effects.
function func_0329(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    if eventid == 1 and not unknown_0079H(itemref) then
        unknown_007EH()
        var_0000 = unknown_083CH()
        var_0000 = unknown_083AH()
        if _GetTimeHour() >= 15 or _GetTimeHour() <= 3 then
            for var_0001 in ipairs(var_0000) do
                unknown_008AH(11, var_0003)
            end
            unknown_001DH(9, -232)
        end
        var_0004 = unknown_0030H(814)
        var_0005 = unknown_0030H(809)
        var_0006 = unknown_0030H(818)
        if #var_0006 > 0 or #var_0005 ~= 3 or #var_0004 < 1 then
            return
        end
        set_flag(31, false)
        set_flag(32, false)
        set_flag(33, false)
        unknown_0933H(0, "@Spin baby!@", -356)
        for var_0007 in ipairs(var_0005) do
            var_000A = random2(2, 0) * 8
            unknown_005CH(var_0009)
            var_000B = unknown_0001H({1547, 8533, var_000A, -3, 7947, 29, 17496, 8014, 22, -3, 7947, 29, 17496, 7758}, var_0009)
        end
    end
end