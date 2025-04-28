require "U7LuaFuncs"
-- Function 02DE: Item frame toggle with array updates
function func_02DE(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid ~= 1 then
        return
    end

    if not callis_0079(itemref) then
        local1 = _GetItemFrame(itemref)
        if local1 < 5 then
            _SetItemFrame(0, itemref)
            local0 = callis_0001({4, -3, 17419, 8014, 35, 7768}, itemref)
        else
            calli_0086(35, itemref)
            if local1 == 11 then
                local0 = callis_0001({35, 8024, 1, -3, 17419, 8014, 34, 7768}, itemref)
            elseif local1 == 12 then
                local0 = callis_0001({0, 8006, 35, 8024, 12, 8006, 35, 7768}, itemref)
            elseif local1 == 12 then
                calli_0086(35, itemref)
                _SetItemFrame(0, itemref)
            end
        end
    end

    return
end