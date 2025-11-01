--- Best guess: Manages NPC health and combat status, updating stats and destroying items if needed.
function utility_unknown_0867(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    var_0000 = objectref
    var_0001 = get_combat_status() --- Guess: Checks combat status
    if var_0001 then
        var_0002 = get_player_stat(1) --- Guess: Gets player stat (health)
        if var_0002 <= 0 then
            -- Guess: sloop checks party members
            for i = 1, 5 do
                var_0005 = {2, 3, 4, 1, 31}[i]
                var_0006 = get_npc_property(1, var_0005) --- Guess: Gets NPC property (health)
                if var_0006 <= 0 then
                    destroyobject_(var_0005) --- Guess: Destroys item
                end
            end
        else
            set_player_stat(1, var_0002 - 1) --- Guess: Sets player stat (health)
        end
    end
end