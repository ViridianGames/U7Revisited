--- Best guess: Similar to func_0937, checks NPC flags and properties, returning true if any condition is met.
function utility_unknown_1080(eventid, objectref, arg1)
    local var_0000

    var_0000 = utility_unknown_1081(arg1) --- External call to func_0939
    if check_object_flag(var_0000, 1) or --- Guess: Checks item flag
       check_object_flag(var_0000, 7) or --- Guess: Checks item flag
       check_object_flag(var_0000, 4) or --- Guess: Checks item flag
       get_npc_property(3, var_0000) <= 0 then --- Guess: Gets NPC property
        return true
    end
    return false
end