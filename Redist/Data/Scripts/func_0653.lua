-- Casts the "Vas Lor" spell, creating a strong light effect with high intensity.
function func_0653(eventid, itemref)
    local local0

    if eventid == 1 then
        item_say("@Vas Lor@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1619, 17493, 17511, 8037, 68, 17496, 7715})
        else
            local0 = add_item(itemref, {1542, 17493, 17511, 7781})
        end
    elseif eventid == 2 then
        external_0057H(5000) -- Unmapped intrinsic
    end
    return
end