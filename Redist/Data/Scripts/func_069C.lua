-- Triggers another combat sequence, creating objects and applying effects.
function func_069C(eventid, itemref)
    local local0, local1, local2, local3, local4

    external_008CH(1, 1, 12) -- Unmapped intrinsic
    local0 = get_item_data(itemref)
    create_object(-1, 0, 0, 0, local0[2] - 2, local0[1] - 2, 13) -- Unmapped intrinsic
    local1 = get_item_data(external_001BH(-356)) -- Unmapped intrinsic
    create_object(-1, 0, 0, 0, local1[2] - 2, local1[1] - 2, 7) -- Unmapped intrinsic
    apply_effect(68) -- Unmapped intrinsic
    local2 = add_item(itemref, {1694, 8021, 8, 17447, 8033, 2, 17447, 8048, 3, 17447, 8047, 4, 7769})
    local3 = external_0881H() -- Unmapped intrinsic
    if external_005AH() then -- Unmapped intrinsic
        local4 = add_item(local3, {20, 7750})
    else
        local4 = add_item(local3, {18, 7750})
    end
    return
end