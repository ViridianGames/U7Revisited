--- Best guess: Changes an object’s shape (ID 935) on use or calls an external function (ID 876), possibly for a quest item or mechanism.
function func_03A7(eventid, objectref)
    if eventid == 2 then
        set_object_shape(objectref, 935)
        return
    elseif eventid == 1 then
        -- calli 006A, 1 (unmapped)
        unknown_006AH(0)
    end
    -- call [0000] (0832H, unmapped)
    unknown_0832H(876, objectref)
    return
end