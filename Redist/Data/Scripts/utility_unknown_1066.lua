--- Best guess: Adjusts a character's health (NPC property 3) by adding or subtracting damage, ensuring it stays within bounds.
function utility_unknown_1066(P0, P1)
    local var_0000, var_0001, var_0002

    if not is_npc(P1) then
        var_0000 = get_npc_quality(0, P1)
        var_0001 = get_npc_quality(3, P1)
        if var_0001 + P0 < 1 then
            var_0000 = -1 * var_0001
        elseif var_0001 + P0 > var_0000 then
            var_0000 = var_0000 - var_0001
        end
        var_0002 = set_npc_quality(var_0000, 3, P1)
    end
end