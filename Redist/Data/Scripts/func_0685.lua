require "U7LuaFuncs"
-- Casts the "Kal Vas Xen" spell, summoning a powerful creature with random type and strength.
function func_0685(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 1 then
        item_say("@Kal Vas Xen@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1669, 8021, 65, 17496, 17514, 17520, 17519, 17505, 7789})
        else
            local0 = add_item(itemref, {1542, 17493, 17514, 17520, 17519, 17505, 7789})
        end
    elseif eventid == 2 then
        local1 = {706, 661, 354, 514, 274, 883, 505, 501, 154, 533, 337, 504, 528}
        local2 = {5, 5, 10, 5, 14, 5, 5, 5, 5, 5, 5, 15, 5}
        local3 = {2, 5, 1, 3, 1, 1, 2, 2, 2, 1, 5, 1, 5}
        local4 = external_092BH(local1) -- Unmapped intrinsic
        local5 = get_random(1, #local1)
        local6 = get_random(1, 100)
        while local2[local5] < local6 do
            local5 = get_random(1, #local1)
            local6 = get_random(1, 100)
        end
        local7 = math.floor(local3[local5] / 2)
        if local7 < 1 then
            local7 = 1
        end
        local8 = get_random(1, local7)
        local9 = get_random(1, 2) == 1 and 1 or -1
        local7 = local3[local5] + local8 * local9
        while local7 > 0 do
            external_0047H(local1[local5], true) -- Unmapped intrinsic
            local7 = local7 - 1
        end
    end
    return
end