require "U7LuaFuncs"
-- Function 06DA: Triggers item or environmental effect
function func_06DA(eventid, itemref)
    if eventid == 3 then
        call_0836H(-359, itemref)
    end

    return
end