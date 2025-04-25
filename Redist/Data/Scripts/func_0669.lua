-- Casts the "Por Xen" spell, causing nearby NPCs to dance with random banter and sprite effects.
function func_0669(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10

    if eventid == 1 then
        item_say("@Por Xen@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1641, 17493, 17514, 17520, 8037, 67, 7768})
            item_say("@Everybody DANCE now!@", itemref)
        else
            local0 = add_item(itemref, {1542, 17493, 17514, 17520, 7781})
        end
    elseif eventid == 2 then
        local1 = 25
        local2 = external_0934H(local1) -- Unmapped intrinsic
        for local3 in ipairs(local2) do
            local4 = local3
            local5 = local4
            local6 = get_npc_property(local5, 2)
            if local6 > 5 and local6 < 25 then
                local7 = get_item_data(local5)
                create_object(-1, 0, 0, 0, local7[2], local7[1], 16) -- Unmapped intrinsic
                external_093FH(local5, 4) -- Unmapped intrinsic
                set_flag(local5, 15, true)
                local8 = {"@Yow!@", "@Boogie!@", "@I'm bad!@", "@Oh, yeah!@", "@Huh!@", "@Yeah!@", "@Dance!@"}
                local9 = get_random(1, 7)
                local10 = get_random(10, 40)
                external_0933H(local5, local8[local9]) -- Unmapped intrinsic
                local0 = add_item(local5, local10, 1672, {17493, 7715})
            end
        end
    end
    return
end