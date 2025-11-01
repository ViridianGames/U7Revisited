--- Best guess: Sets an NPC's training level for a given property.
function utility_unknown_1042(eventid, objectref, arg1, arg2, arg3)
    local var_0000, var_0001, var_0002, var_0003

    var_0003 = set_npc_property(arg1, get_object_owner(arg3), arg2) --- Guess: Sets NPC property
end