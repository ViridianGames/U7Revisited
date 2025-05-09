--- Best guess: Manages party member interactions, updating the party list based on item qualities and conditions, likely for quest or dialogue purposes.
function func_08B3(eventid)
    local var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014

    var_0001 = 1
    var_0002 = 0
    var_0003 = false
    var_0004 = unknown_0023H()
    var_0005 = unknown_0058H(eventid)
    var_0006 = unknown_0035H(0, 30, 292, eventid)
    var_0007 = {}
    var_0008 = {}
    for i = 1, #var_0006 do
        var_0011 = var_0006[i]
        if unknown_0058H(var_0011) == var_0005 then
            if not var_0003 and unknown_0014H(var_0011) == 255 then
                unknown_0046H(var_0011, 356)
                var_0004 = unknown_093CH(unknown_001BH(356), var_0004)
                var_0003 = true
            else
                table.insert(var_0008, unknown_0019H(356, var_0011))
                table.insert(var_0007, var_0011)
            end
        end
    end
    var_0012 = unknown_005EH(var_0004)
    var_0007 = unknown_093DH(var_0007, var_0008)
    for i = 1, #var_0007 do
        var_0011 = var_0007[i]
        if var_0012 >= var_0001 then
            unknown_0046H(var_0011, var_0004[var_0001])
            var_0001 = var_0001 + 1
        else
            return true
        end
    end
    return false
end