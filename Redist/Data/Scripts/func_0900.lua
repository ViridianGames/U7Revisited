require "U7LuaFuncs"
-- Function 0900: Random party member selection
function func_0900(eventid, itemref)
    local random = _Random2(10, 1)
    if random < 4 then
        set_return(call_0902H())
    else
        set_return(call_0901H())
    end
end