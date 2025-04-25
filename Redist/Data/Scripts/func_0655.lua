-- Casts a protection spell ("Uus Sanct") on a selected target.
function func_0655(p0)
    local local0, local1, local2, local3, local4

    if get_event_id() == 1 then
        external_005CH(itemref) -- Unmapped intrinsic
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        item_say("@Uus Sanct@", itemref)
        external_0906H()
        if local0 and not external_0031H(local0) then -- Unmapped intrinsic
            local2 = external_0001H({17514, 17509, 8047, 109, 8536, local1, 7769}, itemref) -- Unmapped intrinsic
            local3 = external_0002H({1621, 17493, 7715}, local0) -- Unmapped intrinsic
            local4 = external_0018H(local0) -- Unmapped intrinsic
            external_007BH(-1, 0, 0, 0, -2, -2, 13, itemref) -- Unmapped intrinsic
        else
            local2 = external_0001H({1542, 17493, 17514, 17509, 8559, local1, 7769}, itemref) -- Unmapped intrinsic
        end
    elseif get_event_id() == 2 then
        external_0089H(itemref, 9) -- Unmapped intrinsic
    end
    return
end