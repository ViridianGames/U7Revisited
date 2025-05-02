-- Handles a complex combat sequence with item type checks and container interactions.
function func_070F(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20

    local0 = get_item_type(itemref)
    if local0 == 466 then
        local1 = get_item_data(external_001BH(-356)) -- Unmapped intrinsic
        create_object(-1, 0, 0, 0, local1[2], local1[1], 17) -- Unmapped intrinsic
        apply_effect(62) -- Unmapped intrinsic
        local2 = external_0035H(8, 80, -1, external_001BH(-356)) -- Unmapped intrinsic
        for local3 in ipairs(local2) do
            local4 = local3
            local5 = local4
            local6 = get_item_type(local5)
            if local6 == 721 or local6 == 989 then
                if external_003CH(local5) == 0 then -- Unmapped intrinsic
                    external_003DH(local5, 2) -- Unmapped intrinsic
                    external_001DH(local5, 0) -- Unmapped intrinsic
                end
            end
        end
        local7 = get_item_data(itemref)
        local8 = get_item_by_type(414) -- Unmapped intrinsic
        external_006BH(itemref) -- Unmapped intrinsic
        external_006CH(local8, itemref) -- Unmapped intrinsic
        set_object_frame(local8, 30)
        external_003FH(-23) -- Unmapped intrinsic
        local9 = set_item_data(local7)
        local10 = get_item_by_type(797) -- Unmapped intrinsic
        set_object_frame(local10, 0)
        local9 = external_0015H(local10, 43) -- Unmapped intrinsic
        local9 = set_item_data(local7)
        local11 = add_item(local8, {797, 17493, 17443, 7724})
    elseif not external_0088H(external_001BH(-356), 18) then -- Unmapped intrinsic
        external_0049H(itemref) -- Unmapped intrinsic
        local2 = external_0035H(8, 80, -1, external_001BH(-356)) -- Unmapped intrinsic
        for local12 in ipairs(local2) do
            local13 = local12
            local5 = local13
            local6 = get_item_type(local5)
            if local6 == 721 or local6 == 989 then
                if external_003CH(local5) == local0 then -- Unmapped intrinsic
                    external_003DH(local5, 2) -- Unmapped intrinsic
                    external_001DH(local5, 0) -- Unmapped intrinsic
                end
            end
        end
        apply_effect(4) -- Unmapped intrinsic
        local14 = get_container_items(-359, 797, 243, itemref) -- Unmapped intrinsic
        if local14 then
            local15 = get_item_quality(local14)
            local11 = false
            if local15 == 240 then
                set_flag(750, true)
                local12 = get_item_data(itemref)
                local11 = get_item_by_type(762) -- Unmapped intrinsic
                external_006BH(itemref) -- Unmapped intrinsic
                external_006CH(local11, itemref) -- Unmapped intrinsic
                set_object_frame(local11, 22)
                external_08E6H(itemref) -- Unmapped intrinsic
                local9 = set_item_data(local12)
            elseif local15 == 241 then
                set_flag(751, true)
                local12 = get_item_data(itemref)
                local11 = get_item_by_type(778) -- Unmapped intrinsic
                external_006BH(itemref) -- Unmapped intrinsic
                external_006CH(local11, itemref) -- Unmapped intrinsic
                set_object_frame(local11, 7)
                external_08E6H(itemref) -- Unmapped intrinsic
                local9 = set_item_data(local12)
            end
            local16 = get_item_by_type(797) -- Unmapped intrinsic
            external_0089H(local16, 18) -- Unmapped intrinsic
            local9 = external_0015H(local16, local15) -- Unmapped intrinsic
            local17 = add_item(local16, {1783, 17493, 17443, 7724})
            local18 = add_item(local11, {8033, 2, 17447, 8048, 3, 7719})
        end
        local2 = external_0035H(8, 80, -1, external_001BH(-356)) -- Unmapped intrinsic
        for local19 in ipairs(local2) do
            local20 = local19
            local5 = local20
            local6 = get_item_type(local5)
            if local6 == 721 or local6 == 989 then
                if external_003CH(local5) == local0 then -- Unmapped intrinsic
                    external_003DH(local5, 2) -- Unmapped intrinsic
                    external_001DH(local5, 0) -- Unmapped intrinsic
                end
            end
        end
    end
    return
end