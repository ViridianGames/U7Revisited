--- Best guess: Checks a condition (opcode 0044H) to return true/false.
function utility_unknown_1030(eventid, objectref)
    if get_weather() == 3 then --- Guess: Unknown condition check
        return false
    else
        return true
    end
end