--- Best guess: Sets flag 9 when triggered by event ID 3, likely part of a dungeon forge sequence.
function utility_event_0425(eventid, objectref)
    if eventid == 3 then
        set_flag(9, true)
    end
    return
end