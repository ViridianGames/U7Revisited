--- Best guess: Toggles an item’s frame (e.g., on/off state) by incrementing or decrementing based on its current frame.
function func_0291(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 % 2 == 0 then
            var_0001 = 1
        else
            var_0001 = -1
        end
        var_0000 = var_0000 + var_0001
        get_object_frame(var_0000, objectref)
    end
end
 |contentType="text/x-lua">
--- Best guess: Toggles an item’s frame (e.g., on/off state) by incrementing or decrementing based on its current frame.
function func_0291(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 % 2 == 0 then
            var_0001 = 1
        else
            var_0001 = -1
        end
        var_0000 = var_0000 + var_0001
        get_object_frame(var_0000, objectref)
    end
end