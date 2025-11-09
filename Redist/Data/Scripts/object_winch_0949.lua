--- Best guess: Calls an external function (ID 083EH) for a winch interaction, possibly for a mechanical or environmental effect.
function object_winch_0949(eventid, objectref)
    -- calli 007E, 0 (unmapped)
    close_gumps()
    -- call [0000] (083EH, unmapped)
    utility_event_0830(eventid, objectref)
    return
end