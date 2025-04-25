-- Casts the "In Lor" spell, creating a light effect with a specific intensity.
function func_064D(eventid, itemref)
    local local0

    if eventid == 1 then
        item_say("@In Lor@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1613, 17493, 17511, 8037, 68, 17496, 7715})
        else
            local0 = add_item(itemref, {1542, 17493, 17511, 7781})
        end
    elseif eventid == 2 then
        external_0057H(500) -- Unmapped intrinsic
    end
    return
end