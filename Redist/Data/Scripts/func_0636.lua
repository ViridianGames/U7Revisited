require "U7LuaFuncs"
-- Fades in the palette and triggers a sprite effect, likely for a visual transition.
function func_0636(eventid, itemref)
    local local0

    set_schedule(1, 1, 12)
    if switch_talk_to(itemref, -356) then
        local0 = get_item_data(itemref)
        create_object(-1, 0, 0, 0, local0[2], local0[1], 7) -- Unmapped intrinsic
    end
    return
end