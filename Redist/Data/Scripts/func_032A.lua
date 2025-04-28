require "U7LuaFuncs"
-- Function 032A: Manages bucket water usage
function func_032A(itemref)
    -- Local variables (35 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21, local22, local23, local24, local25, local26, local27, local28, local29, local30, local31, local32, local33, local34

    if eventid() == 1 then
        callis_007E()
        local0 = callis_0012(itemref)
        if local0 == 6 then
            return
        end
        if not callis_006E(itemref) then
            local1 = {-1, 0, -1, -1, 1, 1, 1, 0}
            local2 = {-1, 1, 0, -1, 1, 0, 1, 1}
            call_0828H(3, itemref, 810, -3, local2, local1, itemref)
        elseif not call_0944H(itemref) then
            callis_007E()
            local3 = call_0945H(itemref)
            local1 = {1, -1, 1, 0}
            local2 = {0, 1, 2, 0}
            call_0828H(3, itemref, 810, -3, local2, local1, local3)
        else
            callis_007E()
            callis_0001({810, 8021, 2, 7719}, itemref)
        end
    elseif eventid() == 3 then
        local3 = call_0945H(itemref)
        local5 = call_092DH(local3)
        if callis_0031(local3) then
            callis_0001({8033, 3, 17447, 8548, local5, 7769}, callis_001B(-356))
            callis_0001({810, 8021, 2, 7975, 1682, 8021, 3, 7719}, itemref)
        else
            callis_0001({8033, 3, 17447, 8556, local5, 7769}, callis_001B(-356))
            callis_0001({810, 8021, 2, 7975, 1682, 8021, 3, 7719}, itemref)
        end
    elseif eventid() == 2 then
        local0 = callis_0012(itemref)
        local6 = callis_0033()
        local7 = callis_0011(local6)
        if local7 == 721 or local7 == 989 then
            if local0 == 2 then
                callis_0040("@No, thank thee.@", callis_001B(-356))
            elseif local0 == 0 then
                callis_0040("@The bucket is empty.@", callis_001B(-356))
            else
                callis_0040("@Ahhh, how refreshing.@", callis_001B(-356))
                callis_0001({0, 7750}, itemref)
            end
        end
        if callis_0031(local6) then
            local1 = {-2, 0, 2, 0}
            local2 = {0, -2, 0, 2}
            if local0 == 0 then
                callis_0040("@The bucket is empty.@", callis_001B(-356))
            else
                callis_0001({50, -2, 7947, 1, 7719}, local6)
                call_0828H(4, local6, 810, 0, local2, local1, local6)
            end
        end
        if local7 == 741 then
            call_0828H(7, local6, 810, 0, {-4, -4, 1, 1, -2, -1, -2, -1}, {-1, -1, 0, 1, -2, -1, 1, 1})
        end
        if local7 == 719 then
            call_0828H(7, local6, 810, 0, {-1, 0, -1, 0, -2, -2, 1, 1}, {-1, -1, 1, 1, -2, -1, -2, -1})
        end
        if local7 == 739 then
            if callis_0012(local6) >= 4 and callis_0012(local6) <= 7 then
                call_0828H(8, local6, 810, 0, {-4, -4, -2, -1, 1, 1, -2, -1}, {-2, -1, -4, -4, -2, -1, 1, 1})
            else
                callis_0040("@The bucket is empty.@", callis_001B(-356))
            end
        end
        if local7 == 338 or local7 == 435 or local7 == 701 or local7 == 658 or local7 == 825 then
            local1 = {0, -2, 0, 2}
            local2 = {-2, 0, 0, 0}
            if local0 == 0 then
                callis_0040("@The bucket is empty.@", callis_001B(-356))
            else
                call_0828H(8, local6, 810, -5, local2, local1, local6)
            end
        end
        if local7 == 470 then
            if local0 == 0 then
                local8 = callis_000E(3, 470, callis_001B(-356))
                if not local8 then
                    call_0828H(9, local8, 810, 0, {-1, -1}, {-5, -5})
                end
            else
                callis_0040("@The bucket is full.@", callis_001B(-356))
            end
        end
        if local7 == 331 then
            if local0 == 0 then
                callis_0040("@The bucket is empty.@", callis_001B(-356))
            else
                local6 = call_093CH(local6[1])
                local6[1] = local6[1]
                local6[2] = local6[2] + 1
                callis_007D(10, itemref, 810, local6)
            end
        end
        local6[1] = local6[1]
        if local6[1] == 0 then
            if local0 == 0 then
                callis_0040("@The bucket is empty.@", callis_001B(-356))
            else
                local6 = call_093CH(local6[1])
                local6[2] = local6[2] + 1
                callis_007D(10, itemref, 810, local6)
            end
        end
    elseif eventid() == 4 then
        local10 = callis_002A(-359, -359, 810, callis_001B(-356))
        local0 = callis_0012(local10)
        local11 = call_092DH(itemref)
        local12 = (local11 + 4) % 8
        if local0 == 2 then
            callis_0001({5, 7463, "@Foul miscreant!@", 8018, 2, 8487, local12, 7769}, itemref)
        else
            callis_0001({5, 7463, "@Hey, stop that!@", 8018, 2, 8487, local12, 7769}, itemref)
        end
        callis_0001({17505, 17508, 8551, local11, 7769}, callis_001B(-356))
        callis_0001({0, 8006, 2, 7719}, local10)
    elseif eventid() == 7 then
        local16 = false
        local16 = callis_000E(5, 741, callis_001B(-356))
        if not local16 then
            local16 = callis_000E(5, 719, callis_001B(-356))
        end
        if not local16 then
            local0 = callis_0012(itemref)
            local17 = callis_0012(local16)
            if local0 > 1 then
                if local17 == 3 or local17 == 7 then
                    callis_0040("@The trough is full.@", callis_001B(-356))
                else
                    local18 = local17 + 1
                    local19 = 0
                end
            else
                if local17 == 0 or local17 == 4 then
                    callis_0040("@The trough is empty.@", callis_001B(-356))
                else
                    local18 = local17 - 1
                    local19 = 1
                end
            end
            local5 = call_092DH(local16)
            callis_0001({8033, 2, 17447, 8556, local5, 7769}, callis_001B(-356))
            callis_0001({40, 17496, 8449, local18, 8006, 2, 7719}, local16)
            callis_0001({local19, 8006, 2, 7719}, itemref)
        end
    elseif eventid() == 8 then
        local0 = callis_0012(local10)
        local7 = callis_0011(itemref)
        local21 = callis_0012(itemref)
        if local7 == 739 then
            if local21 == 4 then
                callis_0040("@There are only coals.@", callis_001B(-356))
            elseif local21 == 7 then
                callis_0001({17488, 17488, 17488, 7937, 1683, 7765}, itemref)
            elseif local21 == 6 then
                callis_0001({17488, 17488, 7937, 1683, 7765}, itemref)
            elseif local21 == 5 then
                callis_0001({17488, 7937, 1683, 7765}, itemref)
            end
            local5 = call_092DH(itemref)
            callis_0001({8033, 2, 17447, 8556, local5, 7769}, callis_001B(-356))
        end
        if local7 == 338 or local7 == 435 or local7 == 701 then
            local17 = callis_0018(itemref)
            if local21 == 16 then
                local18 = 2
                local5 = call_092DH(itemref)
                callis_0001({17447, "@I can't douse it.@", 8018, 1, 17505, 17508, 8551, local5, 7769}, callis_001B(-356))
            else
                local18 = 3
                local19 = callis_0014(itemref)
                if local7 == 338 then
                    local20 = 336
                elseif local7 == 435 then
                    local20 = 481
                elseif local7 == 701 then
                    local20 = 595
                end
                local21 = callis_0024(local20)
                callis_006F(itemref)
                local4 = callis_0015(local19, local21)
                callis_0013(local21, local19)
                callis_0026(local17)
                local5 = call_092DH(itemref)
                callis_0001({17505, 17508, 8551, local5, 7769}, callis_001B(-356))
            end
            if local17[3] == 2 or local17[3] == 3 then
                local18 = local18 + 1
            end
            if local17[3] == 4 or local17[3] == 5 then
                local18 = local18 + 2
            end
            if local17[3] == 6 or local17[3] == 7 then
                local18 = local18 + 3
            end
            if local17[3] == 8 or local17[3] == 9 then
                local18 = local18 + 4
            end
            if local17[3] == 10 or local17[3] == 11 then
                local18 = local18 + 5
            end
            if local17[3] == 12 or local17[3] == 13 then
                local18 = local18 + 6
            end
            callis_0053(-1, 0, 0, 0, local17[2] - local18, local17[1] - local18, 9)
            callis_000F(46)
        end
        if local7 == 825 then
            if local21 == 0 then
                callis_0040("@There are only coals.@", callis_001B(-356))
            else
                callis_0001({0, 7750}, itemref)
                local5 = call_092DH(itemref)
                callis_0001({8033, 2, 17447, 8556, local5, 7769}, callis_001B(-356))
                local17 = callis_0018(itemref)
                callis_0053(-1, 0, 0, 0, local17[2], local17[1], 9)
                callis_000F(46)
            end
        end
        if local7 == 658 then
            if local21 == 0 then
                local5 = call_092DH(itemref)
                callis_0001({8033, 2, 17447, 8556, local5, 7769}, callis_001B(-356))
                callis_0013(itemref, 2)
            end
        end
    elseif eventid() == 9 then
        local20 = callis_000E(10, 740, callis_001B(-356))
        local21 = callis_0012(local20)
        if local21 >= 0 and local21 <= 11 then
            local21 = 1
        elseif local21 >= 12 and local21 <= 23 then
            local21 = 13
        end
        callis_0001({8014, 1, 17447, 8014, 1, 17447, 8014, 1, 17447, 8014, 1, 17447, 8014, 2, 8487, local21, 8006, 1, 7719}, local20)
        callis_0001({17447, 8039, 1, 17447, 8036, 1, 17447, 8038, 1, 17447, 8037, 1, 7975, 4, 8025, 2, 17447, 8039, 2, 7769}, callis_001B(-356))
        callis_0001({1685, 8021, 17, 7719}, itemref)
    elseif eventid() == 10 then
        callis_0001({8033, 3, 17447, 8044, 0, 7769}, callis_001B(-356))
        callis_0001({1684, 8021, 3, 7719}, itemref)
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end