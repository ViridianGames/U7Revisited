--- Best guess: Manages a sextant, checking nearby items and triggering a quest event if conditions (e.g., flag 407) are met.
function object_unknown_0888(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        if get_object_frame(objectref) == 1 then
            play_music(objectref, 48)
            var_0000 = find_nearby(0, 125, 888, objectref) --- Guess: Creates an object with specified parameters
            var_0000 = utility_unknown_1084(objectref) --- Guess: Retrieves nearby items
            if array_size(var_0000) == 1 then
                var_0001 = get_object_position(objectref) --- Guess: Retrieves object position or attributes
                var_0002 = get_object_position(var_0000) --- Guess: Retrieves object position or attributes
                var_0003 = var_0001[1] < var_0002[1]
                var_0004 = get_flag(407)
                if var_0003 == var_0004 then
                    var_0005 = find_nearby(0, 100, 155, 356) --- Guess: Creates an object with specified parameters
                    if var_0005 then
                        set_camera(var_0005) --- Guess: Updates object state
                        utility_unknown_0284(get_barge(var_0005)) --- Guess: Handles quest-specific event; Guess (0058H): Gets object's owner
                    end
                end
            end
        else
            play_music(objectref, 24)
        end
    end
end