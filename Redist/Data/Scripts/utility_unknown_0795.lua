--- Best guess: Returns the modulo 4 of an item's frame, likely for state cycling.
function utility_unknown_0795(eventid, objectref)
    return get_object_frame(objectref) % 4
end