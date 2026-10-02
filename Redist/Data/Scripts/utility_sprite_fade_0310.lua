--- Best guess: Applies sprite effects and fades the palette, likely for visual transitions or effects.
function utility_unknown_0310(eventid, objectref)
    local var_0000

    set_game_state(1, 1, 12) --- Guess: Sets game state
    if get_object_ref(objectref) == 356 then --- Guess: Gets object reference
        var_0000 = get_object_position(objectref) --- Guess: Gets position data
        apply_sprite_effect(-1, 0, 0, 0, var_0000[2], var_0000[1], 7) --- Guess: Applies sprite effect
    end
end