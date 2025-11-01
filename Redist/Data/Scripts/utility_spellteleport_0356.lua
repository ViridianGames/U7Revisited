--- Best guess: Implements the recall spell (Kal Ort Por), teleporting a target (type 330) to the caster's location with protective effects.
function utility_spellteleport_0356(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        destroyobject_(objectref)
        var_0000 = object_select_modal() --- Guess: Selects spell target
        var_0001 = get_object_position(objectref) --- Guess: Gets position data
        bark(objectref, "@Kal Ort Por@")
        if check_spell_requirements() and get_object_type(var_0000) == 330 then
            var_0002 = add_containerobject_s(objectref, {17514, 17520, 7791})
            var_0002 = add_containerobject_s(var_0000, {6, 1555, 17493, 7715})
            apply_sprite_effect(-1, 0, 0, 0, var_0000[3], var_0000[2], 7) --- Guess: Applies sprite effect
            apply_protection_effect(-1, 0, 0, 0, -2, -2, 7, objectref) --- Guess: Applies protection effect
        else
            var_0002 = add_containerobject_s(objectref, {1542, 17493, 17514, 17520, 7791})
        end
    end
end