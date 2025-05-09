--- Best guess: Triggers an external function (ID 2064) with parameters (0, 0) when event ID 3 is received, likely part of a puzzle or dungeon trigger.
function func_06D0(eventid, itemref)
    local var_0000, var_0001

    if eventid == 3 then
        var_0000 = 0
        var_0001 = 0
        unknown_0810H(var_0001, var_0000)
    end
    return
end