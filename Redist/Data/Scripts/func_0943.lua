-- Function 0943: Move object with offsets
function func_0943(eventid, itemref)
    local local0

    local0 = get_item_position(itemref)
    move_object(-1, 0, -2, -2, local0[2], local0[1], 24)
    return
end