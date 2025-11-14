--- Best guess: Checks if values in one array are within bounds defined by another array, returning false if any value is out of bounds, true otherwise.
---@param max_bounds table Array of maximum values for each index
---@param min_bounds table Array of minimum values for each index
---@param values table Array of values to check against bounds
---@return boolean in_bounds True if all values are within bounds, false otherwise
function utility_unknown_1017(max_bounds, min_bounds, values)
    local var_0003, var_0004, var_0005, var_0006

    var_0003 = {3, 2, 1}
    for _, var_0006 in ipairs(var_0003) do
        if values[var_0006] < min_bounds[var_0006] or values[var_0006] > max_bounds[var_0006] then
            return false
        end
    end
    return true
end