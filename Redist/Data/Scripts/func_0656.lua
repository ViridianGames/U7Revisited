-- Casts the "Ort Por Ylem" spell, attracting a selected object to the player.
function func_0656(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        if local0[1] == 0 then
            return
        end
        local1 = external_092DH(local0) -- Unmapped intrinsic
        bark(itemref, "@Ort Por Ylem@")
        if not external_0906H(local1) and is_item_active(local0) then -- Unmapped intrinsic
            local2 = external_0041H(local0, 443, itemref) -- Unmapped intrinsic
            local3 = add_item(itemref, {17530, 17511, 8037, 67, 8536, local1, 7769})
        else
            local3 = add_item(itemref, {1542, 17493, 17511, 8549, local1, 7769})
        end
    elseif eventid == 4 then
        local3 = {785, 1011, 696, 583, 873, 740, 470, 743, 434, 258, 431, 810, 329, 653, 651, 654, 261}
        local4 = {787, 788, 950, 949}
        local5 = get_item_type(itemref)
        if contains(local4, local5) then
            local2 = add_item(itemref, {local5, 7765})
        elseif not contains(local3, local5) then
            external_0095H(local5) -- Unmapped intrinsic
            local2 = add_item(itemref, {local5, 7765})
        end
    end
    return
end