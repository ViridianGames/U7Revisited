--- Best guess: Implements the untrap spell (Des Sanct), disarming traps on a selected target with spell effects.
function func_0658(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        destroyobject_(objectref)
        var_0000 = object_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(objectref, "@Des Sanct@")
        if check_spell_requirements() and var_0000[1] ~= 0 then
            var_0002 = apply_spell_effect(281, var_0000, objectref) --- Guess: Applies spell effect
            var_0003 = add_containerobject_s(objectref, {17530, 17514, 17520, 8037, 67, 8536, var_0001, 7769})
        else
            var_0003 = add_containerobject_s(objectref, {1542, 17493, 17514, 17520, 8549, var_0001, 7769})
        end
    end
end