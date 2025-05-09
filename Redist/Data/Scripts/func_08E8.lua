--- Best guess: Searches party members’ inventories for a specific item (ankh), returning the item if found or zero if not.
function func_08E8(var_0000)
    local var_0001, var_0002, var_0003, var_0004, var_0005

    var_0001 = unknown_0023H()
    for _, var_0004 in ipairs(var_0001) do
        var_0005 = unknown_002AH(var_0000, 359, 955, var_0004)
        if var_0005 then
            return var_0005
        end
    end
    return 0
end