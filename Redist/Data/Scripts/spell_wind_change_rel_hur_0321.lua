--- Best guess: Implements the wind change spell (Rel Hur), randomly altering wind direction based on spell conditions.
function utility_spell_0321(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        destroy_object(objectref)
        bark(objectref, "@Rel Hur@")
        if check_spell_requirements() then
            var_0000 = add_containerobject_s(objectref, {68, 17496, 17511, 7781})
            var_0001 = {1, 2, 0}
            if check_spell_conditions() == 0 then --- Guess: Checks spell conditions
                var_0002 = random(2, 3)
                var_0003 = var_0001[var_0002]
                cast_spell(var_0003) --- Guess: Casts spell
            else
                cast_spell(0) --- Guess: Casts spell
            end
        else
            var_0000 = add_containerobject_s(objectref, {1542, 17493, 17511, 7781})
        end
    end
end