--- Best guess: Triggers explosions based on item state, possibly for traps or environmental hazards.
function utility_unknown_0402(eventid, objectref)
    local var_0000, var_0001, var_0002

    var_0000 = get_container(objectref) --- Guess: Gets item state
    if not var_0000 then
        var_0001 = get_object_position(objectref) --- Guess: Gets position data
        var_0002 = set_last_created(objectref) --- Guess: Checks position
        if not get_object_position(356) then --- Guess: Gets item position
            var_0002 = update_last_created(var_0001) --- Guess: Updates position
            trigger_explosion(5) --- Guess: Triggers explosion
        end
    else
        var_0002 = set_last_created(objectref) --- Guess: Checks position
        if not get_object_position(356) then --- Guess: Gets item position
            var_0002 = get_object_position(var_0000) --- Guess: Gets item position
            trigger_explosion(5) --- Guess: Triggers explosion
        end
    end
end