-- This script handles the harpsichord: when triggered, plays the harpsichord's instrument track (ID 57).
function object_harpsichord_0689(eventid, objectref)

    if eventid == 1 then

        play_instrument(objectref, 57)

    end

    return

end

