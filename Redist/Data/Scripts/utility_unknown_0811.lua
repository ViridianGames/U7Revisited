--- Best guess: Negates values in an array (P1) at specified indices, returning the modified array.
function utility_unknown_0811(P0, P1)
    local var_0000, var_0001, var_0002

    var_0002 = 0
    while var_0002 ~= P0 do
        var_0002 = var_0002 + 1
        P1[var_0002] = P1[var_0002] * -1
    end
    return P1
end