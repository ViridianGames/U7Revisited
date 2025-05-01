-- Casts the "Vas Corp Hur" spell, dealing significant damage to a selected target with a wind effect.
function func_0681(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        bark(itemref, "@Vas Corp Hur@")
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = external_0041H(local0, 639, itemref) -- Unmapped intrinsic
            local3 = add_item(itemref, {17530, 17511, 8047, 65, 8536, local1, 7769})
        else
            local3 = add_item(itemref, {1542, 17493, 17511, 8559, local1, 7769})
        end
    end
    return
end