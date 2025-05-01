-- Casts the "An Nox" spell, curing poison on a selected target, with a fallback effect if the target is invalid.
function func_0649(eventid, itemref)
    local local0, local1, local2

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        bark(itemref, "@An Nox@")
        if not external_0906H(local1) and is_item_active(local0) then -- Unmapped intrinsic
            local2 = add_item(itemref, {17511, 17509, 8038, 64, 8536, local1, 7769})
            local2 = add_item(local0, 6, 1609, {17493, 7715})
        else
            local2 = add_item(itemref, {1542, 17493, 17511, 17509, 8550, local1, 7769})
        end
    elseif eventid == 2 then
        set_flag(itemref, 8, true)
        set_flag(itemref, 7, true)
    end
    return
end