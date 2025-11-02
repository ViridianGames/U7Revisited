--- Best guess: Implements the lightning spell (Ort Grav), dealing damage to a target area with spell effects.
function utility_spell_0353(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 or eventid == 4 then
        var_0000 = object_select_modal() --- Guess: Selects spell target
        destroy_object(objectref)
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(objectref, "@Ort Grav@")
        if check_spell_requirements() then
            var_0002 = apply_spell_effect(807, var_0000, objectref) --- Guess: Applies spell effect
            var_0002 = add_containerobject_s(objectref, {17505, 17530, 17514, 17514, 8048, 65, 17496, 17519, 8549, var_0001, 7769})
        else
            var_0002 = add_containerobject_s(objectref, {1542, 17493, 17514, 17520, 17519, 8549, var_0001, 7769})
        end
    end
end