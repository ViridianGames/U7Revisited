-- Casts the "Vas An Xen Ex" spell, dispelling summoned creatures in an area.
function func_067D(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 1 then
        item_say("@Vas An Xen Ex@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1661, 17493, 17514, 17519, 17520, 8047, 65, 7768})
            local1 = get_item_data(itemref)
            create_object(-1, 0, 0, 0, local1[2] - 2, local1[1] - 2, 7) -- Unmapped intrinsic
            local2 = 25
            local3 = external_0934H(local2) -- Unmapped intrinsic
            for local4 in ipairs(local3) do
                local5 = local4
                local6 = local5
                local2 = calculate_distance(local6, itemref) -- Unmapped intrinsic
                local2 = math.floor(local2 / 4) + 4
                if get_random(1, 3) ~= 1 then
                    local0 = add_item(local6, local2, 1661, {17493, 7715})
                end
            end
        else
            local0 = add_item(itemref, {1542, 17493, 17514, 17519, 17520, 7791})
        end
    elseif eventid == 2 then
        local7 = get_item_owner(itemref)
        if not contains({-356, -218, -217}, local7) then
            local8 = external_003CH(-356) -- Unmapped intrinsic
            if local8 then
                set_flag(itemref, 2, true)
            else
                external_008AH(itemref, 2) -- Unmapped intrinsic
            end
        end
    end
    return
end