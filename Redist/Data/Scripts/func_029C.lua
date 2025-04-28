require "U7LuaFuncs"
-- Function 029C: Manages sword pickup and forging
function func_029C(itemref)
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    if eventid() == 1 then
        if callis_0072(-359, 623, 1, -356) then
            local0 = callis_000E(3, 991, itemref)
            if local0 then
                local1 = callis_0018(itemref)
                local2 = callis_0018(local0)
                if local1[1] == local2[1] and local1[2] == local2[2] and local1[3] == local2[3] + 1 then
                    local3 = callis_0012(itemref)
                    if local3 >= 10 and local3 <= 12 then
                        call_026FH(local0)
                    end
                end
            end
        end
        callis_007E()
        local4 = callis_0012(itemref)
        if local4 >= 8 and local4 <= 15 then
            if not callis_006E(itemref) then
                local5 = {-1, 1, 1, 0}
                local6 = {0, 1, 2, 0}
                call_0828H(7, itemref, 668, -3, local6, local5, itemref)
            elseif not call_0944H(itemref) then
                local7 = call_0945H(itemref)
                local5 = {1, -1, 1, 0}
                local6 = {0, 1, 2, 0}
                call_0828H(7, local7, 668, -3, local6, local5, local7)
            else
                callis_0001({668, 8021, 2, 7719}, itemref)
            end
        end
    elseif eventid() == 7 then
        local9 = call_092DH(itemref)
        callis_0001({668, 17493, 8033, 3, 17447, 8556, local9, 7769}, callis_001B(-356))
        callis_0001({1815, 8021, 3, 7719}, itemref)
    elseif eventid() == 2 then
        local10 = callis_002A(-359, -359, 668, callis_001B(-356))
        if not local10 then
            local11 = callis_0033()
            local12 = callis_0011(local11)
            if local12 == 991 and callis_0012(local11) == 1 then
                call_0828H(8, local11, 668, 0, 2, 0, local11)
            elseif local12 == 739 and callis_0012(local11) >= 4 and callis_0012(local11) <= 7 then
                call_0828H(9, local11, 668, 0, 0, 1, local11)
            elseif local12 == 741 then
                local3 = callis_0012(local10)
                if local3 >= 8 and local3 <= 12 then
                    call_0828H(10, local11, 668, 0, 1, 0, local11)
                else
                    callis_0040("@The sword's not hot.@", callis_001B(-356))
                end
            end
        else
            callis_0040("@I can't pick it up.@", callis_001B(-356))
        end
    elseif eventid() == 8 then
        local9 = call_092DH(itemref)
        callis_0001({8033, 3, 17447, 8556, local9, 7769}, callis_001B(-356))
        local10 = callis_002A(-359, -359, 668, callis_001B(-356))
        callis_0001({1675, 8021, 3, 7719}, local10)
    elseif eventid() == 9 then
        local9 = call_092DH(itemref)
        callis_0001({8033, 3, 17447, 8556, local9, 7769}, callis_001B(-356))
        local10 = callis_002A(-359, -359, 668, callis_001B(-356))
        callis_0001({1676, 8021, 3, 7719}, local10)
    elseif eventid() == 10 then
        local9 = call_092DH(itemref)
        callis_0001({8556, local9, 7769}, callis_001B(-356))
        callis_0001({1677, 8021, 5, 7719}, itemref)
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end