-- Casts the "Tym Vas Flam" spell, creating a timed fire effect at a selected location.
function func_067A(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    local0 = false
    if eventid == 1 then
        local1 = item_select_modal() -- Unmapped intrinsic
        local2 = external_092DH(local1) -- Unmapped intrinsic
        local3 = {local1[2], local1[3], local1[4]}
        item_say("@Tym Vas Flam@", itemref)
        if not external_0906H(local2) then -- Unmapped intrinsic
            local4 = get_item_by_type(621) -- Unmapped intrinsic
            if local4 then
                set_flag(local4, 18, true)
                set_flag(local4, 0, true)
                local5 = set_item_data(local3)
                if local5 then
                    set_npc_property(local4, 3, 1)
                    local5 = external_0041H(local4, 621, itemref) -- Unmapped intrinsic
                    local5 = add_item(itemref, 12, 17530, {17493, 7715})
                    local5 = add_item(local4, 14, 17453, {17493, 7715})
                else
                    local0 = true
                end
            else
                local0 = true
            end
            local5 = add_item(itemref, {17519, 17520, 8042, 65, 8536, local2, 7769})
            create_object(-1, 0, 0, 0, local3[2], local3[1], 13) -- Unmapped intrinsic
        else
            local0 = true
        end
        if local0 then
            local5 = add_item(itemref, {1542, 17493, 17519, 17520, 8554, local2, 7769})
        end
    end
    return
end