--- Best guess: Triggers an effect with parameter 359 when event ID 3 is received, likely part of a dungeon or trap sequence.
function utility_event_0474(eventid, objectref)
    if eventid == 3 then
        utility_unknown_0822(359, objectref)
    end
    return
end