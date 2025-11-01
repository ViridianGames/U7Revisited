--- Best guess: Sets an item's type and frame when eventid is 2, likely for object state change or activation.
function utility_event_0277(eventid, objectref)
    if eventid == 2 then
        set_object_type(objectref, 754) --- Guess: Sets item type
        set_object_frame(objectref, 0)
    end
end