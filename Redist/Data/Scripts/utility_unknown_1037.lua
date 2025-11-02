--- Best guess: Prompts the user to select a party member or “Nobody”, returning the selected member's ID or 0, starting with the party leader.
function utility_unknown_1037(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = _GetPartyLeader()
    var_0001 = get_party_members()
    var_0002 = {0, 0}
    var_0003 = _SelectIndex({var_0000, "Nobody"})
    var_0004 = var_0002[var_0003]
    if var_0004 == 0 then
        return 0
    end
    return unknown_003AH(var_0004)
end