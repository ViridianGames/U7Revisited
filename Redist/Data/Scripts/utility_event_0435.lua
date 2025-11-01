--- Best guess: Triggers external functions (IDs 338, 701, 526) for party members when event ID 3 is received, likely part of a dungeon environmental effect.
function utility_event_0435(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 3 then
        play_sound_effect(28)
        var_0000 = get_item_quality(objectref)
        var_0001 = find_nearby(0, var_0000, 338, objectref)
        for i = 1, #var_0001 do
            var_0004 = var_0001[i]
            object_light_0338(var_0004)
        end
        var_0001 = find_nearby(0, var_0000, 701, objectref)
        for i = 1, #var_0001 do
            var_0004 = var_0001[i]
            object_light_0701(var_0004)
        end
        var_0001 = find_nearby(0, var_0000, 526, objectref)
        for i = 1, #var_0001 do
            var_0004 = var_0001[i]
            object_unknown_0526(var_0004)
        end
    end
    return
end