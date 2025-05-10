--- Best guess: Randomly selects between func_0901 and func_0902 to return an NPC ID.
function func_0900(eventid, objectref)
    if random(1, 10) < 4 then --- Guess: Generates random number
        return calle_0902H() --- External call to NPC selection
    else
        return calle_0901H() --- External call to NPC selection
    end
end