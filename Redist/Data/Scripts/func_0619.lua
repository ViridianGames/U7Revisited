require "U7LuaFuncs"
-- Triggers an action on an item and sets a flag, likely for a one-time event or state change.
function func_0619(eventid, itemref)
    trigger_action(itemref) -- Unmapped intrinsic
    set_flag(itemref, 1)
    return
end