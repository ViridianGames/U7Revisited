--- Best guess: Implements the sleep spell (An Zu), targeting a party member and applying a sleep effect with animation.
function utility_spell_0320(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        destroy_object(objectref)
        var_0000 = object_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(objectref, "@An Zu@")
        if check_spell_requirements() and var_0000[1] ~= 0 then
            var_0002 = add_containerobject_s(objectref, {17511, 8037, 64, 8536, var_0001, 7769})
        else
            var_0002 = add_containerobject_s(objectref, {1542, 17493, 17511, 8549, var_0001, 7769})
        end
    elseif eventid == 2 then
        if is_object_valid(objectref) then --- Guess: Checks item validity
            clear_item_flag(1, objectref) --- Guess: Sets quest flag
        else
            play_spell_animation(60) --- Guess: Plays spell animation
        end
    end
end