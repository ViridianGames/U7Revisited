--- Best guess: Checks if an item (P7) matches a specific frame (P6) and position (P5) near a pedestal (P8), triggering an action (081DH) if conditions are met.
function func_081E(P0, P1, P2, P3, P4, P5, P6, P7, P8)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F

    var_0009 = func_0018(P8)
    var_000A = var_0009[P5]
    var_000B = func_0035(0, 7, P7, P8)
    var_000C = false
    for var_000D in ipairs(var_000B) do
        if func_081B(0, var_000F) == P6 and var_0009[P5] == var_000A then
            var_000C = true
            break
        end
    end
    if not var_000C then
        var_000C = func_081D(P0, P1, P2, P3, P4, var_000F)
    end
end