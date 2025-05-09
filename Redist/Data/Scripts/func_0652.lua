--- Best guess: Implements the fire field spell (Vas Flam), creating a damaging fire field at a target location.
function func_0652(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 or eventid == 4 then
        destroy_item(itemref)
        var_0000 = item_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(itemref, "@Vas Flam@")
        if check_spell_requirements() then
            var_0002 = apply_spell_effect(856, var_0000, itemref) --- Guess: Applies spell effect
            var_0003 = add_container_items(itemref, {17505, 17530, 17514, 17514, 17520, 8047, 65, 8536, var_0001, 7769})
        else
            var_0003 = add_container_items(itemref, {1542, 17493, 17514, 17520, 8559, var_0001, 7769})
        end
    end
end