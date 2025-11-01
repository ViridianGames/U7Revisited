--- Best guess: Implements the magic light spell (Bet Ort), creating a light source with sprite effects at the caster's location.
function utility_spell_0323(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        destroyobject_(objectref)
        bark(objectref, "@Bet Ort@")
        if check_spell_requirements() then
            var_0000 = add_containerobject_s(objectref, {1603, 8021, 36, 17496, 17519, 7792})
        else
            var_0000 = add_containerobject_s(objectref, {1542, 17493, 17519, 7792})
        end
    elseif eventid == 2 then
        var_0001 = get_object_position(objectref) --- Guess: Gets position data
        apply_sprite_effect(-1, 0, 0, 0, var_0001[2] - 2, var_0001[1] - 2, 12) --- Guess: Applies sprite effect
    end
end