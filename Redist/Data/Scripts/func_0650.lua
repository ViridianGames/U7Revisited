-- Casts the "An Jux" spell, disarming traps or unlocking chests with a sprite effect.
function func_0650(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        item_say("@An Jux@", itemref)
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = add_item(itemref, {17514, 17520, 8559, local1, 7769})
            local3 = add_item(local0, 176, 2, 200)
            for local4 in ipairs(local3) do
                local5 = local4
                local6 = local5
                local2 = external_0025H(local6) -- Unmapped intrinsic
                if not local2 then
                    local2 = set_item_data(get_item_data(-358))
                    set_flag(local6, 1, true)
                    create_object(-1, 0, 0, 0, local0[2], local0[1], 13) -- Unmapped intrinsic
                    apply_effect(66) -- Unmapped intrinsic
                end
            end
            local3 = add_item(local0, 176, 2, 522)
            for local4 in ipairs(local3) do
                local5 = local4
                local6 = local5
                if get_item_quality(local6) == 255 then
                    local2 = set_item_quality(local6, 0)
                    create_object(-1, 0, 0, 0, local0[2], local0[1], 13) -- Unmapped intrinsic
                    apply_effect(66) -- Unmapped intrinsic
                end
            end
        else
            local2 = add_item(itemref, {1542, 17493, 17514, 17520, 7791})
        end
    end
    return
end