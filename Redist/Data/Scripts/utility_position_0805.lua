--- Best guess: Adjusts array indices based on comparison, possibly for position alignment.
function utility_position_0805(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    var_0000 = objectref
    var_0001 = arg1
    var_0002 = arg2
    if var_0002[var_0000] >= var_0001[var_0000] then
        if var_0000 == 1 then
            var_0003 = 4658
            var_0004 = 4662
        elseif var_0000 == 2 then
            var_0003 = 4656
            var_0004 = 4660
        end
        if var_0002[var_0000] == var_0001[var_0000] then
            var_0005 = 4
        else
            var_0005 = 3
        end
    else
        if var_0000 == 1 then
            var_0003 = 4662
            var_0004 = 4658
        elseif var_0000 == 2 then
            var_0003 = 4660
            var_0004 = 4656
        end
        var_0005 = -3
    end
    var_0002[var_0000] = var_0002[var_0000] + var_0005
    if get_npc_property(3, 356) > 0 then --- Guess: Gets NPC property
        var_0006 = add_containerobject_s(356, {1, 17447, 8045, 3, 17447, 8558, var_0004, 7769})
    end
    return var_0002
end