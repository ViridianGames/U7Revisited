--- Best guess: Sets flag 0 and triggers an action with value 1000 when event ID 3 is received and flag 0 is not set, likely part of a dungeon trigger.
function utility_event_0422(eventid, objectref)
    if eventid == 3 and not get_flag(0) then
        utility_unknown_1041(1000)
        set_flag(0, true)
    end
    return
end