--- Best guess: Cures poison for a character, checking if they are poisoned, deducting gold, and displaying a success or failure message.
---@param cost integer The gold cost for the cure service
---@param npc_id integer The NPC ID to cure
function utility_unknown_1054(cost, npc_id)
    local var_0000, var_0001

    var_0000 = get_npc_name(npc_id)
    if not get_item_flag(8, var_0000) then
        clear_item_flag(8, var_0000)
        var_0001 = remove_party_items(true, -359, -359, 644, cost)
        add_dialogue("\"The wounds have been healed.\"")
    else
        add_dialogue("\"That individual does not need curing!\"")
    end
end