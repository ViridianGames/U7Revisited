--- Best guess: Filters party members to find a valid NPC, defaulting to 356 if none found.
function utility_unknown_1025(eventid, objectref)
    local var_0000, var_0001, var_0002

    var_0000 = filter_party_members(get_party_members(), get_object_owner(356)) --- Guess: Filters party members
    var_0001 = array_size(var_0000) --- Guess: Gets array size
    if var_0001 ~= 0 then
        var_0002 = get_party_member(var_0001) --- Guess: Gets party member
        if not npc_in_party(var_0002) then --- Guess: Checks if NPC is in party
            return var_0002
        end
    end
    return 356
end