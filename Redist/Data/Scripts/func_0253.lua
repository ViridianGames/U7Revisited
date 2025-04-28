require "U7LuaFuncs"
-- Handles torch interaction, switching to lit torch state.
function func_0253H(eventid, itemref)
    if eventid == 1 or eventid == 2 then
        call_script(0x0942, 701, itemref) -- TODO: Map 0942H to specific Lua function or confirm script call.
    end
end