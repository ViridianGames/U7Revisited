require "U7LuaFuncs"
-- Function 02A6: Toggle item frame
function func_02A6(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid ~= 1 then
        return
    end

    local0 = _GetItemFrame(itemref)
    local1 = (local0 % 2 == 0) and 1 or -1
    local0 = local0 + local1
    _SetItemFrame(local0, itemref)

    return
end