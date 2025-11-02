--- Best guess: Triggers effects on nearby items (type 873, within 20 units) based on their frame, cycling through specific sequences in a dungeon trap.
function utility_unknown_0438(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 3 then
        play_sound_effect(28)
        var_0000 = find_nearby(0, 20, 873, objectref)
        var_0001 = {}
        for i = 1, #var_0000 do
            var_0001 = get_distance(var_0001, var_0000[i], objectref)
        end
        var_0000 = utility_unknown_1085(var_0001, var_0000)
        var_0004 = var_0000[1]
        if var_0004 then
            var_0005 = get_object_frame(var_0004)
            var_0006 = var_0005 % 4
            if var_0006 >= 3 then
                var_0007 = execute_usecode_array({8014, 83, 7768}, var_0004)
            else
                var_0005 = var_0005 - var_0006
                var_0007 = execute_usecode_array({var_0005, 8006, 83, 7768}, var_0004)
            end
        end
    end
    return
end