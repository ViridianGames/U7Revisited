--- Best guess: Randomly selects between func_0901 and func_0902 to return an NPC ID.
---@return integer npc_id The NPC ID selected randomly
function utility_unknown_1024()
    if random(1, 10) < 4 then --- Guess: Generates random number
        return utility_unknown_1026() --- External call to NPC selection
    else
        return utility_unknown_1025() --- External call to NPC selection
    end
end