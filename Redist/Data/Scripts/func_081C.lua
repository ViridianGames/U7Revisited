require "U7LuaFuncs"
-- Adjusts an item's frame based on a given offset.
function func_081C(offset, itemref)
    local local2, local3

    local2 = get_item_frame(itemref)
    local3 = local2 % 4
    set_item_frame(itemref, local2 - local3 + offset)
    return
end