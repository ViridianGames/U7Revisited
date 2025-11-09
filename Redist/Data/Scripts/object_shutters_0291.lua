-- Closed shutters (type 2)
function object_shutters_0291(eventid, objectref)
    if eventid == 1 then
        set_object_shape(objectref, 322) -- open them
        set_object_quality(objectref, 2)
    end
end