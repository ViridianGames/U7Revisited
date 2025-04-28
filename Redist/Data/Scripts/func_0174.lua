require "U7LuaFuncs"
-- Changes an item's type and applies an effect on event ID 1.
function func_0174(p0)
    if get_event_id() == 1 then
        set_item_type(itemref, 290) -- Unmapped intrinsic
        external_0086H(itemref, 2) -- Unmapped intrinsic
    end
    return
end