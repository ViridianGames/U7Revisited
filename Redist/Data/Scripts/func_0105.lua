--- Best guess: Manages a loom interaction, creating thread and cloth items when used, with an error message if threading is incorrect.
function func_0105(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 7 then
        unknown_005CH(itemref)
        var_0000 = unknown_0001H({261, 8021, 32, -4, 7947, 6, 17496, 17409, 8014, 0, 7750}, itemref)
        var_0001 = unknown_0827H(itemref, -356)
        var_0000 = unknown_0001H({9, -5, 7947, 1, 17447, 17505, 17511, 8449, var_0001, 7769}, -356)
    elseif eventid == 2 then
        var_0002 = get_container_objects(-359, -359, 654, -356)
        if var_0002 then
            unknown_006FH(var_0002)
        end
        var_0003 = unknown_0024H(851)
        if var_0003 then
            unknown_0089H(18, var_0003)
            get_object_frame(var_0003, random2(4, 0))
            var_0004 = unknown_0018H(itemref)
            var_0004[1] = var_0004[1] + 1
            var_0004[2] = var_0004[2] + 1
            var_0000 = unknown_0026H(var_0004)
        end
    elseif eventid == 1 then
        unknown_08FFH("@I believe that one threads a loom before using it.@")
    end
end