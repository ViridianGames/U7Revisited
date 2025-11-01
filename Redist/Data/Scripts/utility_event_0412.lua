--- Best guess: Manages a game mechanic, likely a gender-based event trigger, applying effects within a radius and creating items (ID 1694) based on player gender.
function utility_event_0412(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    fade_palette(1, 1, 12)
    var_0000 = get_object_position(objectref)
    sprite_effect(-1, 0, 0, 0, var_0000[2] - 2, var_0000[1] - 2, 13)
    var_0001 = get_object_position(get_npc_name(-356))
    sprite_effect(-1, 0, 0, 0, var_0001[2] - 2, var_0001[1] - 2, 7)
    play_sound_effect(68)
    var_0002 = execute_usecode_array(objectref, {1694, 8021, 8, 17447, 8033, 2, 17447, 8048, 3, 17447, 8047, 4, 7769})
    var_0003 = utility_event_0897()
    if not is_player_female() then
        var_0004 = execute_usecode_array(var_0003, {20, 7750})
    else
        var_0004 = execute_usecode_array(var_0003, {18, 7750})
    end
end