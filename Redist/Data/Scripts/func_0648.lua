-- Casts the "In Mani Ylem" spell, creating food items for party members with random quality.
function func_0648(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid == 1 then
        bark(itemref, "@In Mani Ylem@")
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1608, 17493, 17511, 17509, 8038, 68, 7768})
        else
            local0 = add_item(itemref, {1542, 17493, 17511, 17509, 7782})
        end
    elseif eventid == 2 then
        local1 = get_party_members()
        for local2 in ipairs(local1) do
            local3 = local2
            local4 = local3
            local5 = get_item_data(local4)
            local6 = get_item_frame(377)
            if local6 then
                local7 = get_random(1, 30)
                set_item_frame(local6, local7)
                set_flag(local6, 18, true)
                local0 = set_item_data(local5)
            end
        end
    end
    return
end