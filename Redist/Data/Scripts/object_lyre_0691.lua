--- Best guess: Plays a specific music track (ID 58) when triggered, likely for an ambient or event-based sound effect.
function object_lyre_0691(eventid, objectref)
    if eventid == 1 then
        play_music(objectref, 58)
    end
    return
end