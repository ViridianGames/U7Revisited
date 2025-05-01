-- Handles interaction with an item, warning against wasting it if no wearer is present.
function func_0288H(eventid, itemref)
    if eventid == 1 then
        local target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
        if get_wearer(target) then -- TODO: Implement LuaGetWearer for callis 0031.
            set_item_quality(target, 1) -- TODO: Implement LuaSetItemQuality for calli 0089.
        else
            add_dialogue(0, "Do not waste that!")
        end
        call_script(0x0925, itemref) -- TODO: Map 0925H (possibly item cleanup or state update).
    end
end