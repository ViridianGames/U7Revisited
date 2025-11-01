--- Best guess: Sets flag 695 when event ID 3 is triggered, likely part of a dungeon or event trigger.
function utility_event_0452(eventid, objectref)
    if eventid == 3 then
        set_flag(695, true)
    end
    return
end