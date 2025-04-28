require "U7LuaFuncs"
-- Function 0801: Check for bedroll
function func_0801(eventid, itemref)
    local local0, local1, local2

    local1 = _GetItemFrame(eventid)
    local2 = _GetItemType(eventid)
    if local1 == 17 and local2 == 1011 then
        set_return(true)
    else
        set_return(false)
    end
end