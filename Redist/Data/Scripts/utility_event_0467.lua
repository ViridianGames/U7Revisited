--- Best guess: Triggers an external function (ID 2064) with parameters (1, 1) when event ID 3 is received, part of a puzzle sequence.
function utility_event_0467(eventid, objectref)
    local var_0000, var_0001

    if eventid == 3 then
        var_0000 = 1
        var_0001 = 1
        utility_unknown_0784(var_0001, var_0000)
    end
    return
end