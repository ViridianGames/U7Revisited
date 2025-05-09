--- Best guess: Tests if an item is a bedroll (type 1011, frame 17).
function func_0801(eventid, itemref)
    local var_0000, var_0001, var_0002

    var_0000 = itemref
    var_0001 = get_item_frame(var_0000) --- Guess: Gets item frame
    var_0002 = get_item_type(var_0000) --- Guess: Gets item type
    if var_0001 == 17 and var_0002 == 1011 then
        return true
    else
        return false
    end
end