--- Best guess: Handles a container or trap interaction, displaying a message ("It is about time!") and updating its state (e.g., opening a chest or triggering a trap) when activated.
function func_01B2(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        -- callis 0079, 1 (unmapped)
        if not unknown_0079H(itemref) then
            -- calli 005C, 1 (unmapped)
            unknown_005CH(itemref)
            start_conversation()
            add_dialogue("@It is about time!@")
        else
            -- calle 0629H, 1577 (unmapped)
            unknown_0629H(itemref)
        end
    elseif eventid == 8 then
        var_0000 = unknown_0018H(itemref)
        aidx(var_0000, 1, aidx(var_0000, 1) + 1)
        aidx(var_0000, 2, aidx(var_0000, 2) - 1)
        var_0001 = get_container_objects(359, 359, 810, 356)
        if var_0001 then
            var_0002 = unknown_0025H(var_0001)
            if var_0002 then
                set_object_frame(var_0001, 3)
                var_0002 = unknown_0026H(var_0000)
            end
            var_0002 = unknown_0001H({17516, 7937, 0, 7769}, 356)
        end
    end
    return
end