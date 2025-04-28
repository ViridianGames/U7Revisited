require "U7LuaFuncs"
-- Compares values across three arrays and returns true if all conditions are met.
function func_08F9(p0, p1, p2)
    local local3, local4, local5, local6

    local3 = {3, 2, 1}
    for local4, local5 in ipairs(local3) do
        local6 = local5
        if p2[local6] < p1[local6] or p2[local6] > p0[local6] then
            return false
        end
    end
    return true
end