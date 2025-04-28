require "U7LuaFuncs"
-- Function 03A8: Item type switching
function func_03A8(eventid, itemref)
    if eventid == 2 then
        _SetItemType(936, itemref)
        return -- abrt
    elseif eventid == 1 then
        calli_006A(0)
        -- Note: Original has 'db 2c' here, ignored
        call_0832H(303, itemref)
    end
    return
end