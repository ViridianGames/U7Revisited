-- Casts the "In Hur Grav Ylem" spell, creating a wind and electrical effect that moves objects.
function func_067C(eventid, itemref)
    local local0, local1, local2

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        bark(itemref, "@In Hur Grav Ylem@")
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = external_0041H(local0, 399, itemref) -- Unmapped intrinsic
            local2 = add_item(itemref, {17530, 17514, 17519, 17520, 8047, 65, 8536, local1, 7769})
        else
            local2 = add_item(itemref, {1542, 17493, 17514, 17519, 17520, 8559, local1, 7769})
        end
    end
    return
end