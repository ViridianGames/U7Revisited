--- Best guess: Checks flag 468 and triggers an effect with parameter 5 when event ID 3 is received, likely part of a dungeon sequence.
function utility_event_0471(eventid, objectref)
    if eventid == 3 then
        if not get_flag(468) then
            utility_unknown_1088(5)
            remove_item(objectref)
        end
    end
    return
end