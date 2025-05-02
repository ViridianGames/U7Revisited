-- Manages forging, processing rock and blood to create items, with special handling for golem bodies and tree objects.
function func_062C(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19

    local0 = itemref
    local1 = external_0945H(local0) -- Unmapped intrinsic
    local2 = add_item(local0, 0, 18, 331, {1736, 2487})
    for local3 in ipairs(local2) do
        local4 = local3
        local5 = local4
        local6 = add_item(local5, 176, 3, 912)
        for local7 in ipairs(local6) do
            local8 = local7
            local9 = local8
            local10 = get_object_frame(local9)
            local11 = get_item_data(local9)
            remove_item(local9)
            set_object_frame(local0, local10)
            local13 = set_item_data(local11)
        end
    end
    local14 = get_container_items(-359, local1, 797)
    local15 = add_item(local0, {17453, 17452, 7715})
    if get_item_quality(local14) == 243 then
        external_08E6H(local1) -- Unmapped intrinsic
        set_flag(753, false)
        set_flag(795, true)
    elseif get_item_quality(local14) == 244 then
        external_08E6H(local1) -- Unmapped intrinsic
        set_flag(796, false)
        set_flag(754, false)
    end
    local2 = get_item_by_type(932)
    for local16 in ipairs(local2) do
        local17 = local16
        local18 = local17
        if get_object_frame(local18) == 2 or get_object_frame(local18) == 3 then
            external_0092H(local18) -- Unmapped intrinsic
            set_schedule(0, 1, 12)
            local19 = add_item(local18, {1599, 8021, 30, 7975, 1811, 8021, 1590, 17493, 7715})
        end
    end
    return
end