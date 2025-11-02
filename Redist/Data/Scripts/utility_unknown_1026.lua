--- Best guess: Iterates over negative indices to find a party member not in the party, defaulting to 356.
function utility_unknown_1026(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0000 = {10, 2, 9, 8, 7, 5, 4, 3, 1}
    var_0001 = get_party_members() --- Guess: Gets party members
    for _, var_0004 in ipairs({2, 3, 4, 0}) do
        if is_int_in_array(get_object_owner(var_0004), var_0001) and not npc_in_party(var_0004) then --- Guess: Checks if NPC is in party
            return var_0004
        end
    end
    return 356
end