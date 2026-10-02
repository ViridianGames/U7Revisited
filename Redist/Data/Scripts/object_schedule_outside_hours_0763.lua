--- Best guess: Triggers an NPC schedule change and external function outside 3 AM to 3 PM, possibly for a timed event.
function object_unknown_0763(eventid, objectref)
    if not in_usecode(objectref) and eventid == 1 then
        if get_time_hour() >= 15 or get_time_hour() <= 3 then
            -- calli 001D, 2 (unmapped)
            set_schedule_type(9, -232)
        end
        -- call [0000] (082FH, unmapped)
        utility_clock_0815()
    end
    return
end