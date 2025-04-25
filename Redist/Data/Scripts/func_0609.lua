-- Decrements an item's quality and updates it, possibly for tracking usage or degradation.
function func_0609(eventid, itemref)
    local local0

    local0 = get_item_quality(itemref) - 1
    set_item_quality(itemref, local0)
    return
end