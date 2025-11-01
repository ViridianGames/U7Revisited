--- Best guess: Checks flag 343 and triggers an effect with parameter 3 when event ID 3 is received, likely part of a dungeon sequence.
function utility_event_0472(eventid, objectref)
    if eventid == 3 then
        if not get_flag(343) then
            utility_unknown_1088(3)
            remove_item(objectref)
        end
    end
    return
end