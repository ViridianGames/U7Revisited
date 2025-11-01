--- Best guess: Updates party member states and clears item states, possibly for quest progression.
function utility_unknown_0275(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    set_flag(57, false)
    var_0000 = get_party_members()
    -- Guess: sloop updates party member states
    for i = 1, 4 do
        var_0003 = {1, 2, 3, 0}[i]
        set_schedule_type(31, var_0003) --- Guess: Sets object behavior
    end
    recall_virtue_stone(objectref) --- Guess: Clears item state
end