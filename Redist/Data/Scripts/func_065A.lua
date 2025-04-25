-- Casts the "Kal Bet Xen" spell, summoning small creatures with random success.
function func_065A(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        item_say("@Kal Bet Xen@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1626, 8021, 65, 17496, 17514, 17520, 7791})
        else
            local0 = add_item(itemref, {1542, 17493, 17514, 17520, 7791})
        end
    elseif eventid == 2 then
        local1 = get_random(7, 10)
        while local1 > 0 do
            local1 = local1 - 1
            local2 = 517
            local3 = set_flag(local2, false)
        end
    end
    return
end