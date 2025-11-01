--- Best guess: Handles flour-related interactions, checking item frame and type, applying effects, and displaying messages.
function object_unknown_0863(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 == 0 then
            var_0001 = click_on_item()
            var_0002 = get_object_position(var_0001)
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
                utility_unknown_1023("@Why not put the flour on the table first?@", objectref)
            else
                var_0007 = create_new_object(658)
                if var_0007 then
                    set_item_flag(18, var_0007)
                    get_object_frame(var_0007, 0)
                    var_0008 = update_last_created({var_0004, var_0005, var_0006})
                end
            end
        elseif var_0000 == 8 or var_0000 == 9 then
            var_0001 = click_on_item()
            if get_object_shape(var_0001) == 658 and get_object_frame(var_0001) == 2 then
                get_object_frame(var_0001, 1)
            end
            utility_unknown_1075("@Hey! That really hurt!@", var_0001, 0)
        elseif var_0000 == 13 or var_0000 == 14 then
            get_object_frame(objectref, 0)
        end
    end
    return
end