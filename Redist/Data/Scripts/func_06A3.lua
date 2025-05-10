--- Best guess: Manages a dungeon forge egg, spawning mages, dragons, or golems based on item quality and container contents, with specific flag checks.
function func_06A3(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_001A, var_001B, var_001C, var_001D, var_001E

    if eventid ~= 3 then
        return
    end
    var_0000 = unknown_0014H(objectref)
    if var_0000 == 1 and not get_flag(750) then
        var_0001 = false
        var_0002 = unknown_0035H(8, 80, 154, objectref)
        for i = 1, 5 do
            if unknown_002AH(4, 240, 797, var_0005) then
                var_0001 = var_0005
                break
            end
        end
        if not var_0001 then
            var_0006 = unknown_000EH(1, 154, objectref)
            if not var_0006 then
                if not unknown_0085H(16, 154, unknown_0018H(objectref)) then
                    unknown_08EBH(16, 154, objectref)
                end
                var_0007 = unknown_0018H(objectref)[-359][0]
                var_0008 = unknown_0035H(16, 0, 275, var_0007)
                var_0009 = unknown_0001H(8520, var_0008)
                var_0009 = unknown_0001H(1699, {17493, 7724}, objectref)
            else
                var_000A = unknown_0010H(6, 1)
                if var_000A == 1 then
                    unknown_001DH(14, var_0006)
                elseif var_000A >= 2 and var_000A <= 4 then
                    unknown_001DH(11, var_0006)
                elseif var_000A >= 5 then
                    unknown_001DH(16, var_0006)
                end
                var_000B = unknown_0024H(797)
                unknown_0089H(18, var_000B)
                var_0009 = unknown_0015H(240, var_000B)
                unknown_0013H(4, var_000B)
                var_0009 = unknown_0036H(var_0006)
                var_000C = unknown_0002H(3, 1783, {17493, 17443, 7724}, var_000B)
            end
        end
    elseif var_0000 == 2 and not get_flag(751) then
        var_0001 = false
        var_0002 = unknown_0035H(8, 80, 504, objectref)
        for i = 1, 5 do
            if unknown_002AH(4, 241, 797, var_0005) then
                var_0001 = var_0005
                break
            end
        end
        if not var_0001 then
            var_0006 = unknown_000EH(1, 504, objectref)
            if not var_0006 then
                if not unknown_0085H(19, 504, unknown_0018H(objectref)) then
                    unknown_08EBH(19, 504, objectref)
                end
                var_0007 = unknown_0018H(objectref)[-359][0]
                var_0008 = unknown_0035H(16, 0, 275, var_0007)
                var_0009 = unknown_0001H(8520, var_0008)
                var_0009 = unknown_0001H(1699, {17493, 7724}, objectref)
            else
                unknown_001DH(15, var_0006)
                unknown_0013H(19, var_0006)
                unknown_0089H(18, var_0006)
                var_000F = unknown_0024H(797)
                unknown_0089H(18, var_000F)
                var_0009 = unknown_0015H(241, var_000F)
                unknown_0013H(4, var_000F)
                var_0009 = unknown_0036H(var_0006)
                var_000C = unknown_0002H(3, 1783, {17493, 17443, 7724}, var_000F)
            end
        end
    elseif var_0000 == 4 and not get_flag(753) and get_flag(795) then
        var_0001 = false
        var_0002 = unknown_0035H(8, 80, 1015, objectref)
        for i = 1, 5 do
            if unknown_002AH(4, 243, 797, var_0005) then
                var_0001 = var_0005
                break
            end
        end
        if not var_0001 then
            var_0006 = unknown_000EH(1, 1015, objectref)
            if not var_0006 then
                if not unknown_0085H(16, 1015, unknown_0018H(objectref)) then
                    unknown_08EBH(16, 1015, objectref)
                end
                var_0007 = unknown_0018H(objectref)[-359][0]
                var_0008 = unknown_0035H(16, 0, 275, var_0007)
                var_0009 = unknown_0001H(8520, var_0008)
                var_0009 = unknown_0001H(1699, {17493, 7724}, objectref)
            else
                unknown_0013H(16, var_0006)
                if not get_flag(795) or not get_flag(796) or not get_flag(806) then
                    unknown_001DH(11, var_0006)
                else
                    unknown_001DH(15, var_0006)
                end
                var_0009 = unknown_0036H(var_0006)
                var_000C = unknown_0002H(3, 1783, {17493, 17443, 7724}, var_0006)
                var_0009 = unknown_0001H(2, {7769}, var_0006)
            end
        end
    elseif var_0000 == 5 and not get_flag(754) and not get_flag(796) then
        var_0001 = false
        var_0002 = unknown_0035H(8, 80, 1015, objectref)
        for i = 1, 5 do
            if unknown_002AH(4, 244, 797, var_0005) then
                var_0001 = var_0005
                break
            end
        end
        if not var_0001 then
            var_0006 = unknown_000EH(1, 1015, objectref)
            if not var_0006 then
                if not unknown_0085H(16, 1015, unknown_0018H(objectref)) then
                    unknown_08EBH(16, 1015, objectref)
                end
                var_0007 = unknown_0018H(objectref)[-359][0]
                var_0008 = unknown_0035H(16, 0, 275, var_0007)
                var_0009 = unknown_0001H(8520, var_0008)
                var_0009 = unknown_0001H(1699, {17493, 7724}, objectref)
            else
                unknown_0013H(16, var_0006)
                if not get_flag(795) or not get_flag(796) or not get_flag(806) then
                    unknown_001DH(11, var_0006)
                else
                    unknown_001DH(15, var_0006)
                end
                unknown_0089H(18, var_0006)
                var_0012 = unknown_0024H(797)
                unknown_0089H(18, var_0012)
                var_0009 = unknown_0015H(244, var_0012)
                unknown_0013H(4, var_0012)
                var_0009 = unknown_0036H(var_0006)
                var_000C = unknown_0002H(3, 1783, {17493, 17443, 7724}, var_0012)
                var_0009 = unknown_0001H(2, {7769}, var_0006)
            end
        end
    elseif var_0000 == 6 then
        var_0015 = unknown_0035H(8, 10, 1, objectref)
        for i = 1, 5 do
            if unknown_0011H(var_0018) == 504 and not unknown_002AH(4, 241, 797, var_0018) then
                unknown_01F8H(objectref)
            end
        end
    elseif var_0000 == 7 and not get_flag(755) then
        var_0019 = 245
    elseif var_0000 == 8 and not get_flag(756) then
        var_0019 = 246
        var_001A = 4
    elseif var_0000 == 9 and not get_flag(757) then
        var_0019 = 247
        var_001A = 4
    elseif var_0000 == 10 and not get_flag(758) then
        var_0019 = 248
    elseif var_0000 == 11 and not get_flag(759) then
        var_0019 = 249
        var_001A = 4
    elseif var_0000 == 12 and not get_flag(760) then
        var_0019 = 250
    elseif var_0000 == 13 and not get_flag(761) then
        var_0019 = 251
    elseif var_0000 == 14 and not get_flag(762) then
        var_0019 = 252
    elseif var_0000 == 15 and not get_flag(763) then
        var_0019 = 253
    elseif var_0000 == 16 and not get_flag(764) then
        var_0019 = 254
    end
    if var_0019 then
        var_0002 = unknown_0035H(4, 80, 1015, objectref)
        for i = 1, 5 do
            if unknown_002AH(4, var_0019, 797, var_0005) then
                var_0001 = var_0005
                break
            end
        end
        if not var_0001 then
            var_0006 = unknown_000EH(1, 1015, objectref)
            if not var_0006 then
                if not unknown_0085H(16, 1015, unknown_0018H(objectref)) then
                    unknown_08EBH(16, 1015, objectref)
                end
                var_0007 = unknown_0018H(objectref)[-359][0]
                var_0008 = unknown_0035H(16, 0, 275, var_0007)
                var_0009 = unknown_0001H(8520, var_0008)
                var_0009 = unknown_0001H(1699, {17493, 7724}, objectref)
            else
                unknown_0013H(0, var_0006)
                unknown_0089H(18, var_0006)
                var_001D = unknown_0001H(var_001A or 0, {7769}, var_0006)
                unknown_003DH(2, var_0006)
                var_0012 = unknown_0024H(797)
                unknown_0089H(18, var_0012)
                var_0009 = unknown_0015H(var_0019, var_0012)
                unknown_0013H(4, var_0012)
                var_0009 = unknown_0036H(var_0006)
                var_000C = unknown_0002H(3, 1783, {17493, 17443, 7724}, var_0012)
            end
        end
    end
    return
end