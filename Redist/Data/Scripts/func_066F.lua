require "U7LuaFuncs"
-- Casts the "Vas Zu" spell, inducing deep sleep on multiple NPCs in an area with a sprite effect.
function func_066F(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid == 1 then
        local0 = get_item_data(itemref)
        item_say("@Vas Zu@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            create_object(-1, 0, 0, 0, local0[2] - 2, local0[1] - 2, 7) -- Unmapped intrinsic
            local1 = add_item(itemref, {1647, 17493, 17514, 17511, 17519, 17509, 8033, 65, 7768})
        else
            local1 = add_item(itemref, {1542, 17493, 17514, 17511, 17519, 17509, 7777})
        end
    elseif eventid == 2 then
        local2 = 25
        local3 = add_item(-1, 4, local2, itemref)
        local4 = get_party_members()
        for local5 in ipairs(local3) do
            local6 = local5
            local7 = local6
            if not contains(local4, local7) then
                set_flag(local7, 1, true)
            end
        end
    end
    return
end