--- Best guess: Handles interaction with a specific item, changing its type to 322 and setting its frame to 2 when used.
function func_0123(eventid, objectref)
    if eventid == 1 then
        set_object_shape(objectref, 322)
        set_object_quality(objectref, 2)
    end
end