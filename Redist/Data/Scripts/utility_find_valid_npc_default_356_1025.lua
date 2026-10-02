--- Pick a party companion NPC id (not the Avatar), or Avatar ref 356 if alone.
--- Used by various usecode helpers; decompiled filter_party_members call was incomplete.

function filter_party_members(party_list, exclude)
    local out = {}
    if type(party_list) ~= "table" then
        return out
    end
    for _, member in ipairs(party_list) do
        if member ~= nil and member ~= exclude then
            table.insert(out, member)
        end
    end
    return out
end

function utility_unknown_1025()
    -- Prefer numeric party NPC ids when available
    local party_ids = (get_party_list2 and get_party_list2()) or {}
    for _, id in ipairs(party_ids) do
        if type(id) == "number" and id ~= 0 and id ~= 356 and id ~= -356 then
            return id
        end
    end

    -- Fallback: names from get_party_members → resolve to ids
    local names = (get_party_members and get_party_members()) or {}
    local avatar_name = get_player_name and get_player_name() or nil
    for _, name in ipairs(names) do
        if name and name ~= avatar_name and get_npc_id_from_name then
            local id = get_npc_id_from_name(name)
            if id and id ~= 0 then
                return id
            end
        end
    end

    return 356 -- Avatar usecode ref
end
