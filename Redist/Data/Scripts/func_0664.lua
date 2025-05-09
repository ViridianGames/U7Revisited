--- Best guess: Implements the recall spell (Kal Ort Por), teleporting a target (type 330) to the caster’s location with protective effects.
function func_0664(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        destroy_item(itemref)
        var_0000 = item_select_modal() --- Guess: Selects spell target
        var_0001 = unknown_0018H(itemref) --- Guess: Gets position data
        bark(itemref, "@Kal Ort Por@")
        if check_spell_requirements() and get_item_type(var_0000) == 330 then
            var_0002 = add_container_items(itemref, {17514, 17520, 7791})
            var_0002 = add_container_items(var_0000, {6, 1555, 17493, 7715})
            apply_sprite_effect(-1, 0, 0, 0, var_0000[3], var_0000[2], 7) --- Guess: Applies sprite effect
            apply_protection_effect(-1, 0, 0, 0, -2, -2, 7, itemref) --- Guess: Applies protection effect
        else
            var_0002 = add_container_items(itemref, {1542, 17493, 17514, 17520, 7791})
        end
    end
end