require "U7LuaFuncs"
-- Casts the "Vas Sact Lor" spell, granting invisibility to party members in an area.
function func_0683(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid == 1 then
        item_say("@Vas Sact Lor@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = get_item_data(itemref)
            create_object(-1, 0, 0, 0, local0[2] - 2, local0[1] - 2, 7) -- Unmapped intrinsic
            local1 = add_item(itemref, {17514, 17505, 17519, 8033, 67, 17496, 7781})
            local2 = get_party_members()
            for local3 in ipairs(local2) do
                local4 = local3
                local5 = local4
                local6 = calculate_distance(local5, itemref) -- Unmapped intrinsic
                local6 = math.floor(local6 / 3) + 5
                local1 = add_item(local5, local6, 1667, {17493, 7715})
            end
        else
            local1 = add_item(itemref, {1542, 17493, 17514, 17505, 17519, 17505, 7781})
        end
    elseif eventid == 2 then
        set_flag(itemref, 0, true)
    end
    return
end