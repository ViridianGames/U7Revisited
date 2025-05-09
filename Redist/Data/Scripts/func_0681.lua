--- Best guess: Implements the death vortex spell (Vas Corp Hur), creating a damaging vortex at a target location.
function func_0681(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        var_0000 = item_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        destroy_item(itemref)
        bark(itemref, "@Vas Corp Hur@")
        if check_spell_requirements() then
            var_0002 = apply_spell_effect(639, var_0000, itemref) --- Guess: Applies spell effect
            var_0003 = add_container_items(itemref, {17530, 17511, 8047, 65, 8536, var_0001, 7769})
        else
            var_0003 = add_container_items(itemref, {1542, 17493, 17511, 8559, var_0001, 7769})
        end
    end
end