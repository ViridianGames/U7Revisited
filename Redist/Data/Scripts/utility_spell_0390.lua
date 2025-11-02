--- Best guess: Implements the trap spell (In Jux Por Ylem), creating a trap at a target location.
function utility_spell_0390(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 or eventid == 4 then
        destroy_object(objectref)
        var_0000 = object_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(objectref, "@In Jux Por Ylem@")
        if check_spell_requirements() then
            var_0002 = apply_spell_effect(287, var_0000, objectref) --- Guess: Applies spell effect
            var_0003 = add_containerobject_s(objectref, {17505, 17530, 17514, 17511, 17505, 17519, 17505, 8037, 65, 8536, var_0001, 7769})
        else
            var_0003 = add_containerobject_s(objectref, {1542, 17493, 17514, 17505, 17519, 17505, 8549, var_0001, 7769})
        end
    end
end