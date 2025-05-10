--- Best guess: Toggles an object’s frame (incrementing or decrementing by 1) to create an animation effect, likely for a spinning or rotating object.
function func_02A6(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 % 2 == 0 then
            var_0001 = 1
        else
            var_0001 = -1
        end
        var_0000 = var_0000 + var_0001
        set_object_frame(objectref, var_0000)
    end
    return
end