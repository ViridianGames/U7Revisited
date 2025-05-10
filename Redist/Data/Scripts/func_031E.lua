--- Best guess: Changes an item’s type to 799 and sets its frame to 14 when event ID 1 is received, likely for a transformation or state change.
function func_031E(eventid, itemref)
    if eventid == 1 then
        unknown_000DH(799, itemref)
        set_object_quality(itemref, 14)
    end
    return
end