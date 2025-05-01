-- Casts the "Vas An Nox" spell, curing poison for party members with a sprite effect.
function func_0654(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        local0 = get_item_data(itemref)
        create_object(-1, 0, 0, 0, local0[2] - 2, local0[1] - 2, 7) -- Unmapped intrinsic
        bark(itemref, "@Vas An Nox@")
        if not external_0906H() then -- Unmapped intrinsic
            local1 = add_item(itemref, {1620, 8021, 64, 17496, 17511, 17509, 7782})
        else
            local1 = add_item(itemref, {1542, 17493, 17511, 17509, 7782})
        end
    elseif eventid == 2 then
        local2 = get_party_members()
        for local3 in ipairs(local2) do
            local4 = local3
            local5 = local4
            set_flag(local5, 8, true)
            set_flag(local5, 7, true)
        end
    end
    return
end