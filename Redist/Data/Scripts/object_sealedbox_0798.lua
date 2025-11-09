--- Best guess: Changes an item's type to 799 and sets its frame to 14 when event ID 1 is received, likely for a transformation or state change.
function object_sealedbox_0798(eventid, objectref)
    if eventid == 1 then
        --set_item_shape(799, objectref)
        set_object_quality(objectref, 14)
    end
    return
end