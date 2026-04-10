--- Best guess: Triggers effects on nearby items (type 873, within 20 units) based on their frame, cycling through specific sequences in a dungeon trap.
function utility_unknown_0438(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    debug_print("STARTED FUNCTION 0438")

    --if eventid == 3 then
    play_sound_effect(28)
    var_0000 = find_nearest_chair(0)
    if var_0000 then
        var_0001 = get_object_frame(var_0000)
        var_0002 = var_0001 % 4
        if var_0002 >= 3 then
            var_0001 = var_0001 - 3
        else
            var_0001 = var_0001 + 1
        end
        set_object_frame(var_0000, var_0001)
    end
    --end
end