-- Casts the "Kal Xen" spell, summoning a creature with a random type from a predefined set.
function func_0660(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 1 then
        bark(itemref, "@Kal Xen@")
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1632, 17493, 17511, 17510, 8037, 65, 7768})
        else
            local0 = add_item(itemref, {1542, 17493, 17511, 17510, 7781})
        end
    elseif eventid == 2 then
        local1 = {537, 502, 530, 510, 523, 811, 716}
        local2 = #local1
        local3 = external_08F6H(-356) -- Unmapped intrinsic
        if local3 > local2 then
            local3 = local2
        end
        if local3 < 2 then
            local3 = 2
        end
        local4 = math.floor(local3 / 2)
        if local4 < 1 then
            local4 = 1
        end
        local5 = get_random(local4, local3)
        while local5 > 0 do
            local5 = local5 - 1
            local6 = get_random(local4, local3)
            local7 = local1[local6]
            local8 = set_flag(local7, false)
        end
    end
    return
end