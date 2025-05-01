-- Summons a creature or triggers combat effects based on item type and quality.
function func_070A(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21, local22, local23, local24, local25, local26, local27, local28, local29, local30, local31, local32, local33, local34, local35, local36, local37, local38, local39, local40, local41, local42, local43, local44, local45

    if eventid == 3 then
        if not get_item_quality(itemref) and not get_flag(827) then
            set_flag(827, true)
            local0 = external_000EH(0, 154, itemref) -- Unmapped intrinsic
            if not local0 then
                local1 = get_item_by_type(641) -- Unmapped intrinsic
                set_item_frame(local1, 7)
                local2 = external_0015H(local1, 65) -- Unmapped intrinsic
                local2 = external_0036H(local0) -- Unmapped intrinsic
                bark(local0, "@I summon thee!@")
                local2 = add_item(external_001BH(-356), {22, 7719}) -- Unmapped intrinsic
                local2 = add_item(local0, {8033, 2, 17447, 8044, 1802, 17493, 7937, 3, 17447, 8045, 1, 17447, 8044, 2, 17447, 8033, 2, 17447, 8048, 3, 17447, 7791})
                local3 = external_0035H(0, 20, 336, itemref) -- Unmapped intrinsic
                for local4 in ipairs(local3) do
                    local5 = local4
                    local1 = local5
                    if get_item_frame(local1) == 7 or get_item_frame(local1) == 9 then
                        local6 = get_item_by_type(338) -- Unmapped intrinsic
                        set_item_frame(local1, get_item_frame(local6))
                        local2 = set_item_data(get_item_data(local1))
                        external_006FH(local1) -- Unmapped intrinsic
                    end
                end
                local3 = external_0035H(0, 20, 338, itemref) -- Unmapped intrinsic
                for local7 in ipairs(local3) do
                    local8 = local7
                    local1 = local8
                    if get_item_frame(local1) == 9 then
                        local9 = external_0035H(16, 1, 275, local1) -- Unmapped intrinsic
                        for local10 in ipairs(local9) do
                            local11 = local10
                            local12 = local11
                            if get_item_frame(local12) == 6 and get_item_quality(local12) == 201 then
                                local13 = get_item_by_type(895) -- Unmapped intrinsic
                                set_item_frame(local13, 0)
                                local2 = set_item_data(get_item_data(local12))
                            end
                        end
                    end
                end
                local3 = external_0035H(0, 30, 895, itemref) -- Unmapped intrinsic
                for local14 in ipairs(local3) do
                    local15 = local14
                    local1 = local15
                    external_006FH(local1) -- Unmapped intrinsic
                end
                local3 = external_0035H(0, 30, 168, itemref) -- Unmapped intrinsic
                for local16 in ipairs(local3) do
                    local17 = local16
                    local1 = local17
                    external_006FH(local1) -- Unmapped intrinsic
                end
                local3 = external_0035H(0, 10, 400, itemref) -- Unmapped intrinsic
                for local18 in ipairs(local3) do
                    local19 = local18
                    local1 = local19
                    if get_item_frame(local1) == 29 then
                        external_08E6H(local1) -- Unmapped intrinsic
                    end
                end
                local3 = external_0035H(16, 0, 275, itemref) -- Unmapped intrinsic
                for local20 in ipairs(local3) do
                    local21 = local20
                    local1 = local21
                    if get_item_frame(local1) == 0 then
                        external_006FH(local1) -- Unmapped intrinsic
                    end
                end
                local3 = external_0035H(8, 1, 154, itemref) -- Unmapped intrinsic
                for local22 in ipairs(local3) do
                    local23 = local22
                    local1 = local23
                    external_08E6H(local1) -- Unmapped intrinsic
                end
                external_006FH(itemref) -- Unmapped intrinsic
            end
        end
    elseif eventid == 2 then
        if get_item_type(itemref) == 154 then
            local24 = get_item_data(itemref)[6][200]
            local3 = external_0035H(16, 20, 275, local24) -- Unmapped intrinsic
            if local3 then
                for local25 in ipairs(local3) do
                    local26 = local25
                    local27 = local26
                    local24 = get_item_data(local27)[6][-359]
                    local28 = external_0035H(16, 0, 275, local24) -- Unmapped intrinsic
                    for local29 in ipairs(local28) do
                        local30 = local29
                        local31 = local30
                        local2 = add_item(local31, {17480, 7724})
                        local2 = add_item(external_001BH(-356), {1802, 17493, 17452, 7715}) -- Unmapped intrinsic
                    end
                end
            end
        elseif get_item_type(itemref) == 721 or get_item_type(itemref) == 989 then
            local1 = external_0035H(8, 30, 354, external_001BH(-356)) -- Unmapped intrinsic
            if local1 then
                local21 = get_item_data(local1)
                create_object(-1, 0, 0, 0, local21[2] - 2, local21[1] - 2, 8) -- Unmapped intrinsic
                create_object(-1, 0, 0, 0, local21[2] - 2, local21[1] - 2, 7) -- Unmapped intrinsic
                apply_effect(52) -- Unmapped intrinsic
                set_item_frame(local1, 19)
                local2 = add_item(local1, {1802, 8021, 5, 7975, 4, 7769})
            else
                local27 = get_item_data(local1)[6][-359]
                local3 = external_0035H(16, 0, 275, local1) -- Unmapped intrinsic
                for local32 in ipairs(local3) do
                    local33 = local32
                    local34 = local33
                    local2 = add_item(local34, {17480, 7724})
                    local2 = add_item(external_001BH(-356), {1802, 17493, 17452, 7715}) -- Unmapped intrinsic
                end
            end
        end
        if not external_0088H(external_001BH(-356), 4) then -- Unmapped intrinsic
            abort()
        end
        if get_item_type(itemref) == 354 then
            local35 = external_0019H(external_001BH(-356), itemref) -- Unmapped intrinsic
            if local35 < 20 and external_0088H(external_001BH(-356), 23) then -- Unmapped intrinsic
                local21 = get_item_data(itemref)
                create_object(-1, 0, 0, 0, local21[2] + 3, local21[1] + 3, 17) -- Unmapped intrinsic
                local36 = get_party_members()
                for local37 in ipairs(local36) do
                    local38 = local37
                    local39 = local38
                    local40 = ""
                    local41 = get_random(0, 8)
                    if local41 == 0 then
                        local42 = {17505, 17516, 7789}
                        local40 = array_append(local40, local42)
                    elseif local41 == 1 then
                        local42 = {17505, 17505, 7789}
                        local40 = array_append(local40, local42)
                    elseif local41 == 2 then
                        local42 = {17505, 17518, 7788}
                        local40 = array_append(local40, local42)
                    elseif local41 == 3 then
                        local42 = {17505, 17505, 7777}
                        local40 = array_append(local40, local42)
                    elseif local41 == 4 then
                        local42 = {17505, 17508, 7789}
                        local40 = array_append(local40, local42)
                    elseif local41 == 5 then
                        local42 = {17505, 17517, 7780}
                        local40 = array_append(local40, local42)
                    elseif local41 == 6 then
                        local43 = 7984 + get_random(0, 3) * 2
                        local42 = {17505, 8556, local43, 7769}
                        local40 = array_append(local40, local42)
                    elseif local41 == 7 then
                        local43 = 7984 + get_random(0, 3) * 2
                        local42 = {17505, 8557, local43, 7769}
                        local40 = array_append(local40, local42)
                    elseif local41 == 8 then
                        local43 = 7984 + get_random(0, 3) * 2
                        local42 = {17505, 8548, local43, 7769}
                        local40 = array_append(local40, local42)
                    end
                    local2 = add_item(local39, local40)
                end
                external_0059H(3) -- Unmapped intrinsic
                local44 = get_random(5, 20)
                local2 = add_item(itemref, {1802, 8021, 1, 17447, 8047, 1, 17447, 8044, 2, 17447, 8045, 1, 17447, 8556, local44, 17447, 7780})
            else
                local44 = get_random(5, 15)
                local2 = add_item(itemref, {1802, 8021, 10, 8487, local44, 17447, 7780})
            end
        end
    end
    return
end