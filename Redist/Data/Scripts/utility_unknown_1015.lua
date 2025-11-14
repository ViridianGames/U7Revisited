--- Best guess: Checks if an NPC is in the player's party and not affected by a specific status, returning true if both conditions are met, false otherwise.
---@param npc_id integer The NPC ID to check
---@return boolean is_nearby True if the NPC is nearby and not invisible (item flag 0), false otherwise
function utility_unknown_1015(npc_id)
    local var_0001, var_0002

    var_0001 = get_npc_name(npc_id)
    var_0002 = npc_nearby(var_0001)
    if get_item_flag(0, var_0001) then
        var_0002 = false
    end
    return var_0002
end