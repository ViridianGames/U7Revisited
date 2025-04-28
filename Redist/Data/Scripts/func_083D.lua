require "U7LuaFuncs"
-- Processes triples game outcomes, displaying messages and handling payouts.
function func_083D()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21, local22

    if external_001CH(-232) == 9 then -- Unmapped intrinsic
        external_001DH(-232, 10) -- Unmapped intrinsic
    end
    local0 = external_083AH() -- Unmapped intrinsic
    local1 = external_083BH() -- Unmapped intrinsic
    local2 = local1[1]
    local3 = local1[2]
    local4 = external_083CH(local0) -- Unmapped intrinsic
    if not external_002FH(-232) then -- Unmapped intrinsic
        for local5 in ipairs(local4) do
            local6 = local5
            local7 = local6
            external_0089H(local7, 11) -- Unmapped intrinsic
        end
    end
    local8 = "@Too bad...@"
    if #local4 == 0 then
        external_0933H(0, local8, -232) -- Unmapped intrinsic
    end
    if local2 == 6 then
        if not local3 then
            local9 = {5, 5, 5}
            local10 = {3, 2, 1}
            local11 = 27
            local8 = "@Triples! On the two!@"
        else
            local9 = {3, 3, 3}
            local10 = {3, 2, 1}
            local11 = 4
            local8 = "@Full wheel!@"
        end
    elseif local2 == 9 then
        local9 = {7, 7, 7}
        local10 = {3, 2, 1}
        local11 = 27
        local8 = "@Triples! On the three!@"
    elseif local2 == 3 then
        local9 = {1, 1, 1}
        local10 = {3, 2, 1}
        local11 = 27
        local8 = "@Triples! On the one!@"
    elseif not local3 then
        local9 = {4, 4, 4}
        local10 = {3, 2, 1}
    elseif local2 == 4 then
        local9 = 2
        local10 = {3, 2, 1}
        local11 = 8
        local8 = "@Sum of 4!@"
    elseif local2 == 5 then
        local9 = 2
        local10 = 1
        local11 = 4
        local8 = "@Sum of 5!@"
    elseif local2 == 7 then
        local9 = 6
        local10 = 3
        local11 = 3
        local8 = "@Seven!@"
    elseif local2 == 8 then
        local9 = 6
        local10 = 1
        local11 = 8
        local8 = "@Big eight!@"
    end
    if get_flag(6) then
        local11 = local11 * 2
    end
    for local12 in ipairs(local4) do
        local13 = local12
        local7 = local13
        local14 = 0
        local15 = false
        for local16 in ipairs(local9) do
            local17 = local16
            local18 = local7
            local14 = local14 + 1
            local19 = get_item_data(local18)
            if local19[1] - local14 * local9[local14] + 1 == local0[1] and local19[2] - local14 * local10[local14] + 1 == local0[2] then
                local20 = external_0016H(local18, 9) -- Unmapped intrinsic
                local20 = local20 * local11
                if local20 > 100 then
                    local21 = get_item_by_type(644) -- Unmapped intrinsic
                    local22 = external_0017H(local21, 100) -- Unmapped intrinsic
                    local22 = set_item_data(local19)
                    local20 = local20 - 100
                else
                    local21 = get_item_by_type(644) -- Unmapped intrinsic
                    local22 = external_0017H(local21, local20) -- Unmapped intrinsic
                    local22 = set_item_data(local19)
                end
                local15 = true
            end
        end
        external_006FH(local7) -- Unmapped intrinsic
    end
    external_0933H(0, local8, -232) -- Unmapped intrinsic
    return
end