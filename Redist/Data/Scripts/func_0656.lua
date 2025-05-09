--- Best guess: Implements the teleport spell (Ort Por Ylem), moving a target to the caster’s location with spell effects.
function func_0656(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        destroy_item(itemref)
        var_0000 = item_select_modal() --- Guess: Selects spell target
        if var_0000[1] == 0 then
            return
        end
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(itemref, "@Ort Por Ylem@")
        if check_spell_requirements() and not is_item_valid(var_0000) and var_0000[1] ~= 0 then
            var_0002 = apply_spell_effect(443, var_0000, itemref) --- Guess: Applies spell effect
            var_0002 = add_container_items(itemref, {17530, 17511, 8037, 67, 8536, var_0001, 7769})
        else
            var_0002 = add_container_items(itemref, {1542, 17493, 17511, 8549, var_0001, 7769})
        end
    elseif eventid == 4 then
        local valid_types = {785, 788, 950, 949}
        local invalid_types = {787, 1011, 696, 583, 873, 740, 470, 743, 434, 258, 431, 810, 329, 653, 651, 654, 261}
        var_0003 = get_item_type(itemref)
        if var_0003 == valid_types[1] or var_0003 == valid_types[2] or var_0003 == valid_types[3] or var_0003 == valid_types[4] then
            var_0002 = add_container_items(itemref, {var_0003, 7765})
        elseif not (var_0003 == invalid_types[1] or var_0003 == invalid_types[2] or ...) then
            consume_reagents(var_0003) --- Guess: Consumes reagents
            var_0002 = add_container_items(itemref, {var_0003, 7765})
        end
    end
end