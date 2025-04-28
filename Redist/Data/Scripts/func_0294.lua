require "U7LuaFuncs"
-- Triggers an action for an item, possibly a generic use script.
function func_0294H(eventid, itemref)
    if eventid == 1 then
        call_script(0x0809, itemref) -- TODO: Map 0809H (possibly use_item or specific action).
    end
end