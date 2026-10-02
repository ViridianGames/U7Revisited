--- Best guess: Randomly selects between func_0901 and func_0902 to return an NPC ID.
---@return integer npc_id The NPC ID selected randomly
function utility_random_npc_id_0901_0902_1024()
    if random(1, 10) < 4 then --- Guess: Generates random number
        return utility_find_nonparty_member_1026() --- External call to NPC selection
    else
        return utility_find_valid_npc_default_356_1025() --- External call to NPC selection
    end
end