--- Best guess: Checks item type (668) and triggers explosions, possibly for a trap or ritual effect.
function func_0717(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    if get_item_type(itemref) == 668 then --- Guess: Gets item type
        var_0000 = unknown_0018H(itemref) --- Guess: Gets position data
        var_0001 = unknown_0025H(itemref) --- Guess: Checks position
        if not get_item_position(356) then --- Guess: Gets item position
            var_0002 = unknown_0026H(var_0000) --- Guess: Updates position
            trigger_explosion(5) --- Guess: Triggers explosion
        end
    else
        var_0002 = get_container_items(359, 668, 359, 4) --- Guess: Gets container items
        var_0003 = unknown_006EH(var_0002) --- Guess: Gets item state
        var_0001 = unknown_0025H(var_0002) --- Guess: Checks position
        if not get_item_position(356) then --- Guess: Gets item position
            var_0002 = get_item_position(var_0003) --- Guess: Gets item position
            trigger_explosion(5) --- Guess: Triggers explosion
        end
    end
    calle_0838H(itemref) --- External call to unknown function
end