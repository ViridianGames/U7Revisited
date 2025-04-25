-- Retrieves names of party members.
function func_08FB()
    local party_members = get_party_members()
    local names = {}
    for _, member in ipairs(party_members) do
        table.insert(names, get_player_name(member)) -- Unmapped intrinsic
    end
    return names
end