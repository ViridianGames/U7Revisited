--- Best guess: Removes an NPC from the party if they are a member and a specific flag is set, updating their state.
function func_093F(P0, P1)
    local var_0000

    var_0000 = _GetPartyMembers()
    if unknown_0939H(P1) and table.contains(var_0000, P1) and get_flag(57) then
        unknown_001DH(P0, P1)
    end
end