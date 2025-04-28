require "U7LuaFuncs"
-- Manipulates an item's quality and type, likely for transforming objects (e.g., ore to ingot) based on specific item types, with a fallback action if quality is non-zero.
function func_0600(eventid, itemref)
    local local0, local1, local2, local3

    local0 = get_item_quality(itemref) - 1
    local1 = set_item_quality(itemref, local0)
    if local0 == 0 then
        trigger_action(itemref) -- Unmapped intrinsic
        local2 = get_item_type(itemref)
        if local2 == 338 then
            set_item_type(itemref, 997)
        elseif local2 == 701 then
            set_item_type(itemref, 595)
            local1 = set_item_quality(itemref, 255)
        elseif local2 == 435 then
            set_item_type(itemref, 535)
        end
        apply_effect(106) -- Unmapped intrinsic
    else
        local3 = add_item(50, {1536, 7765}, itemref)
    end
    return
end