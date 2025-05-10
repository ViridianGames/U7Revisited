--- Best guess: Manages the placement of prisms by the Black Gate, checking for beams (ID 168) and pedestals (ID 577), aligning prisms (ID 981) and updating frames.
function func_082E(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F

    unknown_007EH()
    var_0001 = unknown_0035H(0, 20, 168, objectref)
    if var_0001 then
        var_0002 = unknown_0035H(0, 20, 577, objectref)
        var_0003 = 0
        for var_0004 in ipairs(var_0002) do
            var_0007 = unknown_0018H(var_0006)
            var_0008 = unknown_000EH(1, 981, var_0006)
            var_0009 = unknown_0018H(var_0008)
            if var_0009[1] == var_0007[1] and var_0009[2] == var_0007[2] and var_0009[3] == var_0007[3] + 2 and get_object_frame(var_0006) == get_object_frame(var_0008) then
                var_0003 = var_0003 + 1
                if var_0008 == eventid then
                    var_000A = unknown_0018H(var_0008)
                    unknown_0053H(-1, 2, -1, -1, var_000A[2], var_000A[1], 7)
                end
            end
        end
        if var_0003 == 3 then
            for var_000B in ipairs(var_0001) do
                unknown_006FH(var_000D)
            end
            if var_000D then
                unknown_0940H(14)
            end
        else
            for var_000E in ipairs(var_0001) do
                get_object_frame(var_000D, (get_object_frame(var_000D) % 8) + var_0003 * 8)
            end
        end
    end
end