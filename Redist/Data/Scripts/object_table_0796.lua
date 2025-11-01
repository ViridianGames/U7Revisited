--- Best guess: Triggers an action for an item when event ID 1 is received, likely for a generic interactable object.
function object_table_0796(eventid, objectref)
    if eventid == 1 then
        utility_ship_0777(objectref)
    end
    return
end