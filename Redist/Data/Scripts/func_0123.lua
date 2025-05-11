-- Closed shutters (type 2)
function func_0123(eventid, objectref)
    if eventid == 1 then
        set_object_shape(objectref, 322) -- open them
        set_object_quality(objectref, 2)
    end
end