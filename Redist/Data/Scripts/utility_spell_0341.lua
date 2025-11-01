--- Best guess: Implements the protection spell (Uus Sanct), applying a protective effect to a target with visual effects.
function utility_spell_0341(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        destroyobject_(objectref)
        var_0000 = object_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(objectref, "@Uus Sanct@")
        if check_spell_requirements() and is_object_valid(var_0000) then
            var_0002 = add_containerobject_s(objectref, {17514, 17509, 8047, 109, 8536, var_0001, 7769})
            var_0003 = add_containerobject_s(var_0000, {5, 1621, 17493, 7715})
            var_0004 = get_object_position(var_0000) --- Guess: Gets position data
            apply_protection_effect(-1, 0, 0, 0, -2, -2, 13, objectref) --- Guess: Applies protection effect
        else
            var_0002 = add_containerobject_s(objectref, {1542, 17493, 17514, 17509, 8559, var_0001, 7769})
        end
    elseif eventid == 2 then
        set_object_flag(objectref, 9) --- Guess: Sets item flag
    end
end