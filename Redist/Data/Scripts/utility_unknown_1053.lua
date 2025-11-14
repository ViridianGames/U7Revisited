--- Best guess: Heals a character's wounds, restoring health to maximum if injured, deducting gold, and displaying appropriate messages.
---@param cost integer The gold cost for the healing service
---@param npc_id integer The NPC ID to heal
function utility_unknown_1053(cost, npc_id)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = utility_unknown_1040(0, npc_id)
    var_0001 = utility_unknown_1040(3, npc_id)
    var_0002 = get_player_name(npc_id)
    if var_0000 > var_0001 then
        var_0003 = var_0000 - var_0001
        var_0004 = utility_unknown_1042(var_0003, 3, npc_id)
        var_0005 = remove_party_items(true, -359, -359, 644, cost)
        add_dialogue("\"The wounds have been healed.\"")
    elseif npc_id == -356 then
        add_dialogue("\"Thou seemest quite healthy!\"")
    else
        add_dialogue("\"" .. var_0002 .. " is already healthy!\"")
    end
end