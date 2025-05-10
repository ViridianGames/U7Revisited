--- Best guess: Manages a soul cage’s interaction with a liche (ID 519), setting it up when the liche is sleeping, part of a quest.
function func_02EB(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        var_0001 = object_select_modal()
        if var_0000 == 0 then
            if get_object_shape(var_0001) == 519 then
                var_0002 = unknown_000EH(1, 1011, -141)
                if get_object_frame(var_0002) == 1 and unknown_001CH(-141) == 14 and get_object_frame(-141) == 13 then
                    -- calli 005C, 1 (unmapped)
                    unknown_005CH(-141)
                    var_0003 = unknown_0025H(objectref)
                    if var_0003 then
                        var_0003 = unknown_0018H(-141)
                        var_0003 = unknown_0026H(var_0003)
                        -- calli 001D, 2 (unmapped)
                        unknown_001DH(15, -141)
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