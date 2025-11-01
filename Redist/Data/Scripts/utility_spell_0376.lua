--- Best guess: Implements the shape-shift spell (Rel Ylem), transforming an item (type 915) with visual effects.
function utility_spell_0376(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        destroyobject_(objectref)
        var_0000 = object_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(objectref, "@Rel Ylem@")
        if check_spell_requirements() and get_object_type(var_0000) == 915 then
            var_0002 = add_containerobject_s(objectref, {17511, 8037, 66, 8536, var_0001, 7769})
            var_0003 = get_object_position(var_0000) --- Guess: Gets position data
            apply_sprite_effect(-1, 0, 0, 0, var_0003[2], var_0003[1], 13) --- Guess: Applies sprite effect
            var_0004 = add_containerobject_s(var_0000, {5, 1656, 17493, 7715})
        else
            var_0002 = add_containerobject_s(objectref, {1542, 17493, 17511, 8549, var_0001, 7769})
        end
    else
        var_0005 = set_object_count(1, objectref) --- Guess: Sets item count
        var_0005 = var_0005 * 10
        set_object_type(645, objectref) --- Guess: Sets item type
        var_0005 = set_object_weight(var_0005, objectref) --- Guess: Sets item weight
    end
end