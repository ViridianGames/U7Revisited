require "U7LuaFuncs"
-- Function 0940: Start NPC speech or trigger
function func_0940(eventid, itemref)
    if not start_speech(itemref) then
        call_0614H(0)
    else
        trigger_ferry()
    end
    return
end