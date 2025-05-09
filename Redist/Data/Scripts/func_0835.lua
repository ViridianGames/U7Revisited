--- Best guess: Adjusts an NPC property by subtracting a value, likely for stat management.
function func_0835(eventid, itemref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = eventid
    var_0001 = arg1
    var_0002 = arg2
    var_0003 = get_npc_property(var_0001, var_0002) --- Guess: Gets NPC property
    var_0004 = set_npc_property(var_0001, var_0002, var_0003 - var_0000) --- Guess: Sets NPC property
end