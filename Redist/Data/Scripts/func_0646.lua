--- Best guess: Implements the fireball spell (In Flam), targeting and damaging specific item types with spell effects.
function func_0646(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        destroy_item(itemref)
        var_0000 = item_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(itemref, "@In Flam@")
        if check_spell_requirements() then
            var_0002 = apply_spell_effect(280, var_0000, itemref) --- Guess: Applies spell effect
            var_0002 = add_container_items(itemref, {17530, 17514, 17520, 8559, var_0001, 7769})
        else
            var_0002 = add_container_items(itemref, {1542, 17493, 17514, 17520, 8559, var_0001, 7769})
        end
    elseif eventid == 4 then
        var_0003 = get_item_type(itemref)
        if var_0003 == 481 or var_0003 == 336 or var_0003 == 889 or var_0003 == 595 then
            consume_reagents(var_0003) --- Guess: Consumes reagents
            var_0002 = add_container_items(itemref, {17493, 7715})
        else
            play_spell_animation(60) --- Guess: Plays spell animation
        end
    end
end