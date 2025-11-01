--- Best guess: Removes an NPC from the party if they are a member and a specific flag is set, updating their state.
function utility_unknown_1087(P0, P1)
    local var_0000

    var_0000 = get_party_members()
    if utility_unknown_1081(P1) and table.contains(var_0000, P1) and get_flag(57) then
        set_schedule_type(P0, P1)
    end
end