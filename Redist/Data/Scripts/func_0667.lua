-- Casts the "Ex Por" spell, unlocking or opening specific objects (e.g., doors, chests) with a frame adjustment.
function func_0667(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = get_item_type(local0)
        local2 = external_092DH(local0) -- Unmapped intrinsic
        local3 = {828, 845, 433, 432, 376, 270}
        local4 = {376, 270, 433, 432}
        item_say("@Ex Por@", itemref)
        if not external_0906H(local2) then -- Unmapped intrinsic
            if not contains(local3, local1) then
                local5 = get_item_frame(local0)
                if (local5 + 1) % 4 ~= 0 then
                    local6 = add_item(itemref, {66, 17496, 17511, 17509, 8550, local2, 7769})
                    local6 = add_item(local0, 6, 1639, {17493, 7715})
                end
            end
        else
            local6 = add_item(itemref, {1542, 17493, 17511, 17509, 8550, local2, 7769})
        end
    elseif eventid == 2 then
        local5 = get_item_frame(itemref)
        local7 = local5 - 3
        set_item_frame(itemref, local7)
    end
    return
end