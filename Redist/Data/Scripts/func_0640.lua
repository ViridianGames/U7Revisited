require "U7LuaFuncs"
-- Casts the "An Zu" spell, waking a selected NPC or object, with a fallback effect if the target is invalid.
function func_0640(eventid, itemref)
    local local0, local1, local2

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        item_say("@An Zu@", itemref)
        if external_0906H(local1) and local0[1] ~= 0 then -- Unmapped intrinsic
            local2 = add_item(itemref, {17511, 8037, 64, 8536, local1, 7769})
            local2 = add_item(local0, 5, 1600, {17493, 7715})
        else
            local2 = add_item(itemref, {1542, 17493, 17511, 8549, local1, 7769})
        end
    elseif eventid == 2 then
        if is_item_active(itemref) then -- Unmapped intrinsic
            set_schedule(itemref, 1)
        else
            external_08FDH(60) -- Unmapped intrinsic
        end
    end
    return
end