--- Best guess: Checks if values in one array are within bounds defined by another array, returning false if any value is out of bounds, true otherwise.
function utility_unknown_1017(var_0000, var_0001, var_0002)
    local var_0003, var_0004, var_0005, var_0006

    var_0003 = {3, 2, 1}
    for _, var_0006 in ipairs(var_0003) do
        if var_0002[var_0006] < var_0001[var_0006] or var_0002[var_0006] > var_0000[var_0006] then
            return false
        end
    end
    return true
end