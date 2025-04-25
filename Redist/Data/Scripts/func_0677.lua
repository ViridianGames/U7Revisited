-- Casts the "Vas Por Ylem" spell, creating a tremor or earthquake effect with random directional movements.
function func_0677(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    if eventid == 1 then
        item_say("@Vas Por Ylem@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1655, 8021, 67, 17496, 17517, 17505, 7784})
        else
            local0 = add_item(itemref, {1542, 17493, 17517, 17505, 7784})
        end
    elseif eventid == 2 then
        local1 = add_item(-359, 8, 40, itemref)
        local2 = get_party_members()
        local3 = 12
        local4 = external_0088H(itemref, 6) -- Unmapped intrinsic
        for local5 in ipairs(local1) do
            local6 = local5
            local7 = local6
            if not local4 or not contains(local2, local7) then
                local8 = 0
                local9 = {}
                while local8 < local3 do
                    local10 = get_random(0, 8)
                    if local10 == 0 then
                        table.insert(local9, {17505, 17516, 7789})
                    elseif local10 == 1 then
                        table.insert(local9, {17505, 17505, 7789})
                    elseif local10 == 2 then
                        table.insert(local9, {17505, 17518, 7788})
                    elseif local10 == 3 then
                        table.insert(local9, {17505, 17505, 7777})
                    elseif local10 == 4 then
                        table.insert(local9, {17505, 17508, 7789})
                    elseif local10 == 5 then
                        table.insert(local9, {17505, 17517, 7780})
                    elseif local10 == 6 then
                        local11 = 7984 + get_random(0, 3) * 2
                        table.insert(local9, {17505, 8556, local11, 7769})
                    elseif local10 == 7 then
                        local11 = 7984 + get_random(0, 3) * 2
                        table.insert(local9, {17505, 8557, local11, 7769})
                    elseif local10 == 8 then
                        local11 = 7984 + get_random(0, 3) * 2
                        table.insert(local9, {17505, 8548, local11, 7769})
                    end
                    local8 = local8 + 1
                end
                local0 = add_item(local7, local9)
            end
        end
        external_0059H(local3 * 3) -- Unmapped intrinsic
    end
    return
end