--- Best guess: Changes an object's shape (ID 935) on use or calls an external function (ID 876), possibly for a quest item or mechanism.
function object_porcullis_0935(eventid, objectref)
    if eventid == 2 then
        set_object_shape(objectref, 935)
        return
    elseif eventid == 1 then
        -- calli 006A, 1 (unmapped)
        flash_mouse(0)
    end
    -- call [0000] (0832H, unmapped)
    utility_event_0818(876, objectref)
    return
end