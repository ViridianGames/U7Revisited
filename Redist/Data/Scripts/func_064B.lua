require "U7LuaFuncs"
-- Casts the "Vas An Flam" spell, negating fire effects across multiple targets in an area.
function func_064B(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    if eventid == 1 then
        item_say("@Vas An Flam@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {17511, 17509, 7782})
            local1 = 25
            local2 = {435, 338, 526, 701}
            for local3 in ipairs(local2) do
                local4 = local3
                local5 = local4
                local6 = add_item(itemref, 0, local1, local5)
                for local7 in ipairs(local6) do
                    local8 = local7
                    local9 = local8
                    local10 = get_item_type(local9)
                    local11 = calculate_distance(local9, itemref) / 3 + 2 -- Unmapped intrinsic
                    external_0095H(local10) -- Unmapped intrinsic
                    local0 = add_item(local9, local11, local10, {17493, 7715})
                end
            end
        else
            local0 = add_item(itemref, {1542, 17493, 17511, 17509, 7782})
        end
    end
    return
end