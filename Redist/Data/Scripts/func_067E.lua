require "U7LuaFuncs"
-- Casts the "In Vas Por" spell, creating a powerful movement effect in an area.
function func_067E(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 1 then
        item_say("@In Vas Por@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1662, 17493, 17514, 17519, 8048, 64, 17496, 7791})
            local1 = get_item_data(itemref)
            create_object(-1, 0, 0, 0, local1[2] - 2, local1[1] - 2, 7) -- Unmapped intrinsic
            local2 = get_party_members()
            for local3 in ipairs(local2) do
                local4 = local3
                local5 = local4
                local6 = calculate_distance(local5, itemref) -- Unmapped intrinsic
                local6 = math.floor(local6 / 3) + 5
                local0 = add_item(local5, local6, 1662, {17493, 7715})
            end
        else
            local0 = add_item(itemref, {1542, 17493, 17514, 17519, 17520, 7791})
        end
    elseif eventid == 2 then
        set_flag(itemref, 12, true)
    end
    return
end