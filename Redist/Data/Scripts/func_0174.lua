--- Best guess: Handles interaction with a specific item, changing its type to 290 and setting its frame to 2 when used.
function func_0174(eventid, objectref)
    if eventid == 1 then
        set_object_shape(objectref, 290)
        set_object_quality(objectref, 2)
    end
end