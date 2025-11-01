--- Best guess: Manages a soul cage's interaction with a liche (ID 519), setting it up when the liche is sleeping, part of a quest.
function object_unknown_0747(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        var_0001 = object_select_modal()
        if var_0000 == 0 then
            if get_object_shape(var_0001) == 519 then
                var_0002 = find_nearest(1, 1011, -141)
                if get_object_frame(var_0002) == 1 and get_schedule_type(-141) == 14 and get_object_frame(-141) == 13 then
                    -- calli 005C, 1 (unmapped)
                    halt_scheduled(-141)
                    var_0003 = set_last_created(objectref)
                    if var_0003 then
                        var_0003 = get_object_position(-141)
                        var_0003 = update_last_created(var_0003)
                        -- calli 001D, 2 (unmapped)
                        set_schedule_type(15, -141)
                        set_flag(431, true)
                    end
                end
            end
        elseif var_0000 == 1 then
            if get_object_shape(var_0001) == 748 then
                set_object_frame(objectref, 0)
            end
        end
    end
    return
end