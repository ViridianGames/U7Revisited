require "U7LuaFuncs"
-- Function 0941: Check speech and trigger
function func_0941(eventid, itemref)
    if not check_speech(itemref) then
        call_0614H(0)
    else
        trigger_ferry()
    end
    return
end