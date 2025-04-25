-- Negates an array's elements by incrementing indices.
function func_082B(p0, p1)
    local local2

    local2 = 0
    while local2 ~= p0 do
        local2 = local2 + 1
        p1[local2] = -p1[local2]
    end
    return p1
end