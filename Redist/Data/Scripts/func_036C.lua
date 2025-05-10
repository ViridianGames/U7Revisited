--- Best guess: Changes an item’s type to 876 on event ID 2 and triggers another action on event ID 1.
function func_036C(eventid, objectref)
    if eventid == 2 then
        set_object_shape(objectref, 876)
        return
    elseif eventid == 1 then
        unknown_006AH(0)
        -- Note: Unrecognized instruction '2c' at address 0020, treated as no-op
    end
    unknown_0833H(objectref, 935)
    return
end