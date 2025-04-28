require "U7LuaFuncs"
-- Triggers a sprite effect and creates items, likely for a magical or environmental effect involving a specific item.
function func_063C(eventid, itemref)
    local local0, local1

    set_schedule(1, 1, 12)
    local0 = add_item(-356, 0, 6, 376)
    if local0 then
        local1 = add_item(local0, 1, 6, {8006, 270, 7765})
    end
    return
end