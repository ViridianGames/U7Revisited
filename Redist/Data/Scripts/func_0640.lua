--- Best guess: Implements the sleep spell (An Zu), targeting a party member and applying a sleep effect with animation.
function func_0640(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        destroy_item(itemref)
        var_0000 = item_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(itemref, "@An Zu@")
        if check_spell_requirements() and var_0000[1] ~= 0 then
            var_0002 = add_container_items(itemref, {17511, 8037, 64, 8536, var_0001, 7769})
        else
            var_0002 = add_container_items(itemref, {1542, 17493, 17511, 8549, var_0001, 7769})
        end
    elseif eventid == 2 then
        if is_item_valid(itemref) then --- Guess: Checks item validity
            unknown_008AH(1, itemref) --- Guess: Sets quest flag
        else
            play_spell_animation(60) --- Guess: Plays spell animation
        end
    end
end