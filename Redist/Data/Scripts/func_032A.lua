--- Best guess: Manages bucket interactions, handling water usage for drinking, filling troughs, dousing fires, and other actions, with appropriate messages.
function func_032A(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_001A, var_001B, var_001C, var_001D, var_001E, var_001F, var_0020, var_0021, var_0022

    if eventid == 1 then
        unknown_007EH()
        var_0000 = unknown_0012H(itemref)
        if var_0000 == 6 then
        end
        if not unknown_006EH(itemref) then
            var_0001 = {-1, -1, -1, -1, 1, 1, 1, 0}
            var_0002 = {-1, 0, -1, 1, -1, 0, 1, 1}
            unknown_0828H(itemref, var_0001, var_0002, -3, 810, itemref, 3)
        elseif not unknown_0944H(itemref) then
            unknown_007EH()
            var_0003 = unknown_0945H(itemref)
            var_0001 = {1, -1, 1, 0}
            var_0002 = {0, 2, 1, 2}
            unknown_0828H(var_0003, var_0001, var_0002, -3, 810, itemref, 3)
        else
            unknown_007EH()
            var_0004 = unknown_0001H({810, 8021, 2, 7719}, itemref)
        end
    elseif eventid == 3 then
        var_0003 = unknown_0945H(itemref)
        var_0005 = unknown_092DH(var_0003)
        if unknown_0031H(var_0003) then
            var_0004 = unknown_0001H({8033, 3, 17447, 8548, var_0005, 7769}, unknown_001BH(-356))
            var_0004 = unknown_0001H({810, 8021, 2, 7975, 1682, 8021, 3, 7719}, itemref)
        else
            var_0004 = unknown_0001H({8033, 3, 17447, 8556, var_0005, 7769}, unknown_001BH(-356))
            var_0004 = unknown_0001H({810, 8021, 2, 7975, 1682, 8021, 3, 7719}, itemref)
        end
    elseif eventid == 2 then
        var_0000 = unknown_0012H(itemref)
        var_0006 = unknown_0033H()
        var_0007 = unknown_0011H(var_0006)
        if var_0007 == 721 or var_0007 == 989 then
            if var_0000 == 2 then
                unknown_0040H("@No, thank thee.@", unknown_001BH(-356))
            elseif var_0000 == 0 then
                unknown_0040H("@The bucket is empty.@", unknown_001BH(-356))
            else
                unknown_0040H("@Ahhh, how refreshing.@", unknown_001BH(-356))
                var_0004 = unknown_0001H({0, 7750}, itemref)
            end
        elseif unknown_0031H(var_0006) then
            var_0001 = {-2, 0, 2, 0}
            var_0002 = {0, -2, 0, 2}
            if var_0000 == 0 then
                unknown_0040H("@The bucket is empty.@", unknown_001BH(-356))
            else
                var_0004 = unknown_0001H({50, -2, 7947, 1, 7719}, var_0006)
                unknown_0828H(var_0006, var_0001, var_0002, 0, 810, var_0006, 4)
            end
        elseif var_0007 == 741 then
            var_0001 = {-4, -4, 1, 1, -2, -1, -2, -1}
            var_0002 = {-1, -1, 0, 1, -2, -2, 1, 1}
            unknown_0828H(var_0006, var_0001, var_0002, 0, 810, var_0006, 7)
        elseif var_0007 == 719 then
            var_0001 = {-1, 0, -1, 1, -2, -1, -2, -1}
            var_0002 = {-1, -1, 0, 0, -2, -2, 1, 1}
            unknown_0828H(var_0006, var_0001, var_0002, 0, 810, var_0006, 7)
        elseif var_0007 == 739 then
            var_0001 = {-4, -4, -2, -1, 1, 1, -2, -1}
            var_0002 = {-1, -1, -2, -1, 1, 1, -2, -1}
            if unknown_0012H(var_0006) >= 4 and unknown_0012H(var_0006) <= 7 then
                var_0001 = {-4, -4, -2, -1, 1, 1, -2, -1}
                var_0002 = {-1, -1, -2, -1, 1, 1, -2, -1}
                if var_0000 == 0 then
                    unknown_0040H("@The bucket is empty.@", unknown_001BH(-356))
                else
                    unknown_0828H(var_0006, var_0001, var_0002, -5, 810, var_0006, 8)
                end
            end
        elseif var_0007 == 338 or var_0007 == 435 or var_0007 == 701 or var_0007 == 658 or var_0007 == 825 then
            var_0001 = {0, -2, 0, 2}
            var_0002 = {-2, 0, 2, 0}
            if var_0000 == 0 then
                unknown_0040H("@The bucket is empty.@", unknown_001BH(-356))
            elseif var_0000 > 1 then
            elseif var_0000 == 1 then
                unknown_0828H(var_0006, var_0001, var_0002, -5, 810, var_0006, 8)
            end
        elseif var_0007 == 740 then
            if var_0000 == 0 then
                var_0008 = unknown_000EH(3, 470, var_0006)
                if var_0008 then
                    var_0001 = {-5, -5}
                    var_0002 = {-1, -1}
                    unknown_0828H(var_0008, var_0001, var_0002, 0, 810, itemref, 9)
                end
            else
                unknown_0040H("@The bucket is full.@", unknown_001BH(-356))
            end
        elseif var_0007 == 470 then
            if var_0000 == 0 then
                var_0001 = {-5, -5}
                var_0002 = {-1, -1}
                unknown_0828H(var_0006, var_0001, var_0002, 0, 810, itemref, 9)
            else
                unknown_0040H("@The bucket is full.@", unknown_001BH(-356))
            end
        elseif var_0007 == 331 then
            if var_0000 == 0 then
                unknown_0040H("@The bucket is empty.@", unknown_001BH(-356))
            else
                var_0006 = unknown_093CH(var_0006[1])
                var_0006[1] = var_0006[1]
                var_0006[2] = var_0006[2] + 1
                var_0009 = unknown_007DH(10, 810, itemref, var_0006)
            end
        elseif var_0006[1] == 0 then
            if var_0000 == 0 then
                unknown_0040H("@The bucket is empty.@", unknown_001BH(-356))
            else
                var_0006 = unknown_093CH(var_0006[1])
                var_0006[2] = var_0006[2] + 1
                var_0009 = unknown_007DH(10, 810, itemref, var_0006)
            end
    elseif eventid == 4 then
        var_000A = unknown_002AH(-359, -359, 810, unknown_001BH(-356))
        var_0000 = unknown_0012H(var_000A)
        var_000B = unknown_092DH(itemref)
        var_000C = (var_000B + 4) % 8
        if var_0000 == 2 then
            var_000D = unknown_0001H({5, 7463, "@Foul miscreant!@", 8018, 2, 8487, var_000C, 7769}, itemref)
        else
            var_000D = unknown_0001H({5, 7463, "@Hey, stop that!@", 8018, 2, 8487, var_000C, 7769}, itemref)
        end
        var_000E = unknown_0001H({17505, 17508, 8551, var_000B, 7769}, unknown_001BH(-356))
        var_000F = unknown_0001H({0, 8006, 2, 7719}, var_000A)
    elseif eventid == 7 then
        var_0010 = false
        var_0010 = unknown_000EH(5, 741, unknown_001BH(-356))
        if not var_0010 then
            var_0010 = unknown_000EH(5, 719, unknown_001BH(-356))
        end
        if var_0010 then
            var_0000 = unknown_0012H(itemref)
            var_0011 = unknown_0012H(var_0010)
            if var_0000 > 1 then
            elseif var_0000 == 1 then
                if var_0011 == 3 or var_0011 == 7 then
                    unknown_0040H("@The trough is full.@", unknown_001BH(-356))
                else
                    var_0012 = var_0011 + 1
                    var_0013 = 0
                end
            else
                if var_0011 == 0 or var_0011 == 4 then
                    unknown_0040H("@The trough is empty.@", unknown_001BH(-356))
                else
                    var_0012 = var_0011 - 1
                    var_0013 = 1
                end
            end
            var_0014 = unknown_0001H({17505, 17508, 8551, var_0005, 7769}, unknown_001BH(-356))
            var_0014 = unknown_0001H({40, 17496, 8449, var_0012, 8006, 2, 7719}, var_0010)
            var_0015 = unknown_0001H({var_0013, 8006, 2, 7719}, itemref)
        end
    elseif eventid == 8 then
        var_000A = unknown_002AH(-359, -359, 810, unknown_001BH(-356))
        var_0000 = unknown_0012H(var_000A)
        var_0007 = unknown_0011H(itemref)
        var_0015 = unknown_0012H(itemref)
        if var_0007 == 739 then
            if var_0015 == 4 then
                unknown_0040H("@There are only coals.@", unknown_001BH(-356))
            elseif var_0015 == 7 then
                var_0016 = unknown_0001H({17488, 17488, 17488, 7937, 1683, 7765}, itemref)
            elseif var_0015 == 6 then
                var_0016 = unknown_0001H({17488, 17488, 7937, 1683, 7765}, itemref)
            elseif var_0015 == 5 then
                var_0016 = unknown_0001H({17488, 7937, 1683, 7765}, itemref)
            end
            var_0005 = unknown_092DH(itemref)
            var_0016 = unknown_0001H({8033, 2, 17447, 8556, var_0005, 7769}, unknown_001BH(-356))
            if var_0007 == 338 then
                var_001A = 336
            elseif var_0007 == 435 then
                var_001A = 481
            elseif var_0007 == 701 then
                var_001A = 595
            end
            unknown_006FH(itemref)
            var_001B = unknown_0024H(var_001A)
            var_0019 = unknown_0014H(itemref)
            var_001C = unknown_0015H(var_001B, var_0019)
            unknown_0013H(var_001B, var_0015)
            var_0017 = unknown_0018H(itemref)
            var_0005 = unknown_092DH(itemref)
            var_001E = unknown_0001H({8033, 2, 17447, 8556, var_0005, 7769}, unknown_001BH(-356))
            var_001D = {var_0017[1] - var_0018, var_0017[2] - var_0018}
            unknown_0053H(-1, 0, 0, 0, var_001D[2], var_001D[1], 9)
            unknown_000FH(46)
        elseif var_0007 == 825 then
            if var_0015 == 0 then
                unknown_0040H("@There are only coals.@", unknown_001BH(-356))
            else
                var_001E = unknown_0001H({0, 7750}, itemref)
                var_0005 = unknown_092DH(itemref)
                var_001E = unknown_0001H({8033, 2, 17447, 8556, var_0005, 7769}, unknown_001BH(-356))
                var_001F = unknown_0018H(itemref)
                unknown_0053H(-1, 0, 0, 0, var_001F[2], var_001F[1], 9)
                unknown_000FH(46)
            end
        elseif var_0007 == 658 then
            if var_0015 == 0 then
                var_0005 = unknown_092DH(itemref)
                var_001E = unknown_0001H({8033, 2, 17447, 8556, var_0005, 7769}, unknown_001BH(-356))
                unknown_0013H(itemref, 2)
            end
    elseif eventid == 9 then
        var_0020 = unknown_000EH(10, 740, unknown_001BH(-356))
        var_0021 = unknown_0012H(var_0020)
        if var_0021 >= 0 and var_0021 <= 11 then
            var_0021 = 1
        elseif var_0021 >= 12 and var_0021 <= 23 then
            var_0021 = 13
        end
        var_0022 = unknown_0001H({8014, 1, 17447, 8014, 1, 17447, 8014, 1, 17447, 8014, 1, 17447, 8014, 2, 8487, var_0021, 8006, 1, 7719}, var_0020)
        var_0022 = unknown_0001H({4, 17447, 8039, 1, 17447, 8036, 1, 17447, 8038, 1, 17447, 8037, 1, 7975, 4, 8025, 2, 17447, 8039, 2, 7769}, unknown_001BH(-356))
        var_0022 = unknown_0001H({1685, 8021, 17, 7719}, itemref)
    elseif eventid == 10 then
        var_000E = unknown_0001H({8033, 3, 17447, 8044, 0, 7769}, unknown_001BH(-356))
        var_000F = unknown_0001H({1684, 8021, 3, 7719}, itemref)
    end
    return
end