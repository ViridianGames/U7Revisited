require "U7LuaFuncs"
-- Function 02BE: Cannon firing mechanics
function func_02BE(eventid, itemref)
    -- Local variables (14 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13

    if eventid == 1 then
        calli_007E()
        local0 = callis_0035(0, 10, 704, itemref) -- Powder
        local1 = callis_0035(0, 10, 703, itemref) -- Cannonballs
        if not local0 then
            call_08FEH("@It needs powder!@")
            -- Note: Original has 'db 2c' here, ignored
        end
        if not local1 then
            call_08FEH("@It needs cannon balls!@")
            -- Note: Original has 'db 2c' here, ignored
        end
        call_0925H(local0[1])
        call_0925H(local1[1])
        local2 = _ItemSelectModal()
        local3 = callis_0018(itemref)
        local4 = local2[2] - local3[1]
        local5 = local3[2] - local2[3]
        local6 = (local5 > local4 and call_0932H(local5) or call_0932H(local4)) > 0 and
                 (local4 > 0 and 2 or 6) or
                 (local5 > 0 and 4 or 0)
        _SetItemFrame(local6 // 2, itemref)
        calli_0076(702, 702, 30, 703, local6, itemref)
    elseif eventid == 4 then
        local7 = _GetItemType(itemref)
        local8 = _GetItemFrame(itemref)
        if local7 == 704 then
            local9 = callis_0002(1, {704, 17493, 7715}, itemref)
            -- Note: Original has 'db 2c' here, ignored
        end
        if local7 == 376 or local7 == 270 then
            local10 = {0, 1, 2, 8, 9, 10, 17, 18}
        elseif local7 == 433 or local7 == 432 then
            local10 = {0, 1, 2, 4, 5, 6}
        end
        while local10 do
            -- Note: Original has 'sloop' for iteration
            local13 = local10
            if local8 == local13 then
                calli_006F(itemref)
                break
            end
            local10 = next(local10)
        end
    end

    return
end