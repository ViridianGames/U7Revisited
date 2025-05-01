-- Casts a fireball spell ("Kal Flam Grav") on a target area.
function func_0672(p0)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    if get_event_id() == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        external_005CH(itemref) -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        bark(itemref, "@Kal Flam Grav@")
        external_0906H()
        if not external_0906H() then
            local2 = external_0001H({17509, 17511, 8038, 65, 8536, local1, 7769}, itemref) -- Unmapped intrinsic
            local3 = {-1, 0, 1, 2, 2, 2, 1, 0, -1, -2, -2, -2}
            local4 = {-2, -2, -2, -1, 0, 1, 2, 2, 2, 1, 0, -1}
            local5 = 0
            while local5 < 12 do
                local5 = local5 + 1
                local6 = local3[local5] + 2
                local7 = local4[local5] + 3
                local8 = 4
                local9 = {local6, local7, local8}
                local10 = {local8 + 1, local7, local6}
                if not external_0085H(0, 621, local9) then -- Unmapped intrinsic
                    local9 = local10
                end
                if external_0085H(0, 621, local9) then -- Unmapped intrinsic
                    local11 = external_0024H(621) -- Unmapped intrinsic
                    if local11 then
                        external_0089H(local11, 18) -- Unmapped intrinsic
                        external_0089H(local11, 0) -- Unmapped intrinsic
                        local2 = external_0026H(local9) -- Unmapped intrinsic
                        set_npc_property(3, local11, 1) -- Unmapped intrinsic
                        local2 = external_0002H({1650, 17493, 7715}, local11) -- Unmapped intrinsic
                    end
                end
            end
        else
            local12 = external_0001H({1542, 17493, 17509, 17511, 8550, local1, 7769}, itemref) -- Unmapped intrinsic
        end
    elseif get_event_id() == 2 then
        local9 = external_0018H(itemref) -- Unmapped intrinsic
        local2 = external_0025H(itemref) -- Unmapped intrinsic
        if not local2 then
            local2 = external_0026H(-358) -- Unmapped intrinsic
        end
        local11 = external_0024H(895) -- Unmapped intrinsic
        if local11 then
            external_0089H(local11, 18) -- Unmapped intrinsic
            local13 = random2(1, 5) -- Unmapped intrinsic
            local13 = 30 + local13
            local2 = external_0015H(local11, local13) -- Unmapped intrinsic
            local2 = external_0002H({17453, 7715}, local11) -- Unmapped intrinsic
        end
    end
    return
end