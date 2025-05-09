--- Best guess: Aligns an object (shape 577) with another’s frame and position, possibly for a puzzle or placement mechanic.
function func_03D5(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        var_0000 = item_select_modal()
        var_0001 = get_object_shape(var_0000)
        var_0002 = unknown_0018H(var_0000)
        if var_0001 == 577 and get_object_frame(var_0000) == get_object_frame(itemref) then
            var_0003 = unknown_0025H(itemref)
            if var_0003 then
                aidx(var_0002, 3, aidx(var_0002, 3) + 2)
                var_0003 = unknown_0026H(var_0002)
            end
        else
            -- calli 006A, 1 (unmapped)
            unknown_006AH(0)
        end
        -- call [0000] (082EH, unmapped)
        var_0003 = unknown_082EH(itemref)
    end
    return
end