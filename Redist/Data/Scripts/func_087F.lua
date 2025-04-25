-- Processes items of type 800 with specific quality and frame, creating or updating items.
function func_087F(p0)
    local local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21

    local1 = external_0035H(16, 15, 275, itemref) -- Unmapped intrinsic
    for local2 in ipairs(local1) do
        local3 = local2
        local4 = local3
        local5 = get_item_quality(local4)
        local6 = get_item_frame(local4)
        local7 = get_item_data(local4)
        if local5 == 10 and local6 == 6 then
            local8 = external_0035H(0, 1, -1, local4) -- Unmapped intrinsic
            local9 = 0
            if not local8 then
                for local10 in ipairs(local8) do
                    local11 = local10
                    local12 = local11
                    local13 = get_item_type(local12)
                    if local13 == 800 then
                        local14 = get_item_data(local12)
                        if local14[1] == local7[1] and local14[2] == local7[2] then
                            local9 = local12
                            external_0015H(local9, 100) -- Unmapped intrinsic
                        end
                    end
                end
                if not local9 then
                    local9 = get_item_by_type(800) -- Unmapped intrinsic
                    external_0015H(local9, 100) -- Unmapped intrinsic
                    set_item_frame(local9, 0)
                    local15 = set_item_data(local7)
                end
                for local16 in ipairs(local8) do
                    local17 = local16
                    local12 = local17
                    local13 = get_item_type(local12)
                    local18 = get_item_data(local12)
                    if local18[3] < 5 and local12 ~= local9 then
                        if local13 == 338 then
                            local19 = get_item_quality(local12)
                            local20 = get_item_frame(local12)
                            external_006FH(local12) -- Unmapped intrinsic
                            local12 = get_item_by_type(336) -- Unmapped intrinsic
                            external_0015H(local12, local19) -- Unmapped intrinsic
                            set_item_frame(local12, local20)
                        end
                        local15 = external_0025H(local12) -- Unmapped intrinsic
                        external_0036H(local9) -- Unmapped intrinsic
                    end
                end
            end
            local14 = get_item_data(local9)
            local15 = create_object(-1, local14[2] - 1, local14[1] - 1, 0, 0, 0, 13) -- Unmapped intrinsic
            local21 = get_item_type(p0)
            if local21 == 338 then
                local19 = get_item_quality(p0)
                local20 = get_item_frame(p0)
                external_006FH(p0) -- Unmapped intrinsic
                p0 = get_item_by_type(336) -- Unmapped intrinsic
                external_0015H(p0, local19) -- Unmapped intrinsic
                set_item_frame(p0, local20)
            end
            local15 = external_0025H(p0) -- Unmapped intrinsic
            external_0036H(local9) -- Unmapped intrinsic
        end
    end
    return
end