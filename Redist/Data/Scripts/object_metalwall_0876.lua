--- Best guess: Changes an item's type to 876 on event ID 2 and triggers another action on event ID 1.
function object_metalwall_0876(eventid, objectref)
    if eventid == 2 then
        set_object_shape(objectref, 876)
        return
    elseif eventid == 1 then
        flash_mouse(0)
        -- Note: Unrecognized instruction '2c' at address 0020, treated as no-op
    end
    utility_event_0819(objectref, 935)
    return
end