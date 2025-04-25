-- Casts the "Vas Corp" spell, dealing massive damage to non-protected NPCs in an area.
function func_0682(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    if eventid == 1 then
        item_say("@Vas Corp@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = get_item_data(itemref)
            create_object(-1, 0, 0, 0, local0[2] - 2, local0[1] - 2, 7) -- Unmapped intrinsic
            local1 = add_item(itemref, {67, 17496, 17520, 17519, 17505, 8045, 65, 7768})
            local2 = 25
            local3 = add_item(-1, 4, local2, itemref)
            local4 = get_party_members()
            local4 = array_append(local4, -23) -- Lord British
            local4 = array_append(local4, -26) -- Batlin
            local5 = false
            for local6 in ipairs(local3) do
                local7 = local6
                local8 = local7
                if not contains(local4, local8) then
                    local2 = calculate_distance(local8, itemref) -- Unmapped intrinsic
                    local2 = math.floor(local2 / 3) + 5
                    local1 = add_item(local8, local2, 1666, {17493, 7715})
                    local5 = true
                end
            end
            if not local5 then
                local4 = get_party_members()
                for local9 in ipairs(local4) do
                    local10 = local9
                    local11 = local10
                    local12 = get_npc_property(local11, 3)
                    external_0936H(local11, local12 - 2) -- Unmapped intrinsic
                end
            end
        else
            local1 = add_item(itemref, {1542, 17493, 17520, 17519, 17505, 7789})
        end
    elseif eventid == 2 then
        local13 = external_0088H(itemref, 14) -- Unmapped intrinsic
        if not local13 then
            local12 = get_npc_property(itemref, 3)
            external_0936H(itemref, local12 - 2) -- Unmapped intrinsic
            external_0936H(itemref, 50) -- Unmapped intrinsic
        end
    end
    return
end