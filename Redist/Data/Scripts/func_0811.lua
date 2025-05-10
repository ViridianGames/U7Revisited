--- Best guess: Adds party members to the party with flag settings, likely for event initialization.
function func_0811(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = remove_from_party(get_party_members(), 356) --- Guess: Removes from party
    -- Guess: sloop adds party members with flags
    for i = 1, 5 do
        var_0003 = {1, 2, 3, 0, 17}[i]
        set_flag(57, true)
        unknown_001DH(15, var_0003) --- Guess: Sets object behavior
    end
end