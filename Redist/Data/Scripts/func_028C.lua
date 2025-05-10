--- Best guess: Triggers an action for a barge when event ID 1 is received, likely for transportation or movement mechanics.
function func_028C(eventid, objectref)
    if eventid == 1 then
        unknown_0809H(objectref)
    end
    return
end