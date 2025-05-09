--- Best guess: Triggers an explosion effect at a specific position with multiple parameters.
function func_0943(eventid, itemref, arg1)
    local var_0000, var_0001

    var_0001 = get_position_data(arg1) --- Guess: Gets position data
    create_explosion(-1, 0, -2, -2, var_0001[2], var_0001[1], 24) --- Guess: Creates explosion
end