-- Casts the "Kal Ort Por" spell, teleporting the caster to a random location with a sprite effect.
function func_0664(eventid, itemref)
    local local0, local1, local2

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = get_item_data(itemref)
        bark(itemref, "@Kal Ort Por@")
        if not external_0906H() and get_item_type(local0) ~= 330 then -- Unmapped intrinsic
            local2 = add_item(itemref, {17514, 17520, 7791})
            local2 = add_item(local0, 6, 1555, {17493, 7715})
            create_object(-1, 0, 0, 0, local0[2], local0[1], 7) -- Unmapped intrinsic
            external_007BH(-1, 0, 0, 0, -2, -2, 7, itemref) -- Unmapped intrinsic
        else
            local2 = add_item(itemref, {1542, 17493, 17514, 17520, 7791})
        end
    end
    return
end