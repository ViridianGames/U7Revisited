-- Casts the "Bet Lor" spell, triggering a small light effect.
function func_0644(eventid, itemref)
    local local0

    if eventid == 1 then
        item_say("@Bet Lor@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1604, 17493, 17511, 8037, 68, 17496, 7715})
        else
            local0 = add_item(itemref, {1542, 17493, 17511, 7781})
        end
    elseif eventid == 2 then
        external_0057H(110) -- Unmapped intrinsic
    end
    return
end