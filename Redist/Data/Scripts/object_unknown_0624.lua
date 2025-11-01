--- Best guess: Manages a pickaxe, mining resources from trees (ID 932) if held, with specific frame and position checks.
function object_unknown_0624(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016

    if eventid == 1 then
        if not is_readied(-359, 624, 1, -356) then
            utility_unknown_1023("@Thou must hold that in thine hand.@")
            return
        end
        var_0000 = object_select_modal()
        var_0001 = get_object_shape(var_0000)
        if var_0001 == 932 then
            if get_object_frame(var_0000) == 2 or get_object_frame(var_0000) == 3 then
                var_0002 = {0, 1, 2}
                var_0003 = {2, 2, 2}
                var_0004 = {-5}
                utility_position_0808(7, objectref, 624, var_0004, var_0003, var_0002, var_0000)
                close_gumps()
            else
                utility_unknown_1023("It seems the tree will yield nothing of value.")
            end
        else
            utility_unknown_1023("It seems that a pick is not needed for that.")
        end
    elseif eventid == 7 then
        var_0005 = find_nearby(0, 3, 932, -356)
        for var_0006 in ipairs(var_0005) do
            var_0009 = get_object_frame(var_0008)
            if var_0009 == 2 or var_0009 == 3 then
                var_000A = utility_unknown_1069(var_0008)
            end
        end
        var_000B = execute_usecode_array({624, 8021, 1, 17447, 8039, 2, 17447, 8037, 2, 17447, 8039, 2, 17447, 8549, var_000A, 7769}, -356)
    elseif eventid == 2 then
        if not get_flag(801) then
            var_000C = create_new_object(203)
            get_object_frame(var_000C, 10)
            var_000D = update_last_created({4, 1561, 2426})
            var_000E = find_nearby(3, 0, 3, 932, -356)
            get_object_frame(var_000E, 3)
            set_flag(801, false)
        else
            var_000E = find_nearby(0, 3, 932, -356)
            for var_000F in ipairs(var_000E) do
                var_0009 = get_object_frame(var_000E)
                if var_0009 == 3 or var_0009 == 2 then
                    var_0011 = 0
                    while var_0011 < 3 do
                        var_0012 = create_new_object(912)
                        get_object_frame(var_0012, 3 - var_0011)
                        var_0013 = get_object_position(var_000E)
                        var_0013[1] = var_0013[1] + 1 + var_0011
                        var_0013[2] = var_0013[2] + 2
                        var_0013[3] = var_0013[3] - 3
                        var_0014 = update_last_created(var_0013)
                        var_0011 = var_0011 + 1
                    end
                end
            end
            var_0015 = find_nearby(0, 5, 810, var_000E)
            if not var_0015 then
                get_object_frame(var_0015, 2)
                var_0016 = set_item_quality(4, var_0015)
            end
        end
    end
end