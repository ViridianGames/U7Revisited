require "U7LuaFuncs"
-- Clears an item flag, possibly disabling a state like dancing.
function func_061F(eventid, itemref)
    set_flag(itemref, 15, false)
    return
end