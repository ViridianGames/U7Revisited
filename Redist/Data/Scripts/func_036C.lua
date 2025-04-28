require "U7LuaFuncs"
-- Function 036C: Manages item type transformation
function func_036C(itemref)
    if eventid() == 2 then
        _SetItemType(876, itemref)
        abort()
    elseif eventid() == 1 then
        callis_006A(0)
        call_0833H(935, itemref)
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function abort()
    -- Placeholder
end