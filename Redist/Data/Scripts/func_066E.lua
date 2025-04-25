-- Casts the "In Flam Grav" spell, creating a fiery electrical effect with a chance to ignite objects.
function func_066E(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        item_say("@In Flam Grav@", itemref)
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = add_item(itemref, {17511, 17510, 8549, local1, 8025, 65, 7768})
            local3 = get_item_by_type(895) -- Unmapped intrinsic
            if local3 then
                local4 = local0[2] + 1
                local5 = local0[3] + 1
                local6 = local0[4]
                local7 = {local6, local5, local4}
                local8 = set_item_data(local7)
                local9 = 100
                local8 = set_item_quality(local3, local9)
                set_flag(local3, 18, true)
                local8 = add_item(local3, local9, 8493, {17493, 7715})
            end
        else
            local2 = add_item(itemref, {1542, 17493, 17511, 17510, 8549, local1, 7769})
        end
    end
    return
end