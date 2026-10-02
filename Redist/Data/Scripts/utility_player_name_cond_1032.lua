--- Best guess: Returns the player's name based on a condition (opcode 0022H).
function utility_player_name_cond_1032()
    get_avatar_ref() --- Guess: Unknown condition check
    return get_player_name() --- Guess: Gets player name
end