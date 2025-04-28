require "U7LuaFuncs"
-- Casts the "Quas Wis" spell, causing fear or confusion in nearby NPCs.
function func_0670(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        item_say("@Quas Wis@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1648, 17493, 17511, 17509, 17510, 17505, 8045, 65, 7768})
        else
            local0 = add_item(itemref, {1542, 17493, 17511, 17509, 17510, 17505, 7789})
        end
    elseif eventid == 2 then
        local1 = add_item(-1, 8, 25, itemref)
        local2 = get_party_members()
        for local3 in ipairs(local1) do
            local4 = local3
            local5 = local4
            if not contains(local2, local5) and get_npc_property(local5, 2) > 5 then
                set_flag(local5, 0, true)
                external_004BH(local5, 7) -- Unmapped intrinsic
                external_0022H() -- Unmapped intrinsic
                external_004CH(local5) -- Unmapped intrinsic
            end
        end
    end
    return
end