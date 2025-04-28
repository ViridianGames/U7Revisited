require "U7LuaFuncs"
-- Casts the "Vas Des Sanct" spell, lowering defense for multiple targets in an area with a sprite effect.
function func_0663(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid == 1 then
        item_say("@Vas Des Sanct@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = get_item_data(itemref)
            create_object(-1, 0, 0, 0, local0[2] - 2, local0[1] - 2, 7) -- Unmapped intrinsic
            local1 = add_item(itemref, {17514, 17519, 8048, 65, 17496, 7791})
            local2 = 30
            local3 = external_0934H(local2) -- Unmapped intrinsic
            local4 = get_party_members()
            for local5 in ipairs(local3) do
                local6 = local5
                local7 = local6
                if not contains(local4, local7) and get_random(1, 3) == 1 then
                    local0 = calculate_distance(local7, itemref) -- Unmapped intrinsic
                    local0 = add_item(local7, {1635, 17493, 7715})
                end
            end
        else
            local1 = add_item(itemref, {1542, 17493, 17514, 17519, 17520, 7791})
        end
    elseif eventid == 2 then
        set_flag(itemref, 3, true)
    end
    return
end