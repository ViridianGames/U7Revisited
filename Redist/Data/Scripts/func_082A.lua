--- Best guess: Increments an array index and accumulates values from P2, adding P1 values, returning the modified array P2.
function func_082A(P0, P1, P2)
    local var_0000, var_0001, var_0002, var_0003

    var_0003 = 0
    while var_0003 ~= P0 do
        var_0003 = var_0003 + 1
        P2[var_0003] = P2[var_0003] + P1[var_0003]
    end
    return P2
end