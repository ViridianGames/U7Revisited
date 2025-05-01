-- Casts the "In Quas Xen" spell, charming or controlling a selected creature if it is active.
function func_0671(eventid, itemref)
    local local0, local1, local2

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        bark(itemref, "@In Quas Xen@")
        if not external_0906H(local1) and is_item_active(local0) and external_0088H(local0, 27) ~= -1 then -- Unmapped intrinsic
            local2 = add_item(itemref, {17514, 17520, 7781})
            local2 = add_item(local0, 4, 1649, {17493, 7715})
        else
            local2 = add_item(itemref, {1542, 17493, 17514, 17520, 7781})
        end
    elseif eventid == 2 then
        local2 = external_004DH(itemref) -- Unmapped intrinsic
    end
    return
end