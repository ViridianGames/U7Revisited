--- Best guess: Manages an egg outside the forge, triggering different item creations based on event IDs and item types, with flag checks and dialogue.
function func_06F9(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_0020, var_0021, var_0022, var_0023, var_0024, var_0025, var_0026, var_0027, var_0028, var_0029, var_0030, var_0031

    var_0000 = false
    var_0001 = false
    if eventid == 2 then
        var_0002 = unknown_0011H(itemref)
        if var_0002 == 854 then
            return
        elseif var_0002 == 707 then
            var_0000 = {1530, 2192}
            var_0001 = 0
        else
            unknown_008CH(1, 1, 12)
            if var_0002 == 955 then
                var_0003 = false
                var_0004 = unknown_0035H(0, 20, 854, 356)
                if var_0004 then
                    for i = 1, #var_0004 do
                        var_0007 = var_0004[i]
                        if unknown_0012H(itemref) == 8 and unknown_0012H(var_0007) == 16 then
                            var_0003 = var_0007
                        elseif unknown_0012H(itemref) == 9 and unknown_0012H(var_0007) == 15 then
                            var_0003 = var_0007
                        elseif unknown_0012H(itemref) == 10 and unknown_0012H(var_0007) == 14 then
                            var_0003 = var_0007
                        end
                    end
                    unknown_0356H(4, var_0003)
                end
            end
        end
    elseif eventid == 1 then
        var_0000 = {1637, 2168}
        var_0001 = 4
    elseif eventid == 4 then
        var_0000 = {1530, 2192}
        var_0001 = 0
    elseif eventid == 7 then
        var_0000 = {1487, 2187}
        var_0001 = 6
    elseif eventid == 3 then
        var_0008 = unknown_0014H(itemref)
        if var_0008 == 1 then
            if not get_flag(808) then
                var_0000 = {1671, 2464}
                var_0001 = 4
            end
        elseif var_0008 == 2 then
            if not get_flag(834) then
                var_0000 = {1637, 2216}
                var_0001 = 4
            end
        elseif var_0008 == 3 then
            var_0000 = {1483, 2191}
            var_0001 = 0
        elseif var_0008 == 4 then
            if not get_flag(808) then
                var_0000 = {1502, 2182}
                var_0001 = 4
            end
        elseif var_0008 == 5 then
            var_0000 = {1502, 2201}
            var_0001 = 4
        elseif var_0008 == 6 then
            var_0000 = {1591, 2312}
            var_0001 = 0
        elseif var_0008 == 7 then
            if not unknown_08E8H(8) then
                var_0000 = {1483, 2191}
                var_0001 = 0
                set_flag(793, true)
            else
                var_0009 = unknown_0035H(0, 80, 955, itemref)
                for i = 1, #var_0009 do
                    var_0012 = var_0009[i]
                    var_0013 = unknown_0012H(var_0012)
                    if var_0013 == 8 then
                        var_0014 = unknown_0018H(var_0012)
                        var_0015 = unknown_0025H(itemref)
                        unknown_0026H(var_0014)
                    end
                end
            end
        elseif var_0008 == 8 then
            if not unknown_08E8H(9) then
                var_0000 = {1487, 2195}
                var_0001 = 2
                set_flag(834, true)
            else
                var_0009 = unknown_0035H(0, 80, 955, itemref)
                for i = 1, #var_0009 do
                    var_0012 = var_0009[i]
                    var_0013 = unknown_0012H(var_0012)
                    if var_0013 == 9 then
                        var_0014 = unknown_0018H(var_0012)
                        var_0015 = unknown_0025H(itemref)
                        unknown_0026H(var_0014)
                    end
                end
            end
        elseif var_0008 == 9 then
            var_0012 = unknown_000EH(0, 955, itemref)
            if var_0012 and unknown_0012H(var_0012) == 11 then
                if not unknown_08E8H(11) then
                    unknown_006FH(var_0012)
                    var_0014 = unknown_0018H(itemref)
                    unknown_0053H(-1, 0, 0, 0, var_0014[2] - 2, var_0014[1] - 2, 7)
                    unknown_000FH(67)
                end
                var_0009 = unknown_0035H(0, 25, 955, 356)
                if var_0009 then
                    for i = 1, #var_0009 do
                        var_0013 = var_0009[i]
                        var_001D = unknown_0012H(var_0013)
                        if var_001D == 11 then
                            unknown_006FH(var_0013)
                            var_0014 = unknown_0018H(itemref)
                            unknown_0053H(-1, 0, 0, 0, var_0014[2] - 2, var_0014[1] - 2, 7)
                            unknown_000FH(67)
                        end
                    end
                end
                var_0017 = unknown_0035H(0, 8, 750, itemref)
                var_001B = unknown_0035H(0, 8, 849, itemref)
                var_001B = {var_001B, unpack(unknown_0035H(0, 8, 293, itemref))}
                var_001B = {var_001B, unpack(unknown_0035H(0, 8, 678, itemref))}
                var_001B = {var_001B, unpack(unknown_0035H(0, 8, 657, itemref))}
                var_001B = {var_001B, unpack(unknown_0035H(0, 8, 750, itemref))}
                var_001C = unknown_0035H(0, 8, 338, itemref)
                for i = 1, #var_001C do
                    var_001F = var_001C[i]
                    var_0020 = unknown_0012H(var_001F)
                    if var_0020 == 2 then
                        var_001B = {var_001B, var_001F}
                    end
                end
                var_0021 = unknown_0035H(0, 8, 336, itemref)
                for i = 1, #var_0021 do
                    var_001F = var_0021[i]
                    var_0020 = unknown_0012H(var_001F)
                    if var_0020 == 2 then
                        var_001B = {var_001B, var_001F}
                    end
                end
                var_0024 = unknown_0035H(0, 8, 997, itemref)
                for i = 1, #var_0024 do
                    var_001F = var_0024[i]
                    var_0020 = unknown_0012H(var_001F)
                    if var_0020 == 2 then
                        var_001B = {var_001B, var_001F}
                    end
                end
                for i = 1, #var_001B do
                    var_001A = var_001B[i]
                    unknown_006FH(var_001A)
                end
                var_0029 = unknown_000EH(8, 718, itemref)
                unknown_0013H(1, var_0029)
            end
        elseif var_0008 == 10 then
            var_0012 = unknown_000EH(0, 955, itemref)
            if var_0012 and unknown_0012H(var_0012) == 11 then
                set_flag(832, true)
                if not unknown_08E8H(11) then
                    unknown_006FH(var_0012)
                    var_0014 = unknown_0018H(itemref)
                    unknown_0053H(-1, 0, 0, 0, var_0014[2] - 2, var_0014[1] - 2, 7)
                    unknown_000FH(67)
                end
                var_0009 = unknown_0035H(0, 25, 955, 356)
                if var_0009 then
                    for i = 1, #var_0009 do
                        var_0013 = var_0009[i]
                        var_001D = unknown_0012H(var_0013)
                        if var_001D == 11 then
                            unknown_006FH(var_0013)
                            var_0014 = unknown_0018H(itemref)
                            unknown_0053H(-1, 0, 0, 0, var_0014[2] - 2, var_0014[1] - 2, 7)
                            unknown_000FH(67)
                        end
                    end
                end
                var_002C = unknown_000EH(10, 515, itemref)
                unknown_006FH(var_002C)
                var_002D = unknown_0024H(870)
                unknown_0013H(0, var_002D)
                var_0014 = unknown_0018H(itemref)
                var_0015 = unknown_0026H(var_0014)
            end
        elseif var_0008 == 11 then
            if not get_flag(832) then
                var_002C = unknown_000EH(10, 515, itemref)
                unknown_006FH(var_002C)
                var_002D = unknown_0024H(870)
                unknown_0013H(0, var_002D)
                var_0014 = unknown_0018H(itemref)
                var_0015 = unknown_0026H(var_0014)
            end
            var_0000 = {1590, 2391}
            var_0001 = 0
        elseif var_0008 == 12 then
            var_0000 = {1589, 2392}
            var_0001 = 4
        elseif var_0008 == 13 then
            var_0000 = {1401, 2152}
            var_0001 = 4
        elseif var_0008 == 14 then
            if not get_flag(808) then
                var_0000 = {1495, 2439}
                var_0001 = 4
            end
        elseif var_0008 == 15 then
            if not get_flag(808) then
                var_0000 = {1732, 2520}
                var_0001 = 0
            end
        elseif var_0008 == 16 then
            var_0000 = {1590, 2391}
            var_0001 = 0
        elseif var_0008 == 17 then
            var_0000 = {1476, 2359}
            var_0001 = 4
        elseif var_0008 == 20 then
            var_0000 = {1560, 2740}
            var_0001 = 6
        elseif var_0008 == 21 then
            var_002E = unknown_000EH(3, 268, itemref)
            if not var_002E then
                unknown_0013H(2, var_002E)
                unknown_000FH(37)
            end
        end
        if var_0000 and not unknown_0088H(var_0000, 10) then
            unknown_008CH(0, 1, 12)
            unknown_003EH(var_0000, 357)
            if get_flag(793) and not get_flag(792) then
                if not unknown_08E8H(8) then
                    var_000C = unknown_08E8H(8)
                    set_flag(791, true)
                    var_002F = unknown_0001H({1785, 8021, 2, 7719}, var_000C)
                    var_0030 = unknown_0001H({2, 8487, var_0001, 7769}, 356)
                end
            elseif get_flag(808) and not get_flag(807) then
                if not unknown_08E8H(10) then
                    var_000C = unknown_08E8H(10)
                    set_flag(791, true)
                    var_002F = unknown_0001H({1785, 8021, 2, 7719}, var_000C)
                    var_0030 = unknown_0001H({2, 8487, var_0001, 7769}, 356)
                end
            elseif get_flag(834) and not get_flag(833) then
                if not unknown_08E8H(9) then
                    var_000C = unknown_08E8H(9)
                    set_flag(791, true)
                    var_002F = unknown_0001H({1785, 8021, 2, 7719}, var_000C)
                    var_0030 = unknown_0001H({2, 8487, var_0001, 7769}, 356)
                end
            end
            var_0030 = unknown_0001H({1785, 8021, 1, 8487, var_0001, 7769}, 356)
        end
    end
    return
end