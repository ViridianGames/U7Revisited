--- Best guess: Disables a flag or effect when event ID 3 is triggered, likely part of a dungeon or trap deactivation.
function utility_event_0476(eventid, objectref)
    if eventid == 3 then
        run_endgame(false)
    end
    return
end