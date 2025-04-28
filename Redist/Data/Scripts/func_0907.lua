require "U7LuaFuncs"
-- Function 0907: Process item ownership
function func_0907(eventid, itemref)
    set_return(call_0036H(call_001BH(itemref)))
end