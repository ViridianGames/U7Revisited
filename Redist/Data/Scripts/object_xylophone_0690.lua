-- This script handles the xylophone: when triggered, plays the xylophone's instrument track (ID 56).
function object_xylophone_0690(eventid, objectref)

    if eventid == 1 then

        play_instrument(objectref, 56)

    end

    return

end

