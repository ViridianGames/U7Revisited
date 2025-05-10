--- Best guess: Checks NPC properties and displays a message about health status, possibly adjusting NPC state.
function func_0603(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = set_npc_property(6, 0, objectref) --- Guess: Sets NPC property
    var_0000 = set_npc_property(6, 1, objectref) --- Guess: Sets NPC property
    var_0000 = set_npc_property(6, 2, objectref) --- Guess: Sets NPC property
    var_0001 = get_npc_property(0, objectref) --- Guess: Gets NPC property
    var_0002 = get_npc_property(0, objectref) --- Guess: Gets NPC property
    var_0003 = get_npc_property(0, objectref) --- Guess: Gets NPC property
    if var_0001 < 1 then
        unknown_0835H(1, 0, objectref) --- Guess: Sets NPC state
    end
    if var_0002 < 1 then
        unknown_0835H(1, 2, objectref) --- Guess: Sets NPC state
    end
    if var_0003 < 1 then
        unknown_0835H(1, 1, objectref) --- Guess: Sets NPC state
    end
    unknown_08FEH("@Thou dost not look well.@") --- Guess: Displays message
end