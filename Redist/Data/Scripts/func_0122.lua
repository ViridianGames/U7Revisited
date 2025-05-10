--- Best guess: Handles interaction with a specific item, changing its type to 372 and setting its frame to 2 when used.
function func_0122(eventid, objectref)
    if eventid == 1 then
        set_object_shape(objectref, 372)
        set_object_quality(objectref, 2)
    end
end