--- Best guess: Triggers an action for a barge when event ID 1 is received, likely for transportation or movement mechanics.
function object_unknown_0652(eventid, objectref)
    if eventid == 1 then
        utility_ship_0777(objectref)
    end
    return
end