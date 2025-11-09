--- Best guess: Plays a specific music track (ID 39) when triggered by event ID 1, likely for an ambient or event-based sound effect.
function object_unknown_0267(eventid, objectref)
    if eventid == 1 then
        play_music(objectref, 39)
    end
    return
end