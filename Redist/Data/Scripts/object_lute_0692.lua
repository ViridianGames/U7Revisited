-- This script handles the lute: when triggered, plays the lute's instrument track (ID 59).



function object_lute_0692(eventid, objectref)

    if eventid == 1 then

        play_instrument(objectref, 59)

    end

    return

end

