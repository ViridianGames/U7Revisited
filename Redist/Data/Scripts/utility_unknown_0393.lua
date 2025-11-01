--- Best guess: Damages an NPC based on property checks, likely a combat helper function.
function utility_unknown_0393(eventid, objectref)
    local var_0000, var_0001

    var_0000 = get_npc_property(2, objectref) --- Guess: Gets NPC property
    var_0001 = get_npc_property(3, objectref) --- Guess: Gets NPC property
    if check_npc_flag(16, var_0000) then --- Guess: Checks NPC flag
        damage_npc(objectref, var_0001 - 1) --- Guess: Damages NPC
        damage_npc(objectref, 50) --- Guess: Damages NPC
    end
end