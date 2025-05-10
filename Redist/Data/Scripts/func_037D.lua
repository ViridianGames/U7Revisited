--- Best guess: Modifies item properties based on quality and event ID, applying random or specific effects.
function func_037D(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        var_0000 = _get_object_quality(itemref)
        var_0001 = unknown_0033H()
        unknown_0086H(itemref, 90)
        if var_0000 == 1 then
            unknown_0089H(var_0001, 1)
        elseif var_0000 == 2 then
            var_0002 = random2(10, 1)
            var_0003 = 13 - var_0002
            unknown_092AH(var_0001, var_0003)
        elseif var_0000 == 3 then
            unknown_008AH(var_0001, 8)
            unknown_008AH(var_0001, 7)
            unknown_008AH(var_0001, 1)
            unknown_008AH(var_0001, 2)
            unknown_008AH(var_0001, 3)
        elseif var_0000 == 4 then
            unknown_0089H(var_0001, 8)
        elseif var_0000 == 5 then
            unknown_008AH(var_0001, 1)
        elseif var_0000 == 6 then
            unknown_0089H(var_0001, 9)
        elseif var_0000 == 7 then
            unknown_0057H(100)
        elseif var_0000 == 8 then
            unknown_0089H(var_0001, 0)
        end
    end
    return
end