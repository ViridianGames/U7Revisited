--- Best guess: Sets a quest-related property (ID 8) for all party members.
function func_0911(eventid, itemref, arg1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0001 = get_party_members() --- Guess: Gets party members
    for _, var_0004 in ipairs({2, 3, 4, 1}) do
        var_0005 = set_npc_property(8, var_0004, arg1) --- Guess: Sets NPC property
    end
end