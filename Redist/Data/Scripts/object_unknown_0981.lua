--- Best guess: Aligns an object (shape 577) with another's frame and position, possibly for a puzzle or placement mechanic.
function object_unknown_0981(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        var_0000 = object_select_modal()
        var_0001 = get_object_shape(var_0000)
        var_0002 = get_object_position(var_0000)
        if var_0001 == 577 and get_object_frame(var_0000) == get_object_frame(objectref) then
            var_0003 = set_last_created(objectref)
            if var_0003 then
                aidx(var_0002, 3, aidx(var_0002, 3) + 2)
                var_0003 = update_last_created(var_0002)
            end
        else
            -- calli 006A, 1 (unmapped)
            flash_mouse(0)
        end
        -- call [0000] (082EH, unmapped)
        var_0003 = utility_unknown_0814(objectref)
    end
    return
end