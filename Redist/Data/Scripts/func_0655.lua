--- Best guess: Implements the protection spell (Uus Sanct), applying a protective effect to a target with visual effects.
function func_0655(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        destroy_item(itemref)
        var_0000 = item_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(itemref, "@Uus Sanct@")
        if check_spell_requirements() and is_item_valid(var_0000) then
            var_0002 = add_container_items(itemref, {17514, 17509, 8047, 109, 8536, var_0001, 7769})
            var_0003 = add_container_items(var_0000, {5, 1621, 17493, 7715})
            var_0004 = unknown_0018H(var_0000) --- Guess: Gets position data
            apply_protection_effect(-1, 0, 0, 0, -2, -2, 13, itemref) --- Guess: Applies protection effect
        else
            var_0002 = add_container_items(itemref, {1542, 17493, 17514, 17509, 8559, var_0001, 7769})
        end
    elseif eventid == 2 then
        set_item_flag(itemref, 9) --- Guess: Sets item flag
    end
end