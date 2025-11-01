--- Best guess: Sets flag 2 and triggers an action with value 1000 when event ID 3 is received and flag 2 is not set, likely part of a dungeon trigger.
function utility_event_0424(eventid, objectref)
    if eventid == 3 and not get_flag(2) then
        utility_unknown_1041(1000)
        set_flag(2, true)
    end
    return
end