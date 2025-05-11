-- Open shutters (type 2)
function func_0142(eventid, objectref)
    if eventid == 1 then
        set_object_shape(objectref, 291) -- close them
        set_object_quality(objectref, 2)
    end
end