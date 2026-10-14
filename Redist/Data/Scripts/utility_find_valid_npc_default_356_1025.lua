--- fn_0901: one random party companion, else the Avatar (-356).
--- Called on the other 7 of 10 dialogue rolls. The Avatar object is removed first.
--- A companion who fails NPCInParty is not replaced; the Avatar speaks instead.
function utility_find_valid_npc_default_356_1025()
    local companions = {}
    for _, id in ipairs(get_party_list2() or {}) do
        if id ~= 0 and id ~= 356 and id ~= -356 then
            local obj = get_npc_name(id)
            if obj then
                table.insert(companions, obj)
            end
        end
    end

    if #companions == 0 then
        return -356
    end

    local npc_id = get_npc_number(companions[random(1, #companions)])
    if type(npc_id) == "number" and npc_id >= 0 and npc_id_in_party(npc_id) then
        return npc_id
    end
    return -356
end
