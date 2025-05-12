-- Open shutters (type 1)
function func_0174(eventid, objectref)
    if eventid == 1 then
        set_object_shape(objectref, 290) -- close them
        set_object_quality(objectref, 2)
    end
end