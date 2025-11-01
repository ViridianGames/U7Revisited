-- Evaluates training ability, checking gold and training level caps, returning 0 (insufficient experience), 1 (insufficient gold), 2 (maxed out), or 3 (can train).
function utility_unknown_1058(training_points_required, npc_id, cost_to_train, stat_to_train)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    debug_print("Starting function 0922")
    debug_print("training points required: " .. training_points_required)
    debug_print("npc_id: " .. npc_id)
    debug_print("cost to train: " .. cost_to_train)
    debug_print("stat to train: " .. stat_to_train)
    var_0004 = false
    var_0005 = get_npc_training_points(npc_id)
    debug_print("Training points: " .. var_0005)
    var_0006 = get_party_gold()
    -- Return - not enough money
    if var_0006 <= cost_to_train then
        debug_print("Not enough gold")
        return 1
    end
    -- Return - not enough training points
    if var_0005 < training_points_required then
        debug_print("No training points")
        return 0
    end
    -- Return - stat level maxed out
    var_000A = get_npc_training_level(npc_id, stat_to_train)
    if var_000A < 30 then
        debug_print("Too high skill")
        var_0004 = true
    end
    if not var_0004 then
        return 2
    end
    -- Return - can train
    debug_print("Can train")
    return 3
end