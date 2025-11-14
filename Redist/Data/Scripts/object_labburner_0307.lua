--- Best guess: Manages a laboratory burner, checking for nearby portions and aligning them based on position and frame conditions.
function object_labburner_0307(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015

    if eventid == 1 and get_object_frame(objectref) == 0 then
        var_0000 = get_object_position(objectref)
        var_0001 = find_nearby(0, 5, 340, objectref)
        var_0002 = 0
        var_0003 = 0
        var_0004 = 0
        var_0005 = {8, 7, 2}
        for var_0006 in ipairs(var_0001) do
            var_0007 = get_object_position(var_0008)
            var_000A = get_object_frame(var_0008)
            if var_0007[1] == var_0000[1] - 3 and var_0007[2] == var_0000[2] and var_0007[3] == var_0000[3] and table.contains(var_0005, var_000A) then
                var_0005 = utility_unknown_0770(var_0005, var_000A)
                var_0002 = var_0008
            end
            if var_0007[1] == var_0000[1] and var_0007[2] == var_0000[2] - 2 and var_0007[3] == var_0000[3] and table.contains(var_0005, var_000A) then
                var_0005 = utility_unknown_0770(var_0005, var_000A)
                var_0003 = var_0008
            end
            if var_0007[1] == var_0000[1] and var_0007[2] == var_0000[2] and var_0007[3] == var_0000[3] and table.contains(var_0005, var_000A) then
                var_0005 = utility_unknown_0770(var_0005, var_000A)
                var_0004 = var_0008
            end
        end
        if var_0002 and var_0003 and var_0004 then
            var_000B = find_nearby(0, 5, 754, objectref)
            for var_000C in ipairs(var_000B) do
                var_000D = get_object_position(var_000E)
                if var_000D[1] == var_0000[1] + 2 and var_000D[2] == var_0000[2] and var_000D[3] == var_0000[3] then
                    var_0010 = find_nearby(0, 5, 177, objectref)
                    for var_0011 in ipairs(var_0010) do
                        var_0012 = get_object_position(var_0013)
                        if var_0012[1] == var_0000[1] + 1 and var_0012[2] == var_0000[2] + 2 and var_0012[3] == var_0000[3] + 2 then
                            var_0015 = execute_usecode_array(objectref, {8016, 10, 7975, 67, 17496, 7758})
                            var_0015 = delayed_execute_usecode_array(2, {1557, 17493, 7715}, var_0002)
                            var_0015 = delayed_execute_usecode_array(4, {1557, 17493, 7715}, var_0003)
                            var_0015 = delayed_execute_usecode_array(6, {1557, 17493, 7715}, var_0004)
                            var_0015 = execute_usecode_array(var_000E, {-1, 4, 17419, 7758})
                            var_0015 = execute_usecode_array(var_0013, {0, 3, -1, 17419, 7758})
                            set_flag(464, true)
                            abort()
                        end
                    end
                end
            end
            var_0015 = execute_usecode_array(objectref, {8016, 10, 7975, 69, 17496, 7758})
        end
        get_object_frame(objectref, 0)
    end
end