--- Best guess: Returns the name of a specified character ID.
function func_090F(P0)
    return get_player_name(get_npc_name(P0))
end