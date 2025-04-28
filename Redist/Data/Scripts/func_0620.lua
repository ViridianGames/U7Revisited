require "U7LuaFuncs"
-- Sets an item flag, possibly enabling a state like dancing.
function func_0620(eventid, itemref)
    set_flag(itemref, 15, true)
    return
end