--- Best guess: Initializes multiple training levels for an NPC (properties 2 and 7).
---@param amount integer The number of training iterations to apply
---@param npc_id integer The NPC ID to apply training to
function utility_unknown_1046(amount, npc_id)
    local var_0000, var_0001, var_0002, var_0003

    var_0002 = 0
    while var_0002 < amount do
        var_0003 = get_training_level(2, npc_id) --- Guess: Gets training level
        set_training_level(2, npc_id, 1) --- Guess: Sets training level
        set_training_level(7, npc_id, -1) --- Guess: Sets training level
        var_0002 = var_0002 + 1
    end
end