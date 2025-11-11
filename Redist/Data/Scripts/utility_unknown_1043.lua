--- Best guess: Counts iterations until a target value is matched, returning the count.
function utility_unknown_1043(arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0002 = 0
    for _, var_0005 in ipairs({3, 4, 5, 0}) do
        var_0002 = var_0002 + 1
        if arg2 == var_0005 then
            return var_0002
        end
    end
    return 0
end