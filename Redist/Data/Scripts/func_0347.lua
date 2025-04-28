require "U7LuaFuncs"
-- Triggers Time Lord dialogue when using an hourglass under specific conditions.
function func_0347H(eventid, itemref)
    if eventid == 1 then
        local frame = get_item_frame(itemref)
        if frame == 1 and not get_flag(0x0004) then
            local state = check_item_state(617) -- TODO: Implement LuaCheckItemState for callis 001B.
            call_script(0x0269, state)
            set_stat(itemref, 67)
        end
    end
end