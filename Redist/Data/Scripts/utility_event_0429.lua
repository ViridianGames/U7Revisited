--- Best guess: Triggers an external function (ID 704) for the item when event ID 3 is received, likely part of a dungeon interaction.
function utility_event_0429(eventid, objectref)
    if eventid == 3 then
        object_powderkeg_0704(objectref)
    end
    return
end