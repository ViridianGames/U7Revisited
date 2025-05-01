-- Casts the "Vas Flam Hur" spell, creating a fiery wind effect on a selected target.
function func_066B(eventid, itemref)
    local local0, local1, local2

    if eventid == 1 or eventid == 4 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        bark(itemref, "@Vas Flam Hur@")
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = external_0041H(local0, 78, itemref) -- Unmapped intrinsic
            local2 = add_item(itemref, {17505, 17530, 17511, 17511, 17520, 8047, 65, 8536, local1, 7769})
        else
            local2 = add_item(itemref, {1542, 17493, 17511, 17520, 8559, local1, 7769})
        end
    end
    return
end