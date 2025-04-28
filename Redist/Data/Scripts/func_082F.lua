require "U7LuaFuncs"
-- Manages the Rat Race game, updating rat positions and applying effects.
function func_082F()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21, local22, local23, local24, local25, local26, local27, local28, local29, local30, local31, local32

    local0 = external_0030H(763) -- Unmapped intrinsic
    local1 = external_0030H(764) -- Unmapped intrinsic
    if array_size(local1) == 4 and array_size(local0) == 2 then -- Unmapped intrinsic
        local2 = get_random(1, 4)
        local3 = get_item_data(local0[1])
        local4 = external_0035H(0, 10, 644, local0[1]) -- Unmapped intrinsic
        local5 = get_item_data(itemref)
        if get_time_hour() >= 15 or get_time_hour() <= 3 then -- Unmapped intrinsic
            for local6 in ipairs(local4) do
                local7 = local6
                local8 = local7
                local9 = get_item_data(local8)
                if local9[1] <= local3[1] and local9[1] >= local3[1] - 5 and local9[2] <= local3[2] + 8 and local9[2] >= local3[2] - 8 then
                    external_008AH(local8, 11) -- Unmapped intrinsic
                end
            end
        end
        local10 = {1548, 7765}
        local11 = {local10, 28, -1, 17419, 8013, 2, 7975, 0, 7750}
        local12 = {local10, 1, 7975, 28, -1, 17419, 8013, 1, 7975, 0, 7750}
        local13 = {local10, 14, -1, 17419, 8013, 7, 7975, 15, -1, 17419, 8013, 0, 7750}
        local14 = {local10, 28, -1, 17419, 8013, 1, 7975, 0, 7750}
        local15 = {local10, 2, 7975, 28, -1, 17419, 8013, 0, 7750}
        local16 = {local10, 14, -4, 17419, 8013, 2, 17447, 8013, 0, 7750}
        local17 = {local10, 14, -1, 17419, 8013, 7, 7975, 15, -1, 17419, 8013, 0, 7750}
        local18 = {local10, 2, -1, 17419, 8014, 2, -1, 17419, 8016, 1, 7975, 28, -1, 17419, 8013, 1, 7975, 0, 7750}
        local19 = {2, 7719}
        local20 = {local19, 1, 7975}
        local21 = {local19, 1, 7975}
        local22 = {local19, 1, 7975}
        local23 = {local19, 1, 7975}
        local24 = {local19, 1, 7975}
        local25 = {local19, 1, 7975}
        local26 = {local19, 1, 7975}
        local27 = {local19, 1, 7975}
        local28 = 0
        for local29 in ipairs(local1) do
            local30 = local29
            local31 = local30
            if local2 == local28 then
                local32 = get_random(1, 3)
                if local32 == 1 then
                    local19 = local11
                elseif local32 == 2 then
                    local19 = local12
                elseif local32 == 3 then
                    local19 = local13
                elseif local32 == 4 then
                    local19 = local14
                elseif local32 == 5 then
                    local19 = local15
                end
            else
                local32 = get_random(1, 8)
                if local32 == 1 then
                    local19 = local20
                elseif local32 == 2 then
                    local19 = local21
                elseif local32 == 3 then
                    local19 = local22
                elseif local32 == 4 then
                    local19 = local23
                elseif local32 == 5 then
                    local19 = local24
                elseif local32 == 6 then
                    local19 = local25
                elseif local32 == 7 then
                    local19 = local26
                elseif local32 == 8 then
                    local19 = local27
                end
            end
            external_005CH(local31) -- Unmapped intrinsic
            local19 = add_item(local31, local19)
            local28 = local28 + 1
        end
    end
    return
end