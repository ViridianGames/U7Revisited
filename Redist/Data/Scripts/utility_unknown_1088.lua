--- Best guess: Initiates NPC speech, calling an external function if speech fails.
function utility_unknown_1088(eventid, objectref, arg1)
    if not start_speech(arg1) then --- Guess: Starts speech
        utility_clock_0276(0) --- External call to unknown function
    else
        close_gumps() --- Guess: Unknown function
    end
end