require "U7LuaFuncs"
-- Function 02C3: Item interaction with script call
function func_02C3(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    if eventid == 1 then
        calle_06F6H(itemref)
    elseif eventid == 2 then
        if _GetItemType(itemref) == 990 then
            calli_008C(0, 1, 12)
            local0 = callis_0001({990, 8021, 3, 7719}, itemref)
        end
    end

    return
end