--- Best guess: Handles interaction with a specific item, changing its type to 291 and setting its frame to 2 when used.
function func_0142(eventid, objectref)
    if eventid == 1 then
        set_object_shape(objectref, 291)
        set_object_quality(objectref, 2)
    end
end