--- Best guess: Handles flour-related interactions, checking item frame and type, applying effects, and displaying messages.
function func_035F(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        var_0000 = get_object_frame(itemref)
        if var_0000 == 0 then
            var_0001 = unknown_0033H()
            var_0002 = unknown_0018H(var_0001)
            var_0003 = get_object_shape(var_0001)
            var_0004 = -1
            if var_0003 == 1018 then
                var_0004 = var_0002[1] - random2(3, 0)
                var_0005 = var_0002[2]
                var_0006 = var_0002[3] + 2
            elseif var_0003 == 1003 then
                var_0004 = var_0002[1]
                var_0005 = var_0002[2] - random2(2, 0)
                var_0006 = var_0002[3] + 2
            end
            if var_0004 == -1 then
                unknown_08FFH("@Why not put the flour on the table first?@", itemref)
            else
                var_0007 = unknown_0024H(658)
                if var_0007 then
                    unknown_0089H(18, var_0007)
                    get_object_frame(var_0007, 0)
                    var_0008 = unknown_0026H({var_0004, var_0005, var_0006})
                end
            end
        elseif var_0000 == 8 or var_0000 == 9 then
            var_0001 = unknown_0033H()
            if get_object_shape(var_0001) == 658 and get_object_frame(var_0001) == 2 then
                get_object_frame(var_0001, 1)
            end
            unknown_0933H("@Hey! That really hurt!@", var_0001, 0)
        elseif var_0000 == 13 or var_0000 == 14 then
            get_object_frame(itemref, 0)
        end
    end
    return
end