--- Best guess: Manages a Triples game, evaluating game state (via 083BH), determining outcomes, and distributing rewards based on money items (via 083CH).
function func_083D()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016

    if unknown_001CH(-232) == 9 then
        unknown_001DH(10, -232)
    end
    var_0000 = unknown_083AH()
    var_0001 = unknown_083BH()
    var_0002 = var_0001[1]
    var_0003 = var_0001[2]
    var_0004 = unknown_083CH(0, var_0000)
    if not _NPCInParty(-232) then
        for var_0005 in ipairs(var_0004) do
            unknown_0089H(var_0007, 11)
        end
    end
    var_0008 = "@Too bad...@"
    if #var_0004 == 0 then
        unknown_0933H(0, var_0008, -232)
    end
    if var_0002 == 6 then
        if var_0003 == 0 then
            var_0009 = {5, 5, 5}
            var_000A = {3, 2, 1}
            var_000B = 27
            var_0008 = "@Triples! On the two!@"
        else
            var_0009 = {3, 3, 3}
            var_000A = {3, 2, 1}
            var_000B = 4
            var_0008 = "@Full wheel!@"
        end
    elseif var_0002 == 9 then
        var_0009 = {7, 7, 7}
        var_000A = {3, 2, 1}
        var_000B = 27
        var_0008 = "@Triples! On the three!@"
    elseif var_0002 == 3 then
        var_0009 = {1, 1, 1}
        var_000A = {3, 2, 1}
        var_000B = 27
        var_0008 = "@Triples! On the one!@"
    elseif var_0003 == 0 then
        table.insert(var_0009, {4, 4, 4})
        table.insert(var_000A, {3, 2, 1})
    elseif var_0002 == 4 then
        var_0009 = 2
        var_000A = 3
        var_000B = 8
        var_0008 = "@Sum of 4!@"
    elseif var_0002 == 5 then
        var_0009 = 2
        var_000A = 1
        var_000B = 4
        var_0008 = "@Sum of 5!@"
    elseif var_0002 == 7 then
        var_0009 = 6
        var_000A = 3
        var_000B = 3
        var_0008 = "@Seven!@"
    elseif var_0002 == 8 then
        var_0009 = 6
        var_000A = 1
        var_000B = 8
        var_0008 = "@Big eight!@"
    end
    if not get_flag(6) then
        var_000B = var_000B * 2
    end
    for var_000C in ipairs(var_0004) do
        var_000E = 0
        var_000F = false
        for var_0010 in ipairs(var_0009) do
            var_000E = var_000E + 1
            var_0013 = unknown_0018H(var_0007)
            if var_0013[1] == var_0000[1] - var_000E + 1 and var_0013[2] == var_0000[2] - var_000E + 1 then
                var_0014 = unknown_0016H(var_0007, 9)
                var_0014 = var_0014 * var_000B
                if var_0014 > 100 then
                    var_0015 = unknown_0024H(644)
                    if var_0015 then
                        var_0016 = unknown_0017H(var_0015, 100)
                        var_0016 = unknown_0026H(var_0013)
                    end
                    var_0014 = var_0014 - 100
                    goto continue
                end
                var_0015 = unknown_0024H(644)
                if var_0015 then
                    var_0016 = unknown_0017H(var_0015, var_0014)
                    var_0016 = unknown_0026H(var_0013)
                end
                var_000F = true
            end
            ::continue::
        end
        unknown_006FH(var_0007)
    end
    unknown_0933H(0, var_0008, -232)
end