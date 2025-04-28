require "U7LuaFuncs"
-- Performs a bubble sort on two parallel arrays based on distance.
function func_093D(p0, p1)
    local local2, local3, local4, local5

    local2 = array_size(p1) -- Unmapped intrinsic
    if local2 <= 1 then
        return p1
    end
    local3 = true
    while local3 do
        local3 = false
        for local4 = 1, local2 - 1 do
            if p0[local4] > p0[local4 + 1] then
                local5 = p0[local4]
                p0[local4] = p0[local4 + 1]
                p0[local4 + 1] = local5
                local5 = p1[local4]
                p1[local4] = p1[local4 + 1]
                p1[local4 + 1] = local5
                local3 = true
            end
        end
    end
    return p1
end