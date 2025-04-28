require "U7LuaFuncs"
-- Function 0828: Use bucket on item
function func_0828(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    if call_006EH(local6) then
        call_006AH(0)
        return
    end
    set_item_glow(-356)
    local7 = get_item_position(local6)
    if local5 < 0 and _ArraySize(local5) == 1 then
        local8 = local3
        while local8 <= 3 + local7[3] do
            if local8 >= local5 then
                local9[1] = local7[1] + local5
                local9[2] = local7[2] + local4
                local9[3] = local7[3] + local8
                if not call_007DH(local0, local1, local2, local9) then
                    return
                end
            end
            local8 = local8 + 1
        end
    else
        local12 = 0
        while local13 do
            local14 = local12 + 1
            local11 = local4[local14]
            local8 = local3[local14]
            local9[1] = local7[1] + local5[local14]
            local9[2] = local7[2] + local11
            if local3 < -1 then
                local9[3] = local7[3]
            elseif local3 == -1 then
                local9[3] = local7[3]
            else
                local9[3] = local7[3] + local8
            end
            if not call_007DH(local0, local1, local2, local9) then
                return
            end
            local13 = get_next_item() -- sloop
        end
    end
    call_006AH(0)
end