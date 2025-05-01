-- Casts the "In Mani Corp" spell, resurrecting a selected corpse if conditions are met.
function func_0684(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = get_item_type(local0)
        local2 = get_item_data(local0)
        local3 = external_092DH(local0) -- Unmapped intrinsic
        local6 = 0
        if contains({778, 414, 400}, local1) then
            local4 = get_item_quality(local0)
            local5 = external_0016H(local0, local1) -- Unmapped intrinsic
            if local4 == 0 and local5 == 0 then
                local6 = 0
            else
                local6 = external_0051H(local0) -- Unmapped intrinsic
            end
        end
        bark(itemref, "@In Mani Corp@")
        if not external_0906H(local6) then -- Unmapped intrinsic
            local7 = 1
            local8 = add_item(itemref, {17519, 17505, 8045, 64, 8536, local3, 7769})
            external_002EH(0, 15) -- Unmapped intrinsic
            create_object(-1, 0, 0, 0, local2[2], local2[1], 17) -- Unmapped intrinsic
            create_object(-1, 0, 0, 0, local2[2] - 2, local2[1] - 2, 13) -- Unmapped intrinsic
        else
            local7 = 1
            local8 = add_item(itemref, {1542, 17493, 17519, 17505, 8557, local3, 7769})
        end
    end
    return
end