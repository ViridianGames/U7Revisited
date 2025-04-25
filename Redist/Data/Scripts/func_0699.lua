-- Handles combat mechanics, checking item positions and applying directional effects to party members.
function func_0699(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16

    local0 = get_item_data(itemref)[6][8]
    local1 = external_0035H(16, 40, 275, local0) -- Unmapped intrinsic
    local2 = get_item_data(itemref)[6][9]
    local3 = external_0035H(16, 40, 275, local2) -- Unmapped intrinsic
    if local1 and local3 then
        local4 = get_item_data(local1[1])
        local5 = get_item_data(local3[1])
        local6 = external_0881H() -- Unmapped intrinsic
        external_003EH(local4, itemref) -- Unmapped intrinsic
        external_003EH(local5, external_001BH(-356)) -- Unmapped intrinsic
        if local6 then
            external_003EH(local5, local6) -- Unmapped intrinsic
        end
        local7 = 1
        local8 = get_party_members()
        local9 = local5
        for local10 in ipairs(local8) do
            local11 = local10
            local12 = local11
            if local7 == 1 then
                external_0009H(local5[1] - 2, local5[2], 9) -- Unmapped intrinsic
                external_0009H(local5[1] + 2, local5[2], 2) -- Unmapped intrinsic
            elseif local7 == 2 then
                external_0009H(local5[1] + 2, local5[2], 1) -- Unmapped intrinsic
                external_0009H(local5[1] + 2, local5[2], 2) -- Unmapped intrinsic
            elseif local7 == 3 then
                external_0009H(local5[1] - 4, local5[2], 1) -- Unmapped intrinsic
                external_0009H(local5[1] + 4, local5[2], 2) -- Unmapped intrinsic
            elseif local7 == 4 then
                external_0009H(local5[1], local5[2] + 4, 1) -- Unmapped intrinsic
                external_0009H(local5[1], local5[2] + 4, 2) -- Unmapped intrinsic
            elseif local7 == 5 then
                external_0009H(local5[1] + 4, local5[2], 1) -- Unmapped intrinsic
                external_0009H(local5[1] + 4, local5[2], 2) -- Unmapped intrinsic
            elseif local7 == 6 then
                external_0009H(local5[1] - 2, local5[2], 1) -- Unmapped intrinsic
                external_0009H(local5[1] + 6, local5[2], 2) -- Unmapped intrinsic
            elseif local7 == 7 then
                external_0009H(local5[1] + 2, local5[2], 1) -- Unmapped intrinsic
                external_0009H(local5[1] + 6, local5[2], 2) -- Unmapped intrinsic
            end
            if local12 == external_001BH(-356) then
                external_003EH(local9, local12) -- Unmapped intrinsic
                local13 = add_item(local12, {0, 7769})
                local7 = local7 + 1
            end
        end
        local14 = add_item(itemref, {1692, 8021, 2, 7975, 4, 7769})
        local15 = add_item(external_001BH(-356), {0, 7769})
        if external_005AH() then -- Unmapped intrinsic
            local16 = add_item(local6, {20, 7750})
        else
            local16 = add_item(local6, {18, 7750})
        end
    end
    return
end