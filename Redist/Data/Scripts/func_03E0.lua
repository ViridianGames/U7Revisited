require "U7LuaFuncs"
-- Function 03E0: Item interaction with array updates
function func_03E0(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid ~= 1 then
        return
    end

    calli_007E()
    local0 = {0, 8006, 3, 8006, 4, 8006, 17, 8024, 4, 8006, 3, 8006, 0, 8006, 1, 8006, 2, 8006, 17, 8024, 2, 8006, 1, 8006, 0, 7750}
    local1 = callis_0001(arra(local0, {2, -26, 7691}), itemref)

    return
end

-- Helper function
function arra(array, value)
    local new_array = {unpack(array)}
    table.insert(new_array, value)
    return new_array
end