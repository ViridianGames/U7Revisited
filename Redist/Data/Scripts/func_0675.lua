-- Casts the "In Nox Grav" spell, applying a poisonous electrical effect to a selected target.
function func_0675(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        bark(itemref, "@In Nox Grav@")
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = add_item(itemref, {17511, 17510, 8037, 110, 8536, local1, 7769})
            local3 = get_item_by_type(900) -- Unmapped intrinsic
            if local3 then
                local4 = local0[2] + 1
                local5 = local0[3] + 1
                local6 = local0[4]
                local7 = {local6, local5, local4}
                set_flag(local3, 18, true)
                set_item_data(local7)
            end
        else
            local2 = add_item(itemref, {1542, 17493, 17511, 17510, 8549, local1, 7769})
        end
    end
    return
end