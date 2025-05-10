--- Best guess: Implements the dispel fire spell (An Flam), extinguishing fires of specific item types with spell effects.
function func_0642(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        destroyobject_(objectref)
        var_0000 = object_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(objectref, "@An Flam@")
        if check_spell_requirements() then
            var_0002 = apply_spell_effect(540, var_0000, objectref) --- Guess: Applies spell effect
            var_0002 = add_containerobject_s(objectref, {17530, 17511, 8549, var_0001, 7769})
        else
            var_0002 = add_containerobject_s(objectref, {1542, 17493, 17511, 8549, var_0001, 7769})
        end
    elseif eventid == 4 then
        var_0003 = get_object_type(objectref)
        if var_0003 == 435 or var_0003 == 338 or var_0003 == 526 or var_0003 == 701 then
            consume_reagents(var_0003) --- Guess: Consumes reagents
            var_0002 = add_containerobject_s(objectref, {var_0003, 7765})
            unknown_000FH(46) --- Guess: Unknown spell operation
        else
            play_spell_animation(60) --- Guess: Plays spell animation
        end
    end
end