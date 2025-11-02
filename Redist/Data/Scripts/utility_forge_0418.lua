--- Best guess: Attempts to modify items in a dungeon forge but fails, displaying an error message and reverting to a previous state by calling func_06A0.
function utility_forge_0418(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    var_0000 = find_nearby(16, 10, 275, objectref)
    for i = 1, 5 do
        var_0004 = get_object_quality(var_0003)
        var_0005 = get_object_frame(var_0003)
        var_0006 = get_object_position(var_0003)
        if var_0005 == 6 then
            if var_0004 == 3 then
                var_0007 = create_new_object(675)
                set_object_frame(16, var_0007)
                var_0008 = var_0006
                var_0009 = update_last_created(var_0008)
                sprite_effect(1, 0, 0, 0, var_0006[2] - 2, var_0006[1] - 2, 13)
            elseif var_0004 == 7 then
                var_000A = create_new_object(999)
                set_object_frame(1, var_000A)
                var_0009 = update_last_created(var_0006)
                sprite_effect(1, 0, 0, 0, var_0006[2] - 2, var_0006[1] - 1, 13)
            end
        end
    end
    var_000B = execute_usecode_array(1696, {8021, 14, 7463, "@NO!, No. No...@", 8018, 6, 7719}, objectref)
    play_sound_effect(68)
    return
end