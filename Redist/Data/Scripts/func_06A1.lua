--- Best guess: Modifies items in a dungeon forge, adjusting frames and positions for items with specific quality and frame values, then spawns additional items.
function func_06A1(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    var_0000 = unknown_0035H(16, 10, 275, itemref)
    for i = 1, 5 do
        var_0004 = unknown_0014H(var_0003)
        var_0005 = unknown_0012H(var_0003)
        var_0006 = unknown_0018H(var_0003)
        if var_0005 == 6 then
            if var_0004 == 3 then
                var_0007 = unknown_0024H(623)
                unknown_0013H(0, var_0007)
                var_0008 = unknown_0026H(var_0006)
                unknown_0053H(1, 0, 0, 0, var_0006[2] - 2, var_0006[1] - 1, 13)
            elseif var_0004 == 7 then
                var_0009 = unknown_0024H(810)
                unknown_0013H(0, var_0009)
                var_0008 = unknown_0026H(var_0006)
                unknown_0053H(1, 0, 0, 0, var_0006[2] - 2, var_0006[1] - 1, 13)
            end
        end
    end
    var_000A = unknown_0001H(1781, {8021, 2, 17447, 8033, 3, 17447, 8044, 4, 17447, 8045, 3, 17447, 7788}, itemref)
    unknown_000FH(68)
    return
end