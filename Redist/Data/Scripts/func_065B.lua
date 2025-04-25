-- Casts the "Vas Uus Sanct" spell, raising defense for party members with a sprite effect.
function func_065B(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        item_say("@Vas Uus Sanct@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1627, 17493, 17514, 17519, 17520, 7791})
        else
            local0 = add_item(itemref, {1542, 17493, 17514, 17519, 17520, 7791})
        end
    elseif eventid == 2 then
        apply_effect(109) -- Unmapped intrinsic
        local1 = get_item_data(itemref)
        create_object(-1, 0, 0, 0, local1[2] - 2, local1[1] - 2, 7) -- Unmapped intrinsic
        local2 = get_party_members()
        for local3 in ipairs(local2) do
            local4 = local3
            local5 = local4
            set_flag(local5, 9, true)
        end
    end
    return
end