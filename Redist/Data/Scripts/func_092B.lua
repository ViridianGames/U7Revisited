require "U7LuaFuncs"
-- Increments a counter based on an input parameter.
function func_092B(p0, p1)
    local local1, local2, local3, local4

    local1 = 0
    for local2, local3 in ipairs(p1) do
        local4 = local3
        local1 = local1 + 1
    end
    return local1
end