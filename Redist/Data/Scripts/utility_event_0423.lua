--- Best guess: Sets flag 1 and triggers an action with value 1000 when event ID 3 is received and flag 1 is not set, likely part of a dungeon trigger.
function utility_event_0423(eventid, objectref)
    if eventid == 3 and not get_flag(1) then
        utility_unknown_1041(1000)
        set_flag(1, true)
    end
    return
end