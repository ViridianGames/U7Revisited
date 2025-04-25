-- Casts the "An Flam" spell, negating fire effects on a selected target, with a fallback if the target is invalid.
function func_0642(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        item_say("@An Flam@", itemref)
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = external_0041H(local0, 540, itemref) -- Unmapped intrinsic
            local2 = add_item(itemref, {17530, 17511, 8549, local1, 7769})
        else
            local2 = add_item(itemref, {1542, 17493, 17511, 8549, local1, 7769})
        end
    elseif eventid == 4 then
        local3 = get_item_type(itemref)
        if local3 == 435 or local3 == 338 or local3 == 526 or local3 == 701 then
            external_0095H(local3) -- Unmapped intrinsic
            local2 = add_item(itemref, {local3, 7765})
            apply_effect(46) -- Unmapped intrinsic
        else
            external_08FDH(60) -- Unmapped intrinsic
        end
    end
    return
end