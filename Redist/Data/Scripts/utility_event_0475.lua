--- Best guess: Triggers an external function (ID 2084) when event ID 3 is received, likely part of a dungeon or trap sequence.
function utility_event_0475(eventid, objectref)
    if eventid == 3 then
        utility_unknown_0804(objectref)
    end
    return
end