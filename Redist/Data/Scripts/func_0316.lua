require "U7LuaFuncs"
-- Handles interaction with an item, warning against wasting it if conditions aren’t met.
function func_0316H(eventid, itemref)
    if eventid == 1 then
        local target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
        if get_wearer(target) then -- TODO: Implement LuaGetWearer for callis 0031.
            set_item_quality(target, 0)
        elseif get_item_shape(target, 18) then -- TODO: Implement LuaGetItemShape for callis 0088.
            set_item_quality(target, 0)
        else
            say(0, "Do not waste that!")
        end
        set_stat(itemref, 67)
        call_script(0x0925, itemref) -- TODO: Map 0925H (possibly item cleanup).
    end
end