--- Best guess: Compares item attributes across a list, updating a value to the smallest attribute.
function utility_unknown_1077(arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0002 = arg2[1]
    for _, var_0005 in ipairs({3, 4, 5, 1}) do
        if compare_object_attribute(var_0005, arg1) < compare_object_attribute(var_0002, arg1) then --- Guess: Compares item attributes
            var_0002 = var_0005
        end
    end
    return var_0002
end