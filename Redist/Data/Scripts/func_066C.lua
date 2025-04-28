require "U7LuaFuncs"
-- Casts the "Vas Mani" spell, fully healing a selected target by setting their health to maximum.
function func_066C(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        item_say("@Vas Mani@", itemref)
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = add_item(itemref, {64, 17496, 17511, 17509, 8550, local1, 7769})
            if not is_item_active(local0) then -- Unmapped intrinsic
                local3 = get_npc_property(local0, 0)
                local4 = get_npc_property(local0, 3)
                local5 = set_npc_property(local0, 3, local3 - local4)
            end
        else
            local2 = add_item(itemref, {1542, 17493, 17511, 17509, 8550, local1, 7769})
        end
    end
    return
end