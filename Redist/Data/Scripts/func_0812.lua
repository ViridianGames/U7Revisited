--- Best guess: Plays music and adds items if music is not playing, possibly for ambiance or event trigger.
function func_0812(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = objectref
    var_0001 = get_object_owner(356) --- Guess: Gets item owner
    if not is_music_playing() then --- Guess: Checks music state
        var_0002 = unknown_0018H(var_0000) --- Guess: Gets position data
        var_0003 = add_containerobject_s(var_0000, {15, -2, 17419, 17441, 7737})
        play_music(25, 0) --- Guess: Plays music
        set_object_flag(var_0000, 10) --- Guess: Sets item flag
        set_object_flag(var_0001, 26) --- Guess: Sets item flag
    end
end