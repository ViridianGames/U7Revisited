--- Best guess: Adjusts a character's health (NPC property 3) by adding or subtracting damage, ensuring it stays within bounds.
---@param amount integer The amount to adjust health by (positive for healing, negative for damage)
---@param npc_id integer The NPC ID to adjust health for
function utility_unknown_1066(amount, npc_id)
    local var_0000, var_0001, var_0002

    if not is_npc(npc_id) then
        var_0000 = get_npc_quality(0, npc_id)
        var_0001 = get_npc_quality(3, npc_id)
        if var_0001 + amount < 1 then
            var_0000 = -1 * var_0001
        elseif var_0001 + amount > var_0000 then
            var_0000 = var_0000 - var_0001
        end
        var_0002 = set_npc_quality(var_0000, 3, npc_id)
    end
end