require "U7LuaFuncs"
-- Function 0938: Check NPC combat ineligibility
function func_0938(eventid, itemref)
    itemref = call_0939H(itemref)
    if check_item_state(1, itemref) or
       check_item_state(7, itemref) or
       check_item_state(4, itemref) or
       _GetNPCProperty(3, itemref) <= 0 then
        set_return(true)
    else
        set_return(false)
    end
end