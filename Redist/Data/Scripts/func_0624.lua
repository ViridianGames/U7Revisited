require "U7LuaFuncs"
-- Manages bedroll retrieval and placement, handling events for interaction, state changes, and positioning in Trinsic.
function func_0624(eventid, itemref)
    local local0, local1, local2

    if eventid == 1 then
        external_007E() -- Unmapped intrinsic
        local0 = {-1, -1, -1, 0, 0, 0, 1, 1, 1}
        local1 = {1, 0, -1, 1, 0, -1, 1, 0, -1}
        add_item(-356, 7, 1572, local1, local0)
        set_schedule(itemref, 2, 1572)
    elseif eventid == 2 then
        set_item_type(itemref, 583)
        set_item_frame(itemref, 0)
    elseif eventid == 7 then
        external_007E() -- Unmapped intrinsic
        local2 = add_item(-356, {8033, 1, 17447, 17516, 17456, 7769})
        if not local2 then
            local2 = add_item(itemref, {1572, 8021, 2, 7719})
        end
    end
    return
end