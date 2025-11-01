--- Best guess: Sets flag 151 when event ID 3 is triggered, likely part of a dungeon or event trigger.
function utility_event_0453(eventid, objectref)
    if eventid == 3 then
        set_flag(151, true)
    end
    return
end