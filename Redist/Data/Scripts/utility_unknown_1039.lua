--- Best guess: Returns the name of a specified character ID.
---@param npc_id integer The NPC ID to get the name for
---@return string player_name The player/character name
function utility_unknown_1039(npc_id)
    return get_npc_name(npc_id)
end