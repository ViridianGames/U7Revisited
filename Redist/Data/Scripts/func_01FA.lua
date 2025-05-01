-- Function 01FA: Batlin's dialogue after Hook's death
function func_01FA(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    if eventid ~= 2 then
        return
    end

    switch_talk_to(26, 0)
    say("Batlin watches Hook's death with icy resignation. Time seems to slow as he turns to you. \"This battle is not done, Avatar. Dost thou imagine thyself an immortal? The Guardian is far more. Return to your precious Earth and rest.~Sleep, that he may visit your dreams with countless visions of death in the belly of the Great Sea Serpent.\"")
    say("\"As for me, I shall begone! Thou shalt never find me! Farewell, Avatar!\"")
    _HideNPC(-26)
    local0 = callis_0035(0, 40, 403, -356)
    -- Note: Original has 'db 4b' here, possibly a debug artifact, ignored
    calle_0639H(local0[1])

    return
end

-- Helper function (assumed to be defined elsewhere)
function say(message)
    print(message) -- Adjust to your dialogue system
end