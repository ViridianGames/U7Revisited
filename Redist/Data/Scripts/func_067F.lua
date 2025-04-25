-- Casts the "Vas Mani" spell, fully healing all party members with a sprite effect.
function func_067F(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 1 then
        item_say("@Vas Mani@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {64, 17496, 17514, 17520, 7781})
            local1 = get_party_members()
            for local2 in ipairs(local1) do
                local3 = local2
                local4 = local3
                external_008AH(local4, 7) -- Unmapped intrinsic
                external_008AH(local4, 8) -- Unmapped intrinsic
                local5 = get_npc_property(local4, 0)
                local6 = get_npc_property(local4, 3)
                local0 = set_npc_property(local4, 3, local5 - local6)
            end
            create_object(-1, 0, 0, 0, -1, -1, 13, -356) -- Unmapped intrinsic
        else
            local0 = add_item(itemref, {1542, 17493, 17514, 17520, 7781})
        end
    end
    return
end