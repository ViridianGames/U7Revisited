--- Best guess: Toggles an object’s frame (0 or 1) and sets quality (28), likely for a switch or toggleable object animation.
function func_02C4(eventid, itemref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = get_object_frame(itemref)
        var_0001 = var_0000
        if var_0000 == 1 then
            var_0001 = 0
        elseif var_0000 == 0 then
            var_0001 = 1
        end
        set_object_quality(itemref, 28)
        set_object_frame(itemref, var_0001)
    end
    return
end