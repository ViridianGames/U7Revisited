require "U7LuaFuncs"
-- Function 03F3: Bed action delegate
function func_03F3(eventid, itemref)
    if eventid == 1 then
        call_0800H(itemref)
    end
    return
end