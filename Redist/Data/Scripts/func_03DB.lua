require "U7LuaFuncs"
-- Function 03DB: Baby crying and transformation
function func_03DB(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid ~= 1 then
        return
    end

    calli_007E()
    local0 = {0, 8006, 3, 8006, 4, 8006, 17, 8024, 4, 8006, 3, 8006, 0, 8006, 1, 8006, 2, 8006, 17, 8024, 2, 8006, 1, 8006, 0, 7750}
    local1 = callis_0001(arra(local0, {2, -26, 7691}), itemref)
    if _Random2(1, 10) == 1 then
        local2 = callis_0018(itemref)
        _SetItemType(992, itemref)
        local3 = callis_0024(730)
        calli_0089(18, local3)
        calli_0089(11, local3)
        if local3 then
            local1 = callis_0026(local2)
            _ItemSay("@Whaaahh!!@", local3)
        end
    end

    return
end

-- Helper function
function arra(array, value)
    local new_array = {unpack(array)}
    table.insert(new_array, value)
    return new_array
end