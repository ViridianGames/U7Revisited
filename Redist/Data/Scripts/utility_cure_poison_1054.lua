--- Healer cure-poison service. Clears flag 8 (poison) when the patient is poisoned.
---@param cost integer Gold cost
---@param npc_id integer NPC id (or object ref) to cure
function utility_cure_poison_1054(cost, npc_id)
    local obj = get_npc_object_id(npc_id)
    if not obj or obj == -1 then
        obj = npc_id
    end

    -- get_item_flag returns 0/1; only nil/false are falsy in Lua, so compare to 0.
    if get_item_flag(obj, 8) ~= 0 then
        clear_item_flag(obj, 8)
        clear_item_flag(obj, 7)
        remove_party_items(true, -359, -359, 644, cost)
        add_dialogue("\"The wounds have been healed.\"")
    else
        add_dialogue("\"That individual does not need curing!\"")
    end
end
