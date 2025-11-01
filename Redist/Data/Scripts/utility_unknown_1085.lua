--- Best guess: Sorts an array of distances using bubble sort, returning the sorted array.
function utility_unknown_1085(P0, P1)
    local var_0000, var_0001, var_0002

    var_0000 = get_#P1
    var_0001 = true
    if var_0000 <= 1 then
        var_0001 = false
    end
    while var_0001 do
        var_0001 = false
        for var_0002 = 1, var_0000 - 1 do
            if P0[var_0002] > P0[var_0002 + 1] then
                var_0003 = P0[var_0002]
                P0[var_0002] = P0[var_0002 + 1]
                P0[var_0002 + 1] = var_0003
                var_0004 = P1[var_0002]
                P1[var_0002] = P1[var_0002 + 1]
                P1[var_0002 + 1] = var_0004
                var_0001 = true
            end
        end
    end
    return P1
end