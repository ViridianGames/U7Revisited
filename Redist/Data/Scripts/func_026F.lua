-- Function 026F: Manages hammer-on-sword forging
function func_026F(itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid() == 1 then
        if not callis_0072(-359, 623, 1, -356) then
            callis_006A(2)
        end
        callis_007E()
        calle_0690H(itemref)
    elseif eventid() == 2 then
        local0 = false
        local1 = callis_0011(itemref)
        if local1 == 991 then
            local0 = callis_000E(1, 668, itemref)
        elseif local1 == 623 then
            local0 = callis_0033()
        end
        if local0 and callis_0011(local0) == 668 then
            local2 = callis_000E(3, 991, local0)
            if local2 then
                local3 = callis_0018(local2)
                local4 = callis_0018(local0)
                if local3[1] == local4[1] and local3[2] == local4[2] and local3[3] - 1 == local4[3] then
                    local5 = callis_0012(local0)
                    if local5 >= 8 and local5 <= 15 then
                        if local5 >= 13 and local5 <= 15 then
                            callis_0040("@The sword is not heated.@", callis_001B(-356))
                            callis_0001(local8, {7769}, callis_001B(-356))
                        elseif local5 == 8 or local5 == 9 then
                            callis_0040("@The sword is too cool.@", callis_001B(-356))
                            callis_0001(local8, {7769}, callis_001B(-356))
                        elseif local5 >= 10 and local5 <= 12 then
                            callis_0001({17505, 17508, 17511, 17509, 8548, local8, 7769}, callis_001B(-356))
                            local2 = callis_000E(3, 991, callis_001B(-356))
                            callis_0001({1681, 8021, 4, 7719}, local2)
                        end
                    end
                end
            end
        end
    elseif eventid() == 7 then
        local6 = callis_000E(3, 668, callis_001B(-356))
        local5 = callis_0012(local6)
        local7 = callis_001B(-356)
        local8 = call_092DH(itemref)
        if local5 >= 13 and local5 <= 15 then
            callis_0040("@The sword is not heated.@", local7)
            callis_0001(local8, {7769}, local7)
        elseif local5 == 8 or local5 == 9 then
            callis_0040("@The sword is too cool.@", local7)
            callis_0001(local8, {7769}, local7)
        elseif local5 >= 10 and local5 <= 12 then
            callis_0001({17505, 17508, 17511, 17509, 8548, local8, 7769}, local7)
            local2 = callis_000E(3, 991, callis_001B(-356))
            callis_0001({1681, 8021, 4, 7719}, local2)
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end