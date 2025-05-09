--- Best guess: Manages a mechanic for item type 466, creating a body (ID 414) and items (IDs 797, 1783) with environmental effects, or handling container items (ID 797) with quality checks.
function func_070F(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018

    var_0000 = get_object_shape(itemref)
    if var_0000 == 466 then
        var_0001 = unknown_0018H(unknown_001BH(-356))
        unknown_0053H(-1, 0, 0, 0, var_0001[2], var_0001[1], 17)
        unknown_000FH(62)
        var_0002 = unknown_0035H(8, 80, -1, unknown_001BH(-356))
        for var_0003 in ipairs(var_0002) do
            var_0006 = get_object_shape(var_0005)
            if not (var_0006 == 721 or var_0006 == 989) then
                if unknown_003CH(var_0005) == 0 then
                    unknown_003DH(2, var_0005)
                    unknown_001DH(0, var_0005)
                end
            end
        end
        var_0007 = unknown_0018H(itemref)
        var_0008 = unknown_0024H(414)
        unknown_006BH(itemref)
        unknown_006CH(var_0008, itemref)
        get_object_frame(var_0008, 30)
        unknown_003FH(-23)
        var_0009 = unknown_0026H(var_0007)
        var_000A = unknown_0024H(797)
        get_object_frame(var_000A, 0)
        var_0009 = unknown_0015H(43, var_000A)
        var_0009 = unknown_0036H(var_0008)
        var_000B = unknown_0001H(var_0008, {12, 8006, 2, 7975, 31, 8006, 5, 7719})
    else
        var_000C = unknown_003CH(itemref)
        unknown_000FH(4)
        if not unknown_0088H(itemref, 18) then
            unknown_0049H(itemref)
            unknown_003FH(itemref)
            var_0002 = unknown_0035H(8, 80, -1, unknown_001BH(-356))
            for var_000D in ipairs(var_0002) do
                var_0006 = get_object_shape(var_0005)
                if not (var_0006 == 721 or var_0006 == 989) then
                    if unknown_003CH(var_0005) == var_000C then
                        unknown_003DH(2, var_0005)
                        unknown_001DH(0, var_0005)
                    end
                end
            end
        end
        var_000F = get_container_objects(-359, -359, 797, itemref)
        if var_000F then
            var_0010 = _GetItemQuality(var_000F)
            var_0011 = false
            if var_0010 == 240 then
                set_flag(750, true)
                var_0012 = unknown_0018H(itemref)
                var_0011 = unknown_0024H(762)
                unknown_006BH(itemref)
                unknown_006CH(var_0011, itemref)
                get_object_frame(var_0011, 22)
                unknown_08E6H(itemref)
                var_0009 = unknown_0026H(var_0012)
            elseif var_0010 == 241 then
                set_flag(751, true)
                var_0012 = unknown_0018H(itemref)
                var_0011 = unknown_0024H(778)
                unknown_006BH(itemref)
                unknown_006CH(var_0011, itemref)
                get_object_frame(var_0011, 7)
                unknown_08E6H(itemref)
                var_0009 = unknown_0026H(var_0012)
            end
            var_0013 = unknown_0024H(797)
            unknown_0089H(18, var_0013)
            var_0009 = unknown_0015H(var_0010, var_0013)
            get_object_frame(var_0013, 4)
            var_0009 = unknown_0036H(var_0011)
            var_0014 = unknown_0002H(1, 1783, {17493, 17443, 7724}, var_0013)
            var_0002 = unknown_0035H(8, 80, -1, unknown_001BH(-356))
            for var_0015 in ipairs(var_0002) do
                var_0006 = get_object_shape(var_0005)
                if not (var_0006 == 721 or var_0006 == 989) then
                    if unknown_003CH(var_0005) == var_000C then
                        unknown_003DH(2, var_0005)
                        unknown_001DH(0, var_0005)
                    end
                end
            end
        else
            unknown_0049H(itemref)
            var_0002 = unknown_0035H(8, 80, -1, unknown_001BH(-356))
            for var_0017 in ipairs(var_0002) do
                var_0006 = get_object_shape(var_0005)
                if not (var_0006 == 721 or var_0006 == 989) then
                    if unknown_003CH(var_0005) == var_000C then
                        unknown_003DH(2, var_0005)
                        unknown_001DH(0, var_0005)
                    end
                end
            end
        end
    end
end