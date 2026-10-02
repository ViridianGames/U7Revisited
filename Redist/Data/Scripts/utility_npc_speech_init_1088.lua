--- Best guess: Initiates NPC speech, calling an external function if speech fails.
---@param npc_id integer The NPC ID to start speech with
function utility_unknown_1088(npc_id)
    if not start_speech(npc_id) then --- Guess: Starts speech
        utility_clock_0276() --- External call to unknown function
    else
        close_gumps() --- Guess: Unknown function
    end
end