--- SealedBox: Changes an item's type to 799 and sets its frame to 14 to unseal it
function object_sealedbox_0798(eventid, objectref)
    if eventid == 1 then
        set_object_shape(objectref, 799)
        set_object_quality(objectref, 14)
    end
end