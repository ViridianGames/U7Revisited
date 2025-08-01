--- Best guess: Manages a combat training session with Markus, teaching sword techniques and potentially increasing combat ability, with gold and experience checks.
function func_08BD(cost_to_train, stat_to_train)
    local npc_name, npc_id, npc_reference, training_points_required, var_0006, party_gold, var_0008, var_0009
    training_points_required = 1
    npc_name = func_0920()
    npc_id = get_npc_id_from_name(npc_name)
    if npc_id == 0 then
        npc_reference = "you"
    else
        npc_reference = npc_name
    end
    var_0006 = func_0922(training_points_required, npc_id, cost_to_train, stat_to_train)
    if var_0006 == 0 then
        add_dialogue("\"I am afraid thou dost not have enough practical experience to train at this time. If thou couldst return at a later date, I would be most happy to provide thee with my services.\"")
        return
    elseif var_0006 == 1 then
        party_gold = get_party_gold()
        add_dialogue("You gather your gold and count it. You have " .. party_gold .. " altogether.")
        if party_gold < cost_to_train then
            add_dialogue("Markus stretches. He shrugs and says, \"I regret that thou dost not have enough gold to meet my price. Perhaps later, when thou hast made thy fortune pillaging the land...\"")
            return
        end
    end
    add_dialogue("You pay " .. cost_to_train .. " gold, and the training session begins.")
    if var_0006 == 2 then
        add_dialogue("Markus blinks and seems to come out of his boredom. \"Thou art already as proficient as I! Thou cannot be trained further here.\"")
        add_dialogue("Markus returns the gold.")
        return
    end
    var_0008 = remove_party_gold(cost_to_train)
    add_dialogue("\"Very well,\" Markus says, stifling a yawn. \"Here we go.\"")
    add_dialogue("Markus wields his sword and faces " .. npc_reference .. ". He gives " .. npc_reference .. " a few pointers in stance and balance, then demonstrates some sample thrusts.")
    add_dialogue("Before long, " .. npc_reference .. " and the trainer are trading blows with weapons. He is obviously very good at what he does, and the experience is valuable to " .. npc_reference .. ".")
    add_dialogue("When the session is over, it is felt that there has been a gain in combat ability.")
    var_0009 = get_npc_training_level(npc_id, 4)
    if var_0009 < 30 then
        increase_npc_combat_level(npc_id, 1)
        return
    end
    return
end