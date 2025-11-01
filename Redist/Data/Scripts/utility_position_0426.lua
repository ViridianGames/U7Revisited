--- Best guess: Manages the Avatar's initial appearance via a moongate, creating and positioning it relative to the Avatar's location.
function utility_position_0426(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 2 then
        var_0000 = create_new_object(157)
        if var_0000 then
            set_item_frame_rot(32, 356)
            var_0001 = get_object_position(356)
            var_0001[1] = var_0001[1] + 1
            var_0001[2] = var_0001[2] + 1
            var_0002 = update_last_created(var_0001)
            if var_0002 then
                var_0002 = execute_usecode_array(7981, {3, 1, 17419, 8016, 4, 8006, 5, 1, 17419, 8014, 4, 8006, 1560, 8021, 10, 1, 17419, 8014, 0, 7750}, var_0000)
            end
        end
    end
    return
end