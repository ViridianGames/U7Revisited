require "U7LuaFuncs"
-- Function 02C4: Toggle item frame
function func_02C4(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid ~= 1 then
        return
    end

    local0 = _GetItemFrame(itemref)
    local1 = local0
    if local0 == 1 then
        local1 = 0
    elseif local0 == 0 then
        local1 = 1
    end
    calli_0086(28, itemref)
    _SetItemFrame(local1, itemref)

    return
end