--- Best guess: Similar to func_0940, checks speech status and calls an external function if speech fails.
function func_0941(eventid, objectref, arg1)
    if not check_speech_status(arg1) then --- Guess: Checks speech status
        calle_0614H(0) --- External call to unknown function
    else
        unknown_007EH() --- Guess: Unknown function
    end
end