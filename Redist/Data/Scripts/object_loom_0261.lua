--- Best guess: Manages a loom interaction, creating thread and cloth items when used, with an error message if threading is incorrect.
function object_loom_0261(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 7 then
        halt_scheduled(objectref)
        var_0000 = execute_usecode_array({261, 8021, 32, -4, 7947, 6, 17496, 17409, 8014, 0, 7750}, objectref)
        var_0001 = utility_unknown_0807(objectref, -356)
        var_0000 = execute_usecode_array({9, -5, 7947, 1, 17447, 17505, 17511, 8449, var_0001, 7769}, -356)
    elseif eventid == 2 then
        var_0002 = get_container_objects(-359, -359, 654, -356)
        if var_0002 then
            remove_item(var_0002)
        end
        var_0003 = create_new_object(851)
        if var_0003 then
            set_item_flag(18, var_0003)
            get_object_frame(var_0003, random2(4, 0))
            var_0004 = get_object_position(objectref)
            var_0004[1] = var_0004[1] + 1
            var_0004[2] = var_0004[2] + 1
            var_0000 = update_last_created(var_0004)
        end
    elseif eventid == 1 then
        utility_unknown_1023("@I believe that one threads a loom before using it.@")
    end
end