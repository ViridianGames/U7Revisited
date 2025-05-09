--- Best guess: Manages the Orb of the Moons, creating a moongate for teleportation if conditions (e.g., flag 57) are met, with specific positioning logic.
function func_0311(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010

    if eventid == 1 then
        if get_flag(4) then
            unknown_08FEH({"@It work before.@", "@How odd!@"})
        elseif not get_flag(57) and not unknown_093EH() then
            var_0000 = _ItemSelectModal()
            var_0001 = unknown_0822H(var_0000)
            var_0002 = unknown_001AH(var_0001, -356)
            if var_0002 == 0 or var_0002 == 4 then
                var_0003 = 1
                var_0004 = 779
            else
                var_0003 = 2
                var_0004 = 157
            end
            var_0001[var_0003] = var_0001[var_0003] + 2
            if not unknown_0085H(0, var_0004, var_0001) then
                for var_0006 in ipairs({1, 2, 3}) do
                    if unknown_0085H(0, var_0004, var_0001) then
                        break
                    end
                    var_0001[3] = var_0001[3] + 1
                end
                if not unknown_0085H(0, var_0004, var_0001) then
                    unknown_006AH(0)
                end
            end
            unknown_007EH()
            var_0009 = unknown_0024H(var_0004)
            if not var_0009 then
                unknown_007EH()
                var_000A = unknown_0026H(var_0001)
                var_0001[var_0003] = var_0001[var_0003] - 2
                unknown_002EH(51, 33)
                unknown_0089H(18, var_0009)
                unknown_0015H(var_0002, var_0009)
                var_000A = unknown_0001H({7981, 3, -1, 17419, 8016, 4, 8006, 5, -7, 7947, 5, 5, -1, 17420, 8014, 4, 8006, 10, -1, 17419, 8014, 0, 7750}, var_0009)
                var_000B = 5 - unknown_0019H(-356, var_0009)
                var_000C = {8496 + var_0002, 7769}
                if var_000B > 0 then
                    table.insert(var_000C, var_000B)
                    table.insert(var_000C, 7719)
                end
                var_000A = unknown_0001H(var_000C, -356)
                var_000D = unknown_0018H(-356)
                if var_000D[var_0003] < var_0001[var_0003] then
                    var_000E = 1
                else
                    var_000E = -1
                end
                var_0001[var_0003] = var_0001[var_0003] + var_000E
                var_000A = unknown_007DH(7, var_0009, 785, var_0001)
                if not var_000A then
                    unknown_008BH(8, var_0009, 785)
                    var_000F = unknown_006EH(itemref)
                    var_0010 = _GetPartyMembers()
                    while var_000F and #var_0010 > 1 do
                        if not table.contains(var_0010, var_000F) then
                            var_000F = unknown_006EH(var_000F)
                        else
                            break
                        end
                    end
                    if not var_000F then
                        unknown_006FH(itemref)
                        var_000A = unknown_002CH(false, 0, 0, 785, 1)
                    end
                else
                    unknown_0821H(var_0009)
                end
            else
                unknown_0821H(var_0009)
            end
        end
    elseif eventid == 8 then
        if not unknown_0826H(itemref) then
            unknown_0821H(itemref)
            unknown_08FEH({"@Let thyself enter.@", "@No, Avatar.@"})
        end
    elseif eventid == 7 then
        if not unknown_0826H(itemref) then
            unknown_0821H(itemref)
            unknown_0824H(itemref)
        end
    end
end