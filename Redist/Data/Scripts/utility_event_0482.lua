--- Best guess: Triggers an effect with parameter 128 when event ID 3 is received, likely a minimal dungeon trigger.
function utility_event_0482(eventid, objectref)
    if eventid == 3 then
        set_schedule_type(0, 128)
    end
    return
end