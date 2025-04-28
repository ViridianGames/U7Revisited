require "U7LuaFuncs"
-- Function 0804: Find and remove item
function func_0804(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    local3 = check_position(16, 30, local2, -356)
    local4 = 0
    while local5 do
        local7 = local5
        local8 = _GetItemFrame(local7)
        local9 = _GetItemQuality(local7)
        if local8 == local1 and (local9 == local0 or local0 == -359) then
            local4 = local7
        end
        local5 = get_next_item() -- sloop
    end
    if local4 then
        delete_item(local4)
    end
end