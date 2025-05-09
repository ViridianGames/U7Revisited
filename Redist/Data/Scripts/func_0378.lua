--- Best guess: Manages a sextant, checking nearby items and triggering a quest event if conditions (e.g., flag 407) are met.
function func_0378(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        if get_object_frame(itemref) == 1 then
            play_music(itemref, 48)
            var_0000 = unknown_0035H(0, 125, 888, itemref) --- Guess: Creates an object with specified parameters
            var_0000 = unknown_093CH(itemref) --- Guess: Retrieves nearby items
            if array_size(var_0000) == 1 then
                var_0001 = unknown_0018H(itemref) --- Guess: Retrieves object position or attributes
                var_0002 = unknown_0018H(var_0000) --- Guess: Retrieves object position or attributes
                var_0003 = var_0001[1] < var_0002[1]
                var_0004 = get_flag(407)
                if var_0003 == var_0004 then
                    var_0005 = unknown_0035H(0, 100, 155, 356) --- Guess: Creates an object with specified parameters
                    if var_0005 then
                        unknown_0092H(var_0005) --- Guess: Updates object state
                        unknown_061CH(unknown_0058H(var_0005)) --- Guess: Handles quest-specific event; Guess (0058H): Gets object’s owner
                    end
                end
            end
        else
            play_music(itemref, 24)
        end
    end
end