--- Best guess: Triggers effects on nearby items (type 873, within 20 units) based on their frame, cycling through specific sequences in a dungeon trap.
function func_06B6(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 3 then
        unknown_000FH(28)
        var_0000 = unknown_0035H(0, 20, 873, itemref)
        var_0001 = {}
        for i = 1, #var_0000 do
            var_0001 = unknown_0019H(var_0001, var_0000[i], itemref)
        end
        var_0000 = unknown_093DH(var_0001, var_0000)
        var_0004 = var_0000[1]
        if var_0004 then
            var_0005 = unknown_0012H(var_0004)
            var_0006 = var_0005 % 4
            if var_0006 >= 3 then
                var_0007 = unknown_0001H({8014, 83, 7768}, var_0004)
            else
                var_0005 = var_0005 - var_0006
                var_0007 = unknown_0001H({var_0005, 8006, 83, 7768}, var_0004)
            end
        end
    end
    return
end