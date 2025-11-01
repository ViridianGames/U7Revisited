--- Best guess: Triggers an external function (ID 2064) with parameters (0, 0) when event ID 3 is received, likely part of a puzzle or dungeon trigger.
function utility_event_0464(eventid, objectref)
    local var_0000, var_0001

    if eventid == 3 then
        var_0000 = 0
        var_0001 = 0
        utility_unknown_0784(var_0001, var_0000)
    end
    return
end