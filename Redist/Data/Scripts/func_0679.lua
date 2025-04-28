require "U7LuaFuncs"
-- Casts the "Corp Por" spell, dealing significant damage to a selected target, bypassing Avatar protection.
function func_0679(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 or (eventid == 4 and get_item_owner(itemref) == -356) then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        item_say("@Corp Por@", itemref)
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = external_0041H(local0, 527, itemref) -- Unmapped intrinsic
            local2 = add_item(itemref, {17530, 17514, 17519, 8048, 65, 17496, 8559, local1, 7769})
        else
            local2 = add_item(itemref, {1542, 17493, 17514, 17519, 17520, 8559, local1, 7769})
        end
    elseif eventid == 4 and get_item_owner(itemref) ~= -356 then
        if not is_item_active(itemref) then -- Unmapped intrinsic
            local3 = get_npc_property(-356, 2)
            local4 = get_npc_property(itemref, 2)
        else
            local3 = 0
            local4 = 1
        end
        local5 = external_0088H(itemref, 14) -- Unmapped intrinsic
        if local3 > local4 and local5 == false then
            external_0936H(itemref, 127) -- Unmapped intrinsic
            external_0049H(itemref) -- Unmapped intrinsic
        end
    end
    return
end