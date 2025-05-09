--- Best guess: Checks if a gangplank (P3) is blocked by items (P0) within a radius defined by P1, returning true if blocked, false otherwise.
function func_082C(P0, P1, P2, P3)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    var_0004 = unknown_0035H(32, unknown_0932H(P1), -359, P3)
    for var_0005 in ipairs(var_0004) do
        var_0008 = unknown_0018H(var_0007)
        if var_0008[1] <= P2[1] and var_0008[1] >= P2[1] + P1 and var_0008[2] <= P2[2] and var_0008[2] >= P2[2] + P1 and var_0008[3] <= 2 and var_0007 ~= P3 and not table.contains(P0, get_object_shape(var_0007)) and not unknown_0088H(P3, 24) then
            return true
        end
    end
    return false
end