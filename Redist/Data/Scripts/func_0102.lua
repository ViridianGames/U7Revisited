--- Best guess: Manages a keg interaction, displaying a message and handling specific use cases, including filling containers.
function func_0102(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        if not unknown_0079H(itemref) then
            unknown_005CH(itemref)
            unknown_08FEH("@It is about time!@")
        else
            unknown_0628H(itemref)
        end
    elseif eventid == 8 then
        var_0000 = unknown_0018H(itemref)
        var_0000[1] = var_0000[1] - 2
        var_0000[2] = var_0000[2] + 1
        var_0001 = get_container_objects(-359, -359, 810, -356)
        if var_0001 then
            var_0002 = unknown_0025H(var_0001)
            if var_0002 then
                get_object_frame(var_0001, 4)
                var_0002 = unknown_0026H(var_0000)
            end
        end
        var_0002 = unknown_0001H({17516, 7937, 0, 7769}, -356)
    end
end