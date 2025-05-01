-- Casts the "Por Ort Wis" spell, granting temporary clairvoyance with a navigation effect.
function func_0657(eventid, itemref)
    local local0, local1

    if eventid == 1 then
        bark(itemref, "@Por Ort Wis@")
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1623, 17493, 17514, 17519, 8048, 67, 17496, 7791})
        else
            local0 = add_item(itemref, {1542, 17493, 17514, 17519, 17520, 7791})
        end
    elseif eventid == 2 then
        local1 = get_item_data(itemref)
        external_0050H(200, 45) -- Unmapped intrinsic
    end
    return
end