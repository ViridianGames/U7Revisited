-- Checks for specific items and updates their state, creating effects.
function func_070C(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    local0 = external_000EH(1, 604, itemref) -- Unmapped intrinsic
    local1 = external_000EH(8, 729, itemref) -- Unmapped intrinsic
    if local0 and local1 and get_item_quality(local1) == 7 then
        local3 = get_item_data(local1)
        external_006FH(local1) -- Unmapped intrinsic
        external_006FH(local0) -- Unmapped intrinsic
        local4 = get_item_by_type(641) -- Unmapped intrinsic
        set_object_frame(local4, 30)
        local5 = external_0015H(local4, 66) -- Unmapped intrinsic
        local5 = set_item_data(local3)
        create_object(-1, 0, 0, 0, local3[2] - 2, local3[1] - 1, 13) -- Unmapped intrinsic
        apply_effect(37) -- Unmapped intrinsic
    end
    return
end