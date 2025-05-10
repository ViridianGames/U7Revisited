--- Best guess: Manages a door mechanic in the Courage region, checking flags (829, 830) to toggle door (ID 936) and metal wall (ID 303) states based on quality.
function func_070E(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    var_0000 = unknown_0035H(0, 1, 936, objectref)
    var_0001 = unknown_0035H(0, 1, 303, objectref)
    if not (get_flag(829) and get_flag(830)) then
        for var_0002 in ipairs(var_0001) do
            var_0005 = unknown_0018H(var_0004)
            var_0006 = _get_object_quality(var_0004)
            unknown_006FH(var_0004)
            var_0007 = unknown_0024H(936)
            get_object_frame(var_0007, 0)
            var_0008 = unknown_0015H(var_0006, var_0007)
            var_0008 = unknown_0026H(var_0005)
        end
    elseif get_flag(829) then
        for var_0009 in ipairs(var_0000) do
            var_0006 = _get_object_quality(var_0004)
            if var_0006 == 11 then
                var_0005 = unknown_0018H(var_0004)
                unknown_006FH(var_0004)
                var_0007 = unknown_0024H(936)
                get_object_frame(var_0007, 0)
                var_0008 = unknown_0015H(var_0006, var_0007)
                var_0008 = unknown_0026H(var_0005)
            end
        end
        for var_000B in ipairs(var_0001) do
            var_0006 = _get_object_quality(var_0004)
            if var_0006 == 12 then
                var_0005 = unknown_0018H(var_0004)
                unknown_006FH(var_0004)
                var_0007 = unknown_0024H(303)
                get_object_frame(var_0007, 4)
                var_0008 = unknown_0015H(var_0006, var_0007)
                var_0008 = unknown_0026H(var_0005)
            end
        end
    elseif get_flag(830) then
        for var_000D in ipairs(var_0001) do
            var_0005 = unknown_0018H(var_0004)
            var_0006 = _get_object_quality(var_0004)
            unknown_006FH(var_0004)
            var_0007 = unknown_0024H(303)
            get_object_frame(var_0007, 4)
            var_0008 = unknown_0015H(var_0006, var_0007)
            var_0008 = unknown_0026H(var_0005)
        end
    end
end