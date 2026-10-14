--- fn_0902: first companion from a fixed list who is in the party, else the Avatar (-356).
--- Called on 3 of 10 dialogue rolls. Order is 10, 2, 9, 8, 7, 5, 4, 3, 1.
--- Both original checks are required: the NPC object is in the party list, and NPCInParty.
function utility_find_nonparty_member_1026()
    local candidates = {-10, -2, -9, -8, -7, -5, -4, -3, -1}
    local party_objects = {}
    for _, id in ipairs(get_party_list2() or {}) do
        local obj = get_npc_name(id)
        if obj then
            table.insert(party_objects, obj)
        end
    end

    for _, npc_id in ipairs(candidates) do
        local obj = get_npc_name(npc_id)
        if obj and is_int_in_array(obj, party_objects) and npc_id_in_party(npc_id) then
            return npc_id
        end
    end
    return -356
end
