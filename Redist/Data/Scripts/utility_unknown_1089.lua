--- Best guess: Similar to func_0940, checks speech status and calls an external function if speech fails.
function utility_unknown_1089(eventid, objectref, arg1)
    if not check_speech_status(arg1) then --- Guess: Checks speech status
        utility_clock_0276(0) --- External call to unknown function
    else
        close_gumps() --- Guess: Unknown function
    end
end