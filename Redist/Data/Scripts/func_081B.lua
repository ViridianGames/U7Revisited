-- Returns the item frame modulo 4.
function func_081B(eventid, itemref)
    return get_object_frame(itemref) % 4
end