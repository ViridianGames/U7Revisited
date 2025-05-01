-- Casts the "Ort Ylem" spell, transforming specific item types (e.g., 722, 723 to 417, 556) to attract or manipulate objects.
function func_0651(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    local0 = {723, 722}
    local1 = {417, 556}

    if eventid == 1 then
        local2 = item_select_modal() -- Unmapped intrinsic
        local3 = get_item_type(local2)
        local4 = external_092DH(local2) -- Unmapped intrinsic
        bark(itemref, "@Ort Ylem@")
        if external_0906H() and contains(local0, local3) then -- Unmapped intrinsic
            local5 = add_item(itemref, {17511, 17509, 8038, 67, 8536, local4, 7769})
            local5 = add_item(local2, 4, 1617, {17493, 7715})
        else
            local5 = add_item(itemref, {1542, 17493, 17511, 17509, 8550, local4, 7769})
        end
    elseif eventid == 2 then
        local6 = 0
        while local6 < #local1 do
            local6 = local6 + 1
            local7 = get_item_type(local9)
            if local7 == local1[local6] then
                set_item_type(itemref, local0[local6])
            end
        end
    end
    return
end