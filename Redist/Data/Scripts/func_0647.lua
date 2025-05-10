--- Best guess: Implements the summon spell (Vas Kal), spawning a creature with visual effects.
function func_0647(eventid, objectref)
    local var_0000

    if eventid == 1 then
        destroyobject_(objectref)
        bark(objectref, "@Vas Kal@")
        if check_spell_requirements() then
            var_0000 = add_containerobject_s(objectref, {62, 17496, 17514, 7785})
        else
            var_0000 = add_containerobject_s(objectref, {1542, 17493, 17514, 7785})
        end
    end
end