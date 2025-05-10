--- Best guess: Tracks scrolls in a forge, checking containers for specific items (types 240–248) and updating flags when conditions are met, likely part of a quest.
function func_06F7(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_0020, var_0021, var_0022, var_0023, var_0024, var_0025, var_0026, var_0027, var_0028, var_0029, var_0030, var_0031, var_0032, var_0033, var_0034, var_0035, var_0036, var_0037, var_0038, var_0039, var_0040, var_0041, var_0042, var_0043, var_0044

    var_0000 = unknown_0014H(objectref)
    if var_0000 == 240 then
        var_0001 = false
        var_0002 = unknown_0035H(0, 80, 762, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 22 and not unknown_002AH(4, 240, 797, var_0005) then
                var_0001 = var_0005
            end
        end
        if not var_0001 and not get_flag(750) then
            set_flag(750, true)
            var_0007 = unknown_0024H(unknown_0011H(var_0001))
            unknown_006CH(var_0001, var_0007)
            var_0008 = unknown_0026H(unknown_0018H(var_0001))
            unknown_08E6H(var_0001)
        end
    elseif var_0000 == 241 then
        var_0009 = false
        var_0002 = unknown_0035H(0, 80, 778, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 7 and not unknown_002AH(4, 241, 797, var_0005) then
                var_0009 = var_0005
            end
        end
        if not var_0009 then
            var_0012 = unknown_0024H(414)
            unknown_0013H(4, var_0012)
            var_0008 = unknown_0026H(unknown_0018H(var_0009))
            unknown_08E6H(var_0009)
            set_flag(753, true)
        end
    elseif var_0000 == 243 then
        var_0015 = false
        var_0002 = unknown_0035H(0, 80, 400, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 0 and not unknown_002AH(4, 243, 797, var_0005) then
                var_0015 = var_0005
            end
        end
        if not var_0015 and not get_flag(753) then
            set_flag(753, true)
            var_0012 = unknown_0024H(414)
            unknown_0013H(4, var_0012)
            var_0008 = unknown_0026H(unknown_0018H(var_0015))
            unknown_08E6H(var_0015)
        end
    elseif var_0000 == 244 then
        var_0016 = false
        var_0002 = unknown_0035H(0, 80, 400, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 0 and not unknown_002AH(4, 244, 797, var_0005) then
                var_0016 = var_0005
            end
        end
        if not var_0016 and not get_flag(754) then
            set_flag(754, true)
            var_0012 = unknown_0024H(414)
            unknown_0013H(4, var_0012)
            var_0008 = unknown_0026H(unknown_0018H(var_0016))
            unknown_08E6H(var_0016)
        end
    elseif var_0000 == 245 then
        var_0017 = false
        var_0002 = unknown_0035H(0, 80, 400, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 0 and not unknown_002AH(4, 245, 797, var_0005) then
                var_0017 = var_0005
            end
        end
        if not var_0017 then
            var_0012 = unknown_0024H(414)
            unknown_0013H(4, var_0012)
            var_0008 = unknown_0026H(unknown_0018H(var_0017))
            set_flag(755, true)
            unknown_08E6H(var_0017)
        end
    elseif var_0000 == 246 then
        var_0018 = false
        var_0002 = unknown_0035H(0, 80, 400, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 0 and not unknown_002AH(4, 246, 797, var_0005) then
                var_0018 = var_0005
            end
        end
        if not var_0018 and not get_flag(756) then
            set_flag(756, true)
            var_0012 = unknown_0024H(414)
            unknown_0013H(4, var_0012)
            var_0008 = unknown_0026H(unknown_0018H(var_0018))
            unknown_08E6H(var_0018)
        end
    elseif var_0000 == 247 then
        var_0019 = false
        var_0002 = unknown_0035H(0, 80, 400, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 0 and not unknown_002AH(4, 247, 797, var_0005) then
                var_0019 = var_0005
            end
        end
        if not var_0019 and not get_flag(757) then
            set_flag(757, true)
            var_0012 = unknown_0024H(414)
            unknown_0013H(4, var_0012)
            var_0008 = unknown_0026H(unknown_0018H(var_0019))
            unknown_08E6H(var_0019)
        end
    elseif var_0000 == 248 then
        var_0020 = false
        var_0002 = unknown_0035H(0, 80, 400, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 0 and not unknown_002AH(4, 248, 797, var_0005) then
                var_0020 = var_0005
            end
        end
        if not var_0020 and not get_flag(758) then
            set_flag(758, true)
            var_0012 = unknown_0024H(414)
            unknown_0013H(4, var_0012)
            var_0008 = unknown_0026H(unknown_0018H(var_0020))
            unknown_08E6H(var_0020)
        end
    elseif var_0000 == 249 then
        var_0021 = false
        var_0002 = unknown_0035H(0, 80, 400, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 0 and not unknown_002AH(4, 249, 797, var_0005) then
                var_0021 = var_0005
            end
        end
        if not var_0021 and not get_flag(759) then
            set_flag(759, true)
            var_0012 = unknown_0024H(414)
            unknown_0013H(4, var_0012)
            var_0008 = unknown_0026H(unknown_0018H(var_0021))
            unknown_08E6H(var_0021)
        end
    elseif var_0000 == 250 then
        var_0022 = false
        var_0002 = unknown_0035H(0, 80, 400, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 0 and not unknown_002AH(4, 250, 797, var_0005) then
                var_0022 = var_0005
            end
        end
        if not var_0022 and not get_flag(760) then
            set_flag(760, true)
            var_0012 = unknown_0024H(414)
            unknown_0013H(4, var_0012)
            var_0008 = unknown_0026H(unknown_0018H(var_0022))
            unknown_08E6H(var_0022)
        end
    elseif var_0000 == 251 then
        var_0023 = false
        var_0002 = unknown_0035H(0, 80, 400, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 0 and not unknown_002AH(4, 251, 797, var_0005) then
                var_0023 = var_0005
            end
        end
        if not var_0023 and not get_flag(761) then
            set_flag(761, true)
            var_0012 = unknown_0024H(414)
            unknown_0013H(4, var_0012)
            var_0008 = unknown_0026H(unknown_0018H(var_0023))
            unknown_08E6H(var_0023)
        end
    elseif var_0000 == 252 then
        var_0024 = false
        var_0002 = unknown_0035H(0, 80, 400, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 0 and not unknown_002AH(4, 252, 797, var_0005) then
                var_0024 = var_0005
            end
        end
        if not var_0024 and not get_flag(762) then
            set_flag(762, true)
            var_0012 = unknown_0024H(414)
            unknown_0013H(4, var_0012)
            var_0008 = unknown_0026H(unknown_0018H(var_0024))
            unknown_08E6H(var_0024)
        end
    elseif var_0000 == 253 then
        var_0025 = false
        var_0002 = unknown_0035H(0, 80, 400, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 0 and not unknown_002AH(4, 253, 797, var_0005) then
                var_0025 = var_0005
            end
        end
        if not var_0025 and not get_flag(763) then
            set_flag(763, true)
            var_0012 = unknown_0024H(414)
            unknown_0013H(4, var_0012)
            var_0008 = unknown_0026H(unknown_0018H(var_0025))
            unknown_08E6H(var_0025)
        end
    elseif var_0000 == 254 then
        var_0026 = false
        var_0002 = unknown_0035H(0, 80, 400, 356)
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0012H(var_0005)
            if var_0006 == 0 and not unknown_002AH(4, 254, 797, var_0005) then
                var_0026 = var_0005
            end
        end
        if not var_0026 and not get_flag(764) then
            set_flag(764, true)
            var_0012 = unknown_0024H(414)
            unknown_0013H(4, var_0012)
            var_0008 = unknown_0026H(unknown_0018H(var_0026))
            unknown_08E6H(var_0026)
        end
    end
    unknown_005CH(objectref)
    unknown_0002H(3, 1783, {17493, 7715}, objectref)
    return
end