-- Casts the "An Tym" spell, dispelling time-based effects.
function func_0687(eventid, itemref)
    local local0

    if eventid == 1 then
        item_say("@An Tym@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1671, 17493, 17520, 8042, 67, 7768})
        else
            local0 = add_item(itemref, {1542, 17493, 17520, 7786})
        end
    elseif eventid == 2 then
        external_0056H(100) -- Unmapped intrinsic
    end
    return
end