-- Casts the "An Xen Ex" spell, dispelling summoned creatures or effects on a selected target.
function func_0668(eventid, itemref)
    local local0, local1, local2

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        bark(itemref, "@An Xen Ex@")
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = external_0041H(local0, 80, itemref) -- Unmapped intrinsic
            local2 = add_item(itemref, {17530, 17514, 17520, 8037, 68, 8536, local1, 7769})
        else
            local2 = add_item(itemref, {1542, 17493, 17514, 17520, 8549, local1, 7769})
        end
    end
    return
end