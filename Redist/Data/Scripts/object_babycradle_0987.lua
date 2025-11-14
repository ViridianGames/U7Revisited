--- Best guess: Spawns a screaming creature (ID 992) with a chance to cry out, possibly for a trap or ambush.
function object_babycradle_0987(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        -- calli 007E, 0 (unmapped)
        close_gumps()
        var_0000 = {0, 8006, 3, 8006, 4, 8006, 17, 8024, 4, 8006, 3, 8006, 0, 8006, 1, 8006, 2, 8006, 17, 8024, 2, 8006, 1, 8006, 0, 7750}
        var_0001 = execute_usecode_array(var_0000, objectref)
        if random2(10, 1) == 1 then
            var_0002 = get_object_position(objectref)
            set_object_shape(objectref, 992)
            var_0003 = create_new_object(730)
            set_item_flag(18, var_0003)
            set_item_flag(11, var_0003)
            if var_0003 then
                var_0001 = update_last_created(var_0002)
                bark(var_0003, "@Whaaahh!!@")
            end
        end
    end
    return
end