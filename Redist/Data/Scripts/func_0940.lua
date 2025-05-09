--- Best guess: Initiates NPC speech, calling an external function if speech fails.
function func_0940(eventid, itemref, arg1)
    if not start_speech(arg1) then --- Guess: Starts speech
        calle_0614H(0) --- External call to unknown function
    else
        unknown_007EH() --- Guess: Unknown function
    end
end