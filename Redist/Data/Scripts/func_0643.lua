--- Best guess: Implements the magic light spell (Bet Ort), creating a light source with sprite effects at the caster’s location.
function func_0643(eventid, itemref)
    local var_0000, var_0001

    if eventid == 1 then
        destroy_item(itemref)
        bark(itemref, "@Bet Ort@")
        if check_spell_requirements() then
            var_0000 = add_container_items(itemref, {1603, 8021, 36, 17496, 17519, 7792})
        else
            var_0000 = add_container_items(itemref, {1542, 17493, 17519, 7792})
        end
    elseif eventid == 2 then
        var_0001 = unknown_0018H(itemref) --- Guess: Gets position data
        apply_sprite_effect(-1, 0, 0, 0, var_0001[2] - 2, var_0001[1] - 2, 12) --- Guess: Applies sprite effect
    end
end