--- Best guess: Initiates an object state change or interaction (linked to func_01B3), possibly for a chained mechanism or event trigger.
function object_unknown_0481(eventid, objectref)
    if eventid == 1 or eventid == 2 then
        -- call [0000] (0942H, unmapped)
        set_object_shape(objectref, 435)
    end
    --return
end