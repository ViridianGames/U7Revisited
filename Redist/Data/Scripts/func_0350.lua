require "U7LuaFuncs"
-- Triggers a specific effect or scene transition when using an item with frame 3.
function func_0350H(eventid, itemref)
    if eventid == 1 then
        local frame = get_item_frame(itemref)
        if frame == 3 then
            local arr = {7768, 67, 7937, 17486, 17447, 4, 7947, -3, 4, 7975, 2, 8021, 1782}
            execute_action(itemref, arr) -- TODO: Implement LuaExecuteAction for callis 0001.
        end
    elseif eventid == 2 then
        set_flag(0x032F, true)
        call_script(0x06F6, itemref) -- TODO: Map 06F6H (possibly scene transition).
    end
end