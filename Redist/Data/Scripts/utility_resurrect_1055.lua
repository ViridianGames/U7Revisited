--- Best guess: Resurrects a character, deducting gold if successful, and displays a success or failure message.
---@param cost integer The gold cost for the resurrection service
---@param npc_id integer The NPC ID to resurrect
function utility_unknown_1055(cost, npc_id)
    local var_0000, var_0001

    var_0000 = resurrect(npc_id)
    if var_0000 then
        add_dialogue("\"Breath doth return to the body. Thy comrade is alive!\"")
        var_0001 = remove_party_items(true, -359, -359, 644, cost)
    else
        add_dialogue("\"Alas, I cannot save thy friend. I will provide a proper burial. Thou must go on and continue with thine own life.\"")
    end
end