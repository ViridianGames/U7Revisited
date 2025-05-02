-- Initiates an endgame sequence, updating container items and applying effects.
function func_0715(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    local0 = external_0035H(8, 40, 1015, external_001BH(-356)) -- Unmapped intrinsic
    local1 = false
    for local2 in ipairs(local0) do
        local3 = local2
        local4 = local3
        if get_container_items(4, 243, 797, local4) then -- Unmapped intrinsic
            local1 = local4
        end
        if get_container_items(4, 244, 797, local4) then -- Unmapped intrinsic
            local1 = local4
        end
    end
    if local1 then
        local5 = add_item(local1, {8033, 2, 17447, 17517, 17460, 8025, 3, 7719})
        local6 = get_item_data(local1)
        create_object(-1, 0, 0, 0, local6[2], local6[1], 17) -- Unmapped intrinsic
        apply_effect(62) -- Unmapped intrinsic
        set_object_frame(local1, 29)
    end
    external_005DH() -- Unmapped intrinsic
    local0 = external_0035H(176, 40, 912, external_001BH(-356)) -- Unmapped intrinsic
    for local7 in ipairs(local0) do
        local8 = local7
        local9 = local8
        local10 = get_item_data(local9)
        local11 = get_item_by_type(895) -- Unmapped intrinsic
        local12 = set_item_data(local10)
        external_006FH(local9) -- Unmapped intrinsic
        local5 = add_item(local11, {get_random(150, 200), 17453, 17452, 7715})
    end
    external_001DH(local1, 15) -- Unmapped intrinsic
    return
end