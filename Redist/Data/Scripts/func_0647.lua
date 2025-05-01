-- Casts the "Vas Kal" spell, summoning a magical effect with a specific item creation.
function func_0647(eventid, itemref)
    local local0

    if eventid == 1 then
        bark(itemref, "@Vas Kal@")
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {62, 17496, 17514, 7785})
        else
            local0 = add_item(itemref, {1542, 17493, 17514, 7785})
        end
    end
    return
end