--- Best guess: Returns the player’s name based on a condition (opcode 0022H).
function func_0908(eventid, objectref)
    unknown_0022H() --- Guess: Unknown condition check
    return get_player_name() --- Guess: Gets player name
end