--- Best guess: Manages a game mechanic checking for items (IDs 604, 729) and transforming a container (ID 641) with specific effects and sound.
function utility_music_0524(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0000 = find_nearest(1, 604, objectref)
    if not var_0000 then
        var_0001 = find_nearest(8, 729, objectref)
        if not var_0001 then
            var_0002 = _get_object_quality(var_0001)
            if var_0002 == 7 then
                var_0003 = get_object_position(var_0001)
                remove_item(var_0001)
                remove_item(var_0000)
                var_0004 = create_new_object(641)
                get_object_frame(var_0004, 30)
                var_0005 = set_item_quality(66, var_0004)
                var_0005 = update_last_created(var_0003)
                sprite_effect(-1, 0, 0, 0, var_0003[2] - 2, var_0003[1] - 1, 13)
                play_sound_effect(37)
            end
        end
    end
end