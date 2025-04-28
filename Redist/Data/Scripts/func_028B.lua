require "U7LuaFuncs"
-- Function 028B: Manages spinning wheel crafting
function func_028B(itemref)
    -- Local variables (7 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid() == 7 then
        local0 = callis_0035(0, 1, 873, -356)
        local1 = 0
        if callis_005E(local0) > 0 then
            local2 = callis_0001({12, -1, 17419, 17515, 8044, 6, 7769}, -356)
            local1 = 3
        end
        callis_005C(itemref)
        local2 = callis_0002(local1, {651, 8021, 12, -4, 7947, 6, 17496, 17409, 8014, 0, 7750}, itemref)
    elseif eventid() == 2 then
        local3 = callis_002A(-359, -359, 653, -356)
        if local3 then
            callis_006F(local3)
        end
        local4 = callis_0024(654)
        if local4 then
            callis_0089(18, local4)
            callis_0089(11, local4)
            callis_0013(9 + callis_0010(0, 9), local4)
            local5 = callis_0018(itemref)
            local5[1] = local5[1] + 1
            local5[2] = local5[2] + 1
            local2 = callis_0026(local5)
        end
    elseif eventid() == 1 then
        local6 = "@I suspect spinning the wool will be more fruitful than spinning an empty wheel.@"
        call_08FFH(local6)
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end