require "U7LuaFuncs"
-- Increments an item's quality and updates it, possibly for tracking usage or progression.
function func_0607(eventid, itemref)
    local local0

    local0 = get_item_quality(itemref) + 1
    set_item_quality(itemref, local0)
    return
end