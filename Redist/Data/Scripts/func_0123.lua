--- Best guess: Handles interaction with a specific item, changing its type to 322 and setting its frame to 2 when used.
function func_0123(eventid, itemref)
    if eventid == 1 then
        set_object_shape(322, itemref)
        unknown_0086H(itemref, 2)
    end
end