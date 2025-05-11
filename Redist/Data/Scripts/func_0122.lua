-- Closed shutters (type 1)
function func_0122(eventid, objectref)
    if eventid == 1 then
        set_object_shape(objectref, 372) -- open them
        set_object_quality(objectref, 2)
    end
end