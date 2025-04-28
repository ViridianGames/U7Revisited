require "U7LuaFuncs"
-- Function 0939: Validate NPC ID
function func_0939(eventid, itemref)
    local local0

    if itemref < 0 and itemref >= -356 then
        local0 = call_001BH(itemref)
    else
        local0 = itemref
    end
    set_return(local0)
end