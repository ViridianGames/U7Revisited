--- Best guess: Returns a display name for an NPC id / usecode ref / name string.
function utility_get_character_name_1039(npc_ref)
    if type(npc_ref) == "string" then
        return npc_ref
    end
    if type(npc_ref) ~= "number" then
        return "friend"
    end

    local npc_id = npc_ref
    if npc_id < 0 and npc_id > -256 then
        npc_id = -npc_id
    elseif npc_id == 356 or npc_id == -356 then
        npc_id = 0
    end

    if npc_id == 0 then
        return get_player_name()
    end

    local party_names = get_party_members()
    if type(party_names) == "table" then
        for _, name in ipairs(party_names) do
            if get_npc_id_from_name(name) == npc_id then
                return name
            end
        end
    end

    local known = {
        [1] = "Iolo",
        [2] = "Spark",
        [3] = "Shamino",
        [4] = "Dupre",
        [5] = "Jaana",
        [7] = "Sentri",
        [8] = "Julia",
        [9] = "Katrina",
        [10] = "Tseramed",
    }
    return known[npc_id] or "friend"
end
