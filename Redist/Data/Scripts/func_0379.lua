require "U7LuaFuncs"
-- Likely handles lamppost interaction or state change in Trinsic.
-- Checks event IDs (1 or 2), performs item checks, and modifies item properties (type, frame).
-- Uses random frame selection and sets item state, possibly for lighting or animation.

function func_0379(eventid, itemref)
    local local0, local1 = 0, 0

    if eventid == 1 or eventid == 2 then
        if has_item(440) then
            local0 = 1
            if local0 ~= 0 then
                local1 = get_item_type(itemref)
                set_item_frame(1, get_item_frame(1) + 3)
                set_item_frame(2, get_item_frame(2) + 3)
                set_item_frame(local0, math.random(0, 7))
                if get_item_info(local1) ~= 0 then
                    set_item_type(itemref, 526)
                    apply_effect(itemref, 106)
                end
            end
        end
    end
    return
end