--- Best guess: Manages a keg interaction, displaying a message and handling specific use cases, including filling containers.
function object_chest_0258(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        if not in_usecode(objectref) then
            halt_scheduled(objectref)
            utility_unknown_1022("@It is about time!@")
        else
            utility_unknown_0296(objectref)
        end
    elseif eventid == 8 then
        var_0000 = get_object_position(objectref)
        var_0000[1] = var_0000[1] - 2
        var_0000[2] = var_0000[2] + 1
        var_0001 = get_container_objects(-359, -359, 810, -356)
        if var_0001 then
            var_0002 = set_last_created(var_0001)
            if var_0002 then
                get_object_frame(var_0001, 4)
                var_0002 = update_last_created(var_0000)
            end
        end
        var_0002 = execute_usecode_array({17516, 7937, 0, 7769}, -356)
    end
end