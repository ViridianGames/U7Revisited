-- Casts the "Bet Ort" spell, triggering a small magical effect with a sprite animation.
function func_0643(eventid, itemref)
    local local0, local1

    if eventid == 1 then
        item_say("@Bet Ort@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1603, 8021, 36, 17496, 17519, 7792})
        else
            local0 = add_item(itemref, {1542, 17493, 17519, 7792})
        end
    elseif eventid == 2 then
        local1 = get_item_data(itemref)
        create_object(-1, 0, 0, 0, local1[2] - 2, local1[1] - 2, 12) -- Unmapped intrinsic
    end
    return
end