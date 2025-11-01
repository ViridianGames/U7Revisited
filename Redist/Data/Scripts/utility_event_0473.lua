--- Best guess: Checks flag 142 and triggers an effect with parameter 4 when event ID 3 is received, likely part of a dungeon sequence.
function utility_event_0473(eventid, objectref)
    if eventid == 3 then
        if not get_flag(142) then
            utility_unknown_1088(4)
            remove_item(objectref)
        end
    end
    return
end