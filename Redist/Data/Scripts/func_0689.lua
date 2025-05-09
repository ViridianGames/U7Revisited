--- Best guess: Damages an NPC based on property checks, likely a combat helper function.
function func_0689(eventid, itemref)
    local var_0000, var_0001

    var_0000 = get_npc_property(2, itemref) --- Guess: Gets NPC property
    var_0001 = get_npc_property(3, itemref) --- Guess: Gets NPC property
    if check_npc_flag(16, var_0000) then --- Guess: Checks NPC flag
        damage_npc(itemref, var_0001 - 1) --- Guess: Damages NPC
        damage_npc(itemref, 50) --- Guess: Damages NPC
    end
end