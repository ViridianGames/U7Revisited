require "U7LuaFuncs"
-- Handles item type interactions (707, 760, or others), creating objects and triggering effects.
function func_0690(eventid, itemref)
    local local0, local1

    local0 = get_item_type(itemref)
    if local0 == 707 then
        local1 = add_item(itemref, {1782, 8021, 1, 7719})
    end
    if local0 == 760 then
        local1 = add_item(itemref, {1782, 8021, 1, 7719})
    end
    if eventid == 1 then
        local1 = add_item(itemref, {623, 8021, 1, 7719})
    elseif eventid == 2 then
        local1 = 1
        external_0691H(itemref) -- Unmapped intrinsic
    end
    return
end