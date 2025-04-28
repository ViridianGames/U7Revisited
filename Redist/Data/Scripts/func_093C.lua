require "U7LuaFuncs"
-- Filters an array by removing a specific value.
function func_093C(p0, p1)
    local local2, local3, local4, local5

    local2 = {}
    for local3, local4 in ipairs(p0) do
        local5 = local4
        if local5 ~= p1 then
            table.insert(local2, local5)
        end
    end
    return local2
end