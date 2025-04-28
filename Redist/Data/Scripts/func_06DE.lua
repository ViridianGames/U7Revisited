require "U7LuaFuncs"
-- Function 06DE: Triggers item or environmental effect
function func_06DE(eventid, itemref)
    if eventid == 3 then
        call_0836H(0, itemref)
    end

    return
end