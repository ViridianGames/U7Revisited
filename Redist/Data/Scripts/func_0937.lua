require "U7LuaFuncs"
-- Function 0937: Check NPC combat readiness
function func_0937(eventid, itemref)
    if _GetNPCProperty(2, itemref) >= 10 and
       not check_item_state(1, itemref) and
       not check_item_state(7, itemref) and
       not check_item_state(4, itemref) and
       _GetNPCProperty(3, itemref) > 0 and
       is_npc(itemref) then
        set_return(true)
    else
        set_return(false)
    end
end