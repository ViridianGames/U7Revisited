--- Best guess: Applies an effect to specific NPCs (85, 8, 88) when event ID 3 is triggered, likely part of a dungeon sequence.
function utility_event_0456(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 3 then
        var_0000 = {85, 8, 88}
        for i = 1, #var_0000 do
            var_0003 = var_0000[i]
            utility_unknown_1087(11, var_0003)
        end
    end
    return
end