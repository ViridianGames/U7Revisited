--- Best guess: Manages a loom mechanic, weaving thread (ID 261) into cloth, with dialogue prompting correct item use and updating item states.
function utility_loom_0302(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 7 then
        var_0000 = get_container(objectref)
        if not var_0000 then
            var_0001 = utility_unknown_0807(objectref, -356)
            var_0002 = get_object_position(objectref)
            var_0003 = set_last_created(objectref)
            if not var_0003 then
                var_0003 = give_last_created(-356)
                if not var_0003 then
                    var_0003 = update_last_created(var_0002)
                    flash_mouse(4)
                    return
                else
                    var_0003 = execute_usecode_array(-356, {1582, 17493, 17505, 17516, 8449, var_0001, 7769})
                end
            end
        else
            close_gumps()
        end
    elseif eventid == 2 or var_0000 then
        var_0004 = object_select_modal()
        var_0005 = get_object_shape(var_0004)
        if var_0005 == 261 then
            var_0006 = {-2, -1, 0}
            var_0007 = {1, 1, 1}
            var_0008 = -1
            utility_position_0808(7, var_0004, 261, var_0008, var_0007, var_0006, var_0004)
        else
            var_0009 = "@Why dost thou not weave cloth with that thread on the loom?@"
            utility_unknown_1023(var_0009)
        end
    end
end