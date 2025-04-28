require "U7LuaFuncs"
-- Casts the "Vas An Zu" spell, waking multiple NPCs in an area with a sprite effect.
function func_064F(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 1 then
        local0 = get_item_data(itemref)
        item_say("@Vas An Zu@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            create_object(-1, 0, 0, 0, local0[2] - 2, local0[1] - 2, 7) -- Unmapped intrinsic
            local1 = add_item(itemref, {17511, 8037, 68, 7768})
            local2 = 25
            local3 = add_item(itemref, 4, local2, -1)
            for local4 in ipairs(local3) do
                local5 = local4
                local6 = local5
                local1 = add_item(local6, {1615, 17493, 7715})
            end
        else
            local1 = add_item(itemref, {1542, 17493, 17511, 7781})
        end
    elseif eventid == 2 then
        set_flag(itemref, 1, true)
    end
    return
end