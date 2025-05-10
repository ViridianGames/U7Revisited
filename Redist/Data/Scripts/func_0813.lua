--- Best guess: Handles NPC feeding (e.g., garlic, type 842), adjusting NPC properties with dialogue responses.
function func_0813(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    var_0000 = objectref
    var_0001 = arg1
    var_0002 = arg2
    var_0003 = object_select_modal() --- Guess: Selects item
    var_0004 = get_party_members()
    if table.contains(var_0004, var_0003) and not _CheckNPCStatus(1, var_0003) and not _CheckNPCStatus(7, var_0003) and not _CheckNPCStatus(4, var_0003) then
        var_0005 = get_npc_property(9, var_0003) --- Guess: Gets NPC property
        var_0006 = var_0005 + var_0001
        if var_0005 > 24 then
            var_0007 = "@No, thank thee.@"
        else
            consumeobject_(var_0002) --- Guess: Consumes item
            set_object_behavior(var_0000, var_0000) --- Guess: Sets item behavior
            apply_object_effect(var_0002) --- Guess: Applies item effect
            var_0008 = random(1, 10)
            if var_0005 <= 4 then
                if var_0006 <= 4 then
                    var_0007 = "@More!@"
                    if var_0008 >= 6 then
                        var_0007 = "@I must have more!@"
                    end
                elseif var_0006 < 10 then
                    var_0007 = "@I am still hungry.@"
                    if var_0008 >= 6 and var_0003 ~= 356 then
                        var_0007 = "@May I have some more?@"
                    end
                elseif var_0006 < 20 then
                    if get_object_type(var_0002) == 842 then
                        var_0007 = "@Yum, garlic!@"
                    else
                        var_0007 = "@Ah yes, much better.@"
                    end
                else
                    var_0007 = "@That hit the spot!@"
                    if var_0008 >= 6 then
                        var_0007 = "@Burp@"
                    end
                end
            elseif var_0005 < 20 then
                if get_object_type(var_0002) == 842 then
                    var_0007 = "@Yum, garlic!@"
                else
                    var_0007 = "@Ahh, very tasty.@"
                end
                if var_0006 > 24 and var_0008 >= 3 then
                    var_0007 = "@Belch@"
                end
            else
                if get_flag(155) and var_0008 >= 2 then
                    var_0007 = "@I'll soon be plump.@"
                elseif var_0008 >= 5 then
                    var_0007 = "@I'll soon be plump.@"
                end
            end
        end
        if var_0007 ~= "" and is_object_valid_for_use(var_0003) then
            bark(var_0003, var_0007) --- Guess: Item says dialogue
        end
        var_0009 = set_npc_property(9, var_0001, var_0003) --- Guess: Sets NPC property
    end
end