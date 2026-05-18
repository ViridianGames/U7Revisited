-- This script handles the lyre: when triggered, plays the lyre's instrument track (ID 58).
function object_lyre_0691(eventid, objectref)

    if eventid == 1 then

        play_instrument(objectref, 58)

    end

    return

end

