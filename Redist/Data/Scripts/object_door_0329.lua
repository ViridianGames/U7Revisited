--- Best guess: Handles a storm cloak interaction, moving it to specific coordinates or displaying an error if used indoors.
function object_door_0329(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if not in_usecode(objectref) then
        return
    end
    if eventid == 1 then
        var_0000 = get_container(objectref)
        if not var_0000 then
            var_0001 = get_object_position(-356)
            var_0001[1] = var_0001[1] + 1
            var_0002 = set_last_created(objectref)
            if not var_0002 then
                var_0002 = update_last_created(var_0001)
            end
        end
        if not in_gump_mode() then
            close_gumps()
        end
        var_0003 = -1
        var_0004 = -1
        var_0005 = -2
        utility_position_0808(7, objectref, 329, var_0005, {var_0004, var_0003})
    elseif eventid == 7 then
        if not is_pc_inside() then
            var_0002 = execute_usecode_array(objectref, {0, 14, -1, 17419, 8015, 3, -3, 17419, 8013, 2, 7975, 3, -1, 17419, 8016, 5, 7975, 14, -1, 17419, 8013, 0, 7750})
            var_0002 = execute_usecode_array(-356, {7, -6, 7947, 2, 17447, 8033, 2, 17447, 8037, 6, 17497, 17505, 7788})
        else
            utility_unknown_1022("@Try it outside!@")
        end
    end
end