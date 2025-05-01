-- Casts the "Rel Ylem" spell, transforming a specific item (type 915) with a sprite effect.
function func_0678(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        bark(itemref, "@Rel Ylem@")
        if not external_0906H(local1) and get_item_type(local0) == 915 then -- Unmapped intrinsic
            local2 = add_item(itemref, {17511, 8037, 66, 8536, local1, 7769})
            local3 = get_item_data(local0)
            create_object(-1, 0, 0, 0, local3[2], local3[1], 13) -- Unmapped intrinsic
            local4 = add_item(local0, 5, 1656, {17493, 7715})
        else
            local2 = add_item(itemref, {1542, 17493, 17511, 8549, local1, 7769})
        end
    else
        local5 = get_item_frame(itemref) * 10
        set_item_type(itemref, 645)
        set_item_frame(itemref, local5)
    end
    return
end