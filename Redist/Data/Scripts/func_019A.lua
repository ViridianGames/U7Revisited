--- Best guess: Spawns items or objects based on item quality, likely for dynamic environmental or quest interactions, with specific coordinates and types.
function func_019A(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        unknown_007EH()
        var_0000 = unknown_0035H(0, 10, 411, itemref)
        var_0001 = unknown_0014H(itemref)
        if var_0001 == 0 or var_0001 > 3 then
            var_0002 = unknown_0001H({76, 8024, 37, 8024, 1, 8006, 0, 7750}, itemref)
        else
            var_0003 = {915, 916, 914}
            var_0004 = var_0003[var_0001]
            var_0002 = unknown_0001H({7, -10, 7947, 4, 3, -4, 7948, 8, 17496, 17409, 8013, 0, 7750}, itemref)
            var_0002 = unknown_0001H({24, -7, 7947, 1549, 8021, 15, 17496, 17409, 8014, 0, 7750}, var_0000)
        end
    end
    return
end