require "U7LuaFuncs"
-- Manages game state transitions based on flags, likely for triggering events or cutscenes when specific conditions are met.
function func_060B(eventid, itemref)
    if eventid == 2 then
        if get_flag(31) and get_flag(32) then
            external_083D() -- Unmapped intrinsic
            return
        end
        if not get_flag(31) then
            set_flag(31, true)
            return
        end
        if not get_flag(32) then
            set_flag(32, true)
        end
    end
    return
end