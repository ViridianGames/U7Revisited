--- Best guess: Implements the fire field spell (Vas Flam), creating a damaging fire field at a target location.
function func_0652(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 or eventid == 4 then
        destroyobject_(objectref)
        var_0000 = object_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(objectref, "@Vas Flam@")
        if check_spell_requirements() then
            var_0002 = apply_spell_effect(856, var_0000, objectref) --- Guess: Applies spell effect
            var_0003 = add_containerobject_s(objectref, {17505, 17530, 17514, 17514, 17520, 8047, 65, 8536, var_0001, 7769})
        else
            var_0003 = add_containerobject_s(objectref, {1542, 17493, 17514, 17520, 8559, var_0001, 7769})
        end
    end
end