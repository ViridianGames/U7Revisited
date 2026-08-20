--- Paws proximity/flag egg: advance the venom framing beat.
--- Engine must call this with eventid == 3 (usecode egg hatch).

function utility_event_0454(eventid, objectref)
    debug_print("utility_event_0454: eventid=" .. tostring(eventid) ..
        " objectref=" .. tostring(objectref))
    if eventid == 3 then
        utility_paws_check_frame_ready()
    end
    return
end
