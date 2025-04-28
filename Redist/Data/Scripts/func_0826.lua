require "U7LuaFuncs"
-- Function 0826: Check item type
function func_0826(eventid, itemref)
    local local0, local1

    local1 = {157, 779}
    if _GetItemType(eventid) == local1 then
        set_return(true)
    else
        set_return(false)
    end
end