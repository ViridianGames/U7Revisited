-- Casts the "Mani" spell, healing a selected target by adjusting their health.
function func_0659(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        bark(itemref, "@Mani@")
        if not external_0906H(local1) and is_item_active(local0) then -- Unmapped intrinsic
            local2 = add_item(itemref, {17511, 17509, 17510, 8033, 64, 17496, 8557, local1, 7769})
            local2 = add_item(local0, 5, 1625, {17493, 7715})
        else
            local2 = add_item(itemref, {1542, 17493, 17511, 17509, 17510, 17505, 8557, local1, 7769})
        end
    elseif eventid == 2 then
        local3 = get_npc_property(itemref, 0)
        local4 = get_npc_property(itemref, 3)
        if local4 <= local3 then
            local5 = (local3 - local4) / 2
            local2 = set_npc_property(itemref, 3, local5)
        end
    end
    return
end