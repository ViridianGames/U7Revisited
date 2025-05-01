-- Casts the "Sanct Lor" spell, granting invisibility to a selected target.
function func_066D(eventid, itemref)
    local local0, local1, local2

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        bark(itemref, "@Sanct Lor@")
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = add_item(itemref, {17514, 17520, 8047, 67, 8536, local1, 7769})
            local2 = add_item(local0, 4, 1645, {17493, 7715})
        else
            local2 = add_item(itemref, {1542, 17493, 17514, 17520, 8559, local1, 7769})
        end
    elseif eventid == 2 then
        set_flag(itemref, 0, true)
    end
    return
end