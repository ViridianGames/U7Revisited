--- Best guess: Randomly applies an effect to party members based on item quality when event ID 3 is triggered, likely part of a dungeon trap.
function utility_event_0447(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 3 then
        var_0000 = get_party_list2()
        var_0001 = get_object_quality(objectref)
        for i = 1, #var_0000 do
            var_0004 = var_0000[i]
            var_0005 = die_roll(var_0001, 1)
            utility_unknown_1078(var_0004, var_0005)
        end
    end
    return
end