-- Casts the "In Zu" spell, inducing sleep on a selected target.
function func_065F(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        item_say("@In Zu@", itemref)
        if not external_0906H(local1) and local0[1] ~= 0 then -- Unmapped intrinsic
            local2 = external_0041H(local0, 72, itemref) -- Unmapped intrinsic
            local3 = add_item(itemref, {17505, 17530, 17511, 17511, 8549, local1, 7769})
        else
            local3 = add_item(itemref, {1542, 17493, 17511, 8549, local1, 7769})
        end
    end
    return
end