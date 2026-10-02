--- Best guess: Tests if an item is a bedroll (type 1011, frame 17).
---@param objectref integer The object reference to check
---@return boolean is_bedroll True if the object is a bedroll, false otherwise
function utility_unknown_0769(objectref)
    local var_0000, var_0001, var_0002

    var_0000 = objectref
    var_0001 = get_object_frame(var_0000) --- Guess: Gets item frame
    var_0002 = get_object_shape(var_0000) --- Guess: Gets item type
    if var_0001 == 17 and var_0002 == 1011 then
        return true
    else
        return false
    end
end