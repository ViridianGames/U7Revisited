require "U7LuaFuncs"
-- Function 06BE: Applies item-specific effect
function func_06BE(eventid, itemref)
    if eventid == 3 then
        callis_0056(call_GetItemQuality(itemref))
    end

    return
end