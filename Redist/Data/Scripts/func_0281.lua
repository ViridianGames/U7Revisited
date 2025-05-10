--- Best guess: Manages a key, unlocking specific items (chests or doors) if quality matches, or relocking if already unlocked.
function func_0281(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        var_0000 = object_select_modal()
        unknown_0086H(itemref, 27)
        var_0001 = get_object_shape(var_0000)
        var_0002 = _get_object_quality(itemref)
        var_0003 = _get_object_quality(var_0000)
        if get_object_shape(var_0000[1]) in {433, 432, 270, 376} then
            if var_0002 == var_0003 then
                unknown_0815H(var_0000)
            end
        end
        if var_0001 == 522 then
            if var_0002 == var_0003 then
                bark("Unlocked", var_0000)
                set_object_shape(800, var_0000)
                if var_0003 == 253 then
                    set_flag(62, true)
                end
            end
        elseif var_0001 == 800 then
            if var_0002 == var_0003 then
                var_0004 = get_container_objects(-359, var_0002, 641, var_0000)
                var_0005 = false
                while var_0004 and not var_0005 do
                    if var_0004 == var_0000 then
                        var_0005 = true
                    else
                        var_0004 = unknown_006EH(var_0004)
                    end
                end
                if var_0005 then
                    bark("Key inside", -356)
                else
                    unknown_0080H(var_0000)
                    set_object_shape(522, var_0000)
                    bark("Locked", var_0000)
                end
            end
        end
    end
end