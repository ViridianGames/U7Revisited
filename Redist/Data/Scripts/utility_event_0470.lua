--- Best guess: Manages a dungeon trap, checking nearby items (type 981) and applying effects to items (type 275, quality 50) when event ID 3 is triggered.
function utility_event_0470(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 3 then
        var_0000 = find_nearby(0, 1, 981, objectref)
        var_0001 = {}
        for i = 1, #var_0000 do
            var_0004 = var_0000[i]
            var_0001 = get_distance(var_0001, objectref, var_0004)
        end
        var_0000 = utility_unknown_1085(var_0001, var_0000)
        if utility_unknown_0814(var_0000[1]) then
            var_0005 = find_nearby(16, 20, 275, objectref)
            for i = 1, #var_0005 do
                var_0008 = var_0005[i]
                if get_item_quality(var_0008) == 50 then
                    remove_item(var_0008)
                end
            end
        end
    end
    return
end