-- Casts the "Wis Quas" spell, revealing illusions or hidden objects in an area with a sprite effect.
function func_0665(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15

    if eventid == 1 then
        local0 = get_item_data(-356)
        local1 = {}
        item_say("@Wis Quas@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local2 = add_item(itemref, {17511, 17510, 8037, 67, 7768})
            local3 = get_item_data(itemref)
            local4 = {15, 15, 15, 5, 5, 5, -5, -5, -5, -15, -15, -15}
            local5 = {11, 2, -7, 11, 2, -7, 11, 2, -7, 11, 2, -7}
            local6 = 7
            local7 = 0
            while local7 ~= 12 do
                local7 = local7 + 1
                local8 = local0[1] + local4[local7]
                local9 = local0[2] + local5[local7]
                local3 = {0, local9, local8}
                local10 = add_item(-359, local6, local3)
                for local11 in ipairs(local10) do
                    local12 = local11
                    local13 = local12
                    set_flag(local13, 0, true)
                    if not contains(local1, local13) then
                        table.insert(local1, local13)
                    end
                end
            end
            for local14 in ipairs(local1) do
                local15 = local14
                local13 = local15
                local2 = add_item(local13, 5, 1637, {17493, 7715})
                create_object(-1, 0, 0, 0, -1, -1, 13, local13) -- Unmapped intrinsic
            end
        else
            local2 = add_item(itemref, {1542, 17493, 17511, 17510, 7781})
        end
    elseif eventid == 2 then
        set_flag(itemref, 0, true)
    end
    return
end