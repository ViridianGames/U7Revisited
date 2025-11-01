--- Best guess: Sets flag 290 and applies an effect to specific NPCs (IDs 90, 92, 86, 87) when triggered by event ID 3, likely part of a dungeon sequence.
function utility_event_0427(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 3 then
        set_flag(290, true)
        var_0000 = {90, 92, 86, 87}
        for i = 1, #var_0000 do
            var_0003 = var_0000[i]
            set_schedule_type(11, var_0003)
        end
    end
    return
end