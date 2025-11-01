--- Best guess: Triggers an effect with parameter 0 when event ID 3 is received, likely part of a dungeon or trap sequence.
function utility_event_0478(eventid, objectref)
    if eventid == 3 then
        utility_unknown_0822(0, objectref)
    end
    return
end