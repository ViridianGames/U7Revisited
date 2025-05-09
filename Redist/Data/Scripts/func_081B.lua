--- Best guess: Returns the modulo 4 of an item’s frame, likely for state cycling.
function func_081B(eventid, itemref)
    return get_object_frame(itemref) % 4
end