--- Best guess: Removes party members and resets flags, possibly for party management or event cleanup.
function func_0808(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = remove_from_party(get_party_members(), 356) --- Guess: Removes from party
    var_0001 = get_party_leader() --- Guess: Gets party leader
    -- Guess: sloop resets flags for party members
    for i = 1, 5 do
        var_0004 = {2, 3, 4, 0, 17}[i]
        set_flag(57, false)
        unknown_001DH(var_0001, var_0004) --- Guess: Sets object behavior
    end
end