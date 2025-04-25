-- Casts the "In Flam" spell, creating a fire effect on a selected target, with a fallback if the target is invalid.
function func_0646(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        item_say("@In Flam@", itemref)
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = external_0041H(local0, 280, itemref) -- Unmapped intrinsic
            local2 = add_item(itemref, {17530, 17514, 17520, 8559, local1, 7769})
        else
            local2 = add_item(itemref, {1542, 17493, 17514, 17520, 8559, local1, 7769})
        end
    elseif eventid == 4 then
        local3 = get_item_type(itemref)
        if local3 == 481 or local3 == 336 or local3 == 889 or local3 == 595 then
            external_0095H(local3) -- Unmapped intrinsic
            local2 = add_item(itemref, {local3, 17493, 7715})
        else
            external_08FDH(60) -- Unmapped intrinsic
        end
    end
    return
end