--- Best guess: Handles interaction with a specific item, changing its type to 372 and setting its frame to 2 when used.
function func_0122(eventid, itemref)
    if eventid == 1 then
        set_object_shape(372, itemref)
        unknown_0086H(itemref, 2)
    end
end