--- Best guess: Triggers an action for an item when event ID 1 is received, likely part of a quest or environmental interaction.
function object_unknown_0301(eventid, objectref)
    if eventid == 1 then
        utility_ship_0777(objectref)
    end
    return
end