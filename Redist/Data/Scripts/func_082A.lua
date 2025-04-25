-- Updates an array of coordinates by incrementing indices.
function func_082A(p0, p1, p2)
    local local3

    local3 = 0
    while local3 ~= p0 do
        local3 = local3 + 1
        p2[local3] = p2[local3] + p1[local3]
    end
    return p2
end