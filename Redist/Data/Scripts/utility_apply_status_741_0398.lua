--- Best guess: Applies a game effect or status (ID 741) to an entity (ID -356), triggering an external function (0837H) and creating items (IDs 1679, 46) if successful, likely for a specific event or interaction.
function utility_event_0398(eventid, objectref)
    local var_0000, var_0001, var_0002

    var_0000 = find_nearest(5, 741, get_npc_name(-356))
    if not var_0000 then
        utility_position_0823(2, 0, 0, var_0000, objectref)
        var_0001 = get_object_position(objectref)
        sprite_effect(-1, 0, 0, 0, var_0001[2] - 3, var_0001[1] - 3, 9)
        play_sound_effect(46)
        var_0002 = execute_usecode_array(objectref, {1679, 8021, 8, 7750})
        var_0002 = execute_usecode_array(var_0000, {2, -1, 17419, 7760})
    end
end