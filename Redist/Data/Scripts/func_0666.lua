-- Casts the "Kal Wis Corp" spell, creating a temporary ghost effect with a timed duration and sprite effects.
function func_0666(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 1 then
        item_say("@Kal Wis Corp@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {17511, 17509, 8038, 67, 7768})
            local1 = get_item_data(itemref)
            local2 = local1[1] - 2
            local3 = local1[2] - 2
            create_object(-1, 0, 0, 0, local3, local2, 13) -- Unmapped intrinsic
            create_object(-1, 0, 0, 0, local3, local2, 7) -- Unmapped intrinsic
            set_flag(434, true)
            set_flag(435, true)
            set_flag(436, true)
            set_flag(437, true)
            set_flag(438, true)
            set_flag(439, true)
            set_flag(440, true)
            set_flag(441, true)
            set_flag(442, true)
            set_flag(443, true)
            set_flag(439, true)
            local4 = get_time_hour() -- Unmapped intrinsic
            local5 = get_time_minute() -- Unmapped intrinsic
            if local4 < 6 then
                local6 = (6 - local4) * 60
                local6 = local6 + (60 - local5)
                local6 = local6 * 25
            else
                local6 = (23 - local4) * 60
                local6 = local6 + (60 - local5)
                local6 = local6 * 25
            end
            local0 = add_item(itemref, local6, 1638, {17493, 17452, 7715})
        else
            local0 = add_item(itemref, {1542, 17493, 17511, 17509, 7782})
        end
    elseif eventid == 2 then
        set_flag(434, false)
        set_flag(435, false)
        set_flag(436, false)
        set_flag(437, false)
        set_flag(438, false)
        set_flag(439, false)
        set_flag(440, false)
        set_flag(441, false)
        set_flag(442, false)
        set_flag(443, false)
        set_flag(439, false)
    end
    return
end