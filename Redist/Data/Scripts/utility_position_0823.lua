--- Best guess: Moves an item to a new location with offset, checking position and container validity.
function utility_position_0823(eventid, objectref, arg1, arg2, arg3, arg4)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    var_0000 = eventid
    var_0001 = arg1
    var_0002 = arg2
    var_0003 = arg3
    var_0004 = arg4
    var_0005 = get_object_position(var_0003) --- Guess: Gets position data
    var_0005[1] = var_0005[1] + var_0002
    var_0005[2] = var_0005[2] + var_0001
    var_0005[3] = var_0005[3] + var_0000
    var_0006 = get_object_container(objectref) --- Guess: Gets item container
    var_0007 = get_object_position(objectref) --- Guess: Gets position data
    var_0008 = set_last_created(objectref) --- Guess: Checks position
    if spawn_object_at(get_object_type(objectref), var_0005) then --- Guess: Spawns item at position
        if not var_0008 then
            update_last_created(var_0005) --- Guess: Updates position
            play_sound_effect(73) --- Guess: Triggers event
            return 1
        elseif not var_0006 then
            if not get_object_position(var_0006) then --- Guess: Gets item position
                return 0
            end
        elseif update_last_created(var_0007) then --- Guess: Updates position
            return 0
        end
    end
    return 0
end