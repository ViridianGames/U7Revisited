--- Best guess: Manages a summoning ritual (ID 1802), triggered by event 3, summoning an entity (ID 641) and applying environmental effects, with cleanup for various item types.
function func_070A(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_001A, var_001B, var_001C, var_001D, var_001E, var_001F, var_0020, var_0021, var_0022, var_0023, var_0024, var_0025, var_0026, var_0027, var_0028, var_0029, var_002A, var_002B, var_002C, var_002D

    if eventid ~= 3 then
        if eventid == 2 then
            if get_object_shape(itemref) == 154 then
                var_001A = {unknown_0018H(itemref), 200, 6}
                var_0003 = unknown_0035H(16, 20, 275, var_001A)
                if not var_0003 then
                    for var_001B in ipairs(var_0003) do
                        var_001A = {unknown_0018H(var_0001), -359, 0}
                        var_001D = unknown_0035H(16, 0, 275, var_001A)
                        for var_001E in ipairs(var_001D) do
                            var_0002 = unknown_0001H(var_0020, {17480, 7724})
                            var_0002 = unknown_0001H(unknown_001BH(-356), {1802, 17493, 17452, 7715})
                        end
                    end
                end
            elseif get_object_shape(itemref) == 721 or get_object_shape(itemref) == 989 then
                var_0001 = unknown_0035H(8, 30, 354, unknown_001BH(-356))
                if not var_0001 then
                    var_0021 = unknown_0018H(var_0001)
                    unknown_0053H(-1, 0, 0, 0, var_0021[2] - 2, var_0021[1] - 2, 8)
                    unknown_0053H(-1, 0, 0, 0, var_0021[2] - 2, var_0021[1] - 2, 7)
                    unknown_000FH(52)
                    get_object_frame(var_0001, 19)
                    var_0002 = unknown_0001H(var_0001, {1802, 8021, 5, 7975, 4, 7769})
                else
                    var_001A = {unknown_0018H(var_0001), -359, 6}
                    var_0003 = unknown_0035H(16, 0, 275, var_0001)
                    for var_0022 in ipairs(var_0003) do
                        var_0002 = unknown_0001H(var_0001, {17480, 7724})
                        var_0002 = unknown_0001H(unknown_001BH(-356), {1802, 17493, 17452, 7715})
                    end
                end
            end
            if not unknown_0088H(-356, 4) then
                abort()
            end
            if get_object_shape(itemref) == 354 then
                var_0024 = unknown_0019H(unknown_001BH(-356), itemref)
                if var_0024 < 20 and not unknown_0088H(unknown_001BH(-356), 23) then
                    var_0021 = unknown_0018H(itemref)
                    unknown_0053H(-1, 0, 0, 0, var_0021[2] + 3, var_0021[1] + 3, 17)
                    var_0025 = get_party_members()
                    for var_0026 in ipairs(var_0025) do
                        var_0029 = ""
                        var_002A = random2(8, 0)
                        if var_002A == 0 then
                            var_002B = {17505, 17516, 7789}
                            var_0029 = var_002B
                        elseif var_002A == 1 then
                            var_002B = {17505, 17505, 7789}
                            var_0029 = var_002B
                        elseif var_002A == 2 then
                            var_002B = {17505, 17518, 7788}
                            var_0029 = var_002B
                        elseif var_002A == 3 then
                            var_002B = {17505, 17505, 7777}
                            var_0029 = var_002B
                        elseif var_002A == 4 then
                            var_002B = {17505, 17508, 7789}
                            var_0029 = var_002B
                        elseif var_002A == 5 then
                            var_002B = {17505, 17517, 7780}
                            var_0029 = var_002B
                        elseif var_002A == 6 then
                            var_002C = random2(3, 0) * 2 + 7984
                            var_002B = {17505, 8556, var_002C, 7769}
                            var_0029 = var_002B
                        elseif var_002A == 7 then
                            var_002C = random2(3, 0) * 2 + 7984
                            var_002B = {17505, 8557, var_002C, 7769}
                            var_0029 = var_002B
                        elseif var_002A == 8 then
                            var_002C = random2(3, 0) * 2 + 7984
                            var_002B = {17505, 8548, var_002C, 7769}
                            var_0029 = var_002B
                        end
                        unknown_005CH(var_0028)
                        var_0002 = unknown_0001H(var_0028, var_0029)
                    end
                    unknown_0059H(3)
                    var_002D = random2(20, 5)
                    var_0002 = unknown_0001H(itemref, {1802, 8021, 1, 17447, 8047, 1, 17447, 8044, 2, 17447, 8045, 1, 17447, 8556, var_002D, 17447, 7780})
                else
                    var_002D = random2(15, 5)
                    var_0002 = unknown_0001H(itemref, {1802, 8021, 10, 8487, var_002D, 17447, 7780})
                end
            end
        end
        return
    end

    if not _get_object_quality(itemref) and not get_flag(827) then
        set_flag(827, true)
        var_0000 = unknown_000EH(0, 154, itemref)
        if not var_0000 then
            var_0001 = unknown_0024H(641)
            get_object_frame(var_0001, 7)
            var_0002 = unknown_0015H(65, var_0001)
            var_0002 = unknown_0036H(var_0000)
            bark(var_0000, "@I summon thee!@")
            var_0002 = unknown_0001H(unknown_001BH(-356), {22, 7719})
            var_0002 = unknown_0001H(var_0000, {8033, 2, 17447, 8044, 1802, 17493, 7937, 3, 17447, 8045, 1, 17447, 8044, 2, 17447, 8033, 2, 17447, 8048, 3, 17447, 7791})
            var_0003 = unknown_0035H(0, 20, 336, itemref)
            for var_0004 in ipairs(var_0003) do
                if get_object_frame(var_0001) == 7 or get_object_frame(var_0001) == 9 then
                    var_0006 = unknown_0024H(338)
                    get_object_frame(var_0006, get_object_frame(var_0001))
                    var_0002 = unknown_0026H(unknown_0018H(var_0001))
                    unknown_006FH(var_0001)
                end
            end
            var_0003 = unknown_0035H(0, 20, 338, itemref)
            for var_0007 in ipairs(var_0003) do
                if get_object_frame(var_0001) == 9 then
                    var_0009 = unknown_0035H(16, 1, 275, var_0001)
                    for var_000A in ipairs(var_0009) do
                        if get_object_frame(var_000C) == 6 and _get_object_quality(var_000C) == 201 then
                            var_000D = unknown_0024H(895)
                            get_object_frame(var_000D, 0)
                            var_0002 = unknown_0026H(unknown_0018H(var_000C))
                        end
                    end
                end
                unknown_006FH(var_0001)
            end
            var_0003 = unknown_0035H(0, 30, 168, itemref)
            for var_0012 in ipairs(var_0003) do
                unknown_006FH(var_0001)
            end
            var_0003 = unknown_0035H(0, 10, 400, itemref)
            for var_0014 in ipairs(var_0003) do
                if get_object_frame(var_0001) == 29 then
                    unknown_08E6H(var_0001)
                end
            end
            var_0003 = unknown_0035H(16, 0, 275, itemref)
            for var_0016 in ipairs(var_0003) do
                if get_object_frame(var_0001) == 0 then
                    unknown_006FH(var_0001)
                end
            end
            var_0003 = unknown_0035H(8, 1, 154, itemref)
            for var_0018 in ipairs(var_0003) do
                unknown_08E6H(var_0001)
            end
            unknown_006FH(itemref)
        end
    end
end